minigame <- Ware_MinigameData
({
	name          = "Mandrill Escape"
	author        = "ficool2"
	description   = "Escape the Mandrill Maze!"
	duration      = 82.0
	end_delay     = 1.0
	location      = "mandrill"
	music         = "mandrill"
	start_pass    = false
	fail_on_death = true
})

banana_model <- "models/tf2ware_ultimate/banana.mdl"

function OnPrecache()
{
	PrecacheModel(banana_model)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null)
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		player.SetCustomModel(banana_model)
		Ware_TogglePlayerWearables(player, false)
		player.AddCondEx(TF_COND_SPEED_BOOST, 6.2, null)
	}
	
	EntFire("mandrill_train", "SetSpeed", "150")
}

function OnUpdate()
{
	local threshold = Ware_MinigameLocation.start.x - 13300.0
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (IsEntityAlive(player) && player.GetOrigin().x < threshold)
			Ware_PassPlayer(player, true)
	}
}

function OnEnd()
{
	EntFire("mandrill_train", "TeleportToPathTrack", "camp_move1")
	EntFire("mandrill_train", "Stop", "150")
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		player.SetCustomModel("")
		Ware_TogglePlayerWearables(player, true)
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0
}