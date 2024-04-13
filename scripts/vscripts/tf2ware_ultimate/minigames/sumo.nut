
local mode = RandomInt(0, 1);

minigame <- Ware_MinigameData();
minigame.name = "Sumo Kart";
minigame.music = "underwater";
minigame.duration = 15.0;
minigame.description = "Push Away the Enemies!";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.start_pass = true;
minigame.end_delay = 0.5

local arena =
[
	"circlepit"
	"sumobox"
];

minigame.location = arena[mode];


function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.AddCond(TF_COND_HALLOWEEN_KART);
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0;
}

function OnCleanup()
{
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_HALLOWEEN_KART);
	}
}
