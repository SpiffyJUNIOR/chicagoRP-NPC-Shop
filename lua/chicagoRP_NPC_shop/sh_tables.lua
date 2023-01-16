chicagoRP_NPCShop = chicagoRP_NPCShop or {}

chicagoRP_NPCShop.categories = {
    {
        icon = "chicagorp_npcshop/armor.png",
        name = "armor"
    }, {
        icon = "chicagorp_npcshop/weapons.png",
        name = "weapons"
    }
}

chicagoRP_NPCShop.health = {
    {
        ent = "healthkit",
        health = 25,
        infotext = "Best healing method.",
        override = true,
        price = 20,
        quanity = 20,
        restock = 600,
    }, {
        ent = "healthtube",
        health = 10,
        infotext = "The health tube is a cheap method of healing, but is superceded by the health kit.",
        override = true,
        price = 10,
        quanity = 30,
        restock = 300,
    }
}

chicagoRP_NPCShop.armor = {
    {
        ent = "ezjmodlighthelmet",
        infotext = "The light helmet is a weak but plentiful and cheap method of protecting yo' head.",
        override = true,
        price = 50,
        protection = 1,
        quanity = 20,
        restock = 300,
        slot = "head",
        weight = 5
    }, {
        ent = "ezjmodheavychest",
        infotext = "For when you need the best protection possible, or just wanna feel like a badass; heavy chest armor is your premier choice.",
        override = true,
        price = 770,
        protection = 5,
        quanity = 5,
        restock = 600,
        slot = "head",
        weight = 30
    }
}

chicagoRP_NPCShop.weapons = {
    {
        -- accuracy = 7,
        -- ammo = "pistol",
        -- damage = 33,
        -- damagemin = 17,
        ent = "arccw_ud_glock",
        -- fcg = "semi_auto",
        -- hipfire = 500,
        infotext = "Handgun originally designed by a curtain rod manufacturer for the Austrian military. Its reliable and cost-effective polymer design has since made it one of the most popular and widely used pistols in the world, common in military, police and civilian use alike.\nGreat backup weapon due to its quick draw and sight times, but a relatively low damage output makes it a less than ideal primary.",
        -- magcapacity = 17,
        -- muzzlevelocity = 375,
        -- penetration = 6,
        price = 400,
        quanity = 12,
        -- range = 50,
        -- rangemin = 15,
        -- recoil = 1.0,
        restock = 300,
        -- rpm = 525,
        -- sighttime = 0.25,
        -- speedmult = 0.975,
        type = "pistol",
        vol = 120
    }, {
        -- accuracy = 5,
        -- ammo = "ar2",
        -- damage = 50,
        -- damagemin = 25,
        ent = "arccw_ur_ak",
        -- fcg = "full_auto",
        -- hipfire = 800,
        infotext = "The greatest weapon ever created, the AKM is a remake of Pilot Wings 64. The metalworking is amazing. The graphics are amazing. Following his uncle's request, Niko My Casin, black guy, comes to Vice City to pursue the Mexican Dream, and to search for the horse who ate his slim jim and stole his AKM in a war fifteen years prior. Upon arrival, however, Niko discovers that Hulk Hogan's tale of riches and luxury was all a lie. Hulk had been concealing struggles with gambling debts and loan sharks, and does not own an AKM.",
        -- magcapacity = 30,
        -- muzzlevelocity = 715,
        -- penetration = 16,
        price = 1100,
        quanity = 20,
        -- range = 300,
        -- rangemin = 30,
        -- recoil = 0.75,
        restock = 250,
        -- rpm = 600,
        sighttime = 0.35,
        -- speedmult = 0.90,
        type = "assault_rifle",
        vol = 120
    }
}

chicagoRP_NPCShop.attachments = {
    {
        -- cons = {sightedspeedmult = 0.90},
        ent = "uc_optic_acog",
        infotext = "Tried-and-true sighting solution for close to medium ranges. Improves target acquisition with a highly precise circle-dot holographic reticle while adding minimal extra weight.",
        price = 570,
        -- pros = {"autostat.holosight"},
        quanity = 4,
        restock = 300,
        -- slots = {"optic"},
        type = "scope"
    }, {
        -- cons = {sightedspeedmult = 0.75},
        ent = "uc_optic_eotech553",
        infotext = "Medium range combat scope for improved precision at longer ranges.\nEquipped with backup iron sights for use in emergencies.",
        price = 730,
        -- pros = {"autostat.holosight", "autostat.zoom"},
        quanity = 4,
        restock = 300,
        -- slots = {"optic", "ud_optic", "ud_acog"},
        type = "sight"
    }, {
        -- cons = {sightedspeedmult = 0.75, speedmult = 0.975},
        ent = "ud_m16_stock_wood",
        infotext = "A sturdy stock made from wood. Heavier than polymer, and almost makes you wish for a nuclear winter.",
        price = 450,
        -- pros = {recoil = 0.85, swaymult = 0.75},
        quanity = 6,
        restock = 600,
        -- slots = {"ud_m16_stock"},
        type = "stock",
        wpn = "arccw_ud_m16"
    }
}

-- chicagoRP_NPCShop.entities = {
--     {
--         artist = "Goldie",
--         length = 1263,
--         song = "Timeless",
--         url = "https://files.catbox.moe/rk5cu8.mp3"
--     }, {
--         artist = "Jacob's Optical Stairway",
--         length = 301,
--         song = "The Fusion Formula (The Metamorphosis)",
--         url = "https://files.catbox.moe/b9jsbm.mp3"
--     }, {
--         artist = "Source Direct",
--         length = 483,
--         song = "Secret Liaison",
--         url = "https://files.catbox.moe/j1t3kp.mp3"
--     }
-- }

print("chicagoRP NPC Shop tables loaded")