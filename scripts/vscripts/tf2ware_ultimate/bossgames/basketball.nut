minigame <- Ware_MinigameData
({
	name           = "Basketball"
	author         = "ficool2"
	description    = "Score 7 Goals!"
	custom_overlay = "score_goals_7"
	duration       = 31.4
	location       = "ballcourt"
	music          = "basketball"
	start_pass     = false
})

hoop_sound <- "Halloween.PumpkinDrop"

function OnPrecache()
{
	PrecacheScriptSound(hoop_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Grenade Launcher")
	
	foreach (player in Ware_MinigamePlayers)
	{
		// make grenades pass through
		player.SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		SetPropInt(player, "m_takedamage", DAMAGE_NO)
		Ware_GetPlayerMiniData(player).points <- 0
	}
	
	EntFire("boss4_door", "Unlock")
	EntFire("boss4_door2", "Unlock")
	EntFire("boss4_door", "Open")
	EntFire("boss4_door2", "Open")
	
	for (local trigger; trigger = FindByName(trigger, "basketball_trigger");)
	{
		MarkForPurge(trigger)
		trigger.ValidateScriptScope()
		trigger.GetScriptScope().OnHoopTouch <- OnHoopTouch
		trigger.ConnectOutput("OnStartTouch", "OnHoopTouch")
	}
}

function OnHoopTouch()
{
	local owner = GetPropEntity(activator, "m_hThrower")
	if (owner)
	{	
		EmitSoundOnClient(Ware_MinigameScope.hoop_sound, owner)
		if (++Ware_GetPlayerMiniData(owner).points >= 7)
			Ware_PassPlayer(owner, true)
	}
	
	activator.Kill()
}

function OnUpdate()
{
	for (local grenade; grenade = FindByClassname(grenade, "tf_projectile_pipe");)
	{
		MarkForPurge(grenade)
		grenade.RemoveSolidFlags(FSOLID_TRIGGER)
		grenade.KeyValueFromString("classname", "ware_projectile_pipe")
	}
	
	foreach (player in Ware_MinigamePlayers)
	{
		if (Ware_GetPlayerAmmo(player, TF_AMMO_PRIMARY) == 0)
			SetPropInt(player, "m_nImpulse", 101)
	}
}

function OnEnd()
{
	EntFire("boss4_door", "Close")
	EntFire("boss4_door2", "Close")
 	EntFire("boss4_door", "Lock")
 	EntFire("boss4_door2", "Lock")
	
	for (local trigger; trigger = FindByName(trigger, "basketball_trigger");)
		trigger.DisconnectOutput("OnStartTouch", "OnHoopTouch")
}

function OnCleanup()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		SetPropInt(player, "m_takedamage", DAMAGE_YES)
	}
}