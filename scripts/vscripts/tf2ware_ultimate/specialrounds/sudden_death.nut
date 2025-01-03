special_round <- Ware_SpecialRoundData
({
	name             = "Sudden Death"
	author           = "ficool2"
	description      = "If you lose a minigame, you are out! Last survivor wins."
	min_players      = 3
})

ValidPlayers <- []

function OnStart()
{
	ValidPlayers = Ware_Players.filter(@(i, player) (player.GetTeam() & 2) != 0)
}

function OnMinigameCleanup()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		local idx = ValidPlayers.find(player)
		if (idx == null)
			continue

		if (!data.passed || !(player.GetTeam() & 2))
		{
			ValidPlayers.remove(idx)
			if (player.IsAlive())
				Ware_SuicidePlayer(player)
		}
	}
}

function OnCalculateTopScorers(top_players)
{
	local top_score = 1
	foreach (player in ValidPlayers)
	{
		local data = Ware_GetPlayerData(player)
		if (data.score > top_score)
		{
			top_score = data.score
			top_players.clear()
			top_players.append(player)
		}
		else if (data.score == top_score)
		{
			top_players.append(player)
		}	
	}
}

function OnCheckGameOver()
{
	return ValidPlayers.len() <= 1
}

function OnPlayerDisconnect(player)
{
	local idx = ValidPlayers.find(player)
	if (idx != null)
		ValidPlayers.remove(idx)
}

function CanPlayerRespawn(player)
{
	return ValidPlayers.find(player) != null
}

function GetValidPlayers()
{
	return ValidPlayers
}