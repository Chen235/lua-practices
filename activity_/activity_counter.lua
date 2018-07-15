local cjson = require "cjson"

local shared_dict_counter = ngx.shared.shared_dict_counter;
local code = ngx.var.arg_code;
if not code then
	code = 'mobile';
end

local activity_code = 'activity_' .. code;

-- 获取记录总数
local counter = shared_dict_counter:get(activity_code);
if not counter then
	counter = 0;
end

ngx.say(cjson.encode({counter=counter}));
return ngx.exit(ngx.HTTP_OK);