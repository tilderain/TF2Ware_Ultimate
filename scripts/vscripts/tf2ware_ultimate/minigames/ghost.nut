minigame <- Ware_MinigameData();
minigame.name = "Don't Get Scared";
minigame.description = "Don't get scared!"
minigame.duration = 13.3;
minigame.music = "bliss";
minigame.start_pass = true;

function OnStart()
{
	Ware_CreateTimer(@() SpawnGhost(), 1.2);
	Ware_CreateTimer(@() SpawnGhost(), 3.0);
}

function OnGameEvent_player_stunned(params)
{
	local victim = GetPlayerFromUserID(params.victim);
	if (victim)
	{
		Ware_PassPlayer(victim, false);
		
		// fix a TF2 bug where the weapon doesn't re-appear
		CreateTimer(function() 
		{ 
			local weapon = victim.GetActiveWeapon();
			if (weapon)
				weapon.EnableDraw();
		}
		2.5);
	}
}

function SpawnGhost()
{
	Ware_SpawnEntity("ghost",
	{
		origin = Vector(
				RandomFloat(Ware_MinigameLocation.mins.x + 200.0, Ware_MinigameLocation.maxs.x - 200.0),
				RandomFloat(Ware_MinigameLocation.mins.y + 200.0, Ware_MinigameLocation.maxs.y - 200.0),
				Ware_MinigameLocation.center.z + RandomFloat(300.0, 500)),
		angles = QAngle(0, RandomFloat(-180, 180), 0),	
	});
}