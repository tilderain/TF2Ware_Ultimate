function Ware_TeleportPlayersCircle(players, origin, radius)
{
	local inv = 360.0 / players.len().tofloat();
	local i = 0;
	foreach (player in players)
	{
		local angle = i++ * inv;
		local pos = Vector(
			origin.x + radius * cos(angle * PI / 180.0),
			origin.y + radius * sin(angle * PI / 180.0),
			origin.z);
		local ang = QAngle(0.0, angle + 180.0, 0.0);
		player.Teleport(true, pos, true, ang, true, Vector());
	}
}

function Ware_TeleportPlayersRow(players, origin, angles, max_width, offset_horz, offset_vert)
{
	// TODO should make this work for non-cardinal axes
	local axis_horz = (angles.y == 0.0 || fabs(angles.y) == 180.0) ? "x" : "y";
	local axis_vert = axis_horz == "x" ? "y" : "x";
	
	local center = origin * 1.0;
	local reset = center[axis_vert];
	local accum = 0.0;
	foreach (player in players)
	{
		if (accum >= max_width)
		{
			center[axis_vert] = reset;
			center[axis_horz] += offset_horz;
			accum = 0.0;
		}
		
		center[axis_vert] = origin[axis_vert] - max_width * 0.5 + accum;
		player.Teleport(true, center, true, angles, true, Vector());
		accum += offset_vert;
	}	
}

Ware_Location <- {};

Ware_LocationParent <-
{
	function DebugDraw()
	{
		DebugDrawLine(center, center + Vector(0, 0, 32), 0, 0, 255, true, 10.0);
		if ("mins" in this && "maxs" in this)
			DebugDrawBox(Vector(), mins, maxs, 255, 0, 0, 50, 10.0);
	}
};

Ware_Location.home <-
{
	center     = Vector(-512, 760, -512), 
	mins       = Vector(-896, 376, -512),
	maxs       = Vector(-128, 1144, 3550),
	spawns     = [],
	spawn_name = "home_spawns",
	spawn_idx  = 0,
	Init       = function()
	{
		for (local spawn; spawn = FindByName(spawn, spawn_name);)
		{
			MarkForPurge(spawn);
			spawns.append(spawn);
		}
	}
	Teleport   = function(players)
	{
		local spawn_len = spawns.len();
		foreach (player in players)
		{
			local spawn = spawns[spawn_idx];
			spawn_idx = (spawn_idx + 1) % spawn_len;
			player.Teleport(true, spawn.GetOrigin(), true, spawn.GetAbsAngles(), true, Vector());
		}
	}
};

Ware_Location.home_big <-
{
	center     = Vector(1688, 1560, -864), 
	mins       = Vector(946, 820, -864),
	maxs       = Vector(2428, 2298, 3198),
	spawns     = [],
	spawn_name = "home_big_spawns",
	spawn_idx  = 0,
	Init       = Ware_Location.home.Init,
	Teleport   = Ware_Location.home.Teleport,
};

Ware_Location.circlepit <-
{
	center   = Vector(-1952, -872, 720),
	radius   = 288.0,
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius); }
};

Ware_Location.circlepit_big <-
{
	center   = Vector(-3304, 2400, 1056),
	radius   = 512.0,
	Teleport = Ware_Location.circlepit.Teleport,
};

Ware_Location.sawrun <-
{
	center   = Vector(4480, -3900, -4495),
	Teleport = function(players) 
	{
		Ware_TeleportPlayersRow(players,
			center - Vector(40, 0, 0),
			QAngle(0, 90, 0),
			512.0,
			-50.0, 50.0);
	}
};

Ware_Location.targetrange <-
{
	center   = Vector(2303, -5340, -3999),
	lines	 = 
	[
		[Vector(1535, -4023, -3999), Vector(2080, -4023, -3999)],
		[Vector(1535, -3735, -3999), Vector(2080, -3735, -3999)],
		[Vector(2015, -3896, -3999), Vector(2560, -3896, -3999)],
		[Vector(2400, -4023, -3999), Vector(2944, -4023, -3999)],
		[Vector(2495, -3656, -3999), Vector(3040, -3656, -3999)],
	],
	Teleport = function(players)
	{
		local offset = 64.0;
		local pos = center * 1.0;
		local ang = QAngle(0, 90, 0);
		local x = 0;
		foreach (player in players)
		{
			if (++x > 21)
			{
				pos.y += offset;
				x = 1;
			}
			
			pos.x = center.x + (x / 2) * ((x & 1) ? offset : -offset);
			player.Teleport(true, pos, true, ang, true, Vector());
		}
	}
};

Ware_Location.boxarena <-
{
	center   = Vector(-1792, 8192, -7135),
	mins     = Vector(-2736, 7248, -7135),
	maxs     = Vector(-832, 9152, -5552),
	radius   = 512.0,	
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius); }
};

Ware_Location.beach <-
{
	center   = Vector(4400, 6668, -3790),
	mins     = Vector(4112, 5656, -4200),
	maxs     = Vector(8192, 7680, -3296),	
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center, 
			QAngle(), 
			1000.0, 
			64.0, 64.0);
	}
};

Ware_Location.manor <-
{
	center  	  = Vector(8048, -6440, -3615),
	lobby		  = Vector(6048, -5516, -3822),
};

Ware_Location.pinball <-
{
	center_top    = Vector(-3840, -5344, -5679),
	center_bottom = Vector(-3840, 1984, -7599),
};

Ware_Location.factoryplatform <-
{
	center        = Vector(4208, 1664, -5215),
	center_left   = Vector(3708, 1664, -5271),
	center_right  = Vector(4700, 1664, -5271),
}

Ware_Location.love <-
{
	center_left    = Vector(6160, -984, -5919),
	center_right   = Vector(6160, -2200, -5919),
}

Ware_Location.kart_containers <-
{
	center         = Vector(-1200, 3450, -6718),
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center,
			QAngle(0, 180, 0),
			900.0,
			128.0, 128.0);
	}
}

Ware_Location.kart_paths <-
{
	center_left    = Vector(-7100, -5100, -6046),
	center_right   = Vector(-6550, -5100, -6046),
	radius         = 150.0,
	Teleport = function(players)
	{
		local red_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_RED);
		local blue_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_BLUE);
		
		local left_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);
		
		if (left_team == TF_TEAM_RED)
		{
			Ware_TeleportPlayersCircle(red_players, center_left, radius);
			Ware_TeleportPlayersCircle(blue_players, center_right, radius);
		}
		else
		{
			Ware_TeleportPlayersCircle(blue_players, center_left, radius);
			Ware_TeleportPlayersCircle(red_players, center_right, radius);
		}
	}
	
}

Ware_Location.kart_ramp <-
{
	center         = Vector(-7000, -10400, -6494),
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center,
			QAngle(0, 90, 0),
			1500.0,
			200.0, 100.0);
	}
}
