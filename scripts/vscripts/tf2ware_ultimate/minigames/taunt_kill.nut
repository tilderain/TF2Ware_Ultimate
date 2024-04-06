local loadouts = 
[
	[TF_CLASS_SCOUT,        "Sandman"],
	[TF_CLASS_SOLDIER,      "Equalizer"],
	[TF_CLASS_PYRO,         "Flare Gun"],
	[TF_CLASS_PYRO,         "Rainblower"],
	[TF_CLASS_PYRO,         "Scorch Shot"],
	[TF_CLASS_PYRO,         "Thermal Thruster"],
	[TF_CLASS_DEMOMAN,      "Eyelander"],
	[TF_CLASS_HEAVYWEAPONS, "Fists"],
	[TF_CLASS_ENGINEER,     "Frontier Justice"],
	[TF_CLASS_ENGINEER,     "Gunslinger"],
	[TF_CLASS_MEDIC,        "Ubersaw"],
	[TF_CLASS_SNIPER,       "Huntsman"],
	[TF_CLASS_SPY,          "Knife"],
];

local loadout_idx = RandomInt(0, loadouts.len() - 1);
local loadout = loadouts[loadout_idx];

minigame <- Ware_MinigameData();
minigame.name = "Taunt Kill";
minigame.description = "Taunt Kill!";
minigame.duration = 21.0;
minigame.location = "boxarena";
minigame.music = "morning";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.friendly_fire = false;
minigame.end_below_min = true;
minigame.end_delay = 0.6;

function OnStart()
{
	Ware_SetGlobalLoadout(loadout[0], loadout[1]);
	Ware_SetGlobalAttribute("no_attack", 1, -1);
}

function OnTakeDamage(params)
{
	return params.const_entity != params.attacker;
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker);
	local victim = GetPlayerFromUserID(params.userid);
	if (!attacker || attacker == victim)
		return;
	Ware_PassPlayer(attacker, true);
}