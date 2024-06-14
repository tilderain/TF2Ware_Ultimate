// by ficool2 and pokemonpasta

if (!("Ware_Plugin" in this))
{
	local plugin_found = Convars.GetStr("ware_version") != null
	if (IsDedicatedServer() || plugin_found)
	{
		if (!plugin_found)
		{
			local msg = "** TF2Ware Ultimate requires the SourceMod plugin installed on dedicated servers"
			ClientPrint(null, HUD_PRINTTALK, "\x07FF0000" + msg)
			printl(msg)
			return
		}
		else
		{
			printl("\tVScript: TF2Ware Ultimate linked to SourceMod plugin")
			Ware_Plugin <- true	
		}
	}
	else
	{
		Ware_Plugin <- false
	}
	
	printl("\tVScript: TF2Ware Ultimate Started")
}

// force a game restart if an error occurs while inside code marked as "critical"
Ware_CriticalZone <- false

// override vscript's own error handler for telemetry purposes
Ware_ListenHost <- GetListenServerHost()
Ware_LastErrorTime <- 0.0
function Ware_ErrorHandler(e)
{
	// discard cascading error messages from input hooks
	local info = getstackinfos(2)
	if (info && "post_func" in info.locals)
		return
		
	local developers = Ware_Players.filter(@(i, player) GetPlayerSteamID3(player) in DEVELOPER_STEAMID3)
	// show for non-developers in local host as well
	if (Ware_ListenHost && Ware_ListenHost.IsValid() && developers.find(Ware_ListenHost) == null)
		developers.append(Ware_ListenHost)
		
	local Print = function(msg)
	{
		// dev chat
		foreach (developer in developers)
			ClientPrint(developer, HUD_PRINTCONSOLE, msg)
		// server console
		if (Ware_ListenHost == null)
			printl(msg)
	}
	
	local time = Time()
	if (Ware_LastErrorTime < time)
	{
		// in case of a spammy error, rate limit it
		Ware_LastErrorTime = time + 5.0
		foreach (developer in developers)
			ClientPrint(developer, HUD_PRINTTALK, "\x07FF0000A script error has occured. Check console for details")
	}
	
	Print(format("\n[TF2Ware] AN ERROR HAS OCCURRED [%s]", e))
	
	if (info)
	{
		local i = 2
		for (;;)
		{
			if (info == null || info == ROOT)
				break
			
			Print(format("* %s (%s, line %d)", info.func, info.src, info.line))
			
			foreach (n, v in info.locals) 
			{
				local t = type(v)
				t ==    "null" ? Print(format("\t[%s] NULL"  , n))    :
				t == "integer" ? Print(format("\t[%s] %d"    , n, v)) :
				t ==   "float" ? Print(format("\t[%s] %.14g" , n, v)) :
				v instanceof CTFPlayer ? Print(format("\t[%s] (player) \"%s\"", n, GetPlayerName(v))) :
				t ==  "string" ? Print(format("\t[%s] \"%s\"", n, v)) :
				t ==  "array"  ? Print(format("\t[%s] array (%d)", n, v.len())) :
				t ==  "table"  ? Print(format("\t[%s] table (%d)", n, v.len())) :
								 Print(format("\t[%s] %s %s" , n, t, v.tostring()))
			}
			
			info = getstackinfos(++i)
		}
	}
	
	if (Ware_CriticalZone)
	{
		Ware_CriticalZone = false	
		SetConvarValue("mp_restartgame", 5)
		Ware_Error("Critical error detected. Restarting in 5 seconds...")
	}
}
seterrorhandler(Ware_ErrorHandler)

SetConvarValue("sv_gravity", 800.00006) // hide the sv_tags message
SetConvarValue("mp_disable_respawn_times", 0)
SetConvarValue("mp_forcecamera", 0)
SetConvarValue("mp_friendlyfire", 1)
SetConvarValue("mp_respawnwavetime", 99999)
SetConvarValue("mp_scrambleteams_auto", 0)
SetConvarValue("mp_waitingforplayers_time", 60)
SetConvarValue("mp_teams_unbalance_limit", 1)
SetConvarValue("mp_autoteambalance", 1)
SetConvarValue("sv_turbophysics", 0)
SetConvarValue("tf_dropped_weapon_lifetime", 0)
SetConvarValue("tf_weapon_criticals", 0)
SetConvarValue("tf_spawn_glows_duration", 0)
SetConvarValue("tf_player_movement_restart_freeze", 0)

if (!Ware_Plugin)
{
	SendToConsole("sv_cheats 1")
}

class Ware_Callback
{
	function constructor(_scope, name)
	{
		scope = _scope
		if (name in _scope)
			func = _scope[name]
	}
	
	function _call(...)
	{
		if (func != null)
		{
			vargv.remove(0)
			vargv.insert(0, scope)
			return func.acall(vargv)
		}
		return null
	}
	
	function IsValid()
	{
		return func != null
	}
	
	function GetDefaultScope() { return null }

	func = null
	scope = null
}

class Ware_MinigameData
{
	function constructor(table = null)
	{
		location       = "home"
		min_players    = 0
		start_pass     = false
		allow_damage   = false
		force_backstab = false
		fail_on_death  = false
		suicide_on_end = false
		collisions 	   = false
		friendly_fire  = true
		thirdperson    = false
		boss		   = false
		end_delay      = 0.0
		convars        = []
		entities       = []
		cleanup_names  = {}
		timers		   = []
		annotations    = []
		
		if (table)
		{
			foreach (key, value in table)
				this[key] = value
		}
	}
	
	// Mandatory settings
	// Visual name
	name			= null
	// Who made the minigame?
	// Unused for now but might be used for credits in the future
	author			= null
	// Description shown to people
	// This can either be a string or an array of strings (when using missions)
	description		= null
	// Length before ending
	duration		= null
	// Music to play
	music			= null
	
	// Optional settings
	// Map location to teleport to (Ware_Location enum), default is home
	location		= null
	// Minimum amount of players needed to start, default is 0
	min_players		= null
	// Whether players will be flagged as passed when minigame starts, default is false
	start_pass		= null
	// Is damage to other players allowed? Default is false
	allow_damage	= null
	// Allow backstabs with any weapon
	force_backstab  = null
	// Whether players should be automatically failed when they die, default is false
	fail_on_death	= null
	// Whether players should suicide if they haven't passed when minigame ends, default is false
	suicide_on_end	= null
	// Enables collisions between players, default is false
	collisions    	= null
	// Toggle friendlyfire, default is true
	friendly_fire	= null
	// Force players into thirdperson? Default is false
	thirdperson	    = null
	// Delay after the minigame "ends" before showing results, default is 0.0
	end_delay		= null
	// Custom text overlay to show rather than the default implied from name
	// This can either be a string or an array of strings (when using missions)
	custom_overlay	= null
	// Secondary custom text overlay to show 
	// Same rules as above
	custom_overlay2 = null
	// Table of convars to set for this minigame
	// Reverted to previous values after minigame ends
	convars			= null
	
	// Internal use only
	// Is a boss game?
	boss			= null
	// File name
	file_name       = null
	// Entities spawned by the minigame, to remove after it ends
	entities		= null
	// Entity names to delete after minigame ends (e.g. projectiles)
	cleanup_names	= null
	// Timers spawned by the minigame, stopped after it ends
	timers			= null
	// Annotations created by the minigame, hidden after it ends
	annotations		= null
	// Player condition added by the minigame, reverted after end
	condition		= null
	
	cb_on_take_damage		= null
	cb_on_player_attack		= null
	cb_on_player_death		= null
	cb_on_player_disconnect	= null
	cb_on_player_say		= null
	cb_on_player_voiceline	= null
	cb_on_player_horn		= null
	cb_on_player_touch		= null
	cb_on_update			= null
	cb_check_end			= null
}

class Ware_SpecialRoundData
{
	function constructor(table = null)
	{
		min_players      = 0
		convars          = {}
		reverse_text     = false
		allow_damage     = false
		force_collisions = false
		boss_count       = 1
		
		if (table)
		{
			foreach (key, value in table)
				this[key] = value
		}
	}
	
	
	name             = null
	author           = null
	description      = null
	
	reverse_text     = null
	allow_damage     = null
	force_collisions = null
	boss_count       = null
	
	min_players      = null
	convars          = null
	
	cb_get_boss_threshold    = null
	cb_get_overlay2          = null
	cb_get_player_roll       = null
	cb_on_calculate_scores   = null
	cb_on_player_spawn       = null
	cb_on_player_inventory   = null
	cb_on_begin_intermission = null
	cb_on_minigame_start     = null
	cb_on_minigame_end       = null
	cb_on_speedup            = null
	cb_on_take_damage        = null
	cb_on_update             = null
}

class Ware_PlayerData
{
	function constructor(entity)
	{
		player           = entity
		index			 = player.entindex()
		scope            = entity.GetScriptScope()
		passed           = false
		passed_effects   = false
		mission          = 0
		attributes       = []
		melee_attributes = []
		start_sound      = false
		score			 = 0
		horn_timer		 = 0.0
		horn_buttons	 = 0
	}
	
	player		     	= null
	index			 	= null
	scope		     	= null
	passed		     	= null
	passed_effects   	= null
	mission		     	= null
	melee		     	= null
	melee_index      	= null
	special_melee       = null
	special_vm          = null
	attributes	     	= null
	melee_attributes 	= null
	start_sound      	= null
	saved_team       	= null
	score			 	= null
	horn_timer		 	= null
	horn_buttons	 	= null
}

Ware_Started			  <- false
Ware_Finished             <- false
Ware_TimeScale			  <- 1.0

if (!("Ware_DebugStop" in this))
{
	Ware_DebugStop            	<- false
	Ware_DebugForceMinigame   	<- ""
	Ware_DebugForceBossgame   	<- ""
	Ware_DebugForceMinigameOnce <- false
	Ware_DebugForceBossgameOnce <- false
	Ware_DebugNextSpecialRound <- ""
}
Ware_DebugForceTheme      <- ""
Ware_DebugOldTheme        <- ""
Ware_DebugGameOver		  <- false

Ware_TextManagerQueue     <- null
Ware_TextManagerLastMsg   <- null
Ware_TextManager          <- null

Ware_ParticleSpawnerQueue <- []
Ware_ParticleSpawner      <- null

Ware_MinigameRotation     <- []
if (!("Ware_BossgameRotation" in this))
	Ware_BossgameRotation <- []
if (!("Ware_SpecialRoundRotation" in this))
	Ware_SpecialRoundRotation <- []

Ware_Minigame             <- null
Ware_MinigameScope        <- {}
Ware_MinigameSavedConvars <- {}
Ware_MinigameHomeLocation <- null
Ware_MinigameLocation     <- null
Ware_MinigameEvents       <- []
Ware_MinigameOverlay2Set  <- false
Ware_MinigameStartTime    <- 0.0
Ware_MinigamePreEndTimer  <- null
Ware_MinigameEndTimer     <- null
Ware_MinigameEnded        <- false
Ware_MinigameHighScorers  <- []
Ware_MinigamesPlayed	  <- 0
Ware_BossgamesPlayed         <- 0

// dunno where to put this
Ware_RoundEndMusicTimer <- null

if (!("Ware_RoundsPlayed" in this))
	Ware_RoundsPlayed     <- 0

if (!("Ware_Theme" in this))
{
	Ware_Theme              <- Ware_Themes[0]
	Ware_CurrentThemeSounds <- {}
	Ware_NextTheme          <- ""
}

if (!("Ware_SpecialRound" in this))
{
	Ware_SpecialRound             <- null
	Ware_SpecialRoundScope        <- {}
	Ware_SpecialRoundSavedConvars <- {}
	Ware_SpecialRoundEvents       <- []
	Ware_SpecialRoundPrevious     <- false
}

if (!("Ware_Players" in this))
{
	Ware_Players         <- []
	Ware_PlayersData     <- []
	Ware_MinigamePlayers <- []
	
	Ware_AnnotationIDs   <- 0
	
	Ware_HatIndexList 	 <- {}
	
	// this shuts up incursion distance warnings from the nav mesh
	CreateEntitySafe("base_boss").KeyValueFromString("classname", "point_commentary_viewpoint")
}

