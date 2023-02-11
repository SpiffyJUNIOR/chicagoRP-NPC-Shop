local HideHUD = false
local OpenMotherFrame = nil
local OpenShopPanel = nil
local OpenCartPanel = nil
local OpenItemFrame = nil

local carttable = {}
local filtertable = {}
local discounttimers = nil
local restocktimers = nil

local servertable = nil
local discounttable = nil
local quanitytable = nil
local OOStable = nil
local Dynamic = 0

local whitecolor = Color(255, 255, 255, 255)
local blackcolor = Color(0, 0, 0, 255)
local graycolor = Color(20, 20, 20, 200)
local slightyellowcolor = Color(253, 255, 180, 255)
local slightbluecolor = Color(225, 255, 250, 255)
local purplecolor = Color(200, 200, 30, 255) -- probably not purple
local reddebug = Color(200, 10, 10, 150)

local enabled = GetConVar("cl_chicagoRP_NPCShop_enable")
local truenames_enabled = GetConVar("arccw_truenames")
local blurMat = Material("pp/blurscreen")
local meta = FindMetaTable("Panel")
local L = {}

L["stat.Damage"] = "Close Range Damage"
L["stat.DamageMin"] = "Long Range Damage"
L["stat.Range"] = "Range"
L["stat.RangeMin"] = "Minimum Range"
L["stat.Delay"] = "Firerate"
L["stat.Primary.ClipSize"] = "Mag Size"
L["stat.Precision"] = "Accuracy"
L["stat.HipDispersion"] = "Hipfire Spread"
L["stat.MoveDispersion"] = "Moving Accuracy"
L["stat.JumpDispersion"] = "Jump Accuracy"
L["stat.MuzzleVelocity"] = "Muzzle Velocity"
L["stat.Recoil"] = "Recoil"
L["stat.RecoilSide"] = "Horizontal Recoil"
L["stat.SightTime"] = "Handling"
L["stat.SpeedMult"] = "Move Speed"
L["stat.SightedSpeedMult"] = "Sighted Speed"
L["stat.ShootVol"] = "Volume"
L["stat.BarrelLength"] = "Weapon Length"
L["stat.Penetration"] = "Penetration"

hook.Add("HUDShouldDraw", "chicagoRP_NPCShop_HideHUD", function()
    if HideHUD == true then
        return false
    end
end)

local function RemoveTimers(tbl)
    if !istable(tbl) or table.IsEmpty(tbl) then return end

    for item, _ in pairs(tbl) do
        if timer.Exists("chicagoRP_NPCShop_discount_" .. item) then
            timer.Remove("chicagoRP_NPCShop_discount_" .. item)
        elseif timer.Exists("chicagoRP_NPCShop_OOS_" .. item)
            timer.Remove("chicagoRP_NPCShop_OOS_" .. item)
        else
            continue
        end
    end
end

local function SpawnIcon(parent, model, x, y, w, h)
    local SpawnIc = vgui.Create("SpawnIcon", parent)
    SpawnIc:SetPos(x, y)
    SpawnIc:SetSize(w, h)
    SpawnIc:SetModel(model) -- Model we want for this spawn icon

    return SpawnIc
end

local function OptimizedSpawnIcon(parent, model, x, y, w, h)
    local SpawnIc = vgui.Create("ModelImage", parent) -- or DPanel
    SpawnIc:SetPos(x, y)
    SpawnIc:SetSize(w, h)
    SpawnIc:SetModel(model) -- Model we want for this spawn icon

    -- local iconmat = 

    -- function SpawnIc:Paint(w, h)
    --     surface.SetMaterial(IMaterial material)
    --     surface.DrawTexturedRectRotated(0, 0, w, h, 0)

    --     return nil
    -- end

    return SpawnIc
end

local function CategoryButton(parent, index, w, h)
    local catButton = parent:Add("DButton")
    catButton:Dock(TOP)
    catButton:DockMargin(0, 0, 10, 0)
    catButton:SetSize(w, h)

    local cattable = chicagoRP_NPCShop.categories[index]
    local printname = string.gsub(cattable.name, "^%l", string.upper) -- how do we do this for first letter of every word?

    catButton:SetText(printname)

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

    chicagoRP_NPCShop.SmoothScrollBar(categoryScrollBar)

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

    -- function cartButton:Paint(w, h)
    --     draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 210, 220))

    --     return true
    -- end

    return cartButton
