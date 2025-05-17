minigame <- Ware_MinigameData
({
	name           = "Dove Hunt"
	author         = ["tilderain"]
	description    = "Kill the birds!"
	duration       = 18
	end_delay      = 0.5
	music          = "duckhunt"
})

spawn_rate <- RemapValClamped(Ware_MinigamePlayers.len().tofloat(), 0.0, 32.0, 0.5, 0.05)

hit_sound  <- "tf2ware_ultimate/mp_hit_indication_3c.wav"

bird <- null
bird_model <- "models/props_forest/dove.mdl"

function OnPrecache()
{
	PrecacheSound("tf2ware_ultimate/mp_hit_indication_3c.wav")
	PrecacheModel(bird_model)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Huntsman")

	foreach (player in Ware_MinigamePlayers)
		Ware_GetPlayerMiniData(player).points <- 0
			
	Ware_CreateTimer(@() SpawnDove(), 0.25)
}


function DoveThink()
{
	local time = Time()
	if(spawn_time + 7.0 < Time()) 
	{
		self.Kill()
		return
	}
	// update at cl_interp minimum
	local dt = 0.05
	local my_origin = self.GetOrigin()

	if (move_dir != null)
	{
		local move_speed = 400.0
		
		local dest = move_dir * move_speed * dt
		local offset = Vector(0, 0, 32)
		self.SetAbsOrigin(my_origin + dest)
	}
	
	self.StudioFrameAdvance()
	return dt
}



function SpawnDove()
{
	local origin = Vector(
		RandomFloat(Ware_MinigameLocation.mins.x + 50.0, Ware_MinigameLocation.maxs.x - 50.0),
		RandomFloat(Ware_MinigameLocation.mins.y + 50.0, Ware_MinigameLocation.maxs.y - 50.0),
		Ware_MinigameLocation.center.z + 700 + RandomFloat(-400, 400))

	local angle = RandomFloat(-180, 180)
	local vec_angle = Vector(cos(angle), sin(angle))
	local yaw = atan2(vec_angle.y, vec_angle.x) * RAD2DEG

	local dove = Ware_SpawnEntity("base_boss",
	{	
		model  = bird_model
		origin = origin
		angles    = QAngle(0, yaw, 0)
		defaultanim = "fly_cycle"
		modelscale = 4
		health = 9999
	})
	EntityAcceptInput(dove, "Disable")
	
	dove.SetSolid(SOLID_BBOX)
	dove.SetSize(Vector(-16, -16, 0), Vector(16, 16, 32))
	dove.ResetSequence(dove.LookupSequence("fly_cycle"))
	dove.ValidateScriptScope()
	local dove_scope = dove.GetScriptScope()

	dove_scope.move_dir <- vec_angle
	dove_scope.spawn_time <- Time()

	dove_scope.DoveThink <- DoveThink.bindenv(dove_scope)
	AddThinkToEnt(dove, "DoveThink")
	
	//DispatchParticleEffect("Explosion_bubbles", origin, Vector(1, 0, 0))
	
	return spawn_rate
}


function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "base_boss")
	{
		local player = params.attacker

		if (player && player.IsPlayer())
		{
			local minidata = Ware_GetPlayerMiniData(player)
			minidata.points++
			
			Ware_PlaySoundOnClient(player, hit_sound)			
			Ware_ShowText(player, CHANNEL_MINIGAME, "x", 0.25, "255 255 255", -1, -1)
			
			if (minidata.points >= 3)
				Ware_PassPlayer(player, true)		
		}
		DispatchParticleEffect("blood_impact_red_01", params.const_entity.GetOrigin(), vec3_zero)
		params.const_entity.Kill()

		return true
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (Ware_GetPlayerAmmo(player, TF_AMMO_PRIMARY) == 0)
			SetPropInt(player, "m_nImpulse", 101)
	}
}
