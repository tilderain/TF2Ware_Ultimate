
max_scale <- 2.0

topscore_scale <- 1.1
scale_increase <- max_scale / Ware_BossThreshold

special_round <- Ware_SpecialRoundData
({
	name = "Size Matters"
	author = "pokemonPasta"
	description = "Your size will change to reflect your score!"
})

function OnCalculateTopScorers(top_players)
{
	topscore_scale += scale_increase
	
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
	
	// also resize everyone
	foreach(data in Ware_PlayersData)
	{
		local player = data.player
		Ware_SetPlayerScale(player, RemapValClamped(data.score, 0.0, top_score, 0.5, topscore_scale), 0.5)
	}
	
	CreateTimer(function(){
		foreach(player in Ware_Players)
			if (player.IsAlive() && player.GetModelScale() > 1.0)
				Unstuck(player)
	}, 0.6)
}

// TODO: After fixes, eventually generalize this and add to util.nut
function Unstuck(player)
{
	local normal_vectors = [
		Vector(1, 0, 0) // x
		Vector(0, 1, 0) // y
		Vector(1, 1, 0) // x+y
		Vector(1, -1, 0) // x-y
	]
	
	local radius = 30.0
	local origin = player.GetOrigin()
	local scale = player.GetModelScale()
	local mins = Vector(-radius, -radius, 0)
	local maxs = Vector(radius, radius, 83)
	local nudge_factor = radius*scale - radius
	
	mins *= scale
	maxs *= scale
	
	// do a trace to see if they're stuck at all
	local trace = {
		start = origin
		end = origin
		hullmin = mins
		hullmax = maxs
		mask = MASK_SOLID_BRUSHONLY
		ignore = player
	}
	
	// DebugDrawBox(trace.start, trace.hullmin, trace.hullmax, 255, 255, 255, 15, 10)
	TraceHull(trace)
	
	if (!trace.hit)
		return false
	
	player.SetAbsVelocity(vec3_zero)
	
	// only then trace each vector twice
	foreach(vec in normal_vectors)
	{
		vec *= nudge_factor
		
		trace.start = origin + vec
		trace.end = origin + vec
		
		// DebugDrawBox(trace.start, trace.hullmin, trace.hullmax, 255, 255, 255, 100, 30)
		TraceHull(trace)
		if (!trace.hit)
		{
			Ware_TeleportPlayer(player, trace.endpos, null, null)
			return true
		}
		
		trace.start = origin - vec
		trace.end = origin - vec
		
		// DebugDrawBox(trace.start, trace.hullmin, trace.hullmax, 255, 255, 255, 100, 30)
		TraceHull(trace)
		if (!trace.hit)
		{
			Ware_TeleportPlayer(player, trace.endpos, null, null)
			return true
		}
	}
	
	Ware_Error("No free spot found to unstuck %s", GetPlayerName(player))
}
