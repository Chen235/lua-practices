local delay = 60;
local record_data;

local shared_dict_counter = ngx.shared.shared_dict_counter;
local shared_dict_record = ngx.shared.shared_dict_record;

record_data = function ()
	
	local keys = shared_dict_counter:get_keys();
	local file = io.open('/usr/local/openresty/nginx/logs/activity_counter.log','w');
	assert(file);
	file:write('');

	for k,v in pairs(keys) do
		
		-- 统计活动数据
		local counter = shared_dict_counter:get(v);
		if not counter then
			counter = 0;
		end

		local record = shared_dict_record:get(v);
		if not record then
			record = 0;
		end
		
		ngx.log(ngx.ERR, v ..'_counter : ' .. counter .. ' , ' .. v ..'_record : ' .. record);

		-- 记录一分钟内的请求数量
		local xe = tonumber(counter) - tonumber(record);
		ngx.log(ngx.ERR,v .. ' minute statistics : ' ,xe);

		-- 将当前总请求量保存到activity_record
		local ok,err = shared_dict_record:set(v,counter);
		if not ok then
			ngx.log(ngx.ERR,'failed to save ' .. v .. ' : ',err);
		end
		
		local write_str = '';
		if k == 1 then
			write_str = v .. ':' .. counter;
		else
			write_str = '\n' .. v .. ':' .. counter;
		end
		-- 将当前总请求量记录到文件
		file:write(write_str);
	end
	file:close();

	-- 添加定时任务
	local ok,err = ngx.timer.at(delay,record_data);
	if not ok then
		ngx.log(ngx.ERR,'failed to create the timer: ',err);
		return
	end
end

-- 首次添加定时任务
local ok,err = ngx.timer.at(delay,record_data)
if not ok then
	ngx.log(ngx.ERR,'failed to create the timer: ',err);
	return
end

ngx.say('OK');
return ngx.exit(ngx.HTTP_OK);