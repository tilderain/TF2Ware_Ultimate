minigame <- Ware_MinigameData
({
	name           = "Watch your Fall"
	author         = "ficool2"
	description    = "Deploy your Parachute!"
	music          = "falling"
	duration       = 4.0
	end_delay      = 0.5
	location       = "sumobox"
	custom_overlay = "deploy_parachute"
	start_pass     = true
	fail_on_death  = true
	thirdperson    = true
	start_freeze   = 0.5
	convars        =
	{
		sv_gravity = RemapValClamped(Ware_TimeScale, 1.0, 2.0, 700.0, 270.0)
	}
})

function OnStart()
{
	local player_class = RandomBool() ? TF_CLASS_SOLDIER : TF_CLASS_DEMOMAN
	Ware_SetGlobalLoadout(player_class, "B.A.S.E. Jumper", {}, true)
	
	foreach (player in Ware_MinigamePlayers)
		player.SetHealth(1)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center + Vector(0, 0, 800), 500.0)
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
		player.RemoveCond(TF_COND_PARACHUTE_ACTIVE)
}