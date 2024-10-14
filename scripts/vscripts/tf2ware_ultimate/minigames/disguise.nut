minigame <- Ware_MinigameData
({
	name           = "Disguise"
	author         = "ficool2"
	description    = "Match the Disguise!"
	duration       = 6.0
	end_delay      = 0.5
	music          = "circus"
	suicide_on_end = true
})

class_names <- 
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
}

// unfortunately have to exclude spy because you cannot disguise as a friendly spy
class_idx <- RandomInt(TF_CLASS_FIRST, TF_CLASS_SPY)
if (class_idx == TF_CLASS_SPY)
	class_idx = TF_CLASS_ENGINEER
	
team_idx <- RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit")
	
	local pos = Ware_MinigameLocation.center
	local match = Ware_SpawnEntity("prop_dynamic",
	{
		model       = format("models/player/%s.mdl", class_names[class_idx])
		origin      = pos
		skin        = team_idx - 2
		modelscale  = 1.25
		defaultanim = RandomBool() ? "taunt_aerobic_A" : "taunt_aerobic_B"
	})
	Ware_ShowAnnotation(pos + Vector(0, 0, 128), "MATCH ME!")
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.InCond(TF_COND_DISGUISED) || player.InCond(TF_COND_DISGUISING))
		{
			if (GetPropInt(player, "m_Shared.m_nDisguiseClass") == class_idx
				|| GetPropInt(player, "m_Shared.m_nDesiredDisguiseClass") == class_idx)
			{
				if (GetPropInt(player, "m_Shared.m_nDisguiseTeam") == team_idx
					|| GetPropInt(player, "m_Shared.m_nDesiredDisguiseTeam") == team_idx)
				{
					Ware_PassPlayer(player, true)
				}
				else
				{
					Ware_ChatPrint(player, "You didn't match the disguise team!")
				}
			}
			else
			{
				Ware_ChatPrint(player, "You didn't match the disguise class!")
			}
		}
	}
}