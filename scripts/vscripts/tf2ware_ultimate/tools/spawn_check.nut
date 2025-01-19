local location = Ware_Location.sawrun
local player_count = 40
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

location.Teleport(ghosts)

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