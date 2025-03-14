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
	{
        local color2 = player2.GetTeam() == TF_TEAM_RED ? TF_COLOR_RED : TF_COLOR_BLUE
		
		player1.TakeDamage(1000.0, DMG_BULLET, player2)
		
		Ware_ChatPrint(player1, "You touched {color}{player}{color}!", color2, player2, TF_COLOR_DEFAULT)
	}
}
