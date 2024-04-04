Ware_LocationParent <-
{
	function DebugDraw()
	{
		DebugDrawLine(center, center + Vector(0, 0, 32), 0, 0, 255, true, 10.0);
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
		local idx = 0;
		local spawn_len = spawns.len();
		foreach (data in Ware_Players)
		{
			local spawn = spawns[idx];
			idx = (idx + 1) % spawn_len;
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
	Init       = Ware_Location.home.Init,
	Teleport   = Ware_Location.home.Teleport,
};

Ware_Location.circlepit <-
{
	center   = Vector(-1952, -872, 720),
	mins     = Vector(),
	maxs     = Vector(),
	radius   = 288.0,
	Teleport = function()
	{
		local inv = 360.0 / Ware_Players.len().tofloat();
		local i = 0;
		foreach (data in Ware_Players)
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
	mins     = Vector(),
	maxs     = Vector(),
	radius   = 512.0,
	Teleport = Ware_Location.circlepit.Teleport,
};

Ware_Location.sawrun <-
{
	center   = Vector(4480, -3900, -4495),
	mins     = Vector(),
	maxs     = Vector(),
	Teleport = function()
	{
		local width = 576;
		local offset = 65;
		local pos = Vector(0, center.y, center.z);
		local ang = QAngle(0, 90, 0);
		local row = 0;
		local max_row = 7;

		foreach (i, data in Ware_Players)
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