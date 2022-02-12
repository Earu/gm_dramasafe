include("Lib/PlayerNames.lua")

DramaSafe = DramaSafe or {}

DramaSafe.WatchList = DramaSafe.WatchList or {}
DramaSafe.Drama = DramaSafe.Drama or 0
DramaSafe.MaxDrama = 300
DramaSafe.MaxPercCache = 60
DramaSafe.DramaPerc = DramaSafe.DramaPerc or 0
DramaSafe.CachedPerc = {}

DramaSafe.AddToWatchList = function(ply)
	if IsValid(ply) and ply:IsPlayer() and not DramaSafe.IsWatchListed(ply) then
		DramaSafe.WatchList[ply:SteamID()] = ply
		ply.DramaFactor = 1
		ply.DramaPotential = nil
	end
end

DramaSafe.RemoveFromWatchList = function(ply)
	if IsValid(ply) and ply:IsPlayer() and DramaSafe.IsWatchListed(ply) then
		DramaSafe.WatchList[ply:SteamID()] = nil
		ply.DramaFactor = nil
		ply.DramaPotential = 50
	end
end

DramaSafe.IsWatchListed = function(ply)
	if IsValid(ply) and ply:IsPlayer() then
		return DramaSafe.WatchList[ply:SteamID()] and true or false
	else
		return false
	end
end

DramaSafe.AddDrama = function(amount)
	local result = DramaSafe.Drama + amount
	if result > DramaSafe.MaxDrama then
		DramaSafe.Drama = DramaSafe.MaxDrama
	elseif result < 0 then
		DramaSafe.Drama = 0
	else
		DramaSafe.Drama = result
	end
end

DramaSafe.AddDramaPotential = function(ply,amount)
	if IsValid(ply) and ply:IsPlayer() and not DramaSafe.IsWatchListed(ply) then
		local result = ply.DramaPotential and ply.DramaPotential + amount or amount
		if result > 100 then
			ply.DramaPotential = 100
		elseif result < 0 then
			ply.DramaPotential = 0
		else
			ply.DramaPotential = result
		end
	end
end

DramaSafe.AddDramaFactor = function(ply,amount)
	if IsValid(ply) and ply:IsPlayer() and DramaSafe.IsWatchListed(ply) then
		local result = ply.DramaFactor and ply.DramaFactor + amount or amount
		if result >= 5 then
			ply.DramaFactor = 5
		elseif result <= 1 then
			ply.DramaFactor = 1
		else
			ply.DramaFactor = result
		end
	end
end

DramaSafe.CachePerc = function(perc)
	if #DramaSafe.CachedPerc >= DramaSafe.MaxPercCache then
		table.remove(DramaSafe.CachedPerc,1)
	end
	table.insert(DramaSafe.CachedPerc,perc)
end

DramaSafe.SetDramaPerc = function()
	DramaSafe.CachePerc( DramaSafe.DramaPerc )
	DramaSafe.DramaPerc = ( DramaSafe.Drama / DramaSafe.MaxDrama ) * 100
end

timer.Create("DramaPerc",1,0,DramaSafe.SetDramaPerc)

include("Chat/ChatAnalyzer.lua")
include("Modules/Loader.lua")

--return DramaSafe