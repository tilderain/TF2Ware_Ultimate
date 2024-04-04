minigame <- Ware_MinigameData();
minigame.name = "Math";
minigame.description = "Type the answer!"
minigame.duration = 5.0;
minigame.music = "question";
minigame.custom_overlay = "type_answer";
minigame.custom_overlay2 = "../chalkboard";
minigame.end_delay = 0.5;
minigame.suicide_on_end = true;

local a, b;
local operator;
local answer;
local first = true;

function OnStart()
{
	local mode = RandomInt(0, 2);
	if (mode == 0)
	{
		if (RandomInt(0, 49) == 0)
		{
			a = RandomInt(1, 9) * 1000;
			b = 9001 - a;
		}
		else
		{
			a = RandomInt(3, 15);
			b = RandomInt(3, 15);
		}
		
		answer = a + b;
		operator = "+";
	}
	else if (mode == 1)
	{
		a = RandomInt(3, 15);
		b = RandomInt(3, 15);
		answer = a - b;
		operator = "-";
	}
	else if (mode == 2)
	{
		a = RandomInt(2, 12);
		b = RandomInt(2, 12);
		answer = a * b;
		operator = "*";
	}
	
	local text = Ware_Format("%d %s %d = ?", a, operator, b);
	foreach (data in Ware_Players)
		Ware_ShowMinigameText(data.player, text);
}

function OnEnd()
{
	Ware_ChatPrint(null, "{color}The correct answer was {color}{int}", TF_COLOR_DEFAULT, COLOR_LIME, answer);
}

function OnPlayerSay(player, text)
{
	try
	{
		local num = text.tointeger();
		if (num != answer)
			throw "wrong";
		if (Ware_IsPlayerPassed(player))
			return false;
		if (!IsEntityAlive(player))
			return false;
			
		local text = Ware_Format("%d %s %d = %d", a, operator, b, num);
		Ware_ShowMinigameText(player, text);
		Ware_PassPlayer(player, true);
		
		if (first)
		{
			Ware_ChatPrint(null, "{player} {color}guessed the answer first!", player, TF_COLOR_DEFAULT);
			first = false;
		}
		
		return false;
	}
	catch (error)
	{
		if (IsEntityAlive(player) && !Ware_IsPlayerPassed(player))
		{
			local text = Ware_Format("%d %s %d = %s", a, operator, b, text);
			Ware_ShowMinigameText(player, text);		
			Ware_SuicidePlayer(player);
		}
		
		return true;
	}
}