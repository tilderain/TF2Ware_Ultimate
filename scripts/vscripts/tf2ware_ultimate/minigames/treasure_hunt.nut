minigame <- Ware_MinigameData();
minigame.name = "Treasure Hunt";
minigame.duration = 25.0;
minigame.music = "undergroundbros";
minigame.no_collisions  = true;

local treasures =
[
	["beach", "Octopus", "octopus", "unusual_bubbles", "models/player/items/pyro/treasure_hat_oct.mdl",
		[
			Vector(2170.51, -94.5874, -271.395),
			Vector(2976.74, 174.691, -399.494),
			Vector(466.239, -977.024, -71.8184),
			Vector(2312.92, 945.426, -241.269),
			Vector(3268.91, -522.682, -415.319),
			Vector(3547.32, 773.357, -403.642),
			Vector(2184.68, -295.731, -332.245),
			Vector(2460.42, -124.22, -332.857),
		],
	],
	["manor", "Secret Diary", "secret_diary", "superrare_beams1", "models/player/items/all_class/hwn_spellbook_diary.mdl",
		[
			Vector(-2575.09, -115.668, 209.037),
			Vector(-2355.32, 649.124, -175.273),
			Vector(-1496.04, -793.31, -91.2257),
			Vector(-2271.69, -784.205, -106.629),
			Vector(-180.276, 669.594, -206.969),
			Vector(-3459.82, 356.595, -206.969),
		],
	],		
];

local debug_spawns = false;
local treasure_idx = RandomIndex(treasures);
treasure <- treasures[treasure_idx];

find_sound <- "MatchMaking.MedalClickRare";

minigame.location = treasure[0];
minigame.description = format("Find the %s!", treasure[1]);
minigame.custom_overlay = "treasure_hunt_" + treasure[2];

PrecacheModel(treasure[4]);
PrecacheScriptSound(find_sound);

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
		Ware_GivePlayerWeapon(data.player, "Grappling Hook");
	
	local position_list = treasure[5];
	if (!debug_spawns)
	{
		local origin = Ware_MinigameLocation.center + position_list[RandomIndex(position_list)];
		local prop = Ware_SpawnEntity("prop_dynamic",
		{
			origin = origin,
			model = treasure[4],
			modelscale = 2.0,
		});
		
		local particle = Ware_SpawnEntity("info_particle_system",
		{
			origin = origin,
			effect_name = treasure[3],
			start_active = true,
		});
		
		// TODO: make generic function
		local trigger = Ware_SpawnEntity("trigger_multiple",
		{
			origin = origin,
			spawnflags = 1,
		});		
		trigger.SetSolid(SOLID_BBOX);
		trigger.SetSize(prop.GetBoundingMins(), prop.GetBoundingMaxs());
		trigger.ValidateScriptScope();
		trigger.GetScriptScope().OnStartTouch <- OnTouchTreasure;
		trigger.ConnectOutput("OnStartTouch", "OnStartTouch");
	}
	else
	{
		foreach (position in position_list)
		{
			Ware_SpawnEntity("prop_dynamic",
			{
				origin = Ware_MinigameLocation.center + position,
				model = treasure[4],
				modelscale = 2.0,
			});	
		}
	}	
}

function OnTouchTreasure()
{
	local player = activator;
	if (player)
	{
		player.Teleport(true, Ware_Location.beach.center, true, QAngle(), true, Vector());
		Ware_ShowScreenOverlay(player, null);	
		Ware_CreateTimer(function()
			{
				if (player) 
				{
					player.EmitSound(Ware_MinigameScope.find_sound);
					Ware_PassPlayer(player, true);
					Ware_StripPlayer(player, true);
				}
			}, 0.1);
	}
}

function OnTeleport(players)
{
	if (Ware_MinigameLocation.name == "beach")
	{
		Ware_TeleportPlayersRow(players, 
			Ware_MinigameLocation.center, 
			QAngle(0, 0, 0), 
			1200.0, 
			64.0, 64.0);	
	}
	else if (Ware_MinigameLocation.name == "manor")
	{
		Ware_TeleportPlayersRow(players,
			Ware_MinigameLocation.center,
			QAngle(0, 180, 0),
			400.0,
			64.0, 64.0);
	}
}