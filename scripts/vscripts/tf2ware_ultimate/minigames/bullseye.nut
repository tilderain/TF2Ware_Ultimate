minigame <- Ware_MinigameData
({
	name        = "Bullseye"
	author      = "ficool2"
	description = "Hit the Bullseye 5 times!"
	duration    = 4.0
	music       = "wildwest"
	convars     =
	{
		phys_pushscale = 2
	}
})

prop_model <- "models/tf2ware_ultimate/dummy_sphere.mdl"
sprite_model <- "sprites/tf2ware_ultimate/" + (RandomInt(0, 100) <= 5 ? "bullseye_gabe.vmt" : "bullseye.vmt")

function OnPrecache()
{
	PrecacheModel(prop_model)
	PrecacheSprite("sprites/tf2ware_ultimate/bullseye.vmt")
	PrecacheSprite("sprites/tf2ware_ultimate/bullseye_gabe.vmt")
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Winger");	
	
	local pos = Ware_MinigameLocation.center + Vector(0.0, 0.0, RandomFloat(400.0, 500.0))
	
	local prop = Ware_SpawnEntity("prop_physics_override", 
	{
		model      = prop_model
		origin     = pos
		massscale  = 0.1
		rendermode = kRenderTransColor
		renderamt  = 0
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
	
	// TODO: I'm not sure why this isn't following the entity
	//Ware_ShowAnnotation(sprite, "Bullseye!")
	
	foreach (player in Ware_MinigamePlayers)
		Ware_GetPlayerMiniData(player).points <- 0
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