function Ware_SourcemodRoutine(name, keyvalues)
{
	keyvalues.id <- "tf2ware_ultimate"
	keyvalues.routine <- name
	// unused event repurposed for vscript <-> sourcemod communication
	SendGlobalGameEvent("player_rematch_change", keyvalues)
}

function Ware_FindStandardEntities()
{
	World     <- FindByClassname(null, "worldspawn")
	WaterLOD  <- FindByClassname(null, "water_lod_control")
	GameRules <- FindByClassname(null, "tf_gamerules")
	PlayerMgr <- FindByClassname(null, "tf_player_manager")
	ClientCmd <- CreateEntitySafe("point_clientcommand")
	
	MarkForPurge(WaterLOD)
	
	// avoid adding the think again to not break global execution order
	if (World.GetScriptThinkFunc() != "Ware_OnUpdate")
	{
		AddThinkToEnt(World, "Ware_OnUpdate")
		AddThinkToEnt(PlayerMgr, "Ware_LeaderboardUpdate")
	}
	
	Ware_UpdateGlobalMaterialState()
	
	Ware_TextManagerQueue <- []
	Ware_TextManager = SpawnEntityFromTableSafe("game_text",
	{
		message = ""
		effect  = 0
		fadein  = 0.0
		fadeout = 0.0
		fxtime  = 0.0
		channel = 3
	})
	SetInputHook(Ware_TextManager, "FireUser1", Ware_TextHookBegin, null)
	SetInputHook(Ware_TextManager, "FireUser2", Ware_TextHookEnd, null)
	
	Ware_ParticleSpawnerQueue <- []
	Ware_ParticleSpawner <- CreateEntitySafe("trigger_particle")
	Ware_ParticleSpawner.KeyValueFromInt("spawnflags", SF_TRIGGER_ALLOW_ALL)
	SetInputHook(Ware_ParticleSpawner, "StartTouch", Ware_ParticleHook, null)
}

function Ware_SetupLocations()
{
	foreach (name, location in Ware_Location)
	{
		location.name <- name
		location.setdelegate(Ware_LocationParent)
		if ("Init" in location)
			location.Init()
	}

	Ware_CheckHomeLocation(Ware_Players.len())
	Ware_MinigameLocation = Ware_MinigameHomeLocation
}

function Ware_SetTimeScale(timescale)
{
	if (Ware_Plugin)
		Ware_SourcemodRoutine("timescale", { value = timescale })
	else
		SendToConsole(format("host_timescale %g", timescale))
	
	Ware_TimeScale = timescale
	
	foreach (data in Ware_MinigamePlayers)
		data.player.AddCustomAttribute("voice pitch scale", Ware_GetPitchFactor(), -1)
}

function Ware_UpdateGlobalMaterialState()
{
	// water_lod_control provides 2 global float variables that are read by client material proxies
	// overlays use this to reverse their text
	// unfortunately, mastercomfig overrides these and it results in corrupted rendering
	// to prevent that, do a dummy update of the network vars so the entity is re-transmitted
	
	if (WaterLOD && WaterLOD.IsValid())
		WaterLOD.Kill()
	
	WaterLOD = SpawnEntityFromTableSafe("water_lod_control",
	{
		cheapwaterstartdistance = 0
		cheapwaterenddistance = Ware_SpecialRound && Ware_SpecialRound.reverse_text ? 1 : 0
	})
}

function Ware_GetPitchFactor()
{
	return 1.0 + (Ware_TimeScale - 1.0) * 0.4
}

function Ware_ChatPrint(target, fmt, ...) 
{
	local reversed = Ware_SpecialRound && Ware_SpecialRound.reverse_text
	local result = reversed ? "" : "\x07FFCC22[TF2Ware] "
	
	local start = 0
	local end = fmt.find("{")
	local i = 0
	while (end != null) 
	{
		result += fmt.slice(start, end)
		start = end + 1
		end = fmt.find("}", start)
		if (end == null)
			break
		local word = fmt.slice(start, end)
		
		if (word == "player")
		{
			local player = vargv[i++]

			local team = player.GetTeam()
			if (team == TF_TEAM_RED)
				result += "\x07" + TF_COLOR_RED
			else if (team == TF_TEAM_BLUE)	
				result += "\x07" + TF_COLOR_BLUE
			else
				result += "\x07" + TF_COLOR_SPEC
			result += GetPlayerName(player)
		}
		else if (word == "color")
		{
			result += "\x07" + vargv[i++]
		}
		else if (word == "int" || word == "float")
		{
			result += vargv[i++].tostring()
		}
		else if (word == "str")
		{
			result += vargv[i++]
		}
		else 
		{
			result += format(word, vargv[i++])
		}
		
		start = end + 1
		end = fmt.find("{", start)
	}
	
	result += fmt.slice(start)
	
	if (reversed)
		result = "\x07FFCC22[eraW2FT] \x07" + TF_COLOR_DEFAULT + ReverseString(result)

	ClientPrint(target, HUD_PRINTTALK, result)
}

function Ware_Error(...)
{
	vargv.insert(0, this)
	vargv[1] = "\x07FF0000ERROR:\x07FBECCB " + vargv[1]
	local msg = format.acall(vargv)
	printl(msg)
	ClientPrint(null, HUD_PRINTTALK, msg)
}

function Ware_Format(...)
{
	vargv.insert(0, this)
	local str = format.acall(vargv)
	return str
}

function Ware_CreateEntity(classname)
{
	local entity = CreateEntitySafe(classname)
	Ware_Minigame.entities.append(entity)
	return entity
}

function Ware_SpawnEntity(classname, keyvalues)
{
	local entity = SpawnEntityFromTableSafe(classname, keyvalues)
	Ware_Minigame.entities.append(entity)
	return entity
}

function Ware_SpawnWearable(player, model_name)
{
	local wearable = Ware_CreateEntity("tf_wearable")
	wearable.KeyValueFromString("classname", "ware_wearable")
	SetPropInt(wearable, "m_nModelIndex", PrecacheModel(model_name))
	SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
	wearable.SetOwner(player)
	wearable.DispatchSpawn()
	return wearable
}

function Ware_IsWearableHat(wearable)
{
	if (!startswith(wearable.GetClassname(), "tf_wearable"))
		return false
	
	return wearable.LookupBone("bip_head") >= 0
}

function Ware_ToggleWearable(wearable, toggle)
{
	wearable.SetDrawEnabled(toggle)
}

function Ware_TogglePlayerWearables(player, toggle)
{
	for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
	{
		MarkForPurge(wearable)
		Ware_ToggleWearable(wearable, toggle)
	}
}

function Ware_CreateTimer(on_timer_func, delay)
{
	local timer = CreateTimer(on_timer_func, delay)
	Ware_Minigame.timers.append(timer)
	return timer
}

function Ware_SetTheme(requested_theme)
{
	Ware_Theme <- {}
	
	local theme_found = false
	
	foreach(theme in Ware_Themes)
	{
		if (theme.theme_name == requested_theme)
		{
			Ware_Theme <- theme
			theme_found = true
			break
		}
	}
	
	if (!theme_found)
	{
		Ware_Error("No theme named '%s' was found. Setting to default theme instead.", requested_theme)
		Ware_Theme <- Ware_Themes[0]
	}
	
	Ware_SetupThemeSounds()
}

function Ware_SetupThemeSounds()
{
	Ware_CurrentThemeSounds <- {}
	
	local parent_theme = Ware_GetParentTheme(Ware_Theme)
	
	foreach(key, value in Ware_Themes[0].sounds)
	{
		local sound_name = key
		
		if (sound_name in Ware_Theme.sounds)
			Ware_CurrentThemeSounds[sound_name] <- [Ware_Theme.theme_name, Ware_Theme.sounds[sound_name]]
		else if (parent_theme != null && sound_name in parent_theme.sounds)
			Ware_CurrentThemeSounds[sound_name] <- [parent_theme.theme_name, parent_theme.sounds[sound_name]]
		else
			Ware_CurrentThemeSounds[sound_name] <- [Ware_Themes[0].theme_name, Ware_Themes[0].sounds[sound_name]]
	}
}

function Ware_IsThemeValid(test = Ware_Theme)
{
	if (typeof(test) != "table" || test.len() == 0)
		return false
	
	foreach(theme in Ware_Themes)
	{
		if (theme.theme_name == test.theme_name)
			return true
	}
	
	return false
}

function Ware_GetParentTheme(theme)
{
	// returns internal theme that multiple themes point to based on theme_name
	// this is mostly used for shared sounds due to shared platform, so we don't
	// have multiple copies of the same sound
	
	// note: this returns a table
	
	foreach(internal_theme in Ware_InternalThemes)
	{
		if (startswith(theme.theme_name, internal_theme.theme_name))
			return internal_theme
	}
	
	return null
}

function Ware_GetThemeSoundDuration(sound)
{
	if (sound in Ware_CurrentThemeSounds)
		return Ware_CurrentThemeSounds[sound][1] * Ware_GetPitchFactor()
	else
		return Ware_Themes[0].sounds[sound] * Ware_GetPitchFactor()
}

function Ware_PlaySoundOnClient(player, name, volume = 1.0, pitch = 100, flags = 0)
{
	PlaySoundOnClient(player, name, volume, pitch * Ware_GetPitchFactor(), flags)
}

function Ware_PlaySoundOnAllClients(name, volume = 1.0, pitch = 100, flags = 0)
{
	PlaySoundOnAllClients(name, volume, pitch * Ware_GetPitchFactor(), flags)
}

function Ware_PlayGameSound(player, name, flags = 0)
{
	local path
	
	if (name in Ware_CurrentThemeSounds)
		path = format("%s/%s", Ware_CurrentThemeSounds[name][0], name)
	else
		path = format("%s/%s", Ware_Themes[0].theme_name, name)
	
	if (player)
		Ware_PlaySoundOnClient(player, format("tf2ware_ultimate/v%d/music_game/%s.mp3", WARE_MUSICVERSION, path), 1.0, 100, flags)
	else
		Ware_PlaySoundOnAllClients(format("tf2ware_ultimate/v%d/music_game/%s.mp3", WARE_MUSICVERSION, path), 1.0, 100, flags)
}

function Ware_PlayMinigameSound(player, name, flags = 0, volume = 1.0)
{
	local gametype = Ware_Minigame.boss ? "bossgame" : "minigame"
	if (player)
		Ware_PlaySoundOnClient(player, format("tf2ware_ultimate/v%d/music_%s/%s.mp3", WARE_MUSICVERSION, gametype, name), volume, 100, flags)
	else
		Ware_PlaySoundOnAllClients(format("tf2ware_ultimate/v%d/music_%s/%s.mp3", WARE_MUSICVERSION, gametype, name), volume, 100, flags)
}

function Ware_SetConvarValue(convar, value)
{
	Ware_Minigame.convars[convar] <- value
	if (!(name in Ware_MinigameSavedConvars))
		Ware_MinigameSavedConvars[name] <- GetConvarValue(name)
	SetConvarValue(name, value)
}

function Ware_RunClientCommand(player, command)
{
	if (player)
	{
		EntFireByHandle(ClientCmd, "Command", command, 0, player, null)		
	}
	else
	{
		foreach (player in Ware_Players)
			EntFireByHandle(ClientCmd, "Command", command, 0, player, null)		
	}
}

function Ware_ShowScreenOverlay(player, name)
{
	player.SetScriptOverlayMaterial(name ? name : "")
}

function Ware_ShowScreenOverlay2(player, name)
{
	if (!name)
	{
		player.RemoveHudHideFlags(HIDEHUD_TARGET_ID)
		
		local overlay_name = "off";
		if (Ware_SpecialRound && Ware_SpecialRound.cb_get_overlay2.IsValid())
			overlay_name = Ware_SpecialRound.cb_get_overlay2()
			
		EntFireByHandle(ClientCmd, "Command", format("r_screenoverlay %s", overlay_name), -1, player, null)
	}
	else
	{
		player.AddHudHideFlags(HIDEHUD_TARGET_ID)
		EntFireByHandle(ClientCmd, "Command", format("r_screenoverlay %s", name), -1, player, null)
	}	
}

