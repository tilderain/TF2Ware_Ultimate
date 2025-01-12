minigame <- Ware_MinigameData
({
	name           = "Typing"
	author         = "ficool2"
	description    = "Type each word as fast as you can!"
	duration       = 210.0
	end_delay      = 5.0
	location       = "typing"
	music          = null
	custom_overlay = ""
})

sound_boss_start       <- "TF2Ware_Ultimate.TypingBossStart"
sound_descent_begin    <- "TF2Ware_Ultimate.TypingDescentBegin"
sound_spiral_inward    <- "TF2Ware_Ultimate.TypingSpiralInward"
sound_bad_end          <- "TF2Ware_Ultimate.TypingBadEnd"
sound_good_end         <- "TF2Ware_Ultimate.TypingGoodEnd"
sound_level_up         <- "TF2Ware_Ultimate.TypingLevelUp"
sound_difficulty_up    <- "TF2Ware_Ultimate.TypingDifficultyUp"
sound_overview_start   <- "TF2Ware_Ultimate.TypingOverviewStart"
sound_word_start       <- "TF2Ware_Ultimate.TypingWordStart"
sound_word_fail        <- "TF2Ware_Ultimate.TypingWordFail"
sound_word_success     <- "TF2Ware_Ultimate.TypingWordSuccess"
sound_word_relax       <- "TF2Ware_Ultimate.TypingWordRelax"

overlay_type         <- "hud/tf2ware_ultimate/minigames/typing"
overlay_prepare      <- "hud/tf2ware_ultimate/minigames/typing_prepare"
overlay_announcement <- "hud/tf2ware_ultimate/minigames/announcement"
overlay_difficulty   <- "hud/tf2ware_ultimate/minigames/typing_difficulty"

music_choices <- ["hga", "hvd", "lod", "pta", "spc", "tuh"]
current_music <- null

difficulties <- ["Easy", "Medium", "Hard"]
difficulty <- 0
level <- 0

dictionary <- {}
IncludeScript("tf2ware_ultimate/bossgames/data/dictionary", dictionary)

word_typing <- false
word_type_duration <- 20.0
word_rotation <- []
word_high_score <- 0
word_timer <- null
median_score <- 0
game_over <- false

function OnPrecache()
{
	PrecacheScriptSound(sound_boss_start)
	PrecacheScriptSound(sound_descent_begin)
	PrecacheScriptSound(sound_spiral_inward)
	PrecacheScriptSound(sound_bad_end)
	PrecacheScriptSound(sound_good_end)
	PrecacheScriptSound(sound_level_up)
	PrecacheScriptSound(sound_overview_start)
	PrecacheScriptSound(sound_word_start)
	PrecacheScriptSound(sound_word_fail)
	PrecacheScriptSound(sound_word_success)
	PrecacheScriptSound(sound_word_relax)
	PrecacheScriptSound(music)         

	PrecacheOverlay(overlay_type)
	PrecacheOverlay(overlay_announcement)
	PrecacheOverlay(overlay_round_info)
}

function OnStart()
{
	if (Ware_Plugin)
	{
		// TODO call into plugin to disable SM antiflood
	}
	
	Ware_PlaySoundOnAllClients(sound_boss_start)
	CreateTimer(Descent, 3.0)
	
	foreach (player in Ware_Players)
		player.AddFlag(FL_ATCONTROLS)
}

function OnCleanup()
{
	SetCamera(null)
	
	Ware_PlayMinigameMusic(null, current_music, SND_STOP)
	
	foreach (player in Ware_Players)
		player.RemoveFlag(FL_ATCONTROLS)
	
	if (Ware_Plugin)
	{
		// TODO call into plugin to disable SM antiflood
	}
}

function Descent()
{
	EntFire("DRBoss_DescentSequence_Start", "Trigger")
	SetCamera("DRBoss_DescentCamera_Point")
	Ware_PlaySoundOnAllClients(sound_descent_begin)
	Ware_ShowScreenOverlay(Ware_Players, null)
	current_music = "typing-" + RemoveRandomElement(music_choices)
	Ware_PlayMinigameMusic(null, current_music)
	CreateTimer(Prepare, 3.5)
}

