minigame <- Ware_MinigameData
({
	name           = "Caber King"
	author         = "ficool2"
	description    = "Survive!"
	duration       = 3.5
	end_delay      = 0.5
	music          = "falling"
	custom_overlay = "survive"
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Ullapool Caber")
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_BLAST)
	{
		if (params.const_entity != params.attacker)
			params.damage *= 2.5
		else
			params.damage = 100.0
		
		params.damage_type = params.damage_type & (~DMG_SLOWBURN) // no falloff
	}
}