function Ware_ShowGlobalScreenOverlay(name)
{
	foreach (data in Ware_MinigamePlayers)
		Ware_ShowScreenOverlay(data.player, name)
}

function Ware_ShowGlobalScreenOverlay2(name)
{
	foreach (data in Ware_MinigamePlayers)
		Ware_ShowScreenOverlay2(data.player, name)
}

function Ware_ShowMinigameText(player, text, color = "255 255 255", x = -1.0, y = 0.3)
{
	if (Ware_SpecialRound && Ware_SpecialRound.reverse_text)
		text = ReverseString(text)
	
	Ware_TextManagerQueue.push(
	{ 
		message  = text
		color    = color
		holdtime = Ware_GetMinigameRemainingTime()
		x		 = x
		y        = y
	})
	
	EntityEntFire(Ware_TextManager, "FireUser1")
	if (player)
	{
		EntFireByHandle(Ware_TextManager, "Display", "", -1, player, null)
	}
	else
	{
		foreach (data in Ware_MinigamePlayers)
			EntFireByHandle(Ware_TextManager, "Display", "", -1, data.player, null)
	}
	EntityEntFire(Ware_TextManager, "FireUser2")
}

function Ware_ShowAnnotation(pos, text, lifetime = -1)
{
	// pos can be a vector or an entity handle. if it's a handle it'll follow that entity.
	// if you want it to start at an entity but stay there, pass that entity's origin instead.
	// annotations created outside of minigames will stay around until theyre hidden manually
	
	local vector, entindex
	local id = Ware_AnnotationIDs++
	
	if (typeof(pos) == "Vector")
	{
		vector = pos
		entindex = 0
	}
	else if (typeof(pos) == "instance")
	{
		vector = pos.GetOrigin()
		entindex = pos.entindex()
	}
	else
	{
		return
	}
	
	if (Ware_SpecialRound && Ware_SpecialRound.reverse_text)
		text = ReverseString(text)

	SendGlobalGameEvent("show_annotation",
		{
			worldPosX = vector.x,
			worldPosY = vector.y,
			worldPosZ = vector.z,
			id = id,
			text = text,
			lifetime = lifetime,
			visibilityBitfield = 0,
			follow_entindex = entindex,
			show_distance = false,
			show_effect = false,
			play_sound = "common/null.wav",
		})
	
	if (Ware_Minigame != null)
		Ware_Minigame.annotations.append(id)
	
	return id
}

function Ware_HideAnnotation(id)
{
	SendGlobalGameEvent("hide_annotation", { id = id })
	if (Ware_Minigame != null)
	{
		local idx = Ware_Minigame.annotations.find(id)
		if (idx != null)
			Ware_Minigame.annotations.remove(idx)
	}
}

function Ware_HideAllAnnotations()
{
	for (local i = 0; i < Ware_AnnotationIDs; i++)
		Ware_HideAnnotation(i)
}

function Ware_TextHookBegin()
{
	local params = Ware_TextManagerQueue.remove(0)
	Ware_TextManagerLastMsg = params.message
	self.KeyValueFromString("message", params.message)
	self.KeyValueFromString("color", params.color)
	self.KeyValueFromFloat("holdtime", params.holdtime)
	self.KeyValueFromFloat("x", params.x)
	self.KeyValueFromFloat("y", params.y)
	return true
}

function Ware_TextHookEnd()
{
	// hack to purge stringtable
	local purger = CreateEntitySafe("logic_relay")
	purger.KeyValueFromString("targetname", Ware_TextManagerLastMsg)
	purger.Kill()
}

function Ware_SpawnParticle(entity, name, attach_name = "", attach_type = PATTACH_ABSORIGIN_FOLLOW)
{
	Ware_ParticleSpawnerQueue.push(
	{
		name = name
		attach_name = attach_name
		attach_type = attach_type
	})
	EntFireByHandle(Ware_ParticleSpawner, "StartTouch", "", -1, entity, entity)
}

function Ware_ParticleHook()
{
	if (!activator) // prevent invalid entity or this will crash
		return false
		
	local data = Ware_ParticleSpawnerQueue.remove(0)
	SetPropString(self, "m_iszParticleName", data.name)
	SetPropString(self, "m_iszAttachmentName", data.attach_name)
	SetPropInt(self, "m_nAttachType", data.attach_type)
	return true
}

function Ware_GetPlayerMiniData(player)
{
	return player.GetScriptScope().ware_minidata
}

function Ware_UngroundPlayer(player)
{
	SetPropEntity(player, "m_hGroundEntity", null)
	player.RemoveFlag(FL_ONGROUND)
}

function Ware_PushPlayer(player, scale)
{
	Ware_UngroundPlayer(player)
	
	local dir = player.EyeAngles().Forward()
	dir.x *= scale
	dir.y *= scale
	dir.z *= scale * 2.0
	player.SetAbsVelocity(player.GetAbsVelocity() + dir)
}

function Ware_PushPlayerFromOther(player, other_player, scale)
{
	Ware_UngroundPlayer(player)
	
	local dir = player.GetOrigin() - other_player.GetOrigin()
	dir.Norm()
	dir.x *= scale
	dir.y *= scale
	dir.z *= scale * 2.0
	player.SetAbsVelocity(player.GetAbsVelocity() + dir)
}

function Ware_SlapEntity(entity, scale)
{
	local vel = entity.GetAbsVelocity()
	vel.x += RandomFloat(-1.0, 1.0) * scale
	vel.y += RandomFloat(-1.0, 1.0) * scale
	vel.z += scale * 2.0
	entity.Teleport(false, Vector(), false, QAngle(), true, vel)
}

function Ware_GetMinigameTime()
{
	return Time() - Ware_MinigameStartTime
}

function Ware_GetMinigameRemainingTime()
{
	return (Ware_MinigameStartTime + Ware_Minigame.duration + Ware_Minigame.end_delay) - Time()
}

function Ware_ToggleTruce(toggle)
{
	if (toggle)
	{
		// special round that requires damage must never have truce enabled (OnTakeDamage will cancel it)
		if (!Ware_SpecialRound || !Ware_SpecialRound.allow_damage)
			SetPropBool(GameRules, "m_bTruceActive", true)
		else
			SetPropBool(GameRules, "m_bTruceActive", false)
	}
	else
	{
		SetPropBool(GameRules, "m_bTruceActive", false)
	}
}

function Ware_GetBossThreshold()
{
	if (Ware_SpecialRound && Ware_SpecialRound.cb_get_boss_threshold.IsValid())
		return Ware_SpecialRound.cb_get_boss_threshold()
	else
		return Ware_BossThreshold
}

function Ware_GetBossCount()
{
	if (Ware_SpecialRound)
		return Ware_SpecialRound.boss_count
	else
		return 1
}

function Ware_ParseLoadout(player)
{
	local data = player.GetScriptScope().ware_data
	
	local special_melee = data.special_melee
	if (special_melee)
	{
		// shouldn't happen, if it does, this logic needs rewriting
		if (data.melee_index == null)
		{
			Ware_Error("Failed to find special melee slot for %s", GetPlayerName(player))
			return null					
		}
			
		for (local i = 0; i < MAX_WEAPONS; i++)
		{
			local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
			if (!weapon)
				continue
			MarkForPurge(weapon)
			
			if (weapon != special_melee)
				KillWeapon(weapon)
			SetPropEntityArray(player, "m_hMyWeapons", null, i)
		}
		
		SetPropEntityArray(player, "m_hMyWeapons", special_melee, data.melee_index)			
		
		return special_melee	
	}	
		
	local melee, last_melee
	for (local i = 0; i < MAX_WEAPONS; i++)
	{
		local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
		if (!weapon)
			continue
		
		MarkForPurge(weapon)
		if (weapon.GetSlot() == TF_SLOT_MELEE)
		{
			last_melee = data.melee
			melee = weapon
			data.melee = weapon
			data.melee_index = i
		}
		else
		{
			SetPropEntityArray(player, "m_hMyWeapons", null, i)
			KillWeapon(weapon)
		}
	}
	
	if (last_melee != null && last_melee != melee && last_melee.IsValid())
		last_melee.Destroy()
		
	return melee
}

function Ware_SetPlayerLoadout(player, player_class, items = null, item_attributes = {}, keep_melee = false)
{
	Ware_SetPlayerClass(player, player_class, false)
	
	if (items)
	{
		Ware_StripPlayer(player, keep_melee)
		
		if (typeof(items) == "array")
		{
			local last_item = items[items.len() - 1]
			foreach (item in items)
				Ware_GivePlayerWeapon(player, item, {}, item == last_item)
		}
		else
		{
			Ware_GivePlayerWeapon(player, items, item_attributes)
		}
	}
	else
	{
		player.RemoveCond(TF_COND_TAUNTING)
		
		local data = player.GetScriptScope().ware_data
		local melee
		if (data.special_melee)
			melee = data.special_melee
		else
			melee = data.melee

		if (melee)
		{
			if (item_attributes.len() > 0)
			{
				foreach (attribute, value in item_attributes)
					melee.AddAttribute(attribute, value, -1.0)
				data.melee_attributes = clone(item_attributes)
			}
			
			player.Weapon_Switch(melee)
		}
	}
		
	SetPropEntity(player, "m_hLastWeapon", null)	
}

function Ware_SetGlobalLoadout(player_class, items = null, item_attributes = {}, keep_melee = false)
{
	foreach (data in Ware_MinigamePlayers)
		Ware_SetPlayerLoadout(data.player, player_class, items, item_attributes, keep_melee)		
}

function Ware_StripPlayer(player, give_default_melee)
{
	player.RemoveCond(TF_COND_DISGUISING)
	player.RemoveCond(TF_COND_DISGUISED)
	player.RemoveCond(TF_COND_TAUNTING)
	player.RemoveCond(TF_COND_ZOOMED)
		
	local data = player.GetScriptScope().ware_data
	local melee = data.melee
	local special_melee = data.special_melee
	
	for (local i = 0; i < MAX_WEAPONS; i++)
	{
		local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
		if (weapon)
		{
			SetPropEntityArray(player, "m_hMyWeapons", null, i)

			if (weapon != melee && weapon != special_melee)
				KillWeapon(weapon)
		}
	}

	if (give_default_melee)
	{
		local use_melee
		if (special_melee != null && special_melee.IsValid())
			use_melee = special_melee
		else if (melee != null && melee.IsValid())
			use_melee = melee
		
		if (use_melee)
		{
			SetPropEntityArray(player, "m_hMyWeapons", use_melee, data.melee_index)
			
			local active_weapon = player.GetActiveWeapon()
			if (active_weapon != use_melee)
			{
				if (active_weapon != null)
				{								
					// force switch fixes
					local classname = active_weapon.GetClassname()
					if (classname == "tf_weapon_minigun")
					{
						SetPropEntity(player, "m_hActiveWeapon", null)
					}
					else if (startswith(classname, "tf_weapon_sniperrifle"))
					{
						SetPropFloat(active_weapon, "m_flNextPrimaryAttack", 0.0)
					}
					else if (classname == "tf_weapon_rocketpack")
					{
						active_weapon.AddAttribute("holster_anim_time", 0.0, -1)
						SetPropFloat(active_weapon, "m_flLaunchTime", 0.0)	
						if (player.InCond(TF_COND_ROCKETPACK))
						{
							// needed to stop air sound
							SendGlobalGameEvent("rocketpack_landed", { userid = GetPlayerUserID(player) })
							player.RemoveCond(TF_COND_ROCKETPACK)
						}
					}
				}
				
				player.Weapon_Switch(use_melee)
			}
		}
	}
}

SaxxyToClassnameMap <-
{
	[TF_CLASS_SCOUT]        = "tf_weapon_bat",
	[TF_CLASS_SOLDIER]      = "tf_weapon_shovel",
	[TF_CLASS_PYRO]         = "tf_weapon_fireaxe",
	[TF_CLASS_DEMOMAN]      = "tf_weapon_bottle",
	[TF_CLASS_HEAVYWEAPONS] = "tf_weapon_fists",
	[TF_CLASS_ENGINEER]     = "tf_weapon_wrench",
	[TF_CLASS_MEDIC]        = "tf_weapon_bonesaw",
	[TF_CLASS_SNIPER]       = "tf_weapon_club",
	[TF_CLASS_SPY]          = "tf_weapon_knife",
}

