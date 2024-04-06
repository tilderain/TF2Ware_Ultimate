minigame <- Ware_MinigameData();
minigame.name = "Avoid the Props";
minigame.description = "Look out for the props!"
minigame.duration = 4.0;
minigame.music = "actfast";
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;

local prop_models =
[
	"models/props_gameplay/ball001.mdl",
	"models/props_hydro/barrel_crate_half.mdl",
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_gameplay/haybale.mdl",
	"models/props_forest/wheelbarrow.mdl", 
	"models/props_forest/saw_blade_large.mdl", 
	"models/props_spytech/computer_printer.mdl", 
	"models/props_mvm/oildrum.mdl", 
	"models/props_mining/sign001.mdl", 
	"models/props_trainyard/train_billboard001_sm.mdl", 
	"models/props_well/hand_truck01.mdl", 
];
local prop_model = prop_models[RandomIndex(prop_models)];
PrecacheModel(prop_model);

is_sawblade <- prop_model.find("saw_blade") != null;

kill_sound <- is_sawblade ? "SawMill.BladeImpact" : "Halloween.skeleton_break";
PrecacheScriptSound(kill_sound);

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local origin = data.player.GetOrigin() + Vector(0, 0, 1000);
		local prop = Ware_SpawnEntity("prop_physics_override", 
		{
			origin = origin,
			model = prop_model,
			skin = RandomInt(0, 1),
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
		Ware_MinigameScope.is_sawblade ? (DMG_SAWBLADE) : (DMG_CRUSH|DMG_CRIT)
	);
	
	activator.EmitSound(Ware_MinigameScope.kill_sound);
	
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