function chicagoRP_NPCShop.isempty(s)
    return s == nil or s == ""
end

function chicagoRP_NPCShop.ismaterial(mat)
    return type(mat) == Material
end