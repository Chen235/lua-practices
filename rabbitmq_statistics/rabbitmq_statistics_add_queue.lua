-- local rabbitmq_exchange = ngx.var.arg_exchange;
-- local rabbitmq_routingkey = ngx.var.arg_routingkey;
local rabbitmq_queuename; -- 队列名
local rabbitmq_vhost; -- vhost
local rabbitmq_business_msg; -- 业务描述
local rabbitmq_business_group; -- 所属业务组
local rabbitmq_system; -- 所属系统
local rabbitmq_leader; -- 负责人
local rabbitmq_createtime; -- 创建时间

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
if not args then
 ngx.say("获取Post参数失败 : ", err);
 return ngx.exit(200);
end

-- 解析参数
for key, val in pairs(args) do
	if key == 'queuename' then
		rabbitmq_queuename = val;
	elseif 	key == 'vhost' then
		rabbitmq_vhost = val;
	elseif key == 'business_msg' then
		rabbitmq_business_msg = val;
	elseif key == 'business_group' then
		rabbitmq_business_group = val;
	elseif key == 'system' then
		rabbitmq_system = val;
	elseif key == 'leader' then
		rabbitmq_leader = val;
	elseif key == 'createtime' then
		rabbitmq_createtime = val;
	end
end

if rabbitmq_createtime == nil or rabbitmq_createtime == '' or rabbitmq_createtime == ngx.null  then
	rabbitmq_createtime = os.date('%Y-%m-%d');
end

local value = rabbitmq_queuename .. ';' .. rabbitmq_vhost .. ';' .. rabbitmq_business_msg .. ';' .. rabbitmq_business_group .. ';' 
				.. rabbitmq_system .. ';' .. rabbitmq_leader .. ';' .. rabbitmq_createtime;

local shared_dict_rabbitmq_statistics = ngx.shared.shared_dict_rabbitmq_statistics;

shared_dict_rabbitmq_statistics:set(rabbitmq_queuename,value); -- 添加到缓存

-- 添加到日志文件（用户记录和初始化缓存使用）
local file_log = io.open('/Data/servers/openresty/nginx/html/rabbitmq_statistics.log','a');
assert(file_log);
file_log:write(value .. '&&');
file_log:flush();
file_log:close();

-- 添加到html文件（用户前台展示）
local file = io.open('/Data/servers/openresty/nginx/html/rabbitmq_statistics.html','a');
assert(file);

file:write('<tr><td>' .. rabbitmq_queuename .. '</td>');
file:write('<td>' .. rabbitmq_vhost .. '</td>');
file:write('<td>' .. rabbitmq_business_msg .. '</td>');
file:write('<td>' .. rabbitmq_business_group .. '</td>');
file:write('<td>' .. rabbitmq_system .. '</td>');
file:write('<td>' .. rabbitmq_leader .. '</td>');
file:write('<td>' .. rabbitmq_createtime .. '</td></tr>');

file:flush();
file:close();

ngx.say('OK');