local HideHUD = false
local OpenMotherFrame = nil
local Dynamic = 0
-- local enabled = GetConVar("cl_chicagoRP_NPCShop_enable"):GetBool()
local reddebug = Color(200, 10, 10, 150)
local whitecolor = Color(255, 255, 255, 255)
local blackcolor = Color(0, 0, 0, 255)
local blurMat = Material("pp/blurscreen")

local function isempty(s)
    return s == nil or s == ''
end

local function BlurBackground(panel)
    if (!IsValid(panel) or !panel:IsVisible()) then return end
    local layers, density, alpha = 1, 1, 100
    local x, y = panel:LocalToScreen(0, 0)
    local FrameRate, Num, Dark = 1 / RealFrameTime(), 5, 0

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blurMat)

    for i = 1, Num do
        blurMat:SetFloat("$blur", (i / layers) * density * Dynamic)
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end

    surface.SetDrawColor(0, 0, 0, Dark * Dynamic)
    surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
    Dynamic = math.Clamp(Dynamic + (1 / FrameRate) * 7, 0, 1)
end

surface.CreateFont("chicagoRP_NPCShop", {
    font = "Roboto",
    size = 36,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true
})

hook.Add("HUDShouldDraw", "chicagoRP_NPCShop_HideHUD", function()
    if HideHUD == true then
        return false
    end
end)

net.Receive("chicagoRP_NPCShopGUI", function()
    local ply = LocalPlayer()
    if IsValid(OpenMotherFrame) then OpenMotherFrame:Close() return end
    if !IsValid(ply) then return end
    if !enabled then return end

    local closebool = net.ReadBool()

    if closebool == false then return end

    local screenwidth = ScrW()
    local screenheight = ScrH()
    local motherFrame = vgui.Create("DFrame")
    motherFrame:SetSize(screenwidth / 2, screenheight / 2)
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(false)
    motherFrame:ShowCloseButton(true)
    motherFrame:SetTitle("NPC Shop")
    motherFrame:ParentToHUD()
    HideHUD = true

    chicagoRP.PanelFadeIn(motherFrame, 0.15)

    motherFrame:MakePopup()
    motherFrame:Center()

    function motherFrame:OnClose()
        if IsValid(self) then
            chicagoRP.PanelFadeOut(motherFrame, 0.15)
        end

        HideHUD = false
    end

    function motherFrame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE or key == KEY_Q then
            surface.PlaySound("chicagoRP_settings/back.wav")
            timer.Simple(0.15, function()
                if IsValid(self) then
                    self:Close()
                end
            end)
        end
    end

    function motherFrame:Paint(w, h)
        BlurBackground(self)
    end

    OpenMotherFrame = motherFrame
end)

print("chicagoRP NPC Shop GUI loaded!")