end

local function InfoTextPanel(parent, text, color, w, h)
    local textScrPanel = vgui.Create("DPanel", parent)
    itemScrPanel:SetSize(w, h)
    itemScrPanel:Dock(TOP)
    itemScrPanel:DockMargin(0, 0, 5, 5)

    local colortrue = IsColor(color)

    if colortrue then color.a = 50 end

    function itemScrPanel:Paint(w, h)
        draw.DrawText(text, "chicagoRP_NPCShop", 0, 0, whitecolor, TEXT_ALIGN_LEFT)

        if colortrue then
            surface.SetDrawColor(color)
            surface.DrawRect(0, 0, w, h)

            return true
        else
            return nil
        end
    end

    return itemScrPanel
end

local function InfoParentPanel(parent, itemtbl, x, y, w, h)
    local parentScrPanel = vgui.Create("DScrollPanel", parent)
    parentScrPanel:SetPos(x, y)
    parentScrPanel:SetSize(w, h)

    function parentScrPanel:Paint(w, h)
        return nil
    end

    local parentScrollBar = parentScrPanel:GetVBar()
    parentScrollBar:SetHideButtons(true)
    function parentScrollBar:Paint(w, h)
        if parentScrollBar.btnGrip:IsHovered() then
            draw.RoundedBox(2, 0, 0, w, h, Color(42, 40, 35, 66))
        end
    end
    function parentScrollBar.btnGrip:Paint(w, h)
        if self:IsHovered() then
            draw.RoundedBox(8, 0, 0, w, h, Color(76, 76, 74, 100))
        end
    end

    chicagoRP_NPCShop.SmoothScrollBar(parentScrollBar)

    return parentScrPanel
end

