CreateConVar("sv_chicagoRP_NPCShop_enable", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY}, "Enables or disables the NPC Shop.", 0, 1)
CreateConVar("sv_chicagoRP_NPCShop_discounts", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY}, "Enables or disables random discounts.", 0, 1)
CreateConVar("sv_chicagoRP_NPCShop_discountchance", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY}, "Changes the chance for a new discount, run every 60 seconds by default.", 1, 100)
CreateConVar("sv_chicagoRP_NPCShop_discountdelay", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY}, "In seconds, changes how often new discount creation is attempted.", 15)

print("chicagoRP NPC Shop server convars loaded!")