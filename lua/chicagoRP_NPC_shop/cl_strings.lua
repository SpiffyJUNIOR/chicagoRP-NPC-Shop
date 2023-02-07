function chicagoRP_NPCShop.PrettifyString(str)
    local cachestr = str
    if string.StartWith(str, "%u") then return str end

    local upperstr = string.gsub(cachestr, "^%l", string.upper)

    return upperstr
end

function chicagoRP_NPCShop.PrettifyArcCWString(str)
    if chicagoRP_NPCShop.isempty(str) then return nil end
    local indexedstr = L[str]

    if !chicagoRP_NPCShop.isempty(indexedstr) then
        return indexedstr
    end

    return PrettifyString(str)
end