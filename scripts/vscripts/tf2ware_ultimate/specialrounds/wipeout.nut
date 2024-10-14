
// TODO: More testing/fixes when players join or leave mid-round
// TODO: Make spectators more interesting (use actual spectating stuff?)


// wipeout description found at https://wiki.teamfortress.com/wiki/TF2Ware

player_thresholds <- [
	[8, 40],
	[7, 35],
	[6, 30],
	[5, 20], // 5 players at 20 alive or higher
	[4, 10], // 4 players at 10 or higher
	[3,  3], // etc
	[2,  0]
]

Wipeout_PlayerRotation <- []
Wipeout_ValidPlayers <- []
Wipeout_Spectators <- []

special_round <- Ware_SpecialRoundData
({
	name = "Wipeout"
	author = "pokemonPasta"
	description = "3 lives, battle in smaller groups until one player remains!" // TODO: better description
	
	min_players = 3
	
	boss_count     = INT_MAX
	boss_threshold = INT_MAX
})

function OnStart()
{
	foreach(player in Ware_Players)
	{
		local data = Ware_GetPlayerSpecialRoundData(player)
		data.lives <- 3
		
		Ware_GetPlayerData(player).score = data.lives
	}
}

function OnPlayerConnect(player)
{
	local data = Ware_GetPlayerSpecialRoundData(player)
	data.lives <- 0
}

function OnPlayerSpawn(player)
{
	local data = Ware_GetPlayerSpecialRoundData(player)
	if (!("lives" in data))
		data.lives <- 0
}

function OnPlayerDisconnect(player)
{
	foreach(arr in [Wipeout_Spectators, Wipeout_ValidPlayers, Wipeout_PlayerRotation])
	{
		local idx = arr.find(player)
		if (idx != null)
			arr.remove(idx)
	}
}

function OnTakeDamage(params)
{
	local arr = Wipeout_Spectators
	if (arr.find(params.const_entity) != null || arr.find(params.inflictor) != null)
		params.damage = 0.0
}

function OnBeginIntermission(is_boss)
{
	Wipeout_ValidPlayers <- []
	Wipeout_Spectators <- []
	local player_count
	foreach(threshold in player_thresholds)
	{
		if (Wipeout_GetAlivePlayers().len() >= threshold[1])
		{
			player_count = threshold[0]
			break
		}
	}
	
	while (Wipeout_ValidPlayers.len() < player_count)
	{
		if (Wipeout_PlayerRotation.len() > 0)
		{
			local player = RemoveRandomElement(Wipeout_PlayerRotation)
			if ((player.GetTeam() & 2) && player.IsAlive())
			{
				Wipeout_ValidPlayers.append(player)
			}
		}
		else
			Wipeout_PlayerRotation <- Wipeout_GetAlivePlayers()
	}
	
	foreach(player in Ware_Players)
	{
		if (Wipeout_ValidPlayers.find(player) == null)
			Wipeout_Spectators.append(player)
	}
	
	local holdtime = Ware_GetThemeSoundDuration("intro")
	local player_list = []
	local spectator_text = format("This %s players are:\n", is_boss ? "bossgame's" : "minigame's")
	
	foreach(player in Wipeout_ValidPlayers)
	{
		player_list.append(player)
		spectator_text += GetPlayerName(player)
		spectator_text += "\n"
	}
	
	Ware_PlayGameSound(null, "intro")
	foreach (player in Ware_Players)
	{
		Ware_ShowScreenOverlay(player, null)
		Ware_ShowScreenOverlay2(player, null)
		
		local lives = Ware_GetPlayerSpecialRoundData(player).lives
		if (Wipeout_ValidPlayers.find(player) != null)
		{
			local text = "Get ready! Your opponents are:\n"
			
			foreach(ent in player_list)
			{
				if (ent != player)
				{
					text += GetPlayerName(ent)
					text += "\n"
				}
			}
			
			text += format("You have %d %s remaining.", lives, lives == 1 ? "life" : "lives")
			Ware_ShowText(player, CHANNEL_MISC, text, holdtime)
		}
		if (Wipeout_Spectators.find(player) != null)
		{
			local text = spectator_text + (lives > 0 ? "Please wait for your turn." : "You are out of lives and cannot continue.")
			Ware_ShowText(player, CHANNEL_MISC, text, holdtime)
		}
	}
		
	CreateTimer(@() Ware_StartMinigame(is_boss), holdtime)
}

function GetValidPlayers()
{
	return Wipeout_ValidPlayers
}

function Wipeout_GetAlivePlayers()
{
	local alive_players = []
	
	foreach(player in Ware_Players)
	{
		local data = Ware_GetPlayerSpecialRoundData(player)
		if (data.lives && data.lives > 0)
			alive_players.append(player)
	}
	
	return alive_players
}

function OnCalculateScore(data)
{
	local specialdata = Ware_GetPlayerSpecialRoundData(data.player)
	
	if (!data.passed)
		specialdata.lives--
	
	specialdata.lives = Max(0, specialdata.lives)
	
	data.score = specialdata.lives
}

function OnMinigameEnd()
{
	switch (Wipeout_GetAlivePlayers().len()) {
		case 2:
			special_round.boss_threshold = 0
			break
		case 1:
			special_round.boss_threshold = 0
			special_round.boss_count = 0
			break
		case 0:
			special_round.boss_count = INT_MAX
			foreach(player in Ware_MinigamePlayers)
			{
				local data = Ware_GetPlayerSpecialRoundData(player)
				data.lives <- 1
			}
			break
	}
	
	foreach(player in Wipeout_Spectators)
	{
		Ware_PlayGameSound(player, "victory") // there's just a weird silence without this
	}
}

function OnDeclareWinners(top_players, top_score, winner_count)
{
	if (winner_count > 1)
	{
		Ware_ChatPrint(null, "{color}The winners each with {int} lives remaining:", TF_COLOR_DEFAULT, top_score) // NOTE: this should never happen
		foreach (player in top_players)
			Ware_ChatPrint(null, "> {player} {color}!", player, TF_COLOR_DEFAULT)
	}
	else if (winner_count == 1)
	{
		Ware_ChatPrint(null, "{player} {color}won with {int} lives remaining!", top_players[0], TF_COLOR_DEFAULT, top_score)
	}	
	else if (winner_count == 0)
	{
		Ware_ChatPrint(null, "{color}Nobody won!?", TF_COLOR_DEFAULT)
	}
}