local function CreateItemPanel(parent, itemtbl, w, h)
    if !IsValid(parent) or itemtbl == nil or table.IsEmpty(itemtbl) then return end

    -- local itemButton = vgui.Create("DButton", parent)
    local itemButton = parent:Add("DButton")
    -- itemButton:Dock(TOP)
    -- itemButton:DockMargin(0, 10, 30, 30)
    itemButton:SetSize(w, h)
    -- itemButton:SetPos(x, y)

    local printname = chicagoRP_NPCShop.EntityPrintName(itemtbl)

    local maxquanity = self.quanity or v.quanity

    local discounttimer = nil
    local restocktimer = nil

    if itemButton.discounttime == true and isnumber(itemButton.discounttime) then
        discounttimer = timer.Create("chicagoRP_NPCShop_discount_" .. itemtbl.ent, itemButton.discounttime, 1)

        table.insert(discounttimers, itemtbl.ent)
    end

    if itemButton.outofstock == true and isnumber(itemButton.restocktime) then
        restocktimer = timer.Create("chicagoRP_NPCShop_OOS_" .. itemtbl.ent, itemButton.restocktime, 1)

        table.insert(restocktimers, itemtbl.ent)
    end

    function itemButton:Paint(w, h)
        draw.DrawText(printname, "chicagoRP_NPCShop", (w / 2) - 10, 10, whitecolor, TEXT_ALIGN_LEFT)
        draw.RoundedBox(4, 0, 0, w, h, graycolor)
        -- surface.DrawTexturedRectRotated(20, y, w, 64, 0)

        if self.discounted == true and isnumber(self.discountseed) then
            draw.DrawText("HOLY SHIT CRACKER THESE SOME GOOD DISCOUNTS!!!", "chicagoRP_NPCShop", 40, 40, purplecolor, TEXT_ALIGN_CENTER)
            draw.DrawText(self.discountseed, "chicagoRP_NPCShop", 20, 20, purplecolor, TEXT_ALIGN_CENTER)
        end

        if IsValid(discounttimer) and timer.TimeLeft(discounttimer) > 0 then
            draw.DrawText(timer.TimeLeft(discounttimer), "chicagoRP_NPCShop", 10, 10, reddebug, TEXT_ALIGN_CENTER)
        elseif IsValid(restocktimer) and timer.TimeLeft(restocktimer) > 0 then
            draw.DrawText(timer.TimeLeft(restocktimer), "chicagoRP_NPCShop", 10, 10, reddebug, TEXT_ALIGN_CENTER)
        end

        draw.DrawText(maxquanity, "chicagoRP_NPCShop", 40, 30, purplecolor, TEXT_ALIGN_CENTER)

        return true
    end

    function itemButton:DoClick()
        local expandedPanel = ExpandedItemPanel(itemtbl)
    end

    local spawnicon = OptimizedSpawnIcon(itemButton, chicagoRP_NPCShop.EntityModel(itemtbl), 100, 50, 64, 64)

    spawnicon.Think = nil

    local cartButton = AddCartButton(parent, x, y, w, h)
    local quanitySel = QuanitySelector(parent, 200, 0, 40, 20)
    local statPanel = InfoParentPanel(parent, itemtbl, 2, 100, w - 4, 100)

    local stattbl = chicagoRP_NPCShop.GetStats(itemtbl)
    local wpnbase = chicagoRP_NPCShop.GetWeaponBase(itemtbl.ent)

    if wpnbase == "arccw" then
        stattbl = table.Add(itemtbl, chicagoRP_NPCShop.GetArcCWStats(itemtbl, true))
    elseif wpnbase == "arc9" then
        stattbl = table.Add(itemtbl, chicagoRP_NPCShop.GetARC9Stats(itemtbl, true))
    elseif wpnbase == "m9k" then
        stattbl = table.Add(itemtbl, chicagoRP_NPCShop.GetM9KStats(itemtbl, true))
    end

    if istable(stattbl) and !table.IsEmpty(stattbl) then
        for _, v in ipairs(stattbl) do
            if chicagoRP_NPCShop.isempty(v) then continue end

            InfoTextPanel(parent, v, whitecolor, (w / 2) - 4, 25)
        end
    elseif (!istable(stattbl) and !table.IsEmpty(stattbl)) or stattbl == nil then
        local pros, cons, infos = chicagoRP_NPCShop.GetAttStats(itemtbl)

        if istable(pros) and !table.IsEmpty(pros) then
            for _, v2 in ipairs(pros) do
                if chicagoRP_NPCShop.isempty(v2) then continue end

                InfoTextPanel(parent, v2, whitecolor, (w / 2) - 4, 25)
            end
        end

        if istable(cons) and !table.IsEmpty(cons) then
            for _, v2 in ipairs(cons) do
                if chicagoRP_NPCShop.isempty(v2) then continue end

                InfoTextPanel(parent, v2, whitecolor, (w / 2) - 4, 25)
            end
        end

        if istable(infos) and !table.IsEmpty(infos) then
            for _, v2 in ipairs(infos) do
                if chicagoRP_NPCShop.isempty(v2) then continue end

                InfoTextPanel(parent, v2, whitecolor, (w / 2) - 4, 25)
            end
        end
    end

    quanitySel:SetMax(maxquanity)
    quanitySel:SetMin(1)

    function quanitySel:OnValueChanged(val)
        print("Quanity: " .. val)
        cartButton.value = val
    end

    function cartButton:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 210, 220))

        if self.outofstock == true then
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 20, 20, 220))
            draw.DrawText("OUT OF STOCK", "chicagoRP_NPCShop", 0, 0, whitecolor, TEXT_ALIGN_LEFT)
        end

        return true
    end

    function cartButton:DoClick()
        local quanity = self.quanity or v.quanity -- how do we do if quanity > server_quanity then func return end?
        local finaltable = {ent = itemtbl.ent, quanity = quanity}

        if self.outofstock == true then
            print("This item is out of stock!")
            return
        end

        for _, v in ipairs(carttable) do
            if v.ent == itemtbl then
                v.quanity = v.quanity + quanity
            else
                table.insert(carttable, finaltable)
            end
        end

        if IsValid(OpenCartPanel) then
            OpenCartPanel:InvalidateLayout()
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

    chicagoRP_NPCShop.SmoothScrollBar(itemScrollBar)

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

    local oOnValueChange = textEntry.OnValueChange

    function textEntry:OnValueChange(value)
        oOnValueChange(value)
        local newtext = self:GetText()

        if IsValid(OpenShopPanel) then
            OpenShopPanel:InvalidateLayout()
        end

        print(newtext)
        print(value)
    end

    return textEntry
