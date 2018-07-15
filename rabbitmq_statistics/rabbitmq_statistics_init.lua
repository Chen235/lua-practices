
--字符串分割函数
--传入字符串和分隔符，返回分割后的table
function string.split(str, delimiter)
	if str==nil or str=='' or str==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

local shared_dict_rabbitmq_statistics = ngx.shared.shared_dict_rabbitmq_statistics;

local file_log = io.open('/Data/servers/openresty/nginx/html/rabbitmq_statistics.log','r');
assert(file_log);
local msg = file_log:read();

if msg then
	local list = string.split(msg,'&&');

	-- 初始化到html
	-- local file_statistics = io.open('/Data/servers/openresty/nginx/html/rabbitmq_statistics.html','a');
	-- assert(file_statistics);

	for k,v in pairs(list) do
		if v ~= nil and v ~= '' then
			local ss = string.split(v,";");
			shared_dict_rabbitmq_statistics:set(ss[1],v); -- 添加到缓存

			-- 初始化到html
			-- file_statistics:write('<tr><td>' .. ss[1] .. '</td>');
			-- file_statistics:write('<td>' .. ss[2] .. '</td>');
			-- file_statistics:write('<td>' .. ss[3] .. '</td>');
			-- file_statistics:write('<td>' .. ss[4] .. '</td>');
			-- file_statistics:write('<td>' .. ss[5] .. '</td>');
			-- file_statistics:write('<td>' .. ss[6] .. '</td>');
			-- file_statistics:write('<td>' .. ss[7] .. '</td></tr>');

		end
	end

	-- 初始化到html
	-- file_statistics:flush();
	-- file_statistics:close();

end