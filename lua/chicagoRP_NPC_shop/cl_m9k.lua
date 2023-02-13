local ammostrings = {
    ["pistol"] = "Pistol",
    ["smg1"] = "Carbine",
    ["ar2"] = "Rifle",
    ["SniperPenetratedRound"] = "Sniper",
    ["buckshot"] = "Shotgun",
    ["357"] = "Magnum",
    ["smg1_grenade"] = "Grenade"
}

local stataffix = {
    ["Primary.RPM"] = "RPM"
}

local function M9KFiremodesToString(bool)
    local concattedstr = ""

    if bool then
        concattedstr = "Full-Auto"
    else
        concattedstr = "Semi-Auto"
    end

    return concattedstr
end

local function AmmoString(ammoname)
    if chicagoRP_NPCShop.isempty(ammoname) then return end

    return ammostrings[ammoname]
end

local function M9KStatString(str, statval)
    if str == "Primary.Spread" then
        return 100 - (statval * 1000)
    elseif str == "Primary.KickUp" or str == "Primary.KickHorizontal" then
        return statval * 20
    elseif str == "Primary.RPM" then
        return tostring(statval) .. "RPM"
    else
        print("didn't parse arccw stat string")
        return statval
    end
end

local function M9KPrettyStatString(str, statval)
    if !istable(stataffix[str]) then return statval end

    local str = nil

    str = tostring(statval) .. stataffix[str][1]

    return str
end

function chicagoRP_NPCShop.GetM9KStats(wpnname, pretty)
    local stattbl = {}
    local wpntbl = weapons.GetStored(wpnname.ent)
    local wpnparams = {"Primary.Damage", "Primary.Spread", "Primary.Ammo", "Primary.RPM", "Primary.KickUp", "Primary.KickHorizontal","Primary.ClipSize", "Primary.Automatic"}
    
    if pretty == nil or pretty == false then
        for _, v in ipairs(wpnparams) do
            local paramtbl = {name = v, stat = M9KStatString(v, wpntbl.[v])}

            if v == "Firemodes" then
                paramtbl = {name = v, stat = M9KFiremodesToString(v, wpntbl.[v])}
            end

            table.insert(stattbl, paramtbl)

            continue
        end
    elseif pretty == true
        for _, v in ipairs(wpnparams) do
            local parsedstat = M9KPrettyStatString(v, M9KStatString(v, wpntbl.[v]))

            if v == "Primary.Automatic" then
                parsedstat = M9KFiremodesToString(v, wpntbl.[v])
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