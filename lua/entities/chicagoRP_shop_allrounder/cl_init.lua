include("shared.lua")

local whitecolor = Color(255, 255, 255, 255)

function ENT:Draw()
	self:DrawModel()

	local dist = self:GetPos():Distance(EyePos())
	local clam = math.Clamp(dist, 0, 255)
	local main = (255 - clam)

	if (main <= 0) then return end

	local ahAngle = self:GetAngles()
	local plyEyeAng = LocalPlayer():EyeAngles()
	local text = self:GetPrintName()

	ahAngle:RotateAroundAxis(ahAngle:Forward(), 90)
	ahAngle:RotateAroundAxis(ahAngle:Right(), -90)

	cam.Start3D2D(self:GetPos() + self:GetUp() * 80, Angle(0, plyEyeAng.y - 90, 90), 0.175)
		-- surface.SetDrawColor(Color(whitecolor.x, whitecolor.y, whitecolor.z, main))
		draw.SimpleTextOutlined(text, "chicagoRP_NPCShop", 0, 13, Color(whitecolor.x, whitecolor.y, whitecolor.z, main), 1, 0, 1, Color(25, 25, 25, main))
	cam.End3D2D()
end