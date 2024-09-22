
// TODO:
// - make damage -> percent better (bit low atm?)
// - make percent -> knockback a lot better
// - add dispensers to podiums
// - set up podiums/podium clips for >1 player

sandbag_model <- "models/tf2ware_ultimate/sandbag.mdl"
HomeRun_Sandbags <- []

// TODO: Give players their equipped loadouts instead.
HomeRun_Loadouts <- [
	{
		player_class = TF_CLASS_SCOUT
		loadout = ["Scattergun", "Pistol"],
	},
	{
		player_class = TF_CLASS_SOLDIER
		loadout = ["Rocket Launcher", "Shotgun"],
	},
	{
		player_class = TF_CLASS_PYRO
		loadout = ["Flamethrower", "Shotgun"],
	},
	{
		player_class = TF_CLASS_DEMOMAN
		loadout = ["Grenade Launcher", "Stickybomb Launcher"],
	},
	{
		player_class = TF_CLASS_HEAVYWEAPONS
		loadout = ["Minigun", "Shotgun"],
	},
	{
		player_class = TF_CLASS_ENGINEER
		loadout = ["Shotgun", "Pistol", "Construction PDA", "Toolbox"],
	},
	{
		player_class = TF_CLASS_MEDIC
		loadout = ["Syringe Gun", "Medi Gun"],
	},
	{
		player_class = TF_CLASS_SNIPER
		loadout = ["Sniper Rifle", "SMG"],
	},
	{
		player_class = TF_CLASS_SPY
		loadout = ["Revolver", "Invis Watch", "Sapper"]
	},
]

minigame <- Ware_MinigameData
({
	name           = "Home-Run Contest"
	author         = "pokemonPasta"
	description    = "Home-Run Contest!"
	duration       = INT_MAX.tofloat() // going to always end manually. may reduce this a bit in case something breaks.
	location       = "homerun_contest"
	music          = "homerun_contest"
})

function OnPrecache()
{
	PrecacheModel(sandbag_model)
	
	for (local i = 1; i <= 5; i++)
		PrecacheSound(format("vo/announcer_begins_%dsec.mp3", i))
}

function OnStart()
{
	for (local ent; ent = FindByName(ent, "HomeRun_PodiumClip");)
		EntityAcceptInput(ent, "Enable")
	
	// TODO:
	// spawn a podium for each player
	// create a podium clip around each podium
	
	foreach(player in Ware_MinigamePlayers)
	{
		local player_class = player.GetPlayerClass()
		local loadout
		
		foreach(table in HomeRun_Loadouts)
		{
			if (table.player_class == player_class)
			{
				loadout = table.loadout
				break
			}
		}
		
		Ware_SetPlayerLoadout(player, player_class, loadout, {}, true)
		
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.sandbag <- SpawnEntityFromTableSafe("prop_physics_override", {
			model = sandbag_model,
			origin = player.GetOrigin() + Vector(0, 150, 40)
			angles = QAngle(0, -90, 0)
		})
		
		local sandbag = minidata.sandbag
		EntityAcceptInput(sandbag, "Sleep")
		sandbag.ValidateScriptScope()
		local scope = sandbag.GetScriptScope()
		scope.percent <- 0.0
		scope.player <- player // this might cause null reference issues if a player disconnects, maybe kill the sandbag if a player leaves?
		HomeRun_Sandbags.append(sandbag)
		
		Ware_ShowText(player, CHANNEL_MINIGAME, format("Sandbag: %.1f%%", scope.percent), Ware_GetMinigameRemainingTime())
	}
	
	local timer = 5
	Ware_CreateTimer(function()
	{
		Ware_ShowGlobalScreenOverlay(format("hud/tf2ware_ultimate/countdown_%d", timer))
		if (timer > 0)
			Ware_PlaySoundOnAllClients(format("vo/announcer_begins_%dsec.mp3", timer), 1.0, 100 * Ware_GetPitchFactor())
		
		timer--
		
		if (timer >= 0)
			return 1.0
		else
		{
			Ware_ShowGlobalScreenOverlay(null)
			
			for (local ent; ent = FindByName(ent, "HomeRun_PodiumClip");)
				EntityAcceptInput(ent, "Disable")
		}
	}, 5.0)
	
}

function OnTakeDamage(params)
{
	local ent = params.const_entity
	local inflictor = params.inflictor
	
	if (!inflictor.IsPlayer() || !inflictor.IsValid())
		return
	
	local sandbag = Ware_GetPlayerMiniData(inflictor).sandbag
	
	if (ent == sandbag)
	{
		local scope = sandbag.GetScriptScope()
		scope.percent += (params.damage * 0.1) + RandomFloat(-0.2, 0.2)
		local percent = scope.percent
		
		local melee_multiplier = (params.weapon && params.weapon.IsMeleeWeapon() && percent >= 100.0) ? 10.0 : 1.0
		
		printl("pre: " + params.damage_force)
		params.damage_force *= (((percent / 100.0) * Min(params.damage, percent * 0.09) * melee_multiplier))
		if (melee_multiplier == 10.0)
			params.damage_force.z = abs(params.damage_force.z)
		
		printl("post: " + params.damage_force)
		
		Ware_ShowText(inflictor, CHANNEL_MINIGAME, format("Sandbag: %.1f%%", percent), Ware_GetMinigameRemainingTime())
	}
	else if (inflictor == ent || inflictor == sandbag)
	{
		params.damage == 0.0
	}
}
