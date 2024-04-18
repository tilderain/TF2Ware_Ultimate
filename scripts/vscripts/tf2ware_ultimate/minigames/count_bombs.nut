minigame <- Ware_MinigameData
({
	name           = "Count Bombs"
	author         = "ficool2"
	description    = "How many bombs?"
	duration       = 8.0
	end_delay      = 0.5
	music          = "thethinker"
	suicide_on_end = true
})

prop_model <- "models/tf2ware_ultimate/dummy_sphere.mdl"
sprite_model <- "sprites/tf2ware_ultimate/bomb_red.vmt"
PrecacheModel(prop_model)

count <- 0

function OnStart()
{
	count = RandomInt(6, 15)
	
	for (local i = 0; i < count; i++)
	{
		local pos = Ware_MinigameLocation.center
		pos += Vector(RandomFloat(-250, 250), RandomFloat(-250, 250), RandomFloat(250, 300))
	
		local prop = Ware_SpawnEntity("prop_physics_override", 
		{
			model          = prop_model
			origin         = pos
			massscale      = 0.015
			rendermode     = kRenderNone
			disableshadows = true
		})
		prop.SetCollisionGroup(TFCOLLISION_GROUP_COMBATOBJECT)
		
		local sprite = Ware_SpawnEntity("env_glow",
		{
			model       = sprite_model
			origin      = pos
			scale       = 0.25
			spawnflags  = 1
			rendermode  = 1
			rendercolor = "255 255 255"
		})
		
		SetEntityParent(sprite, prop)
		
		Ware_SlapEntity(prop, RandomFloat(40, 80))
	}
}

function OnEnd()
{
	Ware_ChatPrint(null, "{color}The correct answer was {color}{int}", TF_COLOR_DEFAULT, COLOR_LIME, count)
}

function OnPlayerSay(player, text)
{
	try
	{
		local num = text.tointeger()
		if (num != count)
			throw "wrong"
		if (Ware_IsPlayerPassed(player))
			return false
		if (!IsEntityAlive(player))
			return false
			
		Ware_PassPlayer(player, true)
		return false
	}
	catch (error)
	{
		if (IsEntityAlive(player) && !Ware_IsPlayerPassed(player))
			Ware_SuicidePlayer(player)
		
		return true
	}
}