mode <- RandomInt(0, 1)

minigame <- Ware_MinigameData
({
	name            = "Type the Color"
	author          = "ficool2"
	description     = mode == 0 ? "Type the text below!" : "Type the color below!"
	duration        = 4.0
	end_delay       = 0.5
	music           = "getready"
	custom_overlay  = mode == 0 ? "type_text" : "type_color"
	custom_overlay2 = "../chalkboard"
	suicide_on_end  = true
})

first <- false

text_color <- null
visual_color <- null
answer <- null

colors <-
[
	"255 255 255",
	"255 0 0",
	"255 255 0"
	"0 0 255"
]

text_colors <-
[
	"WHITE"
	"RED"
	"YELLOW" // yellow is more distinguishable than green for colorblind players
	"BLUE"
]

function OnStart()
{
	local text_idx   = RandomIndex(text_colors)
	local visual_idx = RandomIndex(text_colors)
	
	text_color = text_colors[text_idx]
	visual_color = text_colors[visual_idx]

	Ware_ShowMinigameText(null, text_color, colors[visual_idx])
	
	answer = mode == 0 ? text_color : visual_color
}

function OnEnd()
{
	Ware_ChatPrint(null, "{color}The correct answer was {color}{str}", TF_COLOR_DEFAULT, CONST["COLOR_" + answer], answer)
}

function OnPlayerSay(player, text)
{	
	if (text.tolower() == answer.tolower())
	{
		if (!IsEntityAlive(player))
			return false
		
		Ware_PassPlayer(player, true)
		if (first)
		{
			Ware_ChatPrint(null, "{player} {color}said the answer first!", player, TF_COLOR_DEFAULT)
			first = false
		}
		return false
	}
	else
	{
		if (Ware_IsPlayerPassed(player) || !IsEntityAlive(player))
			return true
		
		Ware_SuicidePlayer(player)
	}
}