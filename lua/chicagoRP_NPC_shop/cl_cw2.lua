local ammostrings = {
    ["pistol"] = "Pistol",
    ["smg1"] = "Carbine",
    ["ar2"] = "Rifle",
    ["SniperPenetratedRound"] = "Sniper",
    ["buckshot"] = "Shotgun",
    ["357"] = "Magnum",
    ["smg1_grenade"] = "Grenade",
    ["7.62x39MM"] = "7.62x39mm", -- cw2 custom ammo types
    ["7.62x51MM"] = "7.62x51mm",
    ["7.62x54MMR"] = "7.62x54mmR",
    ["5.45x39MM"] = "5.45x39mm",
    ["5.56x45MM"] = "5.56x45mm",
    ["5.7x28MM"] = "5.7x28mm",
    [".44 Magnum"] = ".44 Magnum",
    [".45 ACP"] = ".45 ACP",
    [".50 AE"] = ".50 AE",
    ["9x19MM"] = "9x19mm",
    ["12 Gauge"] = "12 Gauge",
    ["40MM"] = "40mm",
    ["Frag Grenades"] = "Frag Grenades",
    ["Smoke Grenades"] = "Smoke Grenades",
    ["Flash Grenades"] = "Flash Grenades"
}

local firemodestrings = {
    ["auto"] = "Full-Auto",
    ["semi"] = "Semi-Auto",
    ["double"] = "Double-Action",
    ["bolt"] = "Bolt-Action",
    ["pump"] = "Pump-Action",
    ["break"] = "Break-Action",
    ["2burst"] = "2-Round Burst",
    ["3burst"] = "3-Round Burst",
    ["safe"] = "Safe"
}

local function AmmoString(ammoname)
    if chicagoRP_NPCShop.isempty(ammoname) then return end

    return ammostrings[ammoname]
end

local function CW2FiremodesToString(firemodetbl)
    local concattedstr = ""

    for _, v in ipairs(firemodetbl)
        local mode = v.Mode
        local str = nil

        str = firemodestrings[v]

        concattedstr = concattedstr .. " " .. str
    end

    return concattedstr
end

local function CW2StatString(str, statval)
    if str == "MuzzleVelocity" then
        return tostring(statval) .. "m/s"
    elseif str == "Recoil" then
        return math.Round(statval * 20)
    elseif str == "FireDelay" then
        return tostring(statval) .. "RPM"
    elseif str == "SpeedDec" then
        return math.Round(statval * 20)
    elseif str == "HipSpread" then
        return math.Round(statval * 20)
    elseif str == "AimSpread" then
        return math.Round(statval * 20)
    else
        print("didn't parse cw2 stat string")
        return statval
    end
end

function chicagoRP_NPCShop.GetCW2Stats(wpnname, pretty)
    local stattbl = {}
    local wpntbl = weapons.GetStored(wpnname.ent)
    local wpnparams = {"Damage", "Recoil", "MuzzleVelocity", "FireDelay", "AimSpread", "HipSpread", "Primary.ClipSize", "ReloadTime", "SpeedDec", "FireModes", "Primary.Ammo"}
    
    for _, v in ipairs(wpnparams) do
        if pretty == nil or pretty == false then
            local paramtbl = {name = v, stat = wpntbl.[v]}

            table.insert(stattbl, paramtbl)

            continue
        elseif pretty == true
            local parsedstat = CW2StatString(v, wpntbl.[v])

            if v == "FireModes" then
                parsedstat = CW2FiremodesToString(v, wpntbl.[v])
            end

            if v == "Primary.Ammo" then
                parsedstat = AmmoString(wpntbl.[v])
            end

            local paramtbl = {name = v, stat = parsedstat}

            table.insert(stattbl, paramtbl)

            continue
        end
    end

    return stattbl
end

function chicagoRP_NPCShop.IsCW2Att(ent)
    return CustomizableWeaponry and !chicagoRP_NPCShop.isempty(string.find(ent, "cw_"))
end