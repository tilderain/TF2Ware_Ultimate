
simon <- RandomBool()

special_round <- Ware_SpecialRoundData
({
	name = "Simon Goes Crazy"
	author = "pokemonPasta"
	description = "Only do what Simon tells you to do."
	
	opposite_win = !simon
})

function OnStart()
{
	foreach(player in Ware_Players)
		Ware_GetPlayerSpecialRoundData(player).hint_shown <- false
}

function OnPlayerConnect(player)
{
	Ware_GetPlayerSpecialRoundData(player).hint_shown <- false
}

function OnBeginIntermission(is_boss)
{
	// do this early bcuz minigamestart happens after something that checks opposite_win
	simon <- RandomBool()
	special_round.opposite_win = !simon
	
	Ware_PlayGameSound(null, "intro")
	foreach (player in Ware_Players)
	{
		Ware_ShowScreenOverlay(player, null)
		Ware_ShowScreenOverlay2(player, null)
	}
		
	CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
}

function OnMinigameStart()
{
	local text = (simon ? "Simon" : "Someone") + " Says:"
	Ware_ShowText(Ware_Players, CHANNEL_MISC, text, Ware_GetMinigameRemainingTime(), "255 255 255", -1.0, 0.1)
}

function OnCalculateScore(data)
{
	if (simon == data.passed)
	{
		data.score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
		return
	}
	
	local player = data.player
	local special_data = Ware_GetPlayerSpecialRoundData(player)
	if (!simon)
	{
		local text = "{color}Simon didn't say \"{color}{str}{color}\"."
		if (!special_data.hint_shown)
		{
			text += "\n{color}HINT: {color}Only do what Simon tells you to do!"
			special_data.hint_shown = true
		}
		
		local description = Ware_Minigame.description
		if (typeof(description) == "array")
			description = description[Min(data.mission, description.len() - 1)]
		Ware_ChatPrint(player, text, TF_COLOR_DEFAULT, TF_COLOR_RED, description, TF_COLOR_DEFAULT, COLOR_GREEN, TF_COLOR_DEFAULT)
	}
}