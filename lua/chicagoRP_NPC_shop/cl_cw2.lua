local by = " by "
local percentage = "%"
local tempPositive = {}
local tempNegative = {}

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

local stataffix = {
    ["FireDelay"] = "RPM",
    ["MuzzleVelocity"] = "m/s"
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

local function ConvertFiremodeTable(firemodetbl)
    for _, v in ipairs(firemodetbl)
        v.Mode = firemodestrings[v]
    end

    return firemodetbl
end

local function CW2StatString(str, statval)
    if str == "Recoil" or str == "SpeedDec" or str == "HipSpread" or str == "AimSpread" then
        return math.Round(statval * 20)
    else
        print("didn't parse cw2 stat string")
        return statval
    end
end

local function CW2PrettyStatString(str, statval)
    if !istable(stataffix[str]) then return statval end

    local str = nil

    str = tostring(statval) .. stataffix[str][1]

    return str
end

function chicagoRP_NPCShop.GetCW2AttStats(attname)
    local stattbl = {}
    local atttbl = scripted_ents.GetStored(attname)

    if !istable(atttbl) or table.IsEmpty(atttbl) then return end

    for _, v in ipairs(atttbl.statModifiers) do
        local paramtbl = {name = v, stat = v[1]}

        table.insert(stattbl, paramtbl)

        continue
    end

    return stattbl
end

local function CW2FormatWeaponStatText(target, amount)
    local statText = CustomizableWeaponry.knownStatTexts[target]
    
    if statText then
        -- return text and colors as specified in the table
        if amount < 0 then
            return statText.lesser .. by .. math.Round(math.abs(amount * 100), 1) .. percentage, statText.lesserColor
        elseif amount > 0 then
            return statText.greater .. by .. math.Round(math.abs(amount * 100), 1) .. percentage, statText.greaterColor
        end
    end
    
    -- no result, rip
    return nil
end

local function CW2PrepareText(text, color)
    if text and color then -- sort into 2 different tables
        if color == CustomizableWeaponry.textColors.POSITIVE then
            table.insert(tempPositive, {t = text, c = color})
        else
            table.insert(tempNegative, {t = text, c = color})
        end
    end
end

function chicagoRP_NPCShop.GetCW2AttProsCons(itemtbl)
    local att = scripted_ents.GetStored(itemtbl.ent)

    if !chicagoRP_NPCShop.IsArcCWAtt(itemtbl.ent) then return end

    if !att.statModifiers then -- no point in doing anything if there are no stat modifiers
        return nil
    end

    att.description = {} -- create a new desc table regardless

    local pros = {}
    local cons = {}
    
    if att._description then
        for key, data in ipairs(att._description) do
            att.description[key] = data
        end
    end
    
    local pos = 0
    
    -- get position of positive stat text
    for key, value in ipairs(att.description) do
        if value.c == CustomizableWeaponry.textColors.POSITIVE or value.c == CustomizableWeaponry.textColors.VPOSITIVE then
            pos = math.max(pos, key) + 1
        end
    end
    
    -- if there is none, assume first possible position
    if pos == 0 then
        pos = #att.description + 1
    end
    
    -- loop through, format negative and positive texts into 2 separate tables
    for stat, amount in pairs(att.statModifiers) do
        CW2PrepareText(CW2FormatWeaponStatText(stat, amount))
    end
    
    for stat, data in pairs(CustomizableWeaponry.knownVariableTexts) do
        if att[stat] then
            CW2PrepareText(CW2FormatWeaponStatText(att, stat, data))
        end
    end
    
    -- now insert the positive text first and increment the position of positive text by 1 (since it's positive text we're inserting)
    for _, data in ipairs(tempPositive) do
        table.insert(pros, pos, data)
        pos = pos + 1
    end
    
    -- now insert negative text, but don't increment the position, since it's negative text
    for _, data in ipairs(tempNegative) do
        table.insert(cons, pos, data)
    end
    
    table.Empty(tempNegative)
    table.Empty(tempPositive)

    return pros, cons
end

function chicagoRP_NPCShop.GetCW2WeaponStats(wpnname, pretty)
    local stattbl = {}
    local wpntbl = weapons.GetStored(wpnname.ent)
    local wpnparams = {"Damage", "Recoil", "MuzzleVelocity", "FireDelay", "AimSpread", "HipSpread", "Primary.ClipSize", "ReloadTime", "SpeedDec", "FireModes", "Primary.Ammo"}
    
    if pretty == nil or pretty == false then
        for _, v in ipairs(wpnparams) do
            local paramtbl = {name = v, stat = CW2StatString(v, wpntbl.[v])}

            table.insert(stattbl, paramtbl)

            continue
        end
    elseif pretty == true
        for _, v in ipairs(wpnparams) do
            local parsedstat = CW2PrettyStatString(v, CW2StatString(v, wpntbl.[v]))

            if v == "FireModes" then
                parsedstat = ConvertFiremodeTable(wpntbl.FireModes)
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