function Ware_GivePlayerWeapon(player, item_name, attributes = {}, switch_weapon = true)
{
	local item = ITEM_MAP[item_name]
	local item_id = item.id
	local item_classname = item.classname
	
	if (item_classname == "tf_weapon_shotgun") 
	{
		local player_class = player.GetPlayerClass()
		if (player_class == TF_CLASS_SOLDIER)
		{
			if (item_id == 9) item_id = 10
			item_classname = "tf_weapon_shotgun_soldier"
		}
		else if (player_class == TF_CLASS_PYRO)
		{
			if (item_id == 9) item_id = 12
			item_classname = "tf_weapon_shotgun_pyro"
		}	
		else if (player_class == TF_CLASS_HEAVYWEAPONS)
		{
			if (item_id == 9) item_id = 11
			item_classname = "tf_weapon_shotgun_hwg"
		}	
		else /* if (player_class == TF_CLASS_ENGINEER)*/
		{
			if (item_id == 9) item_id = 9
			item_classname = "tf_weapon_shotgun_primary"
		}			
	}
	else if (item_id == 22) // pistol
	{
		if (player.GetPlayerClass() == TF_CLASS_SCOUT)
			item_id = 23
	}
	else if (item_classname == "saxxy")
	{
		item_classname = SaxxyToClassnameMap[player.GetPlayerClass()]
	}
	
	local weapon = CreateEntitySafe(item_classname)
	SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", item_id)
	SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
	SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
	weapon.SetTeam(player.GetTeam())
	weapon.DispatchSpawn()
	
	if (item_id == 28) // builder
	{
		for (local i = 0; i < 3; i++)
			SetPropIntArray(weapon, "m_aBuildableObjectTypes", 1, i)
		SetPropInt(weapon, "m_iObjectType", 0)
		switch_weapon = false
	}
	else if (item_id == 735 || item_classname == "tf_weapon_sapper") // sapper
	{
		SetPropIntArray(weapon, "m_aBuildableObjectTypes", 1, 3)
		SetPropInt(weapon, "m_iObjectType", 3)
		SetPropInt(weapon, "m_iSubType", 3)
	}
	
	weapon.ValidateScriptScope()
	weapon.GetScriptScope().last_fire_time <- 0.0
	
	// bit of a hack: penetration is required for friendlyfire to work
	if (startswith(item_classname, "tf_weapon_sniperrifle"))
		weapon.AddAttribute("projectile penetration", 1, -1)
	
	foreach (attribute, value in attributes)
		weapon.AddAttribute(attribute, value, -1.0)

	player.Weapon_Equip(weapon)
	if (switch_weapon)
	{
		if (item_id != 28) // toolbox
		{
			if (item_id == 25 || item_id == 27) // construction pda
			{
				// build/disguise menu will not show up unless its holstered for a bit
				EntFireByHandle(player, "CallScriptFunction", "Ware_FixupPlayerWeaponSwitch", 0.25, weapon, weapon)
			}
			else
			{
				player.Weapon_Switch(weapon)
			}
		}
	}
	
	if (Ware_Minigame != null)
	{
		if (item_id in ITEM_PROJECTILE_MAP)
		{
			local proj_classname = ITEM_PROJECTILE_MAP[item_id]
			if (!(proj_classname in Ware_Minigame.cleanup_names))
			{
				Ware_Minigame.cleanup_names[proj_classname] <- 1
				Ware_Minigame.cleanup_names["ware_projectile"] <- 1
			}
		}
	}
	
	return weapon
}

function Ware_RemoveMeleeAttributes(melee)
{
	local id = GetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
	if (id in Ware_MeleeAttributeOverrides)
	{
		local attributes = Ware_MeleeAttributeOverrides[id]
		foreach (name, value in attributes)
			melee.AddAttribute(name, value, -1)
	}
}

function Ware_AddPlayerAttribute(player, name, value, duration)
{
	player.AddCustomAttribute(name, value, duration)
	return player.GetScriptScope().ware_data.attributes.append(name)
}

function Ware_SetGlobalAttribute(name, value, duration)
{
	foreach (data in Ware_MinigamePlayers)
		Ware_AddPlayerAttribute(data.player, name, value, duration)
}

function Ware_SetGlobalCondition(condition)
{
	foreach (data in Ware_MinigamePlayers)
		data.player.AddCond(condition)
	Ware_Minigame.condition = condition
}

function Ware_FixupPlayerWeaponSwitch()
{
	if (activator)
		self.Weapon_Switch(activator)
}

function Ware_DisablePlayerPrimaryFire(player)
{
	local weapon = player.GetActiveWeapon()
	if (weapon != null)
		SetPropFloat(weapon, "m_flNextPrimaryAttack", Time() + 0.2)
}

function Ware_GetPlayerAmmo(player, ammo_type)
{
	return GetPropIntArray(player, "m_iAmmo", ammo_type)
}

function Ware_SetPlayerAmmo(player, ammo_type, ammo)
{
	SetPropIntArray(player, "m_iAmmo", ammo, ammo_type)
}

local Ware_CheckTeleportEffectTimer
function Ware_SetPlayerClass(player, player_class, switch_melee = true)
{
	if (player.GetPlayerClass() == player_class)
		return
	
	SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", player_class)
	player.SetPlayerClass(player_class)
	player.Regenerate(true)
	player.SetCustomModel(GetPropString(player, "m_PlayerClass.m_iszCustomModel"))
	player.SetHealth(player.GetMaxHealth())
	SetPropBool(player, "m_Shared.m_bShieldEquipped", false)
	
	local melee = Ware_ParseLoadout(player)
	if (melee)
		Ware_RemoveMeleeAttributes(melee)
	
	// teleport effect gets cleared on class change, need to recreate it here
	// creating timers is expensive so avoid doing that for every player
	player.RemoveCond(TF_COND_TELEPORTED)
	if (!Ware_CheckTeleportEffectTimer || !Ware_CheckTeleportEffectTimer.IsValid())
	{
		Ware_CheckTeleportEffectTimer = CreateTimer(function()
		{
			foreach (data in Ware_MinigamePlayers)
			{
				if (Ware_MinigameHighScorers.find(data.player) != null)
					data.player.AddCond(TF_COND_TELEPORTED)
			}
		}, 0.25)
	}

	if (melee != null)
	{
		// not sure why this is needed
		melee.SetModel(TF_CLASS_ARMS[player_class])
	
		if (switch_melee)
		{
			player.Weapon_Switch(melee)
			melee.EnableDraw()
		}
	}
}

function Ware_SetPlayerTeam(player, team)
{
	local old_team = player.GetTeam()
	local data = player.GetScriptScope().ware_data
	if (data.saved_team == null)
		data.saved_team = old_team
	Ware_SetPlayerTeamInternal(player, team)
}

function Ware_SetPlayerTeamInternal(player, team)
{
	// force cancel duels
	SetPropBool(player, "m_bIsCoaching", true)
	player.ForceChangeTeam(team, true)
	SetPropBool(player, "m_bIsCoaching", false)
	
	for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
	{
		// cheap way to only catch weapons and cosmetics
		if (wearable.GetTeam() > TEAM_UNASSIGNED)
		{
			MarkForPurge(wearable)
			wearable.SetTeam(team)
		}
	}
}

function Ware_PassPlayer(player, pass)
{
	local data = player.GetScriptScope().ware_data
	if (data.passed == pass)
		return
		
	if (pass && !data.passed_effects)
	{
		Ware_ShowPassEffects(player)
		data.passed_effects = true
	}
	
	data.passed = pass
}

function Ware_ShowPassEffects(player)
{
	player.EmitSound(SFX_WARE_PASS)
	Ware_SpawnParticle(player, player.GetTeam() == TF_TEAM_RED ? PFX_WARE_PASS_RED : PFX_WARE_PASS_BLUE)
}

function Ware_IsPlayerPassed(player)
{
	return player.GetScriptScope().ware_data.passed
}

function Ware_SetPlayerMission(player, mission)
{
	return player.GetScriptScope().ware_data.mission = mission
}

function Ware_SuicidePlayer(player)
{
	player.TakeDamageCustom(player, player, null, Vector(), Vector(), 99999.0, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_SUICIDE)
}

function Ware_SuicideFailedPlayers()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (IsEntityAlive(player) && !Ware_IsPlayerPassed(player))
			Ware_SuicidePlayer(player)
	}
}

function Ware_RadiusDamagePlayers(origin, radius, damage, attacker)
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
			
		local dist = (player.GetOrigin() - origin).Length()
		if (dist > radius)
			continue
			
		dist += DIST_EPSILON // prevent divide by zero
		local falloff = 1.0 - dist / radius
		if (falloff <= 0.0)
			continue
			
		player.TakeDamage(damage * falloff, DMG_BLAST, attacker)
	}	
}

function Ware_TeleportPlayer(player, origin, angles, velocity)
{
	local has_origin = true, has_angles = true, has_velocity = true
	if (origin == null)
	{
		has_origin = false
		origin = vec3_zero
	}
	if (angles == null)
	{
		has_angles = false
		angles = ang_zero
	}
	if (velocity == null)
	{
		has_velocity = false
		velocity = vec3_zero
	}
	
	if (Ware_SpecialRound && Ware_SpecialRound.cb_get_player_roll.IsValid())
		angles = QAngle(angles.x, angles.y, Ware_SpecialRound.cb_get_player_roll(player))
		
	player.Teleport(has_origin, origin, has_angles, angles, has_velocity, velocity)
}

function Ware_GetPlayerHeight(player)
{
	return player.GetOrigin().z - Ware_MinigameLocation.center.z
}

function Ware_PlayStartSound()
{
	if (ware_data.start_sound)
		return
	
	ware_data.start_sound = true
	 
	if (IsInWaitingForPlayers())
		Ware_PlayGameSound(self, "lets_get_started")
}

function Ware_IsTeamDead(team)
{
	if (!(team & 2))
		return true
		
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (player.GetTeam() == team && IsEntityAlive(player)) 
			return false
	}
	
	return true
}

function Ware_GetAlivePlayers(team = TEAM_UNASSIGNED)
{
	if (team & 2)
		return Ware_MinigamePlayers.filter(@(i, data) data.player.GetTeam() == team && IsEntityAlive(data.player))
	else
		return Ware_MinigamePlayers.filter(@(i, data) IsEntityAlive(data.player))
}

function Ware_GetValidPlayers()
{
	local valid_players = []
	foreach (player in Ware_Players)
	{
		if ((player.GetTeam() & 2) && IsEntityAlive(player))
			valid_players.append(player)
	}
	return valid_players
}

function Ware_GetSortedScorePlayers(reverse)
{
	local players = clone(Ware_MinigamePlayers)
	
	if (reverse)
		players.sort(@(a, b) b.score <=> a.score)
	else
		players.sort(@(a, b) a.score <=> b.score)
		
	players = players.map(@(data) data.player)
	return players
}

function Ware_CheckHomeLocation(player_count)
{
	local prev_location = Ware_MinigameHomeLocation
	Ware_MinigameHomeLocation = Ware_Location[player_count > 12 ? "home_big" : "home"]
	
	if (Ware_MinigameHomeLocation != prev_location)
	{
		if (prev_location)
		{
			foreach (spawn in prev_location.spawns)
				SetPropBool(spawn, "m_bDisabled", true)
		}
		
		foreach (spawn in Ware_MinigameHomeLocation.spawns)
			SetPropBool(spawn, "m_bDisabled", false)
	}
}

function Ware_IsSpecialRoundValid(str)
{
	foreach(round in Ware_SpecialRounds)
	{
		if (round == str)
			return true
	}
	
	return false
}

