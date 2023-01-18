local HideHUD = false
local OpenMotherFrame = nil
local OpenShopPanel = nil
local OpenCartPanel = nil
local OpenItemFrame = nil
local carttable = {}
local filtertable = {}
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
L["stat.BarrelLength"] = "Length"
L["stat.Penetration"] = "Penetration"

local ArcCW_AutoStats = {
    -- Attachments
    ["MagExtender"]           = { "autostat.magextender", "override", false,       pr = 317 },
    ["MagReducer"]            = { "autostat.magreducer",  "override", true,        pr = 316 },
    ["Bipod"]                 = { "autostat.bipod",       false, false,            pr = 313 },
    ["ScopeGlint"]            = { "autostat.glint",       "override", true,        pr = 255 },
    ["Silencer"]              = { "autostat.silencer",    "override", false,       pr = 254 },
    ["Override_NoRandSpread"] = { "autostat.norandspr",   "override", false,       pr = 253 },
    ["Override_CanFireUnderwater"] = { "autostat.underwater",   "override", false, pr = 252 },
    ["Override_ShootWhileSprint"] = { "autostat.sprintshoot",   "override", false, pr = 251 },
    -- Multipliers
    ["Mult_BipodRecoil"]      = { "autostat.bipodrecoil", false, true,             pr = 312 },
    ["Mult_BipodDispersion"]  = { "autostat.bipoddisp",   false, true,             pr = 311 },
    ["Mult_Damage"]           = { "autostat.damage",      "mult", false,           pr = 215 },
    ["Mult_DamageMin"]        = { "autostat.damagemin",   "mult", false,           pr = 214 },
    ["Mult_Range"]            = { "autostat.range",       "mult", false,           pr = 185 },
    ["Mult_RangeMin"]         = { "autostat.rangemin",    "mult", false,           pr = 184 },
    ["Mult_Penetration"]      = { "autostat.penetration", "mult", false,           pr = 213 },
    ["Mult_MuzzleVelocity"]   = { "autostat.muzzlevel",   "mult", false,           pr = 212 },
    ["Mult_PhysBulletMuzzleVelocity"] = { "autostat.muzzlevel",   "mult", false,   pr = 211 },
    ["Mult_MeleeTime"]        = { "autostat.meleetime",   "mult", true,            pr = 145 },
    ["Mult_MeleeDamage"]      = { "autostat.meleedamage", "mult", false,           pr = 144 },
    ["Add_MeleeRange"]        = { "autostat.meleerange",  false,  false,           pr = 143 },
    ["Mult_Recoil"]           = { "autostat.recoil",      "mult", true,            pr = 195 },
    ["Mult_RecoilSide"]       = { "autostat.recoilside",  "mult", true,            pr = 194 },
    ["Mult_RPM"]              = { "autostat.firerate",    "mult", false,           pr = 216 },
    ["Mult_AccuracyMOA"]      = { "autostat.precision",   "mult", true,            pr = 186 },
    ["Mult_HipDispersion"]    = { "autostat.hipdisp",     "mult", true,            pr = 155 },
    ["Mult_SightsDispersion"] = { "autostat.sightdisp",   "mult", true,            pr = 154 },
    ["Mult_MoveDispersion"]   = { "autostat.movedisp",    "mult", true,            pr = 153 },
    ["Mult_JumpDispersion"]   = { "autostat.jumpdisp",    "mult", true,            pr = 152 },
    ["Mult_ShootVol"]         = { "autostat.shootvol",    "mult", true,            pr = 115 },
    ["Mult_SpeedMult"]        = { "autostat.speedmult",   "mult", false,           pr = 114 },
    ["Mult_MoveSpeed"]        = { "autostat.speedmult",   "mult", false,           pr = 105 },
    ["Mult_SightedSpeedMult"] = { "autostat.sightspeed",  "mult", false,           pr = 104 },
    ["Mult_SightedMoveSpeed"] = { "autostat.sightspeed",  "mult", false,           pr = 103 },
    ["Mult_ShootSpeedMult"]   = { "autostat.shootspeed",  "mult", false,           pr = 102 },
    ["Mult_ReloadTime"]       = { "autostat.reloadtime",  "mult", true,            pr = 125 },
    ["Add_BarrelLength"]      = { "autostat.barrellength","add",  true,            pr = 915 },
    ["Mult_DrawTime"]         = { "autostat.drawtime",    "mult", true,            pr = 14 },
    ["Mult_SightTime"]        = { "autostat.sighttime",   "mult", true,            pr = 335, flipsigns = true },
    ["Mult_CycleTime"]        = { "autostat.cycletime",   "mult", true,            pr = 334 },
    ["Mult_Sway"]             = { "autostat.sway",        "mult",  true,           pr = 353 },
    ["Mult_HeatCapacity"]     = { "autostat.heatcap",     "mult", false,           pr = 10 },
    ["Mult_HeatDissipation"]  = { "autostat.heatdrain",   "mult", false,           pr = 9 },
    ["Mult_FixTime"]          = { "autostat.heatfix",     "mult", true,            pr = 8 },
    ["Mult_HeatDelayTime"]    = { "autostat.heatdelay",   "mult", true,            pr = 7 },
    ["Mult_MalfunctionMean"]  = { "autostat.malfunctionmean", "mult", false,       pr = 6 },
    ["Add_ClipSize"]          = { "autostat.clipsize.mod",    "add", false,         pr = 315 },
    ["Mult_ClipSize"]         = { "autostat.clipsize.mod",    "mult", false,        pr = 314 },

    ["Override_Ammo"] = {"autostat.ammotype", "func", function(wep, val, att)
        -- have to use the weapons table here because Primary.Ammo *is* modified when attachments are used
        local weptbl = weapons.GetStored(wep)
        if !istable(weptbl) or weptbl.Primary.Ammo == val then return end
        return string.format(translate("autostat.ammotype"), string.lower(ArcCW.TranslateAmmo(val))), "infos"
    end, pr = 316},
    ["Override_ClipSize"] = {"autostat.clipsize", "func", function(wep, val, att)
        local weptbl = weapons.GetStored(wep)
        if !istable(weptbl) then return end
        local ogclip = weptbl.RegularClipSize or (weptbl.Primary and weptbl.Primary.ClipSize) or 0
        if ogclip < val then
            return string.format(translate("autostat.clipsize"), val), "pros"
        else
            return string.format(translate("autostat.clipsize"), val), "cons"
        end
    end, pr = 317},
    ["Bipod"] = {"autostat.bipod2", "func", function(wep, val, att)
        local weptbl = weapons.GetStored(wep)
        if val then
            local recoil = 100 - math.Round((att.Mult_BipodRecoil or (istable(weptbl) and weptbl.BipodRecoil) or 1) * 100)
            local disp = 100 - math.Round((att.Mult_BipodDispersion or (istable(weptbl) and weptbl.BipodDispersion) or 1) * 100)
            return string.format(translate("autostat.bipod2"), disp, recoil), "pros"
        else
            return translate("autostat.nobipod"), "cons"
        end
    end, pr = 314},
    ["UBGL"] = { "autostat.ubgl",  "override", false,        pr = 950 },
    ["UBGL_Ammo"] = {"autostat.ammotypeubgl", "func", function(wep, val, att)
        -- have to use the weapons table here because Primary.Ammo *is* modified when attachments are used
        local weptbl = weapons.GetStored(wep)
        if !istable(weptbl) then return end
        return string.format(translate("autostat.ammotypeubgl"), string.lower(ArcCW.TranslateAmmo(val))), "infos"
    end, pr = 949},
}

