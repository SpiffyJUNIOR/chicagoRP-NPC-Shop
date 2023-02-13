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
    ["burst"] = "%d-Round Burst",
    ["safe"] = "Safe"
}

local stataffix = {
    ["AccuracyMOA"] = "MOA",
    ["BarrelLength"] = "in",
    ["Delay"] = "RPM",
    ["MuzzleVelocity"] = "m/s",
    ["ShootVol"] = "dB"
}

local ArcCW_AttStats = {"MagExtender", "MagReducer", "Bipod", "Silencer", "Mult_BipodRecoil", "Mult_BipodDispersion", "Mult_Damage", "Mult_DamageMin", "Mult_Range", "Mult_RangeMin", "Mult_Penetration", "Mult_MuzzleVelocity", "Mult_PhysBulletMuzzleVelocity", "Mult_MeleeTime", "Mult_MeleeDamage", "Add_MeleeRange", "Mult_Recoil", "Mult_RecoilSide", "Mult_RPM", "Mult_AccuracyMOA", "Mult_HipDispersion", "Mult_SightsDispersion", "Mult_MoveDispersion", "Mult_JumpDispersion", "Mult_ShootVol", "Mult_SpeedMult", "Mult_MoveSpeed", "Mult_SightedSpeedMult", "Mult_SightedMoveSpeed", "Mult_ShootSpeedMult", "Mult_ReloadTime", "Add_BarrelLength", "Mult_DrawTime", "Mult_SightTime", "Mult_CycleTime", "Mult_Sway", "Mult_HeatCapacity", "Mult_HeatDissipation", "Mult_FixTime", "Mult_HeatDelayTime", "Mult_MalfunctionMean", "Add_ClipSize", "Mult_ClipSize", "Override_Ammo", "Override_ClipSize", "Bipod", "UBGL"}

