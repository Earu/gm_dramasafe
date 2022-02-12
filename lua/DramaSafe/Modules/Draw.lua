DramaSafe.UnDrewPlayers = DramaSafe.UnDrewPlayers or {}

DramaSafe.UnDrawPlayer = function(ply)
	if not DramaSafe.IsUnDrewPlayer(ply) then
		DramaSafe.UnDrewPlayers[ply:SteamID()] = ply
		ply:SetNoDraw(true)
		ply:SetNotSolid(true)
		if pac and pace then
			pac.IgnoreEntity(ply)
		end
	end
end

DramaSafe.DrawPlayer = function(ply)
	if DramaSafe.IsUnDrewPlayer(ply) then
		DramaSafe.UnDrewPlayers[ply:SteamID()] = nil
		ply:SetNoDraw(false)
		ply:SetNotSolid(false)
		if pac and pace then
			pac.UnIgnoreEntity(ply)
		end
	end
end

DramaSafe.IsUnDrewPlayer = function(ply)
	return DramaSafe.UnDrewPlayers[ply:SteamID()] and true or false
end

DramaSafe.UnDrawPlayers = function(ply)
	if IsValid(ply) and DramaSafe.IsUnDrewPlayer(ply) then
		ply:SetNoDraw(true)
		ply:SetNotSolid(true)
		return true
	end
end

DramaSafe.UnDrawPacs = function(_,ply)
	if DramaSafe.IsUnDrewPlayer(ply) then
		pac.IgnoreEntity(ply)
	end
end

hook.Add("PrePlayerDraw","DramaNoDraw",DramaSafe.UnDrawPlayers)
hook.Add("pac_OnWoreOutfit","DramaNoDrawPacs",DramaSafe.UnDrawPacs)