minigame <- Ware_MinigameData
({
	name           = "Hoop"
	author         = "ficool2"
	description    = "Jump through the hoops!"
	duration       = 11.0
	max_scale      = 1.0
	location       = "dirtsquare"
	music          = "challenge"
})

hoop_model <- "models/props_halloween/hwn_jump_hoop01.mdl"
hoop_sound <- "ui/hitsound_beepo.wav"

hoops <- []

point_a <- null
point_b <- null
point_c <- null

function OnPrecache()
{
	PrecacheModel(hoop_model)
	PrecacheSound(hoop_sound)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center + Vector(0, 800, 0),
		QAngle(0, 270, 0),
		1300.0,
		100.0, 60.0)
		
	point_a = Ware_MinigameLocation.center + Vector(RandomFloat(-1000, 1000), 700, 0)
	point_b = Ware_MinigameLocation.center + Vector(0, 0, RandomFloat(2000, 3000))
	point_c = Ware_MinigameLocation.center + Vector(RandomFloat(-1000, 1000), RandomFloat(-1000, -600), 0)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Stickybomb Jumper")
	
	local hoop_count = 3
	foreach (player in Ware_MinigamePlayers)
	{
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.last_origin <- player.GetCenter()
		minidata.hoops       <- array(hoop_count, false)
	}
	
	for (local i = 0; i < hoop_count; i++)
	{
		local t
		switch (i)
		{
			case 0: t = 0.15; break
			case 1: t = 0.5; break
			case 2: t = 0.8; break
		}
		
		local origin = LerpQuadratic(point_a, point_b, point_c, t)
		local prev_origin = LerpQuadratic(point_a, point_b, point_c, t - 0.01)
		local dir = origin - prev_origin
		dir.Norm()
		
		local scale = RandomFloat(0.7, 1.0)
		local hoop = Ware_SpawnEntity("prop_dynamic_override",
		{
			origin         = origin
			angles         = VectorAngles(dir)
			model          = hoop_model
			modelscale     = scale
			disableshadows = true
		})
	
		hoops.append
		({
			entity = hoop
			origin = origin
			radius = 315.0 * scale
			normal = dir
			dist   = dir.Dot(origin)
		})
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		local minidata = Ware_GetPlayerMiniData(player)
		local origin = player.GetCenter()
		foreach (i, hoop in hoops)
		{
			local crossed_hoops = minidata.hoops
			if (crossed_hoops[i])
				continue
				
			local point = IntersectLinePlane(minidata.last_origin, origin, hoop.normal, hoop.dist)
			if (point == null)
				continue
			
			local dist = VectorDistance(point, hoop.origin)
			if (dist > hoop.radius)
				continue
				
			crossed_hoops[i] = true
			local crossed_count = crossed_hoops.filter(@(i, crossed) crossed).len() 
								
			Ware_PlaySoundOnClient(player, hoop_sound, 1.0, 90 + crossed_count * 10)
			
			if (crossed_count == hoops.len())
				Ware_PassPlayer(player, true)
		}
		minidata.last_origin = origin
	}
	
	//local points = (10).tofloat()
	//local point_prev = point_a
    //for (local i = 1.0; i <= points; i += 1.0) 
	//{
    //    local t = i / points
    //    local point = LerpQuadratic(point_a, point_b, point_c, t)
    //    DebugDrawLine(point_prev, point, 255, 0, 0, false, NDEBUG_TICK)
    //    point_prev = point
    //}	
}