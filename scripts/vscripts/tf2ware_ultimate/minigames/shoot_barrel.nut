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

barrel <- null

function OnPrecache()
{
	PrecacheModel(barrel_model)
	PrecacheScriptSound(hit_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Reserve Shooter")
	Ware_CreateTimer(@() SpawnBarrel(), 1.0)
}

function SpawnBarrel()
{
	local line = RandomElement(Ware_MinigameLocation.lines)
	local origin = Lerp(line[0], line[1], RandomFloat(0.0, 1.0))
	local angles = QAngle(0, -90, 0)
	barrel = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = barrel_model
		origin = origin
		angles = angles
		health = 1
	})
	barrel.AddEFlags(EFL_NO_DAMAGE_FORCES)
	barrel.SetPhysVelocity(Vector(RandomFloat(-700, 700), 0, RandomFloat(1000, 1100)))
	barrel.ValidateScriptScope()
	local barrel_scope = barrel.GetScriptScope()
	barrel_scope.lag_record <- [origin]
	// hacky way of simulating some shotgun spread
	barrel_scope.mins <- barrel.GetBoundingMins() * 1.7
	barrel_scope.maxs <- barrel.GetBoundingMaxs() * 1.7
	barrel_scope.BarrelThink <- function()
	{
		lag_record.append(self.GetOrigin())
		return -1
	}	
	AddThinkToEnt(barrel, "BarrelThink")
}

function OnPlayerAttack(player)
{		
	local eye_position = player.EyePosition()
	local eye_fwd = player.EyeAngles().Forward()
	
	// backtrack barrel position (lag compensation)
	local latency = GetPlayerLatency(player)
	if (player != Ware_ListenHost)
		latency += Ware_GetPlayerData(player).lerp_time
	local tick = TimeToTicks(latency)
	
	if (barrel && barrel.IsValid())
	{
		local barrel_scope = barrel.GetScriptScope()
		local records = barrel_scope.lag_record
		local record_tick = Max(records.len() - 1 - tick, 0)
		local lag_origin = barrel_scope.lag_record[record_tick]
		
		//DebugDrawBox(barrel_scope.self.GetOrigin(), barrel_scope.mins, barrel_scope.maxs, 255, 0, 0, 20, 3.0)
		//DebugDrawBox(lag_origin, barrel_scope.mins, barrel_scope.maxs, 0, 255, 0, 20, 3.0)
		//DebugDrawLine(eye_position, eye_position + eye_fwd * 2048.0, 255, 0, 0, false, 3.0)
		
		if (IntersectRayWithBox(eye_position, eye_fwd, 
			lag_origin + barrel_scope.mins, 
			lag_origin + barrel_scope.maxs, 
			0.0, 8192.0) > 0.0)
		{
			local minidata = Ware_GetPlayerMiniData(player)
			if (!("hit_sound" in minidata))
			{
				minidata.hit_sound <- true
				Ware_PlaySoundOnClient(player, hit_sound)
			}
			Ware_PassPlayer(player, true)
		}
	}
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker
		if (attacker && attacker.IsPlayer())	
			return false
	}
}