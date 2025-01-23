minigame <- Ware_MinigameData
({
	name          = "Pop the JACK"
	author        = ["TonyBaretta", "ficool2"]
	description   = "Hit the JACK until it pops!"
	duration      = 8.3
	location      = "boxarena"
	music         = "drumdance"
	convars       =
	{
		phys_timescale = 0.5
	}
})

pop_sound <- "TF2Ware_Ultimate.BalloonPop"
jack_model <- RandomInt(0, 100) <= 10 ? "models/passtime/ball/passtime_ball_halloween.mdl" : "models/passtime/ball/passtime_ball.mdl"


function OnPrecache()
{
	PrecacheModel("models/passtime/ball/passtime_ball.mdl")
	PrecacheModel("models/passtime/ball/passtime_ball_halloween.mdl")
	PrecacheScriptSound(pop_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Necro Smasher")
	foreach (player in Ware_MinigamePlayers)
	{
		local target = player // need this to make squirrel happy
		Ware_CreateTimer(@() SpawnJack(target), RandomFloat(0.2, 0.3))
	}
}

function SpawnJack(player)
{
	if (!player.IsValid())
		return
	
	local origin = player.EyePosition() + player.EyeAngles().Forward() * 350.0
	origin.z = Ware_MinigameLocation.center.z + 64.0
	
	local jack = Ware_SpawnEntity("prop_physics_multiplayer",
	{
		targetname = "jack"
		origin     = origin
		model      = jack_model
		skin       = player.GetTeam() - 2
	})
	jack.SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer()) 
	{
		if (params.damage_type & DMG_CRUSH)
			return false
	}
	else if (victim.GetName() == "jack")
	{
		local attacker = params.attacker
		if (attacker && attacker.IsPlayer())
		{
			local scale = victim.GetModelScale() + 0.5
			if (scale > 2.5)
			{
				Ware_PassPlayer(attacker, true)
				EmitSoundOnClient(pop_sound, attacker)
				DispatchParticleEffect("merasmus_blood_bits", victim.GetOrigin(), Vector())
				victim.EmitSound(pop_sound)
				victim.Kill()
			}
			else
			{
				victim.SetModelScale(scale, 0.0)
			}
		}
	}
}