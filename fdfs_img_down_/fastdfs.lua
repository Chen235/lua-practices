-- 写入文件
local function writefile(filename, info)
    local wfile=io.open(filename, "w") --写入文件(w覆盖)
    assert(wfile)  --打开时验证是否出错		
    wfile:write(info)  --写入传入的内容
    wfile:close()  --调用结束后记得关闭
end

-- 检测路径是否目录
local function is_dir(sPath)
    if type(sPath) ~= "string" then return false end

    local response = os.execute( "cd " .. sPath )
    if response == 0 then
        return true
    end
    return false
end

-- 检测文件是否存在
local file_exists = function(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

local area = nil
local originalUri = ngx.var.uri;
local originalFile = ngx.var.file;
local index = string.find(ngx.var.uri, "([0-9]+)x([0-9]+).jpg$");  
if index then 
    originalUri = string.sub(ngx.var.uri, 0, index-2);
    area = string.sub(ngx.var.uri, index);
    index = string.find(area, "([.])");
    area = string.sub(area, 0, index-1);

    local index = string.find(originalFile, "([0-9]+)x([0-9]+).jpg$");  
    originalFile = string.sub(originalFile, 0, index-2)
end

-- check original file
if not file_exists(originalFile) then
    local fileid = string.sub(originalUri, 2);
    -- main
    local fastdfs = require('resty.fastdfs')
    local fdfs = fastdfs:new()
    fdfs:set_tracker("192.168.8.115", 22122)
    fdfs:set_timeout(100)
    fdfs:set_tracker_keepalive(100, 10)
    fdfs:set_storage_keepalive(100, 10)
    local data = fdfs:do_download(fileid)
    if data then
       -- check image dir
        if not is_dir(ngx.var.image_dir) then
            os.execute("mkdir -p " .. ngx.var.image_dir)
        end
        writefile(originalFile, data)
    end
end

-- 创建缩略图
local image_sizes = {"40x40", "60x60", "70x70", "80x80", "100x100", "200x200", "300x300", "400x400", "500x500", "600x600", "700x700", "800x800"};
function table.contains(table, element)  
    for _, value in pairs(table) do  
        if value == element then
            return true  
        end  
    end  
    return false  
end 

if table.contains(image_sizes, area) then  
	local command = "gm convert " .. originalFile  .. " -sample " .. area .. " -quality 70 +profile * " .. area .. " " .. ngx.var.file;
    os.execute(command);  
end;

if file_exists(ngx.var.file) then
    --ngx.req.set_uri(ngx.var.uri, true);  
    ngx.exec(ngx.var.uri)
else
    ngx.exit(ngx.HTTP_NOT_FOUND)
end