end

local function FilterMinMaxSort(parent, text, w, h)
    local sortPanel = vgui.Create("DPanel", parent)
    sortPanel:SetSize(w, h)
    -- sortPanel:SetPos(x, y)
    sortPanel:Dock(TOP)

    function sortPanel:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)

        return nil
    end

    local typeLabel = vgui.Create("DLabel", sortPanel)
    typeLabel:SetPos(0, 0)
    typeLabel:SetSize(10, 10)
    typeLabel:SetFont("chicagoRP_NPCShop")
    typeLabel:SetText(text)
    typeLabel:SetTextColor(whitecolor)

    typeLabel.Think = nil

    function typeLabel:Paint(w, h)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    local minTextEntry = vgui.Create("DNumberWang", sortPanel)
    minTextEntry:SetSize(30, 15)
    minTextEntry:SetPos(0, 0)
    minTextEntry:SetText("...")

    function minTextEntry:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    -- local oOnValueChange = minTextEntry.OnValueChange

    -- function minTextEntry:OnValueChange(val)
    --     oOnValueChange(val)
    --     local newtext = self:GetValue()

    --     if IsValid(OpenShopPanel) then
    --         OpenShopPanel:InvalidateLayout()
    --     end

    --     print(newtext)
    --     print(value)
    -- end

    local hyphenLabel = vgui.Create("DLabel", sortPanel)
    hyphenLabel:SetPos(45, 0)
    hyphenLabel:SetSize(10, 10)
    hyphenLabel:SetFont("chicagoRP_NPCShop")
    hyphenLabel:SetText("-")
    hyphenLabel:SetTextColor(whitecolor)

    hyphenLabel.Think = nil

    function hyphenLabel:Paint(w, h)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    local maxTextEntry = vgui.Create("DNumberWang", sortPanel)
    maxTextEntry:SetSize(30, 15)
    maxTextEntry:SetPos(60, 0)
    maxTextEntry:SetText("...")

    function maxTextEntry:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    -- local nOnValueChange = maxTextEntry.OnValueChange

    -- function maxTextEntry:OnValueChange(val)
    --     nOnValueChange(val)
    --     local newtext = self:GetValue()

    --     if IsValid(OpenShopPanel) then
    --         OpenShopPanel:InvalidateLayout()
    --     end

    --     print(newtext)
    --     print(value)
    -- end

    return sortPanel, minTextEntry, maxTextEntry
end

local function FilterCheckBox(parent, text, w, h) -- how do we do togglable options?
    local checkBox = vgui.Create("DCheckBoxLabel", parent)
    checkBox:SetSize(w, h)
    -- checkBox:SetPos(x, y)
    checkBox:Dock(TOP)
    checkBox:SetText(text)
    checkBox:SetValue(false)
    checkBox:SetTextInset(32, 0)

    function checkBox:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText("Armor Levels", "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    -- function checkBox:OnChange(bVal)
    --     if IsValid(OpenShopPanel) then
    --         OpenShopPanel:InvalidateLayout()
    --     end
    -- end

    return checkBox
end

local function FilterComboBox(parent, x, y, w, h)
    local dropDownPanel = vgui.Create("DComboBox", parent)
    dropDownPanel:SetSize(w, h)
    dropDownPanel:SetPos(x, y)

    function dropDownPanel:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, graycolor)
        draw.DrawText("Armor Levels", "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end

    function dropDownPanel:OnMenuOpened())
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

    function dropDownPanel:OnSelect(index, value, data)
        if IsValid(OpenShopPanel) then
            OpenShopPanel:InvalidateLayout()
        end
    end

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
    if chicagoRP_NPCShop.isempty(text) then text = "Text is empty!" end

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

    chicagoRP_NPCShop.SmoothScrollBar(textScrollBar)

    -- how do we do textwrap and line breaks?

    return ScrollingTextPanel
end