function Prepare()
{
	EntFire("DRBoss_SpinInCamera_Start", "Trigger")
	SetCamera("DRBoss_SpiralCamera_Point")
	Ware_PlaySoundOnAllClients(sound_spiral_inward)
	Ware_ShowScreenOverlay(Ware_Players, overlay_prepare)
	CreateTimer(StartWords, 3.5)
}

function StartWords()
{
	EntFire("DRBoss_CloseupCamera_Start", "Trigger")
	SetCamera("DRBoss_CloseupCamera_Point")
	Ware_PlaySoundOnAllClients(sound_word_start)
	
	word_rotation = Shuffle(clone(dictionary[difficulties[difficulty]]))
	word_high_score = 0

	foreach (player in Ware_Players)
	{
		Ware_ShowScreenOverlay(player, overlay_type)
			
		if (Ware_MinigamePlayers.find(player) != null)
		{
			local minidata = Ware_GetPlayerMiniData(player)
			minidata.score <- 0
			minidata.word_count <- 0
			if (!("word_count_total" in minidata))
				minidata.word_count_total <- 0
			if (player.IsAlive())
			{
				ResetPlayerChatCooldown(player)
				ShowWord(player, 0)		
			}
		}
	}
	
	word_typing = true
	word_timer = Ware_SpawnEntity("team_round_timer",
	{
		timer_length        = word_type_duration
		auto_countdown      = true
		show_in_hud         = true
		show_time_remaining = true
	})
	EntityAcceptInput(word_timer, "Resume")
	
	CreateTimer(EndWords, word_type_duration)
}

function EndWords()
{
	word_typing = false
	word_timer.Kill()
	
	Ware_ShowScreenOverlay(Ware_Players, overlay_announcement)
	Ware_PlayMinigameMusic(null, current_music, SND_STOP)
	EntFire("DRBoss_OverviewSequence_Start", "Trigger")
	SetCamera("DRBoss_DescentCamera_Point")
	
	local players = [], scores = []
	foreach (player in Ware_MinigamePlayers)
	{
		local minidata = Ware_GetPlayerMiniData(player)
		if (player.IsAlive())
		{
			players.append(player)		
			scores.append(minidata.score)
		}
		
		Ware_ChatPrint(player, "Your words-per-minute (WPM) was {color}{int}", COLOR_LIME, 
			(minidata.word_count / (word_type_duration / 60.0)).tointeger())
	}
	if (scores.len() == 0)
	{
		CheckGameOver()
		return
	}
	
	Ware_PlaySoundOnAllClients(sound_overview_start)
	
	scores.sort(@(a, b) b <=> a)
	median_score = Median(scores)
	
	local failed = 0, max_display = 6
	local failed_players = []
	
	local text = "The players with the lowest number of words typed were...\n"	
	if (median_score != scores[0]) // if median is same as highest score then everyone succeeded
	{
		foreach (player in players)
		{
			if (Ware_GetPlayerMiniData(player).score <= median_score)
			{
				failed_players.append(player)
				if (failed++ < max_display)
					text += GetPlayerName(player) + "\n"		
			}
		}
		
		if (failed >= max_display)
			text += format("\n\nand %d more...", failed - max_display)
	}
	else
	{
		text += "no one!\n\nEveryone survives to the next level!"
	}
	
	Ware_ShowMinigameText(null, text)
	
	CreateTimer(function()
	{
		if (failed_players.len() > 0)
		{
			local player = failed_players.remove(0)
			if (player.IsValid())
				Ware_SuicidePlayer(player)					
			return failed_players.len() == 0 ? 1.5 : 0.1
		}
		else
		{
			CheckGameOver()
		}
	}, 3.0)
}

