special_round <- Ware_SpecialRoundData
({
	name             = "Invisible Problem"
	author           = "ficool2"
	description      = "Everyone is invisible!"
	category         = ""
})

function OnUpdate()
{
	foreach (player in Ware_Players)
		player.AddCond(TF_COND_STEALTHED_USER_BUFF_FADING)
}