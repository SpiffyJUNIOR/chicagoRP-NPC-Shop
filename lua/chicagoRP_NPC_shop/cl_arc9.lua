local ammostrings = {
    ["pistol"] = "Pistol",
    ["smg1"] = "Carbine",
    ["ar2"] = "Rifle",
    ["SniperPenetratedRound"] = "Sniper",
    ["buckshot"] = "Shotgun",
    ["357"] = "Magnum",
    ["smg1_grenade"] = "Grenade"
}

local firemodestrings = {
    ["auto"] = "Full-Auto",
    ["semi"] = "Semi-Auto",
    ["burst"] = "Burst",
    ["safe"] = "Safe"
}

local function AmmoString(ammoname)
    if chicagoRP_NPCShop.isempty(ammoname) then return end

    return ammostrings[ammoname]
end

local function ARC9StatString(str, statval)
    if str == "PhysBulletMuzzleVelocity" then
        return math.Round(statval / 30)
    elseif str == "Recoil" or str == "RecoilUp" or str == "RecoilSide" or str == "SpeedMult" or str == "SpreadMultHipFire" or str == "SpeedMultSights" then
        return math.Round(statval * 20)
    else
        print("didn't parse arc9 stat string")
        return statval
    end
end

local function ConvertFiremodeTable(firemodetbl)
    for _, v in ipairs(firemodetbl)
        local mode = v.Mode
        local str = nil

        if mode >= -1 then 
            v.Mode = firemodestrings["auto"]
        elseif mode == 0 then
            v.Mode = firemodestrings["safe"]
        elseif mode == 1 then
            v.Mode = firemodestrings["semi"]
        elseif mode <= 2 then
            v.Mode = tostring(v.Mode) .. "-Round " .. firemodestrings["burst"]
        end
    end

    return firemodetbl
end

function chicagoRP_NPCShop.GetARC9Stats(wpnname, pretty)
    local stattbl = {}
    local wpntbl = weapons.GetStored(wpnname.ent)
    local wpnparams = {"DamageMax", "DamageMin", "RangeMin", "RangeMax", "Penetration", "PhysBulletMuzzleVelocity", "BarrelLength", "Primary.ClipSize", "Recoil", "RecoilUp" "RecoilSide", "RPM", "Firemodes", "SpreadMultHipFire", "Primary.Ammo", "SpeedMult", "SpeedMultSights", "AimDownSightsTime"}
    local prettyparams = {"DamageMin", "RangeMin", "Penetration", "PhysBulletMuzzleVelocity", "BarrelLength", "Primary.ClipSize", "Recoil", "RecoilUp" "RecoilSide", "RPM", "Firemodes", "SpreadMultHipFire", "Primary.Ammo", "SpeedMult", "SpeedMultSights", "AimDownSightsTime"}

    if pretty == nil or pretty == false then
        for _, v in ipairs(wpnparams) do
            local paramtbl = {name = v, stat = ARC9StatString(v, wpntbl.[v])}

            if v == "Firemodes" then
                paramtbl = {name = v, stat = ConvertFiremodeTable(wpntbl.Firemodes)}
            end

            table.insert(stattbl, paramtbl)

            continue
        end
    elseif pretty == true
        for _, v in ipairs(prettyparams) do
            local parsedstat = ARC9StatString(v, wpntbl.[v])

            if v == "Firemodes" then
                parsedstat = ConvertFiremodeTable(wpntbl.Firemodes)
            end

            if v == "Primary.Ammo" then
                parsedstat = AmmoString(wpntbl.[v])
            end

            if v == "DamageMin" and isnumber(wpntbl.["DamageMax"]) then
                parsedstat = tostring(wpntbl.["DamageMin"]) .. "-" .. tostring(wpntbl.["DamageMax"])
            end

            if v == "RangeMin" and isnumber(wpntbl.["RangeMax"]) then
                parsedstat = tostring(wpntbl.["RangeMin"]) .. "m" .. "-" .. tostring(wpntbl.["RangeMax"]) .. "m"
            end

            local paramtbl = {name = v, stat = parsedstat}

            table.insert(stattbl, paramtbl)

            continue
        end
    end

    return stattbl
end

function chicagoRP_NPCShop.GetARC9AttStats(wep, enttable)
    local stattbl = {}

    local wpntbl = weapons.GetStored(wep)
    local atttbl = ARC9.GetAttTable(enttable.ent)

    if !chicagoRP_NPCShop.IsARC9Att(enttable.ent) then return end

    for stat, value in pairs(atttbl) do
        if !isnumber(value) and !isbool(value) then continue end
        if isnumber(value) then value = math.Round(value, 2) end
        
        local autostat = ""
        local autostatnum = ""
        local canautostat = false
        local neg = false
        local unit = false
        local negisgood = false
        local asmain = ""

        local maxlen = 0

        for main, tbl in pairs(ARC9.AutoStatsMains) do
            if string.len(main) > maxlen and string.StartWith(stat, main) then
                autostat = ARC9:GetPhrase("autostat." .. main) or main
                unit = tbl[1]
                negisgood = tbl[2]
                asmain = main
                canautostat = true
                maxlen = string.len(main)
            end
        end

        if !canautostat then
            continue
        end

        stat = string.sub(stat, string.len(asmain) + 1, string.len(stat))

        local foundop = false
        local asop = ""

        for op, func in pairs(ARC9.AutoStatsOperations) do
            if string.StartWith(stat, op) then
                local pre, post, isneg = func(value, wpntbl, asmain, unit)
                autostat = autostat .. post
                autostatnum = pre
                neg = isneg
                foundop = true
                asop = op
                break
            end
        end

        if asop == "Hook" then continue end

        if !foundop then
            -- autostat = tostring(value) .. " " .. autostat

            -- if isnumber(value) then neg = value <= (weapon[asmain] or 0) else neg = value end
            local pre, post, isneg = ARC9.AutoStatsOperations.Override(value, wpntbl, asmain, unit)
            autostat = autostat .. post
            autostatnum = pre
            neg = isneg
            foundop = true
            asop = "Override"
        else
            stat = string.sub(stat, string.len(asop) + 1, string.len(stat))
        end

        if stat == "_Priority" then continue end

        if string.len(stat) > 0 then
            local before = ARC9:GetPhrase("autostat.secondary._beforephrase")
            local div = ARC9:GetPhrase("autostat.secondary._divider")
            if div == true then div = "" end

            for cond, postfix in pairs(ARC9.AutoStatsConditions) do
                if string.StartWith(stat, cond) then
                    local phrase = (ARC9:GetPhrase("autostat.secondary." .. string.lower(cond)) or "")
                    if before then
                        autostat = phrase .. div .. autostat
                    else
                        autostat = autostat .. div .. phrase
                    end
                    break
                end
            end
        end

        table.insert(stattbl, autostat)
        table.insert(stattbl, autostatnum)
    end

    return stattbl
    -- return pros, cons
