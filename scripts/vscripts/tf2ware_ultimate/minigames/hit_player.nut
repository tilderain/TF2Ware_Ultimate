local mode_nobody = RandomInt(0, 3) == 0;
local player_class = RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST);

player_class = TF_CLASS_HEAVYWEAPONS;

minigame <- Ware_MinigameData();
minigame.name = "Hit a Player";
minigame.description = mode_nobody ? "Hit nobody!" : "Hit a player!";
minigame.duration = 4.5;
minigame.music = "heat";
minigame.min_players = 2;
minigame.start_pass = mode_nobody;
minigame.allow_damage = true;
minigame.end_delay = 0.5;
minigame.custom_overlay = mode_nobody ? "hit_nobody" : "hit_player"; 

local loadouts = 
{
	[TF_CLASS_SCOUT]        = "Scattergun",
	[TF_CLASS_SOLDIER]      = "Direct Hit",
	[TF_CLASS_PYRO]         = "Dragon's Fury",
	[TF_CLASS_DEMOMAN]      = "Loch-n-Load",
	[TF_CLASS_HEAVYWEAPONS] = "Minigun",
	[TF_CLASS_ENGINEER]     = "Shotgun",
	[TF_CLASS_MEDIC]        = "Syringe Gun",
	[TF_CLASS_SNIPER]       = "Huntsman",
	[TF_CLASS_SPY]          = "Revolver",
};

function OnStart()
{
	Ware_SetGlobalLoadout(player_class, loadouts[player_class]);
}

function OnUpdate()
{
	local id = ITEM_MAP[loadouts[player_class]].id;
	if (id in ITEM_PROJECTILE_MAP)
	{
		local classname = ITEM_PROJECTILE_MAP[id];
		for (local proj; proj = FindByClassname(proj, classname);)
		{
			// alternating like this to fix rockets specifically
			// TODO: fix dragon's fury
			proj.SetTeam(proj.GetTeam() == TEAM_SPECTATOR ? TF_TEAM_RED : TEAM_SPECTATOR);	
		}
	}
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_FALL)
		return;
	
	if (params.attacker != null && params.const_entity != params.attacker)
		params.damage *= 100.0;
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker);
	if (attacker == null)
		return;
	local victim = GetPlayerFromUserID(params.userid);
	if (victim == attacker)
		return;
	Ware_PassPlayer(attacker, !mode_nobody);
}