local ArcCW_AutoStats = {
    ["MagExtender"]           = {"autostat.magextender", "override", false,       pr = 317}, -- Attachments
    ["MagReducer"]            = {"autostat.magreducer",  "override", true,        pr = 316},
    ["Bipod"]                 = {"autostat.bipod",       false, false,            pr = 313},
    ["ScopeGlint"]            = {"autostat.glint",       "override", true,        pr = 255},
    ["Silencer"]              = {"autostat.silencer",    "override", false,       pr = 254},
    ["Override_NoRandSpread"] = {"autostat.norandspr",   "override", false,       pr = 253},
    ["Override_CanFireUnderwater"] = {"autostat.underwater",   "override", false, pr = 252},
    ["Override_ShootWhileSprint"] = {"autostat.sprintshoot",   "override", false, pr = 251},
    ["Mult_BipodRecoil"]      = {"autostat.bipodrecoil", false, true,             pr = 312}, -- Multipliers
    ["Mult_BipodDispersion"]  = {"autostat.bipoddisp",   false, true,             pr = 311},
    ["Mult_Damage"]           = {"autostat.damage",      "mult", false,           pr = 215},
    ["Mult_DamageMin"]        = {"autostat.damagemin",   "mult", false,           pr = 214},
    ["Mult_Range"]            = {"autostat.range",       "mult", false,           pr = 185},
    ["Mult_RangeMin"]         = {"autostat.rangemin",    "mult", false,           pr = 184},
    ["Mult_Penetration"]      = {"autostat.penetration", "mult", false,           pr = 213},
    ["Mult_MuzzleVelocity"]   = {"autostat.muzzlevel",   "mult", false,           pr = 212},
    ["Mult_PhysBulletMuzzleVelocity"] = {"autostat.muzzlevel",   "mult", false,   pr = 211},
    ["Mult_MeleeTime"]        = {"autostat.meleetime",   "mult", true,            pr = 145},
    ["Mult_MeleeDamage"]      = {"autostat.meleedamage", "mult", false,           pr = 144},
    ["Add_MeleeRange"]        = {"autostat.meleerange",  false,  false,           pr = 143},
    ["Mult_Recoil"]           = {"autostat.recoil",      "mult", true,            pr = 195},
    ["Mult_RecoilSide"]       = {"autostat.recoilside",  "mult", true,            pr = 194},
    ["Mult_RPM"]              = {"autostat.firerate",    "mult", false,           pr = 216},
    ["Mult_AccuracyMOA"]      = {"autostat.precision",   "mult", true,            pr = 186},
    ["Mult_HipDispersion"]    = {"autostat.hipdisp",     "mult", true,            pr = 155},
    ["Mult_SightsDispersion"] = {"autostat.sightdisp",   "mult", true,            pr = 154},
    ["Mult_MoveDispersion"]   = {"autostat.movedisp",    "mult", true,            pr = 153},
    ["Mult_JumpDispersion"]   = {"autostat.jumpdisp",    "mult", true,            pr = 152},
    ["Mult_ShootVol"]         = {"autostat.shootvol",    "mult", true,            pr = 115},
    ["Mult_SpeedMult"]        = {"autostat.speedmult",   "mult", false,           pr = 114},
    ["Mult_MoveSpeed"]        = {"autostat.speedmult",   "mult", false,           pr = 105},
    ["Mult_SightedSpeedMult"] = {"autostat.sightspeed",  "mult", false,           pr = 104},
    ["Mult_SightedMoveSpeed"] = {"autostat.sightspeed",  "mult", false,           pr = 103},
    ["Mult_ShootSpeedMult"]   = {"autostat.shootspeed",  "mult", false,           pr = 102},
    ["Mult_ReloadTime"]       = {"autostat.reloadtime",  "mult", true,            pr = 125},
    ["Add_BarrelLength"]      = {"autostat.barrellength","add",  true,            pr = 915},
    ["Mult_DrawTime"]         = {"autostat.drawtime",    "mult", true,            pr = 14},
    ["Mult_SightTime"]        = {"autostat.sighttime",   "mult", true,            pr = 335, flipsigns = true},
    ["Mult_CycleTime"]        = {"autostat.cycletime",   "mult", true,            pr = 334},
    ["Mult_Sway"]             = {"autostat.sway",        "mult",  true,           pr = 353},
    ["Mult_HeatCapacity"]     = {"autostat.heatcap",     "mult", false,           pr = 10},
    ["Mult_HeatDissipation"]  = {"autostat.heatdrain",   "mult", false,           pr = 9},
    ["Mult_FixTime"]          = {"autostat.heatfix",     "mult", true,            pr = 8},
    ["Mult_HeatDelayTime"]    = {"autostat.heatdelay",   "mult", true,            pr = 7},
    ["Mult_MalfunctionMean"]  = {"autostat.malfunctionmean", "mult", false,       pr = 6},
    ["Add_ClipSize"]          = {"autostat.clipsize.mod",    "add", false,         pr = 315},
    ["Mult_ClipSize"]         = {"autostat.clipsize.mod",    "mult", false,        pr = 314},
    ["Override_Ammo"] = {"autostat.ammotype", "func", function(wep, val, att)
        -- have to use the weapons table here because Primary.Ammo *is* modified when attachments are used
        local weptbl = weapons.GetStored(wep)
        if !istable(weptbl) or weptbl.Primary.Ammo == val then return end
        return string.format(translate("autostat.ammotype"), string.lower(ArcCW.TranslateAmmo(val))), "infos"
    end, pr = 316},
    ["Override_ClipSize"] = {"autostat.clipsize", "func", function(wep, val, att)
        local weptbl = weapons.GetStored(wep)
        if !istable(weptbl) then return end
        local ogclip = weptbl.RegularClipSize or (weptbl.Primary and weptbl.Primary.ClipSize) or 0
        if ogclip < val then
            return string.format(translate("autostat.clipsize"), val), "pros"
        else
            return string.format(translate("autostat.clipsize"), val), "cons"
        end
    end, pr = 317},
    ["Bipod"] = {"autostat.bipod2", "func", function(wep, val, att)
        local weptbl = weapons.GetStored(wep)
        if val then
            local recoil = 100 - math.Round((att.Mult_BipodRecoil or (istable(weptbl) and weptbl.BipodRecoil) or 1) * 100)
            local disp = 100 - math.Round((att.Mult_BipodDispersion or (istable(weptbl) and weptbl.BipodDispersion) or 1) * 100)
            return string.format(translate("autostat.bipod2"), disp, recoil), "pros"
        else
            return translate("autostat.nobipod"), "cons"
        end
    end, pr = 314},
    ["UBGL"] = {"autostat.ubgl", "override", false, pr = 950},
    ["UBGL_Ammo"] = {"autostat.ammotypeubgl", "func", function(wep, val, att)
        -- have to use the weapons table here because Primary.Ammo *is* modified when attachments are used
        local weptbl = weapons.GetStored(wep)
        if !istable(weptbl) then return end
        return string.format(translate("autostat.ammotypeubgl"), string.lower(ArcCW.TranslateAmmo(val))), "infos"
    end, pr = 949},
}

function chicagoRP_NPCShop.IsArcCWAtt(ent)
    return ArcCW and !chicagoRP_NPCShop.isempty(string.find(ent, "acwatt_"))
end

function chicagoRP_NPCShop.ArcCWBodygroup(swepclass, attname)
    local bgtable = nil
    local sweptbl = weapons.GetStored(swepclass)
    local atttbl = scripted_ents.GetStored(attname)

    for _, v in ipairs(atttbl.ActivateElements) do -- sweptbl.AttachmentElements[attname].VMBodygroups
        table.insert(bgtable, sweptbl.AttachmentElements[v].VMBodygroups)
    end

    return bgtable
