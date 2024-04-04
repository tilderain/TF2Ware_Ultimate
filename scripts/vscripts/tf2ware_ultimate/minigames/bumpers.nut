local bump_sound = "BumperCar.BumpIntoAir";
PrecacheScriptSound(bump_sound);

minigame <- Ware_MinigameData();
minigame.name = "Bumpers"
minigame.description = "Bump into others!"
minigame.duration = 4.5;
minigame.location = "circlepit";
minigame.music = "actfast";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.fail_on_death = true;
minigame.convars = 
{
	sv_gravity = 2000,
	tf_avoidteammates = 0
};

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null);
	foreach (data in Ware_Players)
		data.player.AddCond(TF_COND_SPEED_BOOST);
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_FALL)
		params.damage *= 5.0;
}

function OnUpdate()
{
	local candidates = [];
	local bloat_maxs = Vector(0.05, 0.05, 0.05);
	local bloat_mins = bloat_maxs * -1.0;
	
	foreach (data in Ware_Players)
	{
		local player = data.player;
		if (IsEntityAlive(player))
		{
			local origin = player.GetOrigin();
			candidates.append(
			[
				player, 
				origin + player.GetBoundingMins() + bloat_mins, 
				origin + player.GetPlayerMaxs() + bloat_maxs
			]);
		}
	}
	
	local intersections = {};
	local candidates_len = candidates.len();
	for (local i = 0; i < candidates_len; ++i)
	{
		local candidate_a = candidates[i];
		if (candidate_a in intersections)
			continue;
		
		for (local j = i + 1; j < candidates_len; ++j)
		{
			local candidate_b = candidates[j];
			if (candidate_b in intersections)
				continue;
			
			if (IntersectBoxBox(candidate_a[1], candidate_a[2], candidate_b[1], candidate_b[2]))
			{
				local player_a = candidate_a[0];
				local player_b = candidate_b[0];			
				intersections[player_a] <- player_b;
				intersections[player_b] <- player_a;
			}
		}
	}
	
	foreach (player, other_player in intersections)
	{
		other_player.EmitSound(bump_sound);
		other_player.SetAbsVelocity(other_player.GetAbsVelocity() + Vector(0, 0, 600));
		Ware_PushPlayerFromOther(other_player, player, 600.0);
	}
}

function OnEnd()
{
	foreach (data in Ware_Players)
		data.player.RemoveCond(TF_COND_SPEED_BOOST);
}