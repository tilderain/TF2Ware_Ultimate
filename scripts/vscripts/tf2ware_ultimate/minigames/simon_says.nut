simon    <- RandomInt(0, 1)
mode     <- RandomInt(0, 8)
suffixes <- ["Taunt", "Jump", "Crouch", "Medic", "Eat", "Drink", "Inspect", "Horn", "Type"]

minigame <- Ware_MinigameData
({
	name           = "Simon Says"
	author         = ["Mecha the Slag", "Gemidyne", "ficool2"]
	description    = "Simon says..."
	duration       = 4.0
	music          = "clumsy"
	start_pass     = simon == 0
	custom_overlay = format("%s_says_%s", simon ? "simon" : "someone", suffixes[mode].tolower())
	description    = format("%s says %s!", simon ? "Simon" : "Someone", suffixes[mode])
})

function OnPrecache()
{
	foreach (suffix in suffixes)
	{
		PrecacheOverlay("hud/tf2ware_ultimate/minigames/simon_says_" + suffix.tolower())
		PrecacheOverlay("hud/tf2ware_ultimate/minigames/someone_says_" + suffix.tolower())
	}
	
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/simon_says_fail")
}

function OnStart()
{
	if (mode == 4)
	{
		local items = ["Sandvich", "Dalokohs Bar", "Fishcake", "Buffalo Steak Sandvich", "Second Banana"]
		Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, RandomElement(items))
	}
	else if (mode == 5)
	{
		local items = ["Bonk! Atomic Punch", "Crit-a-Cola"]
		Ware_SetGlobalLoadout(TF_CLASS_SCOUT, RandomElement(items))
	}
	else if (mode == 7)
	{
		Ware_SetGlobalCondition(TF_COND_HALLOWEEN_KART)
	}
}

function PassOrFailPlayer(player, pass)
{
	Ware_PassPlayer(player, pass)
	if (!pass)
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/simon_says_fail")
}
	
if (mode == 3 || mode == 4 || mode == 5)
{
	function OnPlayerVoiceline(player, voiceline)
	{
		local pass = simon == 0
		if (Ware_IsPlayerPassed(player) != pass)
			return
			
		if (mode == 5)
		{
			if (voiceline.find("taunt04") != null)
				PassOrFailPlayer(player, !pass)
		}
		else
		{
			if (voiceline in VCD_MAP)
			{
				if (mode == 3)
				{				
					if (VCD_MAP[voiceline].find(".Medic") != null)
						PassOrFailPlayer(player, !pass)
				}
				else if (mode == 4)
				{
					if (VCD_MAP[voiceline] == "Heavy.SandwichEat")
						PassOrFailPlayer(player, !pass)
				}
			}
		}
	}
}
else if (mode == 7)
{
	function OnPlayerHorn(player)
	{
		local pass = simon == 0
		PassOrFailPlayer(player, !pass)
	}
}
else if(mode == 8)
{
	function OnPlayerSay(player, text)
	{
		local pass = simon == 0
		PassOrFailPlayer(player, !pass)
	}
}
else
{
	function OnUpdate()
	{	
		if (Ware_GetMinigameTime() < 1.0) // grace period
			return
				
		local pass = simon == 0
		foreach (player in Ware_MinigamePlayers)
		{
			if (Ware_IsPlayerPassed(player) != pass)
				continue
				
			if (mode == 0)
			{
				if (player.IsTaunting())
					PassOrFailPlayer(player, !pass)
			}
			else if (mode == 1)
			{
				if (GetPropBool(player, "m_Shared.m_bJumping"))
					PassOrFailPlayer(player, !pass)
			}
			else if (mode == 2)
			{
				if (player.GetFlags() & FL_DUCKING)
					PassOrFailPlayer(player, !pass)
			}	
			else if (mode == 6)
			{
				local weapon = player.GetActiveWeapon()
				if (weapon && GetPropInt(weapon, "m_nInspectStage") >= 0)
					PassOrFailPlayer(player, !pass)
			}
		}
	}
}

function OnEnd()
{
	if (mode == 4 || mode == 5)
	{
		foreach (player in Ware_MinigamePlayers)
		{
			player.RemoveCond(TF_COND_PHASE)
			player.RemoveCond(TF_COND_ENERGY_BUFF)
		}
	}
}