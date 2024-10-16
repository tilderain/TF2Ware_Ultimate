	minigame <- Ware_MinigameData
({
	name        = "Parachute"
	author      = "ficool2"
	description = "Land on the Platform!"
	duration    = 7.0
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

function OnPrecache()
{
	PrecacheModel(platform_model)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center + Vector(0, 0, 1400), 768.0)
}

function OnStart()
{
	local player_class = RandomBool() ? TF_CLASS_SOLDIER : TF_CLASS_DEMOMAN
	Ware_SetGlobalLoadout(player_class, "B.A.S.E. Jumper", {}, true)
	
	platform = Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 0, 286),
		model = platform_model,
		solid = SOLID_VPHYSICS,
	})
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (GetPropEntity(player, "m_hGroundEntity") == platform)
			Ware_PassPlayer(player, true)
	}
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
		player.RemoveCond(TF_COND_PARACHUTE_ACTIVE)
}