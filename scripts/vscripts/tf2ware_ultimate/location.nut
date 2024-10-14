// by ficool2

// Stores list of locations
// Each location shares these in common:
// - "Init()" function
// -- Called when the map starts, allows locations to setup their own data
// - "Teleport(players)" function
// -- Executed when players are about to be teleported into this location
// - "cameras" array
// -- Optional list info_observer_point names associated with the location
//    These are automatically enabled/disabled
Ware_Location <- {}

// Internal use only
Ware_LocationParent <-
{
	function DebugDraw()
	{
		DebugDrawLine(center, center + Vector(0, 0, 32), 0, 0, 255, true, 10.0)
		if ("mins" in this && "maxs" in this)
			DebugDrawBox(Vector(), mins, maxs, 255, 0, 0, 50, 10.0)
	}
}

// == Locations ==

Ware_Location.home <-
{
	center     = Vector(-512, 760, -512)
	mins       = Vector(-896, 376, -512)
	maxs       = Vector(-128, 1144, 3550)
	cameras    = ["home_camera"]
	spawns     = []
	spawn_name = "home_spawns"
	spawn_idx  = 0
	Init       = function()
	{
		for (local spawn; spawn = FindByName(spawn, spawn_name);)
		{
			MarkForPurge(spawn)
			spawns.append(spawn)
		}
	}
	Teleport   = function(players)
	{
		local spawn_len = spawns.len()
		foreach (player in players)
		{
			local spawn = spawns[spawn_idx]
			spawn_idx = (spawn_idx + 1) % spawn_len
			Ware_TeleportPlayer(player, spawn.GetOrigin(), spawn.GetAbsAngles(), vec3_zero)
		}
	}
}

Ware_Location.home_big <-
{
	center     = Vector(1688, 1560, -864)
	mins       = Vector(946, 820, -864)
	maxs       = Vector(2428, 2298, 3198)
	cameras    = ["home_big_camera"]
	spawns     = []
	spawn_name = "home_big_spawns"
	spawn_idx  = 0
	Init       = Ware_Location.home.Init
	Teleport   = Ware_Location.home.Teleport
}

Ware_Location.circlepit <-
{
	center   = Vector(-1952, -872, 720)
	radius   = 288.0
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius) }
}

Ware_Location.circlepit_big <-
{
	center   = Vector(-3304, 2400, 1056)
	radius   = 512.0
	Teleport = Ware_Location.circlepit.Teleport
}

Ware_Location.sawrun <-
{
	center   = Vector(4480, -3900, -4495)
	Teleport = function(players) 
	{
		Ware_TeleportPlayersRow(players,
			center - Vector(40, 0, 0),
			QAngle(0, 90, 0),
			480.0,
			-50.0, 50.0)
	}
}

Ware_Location.targetrange <-
{
	left     = Vector(2303, -5340, -3999)
	right    = Vector(2303, -2450, -3999)
	cameras  = ["targetrange_camera1", "targetrange_camera2"]
	lines	 = 
	[
		[Vector(2400, -4056, -3999), Vector(2944, -4056, -3999)],
		[Vector(1536, -4056, -3999), Vector(2080, -4056, -3999)],
		[Vector(2016, -3896, -3999), Vector(2560, -3896, -3999)],
		[Vector(2496, -3712, -3999), Vector(3040, -3712, -3999)],
		[Vector(1536, -3712, -3999), Vector(2080, -3712, -3999)],
	]
	Teleport = function(players)
	{
		local red_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_RED)
		local blue_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_BLUE)	
		local left_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)
		
		if (left_team == TF_TEAM_RED)
			TeleportSides(red_players, blue_players)
		else
			TeleportSides(blue_players, red_players)
	}
	TeleportSides = function(players_left, players_right)
	{
		local PlaceSide = function(players, origin, angles, y_offset)
		{
			local x_offset = 80.0
			local pos = origin * 1.0
			local x = 0
			foreach (player in players)
			{
				if (++x > 20)
				{
					pos.y += y_offset
					x = 1
				}
				
				pos.x = origin.x + (x / 2) * ((x & 1) ? x_offset : -x_offset)
				Ware_TeleportPlayer(player, pos, angles, vec3_zero)
			}		
		}
		
		
		PlaceSide(players_left, left, QAngle(0, 90, 0), 80.0)
		PlaceSide(players_right, right, QAngle(0, 270, 0), -80.0)	
	}
}

Ware_Location.boxarena <-
{
	center   = Vector(-1792, 8192, -7135)
	mins     = Vector(-2736, 7248, -7135)
	maxs     = Vector(-832, 9152, -5552)
	radius   = 512.0
	cameras  = ["boxarena_camera"]
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius) }
}

