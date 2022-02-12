local path = "lua/DramaSafe/Modules/"
local files = (file.Find(path .. "*.lua","GAME"))

for _,file_name in ipairs(files) do
	if file_name ~= "Loader.lua" then
		include(file_name)
	end
end