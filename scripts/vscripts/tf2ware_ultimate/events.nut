
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
	if (!endswith(GetMapName(), WARE_MAPVERSION))
	{
		local map_version = GetMapName().slice(17)
		Ware_Error("Map version does not match script version. Some minigames may not function correctly due to missing geometry.\nMap Version: %s\nScript Version: %s",
		map_version,
		WARE_MAPVERSION)
	}
	
	Ware_SetTimeScale(1.0)
	
	Ware_ShowSpecialRoundText(Ware_Players) // clear it out
	
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
	
	Ware_ChatPrint(null, "Theme: {color}{str}", COLOR_LIME, Ware_Theme.visual_name)
	
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
		
		foreach (data in Ware_MinigamePlayersData)
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
		
		Ware_PlayMinigameMusic(null, Ware_Minigame.music, SND_STOP)
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
	local idx = Ware_MinigamePlayers.find(player)
	if (idx != null)
		Ware_MinigamePlayers.remove(idx)
		
	idx = Ware_MinigamePlayersData.find(data)
	if (idx != null)
		Ware_MinigamePlayersData.remove(idx)
		
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