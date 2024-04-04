local waterfall_model = "models/props_forest/waterfall001.mdl";
PrecacheModel(waterfall_model);

minigame <- Ware_MinigameData();
minigame.name = "Flood"
minigame.description = "Get on a Platform!"
minigame.duration = 4.0;
minigame.music = "ohno";
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_delay = 0.5;
minigame.custom_overlay = "get_platform";

local platform_index;

function OnStart()
{
	local location_name = Ware_MinigameLocation.name;
	
	platform_index = RandomInt(1, 4);
	EntFire(location_name + "_flood", "Open", "", 2);
	EntFire(location_name + "_croc", "Enable", "", 2);
	EntFire(format("%s_platform_%d", location_name, platform_index), "Close");
	
	local pos = Ware_MinigameLocation.mins * 1.0;
	pos.x = (Ware_MinigameLocation.maxs.x + Ware_MinigameLocation.mins.x) * 0.5;
	pos.y -= 256.0;
	pos.x -= 444.0;
	Ware_SpawnEntity("prop_dynamic",
	{
		model = waterfall_model,
		origin = pos,
		angles = QAngle(0, -45, 0),
		disableshadows = true,
	});
	
	DebugDrawLine(pos, pos + Vector(0, 0, 1024), 255, 0, 0, false, 5.0);
}

function OnEnd()
{
	local location_name = Ware_MinigameLocation.name;
	
	EntFire(location_name + "_flood", "Close");
	EntFire(location_name + "_croc", "Disable");
	EntFire(format("%s_platform_%d", location_name, platform_index), "Open");
}

function OnTakeDamage(params)
{
	if (!(params.damage_type & DMG_CLUB))
		return;
	
	local victim = params.const_entity;
	if (victim.IsPlayer() && params.attacker != null && params.attacker != victim)
	{
		params.damage = 10;
		
		local dir = params.attacker.EyeAngles().Forward();
		dir.z = 1.0;
		dir.Norm();
		victim.SetAbsVelocity(victim.GetAbsVelocity() + dir * 500.0);		
	}
}