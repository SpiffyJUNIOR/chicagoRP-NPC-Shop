util.AddNetworkString("chicagoRP_NPCShop_GUI")
util.AddNetworkString("chicagoRP_NPCShop_sendcart")
util.AddNetworkString("chicagoRP_NPCShop_senddiscount")
util.AddNetworkString("chicagoRP_NPCShop_sendquanity")
util.AddNetworkString("chicagoRP_NPCShop_sendoos")
util.AddNetworkString("chicagoRP_NPCShop_getdiscount")
util.AddNetworkString("chicagoRP_NPCShop_getquanity")
util.AddNetworkString("chicagoRP_NPCShop_getoos")
util.AddNetworkString("chicagoRP_NPCShop_senddiscounttimers")
util.AddNetworkString("chicagoRP_NPCShop_getdiscounttimers")
util.AddNetworkString("chicagoRP_NPCShop_sendrestocktimers")
util.AddNetworkString("chicagoRP_NPCShop_getrestocktimers")
util.AddNetworkString("chicagoRP_NPCShop_itemOOSalert")
util.AddNetworkString("chicagoRP_NPCShop_updatequanity")

local enabled = GetConVar("sv_chicagoRP_NPCShop_enable")
local discountsenabled = GetConVar("sv_chicagoRP_NPCShop_discounts")
local discountchance = GetConVar("sv_chicagoRP_NPCShop_discountchance")
local discountdelay = GetConVar("sv_chicagoRP_NPCShop_discountdelay")

local discounttable = {}
local quanitytable = {}
local OOStable = {}
local discounttimers = {}
local restocktimers = {}

local function isempty(s)
    return s == nil or s == ""
end

local function KeyFromValue(tbl, val)
	for key, value in ipairs(tbl) do
		if (value == val) then return key end
	end
end

local function RemoveByValue(tbl, val)
	local key = KeyFromValue(tbl, val)
	if (!key) then return false end

	if (isnumber(key)) then
		table.remove(tbl, key)
	else
		tbl[key] = nil
	end

	return key
end

local function GetDiscount(ent)
    for _, v in ipairs(discounttable)
    	if v.ent == ent then return v.percent end
    end
end

local function GetItemCategory(ent)
	for _, v in ipairs(chicagoRP_NPCShop) do
		PrintTable(v)
	end
end

local function RestockItem(ent)
	RemoveByValue(OOStable, ent)

	if timer.Exists("chicagoRP_NPCShop_OOS_" .. ent) then
		restocktimers[ent].itemname = nil

		timer.Remove("chicagoRP_NPCShop_OOS_" .. ent)
	end
end

local function DiscountRemove(ent)
	RemoveByValue(discounttable, ent)

	if timer.Exists("chicagoRP_NPCShop_discount_" .. ent) then
		discounttimers[ent].itemname = nil

		timer.Remove("chicagoRP_NPCShop_discount_" .. ent)
	end
end

