util.AddNetworkString("chicagoRP_NPCShop_GUI")
util.AddNetworkString("chicagoRP_NPCShop_sendcart")

local function isempty(s)
    return s == nil or s == ""
end

net.Receive("chicagoRP_NPCShop_sendcart", function(_, ply)
	if !IsValid(ply) or !ply:Alive() or !ply:OnGround() or ply:InVehicle() then return end

	local viewtrace = ply:GetEyeTraceNoCursor()
	local entname = viewtrace.Entity:GetName()

	if string.Left(entname, 15) != "chicagoRP_shop_" then return end -- EZ anti-exploit
end)