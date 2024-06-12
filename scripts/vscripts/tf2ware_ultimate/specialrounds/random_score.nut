
special_round <- Ware_SpecialRoundData
({
	name = "Randomized Scores"
	author = "pokemonPasta"
	description = "Each minigame will be worth a random amount of points."
})

// TODO: replace this with a global function
local ShowText = function(str, holdtime)
{
	Ware_TextManagerQueue.push(
		{ 
			message  = str
			color    = "255 255 255"
			holdtime = holdtime
			x		 = -1.0
			y        = 0.3
		})
		
	EntityEntFire(Ware_TextManager, "FireUser1")
	foreach (data in Ware_MinigamePlayers)
		EntFireByHandle(Ware_TextManager, "Display", "", -1, data.player, null)
	EntityEntFire(Ware_TextManager, "FireUser2")
}

random_score <- 0

function OnBeginIntermission(is_boss)
{
	random_score = RandomInt(1, 20)
	if (RandomInt(0, 19) == 0)
		random_score *= -1
	
	ShowText(format("The next minigame will be worth %d point%s.", random_score, random_score == 1 ? "" : "s"), Ware_GetThemeSoundDuration("intro"))
	
	foreach (player in Ware_Players)
	{
		Ware_PlayGameSound(player, "intro")
		Ware_ShowScreenOverlay(player, null)
		Ware_ShowScreenOverlay2(player, null)
	}
	
	CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
}

function OnCalculateScores(data, player, highest_score, highest_players)
{
	if (data.passed)
	{
		data.score += random_score
	}
		
	if (data.score > highest_score)
	{
		highest_score = data.score
		highest_players.clear()
		highest_players.append(player)
	}
	else if (data.score == highest_score)
	{
		highest_players.append(player)
	}
	
	return highest_players
}