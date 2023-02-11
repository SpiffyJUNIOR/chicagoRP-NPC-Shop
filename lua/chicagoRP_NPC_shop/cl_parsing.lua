local function EntityPrintName(enttbl)
    local printname = nil
    local enttbl = scripted_ents.GetStored(itemtbl.ent)
    local sweptbl = weapons.GetStored(enttbl.ent)

    if istable(sweptbl) and !table.IsEmpty(sweptbl) then
        printname = sweptbl.PrintName

        if ArcCW and truenames_enabled:GetBool() and sweptbl.Base == ("arccw_base" or "weapon_base_kent") then
            printname = sweptbl.TrueName
        end
    elseif istable(enttbl) and !table.IsEmpty(enttbl) then
        printname = enttbl.PrintName
    else
        print("Failed to parse entity printname, check your shop table!")
    end

    return printname
end

local function EntityModel(enttbl)
    local model = nil
    local enttbl = scripted_ents.GetStored(itemtbl.ent)
    local sweptbl = weapons.GetStored(enttbl.ent)

    if istable(sweptbl) and !table.IsEmpty(sweptbl) then
        model = sweptbl.ViewModel or sweptbl.Model
    elseif istable(enttbl) and !table.IsEmpty(enttbl) then
        printname = enttbl.DroppedModel or enttbl.Mdl or enttbl.Model
        print(enttbl)
    else
        model = "models/props_borealis/bluebarrel001.mdl"
        print("Failed to parse entity model, check your shop table!")
    end

    return model
end

function chicagoRP_NPCShop.GetModelIcon(enttbl)
    local modelicon = nil

    return modelicon
end

function chicagoRP_NPCShop.GetStats(itemtbl)
    local stattbl = nil
    local enttbl = scripted_ents.GetStored(itemtbl.ent) -- how do we get entity table
    local sweptbl = weapons.GetStored(itemtbl.ent)

    if istable(sweptbl) and !table.IsEmpty(sweptbl) then
        for _, v in ipairs(wpnparams) do
            if chicagoRP_NPCShop.isempty(sweptbl.v) then continue end

            table.insert(stattbl, sweptbl.v)
        end

        return stattbl
    elseif istable(enttbl) and !table.IsEmpty(enttbl) then
        -- for _, v in ipairs(attparams) do
        --     if chicagoRP_NPCShop.isempty(sweptbl.v) then continue end

        --     table.insert(stattbl, sweptbl.v)
        -- end
        if itemtbl.override == true then
            stattbl = chicagoRP_NPCShop.RemoveStrings(itemtbl, true)

            return stattbl
        elseif chicagoRP_NPCShop.IsArcCWAtt(enttbl) then
            return nil
        end
        print(enttbl)
    else
        print("Failed to parse stats, check your code or report this error to the github!")
    end
end