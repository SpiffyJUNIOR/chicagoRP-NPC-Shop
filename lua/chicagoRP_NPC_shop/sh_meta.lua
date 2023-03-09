local categories = chicagoRP_NPCShop.categories

for i = 1, #categories do -- hashtable index
    local category = chicagoRP_NPCShop.[categories[i].name]

    for i2 = 1, #category do
        chicagoRP_NPCShop.iteminfo[category[i2].ent] = category[i2]
        -- chicagoRP_NPCShop.iteminfo[itemtbl.ent].ent = itemtbl.ent
        -- chicagoRP_NPCShop.iteminfo[itemtbl.ent].override = itemtbl.override or false
        -- chicagoRP_NPCShop.iteminfo[itemtbl.ent].price = itemtbl.price
        -- chicagoRP_NPCShop.iteminfo[itemtbl.ent].quanity = itemtbl.quanity
        -- chicagoRP_NPCShop.iteminfo[itemtbl.ent].restock = itemtbl.restock
    end
end

function chicagoRP_NPCShop.isempty(s)
    return s == nil or s == ""
end

function chicagoRP_NPCShop.ismaterial(mat)
    return type(mat) == Material
end

function chicagoRP_NPCShop.GetItemTable(ent)
    return chicagoRP_NPCShop.iteminfo[ent]
end

function chicagoRP_NPCShop.InRange(number, min, max)
    return number >= min and number <= max
end