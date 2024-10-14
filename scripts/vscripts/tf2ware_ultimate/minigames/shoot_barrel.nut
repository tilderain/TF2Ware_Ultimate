minigame <- Ware_MinigameData
({
	name           = "Shoot the Barrel"
	author         = "ficool2"
	description    = "Shoot the Barrel!"
	location       = "targetrange"
	duration       = 5.0
	music          = "wildwest"
})

barrel_model <- "models/props_farm/wooden_barrel.mdl"
hit_sound <- "Player.HitSoundBeepo"

function OnPrecache()
{
	PrecacheModel(barrel_model)
	PrecacheScriptSound(hit_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Reserve Shooter");	
	Ware_CreateTimer(@() SpawnBarrel(), 1.0)
}

function SpawnBarrel()
{
	local line = RandomElement(Ware_MinigameLocation.lines)
	local origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1])
	local angles = QAngle(0, -90, 0)
	local barrel = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = barrel_model,
		origin = origin,
		angles = angles,
		health = 1,
	})
	barrel.AddEFlags(EFL_NO_DAMAGE_FORCES)
	barrel.SetPhysVelocity(Vector(RandomFloat(-700, 700), 0, RandomFloat(1000, 1100)))
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker
		if (attacker && attacker.IsPlayer())	
		{
			local minidata = Ware_GetPlayerMiniData(attacker)
			if (!("hit_sound" in minidata))
			{
				minidata.hit_sound <- true
				EmitSoundOnClient(hit_sound, attacker)
			}
			Ware_PassPlayer(attacker, true)
			return false
		}	
	}
}