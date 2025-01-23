minigame <- Ware_MinigameData
({
	name        = "Don't Get Scared"
	author      = ["TonyBaretta", "ficool2"]
	description = "Don't get scared!"
	duration    = 13.3
	music       = "bliss"
	start_pass  = true
})

function OnPrecache()
{
	PrecacheEntityFromTable({classname = "ghost"})
}

function OnStart()
{
	Ware_CreateTimer(@() SpawnGhost(), 1.2)
	Ware_CreateTimer(@() SpawnGhost(), 3.0)

	if (Ware_MinigameLocation.name.find("big") != null)
	{
		Ware_CreateTimer(@() SpawnGhost(), 1.6)
		Ware_CreateTimer(@() SpawnGhost(), 2.4)
	}
}

function OnGameEvent_player_stunned(params)
{
	local victim = GetPlayerFromUserID(params.victim)
	if (victim)
	{
		Ware_PassPlayer(victim, false)
		
		// fix a TF2 bug where the weapon doesn't re-appear
		CreateTimer(function() 
		{ 
			if (victim.IsValid())
			{
				local weapon = victim.GetActiveWeapon()
				if (weapon)
					weapon.EnableDraw()
			}
		}, 2.5)
	}
}

function SpawnGhost()
{
	local ghost = Ware_SpawnEntity("ghost",
	{
		origin = Vector(
				RandomFloat(Ware_MinigameLocation.mins.x + 200.0, Ware_MinigameLocation.maxs.x - 200.0),
				RandomFloat(Ware_MinigameLocation.mins.y + 200.0, Ware_MinigameLocation.maxs.y - 200.0),
				Ware_MinigameLocation.center.z + RandomFloat(800.0, 1000.0)),
		angles = QAngle(0, RandomFloat(-180, 180), 0),	
	})
	ghost.ValidateScriptScope()
	ghost.GetScriptScope().GhostThink <- function()
	{
		// makes the ghost not look jittery
		self.FlagForUpdate(true)
		return 0.05
	}
	AddThinkToEnt(ghost, "GhostThink")
}