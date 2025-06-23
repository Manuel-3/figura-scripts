local lib = {}

---Join paths e.g. join("./","dir/","/dir2/dir3") -> "./dir/dir2/dir3"
---@return string
function lib.join(...)
    local names = {...}
    local joined = table.remove(names,1):gsub("\\","/")
    for _, value in ipairs(names) do
        value = value:gsub("\\","/")
        value = value:match("^/(.*)$") or value
        joined = (joined:match("^(.*)/$") or joined) .."/".. value
    end
    return joined
end

---Apply meta directories . and .. and empty dirs
---e.g. applyPath("./a//b/./c/../d/") -> "./a/b/d"
---@param path any
function lib.applyPath(path)
    local names = path:gsub("\\","/"):gmatch("[^/]*")
    local applied = {names()}
    for value in names do
        if value ~= "" and value ~= "." then
            if value == ".." then
                table.remove(applied,#applied)
            else
                table.insert(applied, value)
            end
        end
    end
    return table.concat(applied,"/")
end

---Get path of the directory of the file path
---e.g. dirpath("./dir/file.txt") -> "./dir"
---@param path string A file or directory path
---@return string The directory path
function lib.dirpath(path)
    return path:gsub("\\","/"):match("^(.-)[^/.]+%..+$") or path
end

---Get file or folder name from a path including file extension
---e.g. filename("./dir/a.txt") -> "a.txt", filename("./dir") -> "dir"
---@param path string
---@return string
function lib.filename(path)
    return path:gsub("\\","/"):match("^.-([^/]+)/*$") or ""
end

---Get file or folder name from a path excluding file extension
---e.g. filename("./dir/a.txt") -> "a", filename("./dir") -> "dir"
---@param path string
---@return string
function lib.filenameonly(path)
    local filename = lib.filename(path)
    return filename:match("(.-)%..-") or filename
end

---Get file extension, returns "" for directories or when there is no extension
---@param path string
---@return string
function lib.fileext(path)
    return lib.filename(path):match(".-%.(.+)") or ""
end

---mkdir which also creates all parent dirs and works with a file path too
---e.g. mkdir("./dir1/dir2/file.txt") -> creates "./" and "./dir1" and "./dir1/dir2"
---@param path string
function lib.mkdir(path)
    local dir = lib.dirpath(path)
    local current = "./"
    file:mkdir(current)
    for name in dir:gmatch("[^/.]+") do
        current = current .. name .. "/"
        file:mkdir(current)
    end
end

return lib