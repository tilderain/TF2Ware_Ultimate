// by ficool2 and pokemonpasta

function Ware_CheckPlugin()
{
	local plugin_found = Convars.GetStr("ware_version") != null
	if (IsDedicatedServer() || plugin_found)
	{
		Ware_Plugin = true
		if (!plugin_found)
		{
			ClientPrint(null, HUD_PRINTTALK, "\x07FF0000" + Ware_NeedsPluginMsg)
			printl(Ware_NeedsPluginMsg)
			Ware_NeedsPlugin = true
		}
		else
		{
			printl("\tVScript: TF2Ware Ultimate linked to SourceMod plugin")
			Ware_NeedsPlugin = false
		}
	}
}

if (!("Ware_Plugin" in this))
{
	Ware_Plugin <- false
	Ware_NeedsPlugin <- false
	Ware_NeedsPluginMsg <- "** TF2Ware Ultimate requires the SourceMod plugin installed on dedicated servers"
	Ware_CheckPlugin()
	printl("\tVScript: TF2Ware Ultimate Started")
}
else if (Ware_NeedsPlugin)
{
	Ware_CheckPlugin()
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
		
	local developers = []
	if ("Ware_Players" in ROOT)
	{
		developers = Ware_Players.filter(@(i, player) GetPlayerSteamID3(player) in DEVELOPER_STEAMID3)
		// show for non-developers in local host as well
		if (Ware_ListenHost && Ware_ListenHost.IsValid() && developers.find(Ware_ListenHost) == null)
			developers.append(Ware_ListenHost)
	}
		
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
		PlaySoundOnAllClients(SFX_WARE_ERROR)		
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

if (Ware_Plugin)
{
	Ware_TextProxy <- CreateEntitySafe("point_worldtext")
	Ware_TextProxy.KeyValueFromString("classname", "ware_textproxy")
}
else
{
	SendToConsole("sv_cheats 1")
	// this fixes ghosts being stuttery
	SendToConsole("nb_update_frequency 0.05")
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
	Ware_DebugNextSpecialRound  <- ""
}
Ware_DebugForceTheme      <- ""
Ware_DebugOldTheme        <- ""
Ware_DebugGameOver		  <- false

Ware_TextManager          <- null

Ware_ParticleSpawner      <- null

Ware_MinigameRotation     <- []
if (!("Ware_BossgameRotation" in this))
	Ware_BossgameRotation <- []
if (!("Ware_SpecialRoundRotation" in this))
	Ware_SpecialRoundRotation <- []

Ware_MinigameSavedConvars <- {}
Ware_MinigameEvents       <- []
Ware_MinigameOverlay2Set  <- false
Ware_MinigameStartTime    <- 0.0
Ware_MinigamePreEndTimer  <- null
Ware_MinigameEndTimer     <- null
Ware_MinigameEnded        <- false
Ware_MinigameTopScorers   <- []
Ware_MinigamesPlayed	  <- 0
Ware_BossgamesPlayed      <- 0

// dunno where to put this
Ware_RoundEndMusicTimer   <- null
Ware_BlockPassEffects     <- false

Ware_AllowLoadouts		  <- false

if (!("Ware_Precached" in this))
{
	Ware_Precached                <- false
	
	// optimization to avoid having to fetch it back from player handles 
	// which eats up +1 native call per player
	Ware_PlayersData              <- []
	Ware_MinigamePlayersData      <- []
	
	Ware_RoundsPlayed             <- 0
	Ware_MapResetTimer            <- null
	
	Ware_Theme              	  <- Ware_Themes[0]
	Ware_CurrentThemeSounds 	  <- {}
	Ware_DebugNextTheme           <- ""
	
	Ware_SpecialRound             <- null
	Ware_SpecialRoundScope        <- {}
	Ware_SpecialRoundSavedConvars <- {}
	Ware_SpecialRoundEvents       <- []
	Ware_SpecialRoundPrevious     <- false
	
	Ware_AnnotationIDs            <- 0
	
	// credits
	Ware_Authors                  <- {}
	Ware_Credits                  <- "{color}TF2Ware Ultimate {color}by ficool2 and pokemonPasta, based on \"{color}TF2Ware Universe{color}\" by SLAG.TF. See console for a full list of contributors."
	
	// this shuts up incursion distance warnings from the nav mesh
	CreateEntitySafe("base_boss").KeyValueFromString("classname", "point_commentary_viewpoint")
}

function Ware_FindStandardEntities()
{
	World     <- FindByClassname(null, "worldspawn")
	WaterLOD  <- FindByClassname(null, "water_lod_control")
	GameRules <- FindByClassname(null, "tf_gamerules")
	PlayerMgr <- FindByClassname(null, "tf_player_manager")
	TeamMgrs  <- []
	for (local mgr; mgr = FindByClassname(mgr, "tf_team");)
		TeamMgrs.append(mgr)
	ClientCmd <- CreateEntitySafe("point_clientcommand")
	
	MarkForPurge(WaterLOD)
	
	// avoid adding the think again to not break global execution order
	if (World.GetScriptThinkFunc() != "Ware_OnUpdate")
	{
		AddThinkToEnt(World, "Ware_OnUpdate")
		AddThinkToEnt(PlayerMgr, "Ware_LeaderboardUpdate")
	}
	
	Ware_UpdateGlobalMaterialState()
	
	Ware_TextManager = SpawnEntityFromTableSafe("game_text",
	{
		message = ""
		effect  = 0
		fadein  = 0.0
		fadeout = 0.0
		fxtime  = 0.0
	})
	
	Ware_ParticleSpawner <- CreateEntitySafe("trigger_particle")
	Ware_ParticleSpawner.KeyValueFromInt("spawnflags", SF_TRIGGER_ALLOW_ALL)
}

Ware_PrecacheGenerator <- null
function Ware_PrecacheNext()
{
	local PrecacheFile = function(folder, name)
	{
		local path = format("tf2ware_ultimate/%s/%s", folder, name)
		try
		{
			local scope = {}
			IncludeScript(path, scope)
			if ("OnPrecache" in scope)
				scope.OnPrecache()
				
			if ("minigame" in scope)
			{
				local minigame = scope.minigame
				
				local overlays = [], overlays2 = []
				if (minigame.custom_overlay == null)
					overlays = ["hud/tf2ware_ultimate/minigames/" + name]
				else
					overlays = Ware_GetOverlays(minigame.custom_overlay)
				
				if (minigame.custom_overlay2 != null)
					overlays2 = Ware_GetOverlays(minigame.custom_overlay2)			
				
				foreach (overlay in overlays)
				{
					if (overlay)
						PrecacheOverlay(overlay)
				}
				foreach (overlay in overlays2)
				{
					if (overlay)
						PrecacheOverlay(overlay)
				}
				
				Ware_AddAuthor(minigame.author)
			}
			else if ("special_round" in scope)
				Ware_AddAuthor(scope.special_round.author)
		}
		catch (e)
		{
			Ware_ErrorHandler(format("Failed to precache '%s.nut'. Missing from disk or syntax error", path))
		}
		
		return true
	}
	
	foreach (overlay in Ware_GameOverlays)
		yield PrecacheOverlay("hud/tf2ware_ultimate/" + overlay)	
	foreach (minigame in Ware_Minigames)
		yield PrecacheFile("minigames", minigame)
	foreach (bossgame in Ware_Bossgames)
		yield PrecacheFile("bossgames", bossgame)
	foreach (special in Ware_SpecialRounds)
		yield PrecacheFile("specialrounds", special)
		
	printf("[TF2Ware] Precached %d minigames, %d bossgames, %d special rounds\n", 
		Ware_Minigames.len(), Ware_Bossgames.len(), Ware_SpecialRounds.len())
	return null
}

function Ware_PrecacheStep()
{
	if (resume Ware_PrecacheGenerator)
		EntityEntFire(World, "CallScriptFunction", "Ware_PrecacheStep")
}

function Ware_PrecacheEverything()
{
	if (Ware_Precached)
		return
	Ware_Precached = true
	
	// the precaching can take so long that the script is terminated for taking too long
	// as a workaround, spread it out across I/O events
	// note: normally a co-routine would workaround that
	// but it seems to crash the VM here if using nested IncludeScript
	Ware_PrecacheGenerator = Ware_PrecacheNext()
	EntityEntFire(World, "CallScriptFunction", "Ware_PrecacheStep")
}

function Ware_AddAuthor(author)
{
	local add_author = function(author){
		foreach(k, v in Ware_Authors)
		{
			if (k == author)
			{
				Ware_Authors[author]++
				return
			}
		}
		Ware_Authors[author] <- 1
	}
	
	if (typeof(author) == "array")
		foreach(str in author)
			add_author(str)
	else
		add_author(author)
}

function Ware_SetupLocations()
{
	foreach (name, location in Ware_Location)
	{
		location.name <- name
		location.setdelegate(Ware_LocationParent)
		if ("Init" in location)
			location.Init()
			
		local cameras = []
		if ("cameras" in location)
		{
			foreach (camera_name in location.cameras)
			{
				local camera = FindByName(null, camera_name)
				if (camera)
					cameras.append(camera)
			}
		}

		location.cameras <- cameras
	}

	Ware_CheckHomeLocation(Ware_Players.len())
	Ware_MinigameLocation = Ware_MinigameHomeLocation
}

function Ware_SetTheme(requested_theme)
{
	Ware_Theme = {}
	
	local theme_found = false
	
	foreach(theme in Ware_Themes)
	{
		if (theme.theme_name == requested_theme)
		{
			Ware_Theme = theme
			theme_found = true
			break
		}
	}
	
	if (!theme_found)
	{
		Ware_Error("No theme named '%s' was found. Setting to default theme instead.", requested_theme)
		Ware_Theme = Ware_Themes[0]
	}
	
	Ware_SetupThemeSounds()
}

function Ware_SetupThemeSounds()
{
	Ware_CurrentThemeSounds = {}
	
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

function Ware_ParseLoadout(player)
{
	local data = player.GetScriptScope().ware_data
	
	local special_melee = data.special_melee
	if (special_melee && special_melee.IsValid())
	{
		// shouldn't happen, if it does, this logic needs rewriting
		if (data.melee_index == null)
		{
			Ware_Error("Failed to find special melee slot for %s", GetPlayerName(player))
			return null					
		}
		
		if (!Ware_AllowLoadouts)
		{
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
		else if (!Ware_AllowLoadouts)
		{
			SetPropEntityArray(player, "m_hMyWeapons", null, i)
			KillWeapon(weapon)
		}
		else
		{
			// prevent thriller taunt
			weapon.AddAttribute("special taunt", 1, -1)
		}
	}
	
	if (last_melee != null && last_melee != melee && last_melee.IsValid())
		last_melee.Destroy()
		
	return melee
}

function Ware_ModifyMeleeAttributes(melee)
{
	// prevent thriller taunt
	melee.AddAttribute("special taunt", 1, -1)
	
	local id = GetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
	if (id in Ware_MeleeAttributeOverrides)
	{
		local attributes = Ware_MeleeAttributeOverrides[id]
		foreach (name, value in attributes)
			melee.AddAttribute(name, value, -1)
	}
}

function Ware_FixupPlayerWeaponSwitch()
{
	if (activator)
		self.Weapon_Switch(activator)
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

function Ware_ShowPassEffects(player)
{
	player.EmitSound(SFX_WARE_PASS)
	Ware_SpawnParticle(player, player.GetTeam() == TF_TEAM_RED ? PFX_WARE_PASS_RED : PFX_WARE_PASS_BLUE)
}

function Ware_PlayStartSound()
{
	if (ware_data.start_sound)
		return
	
	ware_data.start_sound = true
	 
	if (IsInWaitingForPlayers())
		Ware_PlayGameSound(self, "lets_get_started")
}

function Ware_CheckHomeLocation(player_count)
{
	local old_location = Ware_MinigameHomeLocation
	local new_location = Ware_Location[player_count > 12 ? "home_big" : "home"]
	Ware_MinigameHomeLocation = new_location
	
	if (new_location != old_location)
	{
		if (old_location)
		{
			foreach (camera in old_location.cameras)
				EntityAcceptInput(camera, "Disable")		
			foreach (spawn in old_location.spawns)
				SetPropBool(spawn, "m_bDisabled", true)
		}

		foreach (camera in new_location.cameras)
			EntityAcceptInput(camera, "Enable")		
		foreach (spawn in new_location.spawns)
			SetPropBool(spawn, "m_bDisabled", false)
	}
}

function Ware_GetOverlays(overlays) 
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
	
function Ware_IsSpecialRoundValid(str)
{
	foreach(round in Ware_SpecialRounds)
	{
		if (round == str)
			return true
	}
	
	return false
}

function Ware_ShowSpecialRoundText(players)
{
	local holdtime = 3.0 
	local text = Ware_SpecialRound ? ("\n\n\n Special Round!\n " + Ware_SpecialRound.name) : ""
	if (Ware_SpecialRound && Ware_SpecialRound.reverse_text)
		text = "Special Round!\n" + Ware_SpecialRound.name + "\n\n\n"
	Ware_ShowText(players, CHANNEL_SPECIALROUND, text, holdtime + 0.2, "255 175 0", 0.0, 0.0)
	return holdtime // refresh every few seconds
}

function Ware_SetupSpecialRoundCallbacks()
{
	local special_round = Ware_SpecialRound
	local scope = Ware_SpecialRoundScope
	
	special_round.cb_get_minigame            = Ware_Callback(scope, "GetMinigameName")
	special_round.cb_get_overlay2            = Ware_Callback(scope, "GetOverlay2")
	special_round.cb_get_player_roll         = Ware_Callback(scope, "GetPlayerRollAngle")
	special_round.cb_get_valid_players       = Ware_Callback(scope, "GetValidPlayers")
	special_round.cb_on_calculate_score      = Ware_Callback(scope, "OnCalculateScore")
	special_round.cb_on_calculate_topscorers = Ware_Callback(scope, "OnCalculateTopScorers")
	special_round.cb_on_declare_winners      = Ware_Callback(scope, "OnDeclareWinners")
	special_round.cb_on_player_connect       = Ware_Callback(scope, "OnPlayerConnect")
	special_round.cb_on_player_disconnect    = Ware_Callback(scope, "OnPlayerDisconnect")
	special_round.cb_on_player_spawn         = Ware_Callback(scope, "OnPlayerSpawn")
	special_round.cb_on_player_inventory     = Ware_Callback(scope, "OnPlayerInventory")
	special_round.cb_on_begin_intermission   = Ware_Callback(scope, "OnBeginIntermission")
	special_round.cb_on_minigame_start       = Ware_Callback(scope, "OnMinigameStart")
	special_round.cb_on_minigame_end         = Ware_Callback(scope, "OnMinigameEnd")
	special_round.cb_on_speedup              = Ware_Callback(scope, "OnSpeedup")
	special_round.cb_on_take_damage          = Ware_Callback(scope, "OnTakeDamage")
	special_round.cb_on_update               = Ware_Callback(scope, "OnUpdate")
}

function Ware_BeginSpecialRoundInternal()
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
	
	foreach (player in Ware_Players)
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/special_round")
	
	local start_time = Time()
	local duration = Ware_GetThemeSoundDuration("special_round") * 0.99 // finish slightly faster to set special round before intermission begins
	local reveal_time = duration * 0.6
	local end_time = duration - reveal_time
	local text_interval = 0.15
	// TODO: show special rounds a better way
	// maybe just put something behind it?
	local special_round = Ware_SpecialRoundScope.special_round
		
	CreateTimer(function() 
	{	
		Ware_ShowText(Ware_Players, CHANNEL_SPECIALROUND, RandomElement(Ware_FakeSpecialRounds).toupper(), text_interval * 2.0)
		
		if (Time() - start_time > reveal_time)
		{
			Ware_ShowText(Ware_Players, CHANNEL_SPECIALROUND, special_round.name.toupper(), end_time)
			
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
				
				CreateTimer(@() Ware_ShowSpecialRoundText(Ware_Players), 0.0)
				
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

function Ware_EndSpecialRoundInternal()
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
	
	foreach(player in Ware_Players)
	{
		local scope = player.GetScriptScope()
		scope.ware_specialdata.clear()
	}
	
	Ware_SpecialRound = null
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

function Ware_BeginIntermissionInternal(is_boss)
{
	if (Ware_DebugStop)
	{
		// message
		Ware_ShowText(Ware_Players, CHANNEL_MISC, "TF2Ware Ultimate is paused...", 1.1)
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
		Ware_PlayGameSound(null, "intro")
		foreach (player in Ware_Players)
		{
			Ware_ShowScreenOverlay(player, null)
			Ware_ShowScreenOverlay2(player, null)
		}
		
		CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
	}
}

function Ware_SetTimeScaleInternal(timescale)
{
	if (Ware_Plugin)
		Ware_SourcemodRoutine("timescale", { value = timescale })
	else
		SendToConsole(format("host_timescale %g", timescale))
	
	Ware_TimeScale = timescale
	
	foreach (player in Ware_MinigamePlayers)
		player.AddCustomAttribute("voice pitch scale", Ware_GetPitchFactor(), -1)
}

function Ware_BeginBossInternal()
{
	Ware_SetTimeScale(1.0)
	
	Ware_PlayGameSound(null, "boss")
	foreach (player in Ware_Players)
	{
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/default_boss")
		Ware_ShowScreenOverlay2(player, null)
	}
	
	CreateTimer(@() Ware_BeginIntermission(true), Ware_GetThemeSoundDuration("boss"))
}

function Ware_SpeedupInternal()
{
	if (Ware_SpecialRound && Ware_SpecialRound.cb_on_speedup.IsValid())
	{
		Ware_SpecialRound.cb_on_speedup()
	}
	else
	{
		Ware_SetTimeScale(Ware_TimeScale + Ware_SpeedUpInterval)
		
		Ware_PlayGameSound(null, "speedup")
		foreach (player in Ware_Players)
		{
			Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/default_speed")
			Ware_ShowScreenOverlay2(player, null)
		}
		
		CreateTimer(@() Ware_BeginIntermission(false), Ware_GetThemeSoundDuration("speedup"))
	}
}

function Ware_StartMinigameInternal(is_boss)
{	
	local valid_players = Ware_GetValidPlayers()
	local player_count = valid_players.len()
	
	local success = false
	local try_debug = true
	local prev_is_boss = is_boss
	local attempts = 0
	local minigame

	// TODO move this whole rolling to its own function for cleanness
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
			
			if (Ware_SpecialRound && Ware_SpecialRound.cb_get_minigame.IsValid())
			{
				minigame = Ware_SpecialRound.cb_get_minigame(is_boss)
			}
			else
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
	
	// small optimization
	local minigame_players = Ware_MinigamePlayers
	local minigame_playersdata = Ware_MinigamePlayersData
	
	minigame_players.clear()
	minigame_playersdata.clear()
	
	foreach (player in valid_players)
	{
		if (enable_collisions)
			player.SetCollisionGroup(COLLISION_GROUP_PLAYER)
		if (Ware_Minigame.thirdperson)
			player.SetForcedTauntCam(1)
		
		local max_scale = Ware_Minigame.max_scale
		if (max_scale && player.GetModelScale() > max_scale)
			Ware_SetPlayerScale(player, max_scale, 0.0, true)
		player.RemoveCond(TF_COND_TAUNTING)

		local scope = player.GetScriptScope()
		local data = scope.ware_data
		scope.ware_minidata.clear()
		data.passed = Ware_Minigame.start_pass
		data.passed_effects = false
		data.mission = 0
		data.suicided = false
				
		minigame_players.append(player)
		minigame_playersdata.append(data)
	}
	
	local location
	if (player_count > 12 && ((Ware_Minigame.location + "_big") in Ware_Location))
		location = Ware_Location[Ware_Minigame.location + "_big"]
	else
		location = Ware_Location[Ware_Minigame.location]
		
	if (Ware_Minigame.start_freeze)
	{
		foreach (player in valid_players)
			player.AddFlag(FL_FROZEN)
		
		Ware_CreateTimer(function() 
		{
			foreach (player in Ware_MinigamePlayers) 
				player.RemoveFlag(FL_FROZEN)
		}, 0.3)
	}
	
	local custom_teleport = "OnTeleport" in Ware_MinigameScope
	if (location != Ware_MinigameLocation)
	{
		foreach (camera in Ware_MinigameLocation.cameras)
			EntityAcceptInput(camera, "Disable")		
		foreach (camera in location.cameras)
			EntityAcceptInput(camera, "Enable")
		
		Ware_MinigameLocation = location
		if (!custom_teleport)
			location.Teleport(clone(valid_players))
	}
	
	Ware_SetupMinigameCallbacks()	
	
	// late precache if new minigames are added at runtime
	if (developer() > 0 && "OnPrecache" in Ware_MinigameScope)
		Ware_MinigameScope.OnPrecache()
	
	if (custom_teleport)
		Ware_MinigameScope.OnTeleport(clone(valid_players))
		
	Ware_UpdateGlobalMaterialState()
	
	if (Ware_Minigame.allow_damage)
		Ware_ToggleTruce(false)
		
	// bit hacky but does the job
	Ware_BlockPassEffects = Ware_SpecialRound && Ware_SpecialRound.opposite_win
	if ("OnStart" in Ware_MinigameScope)
		Ware_MinigameScope.OnStart()	
	Ware_BlockPassEffects = false

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
	
	local overlays = [], overlays2 = []
	if (Ware_Minigame.custom_overlay == null)
		overlays = ["hud/tf2ware_ultimate/minigames/" + minigame]
	else
		overlays = Ware_GetOverlays(Ware_Minigame.custom_overlay)
	
	if (Ware_Minigame.custom_overlay2 != null)
	{
		overlays2 = Ware_GetOverlays(Ware_Minigame.custom_overlay2)
		Ware_MinigameOverlay2Set = true
	}

	local overlay_len = overlays.len()
	local overlay2_len = overlays2.len()
	foreach (data in minigame_playersdata)
	{	
		local mission = data.mission
		if (mission < overlay_len)
			Ware_ShowScreenOverlay(data.player, overlays[mission])
		if (mission < overlay2_len)
			Ware_ShowScreenOverlay2(data.player, overlays2[mission])
	}
	
	Ware_PlayMinigameMusic(null, Ware_Minigame.music)
	
	if (Ware_SpecialRound)
		Ware_SpecialRound.cb_on_minigame_start()
	
	Ware_MinigamePreEndTimer = CreateTimer(function() 
	{ 
		Ware_MinigameEnded = true
		if ("OnEnd" in Ware_MinigameScope) 
			Ware_MinigameScope.OnEnd()
			
		local pass_flag = !(Ware_SpecialRound && Ware_SpecialRound.opposite_win)
			
		if (Ware_Minigame.start_pass || pass_flag == false)
		{
			foreach (data in minigame_playersdata)
			{
				if (data.passed == pass_flag && !data.passed_effects)
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
		@() Ware_FinishMinigameInternal(), 
		Ware_Minigame.duration + Ware_Minigame.end_delay
	)
	
	Ware_CriticalZone = false
}

function Ware_EndMinigameInternal()
{
	if (Ware_MinigameEnded)
		return
		
	FireTimer(Ware_MinigamePreEndTimer)
	KillTimer(Ware_MinigameEndTimer)
	
	Ware_MinigameEndTimer = CreateTimer(
		@() Ware_FinishMinigameInternal(),
		Ware_Minigame.end_delay
	)
}

function Ware_FinishMinigameInternal()
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
	
	local restore_collisions = Ware_Minigame.collisions && (!Ware_SpecialRound || !Ware_SpecialRound.force_collisions)
	
	local player_count = 0
	local respawn_players = []
	foreach (player in Ware_Players)
	{
		if (!(player.GetTeam() & 2))
			continue
			
		player.RemoveFlag(FL_FROZEN)
		player.RemoveAllObjects(false)
		player.SetGrapplingHookTarget(null, false)

		if (restore_collisions)
			player.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		if (Ware_Minigame.thirdperson)
			player.SetForcedTauntCam(0)
		foreach (condition in Ware_Minigame.conditions)
			player.RemoveCond(condition)
			
		local data = player.GetScriptScope().ware_data
		if (data.saved_team != null)
		{
			Ware_SetPlayerTeamInternal(player, data.saved_team)
			data.saved_team = null
		}
		
		if (data.saved_scale != null)
		{
			player.SetModelScale(data.saved_scale, 0.0)
			data.saved_scale = null
		}
			
		if (player.IsAlive())
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
			
			foreach (attribute, value in data.attributes)
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
		foreach (camera in Ware_MinigameLocation.cameras)
			EntityAcceptInput(camera, "Disable")	
		foreach (camera in Ware_MinigameHomeLocation.cameras)
			EntityAcceptInput(camera, "Enable")
		
		Ware_MinigameHomeLocation.Teleport(Ware_MinigamePlayers)
		Ware_MinigameLocation = Ware_MinigameHomeLocation
	}
	
	if (Ware_Minigame.allow_damage)
		Ware_ToggleTruce(true)
		
	Ware_PlayMinigameMusic(null, Ware_Minigame.music, SND_STOP)

	local all_passed = true
	local all_failed = true
	
	local pass_flag = !(Ware_SpecialRound && Ware_SpecialRound.opposite_win)
	
	local can_suicide = Ware_Minigame.allow_suicide
	foreach (data in Ware_MinigamePlayersData)
	{
		if (!data.passed == pass_flag && data.suicided && !can_suicide)
		{
			data.passed = !pass_flag
			Ware_ChatPrint(data.player, "{color}You were not given points for suiciding.", TF_COLOR_DEFAULT)
		}
		
		if (data.passed == pass_flag)
			all_failed = false
		else
			all_passed = false
	}
	
	foreach (data in Ware_MinigamePlayersData)
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
		else if (data.passed == pass_flag)
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
		
		if (Ware_SpecialRound && Ware_SpecialRound.cb_on_calculate_score.IsValid())
			Ware_SpecialRound.cb_on_calculate_score(data)
		else if (data.passed)
			data.score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
	}
	
	local top_players = Ware_MinigameTopScorers
	top_players.clear()	
	
	if (Ware_SpecialRound && Ware_SpecialRound.cb_on_calculate_topscorers.IsValid())
	{
		Ware_SpecialRound.cb_on_calculate_topscorers(top_players)
	}
	else
	{
		local top_score = 1
		foreach (data in Ware_MinigamePlayersData)
		{
			if (data.score > top_score)
			{
				top_score = data.score
				top_players.clear()
				top_players.append(data.player)
			}
			else if (data.score == top_score)
			{
				top_players.append(data.player)
			}	
		}
	}
	
	CreateTimer(function()
	{
		foreach (player in top_players)
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

function Ware_GameOverInternal()
{
	Ware_CriticalZone = true
	Ware_Finished = true
	Ware_RoundsPlayed++
	
	local top_players = Ware_MinigameTopScorers
	top_players = top_players.filter(@(i, player) player.IsValid())
	
	local top_score = 0
	local winner_count = top_players.len()
	
	if (winner_count > 0)
		top_score = top_players[0].GetScriptScope().ware_data.score
	
	local delay = GetConvarValue("mp_bonusroundtime").tofloat()
	Ware_ToggleTruce(false)
	
	local winners = Ware_PlayersData.filter(@(i, data) top_players.find(data.player) != null)
	local losers = Ware_PlayersData.filter(@(i, data) top_players.find(data.player) == null)
	
	foreach (data in losers)
	{
		local player = data.player
		Ware_PlayGameSound(player, "gameover")
		player.SetScriptOverlayMaterial("hud/tf2ware_ultimate/default_failure")
		player.StunPlayer(delay, 0.5, TF_STUN_LOSER_STATE|TF_STUN_NO_EFFECTS, null)
	}
	
	Ware_TogglePlayerLoadouts(true)
	foreach (data in winners)
	{
		local player = data.player
		player.Regenerate(true)
		player.AddCondEx(TF_COND_CRITBOOSTED, delay, null)
		Ware_PlayGameSound(player, "gameclear")
		player.SetScriptOverlayMaterial("hud/tf2ware_ultimate/default_victory")
		// TODO: don't allow damage to other winners
		// Note: This has been done in OnTakeDamage in events.nut, needs some testing
		
		// TODO: Allow class changing for winners
		
		// TODO: Fix some weapons being weird in gameover (flamethrower doesn't damage, frontier justice removes crits, etc. Needs more testing)	
	}
	Ware_TogglePlayerLoadouts(false)
	
	Ware_RoundEndMusicTimer <- CreateTimer(function() 
	{
		Ware_PlayGameSound(null, "results")
	}, 5.0)
	
	// TODO: add firework effects

	local win = SpawnEntityFromTableSafe("game_round_win", 
	{
		teamnum         = TEAM_UNASSIGNED
		force_map_reset = true
		switch_teams    = true
	})
	EntityAcceptInput(win, "RoundWin")
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
	
	Ware_CriticalZone = false
	
	if (Ware_SpecialRound && Ware_SpecialRound.cb_on_declare_winners.IsValid())
	{
		Ware_SpecialRound.cb_on_declare_winners(top_players, top_score, winner_count)
	}
	else
	{
		if (winner_count > 1)
		{
			Ware_ChatPrint(null, "{color}The winners each with {int} points:", TF_COLOR_DEFAULT, top_score)
			foreach (player in top_players)
				Ware_ChatPrint(null, "> {player} {color}!", player, TF_COLOR_DEFAULT)
		}
		else if (winner_count == 1)
		{
			Ware_ChatPrint(null, "{player} {color}won with {int} points!", top_players[0], TF_COLOR_DEFAULT, top_score)
		}	
		else if (winner_count == 0)
		{
			Ware_ChatPrint(null, "{color}Nobody won!?", TF_COLOR_DEFAULT)
		}
	}
	

	// TODO: move this to start of next round if it's safe to do so
	// reason being it's more interesting to still have the special round's convars or what have you going on round end
	if (Ware_SpecialRound != null)
		Ware_EndSpecialRound()
}

function Ware_OnUpdate()
{
	if (Ware_SpecialRound)
		Ware_SpecialRound.cb_on_update()
		
	if (Ware_Minigame == null)
		return -1
		
	if (!Ware_MinigameEnded)
	{
		local ret = Ware_Minigame.cb_check_end()
		if (ret != null && ret == true)
			Ware_EndMinigame()
	}
	
	local time = Time()
	foreach (data in Ware_MinigamePlayersData)
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
		foreach (player in Ware_MinigamePlayers)
		{
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
				if (name.find("idleloop") == null && name.find("attack") == null)
					Ware_Minigame.cb_on_player_voiceline(player, name.tolower())
			}
		}
	}
	
	if (Ware_Minigame.cb_on_player_touch.IsValid())
	{
		local candidates = []
		local bloat_maxs = Vector(0.05, 0.05, 0.05)
		local bloat_mins = bloat_maxs * -1.0
		
		foreach (player in Ware_MinigamePlayers)
		{
			if (player.IsAlive())
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

function Ware_OnPlayerSay(player, text)
{
	if (player == null || text.len() == 0)
		return false

	if (startswith(text, "!ware_"))
	{
		local steamid3 = GetPlayerSteamID3(player)
		local len = text.find(" ")
		local cmd = len != null ? text.slice(6, len) : text.slice(6)
		if (steamid3 in DEVELOPER_STEAMID3 && cmd in Ware_DevCommands)
		{
			Ware_DevCommands[cmd](player, len != null ? text.slice(len+1) : "")
		}
		else if (cmd in Ware_PublicCommands)
		{
			Ware_PublicCommands[cmd](player, len != null ? text.slice(len+1) : "")
		}
		else if (cmd in Ware_DevCommands)
		{
			Ware_ChatPrint(player, "You do not have access to this command")
		}
		else
		{
			Ware_ChatPrint(player, "Unknown command '{str}'", cmd)
		}
		return false
	}
	
	if (Ware_Minigame != null)
		return Ware_Minigame.cb_on_player_say(player, text)
	else
		return true
}

if (Ware_Plugin)
{
	// hacky communication via entity between vscript and sourcemod
	function Ware_OnPlayerSayProxy()
	{
		local player = GetPropEntity(self, "m_hDamageFilter")
		local text = GetPropString(self, "m_szText")
		 // incase callback errors, allow message to pass
		SetPropInt(self, "m_iHammerID", 0)
		local ret = Ware_OnPlayerSay(player, text)
		SetPropInt(self, "m_iHammerID", ret == false ? 1 : 0)
	}
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

// API
IncludeScript("tf2ware_ultimate/api/audio",        ROOT)
IncludeScript("tf2ware_ultimate/api/game",         ROOT)
IncludeScript("tf2ware_ultimate/api/minigame",     ROOT)
IncludeScript("tf2ware_ultimate/api/misc",         ROOT)
IncludeScript("tf2ware_ultimate/api/player",       ROOT)
IncludeScript("tf2ware_ultimate/api/specialround", ROOT)

Ware_FindStandardEntities()
Ware_SetupLocations()
Ware_PrecacheEverything()