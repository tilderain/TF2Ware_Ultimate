minigame <- Ware_MinigameData
({
	name          = "Mandrill Maze"
	author        = "ficool2"
	description   = "Escape the Mandrill Maze!"
	duration      = 83.0
	end_delay     = 1.5
	location      = "mandrill"
	music         = "mandrill"
	start_pass    = false
	fail_on_death = true
})

banana_model <- "models/tf2ware_ultimate/banana.mdl"

first <- true

function OnPrecache()
{
	PrecacheModel(banana_model)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null)
	
	foreach (player in Ware_MinigamePlayers)
	{
		player.SetCustomModel(banana_model)
		Ware_TogglePlayerWearables(player, false)
	}
	
	EntFire("mandrill_train", "StartForward")
	
	local block = FindByName(null, "mandrill_block")
	local block_model = block.GetModelName()
	local block_size = 256.0
	
	local maze = GenerateMaze(21, 13, 4, 10)
	local maze_origin = Ware_MinigameLocation.maze * 1.0
	maze_origin.x += block_size * 0.5
	maze_origin.y += block_size * 0.5

	foreach (y, row in maze)
	{
		foreach (x, cell in row)
		{
			//print(cell + " ")	
			if (cell == "#")
			{
				local block_pos = maze_origin * 1.0
				block_pos.x += block_size * x
				block_pos.y += block_size * y
				
				Ware_SpawnEntity("func_brush",
				{
					origin         = block_pos
					model          = block_model
					disableshadows = true
				})
			}
		}
		//print("\n")
	}
}

function GenerateMaze(width, height, start_y, end_y) 
{
	// S start
	// E end
	// # wall
	// . empty
	local maze = array(height)
	for (local y = 0; y < height; y++) 
		maze[y] = array(width, "#")

	local directions = 
	[
		{x = 0,  y = -1}, // up
		{x = 0,  y =  1}, // down
		{x = -1, y =  0}, // left
		{x = 1,  y =  0}  // right
	]

	// depth-first search
	function carve_path(x, y, last_dir) 
	{
		maze[y][x] = "."
		// try random directions on each attempt
		foreach (dir in Shuffle(clone(directions)))
		{
			local nx = x + dir.x * 2
			local ny = y + dir.y * 2
			// check within bounds and not visited
			if (nx >= 0 && ny >= 0 && nx < width && ny < height && maze[ny][nx] == "#") 
			{
				// force turns to reduce long hallways
				if (last_dir != null && dir.x == last_dir.x && dir.y == last_dir.y) 
					continue

				maze[y + dir.y][x + dir.x] = "."
				carve_path(nx, ny, dir)
			}
		}
	}

	// carve out from start point
	local startX = width - 1
	local start = {x = startX, y = start_y}
	carve_path(start.x, start.y, null)

	// mark start/end points
	maze[start_y][startX] = "S"
	maze[end_y][0] = "E"
	
	// block multiple paths to the exit
	local exitY = end_y
	local exitX = 0
	local count = 0
	foreach (dir in directions) 
	{
		local nx = exitX + dir.x
		local ny = exitY + dir.y
		// check within bounds
		if (nx >= 0 && ny >= 0 && nx < width && ny < height && maze[ny][nx] == ".") 
		{
			count++
			if (count > 1) 
				maze[ny][nx] = "#"
		}
	}

	return maze
}

function OnUpdate()
{
	local threshold = Ware_MinigameLocation.start.x - 6144.0
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.IsAlive() && player.GetOrigin().x < threshold)
		{
			Ware_PassPlayer(player, true)					
			if (first)
			{
				Ware_ChatPrint(null, "{player} {color}made it to the goal first!", player, TF_COLOR_DEFAULT)
				first = false
			}
		}
	}
}

function OnEnd()
{
	EntFire("mandrill_train", "TeleportToPathTrack", "camp_move1")
	EntFire("mandrill_train", "Stop", "")
}

function OnCleanup()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.SetCustomModel("")
		Ware_TogglePlayerWearables(player, true)
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0
}