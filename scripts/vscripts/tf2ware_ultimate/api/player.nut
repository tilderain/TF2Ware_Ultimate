// by ficool2 and pokemonpasta

// Gamemode-specific data each player has
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

// Global variables
if (!("Ware_Players" in this)) // These variables never reset
{
	// List of all players in the server
	Ware_Players                  <- []
	// List of all players participating in the current minigame/bossgame
	Ware_MinigamePlayers          <- []
}

// Gets the gamemode data associated with a player
function Ware_GetPlayerData(player)
{
	return player.GetScriptScope().ware_data
}

// Gets the minigame data ("minidata") associated with a player
// Minidata is a table where a minigame can store it's own variables
// E.g. useful to keep track of scores per-player in a minigame
// The table is purged after a minigame is ended
function Ware_GetPlayerMiniData(player)
{
	return player.GetScriptScope().ware_minidata
}

// Marks a player as "passed" during a minigame
// This also plays the sound and particle effects
// This does nothing if the player is already passed
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

// Returns true if the player is considered "passed" during a minigame
function Ware_IsPlayerPassed(player)
{
	return player.GetScriptScope().ware_data.passed
}

// Sets the player's "mission"
// This should be an incremental number starting from 0
// Minigames can have different objectives for different players
// This can be used to assign players to the corresponding objective
// This will automatically choose the appropriate minigame overlay as well
// Internally, all player's begin on mission 0 by default
function Ware_SetPlayerMission(player, mission)
{
	return player.GetScriptScope().ware_data.mission = mission
}

// Returns the player's current "mission", see above
function Ware_GetPlayerMission(player)
{
	return player.GetScriptScope().ware_data.mission
}

// Sets a player loadout, i.e. their class and their items
// This removes all items/weapons they currently have, including their melee (unless "keep_melee" is true)
// Items is an optional item name, or array of item names to give to the player
// For a list of item names, see items.nut
// If items is null, the player is switched to their default melee
// Item attributes is a list of attributes to apply to the given item, or default melee
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

// Sets a loadout for all players
// See Ware_SetPlayerLoadout
function Ware_SetGlobalLoadout(player_class, items = null, item_attributes = {}, keep_melee = false)
{
	foreach (player in Ware_MinigamePlayers)
		Ware_SetPlayerLoadout(player, player_class, items, item_attributes, keep_melee)		
}

// Strips all items/weapons from a player
// If give_default_melee is true, their default melee is given back
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

// Gives a specified item/weapon to the player
// For a list of item names, see items.nut
// "attributes" is a table of attributes that will be applied on the weapon
// If "switch_weapon" is true, the player is automatically switched to the new weapon
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
		item_classname = SAXXY_CLASSNAME_MAP[player.GetPlayerClass()]
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

// Sets the player's class, and regenerates their health, ammo, melee etc
// If "switch_melee" is true, the player will be switched to their new melee
// Does nothing if the player is already the given class
local Ware_CheckTeleportEffectTimer // Ignore this
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
			foreach (player in Ware_MinigamePlayers)
			{
				if (Ware_MinigameHighScorers.find(player) != null)
					player.AddCond(TF_COND_TELEPORTED)
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

// Sets the player's team
// Their current team is saved and reverted when a minigame ends
function Ware_SetPlayerTeam(player, team)
{
	local old_team = player.GetTeam()
	local data = player.GetScriptScope().ware_data
	if (data.saved_team == null)
		data.saved_team = old_team
	Ware_SetPlayerTeamInternal(player, team)
}

// Toggles the visibility of all wearables (including weapons!) on a player
function Ware_TogglePlayerWearables(player, toggle)
{
	for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
	{
		MarkForPurge(wearable)
		Ware_ToggleWearable(wearable, toggle)
	}
}

// Gets a list of alive players on the given team
function Ware_GetAlivePlayers(team = TEAM_UNASSIGNED)
{
	if (team & 2)
		return Ware_MinigamePlayers.filter(@(i, player) player.GetTeam() == team && IsEntityAlive(player))
	else
		return Ware_MinigamePlayers.filter(@(i, player) IsEntityAlive(player))
}

// Gets a list of alive players that are on red or blue team
// Internally this decides what players will be placed into a minigame
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

// Gets a list of players in a minigame sorted by their score
function Ware_GetSortedScorePlayers(reverse)
{
	local players = clone(Ware_MinigamePlayersData)
	if (reverse)
		players.sort(@(a, b) b.score <=> a.score)
	else
		players.sort(@(a, b) a.score <=> b.score)		
	players = players.map(@(data) data.player)
	return players
}

// Adds an attribute to the player
// Given attributes are removed automatically when the minigame ends
function Ware_AddPlayerAttribute(player, name, value, duration)
{
	player.AddCustomAttribute(name, value, duration)
	return player.GetScriptScope().ware_data.attributes.append(name)
}

// Adds an attribute to all players
// See Ware_AddPlayerAttribute
function Ware_SetGlobalAttribute(name, value, duration)
{
	foreach (player in Ware_MinigamePlayers)
		Ware_AddPlayerAttribute(player, name, value, duration)
}

// Sets a condition to all players
// This is removed automatically when a minigame ends
function Ware_SetGlobalCondition(condition)
{
	foreach (player in Ware_MinigamePlayers)
		player.AddCond(condition)
	if (Ware_Minigame.conditions.find(condition) == null)
		Ware_Minigame.conditions.append(condition)
}

// Forces a player to commit suicide (as if they kill binded)
function Ware_SuicidePlayer(player)
{
	player.TakeDamageCustom(player, player, null, Vector(), Vector(), 99999.0, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_SUICIDE)
}

// Force all players that haven't passed the minigame to suicide
function Ware_SuicideFailedPlayers()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (IsEntityAlive(player) && !Ware_IsPlayerPassed(player))
			Ware_SuicidePlayer(player)
	}
}

