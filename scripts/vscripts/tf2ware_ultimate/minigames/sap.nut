minigame <- Ware_MinigameData
({
	name           = "Sap a Building"
	author         = "pokemonPasta"
	description    = 
	[
		"Sap a Building!"
		"Get a Building Sapped!"
	]
	duration       = 4.0
	music          = "funkymoves"
	custom_overlay = 
	[
		"sap_spy"
		"sap_engi"
	]
	min_players    = 2
	// allow damage so sappers work, but prevent player damage
	allow_damage   = true
	friendly_fire  = false
})

function OnStart()
{
	local engi_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
					
		if (player.GetTeam() == engi_team)
		{
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_ENGINEER)
			Ware_GivePlayerWeapon(player, "Toolbox")
			Ware_GivePlayerWeapon(player, "Construction PDA")
		}
		else
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_SPY)
			Ware_GivePlayerWeapon(player, "Sapper")
		}
	}
}

function OnTakeDamage(params)
{
	if (params.const_entity.IsPlayer())
		return false
}

function OnGameEvent_player_sapped_object(params)
{
	local spy = GetPlayerFromUserID(params.userid)
	local engi = GetPlayerFromUserID(params.ownerid)
	
	if (spy)
		Ware_PassPlayer(spy, true)
	if (engi)
		Ware_PassPlayer(engi, true)
}
