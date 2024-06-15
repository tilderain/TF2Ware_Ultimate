mode_nobody  <- RandomInt(0, 3) == 0
player_class <- RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST)

minigame <- Ware_MinigameData
({
	name           = "Hit a Player"
	author         = "ficool2"
	description    = mode_nobody ? "Hit nobody!" : "Hit a player!"
	duration       = 4.5
	end_delay      = 0.5
	music          = "heat"
	custom_overlay = mode_nobody ? "hit_nobody" : "hit_player"
	min_players    = 2
	start_pass     = mode_nobody
	allow_damage   = true
})

loadouts <-
{
	[TF_CLASS_SCOUT]        = RandomElement(["Boston Basher", "Scattergun"]),
	[TF_CLASS_SOLDIER]      = "Direct Hit",
	[TF_CLASS_PYRO]         = "Dragon's Fury",
	[TF_CLASS_DEMOMAN]      = "Loch-n-Load",
	[TF_CLASS_HEAVYWEAPONS] = "Minigun",
	[TF_CLASS_ENGINEER]     = "Shotgun",
	[TF_CLASS_MEDIC]        = "Syringe Gun",
	[TF_CLASS_SNIPER]       = "Huntsman",
	[TF_CLASS_SPY]          = "Revolver",
}

function OnPrecache()
{
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/hit_nobody")
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/hit_player")
}

function OnStart()
{
	Ware_SetGlobalLoadout(player_class, loadouts[player_class])
}

function OnUpdate()
{
	local id = ITEM_MAP[loadouts[player_class]].id
	if (id in ITEM_PROJECTILE_MAP)
	{
		local classname = ITEM_PROJECTILE_MAP[id]
		for (local proj; proj = FindByClassname(proj, classname);)
		{
			// alternating like this to fix rockets specifically
			// TODO: fix dragon's fury
			proj.SetTeam(proj.GetTeam() == TEAM_SPECTATOR ? TF_TEAM_RED : TEAM_SPECTATOR)
		}
	}
}

function OnTakeDamage(params)
{
	if (params.attacker != null && params.const_entity != params.attacker)
		params.damage *= 100.0
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker)
	if (attacker == null)
		return
	local victim = GetPlayerFromUserID(params.userid)
	if (victim == attacker)
		return
	Ware_PassPlayer(attacker, !mode_nobody)
}

function OnEnd()
{
	foreach(data in Ware_MinigamePlayers)
		data.player.RemoveCond(TF_COND_BLEEDING)
}
