//merasmus_health_per_player <- RemapValClamped(Ware_MinigamePlayers.len().tofloat(), 0.0, 5500.0, 24.0, 2500.0)

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
		tf_merasmus_health_base = 5500 * Ware_Players.len()
		tf_merasmus_health_per_player = 0
	}
})

merasmus <- null

function OnStart()
{
	CreateTimer(@() SpawnMerasmus(), 0.25)
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
		Ware_ChatPrint(null, "{color}MERASMUS!{color} wins!", "71b149", TF_COLOR_DEFAULT)
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