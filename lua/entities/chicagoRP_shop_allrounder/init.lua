AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/player/group01/male_07.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:CapabilitiesAdd(CAP_TURN_HEAD)
    self:DropToFloor()
    self:SetMaxYawSpeed(90)
    self:SetCollisionGroup(1)
    self:SetActivity(ACT_IDLE)
end

function ENT:AcceptInput(key, ply)
    if (self.lastUsed or CurTime()) <= CurTime() then
        self.lastUsed = CurTime() + 0.50

        if key == "Use" and ply:IsPlayer() and IsValid(ply) then
        	self:SetActivity(ACT_GMOD_GESTURE_WAVE)

            -- self:EmitSound("chicagorp_npcshop/voiceline".. math.random(1, 8) ..".ogg", 60, 100, 1, CHAN_VOICE)

            net.Start("chicagoRP_NPCShop_GUI")
            net.WriteBool(true)
            net.Send(ply)
        end
    end
end