function CheckGameOver()
{
	local players = Ware_GetAlivePlayers()
	if (players.len() <= 1 || level > 4)
	{
		game_over = true
		if (players.len() > 0)
		{
			foreach (player in Ware_Players)
			{
				if (players.find(player) != null)
				{
					Ware_PlaySoundOnClient(player, sound_good_end)
					Ware_PassPlayer(player, true)
				}
				else
				{
					Ware_PlaySoundOnClient(player, sound_bad_end)
				}
			}
				
			if (players.len() > 1)
			{
				local text = "The winners are...\n"
				foreach (player in players)
					text +=  GetPlayerName(player) + "\n"
				Ware_ShowMinigameText(null, text)
			}
			else
			{
				local player = players[0]
				local average_word_count = Ware_GetPlayerMiniData(player).word_count_total / (level + 1).tofloat()
				Ware_ShowMinigameText(null, format("The winner is...\n%s!", GetPlayerName(player)))
				Ware_ChatPrint(null, "{player}{color} had a total WPM of {color}{int}{color}!", 
					player, TF_COLOR_DEFAULT, COLOR_LIME,
					(average_word_count / (word_type_duration / 60.0)).tointeger(), 
					TF_COLOR_DEFAULT)		
			}
		}
		else
		{
			Ware_PlaySoundOnAllClients(sound_bad_end)
			Ware_ShowMinigameText(null, "Nobody is the winner...")
		}
	}
	else
	{
		level++
		
		Ware_ShowMinigameText(null, "")
		Ware_PlaySoundOnAllClients(sound_level_up)
		CreateTimer(Descent, 3.0)
		
		if (level == 1 || level == 3)
		{
			Ware_ShowScreenOverlay(Ware_Players, overlay_difficulty)
			Ware_PlaySoundOnAllClients(sound_difficulty_up)
			difficulty++
		}
	}
}

function SetCamera(name)
{
	// grab any valid camera if disabling
	local camera = FindByName(null, name ? name : "DRBoss_DescentCamera_Point")
	if (name != null)
	{
		foreach (player in Ware_Players)
		{
			SetPropEntity(camera, "m_hPlayer", player)
			camera.AcceptInput("Enable", "", player, player)
			player.SetForceLocalDraw(true)
			player.AddHudHideFlags(HIDEHUD_TARGET_ID)
			player.RemoveCond(TF_COND_TAUNTING)
			player.AddCond(TF_COND_GRAPPLED_TO_PLAYER) // prevent taunting
			SetPropInt(player, "m_takedamage", DAMAGE_YES)
		}
	}
	else
	{
		foreach (player in Ware_Players)
		{
			SetPropEntity(camera, "m_hPlayer", player)
			
			// workaround point_viewcontrol bug
			local life_state = GetPropInt(player, "m_lifeState")
			SetPropInt(player, "m_lifeState", 0) 
			camera.AcceptInput("Disable", "", player, player)
			SetPropInt(player, "m_lifeState", life_state) 
			
			player.SetForceLocalDraw(false)
			player.RemoveHudHideFlags(HIDEHUD_TARGET_ID)
			player.RemoveCond(TF_COND_GRAPPLED_TO_PLAYER)
		}
	}
}

function ShowWord(player, score)
{
	local word      = word_rotation[score]
	local next_word = word_rotation[score + 1]
	Ware_ShowMinigameText(player, format("%s\n\nNext word: %s\n", word, next_word))	
}

function OnPlayerSay(player, text)
{
	if (word_typing)
	{
		if (player.IsAlive() && Ware_MinigamePlayers.find(player) != null)
		{
			EntityEntFire(player, "CallScriptFunction", "ResetSelfChatCooldown")
			
			local minidata = Ware_GetPlayerMiniData(player)
			// should be impossible to run out of words
			local word = word_rotation[minidata.score]
			if (text.tolower() == word.tolower())
			{
				minidata.word_count++
				minidata.word_count_total++
				
				minidata.score++
				if (minidata.score > word_high_score)
				{
					Ware_PlaySoundOnClient(player, sound_word_relax)
					word_high_score = minidata.score
				}
				else
				{
					Ware_PlaySoundOnClient(player, sound_word_success)
				}
							
				ShowWord(player, minidata.score)
				return false
			}
			else
			{
				Ware_PlaySoundOnClient(player, sound_word_fail)
			}
		}
	}
}

function OnCheckEnd()
{
	 return game_over
}