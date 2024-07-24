minigame <- Ware_MinigameData
({
	name           = "Rocket Jump"
	author         = "ficool2"
	description    = "Get to the top!"
	duration       = 37.0
	end_delay      = 1.0
	location       = "rocketjump"
	music          = "steadynow"
	custom_overlay = "get_top"
	start_pass     = false
	
	allow_scale = false
})

first <- true

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Rocket Jumper")
	
	// this gets very difficult with higher timescale so make the train start later
	EntFire("rocketjump_train", "StartForward", "", RemapValClamped(Ware_GetTimeScale(), 1.0, 2.0, 3.0, 10.0))
}

function OnUpdate()
{
	local thresold = Ware_MinigameLocation.center.z + 2600.0
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.IsAlive() && GetPropEntity(player, "m_hGroundEntity") != null)
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
	local alive_count = Ware_GetAlivePlayers().len()
	return alive_count == 0 || Ware_GetPassedPlayers(true).len() == alive_count
}