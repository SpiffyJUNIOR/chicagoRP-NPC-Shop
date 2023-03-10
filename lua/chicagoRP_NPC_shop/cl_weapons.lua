function chicagoRP_NPCShop.GetAttSlot(enttbl)
    if !chicagoRP_NPCShop.IsArcCWAtt(enttbl) then return end
    local attbl = scripted_ents.GetStored(enttbl.ent)

    return attbl.Slot
end

function chicagoRP_NPCShop.GetWeaponBase(ent)
    local sweptbl = weapons.GetStored(ent)
    local swepbase = sweptbl.Base

    if !istable(sweptbl) or table.IsEmpty(sweptbl) then return end

    if swepbase == "arccw_base" or swepbase == "weapon_base_kent" then
        return "arccw"
    elseif swepbase == "arc9_go_base" or swepbase == "arc9_base" then
        return "arc9"
    elseif swepbase == "cw_base" then
        return "cw2"
    elseif swepbase == "tfa_gun_base" then 
        return "tfa"
    elseif swepbase == "bobs_gun_base" then
        return "m9k"
    else
        return "default"
    end
end

function chicagoRP_NPCShop.GetAttBase(ent)
    if chicagoRP_NPCShop.IsArcCWAtt(ent) then
        return "arccw"
    elseif chicagoRP_NPCShop.IsARC9Att(ent) then
        return "arc9"
    elseif chicagoRP_NPCShop.IsCW2Att(ent) then
        return "cw2"
    else
        return "default"
    end
end

function chicagoRP_NPCShop.GetAttStats(itemtbl) -- Real
    local attbase = GetAttBase(itemtbl.ent)

    if attbase == "arccw" then
        return chicagoRP_NPCShop.GetArcCWAttStats(itemtbl.wpn, itemtbl)
    elseif attbase == "arc9" then
        return chicagoRP_NPCShop.GetARC9AttStats(itemtbl.wpn, itemtbl)
    elseif attbase == "cw2" then
        return chicagoRP_NPCShop.GetCW2AttStats(itemtbl.wpn, itemtbl)
    end

    return nil
end

function chicagoRP_NPCShop.GetAttProsCons(itemtbl)
    local attbase = GetAttBase(itemtbl.ent)

    if attbase == "arccw" then
        return chicagoRP_NPCShop.GetArcCWAttProsCons(itemtbl.wpn, itemtbl)
    elseif attbase == "arc9" then
        return chicagoRP_NPCShop.GetARC9AttProsCons(itemtbl.wpn, itemtbl)
    elseif attbase == "cw2"
        return chicagoRP_NPCShop.GetCW2AttProsCons(itemtbl)
    end

    return nil
end

function chicagoRP_NPCShop.FetchBodygroups(itemtbl)
    if chicagoRP_NPCShop.isempty(itemtbl.wpn) then return end

    local wepbase = chicagoRP_NPCShop.GetWeaponBase(itemtbl.wpn)

    if wepbase == "arccw" then
        return chicagoRP_NPCShop.ArcCWBodygroup(itemtbl.wpn, itemtbl.ent)
    elseif wepbase == "arc9" then
        return chicagoRP_NPCShop.ArcCWBodygroup(itemtbl.wpn, itemtbl.ent)
    end

    return nil
end