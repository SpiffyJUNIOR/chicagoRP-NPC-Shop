AddCSLuaFile()

for i, f in pairs(file.Find("chicagoRP_NPC_shop/*.lua", "LUA")) do
    if string.Left(f, 3) == "sv_" then
        if SERVER then 
            include("chicagoRP_NPC_shop/" .. f) 
        end
    elseif string.Left(f, 3) == "cl_" then
        if CLIENT then
            include("chicagoRP_NPC_shop/" .. f)
        else
            AddCSLuaFile("chicagoRP_NPC_shop/" .. f)
        end
    elseif string.Left(f, 3) == "sh_" then
        AddCSLuaFile("chicagoRP_NPC_shop/" .. f)
        include("chicagoRP_NPC_shop/" .. f)
    else
        print("chicagoRP NPC Shop detected unaccounted for lua file '" .. f .. "' - check prefixes!")
    end
    print("chicagoRP NPC Shop successfully loaded!")
end
