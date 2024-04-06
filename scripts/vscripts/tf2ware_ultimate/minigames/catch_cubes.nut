minigame <- Ware_MinigameData();
minigame.name = "Catch the Cubes";
minigame.description = "Catch the cubes!"
minigame.duration = 14.0;
minigame.location = "boxarena";
minigame.music = "cozy";

cube_model  <- "models/props/metal_box.mdl";
touch_sound <- "Player.HitSoundSpace";
PrecacheModel(cube_model);
PrecacheScriptSound(touch_sound);

spawn_rate <- RemapValClamped(Ware_MinigamePlayers.len().tofloat(), 0.0, 32.0, 1.0, 0.02);

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, RandomInt(0, 1) ? "Sun-on-a-Stick" : "Candy Cane");
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.AddCond(TF_COND_SPEED_BOOST);
		Ware_GetPlayerMiniData(player).points <- 0;
	}
		
	Ware_CreateTimer(@() CreateCube(), 0.5);
}

function CreateCube()
{
	local origin = Vector(
		RandomFloat(Ware_MinigameLocation.mins.x + 200.0, Ware_MinigameLocation.maxs.x - 200.0),
		RandomFloat(Ware_MinigameLocation.mins.y + 200.0, Ware_MinigameLocation.maxs.y - 200.0),
		Ware_MinigameLocation.center.z + 300.0);
	
	local cube = Ware_SpawnEntity("prop_physics", 
	{
		origin = origin,
		model  = cube_model
	});
	
	local trigger = Ware_SpawnEntity("trigger_multiple",
	{
		classname = "passtime_pass",
		origin = origin,
		spawnflags = 1
	});
	SetEntityParent(trigger, cube);
	trigger.SetSolid(SOLID_BBOX);
	trigger.SetSize(cube.GetBoundingMins() * 1.3, cube.GetBoundingMaxs() * 1.3);
	trigger.ValidateScriptScope();
	trigger.GetScriptScope().OnStartTouch <- OnCubeTouch;
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch");
		
	return spawn_rate;
}

function OnCubeTouch()
{
	if (self.IsValid() && activator)
	{
		activator.EmitSound(Ware_MinigameScope.touch_sound);

		if (++Ware_GetPlayerMiniData(activator).points >= 3)	
			Ware_PassPlayer(activator, true);
			
		self.GetMoveParent().Kill();
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
		data.player.RemoveCond(TF_COND_SPEED_BOOST);
}