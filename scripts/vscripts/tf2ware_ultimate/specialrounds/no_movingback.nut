special_round <- Ware_SpecialRoundData
({
	name = "No Moving Forward"
	author = ["ficool2", "tilderain"]
	description = "Enshittification is the only option!"	
	category = ""
})

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (GetPropInt(player, "m_nButtons") & IN_FORWARD)
			player.AddFlag(FL_ATCONTROLS)
		else
			player.RemoveFlag(FL_ATCONTROLS)
	}
}