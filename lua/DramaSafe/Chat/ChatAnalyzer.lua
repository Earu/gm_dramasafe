local Words = include("Filter.lua")
local MessageCacheSize = 10
DramaSafe.CachedMessages = {}
DramaSafe.CachedPlayers = {}

DramaSafe.IsSensibleWord = function(str)
    str = string.lower(str)

    return Words.Sensible[str] and true or false
end

DramaSafe.IsApologizeWord = function(str)
    str = string.lower(str)

    return Words.Apologize[str] and true or false
end

DramaSafe.CacheMessage = function(author, message, info)
    if #DramaSafe.CachedMessages >= MessageCacheSize then
        table.remove(DramaSafe.CachedMessages, 1)
    end

    table.insert(DramaSafe.CachedMessages, {
        Content = message,
        Author = author,
        Info = info
    })
end

DramaSafe.CachePlayer = function(ply)
    if ply and ply:IsPlayer() then
        DramaSafe.CachedPlayers[ply:SteamID()] = ply
    end
end

DramaSafe.WasQuotedRecently = function(str)
    if not str then return false end
    str = string.lower(tostring(str))

    for _, v in pairs(DramaSafe.CachedMessages) do
        for _, info in pairs(v.Info) do
            if type(info) == "table" and info[str] then return true end
        end
    end

    return false
end

DramaSafe.GetPlayerMention = function(str)
    str = string.lower(str)
    local ply = player.FindByName(str)

    if ply and not DramaSafe.IsWatchListed(ply) then
        DramaSafe.CachePlayer(ply)

        return ply
    end

    return nil
end

DramaSafe.GetWatchedMention = function(str)
    str = string.lower(str)
    local watched = player.FindByName(str)

    if watched and DramaSafe.IsWatchListed(watched) then
        DramaSafe.CachePlayer(watched)

        return watched
    end

    return nil
end

DramaSafe.GetMessageDrama = function(author, message)
    local info = {
        Drama = 0,
        Watcheds = {},
        Players = {},
        SensibleWords = {},
        ApologizeWords = {},
        NormalWords = {},
        IsCaps = false,
        Factor = 0,
    }

    if not author or not author:IsPlayer() or not message then return info end
    info.IsCaps = (message == string.upper(message))
    message = string.lower(message)
    message = string.Explode(" ", string.sub(message, 1, 200)) --we don't go past 200 chars
    local tpcount = player.GetCount()

    if tpcount >= 30 then
        info.Factor = 0.5
    elseif tpcount > 10 and tpcount < 30 then
        info.Factor = 1
    else
        info.Factor = 2
    end

    if DramaSafe.IsWatchListed(author) then
        info.Watcheds[author:SteamID()] = author
    else
        info.Players[author:SteamID()] = author
    end

    for _, v in pairs(message) do
        local watched = DramaSafe.GetWatchedMention(v)
        local ply = DramaSafe.GetPlayerMention(v)

        if watched then
            info.Drama = info.Drama + (10 * (DramaSafe.WatchList[watched:SteamID()].DramaFactor or 0))
            info.Watcheds[watched:SteamID()] = watched
        elseif ply then
            info.Players[ply:SteamID()] = ply
        elseif DramaSafe.IsSensibleWord(v) then
            info.SensibleWords[v] = v
        elseif DramaSafe.IsApologizeWord(v) then
            info.ApologizeWords[v] = v
        else
            info.NormalWords[v] = v
        end
    end

    local scount = table.Count(info.SensibleWords)
    local acount = table.Count(info.ApologizeWords)
    local pcount = table.Count(info.Players)

    if #message <= 2 then
        if scount == 0 then
            info.Drama = info.Drama - (15 * acount)
        else
            if pcount > 1 then
                info.Drama = info.Drama + (5 * scount) + (5 * pcount)
            else
                info.Drama = info.Drama + (5 * scount)
            end
        end
    else
        if scount == 0 then
            info.Drama = info.Drama - (5 * acount)
        else
            if pcount > 1 then
                info.Drama = info.Drama + (2 * scount) + (5 * pcount)
            else
                info.Drama = info.Drama + (1 * scount)
            end
        end
    end

    if info.IsCaps and scount > 0 then
        info.Drama = ((info.Drama >= 0 and info.Drama + 40 or 40) * 2) / 2
    end

    info.Drama = info.Drama * info.Factor

    return info
end

DramaSafe.ChatAnalyze = function(author, message)
    local info = DramaSafe.GetMessageDrama(author, message)
    local sensiblecount = table.Count(info.SensibleWords)

    if info.Drama ~= 0 then
        DramaSafe.AddDrama(info.Drama)

        if sensiblecount > 0 then
            if table.Count(info.Watcheds) > 0 then
                for _, v in pairs(info.Watcheds) do
                    DramaSafe.AddDramaFactor(v, 1)
                end
            end

            if table.Count(info.Players) > 0 then
                for _, v in pairs(info.Players) do
                    DramaSafe.AddDramaPotential(v, 10 * sensiblecount)

                    if v.DramaPotential >= 100 then
                        DramaSafe.AddToWatchList(v)
                        v.DramaPotential = nil
                    end
                end
            end
        end
    end

    DramaSafe.CacheMessage(author, message, info)
end

hook.Add("OnPlayerChat", "DramaAnalyzer", DramaSafe.ChatAnalyze)

timer.Create("DramaPlayersQuoted", 30, 0, function()
    local count = 0
    local total = table.Count(DramaSafe.CachedPlayers)
    local safechat = true

    for k, v in pairs(DramaSafe.CachedPlayers) do
        if IsValid(v) and not DramaSafe.WasQuotedRecently(v) then
            if DramaSafe.IsWatchListed(v) then
                if v.DramaFreed and v.DramaFreed >= 20 then
                    DramaSafe.RemoveFromWatchList(v)
                    v.DramaFreed = nil
                else
                    if v.DramaFactor == 1 then
                        v.DramaFreed = v.DramaFreed and v.DramaFreed + 1 or 1
                    end

                    DramaSafe.AddDramaFactor(v, -1)
                end

                count = count + 1
                DramaSafe.CachedPlayers[k] = nil
            else
                DramaSafe.AddDramaPotential(v, -25)
                count = count + 1
                DramaSafe.CachedPlayers[k] = nil
            end
        elseif not IsValid(v) then
            if DramaSafe.IsWatchListed(v) then
                DramaSafe.WatchList[k] = nil
            end

            DramaSafe.CachedPlayers[k] = nil
        end
    end

    for _, v in pairs(DramaSafe.CachedMessages) do
        if table.Count(v.Info.SensibleWords) > 0 then
            safechat = false
            break
        end
    end

    if count / total >= 0.5 then
        if safechat then
            DramaSafe.AddDrama(-10 * count)
        else
            DramaSafe.AddDrama(-5)
        end
    end
end)