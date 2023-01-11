ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "All Around Shop"
ENT.Author = "SpiffyJUNIOR"
ENT.Category = "chicagoRP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true

function ENT:GetPrintName()
	return SWEP.PrintName
end

function ENT:Think()
    self:NextThink(CurTime())

    return true
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "HeaderText")
    self:NetworkVar("String", 1, "TableType")
    self:NetworkVar("String", 2, "NetWorkId")
    self:NetworkVar("Vector", 0, "ThemeColor")
end