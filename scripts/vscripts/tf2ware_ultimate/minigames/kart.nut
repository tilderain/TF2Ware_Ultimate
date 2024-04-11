
local mode = RandomInt(0, 2);

minigame <- Ware_MinigameData();
minigame.name = "Kart Race";
minigame.duration = 50.0;
minigame.music = "";
minigame.description = "Race to the End!";
minigame.allow_damage = true;
minigame.fail_on_death = true;

local tracks =
[
	"kart_containers",
	"kart_paths",
	"kart_ramp",
];

minigame.location = tracks[mode];

