minigame <- Ware_MinigameData
({
	name           = "Sniper War"
	author         = "ficool2"
	description    = "Snipe a Player!"
	location       = "targetrange"
	duration       = 7.0
	end_delay      = 0.5
	music          = "nearend"
	min_players    = 2
	allow_damage   = true
	friendly_fire  = false
	custom_overlay = "snipe_player"
})

function OnTeleport(players)
{
	local red_players = []
	local blue_players = []
	foreach (player in players)
	{
		local team = player.GetTeam()
		if (team == TF_TEAM_RED)
			red_players.append(player)
		else if (team == TF_TEAM_BLUE)
			blue_players.append(player)
	}

	Ware_MinigameLocation.TeleportSides(red_players, blue_players)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Hitman's Heatmaker")
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker)
	if (attacker == null)
		return
	local victim = GetPlayerFromUserID(params.userid)
	if (victim == attacker)
		return
	Ware_PassPlayer(attacker, true)
}

function CheckEnd()
{
	return Ware_GetAlivePlayers(TF_TEAM_RED).len() == 0 || Ware_GetAlivePlayers(TF_TEAM_BLUE).len() == 0
}