function Ware_SetupSpecialRoundCallbacks()
{
	local special_round = Ware_SpecialRound
	local scope = Ware_SpecialRoundScope
	
	special_round.cb_get_boss_threshold      = Ware_Callback(scope, "GetBossThreshold")
	special_round.cb_get_overlay2            = Ware_Callback(scope, "GetOverlay2")
	special_round.cb_get_player_roll         = Ware_Callback(scope, "GetPlayerRollAngle")
	special_round.cb_on_calculate_scores     = Ware_Callback(scope, "OnCalculateScores")
	special_round.cb_on_player_spawn         = Ware_Callback(scope, "OnPlayerSpawn")
	special_round.cb_on_player_inventory     = Ware_Callback(scope, "OnPlayerInventory")
	special_round.cb_on_begin_intermission   = Ware_Callback(scope, "OnBeginIntermission")
	special_round.cb_on_minigame_start       = Ware_Callback(scope, "OnMinigameStart")
	special_round.cb_on_minigame_end         = Ware_Callback(scope, "OnMinigameEnd")
	special_round.cb_on_speedup              = Ware_Callback(scope, "OnSpeedup")
	special_round.cb_on_take_damage          = Ware_Callback(scope, "OnTakeDamage")
	special_round.cb_on_update               = Ware_Callback(scope, "OnUpdate")
}

function Ware_BeginSpecialRound()
{
	// copied logic from minigame start
	local valid_players = Ware_GetValidPlayers()
	local player_count = valid_players.len()
	
	local success = false
	local try_debug = true
	local attempts = 0
	local round
	
	while (!success)
	{
		if (++attempts > 25)
		{
			Ware_Error("No valid special round found to pick. There may not be enough minimum players")
			return
		}
		
		local is_forced = false
		if (try_debug)
		{
			if(Ware_DebugNextSpecialRound.len() > 0)
			{
				if (Ware_IsSpecialRoundValid(Ware_DebugNextSpecialRound))
				{
					round = Ware_DebugNextSpecialRound
					Ware_DebugNextSpecialRound = ""
					is_forced = true
				}
				else
				{
					Ware_Error("No special round named %s was found. Picking another round instead.", Ware_DebugNextSpecialRound)
					Ware_DebugNextSpecialRound = ""
					is_forced = false
				}
			}
			
			try_debug = false
		}
		
		if (!is_forced)
		{
			if (Ware_SpecialRoundRotation.len() == 0)
			{
				if (Ware_SpecialRounds.len() == 0)
				{
					Ware_Error("Special Round rotation is empty")
					return
				}
				
				Ware_SpecialRoundRotation = Ware_SpecialRounds
			}
		
			round = RemoveRandomElement(Ware_SpecialRoundRotation)
		}
		
		local path = format("tf2ware_ultimate/specialrounds/%s", round)
		
		try
		{
			Ware_SpecialRoundScope.clear()
			IncludeScript(path, Ware_SpecialRoundScope)
			
			local min_players = Ware_SpecialRoundScope.special_round.min_players
			if (player_count >= min_players)
			{
				success = true
			}
			else if (is_forced)
			{
				Ware_Error("Not enough players to load '%s', minimum is %d", round, min_players)	
			}
		}
		catch (e)
		{
			Ware_ErrorHandler(format("Failed to load '%s.nut'. Missing from disk or syntax error", path))
		}
		
		if (is_forced && !success)
		{
			Ware_Error("Failed to force load '%s', picking another round", round)
		}
	}
	
	Ware_SpecialRoundPrevious = true
	
	// ingame sequence
	Ware_PlayGameSound(null, "special_round")
	Ware_ShowGlobalScreenOverlay("hud/tf2ware_ultimate/special_round")
	
	local start_time = Time()
	local duration = Ware_GetThemeSoundDuration("special_round") * 0.99 // finish slightly faster to set special round before intermission begins
	local reveal_time = duration * 0.6
	local end_time = duration - reveal_time
	local text_interval = 0.15
	// TODO: show special rounds a better way
	// this is just copied/adapted from Ware_ShowMinigameText
	// maybe just put something behind it?
	local ShowText = function(str, holdtime)
	{
		Ware_TextManagerQueue.push(
			{ 
				message  = str
				color    = "255 255 255"
				holdtime = holdtime
				x		 = -1.0
				y        = 0.3
			})
			
		EntityEntFire(Ware_TextManager, "FireUser1")
		foreach (data in Ware_MinigamePlayers)
			EntFireByHandle(Ware_TextManager, "Display", "", -1, data.player, null)
		EntityEntFire(Ware_TextManager, "FireUser2")
	}
	
	local special_round = Ware_SpecialRoundScope.special_round
		
	CreateTimer(function() 
	{	
		ShowText(RandomElement(Ware_FakeSpecialRounds), text_interval * 2.0)
		
		if (Time() - start_time > reveal_time)
		{
			ShowText(special_round.name, end_time)
			
			Ware_ChatPrint(null, "{color}Special Round: {color}{str}{color}! {str}",TF_COLOR_DEFAULT, COLOR_GREEN, special_round.name, TF_COLOR_DEFAULT, special_round.description)
			
			Ware_PlaySoundOnAllClients("tf2ware_ultimate/pass.mp3")
			
			CreateTimer(function()
			{	
				Ware_SpecialRound = special_round
					
				Ware_SetupSpecialRoundCallbacks()	
						
				// actually change things as late as possible so we don't break things e.g. timescale changing while music is playing would lead to overlapping music
				foreach(name, value in special_round.convars)
				{
					Ware_SpecialRoundSavedConvars[name] <- GetConvarValue(name)
					SetConvarValue(name, value)
				}
				
				if ("OnStart" in Ware_SpecialRoundScope)
					Ware_SpecialRoundScope.OnStart()
					
				if (special_round.allow_damage)
					Ware_ToggleTruce(false)
				
				local event_prefix = "OnGameEvent_"
				local event_prefix_len = event_prefix.len()
				foreach (key, value in Ware_SpecialRoundScope)
				{
					if (typeof(value) == "function" && typeof(key) == "string" && key.find(event_prefix, 0) == 0)
					{
							local event_name = key.slice(event_prefix_len)
							if (event_name.len() > 0)
							{
								if (!(event_name in GameEventCallbacks))
								{
									GameEventCallbacks[event_name] <- []
									RegisterScriptGameEventListener(event_name)
								}
								
								GameEventCallbacks[event_name].push(Ware_SpecialRoundScope)
								Ware_SpecialRoundEvents.append(event_name)
							}
					}
				}
			}, end_time)
		}
		else
		{
			return text_interval
		}
	}, 0.0)
}

function Ware_EndSpecialRound()
{
	if (!Ware_SpecialRound)
		return
	
	if ("OnEnd" in Ware_SpecialRoundScope)
		Ware_SpecialRoundScope.OnEnd()
	
	foreach (name, value in Ware_SpecialRoundSavedConvars)
		SetConvarValue(name, value)
	Ware_SpecialRoundSavedConvars.clear()
	
	foreach (event_name in Ware_SpecialRoundEvents)
		GameEventCallbacks[event_name].pop()
	Ware_SpecialRoundEvents.clear()
	
	Ware_SpecialRound = null
}

function Ware_BeginIntermission(is_boss)
{
	if (Ware_DebugStop)
	{
		// retry
		return 1.0
	}
	
	if (Ware_DebugForceTheme.len() > 0)
	{
		if (Ware_DebugOldTheme == "")
			Ware_DebugOldTheme = Ware_Theme.theme_name
		
		if (Ware_DebugForceTheme == "default")
			Ware_SetTheme("_default")
		else
			Ware_SetTheme(Ware_DebugForceTheme)
	}
	else if (Ware_DebugOldTheme != "")
	{
		Ware_SetTheme(Ware_DebugOldTheme)
		Ware_DebugOldTheme = ""
	}
	
	if (Ware_Theme == {})
		Ware_SetTheme("_default")
	
	if (Ware_SpecialRound && Ware_SpecialRound.cb_on_begin_intermission.IsValid())
	{
		Ware_SpecialRound.cb_on_begin_intermission(is_boss)
	}
	else
	{
		foreach (player in Ware_Players)
		{
			Ware_PlayGameSound(player, "intro")
			Ware_ShowScreenOverlay(player, null)
			Ware_ShowScreenOverlay2(player, null)
		}
		
		CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
	}
}

function Ware_BeginBoss()
{
	Ware_SetTimeScale(1.0)
	
	foreach (player in Ware_Players)
	{
		Ware_PlayGameSound(player, "boss")
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/default_boss")
		Ware_ShowScreenOverlay2(player, null)
	}
	
	CreateTimer(@() Ware_BeginIntermission(true), Ware_GetThemeSoundDuration("boss"))
}

function Ware_Speedup()
{
	if (Ware_SpecialRound && Ware_SpecialRound.cb_on_speedup.IsValid())
	{
		Ware_SpecialRound.cb_on_speedup()
	}
	else
	{
		Ware_SetTimeScale(Ware_TimeScale + Ware_SpeedUpInterval)
		
		foreach (player in Ware_Players)
		{
			Ware_PlayGameSound(player, "speedup")
			Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/default_speed")
			Ware_ShowScreenOverlay2(player, null)
		}
		
		CreateTimer(@() Ware_BeginIntermission(false), Ware_GetThemeSoundDuration("speedup"))
	}
}

function Ware_SetupMinigameCallbacks()
{
	local minigame = Ware_Minigame
	local scope = Ware_MinigameScope
	
	minigame.cb_on_take_damage			= Ware_Callback(scope, "OnTakeDamage")
	minigame.cb_on_player_attack		= Ware_Callback(scope, "OnPlayerAttack")
	minigame.cb_on_player_death			= Ware_Callback(scope, "OnPlayerDeath")
	minigame.cb_on_player_disconnect	= Ware_Callback(scope, "OnPlayerDisconnect")
	minigame.cb_on_player_say			= Ware_Callback(scope, "OnPlayerSay")
	minigame.cb_on_player_voiceline		= Ware_Callback(scope, "OnPlayerVoiceline")
	minigame.cb_on_player_horn			= Ware_Callback(scope, "OnPlayerHorn")
	minigame.cb_on_player_touch			= Ware_Callback(scope, "OnPlayerTouch")
	minigame.cb_on_update				= Ware_Callback(scope, "OnUpdate")
	minigame.cb_check_end				= Ware_Callback(scope, "CheckEnd")	
}

