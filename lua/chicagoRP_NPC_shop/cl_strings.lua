local langstrings = {
    ["DamageMin"] = "Damage", -- ARC9
    ["RangeMin"] = "Range",
    ["PhysBulletMuzzleVelocity"] = "Muzzle Velocity",
    ["RecoilUp"] = "Recoil",
    ["RPM"] = "Firerate",
    ["SpreadMultHipFire"] = "Hipfire Spread",
    ["SpeedMultSights"] = "ADS Movement Speed",
    ["AimDownSightsTime"] = "ADS Time"
    ["Damage"] = "Damage", -- ArcCW
    ["Range"] = "Range",
    ["Penetration"] = "Penetration",
    ["MuzzleVelocity"] = "Muzzle Velocity",
    ["BarrelLength"] = "Barrel Length",
    ["Primary.ClipSize"] = "Magazine Size",
    ["Recoil"] = "Recoil",
    ["RecoilSide"] = "Recoil (Horizontal)",
    ["Delay"] = "Firerate",
    ["Firemodes"] = "Firemodes",
    ["ShootVol"] = "Shoot Volume",
    ["AccuracyMOA"] = "Accuracy",
    ["HipDispersion"] = "Hipfire Spread",
    ["MoveDispersion"] = "Move Spread",
    ["JumpDispersion"] = "Jump Spread",
    ["Primary.Ammo"] = "Ammo",
    ["SpeedMult"] = "Movement Speed",
    ["SightedSpeedMult"] = "ADS Movement Speed",
    ["SightTime"] = "ADS Time",
    ["ShootSpeedMult"] = "Shooting Movement Speed",
    ["FireDelay"] = "Firerate", -- CW2
    ["AimSpread"] = "Accuracy",
    ["HipSpread"] = "Hipfire Spread",
    ["ReloadTime"] = "Reload Speed",
    ["SpeedDec"] = "Movement Speed",
    ["Primary.Damage"] = "Damage", -- M9K
    ["Primary.Spread"] = "Accuracy",
    ["Primary.RPM"] = "Firerate",
    ["Primary.KickUp"] = "Recoil",
    ["Primary.KickHorizontal"] = "Recoil (Horizontal)",
    ["Primary.Automatic"] = "Firemodes"
}

function chicagoRP_NPCShop.GetPhrase(str)
    if istable(str) or chicagoRP_NPCShop.isempty(str) then print("GetPhrase stopped!") return str end

    return langstrings[str]
end

function chicagoRP_NPCShop.PrettifyString(str)
    local cachestr = str
    if string.StartWith(str, "%u") then return str end

    local upperstr = string.gsub(cachestr, "^%l", string.upper)

    return upperstr
end

function chicagoRP_NPCShop.RemoveStrings(source, pretty) -- i'm not doing a full fucking table loop (nvm maybe i will)
    if !istable(source) or table.IsEmpty(source) then return end

    source["ent"] = nil
    source["bodygroups"] = nil
    source["infotext"] = nil
    source["printname"] = nil
    source["override"] = nil
    source["discount"] = nil
    source["discounttime"] = nil
    source["restock"] = nil

    if !pretty or pretty == nil then return source end

    source["price"] = nil
    source["quanity"] = nil
    -- source[restock] = nil

    return source
end