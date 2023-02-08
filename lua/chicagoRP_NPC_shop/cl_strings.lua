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

function chicagoRP_NPCShop.RemoveStrings(source, pretty) -- i'm not doing a full fucking table loop (nvm maybe i will)
    if !istable(source) or table.IsEmpty(source) then return end

    source[ent] = nil
    source[infotext] = nil
    source[printname] = nil
    source[override] = nil
    source[discount] = nil
    source[discounttime] = nil
    source[restock] = nil

    if !pretty or pretty == nil then return source end

    source[price] = nil
    source[quanity] = nil
    -- source[restock] = nil

    return source
end