function Ware_StartMinigame(is_boss)
{	
	local valid_players = Ware_GetValidPlayers()
	local player_count = valid_players.len()
	
	local success = false
	local try_debug = true
	local prev_is_boss = is_boss
	local attempts = 0
	local minigame

	while (!success)
	{
		if (++attempts > 25)
		{
			Ware_Error("No valid %s found to pick. There may not be enough minimum players", is_boss ? "bossgame" : "minigame")
			return
		}
		
		local is_forced = false
		if (try_debug)
		{
			do 
			{
				if (Ware_DebugForceBossgame.len() > 0)
				{
					if (Ware_DebugForceBossgameOnce)
					{
						if (is_boss)
						{
							minigame = Ware_DebugForceBossgame
							Ware_DebugForceBossgame = ""
							Ware_DebugForceBossgameOnce = false
							is_forced = true			
							break
						}
					}
					else
					{
						minigame = Ware_DebugForceBossgame
						is_boss = true
						is_forced = true
						break
					}
				}
				
				if (Ware_DebugForceMinigame.len() > 0)
				{
					minigame = Ware_DebugForceMinigame
					if (Ware_DebugForceMinigameOnce)
					{
						Ware_DebugForceMinigame = ""
						Ware_DebugForceMinigameOnce = false
					}
					is_boss = false
					is_forced = true
					break
				}	
			}
			while (0)
			
			try_debug = false
		}
		else
		{
			is_boss = prev_is_boss
		}
		
		if (!is_forced)
		{
			if (is_boss)
			{
				if (Ware_BossgameRotation.len() == 0)
				{
					if (Ware_Bossgames.len() == 0)
					{
						Ware_Error("Bossgame rotation is empty")
						return
					}
					
					Ware_BossgameRotation = Ware_Bossgames.filter(@(i, bossgame) true)
				}
				
				minigame = RemoveRandomElement(Ware_BossgameRotation)
			}
			else
			{
				if (Ware_MinigameRotation.len() == 0)
				{
					if (Ware_Minigames.len() == 0)
					{
						Ware_Error("Minigame rotation is empty")
						return
					}
					
					Ware_MinigameRotation = Ware_Minigames.filter(@(i, bossgame) true)
				}
				
				minigame = RemoveRandomElement(Ware_MinigameRotation)
			}
		}
		
		local path = format("tf2ware_ultimate/%s/%s", is_boss ? "bossgames" : "minigames", minigame)
		try
		{
			Ware_MinigameScope.clear()
			IncludeScript(path, Ware_MinigameScope)
			
			
			local min_players = Ware_MinigameScope.minigame.min_players
			if (player_count >= min_players)
			{
				success = true
			}
			else if (is_forced)
			{
				Ware_Error("Not enough players to load '%s', minimum is %d", minigame, min_players)	
			}
		}
		catch (e)
		{
			Ware_ErrorHandler(format("Failed to load '%s.nut'. Missing from disk or syntax error", path))
		}
		
		if (is_forced && !success)
		{
			Ware_Error("Failed to force load '%s', fallbacking to rotation", minigame)
		}
	}
	
	printf("[TF2Ware] Starting %s '%s'\n", is_boss ? "bossgame" : "minigame", minigame);

	Ware_CriticalZone = true

	Ware_MinigameEnded = false
	Ware_Minigame = Ware_MinigameScope.minigame
	Ware_Minigame.boss = is_boss
	Ware_Minigame.file_name = minigame
	Ware_MinigameStartTime = Time()
	
	foreach (name, value in Ware_Minigame.convars)
	{
		Ware_MinigameSavedConvars[name] <- GetConvarValue(name)
		SetConvarValue(name, value)
	}
	
	local enable_collisions = Ware_Minigame.collisions || (Ware_SpecialRound && Ware_SpecialRound.force_collisions)
	
	Ware_MinigamePlayers.clear()
	foreach (player in valid_players)
	{
		if (enable_collisions)
			player.SetCollisionGroup(COLLISION_GROUP_PLAYER)
		if (Ware_Minigame.thirdperson)
			player.SetForcedTauntCam(1)
		player.RemoveCond(TF_COND_TAUNTING)

		local scope = player.GetScriptScope()
		local data = scope.ware_data
		scope.ware_minidata.clear()
		data.passed = Ware_Minigame.start_pass
		data.passed_effects = false
		data.mission = 0
		Ware_MinigamePlayers.append(data)
	}
	
	local location
	if (player_count > 12 && ((Ware_Minigame.location + "_big") in Ware_Location))
		location = Ware_Location[Ware_Minigame.location + "_big"]
	else
		location = Ware_Location[Ware_Minigame.location]
		
	local custom_teleport = "OnTeleport" in Ware_MinigameScope
	if (location != Ware_MinigameLocation)
	{
		Ware_MinigameLocation = location
		if (!custom_teleport)
			location.Teleport(clone(valid_players))
	}
	
	Ware_SetupMinigameCallbacks()	
	
	if (custom_teleport)
		Ware_MinigameScope.OnTeleport(clone(valid_players))
		
	Ware_UpdateGlobalMaterialState()
	
	if (Ware_Minigame.allow_damage)
		Ware_ToggleTruce(false)
	
	if ("OnStart" in Ware_MinigameScope)
		Ware_MinigameScope.OnStart()

	local event_prefix = "OnGameEvent_"
	local event_prefix_len = event_prefix.len()
	foreach (key, value in Ware_MinigameScope)
	{
		if (typeof(value) == "function" && typeof(key) == "string" && key.find(event_prefix, 0) == 0)
		{
				local event_name = key.slice(event_prefix_len)
				if (event_name.len() > 0)
				{
					if (!(event_name in GameEventCallbacks))
					{
						GameEventCallbacks[event_name] <- []
						RegisterScriptGameEventListener(event_name)
					}
					
					GameEventCallbacks[event_name].push(Ware_MinigameScope)
					Ware_MinigameEvents.append(event_name)
				}
		}
	}
	
	Ware_TextManager.KeyValueFromFloat("holdtime", Ware_Minigame.duration + Ware_Minigame.end_delay)
	
	local GetOverlays = function(overlays) 
	{
		local FixupOverlay = function(name)
		{
			if (name.len() > 0)
			{
				if (name.slice(0, 3) == "../")
					return "hud/tf2ware_ultimate/" + name.slice(3)
				else
					return "hud/tf2ware_ultimate/minigames/" + name
			}
			
			return null
		}
			
		if (typeof(overlays) == "array")
			return overlays.map(@(name) FixupOverlay(name))
		else
			return [FixupOverlay(overlays)]
	}
	
	local overlays = [], overlays2 = []
	if (Ware_Minigame.custom_overlay == null)
		overlays = ["hud/tf2ware_ultimate/minigames/" + minigame]
	else
		overlays = GetOverlays(Ware_Minigame.custom_overlay)
	
	if (Ware_Minigame.custom_overlay2 != null)
	{
		overlays2 = GetOverlays(Ware_Minigame.custom_overlay2)
		Ware_MinigameOverlay2Set = true
	}

	local overlay_len = overlays.len()
	local overlay2_len = overlays2.len()
	foreach (data in Ware_MinigamePlayers)
	{	
		local mission = data.mission
		if (mission < overlay_len)
			Ware_ShowScreenOverlay(data.player, overlays[mission])
		if (mission < overlay2_len)
			Ware_ShowScreenOverlay2(data.player, overlays2[mission])
	}
	
	Ware_PlayMinigameSound(null, Ware_Minigame.music)
	
	if (Ware_SpecialRound)
		Ware_SpecialRound.cb_on_minigame_start()
	
	Ware_MinigamePreEndTimer = CreateTimer(function() 
	{ 
		Ware_MinigameEnded = true
		if ("OnEnd" in Ware_MinigameScope) 
			Ware_MinigameScope.OnEnd()
			
		if (Ware_Minigame.start_pass)
		{
			foreach (data in Ware_MinigamePlayers)
			{
				if (data.passed && !data.passed_effects)
				{
					Ware_ShowPassEffects(data.player)
					data.passed_effects = true
				}
			}
		}
			
		if (Ware_Minigame.suicide_on_end)
			Ware_SuicideFailedPlayers()
	}, Ware_Minigame.duration)
	
	Ware_MinigameEndTimer = CreateTimer
	(
		@() Ware_EndMinigameInternal(), 
		Ware_Minigame.duration + Ware_Minigame.end_delay
	)
	
	Ware_CriticalZone = false
}

function Ware_EndMinigame()
{
	if (Ware_MinigameEnded)
		return
		
	FireTimer(Ware_MinigamePreEndTimer)
	KillTimer(Ware_MinigameEndTimer)
	
	Ware_MinigameEndTimer = CreateTimer(
		@() Ware_EndMinigameInternal(),
		Ware_Minigame.end_delay
	)
}

Ware_DeferredPlayers <- []
function Ware_DeferredPlayerTeleport()
{
	Ware_MinigameHomeLocation.Teleport(Ware_DeferredPlayers)
	Ware_DeferredPlayers.clear()
}

function Ware_EndMinigameInternal()
{
	Ware_CriticalZone = true
	
	if ("OnCleanup" in Ware_MinigameScope) 
		Ware_MinigameScope.OnCleanup()
				
	Ware_MinigamesPlayed++
	if (Ware_Minigame.boss)
		Ware_BossgamesPlayed++
	
	foreach (name, value in Ware_MinigameSavedConvars)
		SetConvarValue(name, value)
	Ware_MinigameSavedConvars.clear()
	
	local highest_score = 1
	local highest_players = Ware_MinigameHighScorers
	highest_players.clear()
	
	local restore_collisions = Ware_Minigame.collisions && (!Ware_SpecialRound || !Ware_SpecialRound.force_collisions)
	
	local player_count = 0
	local respawn_players = []
	foreach (player in Ware_Players)
	{
		if (!(player.GetTeam() & 2))
			continue
			
		player.RemoveAllObjects(false)
		player.SetGrapplingHookTarget(null, false)

		if (restore_collisions)
			player.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		if (Ware_Minigame.thirdperson && (!Ware_SpecialRound || Ware_SpecialRound.name != "Thirdperson")) // don't like checking this manually but not sure what else to do - pokepasta
			player.SetForcedTauntCam(0)
		if (Ware_Minigame.condition != null)
			player.RemoveCond(Ware_Minigame.condition)
			
		local data = player.GetScriptScope().ware_data
		if (data.saved_team != null)
		{
			Ware_SetPlayerTeamInternal(player, data.saved_team)
			data.saved_team = null
		}
			
		if (IsEntityAlive(player))
		{
			local melee
			if (data.special_melee)
				melee = data.special_melee
			else
				melee = data.melee
			
			if (melee)
			{
				foreach (attribute, value in data.melee_attributes)
					melee.RemoveAttribute(attribute)
			}
			data.melee_attributes.clear()
			
			foreach (attribute in data.attributes)
				player.RemoveCustomAttribute(attribute)
			data.attributes.clear()
			
			player.RemoveCond(TF_COND_TELEPORTED)
			player.SetHealth(player.GetMaxHealth())
			SetPropInt(player, "m_nImpulse", 101) // refill ammo						
			Ware_StripPlayer(player, true)
		}
		else
		{
			respawn_players.append(player)
		}
		
		player_count++
	}

	Ware_CheckHomeLocation(player_count)
	
	foreach (player in respawn_players)
		player.ForceRespawn()
	
	if (Ware_MinigameLocation != Ware_MinigameHomeLocation)
	{
		local players = []
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player
			// parented players aren't unparented at this point so need to defer it to end of frame
			if (player.GetMoveParent())
				Ware_DeferredPlayers.append(player)
			else
				players.append(player)
		}
		
		if (Ware_DeferredPlayers.len() > 0)
			EntityEntFire(World, "CallScriptFunction", "Ware_DeferredPlayerTeleport")
		
		Ware_MinigameHomeLocation.Teleport(players)
		Ware_MinigameLocation = Ware_MinigameHomeLocation
	}
	
	if (Ware_Minigame.allow_damage)
		Ware_ToggleTruce(true)
		
	Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_STOP)

	local all_passed = true
	local all_failed = true
	
	foreach (data in Ware_MinigamePlayers)
	{
		if (data.passed)
			all_failed = false
		else
			all_passed = false
	}
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		
		local overlay
		local sound
		if (all_passed)
		{
			overlay = "hud/tf2ware_ultimate/default_victory_all"
			sound = "victory"
		}
		else if (all_failed)
		{
			overlay = "hud/tf2ware_ultimate/default_failure_all"
			sound = "failure_all"
		}
		else if (data.passed)
		{
			overlay = "hud/tf2ware_ultimate/default_victory"
			sound = "victory"
		}
		else
		{
			overlay = "hud/tf2ware_ultimate/default_failure"
			sound = "failure"
		}		
		
		Ware_ShowMinigameText(player, "")
		Ware_PlayGameSound(player, sound)
		Ware_ShowScreenOverlay(player, overlay)
		if (Ware_MinigameOverlay2Set)
			Ware_ShowScreenOverlay2(player, null)
		
		if (Ware_SpecialRound && Ware_SpecialRound.cb_on_calculate_scores.IsValid())
		{
			highest_players = Ware_SpecialRound.cb_on_calculate_scores(data, player, highest_score, highest_players)
		}
		else
		{
			if (data.passed)
				data.score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
				
			if (data.score > highest_score)
			{
				highest_score = data.score
				highest_players.clear()
				highest_players.append(player)
			}
			else if (data.score == highest_score)
			{
				highest_players.append(player)
			}
		}
	}
	
	CreateTimer(function()
	{
		foreach (player in highest_players)
			if (player.IsValid())
				player.AddCond(TF_COND_TELEPORTED)
	}, 0.25)

	foreach (event_name in Ware_MinigameEvents)
		GameEventCallbacks[event_name].pop()
	Ware_MinigameEvents.clear()
		
	foreach (entity in Ware_Minigame.entities)
		if (entity.IsValid())
			entity.Kill()
	
	foreach (name, v in Ware_Minigame.cleanup_names)
		EntFire(name, "Kill")
		
	foreach (timer in Ware_Minigame.timers)
		KillTimer(timer)
		
	foreach (annotation in Ware_Minigame.annotations)
		Ware_HideAnnotation(annotation)
		
	if (Ware_SpecialRound)
		Ware_SpecialRound.cb_on_minigame_end()		
	
	Ware_Minigame = null
	Ware_MinigameScope.clear()
	Ware_MinigameOverlay2Set = false
	
	local sound_duration = Max(Ware_GetThemeSoundDuration("victory"), Ware_GetThemeSoundDuration("failure"))
	if (all_failed)
		sound_duration = Ware_GetThemeSoundDuration("failure_all")
	
	if ((Ware_MinigamesPlayed > Ware_GetBossThreshold() && Ware_BossgamesPlayed >= Ware_GetBossCount()) || Ware_DebugGameOver)
		CreateTimer(@() Ware_GameOver(), sound_duration)
	else if (Ware_MinigamesPlayed >= Ware_GetBossThreshold() && Ware_BossgamesPlayed < Ware_GetBossCount())
		CreateTimer(@() Ware_BeginBoss(), sound_duration)
	else if (Ware_MinigamesPlayed > 0 && Ware_MinigamesPlayed % Ware_SpeedUpThreshold == 0)
		CreateTimer(@() Ware_Speedup(), sound_duration)
	else
		CreateTimer(@() Ware_BeginIntermission(false), sound_duration)
		
	Ware_CriticalZone = false
}

