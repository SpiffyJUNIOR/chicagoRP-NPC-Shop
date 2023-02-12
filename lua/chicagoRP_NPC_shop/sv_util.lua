util.AddNetworkString("chicagoRP_NPCShop_GUI")
util.AddNetworkString("chicagoRP_NPCShop_sendcart")
util.AddNetworkString("chicagoRP_NPCShop_invalidatelclient")

local enabled = GetConVar("sv_chicagoRP_NPCShop_enable")
local discountsenabled = GetConVar("sv_chicagoRP_NPCShop_discounts")
local discountchance = GetConVar("sv_chicagoRP_NPCShop_discountchance")
local discountdelay = GetConVar("sv_chicagoRP_NPCShop_discountdelay")

local SVTable = {}
SVTable.discounttable = {}
SVTable.quanitytable = {}
SVTable.OOStable = {}
SVTable.discounttimers = {}
SVTable.restocktimers = {}

local discountindex = 0
local OOSindex = 0

local function RandomItem()
	local shuffledindextbl = chicagoRP_NPCShop.categories[math.random(#cattbl)]
	local cattbl = chicagoRP_NPCShop[shuffledindextbl.name]
	local shuffleditemtbl = cattbl[math.random(#cattbl)]

	return shuffleditemtbl
end

local function DiscountThink()
	local seed = math.random(1, 100)

	if seed > discountchance:GetInt() then return end

	local itemtbl = RandomItem()

	if timer.Exists("chicagoRP_NPCShop_discount_" .. itemtbl.ent) then itemtbl = RandomItem() end
	if timer.Exists("chicagoRP_NPCShop_discount_" .. itemtbl.ent) then itemtbl = RandomItem() end

	local discountseed = math.random(10, 50) -- default percent
	local discounttime = 600 -- default time

	if isnumber(itemtbl.discount) then discountseed = itemtbl.discount end
	if isnumber(itemtbl.discounttime) then discounttime = itemtbl.discounttime end

	chicagoRP_NPCShop.CreateDiscount(itemtbl.ent, discounttime, discountseed)
end

function chicagoRP_NPCShop.GetDiscountPercentage(ent)
    return SVTable.discounttable[ent] or nil
end

function chicagoRP_NPCShop.GetDiscountTime(ent)
    return SVTable.discounttable[ent] or nil
end

function chicagoRP_NPCShop.GetItemCategory(ent)
	for _, v in ipairs(chicagoRP_NPCShop) do
		PrintTable(v)
	end
end

function chicagoRP_NPCShop.CreateDiscount(ent, discounttime, discountseed)
	local cachedent = ent

	SVTable.discounttable[ent] = {discount = discountseed, discounttime = discounttime}
	SVTable.discounttimers[ent] = {timeleft = discounttime}
	timer.Create("chicagoRP_NPCShop_discount_" .. ent, discounttime, 1, chicagoRP_NPCShop.RemoveDiscount(cachedent))
end

function chicagoRP_NPCShop.CreateOOS(ent, restocktime)
	local cachedent = ent

	SVTable.OOStable[ent] = {OOS = true}
	SVTable.restocktimers[ent] = {timeleft = restocktime}
	timer.Create("chicagoRP_NPCShop_OOS_" .. ent, restocktime, 1, chicagoRP_NPCShop.RestockItem(cachedent))
end

function chicagoRP_NPCShop.RestockItem(ent)
	SVTable.OOStable[ent] = nil

	if timer.Exists("chicagoRP_NPCShop_OOS_" .. ent) then
		SVTable.restocktimers[ent] = nil

		timer.Remove("chicagoRP_NPCShop_OOS_" .. ent)
	end
end

function chicagoRP_NPCShop.RemoveDiscount(ent)
	SVTable.discounttable[ent] = nil

	if timer.Exists("chicagoRP_NPCShop_discount_" .. ent) then
		SVTable.discounttimers[ent] = nil

		timer.Remove("chicagoRP_NPCShop_discount_" .. ent)
	end
end

net.Receive("chicagoRP_NPCShop_sendcart", function(_, ply)
	if !IsValid(ply) or !ply:Alive() or !ply:OnGround() or ply:InVehicle() then return end

	-- local viewtrace = ply:GetEyeTraceNoCursor()
	-- local entname = viewtrace.Entity:GetName()

	-- if string.Left(entname, 15) != "chicagoRP_shop_" or !viewtrace.Entity:IsNPC() then return end -- EZ anti-exploit

	local bytecount = net.ReadUInt(16) -- Gets back the amount of bytes our data has
	local compTable = net.ReadData(bytecount) -- Gets back our compressed message
	local decompTable = util.Decompress(compTable)
	local finalTable = util.JSONToTable(decompTable)

	PrintTable(finalTable)

	local subtotal = 0
	local groupedOOStbl = {}

	for k, _ in pairs(finalTable) do
		local v = chicagoRP_NPCShop.iteminfo[k]

        if !table.IsEmpty(SVTable.OOStable) and !table.IsEmpty(SVTable.OOStable[v.ent]) then
			print("item out of stock")

	        table.insert(groupedOOStbl, {ent = v.ent})
	    end

        if !table.IsEmpty(SVTable.quanitytable) then
        	if table.IsEmpty(SVTable.quanitytable[v.ent]) then
                SVTable.quanitytable[v.ent] = {quanity = v.quanity}
        	else
                local cachedquanity = chicagoRP_NPCShop.iteminfo[v.ent].quanity

            	if SVTable.quanitytable[v.ent].quanity + v.quanity => cachedquanity then
            		v.quanity = cachedquanity - SVTable.quanitytable[v.ent].quanity
            		SVTable.quanitytable[v.ent] = nil

            		chicagoRP_NPCShop.CreateOOS(v.ent, v3.restock)
            		table.insert(groupedOOStbl, {ent = v.ent, insufficient = true, quanitybought = v.quanity)
            	end
            end
	    end

	    local itemprice = v.price

        if !table.IsEmpty(SVTable.discounttable) and !table.IsEmpty(SVTable.discounttable[v.ent]) then
			local discount = SVTable.discounttable[v.ent].percent

			itemprice = itemprice - math.Round((itemprice * discount))
	    end

        subtotal = subtotal + v.price

        -- ply:Give(v.ent)
        local plypos = ply:GetPos()
        plypos:Add(Vector(0, 5, 0))
        local spawnedent = ents.Create(v.ent)
		button:SetPos(plypos)
		button:Spawn()
	end

    local UQ_JSONTable = util.TableToJSON(SVTable)
    local UQ_compTable = util.Compress(JSONTable)
    local UQ_bytecount = #UQ_compTable

    net.Start("chicagoRP_NPCShop_invalidatelclient")
	net.WriteUInt(UQ_bytecount, 16)
	net.WriteData(UQ_compTable, UQ_bytecount)

	if !table.IsEmpty(groupedOOStbl) then
	    local OOS_JSONTable = util.TableToJSON(groupedOOStbl)
	    local OOS_compTable = util.Compress(JSONTable)
	    local OOS_bytecount = #compTable

	    net.WriteBool(true)
		net.WriteUInt(OOS_bytecount, 16)
		net.WriteData(OOS_compTable, OOS_bytecount)
	else
		net.WriteBit(false)
		net.Send(ply)
	end

	ply:addMoney(-subtotal)
end)

if discountsenabled:GetBool() then
	timer.Create("chicagoRP_NPCShop_discounts", discountdelay:GetInt(), 0, DiscountThink())
end

concommand.Add("chicagoRP_NPCShop", function(ply)
    if !IsValid(ply) then return end
    local JSONTable = util.TableToJSON(SVTable)
    local compTable = util.Compress(JSONTable)
    local bytecount = #discounttable

    net.Start("chicagoRP_NPCShop_GUI")
    net.WriteBool(true)
	net.WriteUInt(bytecount, 16)
	net.WriteData(compTable, bytecount)
    net.Send(ply)
end)











