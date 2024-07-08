
special_round <- Ware_SpecialRoundData
({
	name = "Team Battles"
	author = "pokemonPasta"
	description = "Your score goes towards your team's score. The team with the highest score at the end wins!"
	min_players = 4 // 2 on each team minimum seems fair, could do min_players = 3 either maybe. minimum players of 2 is pointless.
})

red_score <- 0
blu_score <- 0

top_team <- null

function OnCalculateScore(data)
{
	if (data.passed)
	{
		if (data.player.GetTeam() == TF_TEAM_RED)
			red_score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
		else
			blu_score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
	}
}

function OnCalculateTopScorers(top_players, top_score,  winner_count)
{
	top_team = Max(red_score, blu_score) == red_score ? TF_TEAM_RED : TF_TEAM_BLUE
	
	foreach (data in Ware_MinigamePlayersData)
	{
		local player = data.player
		local team = player.GetTeam()
		
		if (team == TF_TEAM_RED)
			data.score = red_score
		else
			data.score = blu_score
			
		if (team == top_team || red_score == blu_score)
			top_players.append(player)
	}
}

function OnDeclareWinners(top_players)
{
	if (red_score == blu_score)
		Ware_ChatPrint(null, "The teams are tied at {int} points.", red_score)
	else
	{
		local red_won = top_team == TF_TEAM_RED
		
		local team   = red_won ? "RED TEAM" : "BLUE TEAM"
		local colour = red_won ? TF_COLOR_RED : TF_COLOR_BLUE
		local points = red_won ? red_score : blu_score
		
		Ware_ChatPrint(null, "{color}{str} {color}won with {int} points!", colour, team, TF_COLOR_DEFAULT, points)
	}
}