function meta:SizeToContentsY(addval) -- dlabel think resizing every frame so we make it only one time
    if self.m_bYSized then return end

    local w, h = self:GetContentSize()
    if (!w || !h) then return end

    self:SetTall(h + (addval or 0))

    self.m_bYSized = true
end

local function isempty(s)
    return s == nil or s == ""
end

local function ismaterial(mat)
    return type(mat) == nil or type(mat) == Material
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

local function GetWeaponBase(enttbl)
    local sweptbl = weapons.GetStored(enttbl.ent)
    local swepbase = sweptbl.Base

    if !istable(sweptbl) then return end

    if swepbase == ("arccw_base" or "weapon_base_kent") then
        return "arccw"
    elseif swepbase == ("arc9_go_base" or "arc9_base") then
        return "arc9"
    elseif swepbase == "cw_base" then
        return "cw2"
    elseif swepbase == "tfa_gun_base" then 
        return "tfa"
    else
        return "default"
    end
end

local function PrettifyString(str)
    local cachestr = str
    if string.StartWith(str, "%u") then return str end

    local upperstr = string.gsub(cachestr, "^%l", string.upper)

    return upperstr
end

local function PrettifyArcCWString(str)
    if isempty(str) then return nil end
    local indexedstr = L[str]

    if !isempty(indexedstr) then
        return indexedstr
    end

    return PrettifyString(str)
