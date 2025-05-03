merasmus_health_per_player <- RemapValClamped(Ware_Players.len().tofloat(), 0.0, 24.0, 5500.0, 4000.0)
//~61 hits per player at 24 players, 84 hits per player at 0 players

special_round <- Ware_SpecialRoundData
({
	name = "Kill Merasmus"
	author = "tilderain"
	description = "Or else!"
	category = ""
	convars = 
	{
		tf_merasmus_lifetime = 999999
		tf_merasmus_chase_range = 10000000
		tf_merasmus_chase_duration = 10000000
		tf_merasmus_health_base = 200
		tf_merasmus_health_per_player = 0
	}
})

merasmus <- null
merasmus_killed <- false

merasmus_color <- "71b149"

function OnStart()
{
	CreateTimer(@() SpawnMerasmus(), 0.25)
	foreach (player in Ware_Players)
	{
		local special = Ware_GetPlayerSpecialRoundData(player)
		special.damage <- 0
	}
}

function GiveBonusPoints(target, points = 1)
{
	local award = true

	// even if there's no award, this is still tracked for the event	
	local player_indices_awarded = ""
	local awarded = target
	if (typeof(awarded) == "instance")
		awarded = [target]
	foreach (player in awarded)
		player_indices_awarded += player.entindex().tochar()
	
	if (award)
	{
		// account for multiple possible but we only got 1 player
		if (typeof(target) == "array" && target.len() == 1)
			target = target[0]
		
		if (typeof(target) == "instance")
		{
			local data = target.GetScriptScope().ware_data
			data.score += points
			data.bonus += points
			
			Ware_ChatPrint(null, "{color}{str}{color} was awarded an extra {str}!",
				TF_COLOR_RED, GetPlayerName(target), TF_COLOR_DEFAULT, points == 1 ? "point" : format("%d points", points))
		}
		else
		{
			local text = ""
			local params = [this, null, text]
			foreach (player in target)
			{
				local data = player.GetScriptScope().ware_data
				data.score += points
				data.bonus += points

				text += text == "" ? "The following players were each awarded an extra point: {player} " : " {player} "
				params.append(player)
			}
			text += "{color}!"
			params.append(TF_COLOR_DEFAULT)
			params[2] = text

			Ware_ChatPrint.acall(params)
		}
	}
	
	Ware_EventCallback("bonus_points", 
	{
		minigame_name      = "Kill Merasmus"
		minigame_file_name = "merasmus"
		players_awarded    = player_indices_awarded
	})
}

function OnUpdate()
{
	if (merasmus && !merasmus.IsValid() && !merasmus_killed)
	{
		merasmus_killed = true

		local playerDamageList = []

		foreach (player in Ware_Players) {
		    local special = Ware_GetPlayerSpecialRoundData(player)
			if(!"damage" in special)
				special.damage <- 0
		    playerDamageList.append({
		        player = player,
		        damage = special.damage
		    });
		}

		playerDamageList.sort(function(a, b) {
		    return b.damage <=> a.damage
		})

		for (local i = 0; i < 3 && i < playerDamageList.len(); i++) {
		    Ware_ChatPrint(null, "{player}{color} did {int} damage to {color}MERASMUS!", 
				playerDamageList[i].player, TF_COLOR_DEFAULT, playerDamageList[i].damage, merasmus_color)
		}

		local top3Players = []
		for (local i = 0; i < 3 && i < playerDamageList.len(); i++) {
		    top3Players.append(playerDamageList[i].player)
		}
		GiveBonusPoints(top3Players)

	}
}

function OnPrecache()
{
	PrecacheEntityFromTable({classname = "merasmus"})
}

function SpawnMerasmus()
{
	merasmus = SpawnEntityFromTableSafe("merasmus",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 0, 32),
		modelscale = 1,
		targetname = "merasmus_special"
	})
	
}

function OnMinigameStart()
{
	if (merasmus && merasmus.IsValid())
		merasmus.SetOrigin(Ware_MinigameLocation.center + Vector(0, 0, 32))
}

function OnMinigameEnd()
{
	if (merasmus && merasmus.IsValid())
		merasmus.SetOrigin(Ware_MinigameLocation.center + Vector(0, 0, 32))
}

function OnTakeDamage(params)
{
	local attacker = params.attacker
	if (params.const_entity.GetClassname() == "merasmus")
	{
		//spy op
		if(params.weapon && params.weapon.GetName() == "tf_weapon_knife")
			params.damage = 20
		if(params.damage > 200)
			params.damage = 20
		if(attacker && attacker.IsPlayer())
		{
			local special = Ware_GetPlayerSpecialRoundData(attacker)
			special.damage <- special.damage + params.damage
		}
	}
	else if (attacker && attacker.GetClassname() == "merasmus" && !Ware_Finished)
	{
		params.damage *= 0.33
	}
	else if (attacker && attacker.GetClassname() == "merasmus" && Ware_Finished)
	{
		params.damage *= 3
	}
}
function OnCalculateTopScorers(top_players)
{
	if(merasmus && merasmus.IsValid())
	{
		top_players.clear()
	}
	else
	{
		// do everything as normal
		local top_score = 1
		foreach (data in Ware_MinigamePlayersData)
		{
			if (data.score > top_score)
			{
				top_score = data.score
				top_players.clear()
				top_players.append(data.player)
			}
			else if (data.score == top_score)
			{
				top_players.append(data.player)
			}	
		}
	}

}

function OnDeclareWinners(top_players, top_score, winner_count)
{
	if(merasmus && merasmus.IsValid())
	{
		Ware_ChatPrint(null, "{color}MERASMUS!{color} wins!", merasmus_color, TF_COLOR_DEFAULT)
	}
	else
	{
		if (winner_count > 1)
		{
			Ware_ChatPrint(null, "{color}The winners each with {int} points:", TF_COLOR_DEFAULT, top_score)
			foreach (player in top_players)
				Ware_ChatPrint(null, "> {player} {color}!", player, TF_COLOR_DEFAULT)
		}
		else if (winner_count == 1)
		{
			Ware_ChatPrint(null, "{player} {color}won with {int} points!", top_players[0], TF_COLOR_DEFAULT, top_score)
		}	
		else if (winner_count == 0)
		{
			Ware_ChatPrint(null, "{color}Nobody won!?", TF_COLOR_DEFAULT)
		}
	}
}