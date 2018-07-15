local cjson = require "cjson";

local shared_dict_counter = ngx.shared.shared_dict_counter;

local code = ngx.var.arg_code;
if not code then
	code = 'mobile';
end

local activity_code = 'activity_' .. code;

-- 获取活动总次数
local counter = shared_dict_counter:get(activity_code);
-- 若为首次请求，则将总次数置为0
if not counter then
	local ok,err = shared_dict_counter:set(activity_code,0);
	if not ok then
		ngx.log(ngx.ERR, 'failed to save '.. activity_code ..' : ', err);
		ngx.say(cjson.encode({code='0100'}));
		return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR);
	end
end

-- 总次数+1
local value, err = shared_dict_counter:incr(activity_code,1);
if not value then
	ngx.log(ngx.ERR,'failed to incr '.. activity_code ..' :' , err);
	ngx.say(cjson.encode({code='0100'}));
	return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR);
end

ngx.say(cjson.encode({code='0000'}));
return ngx.exit(ngx.HTTP_OK);