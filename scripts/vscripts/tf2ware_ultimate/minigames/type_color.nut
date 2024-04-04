local mode = RandomInt(0, 1);

minigame <- Ware_MinigameData();
minigame.name = "Type the Color";
minigame.description = mode == 0 ? "Type the text below!" : "Type the color below!"
minigame.duration = 4.0;
minigame.music = "getready";
minigame.end_delay = 0.5;
minigame.suicide_on_end = true;
minigame.custom_overlay = mode == 0 ? "type_text" : "type_color"; 
minigame.custom_overlay2 = "../chalkboard";

local first = false;
local text_color;
local answer;

local colors =
[
	"255 255 255", 
	"255 0 0", 
	"255 255 0",
	"0 0 255"
];

local text_colors =
[
	"WHITE",
	"RED",
	"YELLOW", // yellow is more distinguishable than green for colorblind players
	"BLUE",
];

function OnStart()
{
	local text_idx   = RandomInt(0, text_colors.len() - 1);
	local visual_idx = RandomInt(0, text_colors.len() - 1);
	
	text_color = text_colors[text_idx];
	local visual_color = text_colors[visual_idx];
	
	foreach (data in Ware_Players)
		Ware_ShowMinigameColorText(data.player, text_color, colors[visual_idx]);
	
	answer = mode == 0 ? text_color : visual_color;
}

function OnEnd()
{
	Ware_ChatPrint(null, "{color}The correct answer was {color}{str}", TF_COLOR_DEFAULT, CONST["COLOR_" + answer], answer);
}

function OnPlayerSay(player, text)
{	
	if (text.tolower() == answer.tolower())
	{
		if (!IsEntityAlive(player))
			return false;
		
		Ware_PassPlayer(player, true);
		if (first)
		{
			Ware_ChatPrint(null, "{player} {color}said the answer first!", player, TF_COLOR_DEFAULT);
			first = false;
		}
		return false;
	}
	else
	{
		if (Ware_IsPlayerPassed(player) || !IsEntityAlive(player))
			return true;
		
		Ware_SuicidePlayer(player);
	}
}