minigame <- Ware_MinigameData
({
	name           = "Rocket Jump"
	author         = "ficool2"
	description    = "Get to the top!"
	duration       = 30.0
	end_delay      = 1.0
	location       = "rocketjump"
	music          = "steadynow"
	custom_overlay = "get_top"
	start_pass     = false
})

first <- true

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Rocket Jumper")
	
	// this gets very difficult with higher timescale so make the train start later
	EntFire("rocketjump_train", "StartForward", "", RemapValClamped(Ware_TimeScale, 1.0, 2.0, 3.0, 10.0))
}

function OnUpdate()
{
	local thresold = Ware_MinigameLocation.center.z + 2600.0
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (IsEntityAlive(player) && GetPropEntity(player, "m_hGroundEntity") != null)
		{
			local origin = player.GetOrigin()
			if (origin.z > thresold)
			{
				Ware_PassPlayer(player, true)
				
				if (first)
				{
					Ware_ChatPrint(null, "{player} {color}made it to the top first in {%.1f} seconds!",
						player, TF_COLOR_DEFAULT, Ware_GetMinigameTime())
					first = false
				}
			}
		}
	}
}

function OnCleanup()
{
	EntFire("rocketjump_train", "TeleportToPathTrack", "boss8_path")
	EntFire("rocketjump_train", "Stop")
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0
}