special_round <- Ware_SpecialRoundData
({
	name = "Double Trouble"
	author = "ficool2"
	description = "Two special rounds will be stacked together!"
	category = "meta"
})

special_round_scope_a <- null
special_round_scope_b <- null

function OnPick()
{
	local categories = clone(Ware_SpecialRoundCategories)
	// don't include ourself...
	if ("meta" in categories)
		delete categories.meta
		
	local special_rounds = []
	foreach (category, file_names in categories)
	{
		foreach (file_name in file_names)
			special_rounds.append({category = category, file_name = file_name})
	}

	local pick_a, pick_b

	local player_count = Ware_GetValidPlayers().len()
	local max_count = Min(16, special_rounds.len())
	for (local i = 0; i <  max_count; i++)
	{
		pick_a = RemoveRandomElement(special_rounds)
		local scope = Ware_LoadSpecialRound(pick_a.file_name, player_count, false)
		if (scope)
		{
			special_round_scope_a = scope
			break
		}
	}
	
	if (!special_round_scope_a)
		return false
		
	max_count = Min(32, special_rounds.len())
	for (local i = 0; i < max_count; i++)
	{
		pick_b = RemoveRandomElement(special_rounds)
		if (pick_b.category != "none" && pick_b.category == pick_a.category)
			continue
		
		local scope = Ware_LoadSpecialRound(pick_b.file_name, player_count, false)
		if (scope)
		{
			special_round_scope_b = scope
			break
		}
	}
	
	if (!special_round_scope_b)
		return false
		
	foreach (callback_name, func in delegated_callbacks)
	{
		if (callback_name in special_round_scope_a || callback_name in special_round_scope_b)
			this[callback_name] <- func.bindenv(this)
	}
	delete delegated_callbacks
	
	local data = special_round
	local data_a = special_round_scope_a.special_round
	local data_b = special_round_scope_b.special_round
	
	foreach (name, value in data_a.convars) data.convars[name] <- value
	foreach (name, value in data_b.convars) data.convars[name] <- value
	data.reverse_text = data_a.reverse_text || data_b.reverse_text
	data.allow_damage = data_a.allow_damage || data_b.allow_damage
	data.force_collisions = data_a.force_collisions || data_b.force_collisions
	data.opposite_win = data_a.opposite_win || data_b.opposite_win
	data.friendly_fire = data_a.friendly_fire && data_b.friendly_fire
	data.bonus_points = data_a.bonus_points || data_b.bonus_points
	// choose whichever one has non-default value
	data.boss_count = data_a.boss_threshold != data.boss_count ? data_a.boss_count : data_b.boss_count
	data.boss_threshold = data_a.boss_threshold != data.boss_threshold ? data_a.boss_threshold : data_b.boss_threshold
	data.speedup_threshold = data_a.speedup_threshold != data.speedup_threshold ? data_a.speedup_threshold : data_b.speedup_threshold
	
	return true
}

function GetName()
{
	return format("%s\n-> %s\n-> %s\n", 
		special_round.name, 
		special_round_scope_a.special_round.name
		special_round_scope_b.special_round.name)	
}

function OnStartInternal() 
{
	Ware_ChatPrint(null, "{color}{color}{str}{color}! {str}", TF_COLOR_DEFAULT, COLOR_GREEN, special_round_scope_a.special_round.name, 
		TF_COLOR_DEFAULT,  special_round_scope_a.special_round.description)
	Ware_ChatPrint(null, "{color}{color}{str}{color}! {str}", TF_COLOR_DEFAULT, COLOR_GREEN, special_round_scope_b.special_round.name, 
		TF_COLOR_DEFAULT, special_round_scope_b.special_round.description)	
}

OnStart <- OnStartInternal // might get overriden below

// call the function only if it exists in that scope
local call_failed
function DelegatedCall(scope, name, ...)
{
	call_failed = false
	if (name in scope)
	{
		vargv.insert(0, scope)
		return scope[name].acall(vargv)
	}
	call_failed = true
}

