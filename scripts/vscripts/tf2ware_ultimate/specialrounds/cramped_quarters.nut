special_round <- Ware_SpecialRoundData
({
	name             = "Cramped Quarters"
	author           = ["Mecha the Slag", "ficool2"]
	description      = "Don't touch anyone!"
	category         = ""
	min_players      = 2
})

local touch_dmg = false

function OnPlayerTouch(player1, player2)
{
	if (Ware_Minigame || Ware_Finished)
	{
		touch_dmg = true	
		local truce = GetPropBool(GameRules, "m_bTruceActive")
		SetPropBool(GameRules, "m_bTruceActive", false)
		player1.TakeDamage(1000.0, DMG_BULLET, player2)
		SetPropBool(GameRules, "m_bTruceActive", truce)
		touch_dmg = false
		
		local color2 = player2.GetTeam() == TF_TEAM_RED ? TF_COLOR_RED : TF_COLOR_BLUE
		Ware_ChatPrint(player1, "You touched {color}{player}{color}!", color2, player2, TF_COLOR_DEFAULT)
	}
}

function OnTakeDamage(params)
{
	if (touch_dmg)
		params.force_friendly_fire = true
}