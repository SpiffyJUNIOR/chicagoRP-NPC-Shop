local HideHUD = false
local OpenMotherFrame = nil
local OpenItemFrame = nil
local carttable = {}
local filtertable = {}
local discounttable = nil
local Dynamic = 0
local whitecolor = Color(255, 255, 255, 255)
local blackcolor = Color(0, 0, 0, 255)
local graycolor = Color(20, 20, 20, 200)
local slightyellowcolor = Color(253, 255, 180, 255)
local slightbluecolor = Color(225, 255, 250, 255)
local purplecolor = Color(200, 200, 30, 255) -- probably not purple
local reddebug = Color(200, 10, 10, 150)
local enabled = GetConVar("cl_chicagoRP_NPCShop_enable")
local blurMat = Material("pp/blurscreen")

local function isempty(s)
    return s == nil or s == ""
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

local function SmoothScrollBar(vbar) -- why
    vbar.nInit = vbar.Init
    function vbar:Init()
        self:nInit()
        self.DeltaBuffer = 0
    end

    vbar.nSetUp = vbar.SetUp
    function vbar:SetUp(_barsize_, _canvassize_)
        self:nSetUp(_barsize_, _canvassize_)
        self.BarSize = _barsize_
        self.CanvasSize = _canvassize_ - _barsize_
        if (1 > self.CanvasSize) then self.CanvasSize = 1 end
    end

    vbar.nAddScroll = vbar.AddScroll
    function vbar:AddScroll(dlta)
        self:nAddScroll(dlta)

        self.DeltaBuffer = OldScroll + (dlta * (self:GetSmoothScroll() && 75 || 50))
        if (self.DeltaBuffer < -self.BarSize) then self.DeltaBuffer = -self.BarSize end
        if (self.DeltaBuffer > (self.CanvasSize + self.BarSize)) then self.DeltaBuffer = self.CanvasSize + self.BarSize end
    end

    vbar.nSetScroll = vbar.SetScroll
    function vbar:SetScroll(scrll)
        self:nSetScroll(scrll)

        if (scrll > self.CanvasSize) then scrll = self.CanvasSize end
        if (0 > scrll ) then scrll = 0 end
        self.Scroll = scrll
    end

    function vbar:AnimateTo(scrll, length, delay, ease)
        self.DeltaBuffer = scrll
    end

    function vbar:GetDeltaBuffer()
        if (self.Dragging) then self.DeltaBuffer = self:GetScroll() end
        if (!self.Enabled) then self.DeltaBuffer = 0 end
        return self.DeltaBuffer
    end

    vbar.nThink = vbar.Think
    function vbar:Think()
        self:nThink()
        if (!self.Enabled) then return end

        local FrameRate = (self.CanvasSize / 10) > math.abs(self:GetDeltaBuffer() - self:GetScroll()) && 2 || 5
        self:SetScroll(Lerp(FrameTime() * (self:GetSmoothScroll() && FrameRate || 10), self:GetScroll(), self:GetDeltaBuffer()))

        if (self.CanvasSize > self.DeltaBuffer && self.Scroll == self.CanvasSize) then self.DeltaBuffer = self.CanvasSize end
        if (0 > self.DeltaBuffer && self.Scroll == 0) then self.DeltaBuffer = 0 end
    end
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

local function CategoryButton(parent, index, w, h)
    local catButton = parent:Add("DButton")
    catButton:Dock(TOP)
    catButton:DockMargin(0, 0, 10, 0)
    catButton:SetSize(w, h)

    local cattable = chicagoRP_NPCShop.categories[index]

    catButton:SetText(string.upper(cattable.name)) -- how do we only uppercase the first letter of a word?

    function catButton:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 20, 0, whitecolor, TEXT_ALIGN_LEFT)
        surface.SetMaterial(cattable.icon)
        surface.DrawTexturedRectRotated(x, y, w, h, 0) -- how do we make the cubemap rotate with model orientation?

        if self:IsHovered() then
            whitecolor.a = 100

            draw.RoundedBox(2, 0, 0, w, h, whitecolor)
        end

        return nil
    end

    return catButton