delegated_callbacks <-
{
	function OnStart()
	{
		OnStartInternal()
		
		DelegatedCall(special_round_scope_a, "OnStart")
		DelegatedCall(special_round_scope_b, "OnStart")
	}

	function OnUpdate()
	{
		DelegatedCall(special_round_scope_a, "OnUpdate")
		DelegatedCall(special_round_scope_b, "OnUpdate")
	}

	function OnEnd()
	{
		DelegatedCall(special_round_scope_a, "OnEnd")
		DelegatedCall(special_round_scope_b, "OnEnd")
	}

	function GetOverlay2()
	{
		// take first valid result
		local ret = DelegatedCall(special_round_scope_a, "GetOverlay2")
		if (ret == null)
			ret = DelegatedCall(special_round_scope_b, "GetOverlay2")	
		return ret
	}

	function GetMinigameName(is_boss)
	{
		local ret = DelegatedCall(special_round_scope_a, "GetMinigameName", is_boss)
		if (ret == null)
			ret = DelegatedCall(special_round_scope_b, "GetMinigameName", is_boss)	
		return ret
	}

	function OnMinigameStart()
	{
		DelegatedCall(special_round_scope_a, "OnMinigameStart")
		DelegatedCall(special_round_scope_b, "OnMinigameStart")
	}

	function OnMinigameEnd()
	{
		DelegatedCall(special_round_scope_a, "OnMinigameEnd")
		DelegatedCall(special_round_scope_b, "OnMinigameEnd")
	}

	function OnMinigameCleanup()
	{
		DelegatedCall(special_round_scope_a, "OnMinigameCleanup")
		DelegatedCall(special_round_scope_b, "OnMinigameCleanup")
	}

	function OnBeginIntermission(is_boss)
	{
		// return true if either one wants to override logic
		local ret_a = DelegatedCall(special_round_scope_a, "OnBeginIntermission", is_boss)
		local ret_b = DelegatedCall(special_round_scope_b, "OnBeginIntermission", is_boss) 
		return ret_a || ret_b
	}

	function OnSpeedup()
	{
		local ret_a = DelegatedCall(special_round_scope_a, "OnSpeedup")
		local ret_b = DelegatedCall(special_round_scope_b, "OnSpeedup")
		return ret_a || ret_b
	}
	
	function OnBeginBoss()
	{
		local ret_a = DelegatedCall(special_round_scope_a, "OnBeginBoss")
		local ret_b = DelegatedCall(special_round_scope_b, "OnBeginBoss") 
		return ret_a || ret_b
	}
	
	function OnCheckGameOver()
	{
		// if either one returns true then it's game over
		local ret_a = DelegatedCall(special_round_scope_a, "OnCheckGameOver")
		local ret_b = DelegatedCall(special_round_scope_b, "OnCheckGameOver") 
		return ret_a || ret_b
	}

	function GetValidPlayers()
	{
		// these cannot overlap so don't run two instances
		local ret = DelegatedCall(special_round_scope_a, "GetValidPlayers")
		if (call_failed)
			ret = DelegatedCall(special_round_scope_b, "GetValidPlayers")	
		return ret
	}

	function OnCalculateScore(data)
	{
		DelegatedCall(special_round_scope_a, "OnCalculateScore", data)
		if (call_failed)
			DelegatedCall(special_round_scope_b, "OnCalculateScore", data)	
	}

	function OnCalculateTopScorers(top_players)
	{
		DelegatedCall(special_round_scope_a, "OnCalculateTopScorers", top_players)
		if (call_failed)
			DelegatedCall(special_round_scope_b, "OnCalculateTopScorers", top_players)	
	}

	function OnDeclareWinners(top_players, top_score, winner_count)
	{
		DelegatedCall(special_round_scope_a, "OnDeclareWinners", top_players, top_score, winner_count)
		if (call_failed)
			DelegatedCall(special_round_scope_b, "OnDeclareWinners", top_players, top_score, winner_count)
	}

	function OnPlayerConnect(player)
	{
		DelegatedCall(special_round_scope_a, "OnPlayerConnect", player)
		DelegatedCall(special_round_scope_b, "OnPlayerConnect", player)
	}

	function OnPlayerDisconnect(player)
	{
		DelegatedCall(special_round_scope_a, "OnPlayerDisconnect", player)
		DelegatedCall(special_round_scope_b, "OnPlayerDisconnect", player)
	}

	function OnPlayerSpawn(player)
	{
		DelegatedCall(special_round_scope_a, "OnPlayerSpawn", player)
		DelegatedCall(special_round_scope_b, "OnPlayerSpawn", player)
	}

	function OnPlayerInventory(player)
	{
		DelegatedCall(special_round_scope_a, "OnPlayerInventory", player)
		DelegatedCall(special_round_scope_b, "OnPlayerInventory", player)
	}

	function GetPlayerRoll(player)
	{
		// take first successful call
		local ret = DelegatedCall(special_round_scope_a, "GetPlayerRoll", player)
		if (call_failed)
			ret = DelegatedCall(special_round_scope_b, "GetPlayerRoll", player)	
		return ret
	}

	function CanPlayerRespawn(player)
	{
		// only respawn if both agree
		// if the function doesn't exist then assume it's allowed
		local ret_a = DelegatedCall(special_round_scope_a, "CanPlayerRespawn", player)
		if (call_failed)
			ret_a = true
		local ret_b = DelegatedCall(special_round_scope_b, "CanPlayerRespawn", player)	
		if (call_failed)
			ret_b = true		
		return ret_a && ret_b
	}

	function OnTakeDamage(params)
	{
		// cancel damage if either one explicitly returns false
		local ret_a = DelegatedCall(special_round_scope_a, "OnTakeDamage", params)
		local ret_b = DelegatedCall(special_round_scope_b, "OnTakeDamage", params)
		if (ret_a == false || ret_b == false)
			return false
	}
}