DramaSafe.MutedPlayers = DramaSafe.MutedPlayers or {}

DramaSafe.IsMutedPlayer = function(ply)
	return DramaSafe.MutedPlayers[ply:SteamID()] and true or false
end

DramaSafe.MutePlayer = function(ply)
	if IsValid(ply) and not DramaSafe.IsMutedPlayer(ply) then
		DramaSafe.MutedPlayers[ply:SteamID()] = ply
		ply:SetMuted(true)
	end
end

DramaSafe.UnMutePlayer = function(ply)
	if IsValid(ply) and DramaSafe.IsMutedPlayer(ply) then
		DramaSafe.MutedPlayers[ply:SteamID()] = nil
		ply:SetMuted(false)
	end
end

DramaSafe.MutePlayers = function(ply,txt)
	if IsValid(ply) and DramaSafe.IsMutedPlayer(ply) then
		return ""
	end
end

hook.Add("OnPlayerChat","DramaMute",DramaSafe.MutePlayers)