end

local function CategoryPanel(parent, x, y, w, h)
    local categoryScrollPanel = vgui.Create("DScrollPanel", parent)
    categoryScrollPanel:SetPos(x, y)
    categoryScrollPanel:SetSize(w, h)

    function categoryScrollPanel:Paint(w, h)
        return nil
    end

    local categoryScrollBar = categoryScrollPanel:GetVBar()
    function categoryScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function categoryScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    SmoothScrollBar(categoryScrollBar)

    return categoryScrollPanel
end

local function QuanitySelector(parent, x, y, w, h)
    local numberWang = vgui.Create("DNumberWang", parent)
    numberWang:SetSize(w, h)
    numberWang:SetPos(x, y)

    function numberWang:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText(self:GetValue(), "chicagoRP_NPCShop", 0, 0, whitecolor, TEXT_ALIGN_LEFT)

        return true
    end

    function numberWang.Up:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)

        return true
    end

    function numberWang.Down:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor) -- how do we get icons?

        return true
    end

    return numberWang
end

local function AddCartButton(parent, x, y, w, h)
    if item == nil or parent == nil then return end

    local cartButton = vgui.Create("DButton", parent)
    cartButton:SetSize(w, h)
    cartButton:SetPos(x, y)

    function cartButton:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 210, 220))

        return true
    end

    return cartButton
end

local function CreateItemPanel(parent, itemname, w, h) -- how do we do args aka (...)???
    if itemname == nil or parent == nil then return end

    -- local itemButton = vgui.Create("DButton", parent)
    local itemButton = parent:Add("DButton")
    itemButton:Dock(TOP)
    itemButton:DockMargin(0, 10, 30, 30)
    -- itemButton:SetSize(w, h)
    itemButton:SetPos(x, y)

    function itemButton:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, graycolor)
        -- surface.SetMaterial(nil) -- how do we get spawnicon?
        surface.DrawTexturedRectRotated(20, y, w, 64, 0)

        return true
    end

    function itemButton:DoClick()
        local expandedPanel = ExpandedItemPanel(itemname)
    end

    local cartButton = AddCartButton(parent, itemname, x, y, w, h)
    local quanitySel = QuanitySelector(parent, 200, 0, 40, 20)

    function quanitySel:OnValueChanged(val)
        print("Quanity: " .. val)
        cartButton.value = val
    end

    function cartButton:DoClick()
        local quanity = self.value -- how do we do if quanity > server_quanity then func return end?
        local finaltable = {itemname, quanity}

        for _, v in ipairs(carttable) do
            if v.itemname == itemname then
                v.quanity = v.quanity + quanity
            else
                table.insert(carttable, finaltable)
            end
        end
    end

    return itemButton
end

local function ItemScrollPanel(parent, x, y, w, h)
    local itemScrPanel = vgui.Create("DScrollPanel", parent)
    itemScrPanel:SetPos(x, y)
    itemScrPanel:SetSize(w, h)

    function itemScrPanel:Paint(w, h)
        return nil
    end

    local itemScrollBar = itemScrPanel:GetVBar()
    function itemScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function itemScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    SmoothScrollBar(itemScrollBar)

    return itemScrPanel
end

local function SearchBox(parent, x, y, w, h)
    local textEntry = vgui.Create("DTextEntry", parent)
    textEntry:SetSize(w, h)
    textEntry:SetPos(x, y)
    textEntry:SetText("Search...")

    function textEntry:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    function textEntry:OnValueChange(value)
        local newtext = self:GetText()

        print(newtext)
        print(value)
    end

    return textEntry
end