local function DiscountThink()
	local seed = math.random(1, 100)
	if seed > discountchance:GetInt() then return end

	local randomitemtbl = mytable[math.random(1, #mytable)]

	if timer.Exists("chicagoRP_NPCShop_discount_" .. v.ent) then return end

	local discountseed = math.random(10, 50) -- default percent
	local discounttime = 600 -- default time

	if isnumber(v.discount) then discountseed = v.discount end
	if isnumber(v.discounttime) then discounttime = v.discounttime end

	timer.Create("chicagoRP_NPCShop_discount_" .. v.ent, discounttime, 1, DiscountRemove(v.ent))
	table.insert(discounttimers, {itemname = v.ent})

	local infotbl = {itemname = v.ent, discount = discountseed, discounttime = discounttime}

	table.insert(discounttable, infotbl)
end

net.Receive("chicagoRP_NPCShop_senddiscount", function(_, ply)
	local nettable = nil

	if istable(discounttable) then
		nettable = discounttable

        local JSONTable = util.TableToJSON(discounttable)
        local compTable = util.Compress(JSONTable)
        local bytecount = #discounttable

        net.Start("chicagoRP_NPCShop_getdiscount")
        net.WriteUInt(bytecount, 16)
        net.WriteData(compTable, bytecount)
		net.Send(ply)
	end
end)

net.Receive("chicagoRP_NPCShop_sendquanity", function(_, ply)
	local nettable = nil

	if istable(discounttable) then
		nettable = quanitytable

        local JSONTable = util.TableToJSON(discounttable)
        local compTable = util.Compress(JSONTable)
        local bytecount = #discounttable

        net.Start("chicagoRP_NPCShop_sendquanity")
        net.WriteUInt(bytecount, 16)
        net.WriteData(compTable, bytecount)
		net.Send(ply)
	end
end)

net.Receive("chicagoRP_NPCShop_sendoos", function(_, ply)
	local nettable = nil
	local mrgntbl = {}

	if istable(restocktimers) then
		nettable = restocktimers

		for _, v in ipairs(restocktimers) do
			local timername = ("chicagoRP_NPCShop_OOS_" .. v.itemname)

			if timer.Exists(timername) then

				local TimeLeft = timer.TimeLeft(timername)

				table.insert(mrgntbl, {timeleft = TimeLeft})
			else
				continue
			end
		end

		local finaltbl = table.Merge(restocktimers, mrgntbl)

        local JSONTable = util.TableToJSON(finaltbl)
        local compTable = util.Compress(JSONTable)
        local bytecount = #discounttable

        net.Start("chicagoRP_NPCShop_getdiscounttimers")
        net.WriteUInt(bytecount, 16)
        net.WriteData(compTable, bytecount)
		net.Send(ply)
	end
end)

net.Receive("chicagoRP_NPCShop_senddiscounttimers", function(_, ply)
	local nettable = nil
	local mrgntbl = {}

	if istable(discounttimers) then
		nettable = discounttimers

		for _, v in ipairs(discounttimers) do
			local timername = ("chicagoRP_NPCShop_discount_" .. v.itemname)

			if timer.Exists(timername) then

				local TimeLeft = timer.TimeLeft(timername)

				table.insert(mrgntbl, {timeleft = TimeLeft})
			else
				continue
			end
		end

		local finaltbl = table.Merge(discounttimers, mrgntbl)

        local JSONTable = util.TableToJSON(finaltbl)
        local compTable = util.Compress(JSONTable)
        local bytecount = #discounttable

        net.Start("chicagoRP_NPCShop_getdiscounttimers")
        net.WriteUInt(bytecount, 16)
        net.WriteData(compTable, bytecount)
		net.Send(ply)
	end
end)

net.Receive("chicagoRP_NPCShop_sendrestocktimers", function(_, ply)
	local nettable = nil

	if istable(restocktimers) then
		nettable = restocktimers

        local JSONTable = util.TableToJSON(discounttable)
        local compTable = util.Compress(JSONTable)
        local bytecount = #discounttable

        net.Start("chicagoRP_NPCShop_getrestocktimers")
        net.WriteUInt(bytecount, 16)
        net.WriteData(compTable, bytecount)
		net.Send(ply)
	end
end)

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

	for _, v in ipairs(finalTable) do
        local qtytbl = {itemname = v.itemname, quanity = v.quanity}

        if !table.IsEmpty(OOStable) then
        	for _, v4 in ipairs(OOStable) do
        		if v4.itemname == v.itemname then
        			print("item out of stock")

			        net.Start("chicagoRP_NPCShop_itemOOSalert")
			        net.WriteString(v.itemname)
					net.Send(ply)

        			continue
        		end
        	end
        end

        -- subtotal = subtotal + v.price

        local itemprice = v.price

        for _, v2 in ipairs(quanitytable) do
            if v.itemname == v2.itemname then
                v.quanity = v.quanity + quanity

                break
            else
                table.insert(quanitytable, qtytbl)

                for _, v3 in ipairs(GetItemCategory(v.itemname)) do
                	if v.quanity => v3.quanity then
                		table.insert(OOStable, v.itemname)
                		table.insert(restocktimers, {itemname = v.itemname})

                		timer.Create("chicagoRP_NPCShop_OOS_" .. v.itemname, v3.restock, 1, RestockItem(v.itemname))
                	end
                end

                break
            end
        end

        for _, v5 in ipairs(discounttable)
        	if v5.ent == v.itemname then
        		itemprice = itemprice - math.Round((itemprice * v5.percent))

        		break
        	end
        end

        subtotal = subtotal + v.price
        -- ply:Give(v.itemname)
        local plypos = ply:GetPos()
        plypos:Add(Vector(0, 5, 0))
        local spawnedent = ents.Create(v.itemname)
		button:SetPos(plypos)
		button:Spawn()
	end

    net.Start("chicagoRP_NPCShop_updatequanity")
	net.Send(ply)

	ply:addMoney(-subtotal)
end)

if discountsenabled:GetBool() then
	timer.Create("chicagoRP_NPCShop_discounts", discountdelay:GetInt(), 0, DiscountThink())
end

concommand.Add("chicagoRP_NPCShop", function(ply) -- how we close/open this based on bind being held?
    if !IsValid(ply) then return end
    net.Start("chicagoRP_NPCShop_GUI")
    net.WriteBool(true)
    net.Send(ply)
end)