Ware_Location.beach <-
{
	center   = Vector(4400, 6668, -3790)
	mins     = Vector(4112, 5656, -4200)
	maxs     = Vector(8192, 7680, -3296)
	cameras  = ["beach_camera"]
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center, 
			QAngle(), 
			1000.0, 
			64.0, 64.0)
	}
}

Ware_Location.manor <-
{
	center  	  = Vector(8048, -6440, -3615)
	lobby		  = Vector(6048, -5516, -3822)
}

Ware_Location.pinball <-
{
	center_top    = Vector(-3840, -5344, -5679)
	center_bottom = Vector(-3840, 1984, -7599)
	cameras       = ["pinball_camera"]
}

Ware_Location.factoryplatform <-
{
	center        = Vector(4208, 1664, -5215)
	center_left   = Vector(3708, 1664, -5271)
	center_right  = Vector(4700, 1664, -5271)
}

Ware_Location.love <-
{
	center_left    = Vector(6160, -984, -5919)
	center_right   = Vector(6160, -2200, -5919)
	cameras        = ["love_camera"]
}

Ware_Location.kart_containers <-
{
	center         = Vector(-1200, 3450, -6718)
	cameras        = ["kartcontainers_camera"]
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center,
			QAngle(0, 180, 0),
			900.0,
			128.0, 128.0)
	}
}

Ware_Location.kart_paths <-
{
	center_left    = Vector(-7095, -5300, -6046)
	center_right   = Vector(-6520, -5300, -6046)
	angles         = QAngle(0, 90, 0)
	width          = 380.0
	spacing        = 100.0
	Teleport = function(players)
	{
		local red_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_RED)
		local blue_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_BLUE)
		
		local left_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)
		
		if (left_team == TF_TEAM_RED)
		{
			Ware_TeleportPlayersRow(red_players, center_left, angles, width, spacing, spacing)
			Ware_TeleportPlayersRow(blue_players, center_right, angles, width, spacing, spacing)
		}
		else
		{
			Ware_TeleportPlayersRow(blue_players, center_left, angles, width, spacing, spacing)
			Ware_TeleportPlayersRow(red_players, center_right, angles, width, spacing, spacing)
		}
	}
	
}

Ware_Location.kart_ramp <-
{
	center   = Vector(-7000, -10400, -6494)
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center,
			QAngle(0, 90, 0),
			1500.0,
			200.0, 100.0)
	}
}

Ware_Location.frogger <-
{
	center   = Vector(11488, -6150, -6447)
	cameras  = ["frogger_camera1", "frogger_camera2", "frogger_camera3"]
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center,
			QAngle(0, 90, 0),
			400.0,
			-50.0, 50.0)
	}
}

Ware_Location.sumobox <-
{
	center   = Vector(-4600, -9500, -6142)
	radius   = 400
	cameras  = ["sumobox_camera"]
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius) }
}

Ware_Location.mandrill <-
{
	start    = Vector(2274, -13562, -5343)
	maze     = Vector(-3584, -14720, -5344)
	cameras  = ["mandrill_camera"]
	Teleport = function(players)
	{
		foreach (player in players)
			Ware_TeleportPlayer(player, start, QAngle(0, 180, 0), vec3_zero)
	}
}

Ware_Location.rocketjump <-
{
	center   = Vector(128, -3344, -7392)
	radius   = 400
	cameras  = ["rocketjump_camera"]
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius) }
}

Ware_Location.rocketjump2 <-
{
	center = Vector(1940, 4780, -6490)
	radius = 400
	Teleport = function(players) { Ware_TeleportPlayersCircle(players, center, radius) }
}

Ware_Location.hexplatforms <-
{
	center      = Vector(2304, -8448, -4880)
	cameras     = ["hexplatforms_camera"]
	plat_models = []
	Init        = function()
	{
		for (local plat; plat = FindByName(plat, "hexplatforms_pillar*");)
		{
			MarkForPurge(plat)
			plat_models.append(plat.GetModelName())
			plat.Kill()
		}	
	}
	Teleport = function(players) 
	{ 
		// Handled by minigame because of dynamic pillars
	}
}

Ware_Location.dirtsquare <-
{
	center      = Vector(1648, -1776, -511)
	camaeras    = ["dirtsquare_camera"]
	Teleport = function(players) 
	{ 
		// TODO
	}	
}

Ware_Location.jumprope <-
{
	center      = Vector(80, -1008, -4959)
	Teleport = function(players) 
	{ 
		local red_players  = players.filter(@(i, player) player.GetTeam() == TF_TEAM_RED)
		local blue_players = players.filter(@(i, player) player.GetTeam() == TF_TEAM_BLUE)
		local center_left  = center + Vector(0, 300, 0)
		local center_right = center + Vector(0, -300, 0)
		local width   = 700.0
		local spacing = 60.0
		Ware_TeleportPlayersRow(red_players, center_left, QAngle(0, 270, 0), width, spacing, spacing)
		Ware_TeleportPlayersRow(blue_players, center_right, QAngle(0, 90, 0), width, spacing, spacing)
	}	
}

