
local mode = RandomInt(0, 2);

minigame <- Ware_MinigameData();
minigame.name = "Kart Race";
minigame.music = "moomoofarm";
minigame.description = "Race to the End!";
minigame.allow_damage = true;
minigame.fail_on_death = true;

local tracks =
{  //mode           location          endzone vectors              duration
	[0]         = ["kart_containers", Vector(-1250, 4450, -5960),  30.0],
	[1]         = ["kart_paths",      Vector(-7000, 9850, -6047),  30.0],
	[2]         = ["kart_ramp",       Vector(-8000, -6475, -6527), 20.0],
};

minigame.location    = tracks[mode][0];
local endzone_vector = tracks[mode][1];
minigame.duration    = tracks[mode][2];

function OnStart()
{
	// put everyone in karts and freeze them
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.AddCond(TF_COND_HALLOWEEN_KART);
		player.AddCond(TF_COND_HALLOWEEN_KART_CAGE);
	}
	
	// start a countdown from 5
	local timer = 5;
	Ware_CreateTimer(function()
	{
		Ware_ShowGlobalScreenOverlay(format("hud/tf2ware_ultimate/countdown_%s", timer.tostring()));
		PrecacheSound(format("vo/announcer_begins_%ssec.mp3", timer.tostring()));
		if (timer > 0)
			PlaySoundOnAllClients(format("vo/announcer_begins_%ssec.mp3", timer.tostring()), 1.0, 100 * Ware_GetPitchFactor());
		
		timer--;
		
		if (timer >= 0)
			return 1.0;
		else
		{
			// when hits 0, unfreeze players
			foreach(data in Ware_MinigamePlayers)
				data.player.RemoveCond(TF_COND_HALLOWEEN_KART_CAGE);
			Ware_ShowGlobalScreenOverlay("hud/tf2ware_ultimate/minigames/kart");
		}
	}, 0.0);
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (IsEntityAlive(player) &&
		player.GetOrigin().x > endzone_vector.x &&
		player.GetOrigin().y > endzone_vector.y &&
		player.GetOrigin().z > endzone_vector.z)
			Ware_PassPlayer(player, true);
	}
}

function OnEnd()
{
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_HALLOWEEN_KART);
	}
}
