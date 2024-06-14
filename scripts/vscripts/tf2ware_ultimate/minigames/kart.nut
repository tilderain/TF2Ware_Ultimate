minigame <- Ware_MinigameData
({
	name          = "Kart Race"
	author        = "pokemonPasta"
	music         = "moomoofarm"
	description   = "Race to the End!"
	end_delay     = 0.5
	allow_damage  = true
	fail_on_death = true
	collisions    = true
})

tracks <-
[  // location          endzone vectors              duration
	["kart_containers", Vector(-1250, 4450, -5960),  26.5],
	["kart_paths",      Vector(-7000, 9850, -6047),  26.5],
	["kart_ramp",       Vector(-8000, -6475, -6527), 10.0],
]

mode <- RandomInt(0, 2)

minigame.location    = tracks[mode][0]
endzone_vector      <- tracks[mode][1]
minigame.duration    = tracks[mode][2]

function OnStart()
{
	// put everyone in karts and freeze them
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		player.AddCond(TF_COND_HALLOWEEN_KART)
		player.AddCond(TF_COND_HALLOWEEN_KART_CAGE)
	}
	
	// start a countdown
	local timer = 3
	Ware_CreateTimer(function()
	{
		Ware_ShowGlobalScreenOverlay(format("hud/tf2ware_ultimate/countdown_%s", timer.tostring()))
		if (timer > 0)
		{
			PrecacheSound(format("vo/announcer_begins_%ssec.mp3", timer.tostring()))
			PlaySoundOnAllClients(format("vo/announcer_begins_%ssec.mp3", timer.tostring()), 1.0, 100 * Ware_GetPitchFactor())
		}
		
		timer--
		
		if (timer >= 0)
			return 1.0
		else
		{
			// when hits 0, unfreeze players
			foreach(data in Ware_MinigamePlayers)
				data.player.RemoveCond(TF_COND_HALLOWEEN_KART_CAGE)
			Ware_ShowGlobalScreenOverlay("hud/tf2ware_ultimate/minigames/kart")
		}
	}, 0.0)
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (IsEntityAlive(player) &&
			player.GetOrigin().x > endzone_vector.x &&
			player.GetOrigin().y > endzone_vector.y &&
			player.GetOrigin().z > endzone_vector.z)
		{
			Ware_PassPlayer(player, true)
		}
	}
}

function CheckEnd()
{
    return Ware_GetAlivePlayers().len() == 0
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		player.RemoveCond(TF_COND_HALLOWEEN_KART)
	}
}
