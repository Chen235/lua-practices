-- 将该代码注入到nginx的access处理阶段，进行控制
-- 使用 access_by_lua 或者 access_by_lua_file

local limit_req = require('resty.limit.req');
local cjson = require "cjson";

local RET_CODE_SUCCESS = '0000'; -- 成功
local RET_CODE_FAIL_SYS_EXCEPT = "FS00101"; --系统服务异常
local RET_CODE_FAIL_SYS_FDFS_EXCEPT = "FS00102"; --存储服务异常
local RET_CODE_FAIL_SYS_USER_OVERMUCH = "FS00103"; --当前用户过多
local RET_CODE_FAIL_PARAM_LOST = "FS00201"; -- 参数异常
local RET_CODE_SESSION_LOST = "FS00301"; -- session失效

local rate = 200; -- 每秒处理的数量
local burst = 300; -- 总容量=并发数+延迟处理数量
local nodelay = false --是否需要不延迟处理

local limit, err = limit_req.new('share_limit_upload',rate,burst); -- share_limit_req 为共享内存(lua_shared_dict)
if not limit then
	ngx.log(ngx.ERR,'failed to instantiate a resty.limit.req object: ', err);
	ngx.say(cjson.encode({code=RET_CODE_FAIL_SYS_EXCEPT, tip='服务异常，请稍后再试！', returnResult=ngx.null, returnSign=ngx.null}));
	return ngx.exit(ngx.HTTP_OK);
end

local key = ngx.var.host; -- 用户ip维度做限流,也可用uri、domain等其他维度

-- 参数：key：限流维度。true:将相关请求记录到共享内存中。false：不记录
-- 返回值：delay 延迟的秒数。 excess 超过的数量
-- 若当前正在处理的数量+当前延迟处理的数量 = 阈值，则该请求返回 nil, rejected
local delay, excess = limit:incoming(key, true);
if not delay then
	if excess == 'rejected' then
		ngx.log(ngx.ERR,'rejected request !');
		ngx.say(cjson.encode({code=RET_CODE_FAIL_SYS_USER_OVERMUCH, tip='当前用户过多，请稍后再试！', returnResult=ngx.null, returnSign=ngx.null}));
		return ngx.exit(ngx.HTTP_OK);
	end
	ngx.log(ngx.ERR,'failed to limit req: ', excess);
	ngx.say(cjson.encode({code=RET_CODE_FAIL_SYS_EXCEPT, tip='服务异常，请稍后再试！', returnResult=ngx.null, returnSign=ngx.null}));
	ngx.exit(ngx.HTTP_OK);
end

--ngx.log(ngx.ERR,'------------' .. delay);
--ngx.log(ngx.ERR,'============' .. excess);

if delay > 0 then
	local excess = excess;
	if nodelay then
		-- 不做延迟操作
	else
		-- 延迟处理
		ngx.sleep(delay);
	end
end