// Damage all players in a radius
// The damage will have linear falloff
function Ware_RadiusDamagePlayers(origin, radius, damage, attacker)
{
	foreach (player in Ware_MinigamePlayers)
	{
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

// Teleports a player to the given origin, angles and/or velocity
// The 3 parameters are optional and can be set to null to not change that property
// Special rounds may override the roll (z) angle
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

// Gets the player's height above the minigame location
// This will only work if the location has a "center" Vector variable defined
function Ware_GetPlayerHeight(player)
{
	return player.GetOrigin().z - Ware_MinigameLocation.center.z
}

// Disables primary fire for the player's current weapon, for the given duration
function Ware_DisablePlayerPrimaryFire(player, duration = 0.2)
{
	local weapon = player.GetActiveWeapon()
	if (weapon != null)
		SetPropFloat(weapon, "m_flNextPrimaryAttack", Time() + duration)
}

// Gets the player's reserve ammo
function Ware_GetPlayerAmmo(player, ammo_type)
{
	return GetPropIntArray(player, "m_iAmmo", ammo_type)
}

// Sets the player's reserve ammo
function Ware_SetPlayerAmmo(player, ammo_type, ammo)
{
	SetPropIntArray(player, "m_iAmmo", ammo, ammo_type)
}

// Ungrounds a player, allowing them to be knocked back more easily
function Ware_UngroundPlayer(player)
{
	SetPropEntity(player, "m_hGroundEntity", null)
	player.RemoveFlag(FL_ONGROUND)
}

// Pushes a player towards the direction they are looking
// Adds extra vertical velocity
function Ware_PushPlayer(player, scale)
{
	Ware_UngroundPlayer(player)
	
	local dir = player.EyeAngles().Forward()
	dir.x *= scale
	dir.y *= scale
	dir.z *= scale * 2.0
	player.SetAbsVelocity(player.GetAbsVelocity() + dir)
}

// Pushes a player away from another player
// Adds extra vertical velocity
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

// Shows text on the screen, with the same properties as the game_text entity
// The text will only display as long as the minigame itself
// Text can be reversed by a special round
// If "player" is null, the text is displayed to all players participating in the minigame
function Ware_ShowMinigameText(player, text, color = "255 255 255", x = -1.0, y = 0.3)
{
	if (player == null)
		Ware_ShowText(Ware_MinigamePlayers, CHANNEL_MINIGAME, text, Ware_GetMinigameRemainingTime(), color, x, y)
	else
		Ware_ShowText(player, CHANNEL_MINIGAME, text, Ware_GetMinigameRemainingTime(), color, x, y)
}

// Shows the primary overlay texture on a player
// If name is null, it removes the overlay
function Ware_ShowScreenOverlay(player, name)
{
	player.SetScriptOverlayMaterial(name ? name : "")
}

// Shows the secondary overlay texture on a player
// This will also hide the name indicator for players when they are under the crosshair
// (As it shows up in front of the overlay)
// If name is null, it removes the overlay, unless a special round wants to use another it's own
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

// Shows a primary overlay texture for everyone
// See Ware_ShowScreenOverlay
function Ware_ShowGlobalScreenOverlay(name)
{
	foreach (player in Ware_MinigamePlayers)
		Ware_ShowScreenOverlay(player, name)
}

// Shows a secondary overlay texture for everyone
// See Ware_ShowScreenOverlay2
function Ware_ShowGlobalScreenOverlay2(name)
{
	foreach (player in Ware_MinigamePlayers)
		Ware_ShowScreenOverlay2(player, name)
}

// Runs a client command on the given player
// If player is null, the command is ran on all playeers
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