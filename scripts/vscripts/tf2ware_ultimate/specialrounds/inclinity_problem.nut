special_round <- Ware_SpecialRoundData
({
	name = "Inclinity Problem"
	author = "ficool2"
	description = "The world has tilted!"
})

function OnStart()
{
	printl("OnStart");
	
	foreach (player in Ware_Players)
	{
		if (IsEntityAlive(player))
		{
			local eye_angles = player.EyeAngles()
			eye_angles.z = GetPlayerRollAngle(player)
			player.SnapEyeAngles(eye_angles)
		}
	}
}

function GetPlayerRollAngle(player)
{
	return 40.0
}
