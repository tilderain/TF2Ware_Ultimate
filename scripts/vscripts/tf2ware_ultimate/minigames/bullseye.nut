minigame <- Ware_MinigameData
({
	name        = "Bullseye"
	author      = "ficool2"
	description = "Hit the Bullseye 5 times!"
	duration    = 4.0
	music       = "wildwest"
})

prop_model <- "models/tf2ware_ultimate/dummy_sphere.mdl"
sprite_model <- "sprites/tf2ware_ultimate/" + (RandomInt(0, 100) <= 5 ? "bullseye_gabe.vmt" : "bullseye.vmt")
PrecacheModel(prop_model)

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Winger");	
	
	local pos = Ware_MinigameLocation.center + Vector(0.0, 0.0, RandomFloat(50.0, 250.0))
	
	local prop = Ware_SpawnEntity("prop_physics_override", 
	{
		model      = prop_model,
		origin     = pos,
		massscale  = 0.02,
		rendermode = kRenderNone,
	})
	prop.SetCollisionGroup(TFCOLLISION_GROUP_COMBATOBJECT)
	
	local sprite = Ware_SpawnEntity("env_glow",
	{
		model       = sprite_model,
		origin      = pos,
		scale       = 0.25,
		spawnflags  = 1,
		rendermode  = kRenderTransColor,
		rendercolor = "255 255 255",
	})	
	SetEntityParent(sprite, prop)
	
	Ware_ShowAnnotation(sprite, "Bullseye!")
	
	foreach (data in Ware_MinigamePlayers)
		Ware_GetPlayerMiniData(data.player).points <- 0
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker
		if (attacker != null && attacker.IsPlayer())
		{
			local minidata = Ware_GetPlayerMiniData(attacker)
			minidata.points++
			if (minidata.points >= 5)
				Ware_PassPlayer(attacker, true)
		}
	}
}