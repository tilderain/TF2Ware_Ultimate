minigame <- Ware_MinigameData
({
	name          = "Taunt Kill"
	author        = "ficool2"
	description   = "Taunt Kill!"
	duration      = 21.0
	end_delay     = 0.6
	location      = "boxarena"
	music         = "morning"
	min_players   = 2
	max_scale     = 1.5
	allow_damage  = true
	friendly_fire = false
	collisions    = true
})

loadouts <-
[
	[ TF_CLASS_SCOUT,        "Sandman"          ],
	[ TF_CLASS_SOLDIER,      "Equalizer"        ],
	[ TF_CLASS_PYRO,         "Flare Gun"        ],
	[ TF_CLASS_PYRO,         "Rainblower"       ],
	[ TF_CLASS_PYRO,         "Scorch Shot"      ],
	[ TF_CLASS_DEMOMAN,      "Eyelander"        ],
	[ TF_CLASS_HEAVYWEAPONS, "Fists"            ],
	[ TF_CLASS_ENGINEER,     "Frontier Justice" ],
	[ TF_CLASS_ENGINEER,     "Gunslinger"       ],
	[ TF_CLASS_MEDIC,        "Ubersaw"          ],
	[ TF_CLASS_SNIPER,       "Huntsman"         ],
	[ TF_CLASS_SPY,          "Knife"            ],
]

// some taunts don't friendlyfire
function OnPick()
{
	return Ware_ArePlayersOnBothTeams()
}

function OnStart()
{
	local loadout = RandomElement(loadouts)
	Ware_SetGlobalLoadout(loadout[0], loadout[1])
	Ware_SetGlobalAttribute("no_attack", 1, -1)
}

function OnTakeDamage(params)
{
	return params.const_entity != params.attacker
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker)
	local victim = GetPlayerFromUserID(params.userid)
	if (!attacker || attacker == victim)
		return
	Ware_PassPlayer(attacker, true)
}

function OnCheckEnd()
{
	return Ware_GetAlivePlayers().len() <= 1
}