function Ware_GameOver()
{
	Ware_Finished = true
	Ware_RoundsPlayed++
	
	// TODO: move this to start of next round if it's safe to do so
	// reason being it's more interesting to still have the special round's convars or what have you going on round end
	if (Ware_SpecialRound != null)
		Ware_EndSpecialRound()
	
	local highest_players = Ware_MinigameHighScorers
	highest_players = highest_players.filter(@(i, player) player.IsValid())
	
	local highest_score = 0
	local winner_count = highest_players.len()
	
	if (winner_count > 0)
		highest_score = highest_players[0].GetScriptScope().ware_data.score
	
	local delay = GetConvarValue("mp_bonusroundtime").tofloat()
	Ware_ToggleTruce(false)
	
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		
		if (highest_players.find(player) != null)
		{
			Ware_PlayGameSound(player, "gameclear")
			player.AddCondEx(TF_COND_CRITBOOSTED, delay, null)
			player.SetScriptOverlayMaterial("hud/tf2ware_ultimate/default_victory")
			// TODO: give full loadout back and add other effects
			// TODO: don't allow damage to other winners
		}
		else
		{
			Ware_PlayGameSound(player, "gameover")
			player.SetScriptOverlayMaterial("hud/tf2ware_ultimate/default_failure")
			StunPlayer(player, TF_TRIGGER_STUN_LOSER, false, delay, 0.5)
		}
	}
	
	Ware_RoundEndMusicTimer <- CreateTimer(function() {
		foreach(player in Ware_Players)
			Ware_PlayGameSound(player, "results")
	}, 5.0)
	
	if (winner_count > 1)
	{
		Ware_ChatPrint(null, "{color}The winners each with {int} points:", TF_COLOR_DEFAULT, highest_score)
		foreach (player in highest_players)
			Ware_ChatPrint(null, "> {player} {color}!", player, TF_COLOR_DEFAULT)
	}
	else if (winner_count == 1)
	{
		Ware_ChatPrint(null, "{player} {color}won with {int} points!", highest_players[0], TF_COLOR_DEFAULT, highest_score)
	}	
	else if (winner_count == 0)
	{
		Ware_ChatPrint(null, "{color}Nobody won!?", TF_COLOR_DEFAULT)
	}
	
	// TODO: add firework effects

	local win = SpawnEntityFromTableSafe("game_round_win", 
	{
		teamnum         = TEAM_UNASSIGNED
		force_map_reset = true
		switch_teams    = true
	})
	SetInputHook(win, "RoundWin", null, function()
	{
		// prevent loser state on winners
		SetPropInt(GameRules, "m_iRoundState", GR_STATE_RND_RUNNING)
		// hide win panel
		SendGlobalGameEvent("tf_game_over", {})
		// stop stalemate sound
		for (local team = TF_TEAM_RED; team <= TF_TEAM_BLUE; team++)
		{
			SendGlobalGameEvent("teamplay_broadcast_audio",
			{
				team             = team
				sound            = "Game.Stalemate"
				additional_flags = SND_STOP
				player           = -1
			})
		}
	})
	EntityEntFire(win, "RoundWin")
}

function Ware_OnUpdate()
{
	if (Ware_SpecialRound)
		Ware_SpecialRound.cb_on_update()
		
	if (Ware_Minigame == null)
		return
		
	if (!Ware_MinigameEnded)
	{
		local ret = Ware_Minigame.cb_check_end()
		if (ret != null && ret == true)
			Ware_EndMinigame()
	}
	
	local time = Time()
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (player.InCond(TF_COND_HALLOWEEN_KART) && data.horn_timer < time)
		{
			local buttons = GetPropInt(player, "m_nButtons")
			local buttons_pressed = (data.horn_buttons ^ buttons) & buttons
			if (buttons_pressed & IN_ATTACK)
			{
				player.EmitSound(SFX_WARE_KART_HORN)
				data.horn_timer = time + 1.0
				Ware_Minigame.cb_on_player_horn(player)		
			}
			data.horn_buttons = buttons
		}
	}
	
	Ware_Minigame.cb_on_update()
	
	if (Ware_Minigame.cb_on_player_attack.IsValid())
	{
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player
			local weapon = player.GetActiveWeapon()
			if (weapon && !weapon.IsMeleeWeapon())
			{
				local fire_time = GetPropFloat(weapon, "m_flLastFireTime")
				local scope = weapon.GetScriptScope()
				if (fire_time > scope.last_fire_time)
				{
					Ware_Minigame.cb_on_player_attack(player)
					scope.last_fire_time = fire_time
				}
			}
		}
	}
	
	if (Ware_Minigame.cb_on_player_voiceline.IsValid())
	{
		for (local scene; scene = FindByClassname(scene, "instanced_scripted_scene");)
		{
			scene.KeyValueFromString("classname", "ware_voiceline")
			MarkForPurge(scene)
			
			local player = GetPropEntity(scene, "m_hOwner")
			if (player)
			{
				local name = GetPropString(scene, "m_szInstanceFilename")
				Ware_Minigame.cb_on_player_voiceline(player, name.tolower())
			}
		}
	}
	
	if (Ware_Minigame.cb_on_player_touch.IsValid())
	{
		local candidates = []
		local bloat_maxs = Vector(0.05, 0.05, 0.05)
		local bloat_mins = bloat_maxs * -1.0
		
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player
			if (IsEntityAlive(player))
			{
				local origin = player.GetOrigin()
				candidates.append(
				[
					player, 
					origin + player.GetBoundingMins() + bloat_mins, 
					origin + player.GetPlayerMaxs() + bloat_maxs
				])
			}
		}
		
		local intersections = {}
		local candidates_len = candidates.len()
		for (local i = 0; i < candidates_len; ++i)
		{
			local candidate_a = candidates[i]
			if (candidate_a in intersections)
				continue
			
			for (local j = i + 1; j < candidates_len; ++j)
			{
				local candidate_b = candidates[j]
				if (candidate_b in intersections)
					continue
				
				if (IntersectBoxBox(candidate_a[1], candidate_a[2], candidate_b[1], candidate_b[2]))
				{
					local player_a = candidate_a[0]
					local player_b = candidate_b[0]		
					intersections[player_a] <- player_b
					intersections[player_b] <- player_a
				}
			}
		}
		
		foreach (player, other_player in intersections)
			Ware_Minigame.cb_on_player_touch(player, other_player)
	}
	
	return -1
}

function Ware_LeaderboardUpdate()
{
	foreach (data in Ware_PlayersData)
	{
		local i = data.index
		SetPropIntArray(self, "m_iTotalScore", data.score, i)
	}
	
	return -1
}

ClearGameEventCallbacks()

function OnScriptHook_OnTakeDamage(params)
{
	if (params.damage_custom == TF_DMG_CUSTOM_SUICIDE)
		return
		
	if (Ware_SpecialRound)
	{
		if (Ware_SpecialRound.cb_on_take_damage(params) == false)
		{
			params.damage = 0
			params.early_out = true
			return
		}
	}
	
	if (Ware_Minigame == null)
	{
		if (params.damage_type & DMG_FALL)
		{
			params.damage = 0
			params.early_out = true
			return
		}
	}
	
	local victim = params.const_entity
	local attacker = params.attacker
	
	// handle the case where truce is disabled but don't want damage between players
	if (victim != attacker && victim.IsPlayer() && attacker.IsPlayer())
	{
		if (!Ware_Finished && Ware_Started && (Ware_Minigame == null || !Ware_Minigame.allow_damage))
		{
			params.damage = 0
			params.early_out = true	
			return
		}
	}

	local same_team = false
	if (victim.IsPlayer()
		&& attacker
		&& attacker != victim
		&& attacker.IsPlayer()
		&& victim.GetTeam() == attacker.GetTeam())
	{
		same_team = true
	}

	if (!Ware_Minigame || Ware_Minigame.friendly_fire)
	{
		params.force_friendly_fire = true
		
		// replicate backstabs for teammates
		local force_backstabs = Ware_Minigame && Ware_Minigame.force_backstab
		if ((same_team || force_backstabs) && attacker && attacker.IsPlayer())
		{
			local weapon = attacker.GetActiveWeapon()
			if (force_backstabs || (weapon && weapon.GetClassname() == "tf_weapon_knife"))
			{
				local to_target = victim.GetCenter() - attacker.GetCenter()
				to_target.z = 0.0
				to_target.Norm()

				local attacker_fwd = attacker.EyeAngles().Forward()
				attacker_fwd.z = 0.0
				attacker_fwd.Norm()

				local victim_fwd = victim.EyeAngles().Forward()
				victim_fwd.z = 0.0
				victim_fwd.Norm()

				if (to_target.Dot(victim_fwd) > 0.0 
					&& to_target.Dot(attacker_fwd) > 0.5 
					&& victim_fwd.Dot(attacker_fwd) > -0.3)
				{
					local viewmodel = GetPropEntity(attacker, "m_hViewModel")
					if (viewmodel)
						viewmodel.ResetSequence(viewmodel.LookupSequence("ACT_MELEE_VM_SWINGHARD"))
						
					params.damage       = victim.GetHealth() * 2.0
					params.damage_stats = TF_DMG_CUSTOM_BACKSTAB
					params.damage_type  = params.damage_type | DMG_CRIT
				}			
			}
		}
	}
	else
	{
		if (same_team)
		{
			params.damage = 0
			params.early_out = true
			return
		}
	}
	
	if (Ware_Minigame != null 
		&& Ware_Minigame.cb_on_take_damage(params) == false)
	{
		params.damage = 0
		params.early_out = true
		return
	}
}

function OnGameEvent_teamplay_round_start(params)
{
	// kill results music if it's playing from a previous round
	Ware_PlayGameSound(null, "results", SND_STOP)
	
	Ware_SetTimeScale(1.0)
	
	foreach (player in Ware_Players)
	{
		player.GetScriptScope().ware_data.score = 0
		player.SetScriptOverlayMaterial("")
		EntFireByHandle(ClientCmd, "Command", "r_cleardecals", -1, player, null)
		BrickPlayerScore(player)
		Ware_PlayGameSound(player, "results", SND_STOP)
	}
	
	if (IsInWaitingForPlayers())
		return
	
	if (Ware_Started)
		return
	Ware_Started = true
	
	// check for next theme. otherwise first round always uses default theme
	if (Ware_NextTheme != "")
	{
		Ware_SetTheme(Ware_NextTheme)
		Ware_NextTheme = ""
	}
	else if (Ware_RoundsPlayed > 0)
	{
		local new_theme
		
		// roll until we get a new one
		do{
			new_theme = RandomElement(Ware_Themes)
		}
		while (new_theme == Ware_Theme)
		
		Ware_Theme <- new_theme
		
		Ware_SetupThemeSounds()
	}
	else if (Ware_IsThemeValid())
		Ware_SetupThemeSounds()
	else
	{
		Ware_Error("Unexpected theme on round start, setting to default instead.")
		Ware_Theme <- Ware_Themes[0]
		Ware_SetupThemeSounds()
	}
	
	Ware_ChatPrint(null, "{color}Theme: {color}{str}", TF_COLOR_DEFAULT, COLOR_LIME, Ware_Theme.visual_name)
	
	// putting this here rather than in loop we already have since i want to go after waiting for players check. if that doesnt matter just move this in.
	foreach(player in Ware_Players)
		Ware_PlayGameSound(player, "lets_get_started", SND_STOP)
	
	Ware_ToggleTruce(true)

	Ware_MinigameRotation.clear()
	foreach (minigame in Ware_Minigames)
		Ware_MinigameRotation.append(minigame)
	
	// don't do two special rounds in a row (checks for special round from last round and then clears it, unless it's forced)
	local delay = 0.0
	
	if (Ware_DebugNextSpecialRound.len() > 0 ||
		(Ware_RoundsPlayed > 0
		&& !Ware_SpecialRoundPrevious 
		&& Ware_SpecialRoundChance != 0 
		&& RandomInt(1, Ware_SpecialRoundChance) == Ware_SpecialRoundChance))
	{
		delay = Ware_GetThemeSoundDuration("special_round")
		Ware_BeginSpecialRound()
	}
	else
	{
		Ware_SpecialRoundPrevious = false
	}
	
	CreateTimer(@() Ware_BeginIntermission(false), delay)
}

