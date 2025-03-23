mode <- 0
minigame <- Ware_MinigameData
({
	name           = "Buff"
	author         = ["tilderain"]
	description    = "Activate buff!"
	duration       = 15
	music          = "keepitup"
	min_players    = 2
	allow_damage   = true
	//fail_on_death  = true
})

function OnStart()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (mode == 0)
		{
			Ware_SetPlayerClass(player, TF_CLASS_SOLDIER)
			Ware_GivePlayerWeapon(player, "Buff Banner")
			Ware_GivePlayerWeapon(player, "Rocket Launcher", {"clip size bonus" : 100, "reload time decreased": 0.1})
		}
		else if (mode == 1)
		{
			//Flamethrower sucks against pyro so this probably won't work
			Ware_SetPlayerClass(player, TF_CLASS_PYRO)
			Ware_GivePlayerWeapon(player, "Phlogistinator", { "damage bonus" : 3})
			Ware_RemovePlayerAttribute(player, "afterburn immunity")
		}
		player.SetHealth(1000)
		player.SetRageMeter(0)
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.IsRageDraining())
			Ware_PassPlayer(player, true)
		//Don't know how to show rage meter hud
		Ware_ShowText(player, CHANNEL_MINIGAME, format("Rage: %.1f", player.GetRageMeter()), 0.4)
	}
	
}

function OnCleanup()
{
	foreach (player in Ware_MinigamePlayers)
	{
		SetPropBool(player, "m_Shared.m_bRageDraining", false)
	}
}