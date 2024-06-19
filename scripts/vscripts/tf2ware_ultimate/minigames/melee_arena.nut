minigame <- Ware_MinigameData
({
	name           = "Melee Arena"
	author         = "ficool2"
	description    = "Survive!"
	location       = "circlepit"
	duration       = 30.9
	end_delay      = 1.0
	music          = "keepitup"
	custom_overlay = "survive"
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
	collisions     = true
	convars =
	{
		tf_avoidteammates = 0
	}
	
	// small players fly into the air and i have no idea why - pokepasta
	allow_scale = false
})

mode <- RandomInt(0, 5)

function OnStart()
{
	local attributes = { "active health degen" : -20.0, "mod see enemy health" : 1.0 }
	if (mode == 0)
		Ware_SetGlobalLoadout(TF_CLASS_MEDIC, null, attributes)
	else if (mode == 1)
		Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null, attributes)
	else if (mode == 2)
		Ware_SetGlobalLoadout(TF_CLASS_SCOUT, null, attributes)
	else if (mode == 3)
		Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Hot Hand", attributes)
	else if (mode == 4)
		Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, null, attributes)
	else if (mode == 5)
		Ware_SetGlobalLoadout(TF_CLASS_ENGINEER, "Gunslinger", attributes)
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
	if (victim.IsPlayer()
		&& attacker && attacker != victim && attacker.IsPlayer())
	{
		local amount = 35.0
		params.damage = amount
		// must add health here instead of 'add_onhit_addhealth' attribute because it doesn't work with friendlyfire
		HealPlayer(attacker, amount)
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() <= 1
}