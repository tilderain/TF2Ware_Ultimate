minigame <- Ware_MinigameData
({
	name        = "Hit the Balls!"
	author      = "ficool2"
	description = "Hit the balls to the other side!"
	duration    = 20.0
	end_delay   = 1.0
	location    = "boxarena"
	music       = "knockout"
	min_players = 2
})

ball_model <- "models/player/items/scout/soccer_ball.mdl"
beam_model <- "sprites/laser.vmt"
end_sound <- "player/taunt_bell.wav"
PrecacheModel(ball_model)
PrecacheModel(beam_model)
PrecacheSound(end_sound)

ball_count <- 0
ball_max_count <- 0

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
	
	Ware_TeleportPlayersRow(red_players,
		Ware_MinigameLocation.center + Vector(0, 500.0, 0),
		QAngle(0, 270, 0),
		1300.0,
		65.0, 65.0)
	Ware_TeleportPlayersRow(blue_players,
		Ware_MinigameLocation.center + Vector(0, -500.0, 0),
		QAngle(0, 90, 0),
		1300.0,
		65.0, 65.0)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Necro Smasher")

	local beam = Ware_CreateEntity("env_beam")
	beam.SetOrigin(Ware_MinigameLocation.center + Vector(-1000, 0, 64))
	SetPropVector(beam, "m_vecEndPos", Ware_MinigameLocation.center + Vector(1000, 0, 64))
	beam.SetModel(beam_model)
	beam.KeyValueFromString("rendercolor", "255 255 0")
	beam.KeyValueFromInt("renderamt", 100)
	beam.DispatchSpawn()
	SetPropFloat(beam, "m_fWidth", 7.0)
	SetPropFloat(beam, "m_fEndWidth", 7.0)
	EntFireByHandle(beam, "TurnOn", "", -1, null, null)
	
	local barrier = Ware_CreateEntity("func_brush")
	barrier.SetOrigin(Ware_MinigameLocation.center)
	barrier.SetSolid(SOLID_BBOX)
	barrier.SetSize(Vector(-1000, -16, 0), Vector(1000, 16, 1000))
	barrier.SetCollisionGroup(TFCOLLISION_GROUP_RESPAWNROOMS)
	
	ball_max_count = Ware_MinigamePlayers.len() > 24 ? 20 : 10
	Ware_CreateTimer(@() SpawnBalls(), 0.1)
}

function SpawnBalls()
{
	local ball = Ware_SpawnEntity("prop_soccer_ball",
	{
		model = ball_model,
		origin = Ware_MinigameLocation.center + Vector(RandomFloat(-700, 700), 320.0, 100),
		skin = 0,
	})
	ball.AddFlag(FL_DONTTOUCH)
	ball = Ware_SpawnEntity("prop_soccer_ball",
	{
		model = ball_model,
		origin = Ware_MinigameLocation.center + Vector(RandomFloat(-700, 700), -320.0, 100),
		skin = 1,
	})
	ball.AddFlag(FL_DONTTOUCH)
	
	if (++ball_count < ball_max_count)
		return 0.1
}

function OnEnd()
{
	PlaySoundOnAllClients(end_sound)
	PlaySoundOnAllClients(end_sound)
	
	local red_score = 0
	local blue_score = 0
	for (local ball; ball = FindByClassname(ball, "prop_soccer_ball");)
	{
		if (ball.GetOrigin().y < Ware_MinigameLocation.center.y)
			red_score++
		else
			blue_score++
	}
	
	Ware_ChatPrint(null, "{color}RED{color} score: {int}", 
		TF_COLOR_RED, TF_COLOR_DEFAULT, red_score)
	Ware_ChatPrint(null, "{color}BLU{color} score: {int}", 
		TF_COLOR_BLUE, TF_COLOR_DEFAULT, blue_score)
	
	local winning_team
	if (blue_score > red_score)
		winning_team = TF_TEAM_BLUE
	else if (red_score > blue_score)
		winning_team = TF_TEAM_RED
	
	if (winning_team)
	{
		foreach (data in Ware_MinigamePlayers)
		{
			if (data.player.GetTeam() == winning_team)
				Ware_PassPlayer(data.player, true)
		}
	}
}