end

local function IsARC9Att(enttbl)
    return ARC9 and !isempty(string.find(enttbl.ent, "arc9_att_"))
end

local function IsArcCWAtt(enttbl)
    return ArcCW and !isempty(string.find(enttbl.ent, "acwatt_"))
end

local function IsCW2Att(enttbl) -- have to dl cw2 source
    -- local atttbl = scripted_ents.GetStored(enttbl.ent)

    -- if !istable(attbl) then return false end

    -- return TFA and istable(atttbl.WeaponTable)
end

local function IsTFAAtt(enttbl)
    local atttbl = scripted_ents.GetStored(enttbl.ent)

    if !istable(attbl) then return false end

    return TFA and istable(atttbl.WeaponTable) -- check scripted_ents.register att prefix
end

local function GetAttSlot(enttbl)
    if !IsArcCWAtt(enttbl) then return end
    local attbl = scripted_ents.GetStored(enttbl.ent)

    return attbl.Slot
end

local function RemoveStrings(source, pretty) -- i'm not doing a full fucking table loop (nvm maybe i will)
    if !istable(source) then return end

    source[ent] = nil
    source[infotext] = nil
    source[printname] = nil
    source[override] = nil
    source[discount] = nil
    source[discounttime] = nil
    source[restock] = nil

    if !pretty or pretty == nil then return source end

    source[price] = nil
    source[quanity] = nil
    -- source[restock] = nil

    return source
end

local function ArcCWBodygroup(swepclass, bglist)
    local bgtable = nil
    local sweptbl = weapons.GetStored(swepclass)

    if istable(bglist) then
        for _, v in ipairs(bglist) do
            table.insert(bgtable, sweptbl.AttachmentElements.v.VMBodygroups)
        end

        return bgtable
    else
        return bglist
    end
end

local function EntityPrintName(enttbl)
    local printname = nil
    local enttbl = scripted_ents.GetStored(itemtbl.ent)
    local sweptbl = weapons.GetStored(enttbl.ent)

    if istable(sweptbl) then
        printname = sweptbl.PrintName

        if ArcCW and truenames_enabled:GetBool() and sweptbl.Base == ("arccw_base" or "weapon_base_kent") then
            printname = sweptbl.TrueName
        end
    elseif istable(enttbl) then
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

    if istable(sweptbl) then
        model = sweptbl.ViewModel
    elseif istable(enttbl) then
        printname = enttbl.DroppedModel or enttbl.Mdl or enttbl.Model
        print(enttbl)
    else
        model = "models/props_borealis/bluebarrel001.mdl"
        print("Failed to parse entity model, check your shop table!")
    end

    return model
end

