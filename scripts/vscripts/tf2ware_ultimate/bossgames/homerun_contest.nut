
// TODO:
// - make damage -> percent better (bit low atm?)
// - make percent -> knockback a lot better
// - add dispensers to podiums
// - set up podiums/podium clips for >1 player

sandbag_model <- "models/tf2ware_ultimate/sandbag.mdl"
HomeRun_Sandbags <- []

minigame <- Ware_MinigameData
({
	name           = "Home-Run Contest"
	author         = "pokemonPasta"
	description    = "Home-Run Contest!"
	duration       = INT_MAX.tofloat() // going to always end manually. may reduce this a bit in case something breaks.
	location       = "homerun_contest"
	music          = "homerun_contest"
	convars        =
	{
		tf_fastbuild = 1
	}
})

function OnPrecache()
{
	PrecacheModel(sandbag_model)
	
	for (local i = 1; i <= 5; i++)
		PrecacheSound(format("vo/announcer_begins_%dsec.mp3", i))
}

function OnTeleport(players)
{
	foreach(player in players)
	{
		local data = Ware_GetPlayerData(player)
		data.keep_weapons = true
		player.ForceRegenerateAndRespawn()
		data.keep_weapons = false
	}
	
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center
		QAngle(0, 90, 0),
		0.0
		0.0, 0.0)
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
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.sandbag <- SpawnEntityFromTableSafe("prop_physics_override", {
			model = sandbag_model,
			origin = player.GetOrigin() + Vector(0, 150, 40),
			angles = QAngle(0, -90, 0),
			massscale = 5
		})
		
		local sandbag = minidata.sandbag
		EntityAcceptInput(sandbag, "Sleep")
		sandbag.ValidateScriptScope()
		local scope = sandbag.GetScriptScope()
		scope.percent <- 0.0
		scope.player <- player // this might cause null reference issues if a player disconnects, maybe kill the sandbag if a player leaves?
		HomeRun_Sandbags.append(sandbag)
		
		Ware_ShowText(player, CHANNEL_MINIGAME, "Sandbag: 0.0%", Ware_GetMinigameRemainingTime())
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

function IsASentry(ent)
{
	return ent.GetClassname() == "obj_sentrygun"
}

function OnTakeDamage(params)
{
	// TODO: Account for projectiles
	
	local ent = params.const_entity
	local inflictor = params.inflictor
	
	if (!(inflictor.IsPlayer() && inflictor.IsValid()) &&
		!IsASentry(inflictor))
		return
	
	local player
	if (IsASentry(inflictor))
	{
		player = GetPropEntity(inflictor, "m_hBuilder")
	}
	else
	{
		player = inflictor
	}
	
	local sandbag = Ware_GetPlayerMiniData(player).sandbag
	
	if (ent == sandbag)
	{
		local scope = sandbag.GetScriptScope()
		scope.percent += (params.damage * 0.3) + RandomFloat(-0.2, 0.2)
		local percent = scope.percent
		
		local melee_multiplier = (params.weapon && params.weapon.IsMeleeWeapon() && percent >= 100.0) ? percent / 10 : 1.0
		
		printl("pre: " + params.damage_force)
		params.damage_force *= ((percent / 10.0) * melee_multiplier)
		params.damage_force.z = fabs(params.damage_force.z)
		
		printl("post: " + params.damage_force)
		
		Ware_ShowText(player, CHANNEL_MINIGAME, format("Sandbag: %.1f%%", percent), Ware_GetMinigameRemainingTime())
	}
	else if (inflictor == ent || inflictor == sandbag || IsASentry(inflictor))
	{
		params.damage == 0.0
	}
}

function OnGameEvent_player_builtobject(params)
{
	local building = EntIndexToHScript(params.index)
	if (!building)
		return
		
	SetPropInt(building, "m_nDefaultUpgradeLevel", 2)
}
