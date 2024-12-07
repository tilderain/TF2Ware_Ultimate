
minigame <- Ware_MinigameData
({
	name          = "Trivia"
	author        = "pokemonPasta"
	music         = "golden"
	duration      = 11.0
	end_delay     = 0.2
	description   = "Answer the Question!"
	location      = "inventoryday"
	fail_on_death = true
	collisions    = false
	
	min_players = Ware_MinigamesPlayed < 3 ? INT_MAX : 1 // disallow if near start of the round
})

minigame_names <- Ware_PreviousMinigames.map(function(value){
	return value.name
})

questions <- [
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
		answers = FillArray(1, Ware_BossThreshold).map(function(value){
			return value.tostring()
		})
	}
]

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

function OnTeleport(players)
{
	Ware_MinigameLocation.Teleport(players)
	foreach(player in players)
		Ware_TeleportPlayer(player, null, ang_zero, null)
}

function OnStart()
{
	Ware_SetGlobalCondition(TF_COND_SPEED_BOOST)
	
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
		
		Ware_ShowAnnotation(brush.GetOrigin(), format("%s: %s", choice.name, choice.value))
		brush.ConnectOutput("OnStartTouch", "OnStartTouch")
	}
}

function OnCorrectTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		Ware_Location.beach.Teleport([player])
		Ware_PassPlayer(player, true)
	}
}

function OnIncorrectTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		Ware_Location.abcdeathpit.Teleport([player])
	}
}

function OnEnd()
{
	Ware_ChatPrint(null, "The correct answer was \"{color}{str}{color}\"!", COLOR_GREEN, question.correct_answer, TF_COLOR_DEFAULT)
	
	foreach(choice in choices)
		choice.brush.DisconnectOutput("OnStartTouch", "OnStartTouch")
		
	foreach(id in minigame.annotations) // TODO: this shouldn't be necessary, why isn't this working in main.nut?
		Ware_HideAnnotation(id)
}
