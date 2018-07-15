--
-- User: CJT
-- Date: 2016/6/20
-- Time: 19:24
--

local resty_lock = require("resty.lock");

local uri = ngx.var.uri;
local index = string.find(uri, "com");
-- 公共资料访问
if index then
    local url = string.sub(uri,6);
    -- 从ShareDic缓存获取数据
    local value,flags = fdfsSecurityDB:get(uri);
    if value then
        ngx.exec(secureMark .. url);
        return ngx.exit(ngx.HTTP_OK);
    end
    ngx.log(ngx.ERR,'Get Public FdfsSecurityDB uri='..uri..' value is Null !');
    
    -- 获取锁
    local lock = resty_lock:new("share_lock");
    local elapsed,err = lock:lock(uri);
    if not elapsed then
        ngx.log(ngx.ERR,"failed to acquire the lock: ", err);
        local redis = get_redis();
        local value = get_cache_redis(redis,uri);
        if value then
            fdfsSecurityDB:set(uri,url);
            ngx.exec(secureMark .. url);
            return ngx.exit(ngx.HTTP_OK);
        end
    end
    ngx.log(ngx.ERR,"Lock Key Successful !!!");

    -- 再次从缓存中获取数据
    local value, flags = fdfsSecurityDB:get(uri);
    if value then
        lock:unlock();--释放锁
        ngx.exec(secureMark .. url);
        return ngx.exit(ngx.HTTP_OK);
    end

    -- 从redis缓存中获取数据
    local redis = get_redis();
    local value = get_cache_redis(redis,uri);
    if value then
        fdfsSecurityDB:set(uri,url);
        lock:unlock();--释放锁
        ngx.exec(secureMark .. url);
        return ngx.exit(ngx.HTTP_OK);
    end
    lock:unlock();--释放锁
    ngx.log(ngx.ERR,'Get Public RedisValue uri='..uri..', value is Null !');
    return ngx.exit(ngx.HTTP_FORBIDDEN);
end

local key = ngx.var.key;
-- 隐私资料访问
if key then
    local redis = get_redis();
    local value,flags = fdfsSecurityDB:get(key);
    if value then
        -- 删除缓存
        fdfsSecurityDB:delete(key);
        del_cache_redis(redis,key);
        ngx.exec(secureMark .. uri);
        return ngx.exit(ngx.HTTP_OK);
    end
    ngx.log(ngx.ERR,'Get Private FdfsSecurityDB key='..key..', value Is Null! ');

    local value = get_cache_redis(key);
    if value then
        del_cache_redis(redis,key);
        ngx.exec(secureMark .. uri);
        return ngx.exit(ngx.HTTP_OK);
    end
    close_redis(redis);
    ngx.log(ngx.ERR,'Get Private RedisValue key='..key..', value Is null, err='..err);
    return ngx.exit(ngx.HTTP_FORBIDDEN);
end

return ngx.exit(ngx.HTTP_FORBIDDEN);