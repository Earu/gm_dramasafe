local META = FindMetaTable("Player")

function META:GetProperName()
	if not IsValid(self) then return nil end
	if EasyChat and EasyChat.GetProperNick then
		return EasyChat.GetProperNick(self)
	end

	local name,_ = string.gsub(self:GetName(),"(%^%d+)","")
	name,_ = string.gsub(name,"(<.->)","")
	name,_ = string.gsub(name,"(%s)","")
	name,_ = string.gsub(name,"(%(.*%))","")
	name,_ = string.gsub(name,"(%[.*%])","")
	return string.lower(name)
end

function META:CapitalizeName()
	local name = self:GetProperName()
	name = string.Explode("",name)
	name[1] = string.upper(name[1])
	name = table.concat(name,"",1,#name)
	return name
end

function player.FindByName(name)
	name = string.lower(string.PatternSafe(name))
	local nlen = string.len(name)

	for _,v in pairs(player.GetAll()) do
		local curname = string.PatternSafe(v:GetProperName())
		local match = string.match(curname,name)

		if match and string.len(match) / nlen >= 0.5 then
			return v
		end

	end

	return nil
end
