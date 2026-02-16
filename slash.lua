local addonName, ns = ...

local function ShowStatus()
    local myName = UnitName("player")
    local electedLeader = "Unknown"

    local candidates = {}
    local _, _, myRank = GetGuildInfo("player")
    table.insert(candidates, { name = myName, rank = myRank or 99, guid = UnitGUID("player"), version = ns.VERSION })

    for name, data in pairs(ns.OnlineAddonUsers) do
        local isOnline = ns.IsPlayerActuallyOnline(name)
        if isOnline then
            table.insert(candidates, { name = name, rank = data.rank, guid = data.guid, version = data.version })
        end
    end

    table.sort(candidates, function(a, b)
        local aIsNewer = ns.CompareVersions(a.version, b.version) >= 0
        local bIsNewer = ns.CompareVersions(b.version, a.version) >= 0
        
        if aIsNewer and not bIsNewer then return true end
        if bIsNewer and not aIsNewer then return false end
        
        if a.rank ~= b.rank then return a.rank < b.rank end
        return a.guid < b.guid
    end)

    if candidates[1] then electedLeader = candidates[1].name end

    print("|cffffff00--- GPC Network Status ---|r")
    print(string.format("Current Leader: |cff00ff00%s|r", electedLeader))

    for name, data in pairs(ns.OnlineAddonUsers) do
        local isLeader = (name == electedLeader)
        local color = ns.GetStatusColor(false, isLeader)

        print(string.format("|c%s[%s]|r - Rank: %d, Version: %s (%s)",
            color, name, data.rank, data.version or "unknown", ns.IsPlayerActuallyOnline(name) and "online" or "offline"))
    end

    local myColor = ns.GetStatusColor(true, myName == electedLeader)
    print(string.format("|c%s[%s] (You)|r - Rank: %d, Version: %s",
        myColor, myName, myRank or 99, ns.VERSION))
    print("|cffffff00--------------------------|r")
end

SLASH_GPC1 = "/gpc"
SlashCmdList["GPC"] = function(msg)
    local cmd = msg:lower():trim()
    if cmd == "status" then
        ShowStatus()
    elseif cmd == "ping" then
        print("Sending manual network ping...")
        if ns.SendPresence then ns.SendPresence("PING") end
    else
        print("GuildPriceCheck Usage:")
        print("  /gpc status - See online peers and elected leader")
        print("  /gpc ping   - Force a network refresh")
    end
end