local function FilterCheckBox(parent, text, x, y, w, h) -- how do we do togglable options?
    local checkBox = vgui.Create("DCheckBoxLabel", parent)
    checkBox:SetSize(w, h)
    checkBox:SetPos(x, y)
    checkBox:SetText(text)
    checkBox:SetValue(false)
    checkBox:SetTextInset(32, 0)

    function checkBox:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText("Armor Levels", "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    function checkBox:OnMenuOpened())
        for i, _ in ipairs(self:GetChildren()) do
            local opt = self.Menu:GetChild(i)
            function opt:Paint(_w, _h)
                draw.DrawText("FUCKING FED...", "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)
                draw.RoundedBox(2, 0, 0, _w, _h, graycolor)
            end

            opt.oPerformLayout = opt.PerformLayout
            function opt:PerformLayout(__w, __h)
                self:oPerformLayout(__w, __h)
                self:SetSize(w, 40)
                self:SetTextInset(0, 0)
            end
        end
    end

    return checkBox
end

local function FilterComboBox(parent, x, y, w, h)
    local dropDownPanel = vgui.Create("DComboBox", parent)
    dropDownPanel:SetSize(w, h)
    dropDownPanel:SetPos(x, y)

    -- function dropDownPanel:Paint(w, h)
    --     draw.RoundedBox(2, 0, 0, w, h, graycolor)
    --     draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

    --     return nil
    -- end

    return dropDownPanel
end

local function FilterBox(parent, x, y, w, h)
    local filterPanel = vgui.Create("DPanel", parent)
    filterPanel:SetSize(w, h)
    filterPanel:SetPos(x, y)

    function filterPanel:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)

        return nil
    end

    return filterPanel
end

local function ScrollingTextPanel(parent, x, y, w, h, text)
    if isempty(text) then text = "Text is empty!" end

    local textScrollPanel = vgui.Create("DScrollPanel", parent)
    textScrollPanel:SetPos(x, y)
    textScrollPanel:SetSize(w, h)

    function textScrollPanel:Paint(w, h)
        return nil
    end

    local textScrollBar = textScrollPanel:GetVBar()
    function textScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function textScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    SmoothScrollBar(textScrollBar)

    -- how do we do textwrap and line breaks?

    return ScrollingTextPanel
end

local function FancyModelPanel(parent, model, x, y, w, h, lightcolor)
    if lightcolor == nil then lightcolor = whitecolor end
    if model == nil or parent == nil then return end

    local parentPanel = vgui.Create("DPanel", parent)
    parentPanel:SetSize(w, h)
    parentPanel:SetPos(x, y)

    function parentPanel:Paint(w, h)
        surface.SetMaterial(nil) -- how do we get cubemap from map?
        -- surface.DrawTexturedRectUV(x, y, w, h, 0, 0, 1, 1)
        surface.DrawTexturedRectRotated(x, y, w, h, 0) -- how do we make the cubemap rotate with model orientation?
        BlurBackground(self)
    end

    local modelPanel = vgui.Create("DAdjustableModelPanel", parentPanel)
    modelPanel:SetSize(w, h)
    modelPanel:SetPos(x, y)
    modelPanel:SetModel(model) -- how do we add arccw attachment support?
    modelPanel:SetAmbientLight(whitecolor) -- main light up top (typically slightly yellow), fill light below camera (very faint pale blue), rim light to the left (urban color), rimlight to the right (white)
    modelPanel:SetDirectionalLight(BOX_TOP, slightyellowcolor)
    modelPanel:SetDirectionalLight(BOX_FRONT, slightbluecolor)
    modelPanel:SetDirectionalLight(BOX_LEFT, lightcolor)
    -- modelPanel:SetDirectionalLight(BOX_LEFT, whitecolor)

    function modelPanel:LayoutEntity(Entity) return end -- how do we make cam movement smoothened?

    return modelPanel
end

local function ExpandedItemPanel(itemname)
    if isempty(itemname) then itemname = "Item Info" end

    local ply = LocalPlayer()
    if IsValid(OpenMotherFrame) then OpenMotherFrame:Close() return end
    if !IsValid(ply) then return end
    if !enabled:GetBool() then return end

    local closebool = net.ReadBool()

    if closebool == false then return end

    local screenwidth = ScrW()
    local screenheight = ScrH()
    local frameW, frameH = screenwidth / 1.6, screenheight / 1.6
    local itemFrame = vgui.Create("DFrame")
    itemFrame:SetSize(screenwidth / 2, screenheight / 1.6) -- 960, 675
    itemFrame:SetVisible(true)
    itemFrame:SetDraggable(true)
    itemFrame:ShowCloseButton(true)
    itemFrame:SetTitle(itemname)
    itemFrame:ParentToHUD() -- needed?
    HideHUD = true

    chicagoRP.PanelFadeIn(itemFrame, 0.15)

    itemFrame:MakePopup()
    itemFrame:Center()

    function itemFrame:OnClose()
        if IsValid(self) then
            chicagoRP.PanelFadeOut(itemFrame, 0.15)
        end

        HideHUD = false
    end

    function itemFrame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE or key == KEY_Q then
            surface.PlaySound("chicagoRP_settings/back.wav")
            timer.Simple(0.15, function()
                if IsValid(self) then
                    self:Close()
                end
            end)
        end
    end

    function itemFrame:Paint(w, h)
        BlurBackground(self)
    end

    local modelPanel = FancyModelPanel(itemFrame, model, 50, 0, frameW, 300, purplecolor)
    local textPanel = ScrollingTextPanel(itemFrame, 350, 0, 100, 100)
    local cartButton = AddCartButton(itemFrame, 500, 860, 100, 30)
    local quanitySel = QuanitySelector(itemFrame, 500, 820, 40, 20)

    function quanitySel:OnValueChanged(val)
        print("Quanity: " .. val)
        cartButton.value = val
    end

    function cartButton:DoClick()
        local quanity = self.value -- how do we do if quanity > server_quanity then func return end?
        local finaltable = {itemname, quanity}

        for _, v in ipairs(carttable) do
            if v.itemname == itemname then
                v.quanity = v.quanity + quanity
            else
                table.insert(carttable, finaltable)
            end
        end
    end

    OpenItemFrame = itemFrame

    return itemFrame
end

local function CartItemPanel(parent, itemname, quanity, x, y, w, h)
    if itemname == nil or parent == nil then return end

    local cartItem = parent:Add("DPanel")
    cartItem:Dock(TOP)
    cartItem:DockMargin(0, 0, 0, 10)

    function cartItem:Paint(w, h)
        draw.DrawText(itemname, "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)
        -- surface.SetMaterial(nil) -- how do we get spawnicon?
        surface.DrawTexturedRectRotated(0, 0, w, h, 0)

        return nil
    end

    return cartItem
end

local function UpdateQuanityButton(parent, x, y, w, h)
    local updQuanityButton = vgui.Create("DButton", parent)
    updQuanityButton:SetSize(w, h)
    updQuanityButton:SetPos(x, y)
    updQuanityButton:SetText("Update")

    function updQuanityButton:Paint(w, h)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 0, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    return updQuanityButton
end

local function priceCalculationPanel(parent, quanity, x, y, w, h) -- how do we fetch item prices?
    if parent == nil then return end

    local priceCalcPanel = vgui.Create("DPanel", parent)
    priceCalcPanel:SetSize(w, h)
    priceCalcPanel:SetPos(x, y)

    local total = nil
    local discount = nil -- how do we fetch the discounts all items in the cart?
    local subtotal = nil

    function priceCalcPanel:Paint(w, h)
        draw.DrawText("Total: $" .. total, "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT) -- original total
        draw.DrawText("Discount (-" .. discountpercent .. "%): -$" .. discount, "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT) -- discounts
        draw.DrawText("Subtotal: " .. subtotal, "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT) -- final total

        return nil
    end

    return priceCalcPanel
end

local function PurchaseButton(parent, x, y, w, h)
    local purButton = vgui.Create("DButton", parent)
    purButton:SetSize(w, h)
    purButton:SetPos(x, y)
    purButton:SetText("PURCHASE")

    function purButton:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 210, 220))
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 0, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    function purButton:DoClick()
        if table.IsEmpty(carttable) then return end

        local JSONTable = util.TableToJSON(carttable)
        local compTable = util.Compress(JSONTable)
        local bytecount = #compTable

        net.Start("chicagoRP_NPCShop_sendcart")
        net.WriteUInt(bytecount, 16)
        net.WriteData(compTable, bytecount)
        net.SendToServer()

        carttable = {} -- or table.Empty(carttable)
    end

    return purButton
end

local function CartViewPanel(parent, x, y, w, h)
    local cartScrollPanel = vgui.Create("DScrollPanel", parent)
    cartScrollPanel:SetPos(x, y)
    cartScrollPanel:SetSize(w, h)

    function cartScrollPanel:Paint(w, h)
        return nil
    end

    local cartScrollBar = cartScrollPanel:GetVBar()
    function cartScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function cartScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    SmoothScrollBar(cartScrollBar)

    return cartScrollPanel
end

local function GetDiscountTable()
    net.Start("chicagoRP_NPCShop_senddiscount")
    net.SendToServer()
end

net.Receive("chicagoRP_NPCShop_getdiscount", function()
    local bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
    local compTable = net.ReadData(bytecount) -- Gets back our compressed message
    local decompTable = util.Decompress(compTable)
    local finalTable = util.JSONToTable(decompTable)

    if istable(finalTable) then 
        discounttable = finalTable
    end
end)

net.Receive("chicagoRP_NPCShop_GUI", function()
    local ply = LocalPlayer()
    if IsValid(OpenMotherFrame) then OpenMotherFrame:Close() return end
    if !IsValid(ply) or !ply:Alive() or !ply:OnGround() or ply:InVehicle() then return end
    if !enabled:GetBool() then return end

    -- local viewtrace = ply:GetEyeTraceNoCursor()
    -- local entname = viewtrace.Entity:GetName()

    -- if string.Left(entname, 15) != "chicagoRP_shop_" or !viewtrace.Entity:IsNPC() then return end -- more protection because god knows we'll need it

    local closebool = net.ReadBool()

    if closebool == false then return end

    local screenwidth = ScrW()
    local screenheight = ScrH()
    local motherFrame = vgui.Create("DFrame")
    motherFrame:SetSize(screenwidth / 1.2, screenheight / 1.2) -- 1600/900
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(true)
    motherFrame:ShowCloseButton(true)
    motherFrame:SetTitle("Shop")
    motherFrame:ParentToHUD()
    HideHUD = true

    carttable = {} -- or table.Empty(carttable)

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
        -- BlurBackground(self)
    end

    local catScrollPanel = CategoryPanel(motherFrame, 0, 0, 100, screenheight / 1.2)
    local cartScrollPanel = CartViewPanel(motherFrame, 700, 0, 200, screenheight / 1.2)
    local searcherPanel = SearchBox(motherFrame, 225, 45, 350, 20)
    local filterPanel = FilterBox(motherFrame, 575, 45, 50, 50)

    local browsingPanels = {searcherPanel, filterPanel}

    for k, v in ipairs(chicagoRP_NPCShop.categories) do
        local catButton = CategoryButton(catScrollPanel, k, w, h)

        local shopScrollPanel = ItemScrollPanel(motherFrame, 100, 200, 700, 500)
        shopScrollPanel:Hide()

        function catButton:DoClick()
            shopScrollPanel:Show()

            for _, v2 in ipairs(chicagoRP_NPCShop[v.name]) do
                local itemPanel = CreateItemPanel(shopScrollPanel, v2.ent, w, h)
            end
        end
    end

    OpenMotherFrame = motherFrame
end)

print("chicagoRP NPC Shop GUI loaded!")

-- todo:
-- add toggle options to dcombobox (idk how)
-- item scroll panel create/perform layout code
-- filter table calc code + filter create/perform layout code
-- cart panel performlayout code
-- create serverside discount table calculation code
-- GetItemCategory function or send item category with net message
-- uodate clientside quanity text when serverside quanity table is updated (table callback?)
-- how to (securely) send NPC table to GUI?
-- add homepage (just restocked, most popular, discounts)
-- add mLogs and Billy's Logs support