local function stattext(wep, att, i, k, dmgboth, flipsigns)
    if !ArcCW_AutoStats[i] then return end
    if i == "Mult_DamageMin" and dmgboth then return end

    local stat = ArcCW_AutoStats[i]

    local txt = ""
    local str, eval = ArcCW.GetTranslation(stat[1]) or stat[1], stat[3]

    if i == "Mult_Damage" and dmgboth then
        str = ArcCW.GetTranslation("autostat.damageboth") or stat[1]
    end

    local tcon, tpro = eval and "cons" or "pros", eval and "pros" or "cons"

    if stat[3] == "infos" then
        tcon = "infos"
    end

    if stat[2] == "mult" and k != 1 then
        local sign, percent = k > 1 and (flipsigns and "-" or "+") or (flipsigns and "+" or "-"), k > 1 and (k - 1) or (1 - k)
        txt = sign .. tostr(math.Round(percent * 100, 2)) .. "% "
        return txt .. str, k > 1 and tcon or tpro
    elseif stat[2] == "add" and k != 0 then
        local sign, state = k > 0 and (flipsigns and "-" or "+") or (flipsigns and "+" or "-"), k > 0 and k or -k
        txt = sign .. tostr(state) .. " "
        return txt .. str, k > 0 and tcon or tpro
    elseif stat[2] == "override" and k == true then
        return str, tcon
    elseif stat[2] == "func" then
        local a, b = stat[3](wep, k, att)
        if a and b then return a, b end
    end
end

local function GetAttStats(wep, enttable) -- check the table to make it filter compatible
    local pros = {}
    local cons = {}
    local infos = {}

    local atttable = scripted_ents.GetStored(enttable.ent) -- how do we get entity table

    if !IsArcCWAtt(atttable) then return end

    if enttable.override == true then
        local stattbl = RemoveStrings(enttable, true)

        return stattbl
    end

    table.Add(pros, atttable.Desc_Pros or {})
    table.Add(cons, atttable.Desc_Cons or {})
    table.Add(infos, atttable.Desc_Neutrals or {})

    -- local override = hook.Run("ArcCW_PreAutoStats", wep, att, pros, cons, infos, toggle)
    -- if override then return pros, cons, infos end

    -- Localize attachment-specific text
    local hasmaginfo = false
    for i, v in pairs(pros) do
        if v == "pro.magcap" then hasmaginfo = true end
        pros[i] = ArcCW.TryTranslation(v)
    end
    for i, v in pairs(cons) do
        if v == "con.magcap" then hasmaginfo = true end
        cons[i] = ArcCW.TryTranslation(v)
    end
    for i, v in pairs(infos) do infos[i] = ArcCW.TryTranslation(v) end

    if !atttable.AutoStats then return pros, cons, infos end

    -- Process togglable stats
    if atttable.ToggleStats then
        --local toggletbl = atttable.ToggleStats[toggle or 1]
        for ti, toggletbl in pairs(atttable.ToggleStats) do
            -- show the first stat block (unless NoAutoStats), and all blocks with AutoStats
            if toggletbl.AutoStats or (ti == (toggle or 1) and !toggletbl.NoAutoStats) then
                local dmgboth = toggletbl.Mult_DamageMin and toggletbl.Mult_Damage and toggletbl.Mult_DamageMin == toggletbl.Mult_Damage
                for i, stat in SortedPairsByMemberValue(ArcCW_AutoStats, "pr", true) do
                    if !toggletbl[i] or toggletbl[i .. "_SkipAS"] then continue end
                    local val = toggletbl[i]

                    local txt, typ = stattext(wep, toggletbl, i, val, dmgboth, ArcCW_AutoStats[i].flipsigns)
                    if !txt then continue end

                    local prefix = (stat[2] == "override" and k == true) and "" or ("[" .. (toggletbl.AutoStatName or toggletbl.PrintName or ti) .. "] ")

                    if typ == "pros" then
                        table.insert(pros, prefix .. txt)
                    elseif typ == "cons" then
                        table.insert(cons, prefix .. txt)
                    elseif typ == "infos" then
                        table.insert(infos, prefix .. txt)
                    end
                end
            end
        end
    end

    local dmgboth = atttable.Mult_DamageMin and atttable.Mult_Damage and atttable.Mult_DamageMin == atttable.Mult_Damage

    for i, _ in SortedPairsByMemberValue(ArcCW_AutoStats, "pr", true) do
        if !atttable[i] or atttable[i .. "_SkipAS"] then continue end

        -- Legacy support: If "Increased/Decreased magazine capacity" line exists, don't do our autostats version
        if hasmaginfo and i == "Override_ClipSize" then continue end

        if i == "UBGL" then 
            table.insert(infos, translate("autostat.ubgl2"))
        end

        local txt, typ = stattext(wep, atttable, i, atttable[i], dmgboth, ArcCW_AutoStats[i].flipsigns)
        if !txt then continue end

        if typ == "pros" then
            table.insert(pros, txt)
        elseif typ == "cons" then
            table.insert(cons, txt)
        elseif typ == "infos" then
            table.insert(infos, txt)
        end
    end

    return pros, cons, infos
