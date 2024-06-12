
special_round <- Ware_SpecialRoundData
({
	name = "Thirdperson"
	author = "pokemonPasta"
	description = "See the game from a new perspective."
})


function OnStart()
{
	foreach (player in Ware_Players)
		player.SetForcedTauntCam(1)
}

function OnPostEndMinigameInternal()
{
	foreach (player in Ware_Players)
		player.SetForcedTauntCam(1)
}

function OnEnd()
{
	foreach (player in Ware_Players)
		player.SetForcedTauntCam(0)
}