end

local function stattext(wep, att, i, k, dmgboth, flipsigns)
    if !ArcCW_AutoStats[i] then return end
    if i == "Mult_DamageMin" and dmgboth then return end

    local stat = ArcCW_AutoStats[i]

    local txt = ""
    local str, eval = ArcCW.GetTranslation(stat[1]) or stat[1], stat[3]

    if i == "Mult_Damage" and dmgboth then
        str = ArcCW.GetTranslation("autostat.damageboth") or stat[1]
    end

    local tcon, tpro = eval and "cons" or "pros", eval and "pros" or "cons"

    if stat[3] == "infos" then
        tcon = "infos"
    end

    if stat[2] == "mult" and k != 1 then
        local sign, percent = k > 1 and (flipsigns and "-" or "+") or (flipsigns and "+" or "-"), k > 1 and (k - 1) or (1 - k)
        txt = sign .. tostr(math.Round(percent * 100, 2)) .. "% "
        return txt .. str, k > 1 and tcon or tpro
    elseif stat[2] == "add" and k != 0 then
        local sign, state = k > 0 and (flipsigns and "-" or "+") or (flipsigns and "+" or "-"), k > 0 and k or -k
        txt = sign .. tostr(state) .. " "
        return txt .. str, k > 0 and tcon or tpro
    elseif stat[2] == "override" and k == true then
        return str, tcon
    elseif stat[2] == "func" then
        local a, b = stat[3](wep, k, att)
        if a and b then return a, b end
    end
end

function chicagoRP_NPCShop.GetArcCWAttProsCons(wep, enttable)
    local pros = {}
    local cons = {}
    local infos = {}

    local atttable = scripted_ents.GetStored(enttable.ent)

    if !chicagoRP_NPCShop.IsArcCWAtt(enttable.ent) then return end

    if enttable.override == true then
        local stattbl = chicagoRP_NPCShop.RemoveStrings(enttable, true)

        return stattbl
    end

    table.Add(pros, atttable.Desc_Pros or {})
    table.Add(cons, atttable.Desc_Cons or {})
    table.Add(infos, atttable.Desc_Neutrals or {})

    -- local override = hook.Run("ArcCW_PreAutoStats", wep, att, pros, cons, infos, toggle)
    -- if override then return pros, cons, infos end

    -- Localize attachment-specific text
    local hasmaginfo = false
    for i, v in pairs(pros) do
        if v == "pro.magcap" then hasmaginfo = true end
        pros[i] = ArcCW.TryTranslation(v)
    end
    for i, v in pairs(cons) do
        if v == "con.magcap" then hasmaginfo = true end
        cons[i] = ArcCW.TryTranslation(v)
    end
    for i, v in pairs(infos) do infos[i] = ArcCW.TryTranslation(v) end

    if !atttable.AutoStats then return pros, cons, infos end

    -- Process togglable stats
    if atttable.ToggleStats then
        --local toggletbl = atttable.ToggleStats[toggle or 1]
        for ti, toggletbl in pairs(atttable.ToggleStats) do
            -- show the first stat block (unless NoAutoStats), and all blocks with AutoStats
            if toggletbl.AutoStats or (ti == (toggle or 1) and !toggletbl.NoAutoStats) then
                local dmgboth = toggletbl.Mult_DamageMin and toggletbl.Mult_Damage and toggletbl.Mult_DamageMin == toggletbl.Mult_Damage
                for i, stat in SortedPairsByMemberValue(ArcCW_AutoStats, "pr", true) do
                    if !toggletbl[i] or toggletbl[i .. "_SkipAS"] then continue end
                    local val = toggletbl[i]

                    local txt, typ = stattext(wep, toggletbl, i, val, dmgboth, ArcCW_AutoStats[i].flipsigns)
                    if !txt then continue end

                    local prefix = (stat[2] == "override" and k == true) and "" or ("[" .. (toggletbl.AutoStatName or toggletbl.PrintName or ti) .. "] ")

                    if typ == "pros" then
                        table.insert(pros, prefix .. txt)
                    elseif typ == "cons" then
                        table.insert(cons, prefix .. txt)
                    elseif typ == "infos" then
                        table.insert(infos, prefix .. txt)
                    end
                end
            end
        end
    end

    local dmgboth = atttable.Mult_DamageMin and atttable.Mult_Damage and atttable.Mult_DamageMin == atttable.Mult_Damage

    for i, _ in SortedPairsByMemberValue(ArcCW_AutoStats, "pr", true) do
        if !atttable[i] or atttable[i .. "_SkipAS"] then continue end

        -- Legacy support: If "Increased/Decreased magazine capacity" line exists, don't do our autostats version
        if hasmaginfo and i == "Override_ClipSize" then continue end

        if i == "UBGL" then 
            table.insert(infos, translate("autostat.ubgl2"))
        end

        local txt, typ = stattext(wep, atttable, i, atttable[i], dmgboth, ArcCW_AutoStats[i].flipsigns)
        if !txt then continue end

        if typ == "pros" then
            table.insert(pros, txt)
        elseif typ == "cons" then
            table.insert(cons, txt)
        elseif typ == "infos" then
            table.insert(infos, txt)
        end
    end

    return pros, cons, infos