local function InfoText(text, parent)
    local labelText = parent:Add("DLabel")
    labelText:SetSize(100, 200)
    labelText:Dock(TOP)
    labelText:SetFont("chicagoRP_NPCShop")
    labelText:SetWrap(true)
    labelText:SetText(text)
    labelText:SetTextColor(whitecolor)

    wikiTxtPanel:SetAutoStretchVertical(true)

    labelText.Think = nil

    function labelText:Paint(w, h)
        draw.DrawText(self:GetText(), "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)

        return nil
    end
end

local function FancyModelPanel(parent, model, x, y, w, h, lightcolor)
    if lightcolor == nil then lightcolor = whitecolor end
    if model == nil or parent == nil then return end

    local parentPanel = vgui.Create("DPanel", parent)
    parentPanel:SetSize(w, h)
    parentPanel:SetPos(x, y)

    function parentPanel:Paint(w, h)
        -- surface.SetMaterial(nil) -- how do we get cubemap from map?
        -- surface.DrawTexturedRectUV(x, y, w, h, 0, 0, 1, 1)
        surface.DrawTexturedRectRotated(x, y, w, h, 0) -- how do we make the cubemap rotate with model orientation?
        chicagoRP.BlurBackground(self)
    end

    local modelPanel = vgui.Create("DAdjustableModelPanel", parentPanel)
    modelPanel:SetSize(w, h)
    modelPanel:SetPos(x, y)
    modelPanel:SetModel(model)
    modelPanel:SetAmbientLight(whitecolor) -- main light up top (typically slightly yellow), fill light below camera (very faint pale blue), rim light to the left (urban color), rimlight to the right (white)
    modelPanel:SetDirectionalLight(BOX_TOP, slightyellowcolor)
    modelPanel:SetDirectionalLight(BOX_FRONT, slightbluecolor)
    modelPanel:SetDirectionalLight(BOX_LEFT, lightcolor)
    -- modelPanel:SetDirectionalLight(BOX_LEFT, whitecolor)

    function modelPanel:LayoutEntity(Entity) return end -- how do we make cam movement smoothened?

    return modelPanel
end

local function ExpandedItemPanel(itemtbl)
    local ply = LocalPlayer()
    if IsValid(OpenMotherFrame) then OpenMotherFrame:Close() return end
    if !IsValid(ply) then return end
    if !enabled:GetBool() then return end

    local closebool = net.ReadBool()

    if closebool == false then return end

    local entname = itemtbl.ent

    local screenwidth = ScrW()
    local screenheight = ScrH()
    local frameW, frameH = screenwidth / 1.6, screenheight / 1.6
    local itemFrame = vgui.Create("DFrame")
    itemFrame:SetSize(screenwidth / 2, screenheight / 1.6) -- 960, 675
    itemFrame:SetVisible(true)
    itemFrame:SetDraggable(true)
    itemFrame:ShowCloseButton(true)
    itemFrame:SetTitle(chicagoRP_NPCShop.EntityPrintName(entname))
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
        chicagoRP.BlurBackground(self)
    end

    local model = chicagoRP_NPCShop.EntityModel(entname)
    local wpnbase = chicagoRP_NPCShop.GetWeaponBase(itemtbl.ent)
    local isAtt = chicagoRP_NPCShop.IsArcCWAtt(itemtbl.ent) or chicagoRP_NPCShop.IsARC9Att(itemtbl.ent)
    local enttbl = scripted_ents.GetStored(entname)

    local modelPanel = FancyModelPanel(itemFrame, model, 50, 0, frameW, 300, purplecolor)
    local textPanel = ScrollingTextPanel(itemFrame, 350, 0, 100, 100)
    local cartButton = AddCartButton(itemFrame, 500, 860, 100, 30)
    local quanitySel = QuanitySelector(itemFrame, 500, 820, 40, 20)
    local infoText = InfoText(itemtbl.infotext, textPanel)

    if wpnbase == "arc9" then
        modelPanel.Entity:SetBodyGroups(chicagoRP_NPCShop.ARC9WeaponBodygroups(itemtbl.ent))
    end

    if isAtt and istable(enttbl) and !table.IsEmpty(enttbl) and !table.IsEmpty(enttbl.ActivateElements) then
        local weapon = itemtbl.wpn
        local parenttbl = weapons.GetStored(weapon)
        local bodygroups = chicagoRP_NPCShop.FetchBodygroups(itemtbl)

        modelPanel:SetModel(parenttbl.Model)

        for _, v in ipairs(bodygroups) do
            modelPanel.Entity:SetBodygroup(v[1], v[2])
        end
    end

    function quanitySel:OnValueChanged(val)
        print("Quanity: " .. val)
        cartButton.value = val
    end

    function cartButton:DoClick()
        local quanity = self.value
        local finaltable = {ent, quanity}

        for _, v in ipairs(carttable) do
            if v.ent == ent then
                v.quanity = v.quanity + quanity
            else
                table.insert(carttable, finaltable)
            end
        end

        if IsValid(OpenCartPanel) then
            OpenCartPanel:InvalidateLayout()
        end
    end

    OpenItemFrame = itemFrame

    return itemFrame
end

local function CartItemPanel(parent, itemtbl, w, h)
    if itemname == nil or parent == nil then return end

    local cartItem = parent:Add("DPanel")
    cartItem:SetSize(w, h)
    cartItem:Dock(TOP)
    cartItem:DockMargin(0, 0, 0, 10)

    local printname = chicagoRP_NPCShop.EntityPrintName(itemtbl)

    function cartItem:Paint(w, h)
        draw.DrawText(printname, "chicagoRP_NPCShop", 0, 4, whitecolor, TEXT_ALIGN_LEFT)
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

        carttable = {}
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

    chicagoRP_NPCShop.SmoothScrollBar(cartScrollBar)

    return cartScrollPanel
end

net.Receive("chicagoRP_NPCShop_invalidatelclient", function()
    local ply = LocalPlayer()
    if !IsValid(ply) or !ply:Alive() or !IsValid(OpenMotherFrame) or !IsValid(OpenShopPanel) then return end

    local inv_bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
    local inv_compTable = net.ReadData(bytecount) -- Gets back our compressed message
    local inv_decompTable = util.Decompress(compTable)
    local inv_finaltable = util.JSONToTable(decompTable)
    local quanitybool = net.ReadBool()

    if !istable(inv_finaltable) or table.IsEmpty(inv_finaltable) then return end

    servertable = inv_finaltable
    discounttable = inv_finaltable.discounttable
    quanitytable = inv_finaltable.quanitytable
    OOStable = inv_finaltable.OOStable
    discounttimers = inv_finaltable.discounttimers
    restocktimers = inv_finaltable.restocktimers

    if IsValid(OpenShopPanel) then
        OpenShopPanel:InvalidateLayout()
    end

    if IsValid(OpenCartPanel) then
        OpenCartPanel:InvalidateLayout()
    end

    if !quanitybool then return end

    local OOS_bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
    local OOS_compTable = net.ReadData(bytecount) -- Gets back our compressed message
    local OOS_decompTable = util.Decompress(compTable)
    local OOS_finaltable = util.JSONToTable(decompTable)

    if !istable(OOS_finaltable) or table.IsEmpty(OOS_finaltable) then return end

    for _, v in ipairs(OOS_finaltable) do
        if v.insufficient == true then
            ply:ChatPrint("Not enough of Item: " .. v.ent .. ", only bought " .. v.quanitybought .. "x!")

            notification.AddLegacy("Insufficient stock of " .. v.ent .. ", only bought " .. v.quanitybought .. "x!", NOTIFY_UNDO, 5)
        else
            ply:ChatPrint("Item " .. v.ent .. " was out of stock!")

            notification.AddLegacy("Item " .. v.ent .. " was out of stock!", NOTIFY_UNDO, 5)
        end
    end

    surface.PlaySound("buttons/button15.wav")
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

    local bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
    local compTable = net.ReadData(bytecount) -- Gets back our compressed message
    local decompTable = util.Decompress(compTable)
    local finaltable = util.JSONToTable(decompTable)

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

    motherFrame.lblTitle.Think = nil

    carttable = {}

    servertable = finaltable
    discounttable = finaltable.discounttable
    quanitytable = finaltable.quanitytable
    OOStable = finaltable.OOStable
    discounttimers = finaltable.discounttimers
    restocktimers = finaltable.restocktimers

    chicagoRP.PanelFadeIn(motherFrame, 0.15)

    motherFrame:MakePopup()
    motherFrame:Center()

    function motherFrame:OnClose()
        if IsValid(self) then
            chicagoRP.PanelFadeOut(motherFrame, 0.15)
        end

        RemoveTimers(discounttimers)
        RemoveTimers(restocktimers)

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
        -- chicagoRP.BlurBackground(self)
    end

    local catScrollPanel = CategoryPanel(motherFrame, 0, 0, 100, screenheight / 1.2)
    local cartScrollPanel = CartViewPanel(motherFrame, 700, 0, 200, screenheight / 1.2)
    local searcherPanel = SearchBox(motherFrame, 225, 45, 350, 20)
    local filterPanel = FilterBox(motherFrame, 575, 45, 50, 50)

    local browsingPanels = {searcherPanel, filterPanel}

    local searchstring = nil

    for _, v in ipairs(chicagoRP_NPCShop.categories) do
        local catButton = CategoryButton(catScrollPanel, k, w, h)

        local shopScrollPanel = ItemScrollPanel(motherFrame, 100, 200, 700, 500)
        shopScrollPanel:Hide()

        local shopPanelLayout = vgui.Create("DIconLayout", shopScrollPanel)
        shopPanelLayout:Dock(FILL)
        shopPanelLayout:SetSpaceY(5) -- Sets the space in between the panels on the Y Axis by 5
        shopPanelLayout:SetSpaceX(5) -- Sets the space in between the panels on the X Axis by 5
        shopPanelLayout:Hide()

        for _, v3 in ipairs(browsingPanels) do
            v3:Hide()
        end

        local oPerformLayout = shopPanelLayout.PerformLayout

        function shopPanelLayout:PerformLayout(w, h)
            oPerformLayout(w, h)

            for _, v4 in ipairs(self:GetChildren()) do
                v4:Remove()
            end

            RemoveTimers(discounttimers)
            RemoveTimers(restocktimers)

            for _, v2 in ipairs(chicagoRP_NPCShop[v.name]) do
                local itemPanel = nil

                if istable(filtertable) and !table.IsEmpty(filtertable) then
                    for _, v5 in ipairs(filtertable) do -- how do we get args and compare them?
                        if v5.typ != v.v5.typ and v5.inc != true then continue end -- for strings
                        if v5.parse != v.v5.typ then continue end -- for numbers
                        if v5.min < v.v5.parse then continue end -- for numbers
                        if v5.max > v.v5.parse then continue end -- for numbers
                        if isstring(searchstring) and IsValid(string.match(v.ent, searchstring)) then continue end

                        itemPanel = CreateItemPanel(shopPanelLayout, v2, w, h)
                    end
                else
                    itemPanel = CreateItemPanel(shopPanelLayout, v2, w, h)
                end

                if !table.IsEmpty(discounttable) and !table.IsEmpty(discounttable[v2.ent]) then
                    itemPanel.discounted = true
                    itemPanel.discount = discounttable[v2.ent].discount
                end

                if !table.IsEmpty(quanitytable) and !table.IsEmpty(quanitytable[v2.ent]) then
                    itemPanel.quanitydifferent = true
                    itemPanel.quanity = quanitytable[v2.ent].quanity
                end

                if !table.IsEmpty(OOStable) and !table.IsEmpty(OOStable[v2.ent]) then
                    itemPanel.outofstock = true
                end

                if !table.IsEmpty(discounttimers) and !table.IsEmpty(discounttimers[v2.ent]) then
                    itemPanel.discounted = true
                    itemPanel.discounttime = discounttimers[v2.ent].timeleft
                end

                if !table.IsEmpty(restocktimers) and !table.IsEmpty(restocktimers[v2.ent]) then
                    itemPanel.outofstock = true
                    itemPanel.restocktime = restocktimers[v2.ent].timeleft
                end

                local sanitizedtbl = chicagoRP_NPCShop.RemoveStrings(v2, false)
                local filterLayout = {}

                local wpnbase = chicagoRP_NPCShop.GetWeaponBase(v2.ent)

                if wpnbase == "arccw" or wpnbase == "arc9" then
                    local wpntable = table.Add(v2, chicagoRP_NPCShop.GetArcCWStats(v2))
                    local scrubbedtbl = chicagoRP_NPCShop.RemoveStrings(wpntable, false)

                    sanitizedtbl = scrubbedtbl
                elseif wpnbase == "arc9" then
                    local wpntable = table.Add(v2, chicagoRP_NPCShop.GetARC9Stats(v2))
                    local scrubbedtbl = chicagoRP_NPCShop.RemoveStrings(wpntable, false)

                    sanitizedtbl = scrubbedtbl
                elseif wpnbase == "m9k" then
                    local wpntable = table.Add(v2, chicagoRP_NPCShop.GetM9KStats(v2))
                    local scrubbedtbl = chicagoRP_NPCShop.RemoveStrings(wpntable, false)

                    sanitizedtbl = scrubbedtbl
                end

                for _, v3 in ipairs(sanitizedtbl) do
                    if isstring(v3) then
                        local checkBox = FilterCheckBox(filterPanel, chicagoRP_NPCShop.PrettifyString(v3), 40, 20)

                        function checkBox:OnChange(bVal)
                            filtertable[v3] = filtertable[v3] or {}

                            filtertable[v3].typ == v3
                            filtertable[v3].inc == bVal

                            if IsValid(OpenShopPanel) then
                                OpenShopPanel:InvalidateLayout()
                            end
                        end
                    elseif isnumber(v3) and filterLayout[v3] == (false or nil) then
                        local parentPanel, minSorter, maxSorter = FilterMinMaxSort(filterPanel, v3, w, h)
                        filterLayout[v3] = true

                        local minOnValueChange = minSorter.OnValueChange

                        function maxSorter:OnValueChange(val)
                            minOnValueChange(val)
                            local newtext = self:GetValue()

                            filtertable[v3] = filtertable[v3] or {}

                            filtertable[v3].parse == v3
                            filtertable[v3].min == val

                            if IsValid(OpenShopPanel) then
                                OpenShopPanel:InvalidateLayout()
                            end

                            print(newtext)
                            print(value)
                        end

                        local maxOnValueChange = maxTextEntry.OnValueChange

                        function maxSorter:OnValueChange(val)
                            maxOnValueChange(val)
                            local newtext = self:GetValue()

                            filtertable[v3] = filtertable[v3] or {}

                            filtertable[v3].parse == v3
                            filtertable[v3].min == val

                            if IsValid(OpenShopPanel) then
                                OpenShopPanel:InvalidateLayout()
                            end

                            print(newtext)
                            print(value)
                        end
                    end
                end
            end
        end

        function catButton:DoClick()
            filtertable = {}

            searchstring = nil

            shopScrollPanel:Show()
            shopPanelLayout:Show()

            OpenShopPanel = shopPanelLayout

            for _, v3 in ipairs(browsingPanels) do
                v3:Show()
            end

            shopPanelLayout:InvalidateLayout(true)
        end
    end

    function searcherPanel:OnValueChange(value)
        oOnValueChange(value)
        local newtext = self:GetText()

        if IsValid(OpenShopPanel) then
            OpenShopPanel:InvalidateLayout()
        end

        print(newtext)
        print(value)
    end

    local nPerformLayout = cartScrollPanel.PerformLayout

    function cartScrollPanel:PerformLayout(w, h)
        nPerformLayout(w, h)

        for _, v4 in ipairs(self:GetChildren()) do
            v4:Remove()
        end

        for _, v in ipairs(carttable)
            CartItemPanel(cartScrollPanel, v, 100, 200)
        end
    end

    cartScrollPanel:InvalidateLayout(true)

    OpenCartPanel = cartScrollPanel
    OpenMotherFrame = motherFrame
end)

print("chicagoRP NPC Shop GUI loaded!")

-- todo:
-- TFA weapon parsing
-- CW2 weapon parsing, bodygroups will have to be inputted manually :|
-- redo filter loop code
-- improve override handling
-- removing the weapon/att parse code and moving to strictly stats in tables?

-- later:
-- how to spawn npcs in an npc table and assign specific tables to them?
-- how to (securely) send NPC table to GUI?
-- add homepage (just restocked, most popular, discounts)
-- add mLogs and Billy's Logs support