end

function chicagoRP_NPCShop.GetARC9AttProsCons(wep, enttable)
    local prosname = {}
    local prosnum = {}
    local consname = {}
    local consnum = {}

    local wpntbl = weapons.GetStored(wep)
    local atttbl = ARC9.GetAttTable(enttable.ent)

    if !chicagoRP_NPCShop.IsARC9Att(enttable.ent) then return end

    if enttable.override == true then
        local stattbl = chicagoRP_NPCShop.RemoveStrings(enttable, true)

        return stattbl
    end

    for stat, value in pairs(atttbl) do
        if !isnumber(value) and !isbool(value) then continue end
        if isnumber(value) then value = math.Round(value, 2) end
        
        local autostat = ""
        local autostatnum = ""
        local canautostat = false
        local neg = false
        local unit = false
        local negisgood = false
        local asmain = ""

        local maxlen = 0

        for main, tbl in pairs(ARC9.AutoStatsMains) do
            if string.len(main) > maxlen and string.StartWith(stat, main) then
                autostat = ARC9:GetPhrase("autostat." .. main) or main
                unit = tbl[1]
                negisgood = tbl[2]
                asmain = main
                canautostat = true
                maxlen = string.len(main)
            end
        end

        if !canautostat then
            continue
        end

        stat = string.sub(stat, string.len(asmain) + 1, string.len(stat))

        local foundop = false
        local asop = ""

        for op, func in pairs(ARC9.AutoStatsOperations) do
            if string.StartWith(stat, op) then
                local pre, post, isneg = func(value, wpntbl, asmain, unit)
                autostat = autostat .. post
                autostatnum = pre
                neg = isneg
                foundop = true
                asop = op
                break
            end
        end

        if asop == "Hook" then continue end

        if !foundop then
            -- autostat = tostring(value) .. " " .. autostat

            -- if isnumber(value) then neg = value <= (weapon[asmain] or 0) else neg = value end
            local pre, post, isneg = ARC9.AutoStatsOperations.Override(value, wpntbl, asmain, unit)
            autostat = autostat .. post
            autostatnum = pre
            neg = isneg
            foundop = true
            asop = "Override"
        else
            stat = string.sub(stat, string.len(asop) + 1, string.len(stat))
        end

        if stat == "_Priority" then continue end

        if string.len(stat) > 0 then
            local before = ARC9:GetPhrase("autostat.secondary._beforephrase")
            local div = ARC9:GetPhrase("autostat.secondary._divider")
            if div == true then div = "" end

            for cond, postfix in pairs(ARC9.AutoStatsConditions) do
                if string.StartWith(stat, cond) then
                    local phrase = (ARC9:GetPhrase("autostat.secondary." .. string.lower(cond)) or "")
                    if before then
                        autostat = phrase .. div .. autostat
                    else
                        autostat = autostat .. div .. phrase
                    end
                    break
                end
            end
        end

        if neg and negisgood or !neg and !negisgood then
            table.insert(prosname, autostat)
            table.insert(prosnum, autostatnum)
        else
            table.insert(consname, autostat)
            table.insert(consnum, autostatnum)
        end
    end

    -- custom stats
    if istable(atttbl.CustomPros) then  
        for stat, value in pairs(atttbl.CustomPros) do
            table.insert(prosname, stat)
            table.insert(prosnum, value)
        end
    end

    if istable(atttbl.CustomCons) then  
        for stat, value in pairs(atttbl.CustomCons) do
            table.insert(consname, stat)
            table.insert(consnum, value)
        end
    end

    return prosname, prosnum, consname, consnum
    -- return pros, cons
end

function chicagoRP_NPCShop.IsARC9Att(ent)
    return ARC9 and !chicagoRP_NPCShop.isempty(string.find(ent, "arc9_att_"))
end

function chicagoRP_NPCShop.ARC9WeaponBodygroups(weaponname)
    local bgtable = {}
    local sweptbl = weapons.GetStored(weaponname)

    local bodygroups = sweptbl.DefaultBodygroups

    if chicagoRP_NPCShop.isempty(bodygroups) then return end

    return bodygroups
end

function chicagoRP_NPCShop.ARC9Bodygroup(weaponname, attname)
    local bgtable = {}
    local sweptbl = weapons.GetStored(weaponname)

    local bgindex = sweptbl.AttachmentElements[attname].Bodygroups

    for _, j in ipairs(bgindex) do
        if !istable(j) then continue end

        table.insert(bgtable, {j[1] or 0, j[2] or 0})
    end

    return bgtable
end