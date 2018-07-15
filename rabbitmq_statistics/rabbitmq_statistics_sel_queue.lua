-- RabbitMQ 统计查询队列信息

local rabbitmq_queuename; -- 队列名

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
	end
end

local shared_dict_rabbitmq_statistics = ngx.shared.shared_dict_rabbitmq_statistics;

local value = shared_dict_rabbitmq_statistics:get(rabbitmq_queuename);

ngx.say(value);