// called right before the map is reset for a new round
function OnGameEvent_scorestats_accumulated_update(params)
{
	if (Ware_Minigame) // when restarted mid-minigame
	{
		if ("OnCleanup" in Ware_MinigameScope) 
			Ware_MinigameScope.OnCleanup()
		
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player
			if (!player.IsValid())
				continue
				
			if (data.saved_team != null)
			{
				Ware_SetPlayerTeamInternal(player, data.saved_team)
				data.saved_team = null
			}		
		}
		
		foreach (name, value in Ware_MinigameSavedConvars)
			SetConvarValue(name, value)
		Ware_MinigameSavedConvars.clear()
		
		Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_STOP)
	}

	if (Ware_SpecialRound) // same as above
	{
		Ware_EndSpecialRound()
		Ware_PlayGameSound(null, "special_round", SND_STOP)
	}
}

function OnGameEvent_recalculate_truce(params)
{
	// minigames can spawn bosses like merasmus which will revert truce to false after its over
	if (Ware_Minigame)
	{
		if (!Ware_Minigame.allow_damage)
			Ware_ToggleTruce(true)
	}
	else
	{
		Ware_ToggleTruce(true)
	}
}

function PlayerPostSpawn()
{
	if (Ware_TimeScale != 1.0)
		self.AddCustomAttribute("voice pitch scale", Ware_GetPitchFactor(), -1)
	SetPropBool(self, "m_Shared.m_bShieldEquipped", false)
	
	local melee = ware_data.special_melee
	if (melee == null)
		melee = ware_data.melee
	
	if (melee != null)
	{
		// not sure why this is needed
		melee.SetModel(TF_CLASS_ARMS[self.GetPlayerClass()])		
		self.Weapon_Switch(melee)
		melee.EnableDraw()
		
		// hack: something is not clearing the render color
		// last minute for the playtest
		SetPropInt(melee, "m_clrRender", 0xFFFFFFFF)
		
		// hack: calculates correct speed
		self.AddCondEx(TF_COND_SPEED_BOOST, 0.001, null)
	}
}

function OnGameEvent_player_spawn(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player == null)
		return
	
	if (Ware_Players.find(player) == null)
	{
		MarkForPurge(player)
		player.ValidateScriptScope()
		local scope = player.GetScriptScope()
		scope.ware_data <- Ware_PlayerData(player)
		scope.ware_minidata <- {}
		Ware_Players.append(player)
		Ware_PlayersData.append(scope.ware_data)
		if (params.team == TEAM_UNASSIGNED)
			return
	}
	
	local data = player.GetScriptScope().ware_data

	// this is to fix persisting attributes if restarting mid-minigame
	local melee = data.melee
	if (melee && melee.IsValid())
	{
		foreach (attribute, value in data.melee_attributes)
			melee.RemoveAttribute(attribute)
	}
	data.attributes.clear()
	data.melee_attributes.clear()
	
	if (params.team & 2)
	{
		if (Ware_MinigameHighScorers.find(player) != null)
			player.AddCond(TF_COND_TELEPORTED)
		
		if (!data.start_sound)
			EntityEntFire(player, "CallScriptFunction", "Ware_PlayStartSound", 2.0)
		
		local melee = Ware_ParseLoadout(player)		
		if (melee)
			Ware_RemoveMeleeAttributes(melee)
			
		EntityEntFire(player, "CallScriptFunction", "PlayerPostSpawn")
		
		player.AddHudHideFlags(HIDEHUD_BUILDING_STATUS|HIDEHUD_CLOAK_AND_FEIGN|HIDEHUD_PIPES_AND_CHARGE)
		player.SetCustomModel("")		
		player.SetHealth(player.GetMaxHealth())	
		player.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY);
		SetPropInt(player, "m_clrRender", 0xFFFFFFFF)
		
		if (Ware_SpecialRound)
		{
			if (Ware_SpecialRound.cb_get_player_roll.IsValid())
			{
				local eye_angles = player.EyeAngles()
				eye_angles.z = Ware_SpecialRound.cb_get_player_roll(player)
				player.SnapEyeAngles(eye_angles)
			}
			
			Ware_SpecialRound.cb_on_player_spawn(player)
		}
	}
}

function OnGameEvent_post_inventory_application(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player == null)
		return
	
	if (Ware_SpecialRound)
		Ware_SpecialRound.cb_on_player_inventory(player)
}

function OnGameEvent_player_initial_spawn(params)
{
	local player = PlayerInstanceFromIndex(params.index)
	if (player == null)
		return
	
	BrickPlayerScore(player)
}

function OnGameEvent_player_changeclass(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player && !IsEntityAlive(player) && !IsInWaitingForPlayers())
		SetPropFloat(player, "m_flDeathTime", Time()) // no late respawns
}

function OnGameEvent_player_death(params)
{
	local ammos = []
	for (local ammo; ammo = FindByClassname(ammo, "tf_ammo_pack");)
	{
		MarkForPurge(ammo)
		ammos.append(ammo)
	}
	
	foreach (ammo in ammos)
		ammo.Kill()
	
	if (Ware_Minigame == null)
		return
		
	if (Ware_Minigame.fail_on_death == true)
	{
		local victim = GetPlayerFromUserID(params.userid)
		if (victim != null)
			Ware_PassPlayer(victim, false)
	}
	
	Ware_Minigame.cb_on_player_death(params)
}

function OnGameEvent_player_disconnect(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (!player)
		return
		
	local data = player.GetScriptScope().ware_data
	local idx = Ware_MinigamePlayers.find(data)
	if (idx != null)
		Ware_MinigamePlayers.remove(idx)
		
	idx = Ware_Players.find(player)
	if (idx != null)
		Ware_Players.remove(idx)
		
	idx = Ware_PlayersData.find(data)
	if (idx != null)
		Ware_PlayersData.remove(idx)
		
	if (Ware_Minigame == null)
		return
	
	Ware_Minigame.cb_on_player_disconnect(player)
}

function OnGameEvent_teamplay_game_over(params)
{
	// map end
	KillTimer(Ware_RoundEndMusicTimer)
	Ware_PlayGameSound(null, "results", SND_STOP)
	Ware_PlayGameSound(null, "mapend")
}

function Ware_DevCommandForceMinigame(player, text, is_boss, once)
{
	local gamename = is_boss ? "Ware_DebugForceBossgame" : "Ware_DebugForceMinigame"
	local args = split(text, " ")
	
	if (args.len() >= 1)
		ROOT[gamename] = args[0]
	else
		ROOT[gamename] = ""
		
	ROOT[gamename + "Once"] = once	
	
	local name = is_boss ? "bossgame" : "minigame"
	if (once)
		Ware_ChatPrint(player, "Setting next {str} to '{str}'", name, ROOT[gamename])	
	else
		Ware_ChatPrint(player, "Forced {str} to '{str}'", name, ROOT[gamename])	
}

Ware_DevCommands <-
{
	"nextminigame"  : function(player, text) { Ware_DevCommandForceMinigame(player, text, false, true)  }
	"nextbossgame"  : function(player, text) { Ware_DevCommandForceMinigame(player, text, true, true)   }
	"forceminigame" : function(player, text) { Ware_DevCommandForceMinigame(player, text, false, false) }
	"forcebossgame" : function(player, text) { Ware_DevCommandForceMinigame(player, text, true, false)  }
	"nexttheme": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
			Ware_NextTheme = args[0]
		else
			Ware_NextTheme = ""
		Ware_ChatPrint(player, "Setting next theme to '{str}'", Ware_NextTheme)
	}
	"forcetheme": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
			Ware_DebugForceTheme = args[0]
		else
			Ware_DebugForceTheme = ""
		Ware_ChatPrint(player, "Forced theme to '{str}'", Ware_DebugForceTheme)
	}
	"nextspecial": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
			Ware_DebugNextSpecialRound = args[0]
		else
			Ware_DebugNextSpecialRound = ""
		Ware_ChatPrint(player, "Forced next special round to '{str}'", Ware_DebugNextSpecialRound)
	}
	"restart" : function(player, text)
	{
		SetConvarValue("mp_restartgame_immediate", 1)
		Ware_ChatPrint(player, "Restarting...")
	}
	"gameover" : function(player, text)
	{
		Ware_DebugGameOver = true
		Ware_ChatPrint(player, "Forcing game over...")		
	}
	"stop" : function(player, text)
	{
		Ware_DebugStop = true
		Ware_ChatPrint(player, "Stopping...")
	}
	"resume" : function(player, text)
	{
		Ware_DebugStop = false
		Ware_ChatPrint(player, "Resuming...")
	}
	"run" : function(player, text)
	{
		try
		{
			local quotes = split(text, "'")
			local quote_len = quotes.len() - 1
			if (quote_len > 0)
			{
				text = ""
				foreach (i, quote in quotes)
				{
					text += quote
					if (i != quote_len)
						text += "\""
				}		
			}
			local code = "return (@() " + text + ").bindenv(ROOT)()"
			printf("Player '%s' executed code: %s\n", GetPlayerName(player), code)
			local ret = compilestring(code)()
			ClientPrint(player, HUD_PRINTTALK, "\x07FFFFFFRETURN: " + ret)
		}
		catch (e)
		{
			ClientPrint(player, HUD_PRINTTALK, "\x07FF0000ERROR: " + e)
		}	
	}
	"timescale" : function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
		{
			local scale = args[0].tofloat()
			Ware_SetTimeScale(scale)
			Ware_ChatPrint(player, "Set timescale to {%g}", scale)
		}
		else		
		{
			Ware_ChatPrint(player, "Missing required scale parameter")
		}
	}
	"help" : function(player, text)
	{
		local cmds = []
		foreach (name, func in Ware_DevCommands)
			if (name != "help")
				cmds.append(name)
			
		cmds.sort(@(a, b) a <=> b)
		foreach (name in cmds)
			ClientPrint(player, HUD_PRINTTALK, "\x07FFFFFF* " + name)
	}
}

function OnGameEvent_player_say(params)
{	
	local player = GetPlayerFromUserID(params.userid)
	if (player == null)
		return
		
	local text = params.text
	if (text.len() > 0)
	{
		if (startswith(text, "!ware_"))
		{
			local steamid3 = GetPlayerSteamID3(player)
			if (steamid3 in DEVELOPER_STEAMID3)
			{
				local len = text.find(" ")
				local cmd = len != null ? text.slice(6, len) : text.slice(6)
				if (cmd in Ware_DevCommands)
					Ware_DevCommands[cmd](player, len != null ? text.slice(len+1) : "")
				else
					Ware_ChatPrint(player, "Unknown command '{str}'", cmd)
			}
			else
			{
				Ware_ChatPrint(player, "You do not have access to this command")
			}
			
			return
		}
	}
	
	if (Ware_Minigame == null)
		return
	
	// TODO: return value should indicate whether to hide message
	Ware_Minigame.cb_on_player_say(player, text)
}

__CollectGameEventCallbacks(this)

Ware_FindStandardEntities()
Ware_SetupLocations()