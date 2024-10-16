minigame <- Ware_MinigameData
({
	name           = "Change Class"
	author         = "pokemonPasta"
	duration       = 4.0
	end_delay      = 0.5
	music          = "settingthescene"
	suicide_on_end = true
	allow_suicide  = true
})

desired_class <- RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST)
desc_class <-
{
	[TF_CLASS_SCOUT]        = [ "Change Class to Scout!",    "class_scout"    ],
	[TF_CLASS_SOLDIER]      = [ "Change Class to Soldier!",  "class_soldier"  ],
	[TF_CLASS_PYRO]         = [ "Change Class to Pyro!",     "class_pyro"     ],
	[TF_CLASS_DEMOMAN]      = [ "Change Class to Demoman!",  "class_demoman"  ],
	[TF_CLASS_HEAVYWEAPONS] = [ "Change Class to Heavy!",    "class_heavy"    ],
	[TF_CLASS_ENGINEER]     = [ "Change Class to Engineer!", "class_engineer" ],
	[TF_CLASS_MEDIC]        = [ "Change Class to Medic!",    "class_medic"    ],
	[TF_CLASS_SNIPER]       = [ "Change Class to Sniper!",   "class_sniper"   ],
	[TF_CLASS_SPY]          = [ "Change Class to Spy!",      "class_spy"      ],
}

minigame.description    = desc_class[desired_class][0]
minigame.custom_overlay = desc_class[desired_class][1]

function OnPrecache()
{
	foreach (_, desired in desc_class)
		PrecacheOverlay("hud/tf2ware_ultimate/minigames/" + desired[1])
}

function OnStart()
{
	// set everyone to non-desired class
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.GetPlayerClass() != desired_class)
			continue
		
		local start_class = RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST)
		// roll til we get a non-desired class
		while (start_class == desired_class)
			start_class = RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST)
		
		Ware_SetPlayerClass(player, start_class)
	}
}

function OnGameEvent_player_changeclass(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player)
	{
		Ware_CreateTimer(function() 
		{
			if (player.IsValid())
				player.ForceRespawn()	
		}, 1.0)
	}
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (GetPropInt(player, "m_Shared.m_iDesiredPlayerClass") == desired_class)
			Ware_PassPlayer(player, true)
	}
}
