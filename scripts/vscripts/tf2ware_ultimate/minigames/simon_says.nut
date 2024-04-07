local simon    = RandomInt(0, 1);
local mode     = RandomInt(0, 6);
local suffixes = ["Taunt", "Jump", "Crouch", "Medic", "Eat", "Drink", "Inspect"];

minigame <- Ware_MinigameData();
minigame.name = "Simon Says";
minigame.description = "Simon says..."
minigame.duration = 4.0;
minigame.music = "clumsy";
minigame.start_pass = simon == 0;
minigame.custom_overlay = format("%s_says_%s", simon ? "simon" : "someone", suffixes[mode].tolower()); 
minigame.description = format("%s says %s!", simon ? "Simon" : "Someone", suffixes[mode]);

function OnStart()
{
	if (mode == 4)
	{
		local items = ["Sandvich", "Dalokohs Bar", "Fishcake", "Buffalo Steak Sandvich", "Second Banana"];
		Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, items[RandomIndex(items)]);
	}
	else if (mode == 5)
	{
		local items = ["Bonk! Atomic Punch", "Crit-a-Cola"];
		Ware_SetGlobalLoadout(TF_CLASS_SCOUT, items[RandomIndex(items)]);
	}
}

function PassOrFailPlayer(player, pass)
{
	Ware_PassPlayer(player, pass);
	if (!pass)
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/" + "simon_says_fail");
}
	
if (mode == 3 || mode == 4 || mode == 5)
{
	function OnPlayerVoiceline(player, voiceline)
	{
		local pass = simon == 0;
		if (Ware_IsPlayerPassed(player) != pass)
			return;
			
		if (mode == 5)
		{
			if (voiceline.find("taunt04") != null)
				PassOrFailPlayer(player, !pass);
		}
		else
		{
			if (voiceline in VCD_MAP)
			{
				if (mode == 3)
				{				
					if (VCD_MAP[voiceline].find(".Medic") != null)
						PassOrFailPlayer(player, !pass);
				}
				else if (mode == 4)
				{
					if (VCD_MAP[voiceline] == "Heavy.SandwichEat")
						PassOrFailPlayer(player, !pass);			
				}
			}
		}
	}
}
else
{
	function OnUpdate()
	{	
		if (Ware_GetMinigameTime() < 1.0) // grace period
			return;
				
		local pass = simon == 0;
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player;
			if (Ware_IsPlayerPassed(data.player) != pass)
				continue;
				
			if (mode == 0)
			{
				if (player.IsTaunting())
					PassOrFailPlayer(player, !pass);
			}
			else if (mode == 1)
			{
				if (GetPropBool(player, "m_Shared.m_bJumping"))
					PassOrFailPlayer(player, !pass);
			}
			else if (mode == 2)
			{
				if (player.GetFlags() & FL_DUCKING)
					PassOrFailPlayer(player, !pass);
			}	
			else if (mode == 6)
			{
				local weapon = player.GetActiveWeapon();
				if (weapon && GetPropInt(weapon, "m_nInspectStage") >= 0)
					PassOrFailPlayer(player, !pass);
			}
		}
	}
}

function OnEnd()
{
	if (mode == 4 || mode == 5)
	{
		foreach (data in Ware_MinigamePlayers)
		{
			data.player.RemoveCond(TF_COND_PHASE);
			data.player.RemoveCond(TF_COND_ENERGY_BUFF);
		}
	}
}