minigame <- Ware_MinigameData
({
	name        = "Parachute"
	author      = "ficool2"
	description = "Land on the Platform!"
	duration    = 6.0
	location    = "boxarena"
	music       = "dizzy"
	thirdperson = true
	convars     = 
	{
		tf_parachute_deploy_toggle_allowed = 1
	}
})

platform <- null

platform_model <- "models/props_coldfront/waste_base.mdl"
PrecacheModel(platform_model)

function OnTeleport(players)
{
	Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center + Vector(0, 0, 1400), 768.0)
}

function OnStart()
{
	local player_class = RandomInt(0, 1) ? TF_CLASS_SOLDIER : TF_CLASS_DEMOMAN
	Ware_SetGlobalLoadout(player_class, "B.A.S.E. Jumper", {}, true)
	
	platform = Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 0, 286),
		model = platform_model,
		solid = SOLID_VPHYSICS,
	})
	
	Ware_CreateTimer(@() AutodeployParachutes(), 1.1)
}

function AutodeployParachutes()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (!player.InCond(TF_COND_PARACHUTE_ACTIVE))
		{
			EmitSoundOnClient("Parachute_open", player)
			player.AddCond(TF_COND_PARACHUTE_ACTIVE)
		}
	}
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (GetPropEntity(player, "m_hGroundEntity") == platform)
			Ware_PassPlayer(player, true)
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
		data.player.RemoveCond(TF_COND_PARACHUTE_ACTIVE)
}