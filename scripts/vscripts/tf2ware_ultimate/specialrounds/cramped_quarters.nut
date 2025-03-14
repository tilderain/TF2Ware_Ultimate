special_round <- Ware_SpecialRoundData
({
	name             = "Cramped Quarters"
	author           = ["Mecha the Slag", "ficool2"]
	description      = "Don't touch anyone!"
	category         = ""
	min_players      = 2
})

function OnPlayerTouch(player1, player2)
{
	if (Ware_Minigame)
        player1.TakeDamage(1000.0, DMG_BULLET, player2)
}
