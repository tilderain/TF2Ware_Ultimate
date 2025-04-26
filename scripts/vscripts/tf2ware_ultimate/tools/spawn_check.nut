local location = Ware_Location.love
local player_count = 100
local copy_player = Ware_ListenHost

if ("ghosts" in this)
{
	foreach (ghost in ghosts)
		if (ghost.IsValid())
			ghost.Kill()
}
ghosts <- []

for (local i = 0; i < player_count; i++)
{
	local ghost = SpawnEntityFromTableSafe("prop_dynamic_override",
	{
		model       = copy_player.GetModelName()
		modelscale  = copy_player.GetModelScale()
		rendermode  = kRenderTransColor
		rendercolor = "255 0 0"		
	})
	ghosts.append(ghost)
}

if (1)
{
	location.Teleport(ghosts)
}
else
{
	Ware_TeleportPlayersRow(ghosts,
		location.center_right,
		QAngle(0, 90, 0),
		400.0,
		-50.0, 33.0)	
}

local stuck = 0
foreach (ghost in ghosts)
{
	local trace = 
	{
		start   = ghost.GetOrigin()
		end     = ghost.GetOrigin()
		hullmin = copy_player.GetBoundingMins()
		hullmax = copy_player.GetBoundingMaxs()
		mask    = MASK_PLAYERSOLID
		ignore  = ghost
	}
	TraceHull(trace)
	if (trace.hit)
	{
		SetEntityColor(ghost, 255, 0, 0, 255)
		stuck++
	}
	else
	{
		SetEntityColor(ghost, 255, 255, 255, 255)
	}
}

Ware_ChatPrint(copy_player, "{int} players stuck", stuck)