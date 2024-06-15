minigame <- Ware_MinigameData
({
	name          = "Avoid the Props"
	author		  = "ficool2"
	description   = "Look out for the props!"
	duration      = 4.0
	music         = "actfast"
	start_pass    = true
	allow_damage  = true
	fail_on_death = true
})

prop_models <-
[
	"models/props_gameplay/ball001.mdl"
	"models/props_hydro/barrel_crate_half.mdl"
	"models/props_gameplay/orange_cone001.mdl"
	"models/props_gameplay/haybale.mdl"
	"models/props_forest/wheelbarrow.mdl"
	"models/props_forest/saw_blade_large.mdl"
	"models/props_spytech/computer_printer.mdl",
	"models/props_mvm/oildrum.mdl"
	"models/props_mining/sign001.mdl"
	"models/props_trainyard/train_billboard001_sm.mdl"
	"models/props_well/hand_truck01.mdl"
]

prop_model <- RandomElement(prop_models)
is_sawblade <- prop_model.find("saw_blade") != null
kill_sound <- is_sawblade ? "SawMill.BladeImpact" : "Halloween.skeleton_break"

function OnPrecache()
{
	foreach (model in prop_models)
		PrecacheModel(prop_model)
	PrecacheScriptSound("SawMill.BladeImpact")
	PrecacheScriptSound("Halloween.skeleton_break")
}

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local origin = data.player.GetOrigin() + Vector(0, 0, 1000)
		local prop = Ware_SpawnEntity("prop_physics_override", 
		{
			origin       = origin
			model        = prop_model
			skin         = RandomInt(0, 1)
			spawnflags   = SF_PHYSPROP_TOUCH,	
			minhealthdmg = INT_MAX, // don't destroy on touch			
		})	
		Ware_SlapEntity(prop, 40.0)
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer())
	{
		if (params.damage_type & DMG_CLUB)
		{
			local attacker = params.attacker
			if (victim.IsPlayer() && attacker && attacker.IsPlayer())
			{
				victim.SetAbsVelocity(victim.GetAbsVelocity() + Vector(0, 0, 300))
				Ware_PushPlayerFromOther(victim, attacker, 250.0)
				return false
			}
		}
		else if (params.damage_type & DMG_SLASH) // prop touch
		{
			// the attacker is the player, so recover the true attacker from the damage position
			local attacker = FindByClassnameNearest("prop_physics", params.damage_position, 0.0)
			if (attacker)
			{
				victim.TakeDamageEx(
					attacker, 
					attacker,
					null, 
					Vector(RandomFloat(19999, -19999), RandomFloat(19999, -19999), -999999),
					attacker.GetOrigin(), 
					999.9, 
					Ware_MinigameScope.is_sawblade ? (DMG_SAWBLADE) : (DMG_CRUSH|DMG_CRIT)
				)
				
				victim.EmitSound(Ware_MinigameScope.kill_sound)
				
				local ragdoll = GetPropEntity(victim, "m_hRagdoll")
				if (ragdoll)
				{
					MarkForPurge(ragdoll)
					SetPropFloat(victim, "m_flTorsoScale", -1)
					SetPropFloat(ragdoll, "m_flTorsoScale", -1)
				}
				
				return false
			}
		}
	}
}