end

local function ConvertFiremodeTable(firemodetbl)
    for _, v in ipairs(firemodetbl)
        local mode = v.Mode

        if mode == 0 then 
            v.Mode = firemodestrings["safe"]
        elseif mode == 1 then
            v.Mode = firemodestrings["semi"]
        elseif mode >= 2 then
            v.Mode = firemodestrings["auto"]
        elseif mode < 0 then
            v.Mode = string.format(firemodestrings["burst"], tostring(-mode)) 
        end
    end

    return firemodetbl
end

local function AmmoString(ammoname)
    if chicagoRP_NPCShop.isempty(ammoname) then return end

    return ammostrings[ammoname]
end

local function ArcCWStatString(str, statval)
    if str == "Recoil" or str == "RecoilSide" or str == "SpeedMult" or str == "SightedSpeedMult" or str == "SightTime" or str == "ShootSpeedMult" then
        return math.Round(statval * 20)
    else
        print("didn't parse arccw stat string")
        return statval
    end
end

local function ArcCWPrettyStatString(str, statval)
    if !istable(stataffix[str]) then return statval end

    local str = nil

    str = tostring(statval) .. stataffix[str][1]

    return str
end

function chicagoRP_NPCShop.GetArcCWAttStats(attname, pretty)
    local stattbl = {}
    local atttbl = scripted_ents.GetStored(attname)

    if !istable(atttbl) or table.IsEmpty(atttbl) then return end

    for i = 1, #ArcCW_AttStats do
        if !chicagoRP_NPCShop.isempty(atttbl.ArcCW_AttStats[i][1]) then
            local parsedstat = atttbl.ArcCW_AttStats[i][1]

            local paramtbl = {name = ArcCW_AttStats[i][1], stat = parsedstat}

            table.insert(stattbl, paramtbl)

            continue
        end
    end

    return stattbl
end

function chicagoRP_NPCShop.GetArcCWWeaponStats(wpnname, pretty)
    local stattbl = {}
    local wpntbl = weapons.GetStored(wpnname.ent)
    local wpnparams = {"Damage", "DamageMin", "RangeMin", "Range", "Penetration", "MuzzleVelocity", "BarrelLength", "Primary.ClipSize", "Recoil", "RecoilSide", "Delay", "Firemodes", "ShootVol", "AccuracyMOA", "HipDispersion", "MoveDispersion", "JumpDispersion", "Primary.Ammo", "SpeedMult", "SightedSpeedMult", "SightTime", "ShootSpeedMult"}
    local prettyparams = {"Damage", "Range", "Penetration", "MuzzleVelocity", "BarrelLength", "Primary.ClipSize", "Recoil", "RecoilSide", "Delay", "Firemodes", "ShootVol", "AccuracyMOA", "HipDispersion", "MoveDispersion", "JumpDispersion", "Primary.Ammo", "SpeedMult", "SightedSpeedMult", "SightTime", "ShootSpeedMult"}
    
    if pretty == nil or pretty == false then
        for _, v in ipairs(wpnparams) do
            local paramtbl = {name = v, stat = ArcCWStatString(v, wpntbl.[v])}

            if v == "Firemodes" then
                paramtbl = {name = v, stat = ConvertFiremodeTable(wpntbl.Firemodes)}
            end

            table.insert(stattbl, paramtbl)

            continue
        end
    elseif pretty == true
        for _, v in ipairs(prettyparams) do
            local parsedstat = ArcCWPrettyStatString(v, ArcCWStatString(v, wpntbl.[v]))

            if v == "Firemodes" then
                parsedstat = ConvertFiremodeTable(wpntbl.Firemodes)
            end

            if v == "Primary.Ammo" then
                parsedstat = AmmoString(wpntbl.[v])
            end

            if v == "Damage" and isnumber(wpntbl.["DamageMin"]) then
                parsedstat = tostring(wpntbl.["DamageMin"]) .. "-" .. tostring(wpntbl.["Damage"])
            end

            if v == "Range" and isnumber(wpntbl.["RangeMin"]) then
                parsedstat = tostring(wpntbl.["RangeMin"]) .. "m" .. "-" .. tostring(wpntbl.["Range"]) .. "m"
            end

            local paramtbl = {name = v, stat = parsedstat}

            table.insert(stattbl, paramtbl)

            continue
        end
    end

    return stattbl
end