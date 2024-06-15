minigame <- Ware_MinigameData
({
	name        = "Break a Barrel"
	author      = "ficool2"	
	description = "Break a barrel!"
	duration    = 4.0
	music       = "clumsy"
})

barrel_model <- "models/props_farm/wooden_barrel.mdl"

function OnPrecache()
{
	PrecacheModel(barrel_model)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT)
	
	foreach (data in Ware_MinigamePlayers)
	{
		local barrel = Ware_SpawnEntity("prop_physics_override", 
		{
			origin = data.player.GetOrigin() + Vector(0, 0, 400)
			model  = barrel_model
			health = 25
		})
		Ware_SlapEntity(barrel, 80.0)
	}
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker
		if (attacker != null 
			&& attacker.IsPlayer() 
			&& (params.damage_type & DMG_CLUB))
		{
			Ware_PassPlayer(attacker, true)
		}
	}
}