local uri = ngx.var.uri;

local url = uri;

local index = string.find(uri, "el0805055fdfs");
if index then
   url = string.sub(url, index+14);
end

local index2 = string.find(url, "userData");
if index2 then
   url = string.sub(url, index2+9);
end

ngx.exec('/' .. url);