end

local function GetArcCWStats(wpnname)
    local stattbl = {}
    local wpntbl = weapons.GetStored(wpnname.ent)
    local wpnparams = {"Damage", "DamageMin", "RangeMin", "Range", "Penetration", "MuzzleVelocity", "BarrelLength", "Primary.ClipSize", "Recoil", "RecoilSide", "RecoilRise", "Delay", "Firemodes", "ShootVol", "AccuracyMOA", "HipDispersion", "MoveDispersion", "JumpDispersion", "Primary.Ammo", "SpeedMult", "SightedSpeedMult", "SightTime", "ShootSpeedMult"}
    
    for _, v in ipairs(wpnparams) do
        local paramtbl = {name = v, stat = wpntbl.[v]}

        table.insert(stattbl, paramtbl)
    end

    return stattbl
end

local function GetStats(itemtbl)
    local stattbl = nil
    local enttbl = scripted_ents.GetStored(itemtbl.ent) -- how do we get entity table
    local sweptbl = weapons.GetStored(itemtbl.ent)

    if istable(sweptbl) then
        for _, v in ipairs(wpnparams) do
            if isempty(sweptbl.v) then continue end

            table.insert(stattbl, sweptbl.v)
        end
    elseif istable(enttbl) then
        -- for _, v in ipairs(attparams) do
        --     if isempty(sweptbl.v) then continue end

        --     table.insert(stattbl, sweptbl.v)
        -- end
        if itemtbl.override == true then
            stattbl = RemoveStrings(itemtbl, true)

            return stattbl
        elseif IsArcCWAtt(enttbl) then
            return nil
        end
        print(enttbl)
    else
        print("Failed to parse stats, check your code or report this error to the github!")
    end
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

local function GetModelIcon(enttbl)
    local modelicon = nil

    return modelicon
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

    SmoothScrollBar(parentScrollBar)

    return parentScrPanel
end

