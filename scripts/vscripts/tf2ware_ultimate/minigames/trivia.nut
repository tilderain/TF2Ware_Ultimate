
minigame <- Ware_MinigameData
({
	name          = "Trivia"
	author        = "pokemonPasta"
	music         = "golden"
	duration      = 11.0
	end_delay     = 0.2
	description   = "Answer the Question!"
	location      = "inventoryday"
	collisions    = false
	thirdperson   = true
	convars       = 
	{
		tf_avoidteammates = 0
	}
})

choices <- [
	{
		name = "A"
		door = FindByName(null, "plugin_PCBoss_Door1")
		brush = FindByName(null, "plugin_PCBoss_Hurt1")
		value = ""
	}
	{
		name = "B"
		door = FindByName(null, "plugin_PCBoss_Door2")
		brush = FindByName(null, "plugin_PCBoss_Hurt2")
		value = ""
	}
	{
		name = "C"
		door = FindByName(null, "plugin_PCBoss_Door3")
		brush = FindByName(null, "plugin_PCBoss_Hurt3")
		value = ""
	}
]

function OnPick()
{
	// don't allow this minigame near start of the round
	return Ware_MinigamesPlayed >= 3
}

function OnTeleport(players)
{
	local pos = Ware_MinigameLocation.side
	local ang = QAngle(0, -25, 0)
	foreach (player in players)
		Ware_TeleportPlayer(player, pos, ang, vec3_zero)
}

function OnStart()
{
	Ware_SetGlobalAttribute("no_attack", 1, -1)
	Ware_SetGlobalAttribute("voice pitch scale", 0, -1)
	foreach (player in Ware_MinigamePlayers)
	{
		player.AddCond(TF_COND_GRAPPLED_TO_PLAYER) // prevent taunting
		player.RemoveCond(TF_COND_TELEPORTED)
		player.AddHudHideFlags(HIDEHUD_TARGET_ID)
		SetPropInt(player, "m_nRenderMode", kRenderNone)
		Ware_TogglePlayerWearables(player, false)
	}
	
	local minigame_names = Ware_PreviousMinigames.map(@(value) value.name)
	local questions = [
		{
			name = "first"
			string = "What was the first minigame this round?"
			correct_answer = minigame_names[0]
			answers = minigame_names
		},
		{
			name = "previous"
			string = "What minigame did we just play?"
			correct_answer = minigame_names[Ware_MinigamesPlayed - 1]
			answers = minigame_names
		},
		{
			name = "howmany"
			string = "How many minigames have there been this round?"
			correct_answer = Ware_MinigamesPlayed.tostring()
			answers = FillArray(1, Ware_BossThreshold).map(@(value) value.tostring())
		}
	]

	
	question <- RandomElement(questions)
	correct_choice <- RandomElement(choices)
	
	// show the question
	Ware_ShowMinigameText(null, question.string)
	Ware_ChatPrint(null, "{color}QUESTION: {color}{str}", COLOR_GREEN, TF_COLOR_DEFAULT, question.string)
	
	// remove the correct answer from the wrong answers
	local answers = question.answers
	local idx = answers.find(question.correct_answer)
	while (idx != null){
		answers.remove(idx)
		idx = answers.find(question.correct_answer)
	}
	
	// answers
	foreach(choice in choices)
	{
		EntityAcceptInput(choice.door, "Open")
		local brush = choice.brush
		EntityAcceptInput(brush, "SetDamage", "0.0")
		brush.ValidateScriptScope()
		local scope = brush.GetScriptScope()
		if (choice == correct_choice)
		{
			choice.value = question.correct_answer
			scope.OnStartTouch <- OnCorrectTouch
		}
		else
		{
			choice.value = RemoveRandomElement(question.answers)
			scope.OnStartTouch <- OnIncorrectTouch
		}
		scope.ResetPlayer <- ResetPlayer
		Ware_ShowAnnotation(brush.GetOrigin(), format("%s: %s", choice.name, choice.value))
		brush.ConnectOutput("OnStartTouch", "OnStartTouch")
	}
}

function ResetPlayer(player)
{
	Ware_RemovePlayerAttribute(player, "voice pitch scale")
	Ware_RemovePlayerAttribute(player, "no_attack")
	Ware_TogglePlayerWearables(player, true)
	SetPropInt(player, "m_nRenderMode", kRenderNormal)
	player.RemoveHudHideFlags(HIDEHUD_TARGET_ID)
	player.RemoveCond(TF_COND_GRAPPLED_TO_PLAYER)
}

function OnCorrectTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		ResetPlayer(player)
		Ware_Location.beach.Teleport([player])
		Ware_PassPlayer(player, true)
	}
}

function OnIncorrectTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		ResetPlayer(player)
		Ware_PlaySoundOnClient(player, "vo/engineer_No01.mp3")
		Ware_Location.abcdeathpit.Teleport([player])
	}
}

function OnUpdate()
{
	// prevent spraying
	local sprays = FindAllOfEntity("spraycan")
	foreach (spray in sprays)
	{
		spray.StopSound("SprayCan.Paint")
		spray.Kill()
	}
}

function OnEnd()
{
	Ware_ChatPrint(null, "The correct answer was {color}{str}{color}!",
		COLOR_GREEN, question.correct_answer, TF_COLOR_DEFAULT)
	
	foreach(choice in choices)
		choice.brush.DisconnectOutput("OnStartTouch", "OnStartTouch")
}

function OnCleanup()
{
	foreach (player in Ware_MinigamePlayers)
		ResetPlayer(player)
}