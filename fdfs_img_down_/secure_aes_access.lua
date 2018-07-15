local aes = require "resty.aes"

local key = 'w6l0v5qrc0meuki0';
local hash = {
	iv = "b0isye20iyo006pu",
	method = nil
}

--local strmark = 'secure';

local aes_128_cbc, err = aes:new(key, nil, aes.cipher(128,"cbc"), hash)
if err then
    ngx.log(ngx.ERR,err);
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR);
end

local uri = ngx.var.uri;
--local index = string.find(uri,strmark);
local aes_str = string.sub(uri,18);
aes_str = string.gsub(aes_str,'-','+');
aes_str = string.gsub(aes_str,'_','/');
aes_str = string.gsub(aes_str,'%.jpg','');
local index2 = string.find(aes_str,'*');
if index2 then
	local length = string.sub(aes_str,index2+4,index2+4);
	local str = '';
	for i=1,length,1 do
		str = str .. '=';
	end
	aes_str = string.sub(aes_str,0,index2-1) .. str;
end
--ngx.say(aes_str);

local file_path = aes_128_cbc:decrypt(ngx.decode_base64(aes_str));
--ngx.say(file_path);
if not file_path then
	ngx.log(ngx.ERR,'AESUrl :' .. aes_str .. ' Decode Error !');
	return ngx.exit(ngx.HTTP_FORBIDDEN);
end

local group = string.match(file_path,'group');
local video = string.match(file_path,'video');
local file = string.match(file_path,'file');
local upload = string.match(file_path,'upload');
if not group and not video and not file and not upload then
	ngx.log(ngx.ERR,'FilePath :' .. file_path .. ' Access Error !');
	return ngx.exit(ngx.HTTP_FORBIDDEN);
end

--local file_path = "/userData/group23/M00/08/11/wKgKcleIQhWAP838AAG04ywe8Io942.jpg";
local str_filter = string.sub(file_path,0,1);
if str_filter == '/' then
	file_path = string.sub(file_path,2);
end

local index1 = string.find(file_path,'userData/');
if index1 then
	file_path = string.sub(file_path,index1+9);
end

--ngx.say('/el0805055fdfs/' .. file_path);
ngx.exec('/el0805055fdfs/' .. file_path);