local function CreateItemPanel(parent, itemtbl, w, h)
    if itemtbl == nil or parent == nil then return end

    -- local itemButton = vgui.Create("DButton", parent)
    local itemButton = parent:Add("DButton")
    itemButton:Dock(TOP)
    itemButton:DockMargin(0, 10, 30, 30)
    -- itemButton:SetSize(w, h)
    itemButton:SetPos(x, y)

    local printname = EntityPrintName(itemtbl)

    function itemButton:Paint(w, h)
        draw.DrawText(printname, "chicagoRP_NPCShop", (w / 2) - 10, 10, whitecolor, TEXT_ALIGN_LEFT)
        draw.RoundedBox(4, 0, 0, w, h, graycolor)
        surface.DrawTexturedRectRotated(20, y, w, 64, 0)

        if self.discounted == true and isnumber(self.discountseed) then
            draw.DrawText("HOLY SHIT CRACKER THESE SOME GOOD DISCOUNTS!!!", "chicagoRP_NPCShop", 40, 40, purplecolor, TEXT_ALIGN_CENTER)
            draw.DrawText(self.discountseed, "chicagoRP_NPCShop", 20, 20, purplecolor, TEXT_ALIGN_CENTER)
        end

        return true
    end

    function itemButton:DoClick()
        local expandedPanel = ExpandedItemPanel(itemtbl)
    end

    local spawnicon = OptimizedSpawnIcon(itemButton, EntityModel(itemtbl), 100, 50, 64, 64)

    spawnicon.Think = nil

    local cartButton = AddCartButton(parent, x, y, w, h)
    local quanitySel = QuanitySelector(parent, 200, 0, 40, 20)
    local statPanel = InfoParentPanel(parent, itemtbl, 2, 100, w - 4, 100)

    local stattbl = GetStats(itemtbl)
    local pros, cons, infos = GetAttStats(itemtbl.wpn, itemtbl.ent)

    if istable(stattbl) then
        for _, v in ipairs(stattbl) do
            if isempty(v) then continue end

            InfoTextPanel(parent, v, whitecolor, (w / 2) - 4, 25)
        end
    elseif !istable(stattbl) or stattbl == nil then
        local pros, cons, infos = GetAttStats(itemtbl.wpn, itemtbl.ent)

        if istable(pros) then
            for _, v2 in ipairs(pros) do
                if isempty(v2) then continue end

                InfoTextPanel(parent, v2, whitecolor, (w / 2) - 4, 25)
            end
        end

        if istable(cons) then
            for _, v2 in ipairs(cons) do
                if isempty(v2) then continue end

                InfoTextPanel(parent, v2, whitecolor, (w / 2) - 4, 25)
            end
        end

        if istable(infos) then
            for _, v2 in ipairs(infos) do
                if isempty(v2) then continue end

                InfoTextPanel(parent, v2, whitecolor, (w / 2) - 4, 25)
            end
        end
    end

    function quanitySel:OnValueChanged(val)
        print("Quanity: " .. val)
        cartButton.value = val
    end

    function cartButton:DoClick()
        local quanity = self.value -- how do we do if quanity > server_quanity then func return end?
        local finaltable = {itemtbl, quanity}

        for _, v in ipairs(carttable) do
            if v.itemname == itemtbl then
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
    itemFrame:SetTitle(EntityPrintName(entname))
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

    local model = EntityModel(entname)
    local isAtt = IsArcCWAtt(itemtbl)
    local enttbl = scripted_ents.GetStored(entname)
    local bg_elements = enttbl.ActivateElements

    local modelPanel = FancyModelPanel(itemFrame, model, 50, 0, frameW, 300, purplecolor) -- fix model
    local textPanel = ScrollingTextPanel(itemFrame, 350, 0, 100, 100)
    local cartButton = AddCartButton(itemFrame, 500, 860, 100, 30)
    local quanitySel = QuanitySelector(itemFrame, 500, 820, 40, 20)

    if isAtt and istable(enttbl) and !isempty(bg_elements) then
        local weapon = itemtbl.wpn
        local parenttbl = weapons.GetStored(weapon)

        local bodygroups = ArcCWBodygroup(weapon, bg_elements)

        modelPanel:SetModel(parenttbl.Model)

        for _, v in ipairs(bodygroups) do
            modelPanel.Entity:SetBodygroup(v.ind, v.bg)
        end
    end

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

    local printname = EntityPrintName(itemtbl)

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

    SmoothScrollBar(cartScrollBar)

    return cartScrollPanel
end

local function GetDiscountTable()
    net.Start("chicagoRP_NPCShop_senddiscount")
    net.SendToServer()
end

local function GetQuanityTable()
    net.Start("chicagoRP_NPCShop_sendquanity")
    net.SendToServer()
end

local function GetOOSTable()
    net.Start("chicagoRP_NPCShop_sendoos")
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

