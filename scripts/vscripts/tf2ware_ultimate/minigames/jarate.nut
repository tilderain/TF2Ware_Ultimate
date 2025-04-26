minigame <- Ware_MinigameData
({
	name         = "Jarate an Enemy"
	author       = ["Gemidyne", "pokemonPasta"]
	duration     = 4.0
	music        = "rockingout"
	description  = "Jarate an Enemy!"
	min_players  = 2
	allow_damage = true
})

projectiles <- {}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Jarate", {}, true)
}

function OnUpdate()
{
	local dead_projs = []
	foreach (proj, data in projectiles)
	{
		local owner = data.owner
		if (proj.IsValid() && !proj.IsSolidFlagSet(FSOLID_NOT_SOLID))
			continue
		
		dead_projs.append(proj)
		
		if (!owner || !owner.IsValid())
			continue
		local last_origin = data.origin
		for (local player; player = FindByClassnameWithin(player, "player", last_origin, 200.0);)
		{
			if (player != owner)
				Ware_PassPlayer(owner, true)
		}
	}
	foreach (proj in dead_projs)
		delete projectiles[proj]
	
	local id = ITEM_MAP.Jarate.id
	local classname = ITEM_PROJECTILE_MAP[id]
	for (local proj; proj = FindByClassname(proj, classname);)
	{
		if (proj.IsSolidFlagSet(FSOLID_NOT_SOLID))
			continue
		projectiles[proj] <- { origin = proj.GetOrigin(), owner = GetPropEntity(proj, "m_hThrower") }
		proj.SetTeam(TEAM_SPECTATOR)
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
	if (victim.IsPlayer() && attacker && attacker.IsPlayer())
		return false
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
		player.RemoveCond(TF_COND_URINE)
}
