local shared_dict_counter = ngx.shared.shared_dict_counter;
local shared_dict_record = ngx.shared.shared_dict_record;

local file_path = '/usr/local/openresty/nginx/logs/activity_counter.log';

-- 逐行读取文件
for line in io.lines(file_path) do
	ngx.log(ngx.ERR, 'activity_mobile_init Line : ' .. line);
	if line and line ~= '' and line ~= ngx.null then
		-- 解析行，获取活动编码及统计数据
		local index = string.find(line, ':');
		local activity_code = string.sub(line,0,index-1); -- 活动编码
		local activity_counter = string.sub(line,index+1); -- 统计数据
		ngx.log(ngx.ERR,'activity_mobile_init activity_code : ' .. activity_code .. ' , activity_counter : ' .. activity_counter);

		-- 将活动统计数据加入缓存
		--local activity_counter_code = 'activity_counter_' .. activity_code;
		local ok,err = shared_dict_counter:set(activity_code,tonumber(activity_counter));
		if not ok then
			ngx.log(ngx.ERR, 'failed to save activity_counter : ', err);
		end
		-- 将活动统计数据加入记录缓存
		--local activity_record_code = 'activity_record_' .. activity_code;
		local ok,err = shared_dict_record:set(activity_code,tonumber(activity_counter));
		if not ok then
			ngx.log(ngx.ERR, 'failed to save activity_record : ', err);
		end
	end
end