net.Receive("chicagoRP_NPCShop_getquanity", function()
    local bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
    local compTable = net.ReadData(bytecount) -- Gets back our compressed message
    local decompTable = util.Decompress(compTable)
    local finalTable = util.JSONToTable(decompTable)

    if istable(finalTable) then 
        quanitytable = finalTable
    end
end)

net.Receive("chicagoRP_NPCShop_getoos", function()
    local bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
    local compTable = net.ReadData(bytecount) -- Gets back our compressed message
    local decompTable = util.Decompress(compTable)
    local finalTable = util.JSONToTable(decompTable)

    if istable(finalTable) then 
        OOStable = finalTable
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

    motherFrame.lblTitle.Think = nil

    carttable = {}

    GetDiscountTable()

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

    local searchstring = nil

    for _, v in ipairs(chicagoRP_NPCShop.categories) do
        local catButton = CategoryButton(catScrollPanel, k, w, h)

        local shopScrollPanel = ItemScrollPanel(motherFrame, 100, 200, 700, 500)
        shopScrollPanel:Hide()

        for _, v3 in ipairs(browsingPanels) do
            v3:Hide()
        end

        local oPerformLayout = shopScrollPanel.PerformLayout

        function shopScrollPanel:PerformLayout(w, h)
            oPerformLayout(w, h)

            for _, v4 in ipairs(self:GetChildren()) do
                v4:Remove()
            end

            for _, v2 in ipairs(chicagoRP_NPCShop[v.name]) do
                local itemPanel = nil

                if istable(filtertable) and !isempty(filtertable) then
                    for _, v5 in ipairs(filtertable) do -- how do we get args and compare them?
                        if v5.typ != v.v5.typ and v5.inc != true then continue end -- for strings
                        if v5.parse != v.v5.typ then continue end -- for numbers
                        if v5.min < v.v5.parse then continue end -- for numbers
                        if v5.max > v.v5.parse then continue end -- for numbers
                        if isstring(searchstring) and IsValid(string.match(v.ent, searchstring)) then continue end

                        itemPanel = CreateItemPanel(shopScrollPanel, v2, w, h)
                    end
                else
                    itemPanel = CreateItemPanel(shopScrollPanel, v2, w, h)
                end

                for _, vv in ipairs(discounttable) do
                    if !IsValid(itemPanel) or vv.itemname != v2.ent then continue end

                    itemPanel.discounted = true
                    itemPanel.discount = vv.discountseed
                end

                local sanitizedtbl = RemoveStrings(v2, false)
                local filterLayout = {}

                if GetWeaponBase(v2) == "arccw" then
                    local wpntable = table.Add(v2, GetArcCWStats(v2))
                    local scrubbedtbl = RemoveStrings(wpntable, false)

                    sanitizedtbl = scrubbedtbl
                end

                for _, v3 in ipairs(sanitizedtbl) do
                    if isstring(v3) then
                        local checkBox = FilterCheckBox(filterPanel, PrettifyString(v3), 40, 20)

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

            OpenShopPanel = shopScrollPanel

            for _, v3 in ipairs(browsingPanels) do
                v3:Show()
            end

            for _, v2 in ipairs(chicagoRP_NPCShop[v.name]) do
                local itemPanel = CreateItemPanel(shopScrollPanel, v2, w, h)
            end
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

    if !table.IsEmpty(carttable) then
        for _, v in ipairs(carttable)
            CartItemPanel(cartScrollPanel, v, 100, 200)
        end
    end

    OpenCartPanel = cartScrollPanel
    OpenMotherFrame = motherFrame
end)

print("chicagoRP NPC Shop GUI loaded!")

-- todo:
-- hook GetQuanityTable functiona and GetOOSTable function into panels
-- update clientside quanity text when serverside quanity table is updated (when quanity table is changed, send net message to client that invalidates panel layout and does GetQuanityTable and GetOOSTable)

-- later:
-- how to spawn npcs in an npc table and assign specific tables to them?
-- how to (securely) send NPC table to GUI?
-- add homepage (just restocked, most popular, discounts)
-- add mLogs and Billy's Logs support