Ware_Location.obstaclecourse <-
{
	center      = Vector(-1696, -4068, -3927)
	cameras     = ["obstaclecourse_camera"]
	Teleport = function(players) 
	{ 
		// highest scoring players start last
		Ware_TeleportPlayersRow(Ware_GetSortedScorePlayers(false), center, QAngle(0, 90, 0), 600.0, -60.0, 60.0)
	}	
}

Ware_Location.ballcourt <-
{
	left        = Vector(5792, -3064, -7199)
	right       = Vector(5792, -1278, -7199)
	cameras     = ["basketball_camera", "basketball_camera2"]
	Teleport = function(players) 
	{ 
		local players_left = players.slice(0, players.len() / 2)
		local players_right = players.slice(players.len() / 2)
		local width = 1200.0
		Ware_TeleportPlayersRow(players_left, left, QAngle(0, 90, 0), width, -60.0, 59.0)
		Ware_TeleportPlayersRow(players_right, right, QAngle(0, 270, 0), width, 60.0, 59.0)
	}	
}

Ware_Location.beepblockskyway_micro <-
{
	center = Vector(-13285, -14570, -9760)
	cameras = ["Beatblock_Camera1", "Beatblock_Camera2", "Beatblock_Camera3"	]
	Teleport = function(players)
	{
		// highest scoring players start last
		Ware_TeleportPlayersRow(Ware_GetSortedScorePlayers(true), center, QAngle(0, 90, 0), 450, 90, 80)
	}
}

Ware_Location.beepblockskyway_ultimate <-
{
	center = Vector(-8960, -13500, -9760)
	cameras = ["Beatblock_Camera4", "Beatblock_Camera5", "Beatblock_Camera6"]
	Teleport = function(players)
	{	
		// highest scoring players start last
		Ware_TeleportPlayersRow(Ware_GetSortedScorePlayers(true), center, QAngle(0, 90, 0), 900, 120, 110)
	}
}

Ware_Location.warehouse <-
{
	center = Vector(1000, 11280, -4159)
	mins   = Vector(480, 11664, -4160)
	maxs   = Vector(1560, 12592, -3648)
	cameras = ["warehouse_camera"]
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players, 
			center,
			QAngle(0, 90, 0),
			900.0,
			64.0, 64.0)
	}	
}

Ware_Location.homerun_contest <-
{
	center = Vector(-12128, -5470, -14207)
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players,
			center
			QAngle(0, 90, 0),
			0.0,
			0.0, 0.0)
	}
}

Ware_Location.factory <-
{
	center = Vector(4300, 2450, -6205)
	Teleport = function(players)
	{
		Ware_TeleportPlayersRow(players,
			center
			QAngle(0.0, 180.0, 0.0),
			400.0,
			40.0, 80.0)
	}
}

Ware_Location.typing <-
{
	cameras = ["DRBoss_CloseupCamera_Point", "DRBoss_DescentCamera_Point", "DRBoss_SpiralCamera_Point"]
}

// == Teleport helpers ==

// Place the given array of players in a circle
function Ware_TeleportPlayersCircle(players, origin, radius)
{
	local inv = 360.0 / players.len().tofloat()
	local i = 0
	foreach (player in players)
	{
		local angle = i++ * inv
		local pos = Vector(
			origin.x + radius * cos(angle * PI / 180.0),
			origin.y + radius * sin(angle * PI / 180.0),
			origin.z)
		local ang = QAngle(0.0, angle + 180.0, 0.0)
		Ware_TeleportPlayer(player, pos, ang, vec3_zero)
	}
}

// Place the given array of players in a rectangular formation
function Ware_TeleportPlayersRow(players, origin, angles, max_width, offset_horz, offset_vert)
{
	// TODO should make this work for non-cardinal axes
	local axis_horz = (angles.y == 0.0 || fabs(angles.y) == 180.0) ? "x" : "y"
	local axis_vert = axis_horz == "x" ? "y" : "x"
	
	local center = origin * 1.0
	local reset = center[axis_vert]
	local accum = 0.0
	foreach (player in players)
	{
		if (accum >= max_width)
		{
			center[axis_vert] = reset
			center[axis_horz] += offset_horz
			accum = 0.0
		}
		
		center[axis_vert] = origin[axis_vert] - max_width * 0.5 + accum
		Ware_TeleportPlayer(player, center, angles, vec3_zero)
		accum += offset_vert
	}	
}
