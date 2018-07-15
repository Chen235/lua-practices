--
-- User: CJT
-- Date: 2016/6/20
-- Time: 19:34
--

local uri = ngx.var.uri;

local url = uri;

local index = string.find(uri, "secure");
if index then
    url = string.sub(url, index+7);
end

local index2 = string.find(url, "userData");
if index2 then
    url = string.sub(url, index2+9);
end

ngx.exec(secureMark .. url);