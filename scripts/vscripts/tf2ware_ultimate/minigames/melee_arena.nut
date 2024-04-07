local mode = RandomInt(0, 5);

minigame <- Ware_MinigameData();
minigame.name = "Melee Arena"
minigame.description = "Survive!"
minigame.location = "circlepit";
minigame.duration = 30.9;
minigame.music = "keepitup";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_below_min = true;
minigame.end_delay = 1.0;
minigame.custom_overlay = "survive";

function OnStart()
{
	local attributes = { "active health degen" : -20.0 };
	if (mode == 0)
		Ware_SetGlobalLoadout(TF_CLASS_MEDIC, null, attributes);
	else if (mode == 1)
		Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null, attributes);	
	else if (mode == 2)
		Ware_SetGlobalLoadout(TF_CLASS_SCOUT, null, attributes);	
	else if (mode == 3)
		Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Hot Hand", attributes);
	else if (mode == 4)
		Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, null, attributes);	
	else if (mode == 5)
		Ware_SetGlobalLoadout(TF_CLASS_ENGINEER, "Gunslinger", attributes);
}

function OnTakeDamage(params)
{
	local victim = params.const_entity;
	local attacker = params.attacker;
	if (victim.IsPlayer()
		&& attacker && attacker != victim && attacker.IsPlayer())
	{
		local amount = 35.0;
		
		params.damage = amount;
		// must add health here instead of 'add_onhit_addhealth' attribute because it doesn't work with friendlyfire
		HealPlayer(attacker, amount);
	}
}