minigame <- Ware_MinigameData
({
	name         = "Jarate an Enemy"
	author       = "pokemonPasta"
	duration     = 4.0
	music        = "rockingout"
	description  = "Jarate an Enemy!"
	min_players  = 2
	allow_damage = true
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Jarate", {}, true)
	Ware_SetGlobalAttribute("applies snare effect", 0.0000001, Ware_GetMinigameTime())
}

function OnGameEvent_player_stunned(params)
{
	local victim = GetPlayerFromUserID(params.victim)
	local player = GetPlayerFromUserID(params.stunner)
	if (victim && player && victim != player)
		Ware_PassPlayer(player, true)
}

function OnUpdate()
{
	local id = ITEM_MAP.Jarate.id
	local classname = ITEM_PROJECTILE_MAP[id]
	for (local proj; proj = FindByClassname(proj, classname);)
	{
		proj.SetTeam(TEAM_SPECTATOR)
	}
}

function OnTakeDamage(params)
{
	params.damage = 0.0
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.RemoveCond(TF_COND_URINE)
		player.RemoveCond(TF_COND_STUNNED)
	}
}
