local class_names = 
{
	[TF_CLASS_SCOUT]        = "scout",
	[TF_CLASS_SOLDIER]      = "soldier",
	[TF_CLASS_PYRO]         = "pyro",
	[TF_CLASS_DEMOMAN]      = "demo",
	[TF_CLASS_HEAVYWEAPONS] = "heavy",
	[TF_CLASS_ENGINEER]     = "engineer",
	[TF_CLASS_MEDIC]        = "medic",
	[TF_CLASS_SNIPER]       = "sniper",
	[TF_CLASS_SPY]          = "spy",
};

// unfortunately have to exclude spy because you cannot disguise as a friendly spy
local class_idx = RandomInt(TF_CLASS_FIRST, TF_CLASS_SPY);
if (class_idx == TF_CLASS_SPY)
	class_idx = TF_CLASS_ENGINEER;
	
local team_idx = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);

minigame <- Ware_MinigameData();
minigame.name = "Disguise";
minigame.description = "Match the Disguise!"
minigame.duration = 6.0;
minigame.music = "circus";
minigame.min_players = 2;
minigame.end_delay = 0.5;
minigame.suicide_on_end = true;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit");
	
	local pos = Ware_MinigameLocation.center;
	local match = Ware_SpawnEntity("prop_dynamic",
	{
		model = format("models/player/%s.mdl", class_names[class_idx]),
		origin = pos,
		skin = team_idx - 2,
		modelscale = 1.25,
		defaultanim = RandomInt(0, 1) ? "taunt_aerobic_A" : "taunt_aerobic_B"
	});
	SendGlobalGameEvent("show_annotation",
	{
		worldPosX       = pos.x,
		worldPosY       = pos.y,
		worldPosZ       = pos.z + 128.0,
		id              = 1,
		text            = "MATCH ME!",
		lifetime        = minigame.duration,
		show_distance   = false,
		show_effect     = false,	
	});
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (player.InCond(TF_COND_DISGUISED))
		{
			if (GetPropInt(player, "m_Shared.m_nDisguiseClass") == class_idx)
			{
				if (GetPropInt(player, "m_Shared.m_nDisguiseTeam") == team_idx)
					Ware_PassPlayer(player, true);
				else
					Ware_ChatPrint(player, "{color}You didn't match the disguise team!", TF_COLOR_DEFAULT);
			}
			else
			{
				Ware_ChatPrint(player, "{color}You didn't match the disguise class!", TF_COLOR_DEFAULT);
			}
		}
	}
}