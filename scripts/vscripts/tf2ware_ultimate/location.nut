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
	Teleport   = function()
	{
		local spawn_len = spawns.len();
		foreach (data in Ware_MinigamePlayers)
		{
			local spawn = spawns[spawn_idx];
			spawn_idx = (spawn_idx + 1) % spawn_len;
			data.player.Teleport(true, spawn.GetOrigin(), true, spawn.GetAbsAngles(), true, Vector());
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
	Teleport = function()
	{
		local inv = 360.0 / Ware_MinigamePlayers.len().tofloat();
		local i = 0;
		foreach (data in Ware_MinigamePlayers)
		{
			local angle = i++ * inv;
			local pos = Vector(
				center.x + radius * cos(angle * PI / 180.0),
				center.y + radius * sin(angle * PI / 180.0),
				center.z);
			local ang = QAngle(0.0, angle + 180.0, 0.0);
			
			data.player.Teleport(true, pos, true, ang, true, Vector());
		}
	}
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
	Teleport = function()
	{
		local width = 576;
		local offset = 65;
		local pos = Vector(0, center.y, center.z);
		local ang = QAngle(0, 90, 0);
		local row = 0;
		local max_row = 7;

		foreach (i, data in Ware_MinigamePlayers)
		{
			if (row > max_row)
			{
				pos.y -= offset;
				row = 0;
			}
			
			pos.x = center.x - (width * 0.5) + (row * offset);
			data.player.Teleport(true, pos, true, ang, true, Vector());
			row++;
		}
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
	Teleport = function()
	{
		local offset = 64.0;
		local pos = center * 1.0;
		local ang = QAngle(0, 90, 0);
		local x = 0;
		foreach (data in Ware_MinigamePlayers)
		{
			if (++x > 21)
			{
				pos.y += offset;
				x = 1;
			}
			
			pos.x = center.x + (x / 2) * ((x & 1) ? offset : -offset);
			data.player.Teleport(true, pos, true, ang, true, Vector());
		}
	}
};


Ware_Location.boxarena <-
{
	center   = Vector(-1792, 8192, -7135),
	mins     = Vector(-2736, 7248, -7135),
	maxs     = Vector(-832, 9152, -5552),
	radius   = 512.0,	
	Teleport = function()
	{
		local inv = 360.0 / Ware_MinigamePlayers.len().tofloat();
		local i = 0;
		foreach (data in Ware_MinigamePlayers)
		{
			local angle = i++ * inv;
			local pos = Vector(
				center.x + radius * cos(angle * PI / 180.0),
				center.y + radius * sin(angle * PI / 180.0),
				center.z);
			local ang = QAngle(0.0, angle + 180.0, 0.0);
			
			data.player.Teleport(true, pos, true, ang, true, Vector());
		}
	}
};