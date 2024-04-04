kill_sound <- "Halloween.skeleton_break";
PrecacheScriptSound(kill_sound);

minigame <- Ware_MinigameData();
minigame.name = "Avoid the Props";
minigame.description = "Look out for the props!"
minigame.duration = 4.0;
minigame.music = "actfast";
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;

local prop_model =  "models/props_gameplay/ball001.mdl";
PrecacheModel(prop_model);

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local origin = data.player.GetOrigin() + Vector(0, 0, 650);
		local prop = Ware_SpawnEntity("prop_physics_override", 
		{
			origin = origin,
			model = prop_model,
		});
		local trigger = Ware_SpawnEntity("trigger_multiple",
		{
			classname = "passtime_pass",
			origin = origin,
			spawnflags = 1
		});
		SetEntityParent(trigger, prop);
		trigger.SetSolid(SOLID_BBOX);
		trigger.SetSize(prop.GetBoundingMins() * 1.1, prop.GetBoundingMaxs() * 1.1);
		trigger.ValidateScriptScope();
		trigger.GetScriptScope().OnStartTouch <- OnPropTouch;
		trigger.ConnectOutput("OnStartTouch", "OnStartTouch");
	
		Ware_SlapEntity(prop, 40.0);
	}
}

function OnPropTouch()
{
	activator.TakeDamageEx(
		self, 
		self,
		null, 
		Vector(RandomFloat(19999, -19999), RandomFloat(19999, -19999), -999999),
		self.GetOrigin(), 
		999.9, 
		DMG_CRUSH|DMG_CRIT
	);
	
	EmitSoundOnClient(Ware_MinigameScope.kill_sound, activator);
	
	local ragdoll = GetPropEntity(activator, "m_hRagdoll");
	if (ragdoll)
	{
		MarkForPurge(ragdoll);
		SetPropFloat(activator, "m_flTorsoScale", -1);
		SetPropFloat(ragdoll, "m_flTorsoScale", -1);
	}
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_CLUB)
	{
		local victim = params.const_entity;
		local attacker = params.attacker;
		if (victim.IsPlayer() && attacker && attacker.IsPlayer())
		{
			victim.SetAbsVelocity(victim.GetAbsVelocity() + Vector(0, 0, 300));
			Ware_PushPlayerFromOther(victim, attacker, 250.0);
			return false;
		}
	}
}