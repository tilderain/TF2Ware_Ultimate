
simon <- RandomInt(0, 1)

special_round <- Ware_SpecialRoundData
({
	name = "Simon Goes Crazy"
	author = "pokemonPasta"
	description = "Only do what Simon tells you to do."
	
	opposite_win = !simon
})

function OnBeginIntermission(is_boss)
{
	// do this early bcuz minigamestart happens after something that checks opposite_win
	simon <- RandomInt(0, 1)
	special_round.opposite_win = !simon
	
	foreach (player in Ware_Players)
		{
			Ware_PlayGameSound(player, "intro")
			Ware_ShowScreenOverlay(player, null)
			Ware_ShowScreenOverlay2(player, null)
		}
		
	CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
}

function OnMinigameStart()
{
	local text = (simon ? "Simon" : "Someone") + " Says:"
	
	// todo: make new channel?
	Ware_ShowText(Ware_Players, CHANNEL_MINIGAME, text, Ware_GetMinigameRemainingTime(), "255 255 255", -1.0, 0.12)
}

function OnCalculateScore(data)
{
	if (simon == data.passed)
		data.score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
}