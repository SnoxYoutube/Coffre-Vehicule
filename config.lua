-- Pensez à save les coffre avant de reboot votre serveur avec la commande /savecoffreveh
Config = {
    ESX = "",
    Touche = "L",
    MessageBan = "Tentative de Cheat",
    OnlyOwnerConfig = {
        Deposit = true,-- Peut déposer 
        Remove = true, -- Ne peux pas retirer
    },
    Money = {
        cash = "cash",
        argentsale = "dirtycash"
    },
    Logs = {
        Actif = true, 
        --Items 
        DepotItem = "https://discord.com/api/webhooks/981625483756191754/foWzBTQfAs8KtdBbAGVZGaBG1u6ylC6v-G1Uvk5euFptiKcXayXz04Ah36UyMGu4NqtS",
        RemoveItem = "https://discord.com/api/webhooks/981625483756191754/foWzBTQfAs8KtdBbAGVZGaBG1u6ylC6v-G1Uvk5euFptiKcXayXz04Ah36UyMGu4NqtS",
        -- Armes
        DepotWeapons = "https://discord.com/api/webhooks/981625483756191754/foWzBTQfAs8KtdBbAGVZGaBG1u6ylC6v-G1Uvk5euFptiKcXayXz04Ah36UyMGu4NqtS",
        RemoveWeapon = "https://discord.com/api/webhooks/981625483756191754/foWzBTQfAs8KtdBbAGVZGaBG1u6ylC6v-G1Uvk5euFptiKcXayXz04Ah36UyMGu4NqtS",
        --Argent 
        DepotMoney = "https://discord.com/api/webhooks/981625483756191754/foWzBTQfAs8KtdBbAGVZGaBG1u6ylC6v-G1Uvk5euFptiKcXayXz04Ah36UyMGu4NqtS",
        RemoveMoney = "https://discord.com/api/webhooks/981625483756191754/foWzBTQfAs8KtdBbAGVZGaBG1u6ylC6v-G1Uvk5euFptiKcXayXz04Ah36UyMGu4NqtS",
    }
}

WeightWeh = {
    [0] = 5, --Compact
    [1] = 30,
    [2] = 40,
    [3] = 50,
    [4] = 60, --Vans
    [5] = 70,
    [6] = 5,
    [7] = 5, --LE 8 C LES MOTO MES G RETIRER  Le 7 c supersportive
    [9] = 50, --Style Bifta
    [10] = 500, --Style Guardian
    [11] = 130,
    [12] = 140,
    [13] = 150,
    [14] = 10,
    [15] = 170, --Helico
    [16] = 250, --Avion
    [17] = 190,
    [18] = 200,
    [19] = 210,
    [20] = 220,
    [21] = 230,
}

WeaponWeight = {
    ["WEAPON_NIGHTSTICK"] = 15,
    ["WEAPON_STUNGUN"] = 30,
    ["WEAPON_FLASHLIGHT"] = 15,
    ["WEAPON_FLAREGUN"] = 30,
    ["WEAPON_FLARE"] = 30,
    ["WEAPON_COMBATPISTOL"] = 35,
    ["WEAPON_HEAVYPISTOL"] = 32,
    ["WEAPON_ASSAULTSMG"] = 40,
    ["WEAPON_BULLPUPRIFLE"] = 42,
    ["WEAPON_PUMPSHOTGUN"] = 42,
    ["WEAPON_BULLPUPSHOTGUN"] = 45,
    ["WEAPON_CARBINERIFLE"] = 45,
    ["WEAPON_ADVANCEDRIFLE"] = 45,
    ["WEAPON_MARKSMANRRIFLE"] = 28,
    ["WEAPON_SNIPERRIFLE"] = 28,
    ["WEAPON_FIREEXTINGUISHER"] = 28, 
    ["GADGET_PARACHUTE"] = 10,
    ["WEAPON_PISTOL"] = 40,
    ["WEAPON_PISTOL50"] = 42, 
    ["WEAPON_snspistol"] = 36,
    ["WEAPON_revolver"] = 52,
    ["WEAPON_vintagepistol"] = 42,
    ["WEAPON_microsmg"] = 56,
    ["WEAPON_SMG"] = 58,
    ["WEAPON_MACHINEPISTOL"] = 48,
    ["WEAPON_MINISMG"] = 10,
    ["WEAPON_compactrifle"] = 58,
    ["WEAPON_heavyshotgun"] = 42,
    ["WEAPON_autoshotgun"] = 32,
    ["WEAPON_dagger"] = 10,
    ["WEAPON_crowbar"] = 10,
    ["WEAPON_knuckle"] = 10,
    ["WEAPON_KNIFE"] = 10,
    ["WEAPON_wrench"] = 13,
    ["WEAPON_poolcue"] = 13,
}

ItemWeight = {
    ["FENTANYL_POOCH"] = 500,
}
