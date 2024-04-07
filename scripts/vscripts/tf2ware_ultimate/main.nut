printl("\tTF2Ware Started");

SetConvarValue("sv_gravity", 800.00006); // hide the sv_tags message
SetConvarValue("mp_friendlyfire", 1);
SetConvarValue("mp_respawnwavetime", 99999);
SetConvarValue("mp_scrambleteams_auto", 0);
SetConvarValue("mp_waitingforplayers_time", 60);
SetConvarValue("mp_teams_unbalance_limit", 1);
SetConvarValue("mp_autoteambalance", 1);
SetConvarValue("sv_turbophysics", 0);
SetConvarValue("tf_dropped_weapon_lifetime", 0);
SetConvarValue("tf_weapon_criticals", 0);
SetConvarValue("tf_spawn_glows_duration", 0);
SetConvarValue("tf_player_movement_restart_freeze", 0);
// TODO: need to block cheat commands
SendToConsole("sv_cheats 1");

class Ware_MinigameCallback
{
	function constructor(name)
	{
		if (name in Ware_MinigameScope)
			func = Ware_MinigameScope[name];
	}
	
	function _call(...)
	{
		if (func != null)
		{
			vargv.remove(0);
			vargv.insert(0, Ware_MinigameScope);
			return func.acall(vargv);
		}
		return null;
	}

	func = null;
};

class Ware_MinigameData
{
	function constructor()
	{
		location       = "home";
		min_players    = 0;
		start_pass     = false;
		allow_damage   = false;
		fail_on_death  = false;
		suicide_on_end = false;
		no_collisions  = false;
		friendly_fire  = true;
		thirdperson    = false;
		end_below_min  = false;
		end_dead_team  = false;
		end_delay      = 0.0;
		convars        = [];
		entities       = [];
		cleanup_names  = {};
		timers		   = [];
	}
	
	// Mandatory parameters
	// Internal name
	name			= null;
	// Description shown to people
	// Also only shown to players on 1st mission
	description		= null;
	// Only shown to players on 2nd mission
	description2	= null;
	// Length before ending
	duration		= null;
	// Music to play
	music			= null;
	
	// Optional parameters
	// Map location to teleport to (Ware_Location enum), default is home
	location		= null;
	// Minimum amount of players needed to start, default is 0
	min_players		= null;
	// Whether players will be flagged as passed when minigame starts, default is false
	start_pass		= null;
	// Is damage to other players allowed? Default is false
	allow_damage	= null;
	// Whether players should be automatically failed when they die, default is false
	fail_on_death	= null;
	// Whether players should suicide if they haven't passed when minigame ends, default is false
	suicide_on_end	= null;
	// Disables collisions between players, default is false
	no_collisions	= null;
	// Toggle friendlyfire, default is true
	friendly_fire	= null;
	// Force players into thirdperson? Default is false
	thirdperson	    = null;
	// Automatically end the minigame early if number of players alive is less than min_players, default is false
	end_below_min	= null;
	// Automatically end the minigame early if either team has no alive players, default is false
	end_dead_team	= null;
	// Delay after the minigame "ends" before showing results, default is 0.0
	end_delay		= null;
	// Custom text overlay to show rather than the default implied from name
	// Also only shown to players on 1st mission
	custom_overlay	= null;
	// Secondary custom text overlay to show 
	// Also only shown to players on 2nd mission
	custom_overlay2	= null;
	// Table of convars to set for this minigame
	// Reverted to previous values after minigame ends
	convars			= null;
	
	// Internal use only
	// Entities spawned by the minigame, to remove after it ends
	entities		= null;
	// Entity names to delete after minigame ends (e.g. projectiles)
	cleanup_names	= null;
	// Timers spawned by the minigame, stopped after it ends
	timers			= null;
	
	cb_on_take_damage		= null;
	cb_on_player_attack		= null;
	cb_on_player_death		= null;
	cb_on_player_say		= null;
	cb_on_player_voiceline	= null;
	cb_on_player_touch		= null;
	cb_on_update			= null;
};

class Ware_PlayerData
{
	function constructor(entity)
	{
		player           = entity;
		scope            = entity.GetScriptScope();
		team             = entity.GetTeam();
		passed           = false;
		passed_effects   = false;
		mission          = 0;
		attributes       = [];
		melee_attributes = [];
		start_sound      = false;
	}
	
	player		     = null;
	scope		     = null;
	team		     = null;
	passed		     = null;
	passed_effects   = null;
	mission		     = null;
	melee		     = null;
	melee_index      = null;
	attributes	     = null;
	melee_attributes = null;
	start_sound      = null;
	construction_pda = null;
};

if ("Ware_Minigame" in this && Ware_Minigame) // when restarted mid-minigame
{
	foreach (name, value in Ware_MinigameSavedConvars)
		SetConvarValue(name, value);
	Ware_MinigameSavedConvars.clear();
	
	Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_STOP);
}

Ware_Started			  <- false;
Ware_TimeScale			  <- 1.0;

if (!("Ware_DebugStop" in this))
{
	Ware_DebugStop            <- false;
	Ware_DebugForceMinigame   <- "";
}

Ware_TextManagerQueue     <- null;
Ware_TextManager          <- null;

Ware_ParticleSpawnerQueue <- [];
Ware_ParticleSpawner      <- null;

Ware_MinigameRotation     <- [];
Ware_Minigame             <- null;
Ware_MinigameScope        <- {};
Ware_MinigameSavedConvars <- {};
Ware_MinigameHomeLocation <- null;
Ware_MinigameLocation     <- null;
Ware_MinigameEvents       <- [];
Ware_MinigameOverlay2Set  <- false;
Ware_MinigameStartTime    <- 0.0;
Ware_MinigamePreEndTimer  <- null;
Ware_MinigameEndTimer     <- null;
Ware_MinigameEnded        <- false;
Ware_MinigamesPlayed	  <- 0;

if (!("Ware_Players" in this))
{
	Ware_Players         <- [];
	Ware_MinigamePlayers <- [];
	
	// this shuts up incursion distance warnings from the nav mesh
	CreateEntitySafe("base_boss").KeyValueFromString("classname", "point_commentary_viewpoint");
}

function Ware_FindStandardEntities()
{
	World     <- FindByClassname(null, "worldspawn");
	GameRules <- FindByClassname(null, "tf_gamerules");
	WaterLOD  <- FindByClassname(null, "water_lod_control");
	ClientCmd <- CreateEntitySafe("point_clientcommand");
	
	MarkForPurge(WaterLOD);
	
	// avoid adding the think again to not break global execution order
	if (World.GetScriptThinkFunc() != "Ware_OnUpdate")
		AddThinkToEnt(World, "Ware_OnUpdate");
	
	Ware_TextManagerQueue <- [];
	Ware_TextManager = SpawnEntityFromTableSafe("game_text",
	{
		message = "",
		x = -1,
		y = 0.3,
		effect = 0,
		color = "255 255 255",
		fadein = 0.0,
		fadeout = 0.0,
		holdtime = 0.0,
		fxtime = 0.0,
		channel = 3
	});
	Ware_TextManager.ValidateScriptScope();
	Ware_TextManager.GetScriptScope().InputDisplay <- Ware_TextHook;
	Ware_TextManager.GetScriptScope().inputdisplay <- Ware_TextHook;
	
	Ware_ParticleSpawnerQueue <- [];
	Ware_ParticleSpawner <- CreateEntitySafe("trigger_particle");
	Ware_ParticleSpawner.KeyValueFromInt("spawnflags", 64);
	Ware_ParticleSpawner.ValidateScriptScope();
	Ware_ParticleSpawner.GetScriptScope().InputStartTouch <- Ware_ParticleHook;
	Ware_ParticleSpawner.GetScriptScope().Inputstarttouch <- Ware_ParticleHook;
}

function Ware_SetupLocations()
{
	foreach (name, location in Ware_Location)
	{
		location.name <- name;
		location.setdelegate(Ware_LocationParent);
		if ("Init" in location)
			location.Init();
	}

	Ware_CheckHomeLocation(Ware_Players.len());
	Ware_MinigameLocation = Ware_MinigameHomeLocation;
}

function Ware_SetTimeScale(timescale)
{
	SendToConsole(format("host_timescale %g", timescale));
	Ware_TimeScale = timescale;
	
	foreach (data in Ware_MinigamePlayers)
		data.player.AddCustomAttribute("voice pitch scale", Ware_GetPitchFactor(), -1);
}

function Ware_GetPitchFactor()
{
	return 1.0 + (Ware_TimeScale - 1.0) * 0.4;
}

function Ware_ChatPrint(target, fmt, ...) 
{
	local result = "\x07FFCC22[TF2Ware] ";
	local start = 0;
	local end = fmt.find("{");
	local i = 0;
	while (end != null) 
	{
		result += fmt.slice(start, end);
		start = end + 1;
		end = fmt.find("}", start);
		if (end == null)
			break;
		local word = fmt.slice(start, end);
		
		if (word == "player")
		{
			local player = vargv[i++];

			local team = player.GetTeam();
			if (team == TF_TEAM_RED)
				result += "\x07" + TF_COLOR_RED;
			else if (team == TF_TEAM_BLUE)	
				result += "\x07" + TF_COLOR_BLUE;
			else
				result += "\x07" + TF_COLOR_SPEC;
			result += GetPlayerName(player);
		}
		else if (word == "color")
		{
			result += "\x07" + vargv[i++];
		}
		else if (word == "int" || word == "float")
		{
			result += vargv[i++].tostring();
		}
		else if (word == "str")
		{
			result += vargv[i++];
		}
		else 
		{
			result += "{" + word + "}";
		}
		
		start = end + 1;
		end = fmt.find("{", start);
	}
	
	result += fmt.slice(start);
	
	ClientPrint(target, HUD_PRINTTALK, result);
}

function Ware_Format(...)
{
	vargv.insert(0, this);
	local str = format.acall(vargv);
	return str;
}

function Ware_CreateEntity(classname)
{
	local entity = CreateEntitySafe(classname);
	Ware_Minigame.entities.append(entity);
	return entity;
}

function Ware_SpawnEntity(classname, keyvalues)
{
	local entity = SpawnEntityFromTableSafe(classname, keyvalues);
	Ware_Minigame.entities.append(entity);
	return entity;
}

function Ware_SpawnWearable(player, model_name)
{
	local wearable = Ware_CreateEntity("tf_wearable");
	wearable.KeyValueFromString("classname", "ware_wearable");
	SetPropInt(wearable, "m_nModelIndex", PrecacheModel(model_name));
	SetPropBool(wearable, "m_bValidatedAttachedEntity", true);
	wearable.SetOwner(player);
	wearable.DispatchSpawn();
	return wearable;
}

function Ware_CreateTimer(on_timer_func, delay)
{
	local timer = CreateTimer(on_timer_func, delay);
	Ware_Minigame.timers.append(timer);
	return timer;	
}

function Ware_PlayGameSound(player, name, flags = 0)
{
	if (player)
		PlaySoundOnClient(player, format("tf2ware_ultimate/music_game/%s.mp3", name), 1.0, 100 * Ware_GetPitchFactor(), flags);
	else
		PlaySoundOnAllClients(format("tf2ware_ultimate/music_game/%s.mp3", name), 1.0, 100 * Ware_GetPitchFactor(), flags);
}

function Ware_PlayMinigameSound(player, name, flags = 0)
{
	if (player)
		PlaySoundOnClient(player, format("tf2ware_ultimate/music_minigame/%s.mp3", name), 1.0, 100 * Ware_GetPitchFactor(), flags);
	else
		PlaySoundOnAllClients(format("tf2ware_ultimate/music_minigame/%s.mp3", name), 1.0, 100 * Ware_GetPitchFactor(), flags);
}

function Ware_SetConvarValue(convar, value)
{
	Ware_Minigame.convars[convar] <- value;
	if (!(name in Ware_MinigameSavedConvars))
		Ware_MinigameSavedConvars[name] <- GetConvarValue(name);
	SetConvarValue(name, value);
}

function Ware_ShowScreenOverlay(player, name)
{
	player.SetScriptOverlayMaterial(name ? name : "");
}

function Ware_ShowScreenOverlay2(player, name)
{
	if (!name)
	{
		player.RemoveHudHideFlags(HIDEHUD_TARGET_ID);
		EntFireByHandle(ClientCmd, "Command", "r_screenoverlay off", -1. player, null);
	}
	else
	{
		player.AddHudHideFlags(HIDEHUD_TARGET_ID);
		EntFireByHandle(ClientCmd, "Command", format("r_screenoverlay %s", name), -1. player, null);
	}	
}

function Ware_ShowMinigameText(player, text)
{
	Ware_TextManagerQueue.push(
	{ 
		message = text, 
		color   = "255 255 255",
		// TODO: adjust holdtime depending on current minigame remaining time
	});	
	EntFireByHandle(Ware_TextManager, "Display", "", -1, player, null);
}

function Ware_ShowMinigameColorText(player, text, color)
{
	Ware_TextManagerQueue.push(
	{ 
		message = text, 
		color   = color,
		// TODO: adjust holdtime depending on current minigame remaining time
	});	
	EntFireByHandle(Ware_TextManager, "Display", "", -1, player, null);
}

function Ware_TextHook()
{
	local params = Ware_TextManagerQueue.remove(0);
	self.KeyValueFromString("message", params.message);
	self.KeyValueFromString("color", params.color);
	return true;
}

function Ware_SpawnParticle(entity, name, attach_name = "", attach_type = PATTACH_ABSORIGIN_FOLLOW)
{
	Ware_ParticleSpawnerQueue.push(
	{
		name = name, 
		attach_name = attach_name,
		attach_type = attach_type,
	});
	EntFireByHandle(Ware_ParticleSpawner, "StartTouch", "", -1, entity, entity);	
}

function Ware_ParticleHook()
{
	local data = Ware_ParticleSpawnerQueue.remove(0);
	SetPropString(self, "m_iszParticleName", data.name);
	SetPropString(self, "m_iszAttachmentName", data.attach_name);
	SetPropInt(self, "m_nAttachType", data.attach_type);
	return true;
}

function Ware_GetPlayerMiniData(player)
{
	return player.GetScriptScope().ware_minidata;
}

function Ware_PushPlayer(player, scale)
{
	local dir = player.EyeAngles().Forward();
	dir.x *= scale;
	dir.y *= scale;
	dir.z *= scale * 2.0;
	player.SetAbsVelocity(player.GetAbsVelocity() + dir);
}

function Ware_PushPlayerFromOther(player, other_player, scale)
{
	local dir = player.GetOrigin() - other_player.GetOrigin();
	dir.Norm();
	dir.x *= scale;
	dir.y *= scale;
	dir.z *= scale * 2.0;
	player.SetAbsVelocity(player.GetAbsVelocity() + dir);
}

function Ware_SlapEntity(entity, scale)
{
	local vel = entity.GetAbsVelocity();
	vel.x += RandomFloat(-1.0, 1.0) * scale;
	vel.y += RandomFloat(-1.0, 1.0) * scale;
	vel.z += scale * 2.0;
	entity.Teleport(false, Vector(), false, QAngle(), true, vel);
}

function Ware_GetMinigameTime()
{
	return Time() - Ware_MinigameStartTime;
}

function Ware_ParseLoadout(player)
{
	local melee, last_melee;
	for (local i = 0; i < MAX_WEAPONS; i++)
	{
		local weapon = GetPropEntityArray(player, "m_hMyWeapons", i);
		if (!weapon)
			continue;
			
		weapon.ValidateScriptScope();
		weapon.GetScriptScope().last_fire_time <- 0.0;
			
		MarkForPurge(weapon);
		if (weapon.GetSlot() == TF_SLOT_MELEE)
		{
			local data = player.GetScriptScope().ware_data;
			last_melee = data.melee;
			melee = weapon;
			data.melee = weapon;
			data.melee_index = i;
		}
		else
		{
			SetPropEntityArray(player, "m_hMyWeapons", null, i);
			KillWeapon(weapon);
		}
	}
	
	if (last_melee != null && last_melee != melee && last_melee.IsValid())
		last_melee.Kill();
	
	return melee;
}

function Ware_SetGlobalLoadout(player_class, items, item_attributes = {}, keep_melee = false)
{
	local is_list = typeof(items) == "array";
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		Ware_SetPlayerClass(player, player_class, false);
		
		if (items)
		{
			Ware_StripPlayer(player, keep_melee);
			
			if (is_list)
			{
				local last_item = items[items.len() - 1];
				foreach (item in items)
					Ware_GivePlayerWeapon(player, item, {}, item == last_item);
			}
			else
			{
				Ware_GivePlayerWeapon(player, items, item_attributes);
			}
		}
		else
		{
			player.RemoveCond(TF_COND_TAUNTING);
			
			local melee = data.melee;
			if (melee)
			{
				if (item_attributes.len() > 0)
				{
					foreach (attribute, value in item_attributes)
						melee.AddAttribute(attribute, value, -1.0);
					data.melee_attributes = clone(item_attributes);
				}
				
				player.Weapon_Switch(melee);
			}
		}
	}	
}

function Ware_StripPlayer(player, give_default_melee)
{
	player.RemoveCond(TF_COND_DISGUISING);
	player.RemoveCond(TF_COND_DISGUISED);
	player.RemoveCond(TF_COND_TAUNTING);
	player.RemoveCond(TF_COND_ZOOMED);
		
	local data = player.GetScriptScope().ware_data;
	local melee = data.melee;
	for (local i = 0; i < MAX_WEAPONS; i++)
	{
		local weapon = GetPropEntityArray(player, "m_hMyWeapons", i);
		if (weapon)
		{
			MarkForPurge(weapon);
			SetPropEntityArray(player, "m_hMyWeapons", null, i);
			if (weapon != melee)
				KillWeapon(weapon);
		}
	}
	
	Ware_DeferredPDAKill(data);
	
	if (give_default_melee)
	{
		if (melee != null && melee.IsValid())
		{
			SetPropEntityArray(player, "m_hMyWeapons", melee, data.melee_index);
			local active_weapon = player.GetActiveWeapon();
			if (active_weapon != melee)
			{
				if (active_weapon)
				{
					local classname = active_weapon.GetClassname();
					
					 // force switch fix
					if (classname == "tf_weapon_minigun")
						SetPropEntity(player, "m_hActiveWeapon", null);
					else if (startswith(classname, "tf_weapon_sniperrifle"))
						SetPropFloat(active_weapon, "m_flNextPrimaryAttack", 0.0);
				}
				player.Weapon_Switch(melee);
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
};

function Ware_GivePlayerWeapon(player, item_name, attributes = {}, switch_weapon = true)
{
	local item = ITEM_MAP[item_name];
	local item_id = item.id;
	local item_classname = item.classname;
	
	if (item_classname == "tf_weapon_shotgun") 
	{
		local player_class = player.GetPlayerClass();
		if (player_class == TF_CLASS_SOLDIER)
		{
			if (item_id == 9) item_id = 10;
			item_classname = "tf_weapon_shotgun_soldier";
		}
		else if (player_class == TF_CLASS_PYRO)
		{
			if (item_id == 9) item_id = 12;
			item_classname = "tf_weapon_shotgun_pyro";
		}	
		else if (player_class == TF_CLASS_HEAVYWEAPONS)
		{
			if (item_id == 9) item_id = 11;
			item_classname = "tf_weapon_shotgun_hwg";
		}	
		else /* if (player_class == TF_CLASS_ENGINEER)*/
		{
			if (item_id == 9) item_id = 9;
			item_classname = "tf_weapon_shotgun_primary";
		}			
	}
	else if (item_id == 22) // pistol
	{
		if (player.GetPlayerClass() == TF_CLASS_SCOUT)
			item_id = 23;
	}
	else if (item_classname == "saxxy")
	{
		item_classname = SaxxyToClassnameMap[player.GetPlayerClass()];
	}
	
	local weapon = CreateEntitySafe(item_classname);
	SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", item_id)
	SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true);
	SetPropBool(weapon, "m_bValidatedAttachedEntity", true);
	weapon.SetTeam(player.GetTeam());
	weapon.DispatchSpawn();	
	
	if (item_id == 28) // builder
	{
		for (local i = 0; i < 3; i++)
			SetPropIntArray(weapon, "m_aBuildableObjectTypes", 1, i);	
		SetPropInt(weapon, "m_iObjectType", 0);
		switch_weapon = false;
	}
	else if (item_id == 735 || item_classname == "tf_weapon_sapper") // sapper
	{
		SetPropIntArray(weapon, "m_aBuildableObjectTypes", 1, 3);	
		SetPropInt(weapon, "m_iObjectType", 3);
		SetPropInt(weapon, "m_iSubType", 3);
	}
	
	weapon.ValidateScriptScope();
	weapon.GetScriptScope().last_fire_time <- 0.0;
	
	// bit of a hack: penetration is required for friendlyfire to work
	if (startswith(item_classname, "tf_weapon_sniperrifle"))
		weapon.AddAttribute("projectile penetration", 1, -1);
	
	foreach (attribute, value in attributes)
		weapon.AddAttribute(attribute, value, -1.0);

	player.Weapon_Equip(weapon);
	if (switch_weapon)
	{
		if (item_id == 25 || item_id == 27) // construction pda
		{
			// build/disguise menu will not show up unless its holstered for a bit
			EntFireByHandle(player, "CallScriptFunction", "Ware_FixupPlayerWeaponSwitch", 0.1, weapon, weapon);
		}
		else
		{
			player.Weapon_Switch(weapon);
		}
	}
	
	if (Ware_Minigame != null)
	{
		if (item_id in ITEM_PROJECTILE_MAP)
		{
			local proj_classname = ITEM_PROJECTILE_MAP[item_id];
			if (!(proj_classname in Ware_Minigame.cleanup_names))
			{
				Ware_Minigame.cleanup_names[proj_classname] <- 1;
				Ware_Minigame.cleanup_names["ware_projectile"] <- 1;
			}
		}
	}
	
	return weapon;
}

function Ware_StripPlayerWeapons(player, weapons)
{
	for (local i = 0; i < MAX_WEAPONS; i++)
	{
		local weapon = GetPropEntityArray(player, "m_hMyWeapons", i);
		if (weapon)
		{
			local classname = weapon.GetClassname();
			if (weapons.find(classname) != null)	
			{
				SetPropEntityArray(player, "m_hMyWeapons", null, i);
				
				// see Ware_DeferredPDAKill for why this is needed
				if (classname == "tf_weapon_pda_engineer_build")
				{
					local data = player.GetScriptScope().ware_data;
					Ware_DeferredPDAKill(data);
					data.construction_pda = weapon;
					SetPropInt(weapon, "m_iObjectType", 0xFF);
				}
				else
				{
					KillWeapon(weapon);
				}
			}
		}
	}		
}

// workaround for a tf2 bug: if a construction PDA is deleted it will hide the build menu for EVERYONE!
// so it is deferred till the end of a minigame
function Ware_DeferredPDAKill(data)
{
	local pda = data.construction_pda;
	if (pda)
	{
		if (pda.IsValid())
			pda.Kill();
		data.construction_pda = null;
	}
}

function Ware_AddPlayerAttribute(player, name, value, duration)
{
	player.AddCustomAttribute(name, value, duration);
	return player.GetScriptScope().ware_data.attributes.append(name);
}

function Ware_SetGlobalAttribute(name, value, duration)
{
	foreach (data in Ware_MinigamePlayers)
		Ware_AddPlayerAttribute(data.player, name, value, duration);
}

function Ware_FixupPlayerWeaponSwitch()
{
	if (activator)
		self.Weapon_Switch(activator);
}

function Ware_DisablePlayerPrimaryFire(player)
{
	local weapon = player.GetActiveWeapon();
	if (weapon != null)
		SetPropFloat(weapon, "m_flNextPrimaryAttack", FLT_MAX);
}

function Ware_SetPlayerAmmo(player, ammo_type, ammo)
{
	SetPropIntArray(player, "m_iAmmo", ammo, ammo_type);
}

function Ware_SetPlayerClass(player, player_class, switch_melee = true)
{
	if (player.GetPlayerClass() == player_class)
		return;
	
	SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", player_class);
	player.SetPlayerClass(player_class);
	player.Regenerate(true);
	player.SetCustomModel(GetPropString(player, "m_PlayerClass.m_iszCustomModel"));
	player.SetHealth(player.GetMaxHealth());
	Ware_ParseLoadout(player);
	
	if (switch_melee)
	{
		local data = player.GetScriptScope().ware_data;
		if (data.melee)
			player.Weapon_Switch(data.melee);
	}
}

function Ware_PassPlayer(player, pass)
{
	local data = player.GetScriptScope().ware_data;
	if (data.passed == pass)
		return;
		
	if (pass && !data.passed_effects)
	{
		Ware_ShowPassEffects(player);
		data.passed_effects = true;
	}
	
	data.passed = pass;
}

function Ware_ShowPassEffects(player)
{
	player.EmitSound(SFX_WARE_PASS);
	Ware_SpawnParticle(player, player.GetTeam() == TF_TEAM_RED ? PFX_WARE_PASS_RED : PFX_WARE_PASS_BLUE);	
}

function Ware_IsPlayerPassed(player)
{
	return player.GetScriptScope().ware_data.passed;
}

function Ware_SetPlayerMission(player, mission)
{
	return player.GetScriptScope().ware_data.mission = mission;
}

function Ware_SuicidePlayer(player)
{
	player.TakeDamageCustom(player, player, null, Vector(), Vector(), 99999.0, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_SUICIDE);
}

function Ware_SuicideFailedPlayers()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (IsEntityAlive(player) && !Ware_IsPlayerPassed(player))
			Ware_SuicidePlayer(player);
	}
}

function Ware_RadiusDamagePlayers(origin, radius, damage, attacker)
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
			
		local dist = (player.GetOrigin() - origin).Length();
		if (dist > radius)
			continue;
			
		dist += DIST_EPSILON; // prevent divide by zero
		local falloff = 1.0 - dist / radius;
		if (falloff <= 0.0)
			continue;
			
		player.TakeDamage(damage * falloff, DMG_BLAST, attacker);
	}	
}

function Ware_GetPlayerHeight(player)
{
	return player.GetOrigin().z - Ware_MinigameLocation.center.z;
}

function Ware_PlayStartSound()
{
	self.GetScriptScope().ware_data.start_sound = true;
	 
	if (IsInWaitingForPlayers())
		Ware_PlayGameSound(self, "lets_get_started");	
}

function Ware_CheckHomeLocation(player_count)
{
	local prev_location = Ware_MinigameHomeLocation;
	Ware_MinigameHomeLocation = Ware_Location[player_count > 12 ? "home_big" : "home"];
	
	if (Ware_MinigameHomeLocation != prev_location)
	{
		if (prev_location)
		{
			foreach (spawn in prev_location.spawns)
				SetPropBool(spawn, "m_bDisabled", true);
		}
		
		foreach (spawn in Ware_MinigameHomeLocation.spawns)
			SetPropBool(spawn, "m_bDisabled", false);		
	}
}

function Ware_BeginIntermission()
{
	if (Ware_DebugStop)
		return;
	
	foreach (player in Ware_Players)
	{
		Ware_PlayGameSound(player, "intro");
		Ware_ShowScreenOverlay(player, null);
		Ware_ShowScreenOverlay2(player, null);
	}
	
	if (Ware_MinigameRotation.len() == 0)
	{
		foreach (minigame in Ware_Minigames)
		{
			if (minigame[0])
				Ware_MinigameRotation.append(minigame[1]);
		}
	}
	
	local minigame;
	if (Ware_DebugForceMinigame.len() > 0)
		minigame = Ware_DebugForceMinigame;
	else
		minigame = Ware_MinigameRotation.remove(RandomIndex(Ware_MinigameRotation));
	
	CreateTimer(@() Ware_StartMinigame(minigame), 4.0);
}

function Ware_Speedup()
{
	Ware_SetTimeScale(Ware_TimeScale + 0.25);
	
	foreach (player in Ware_Players)
	{
		Ware_PlayGameSound(player, "speedup");
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/default_speed");
		Ware_ShowScreenOverlay2(player, null);
	}
	
	CreateTimer(@() Ware_BeginIntermission(), 5.0);
}

function Ware_StartMinigame(minigame)
{
	if (Ware_DebugForceMinigame.len() > 0)
		minigame = Ware_DebugForceMinigame;
	
	Ware_MinigameEnded = false;
	
	IncludeScript(format("tf2ware_ultimate/minigames/%s", minigame), Ware_MinigameScope); 	

	Ware_Minigame = Ware_MinigameScope.minigame;
	Ware_MinigameStartTime = Time();
	
	foreach (name, value in Ware_Minigame.convars)
	{
		Ware_MinigameSavedConvars[name] <- GetConvarValue(name);
		SetConvarValue(name, value);
	}
	
	Ware_MinigamePlayers.clear();
	foreach (player in Ware_Players)
	{
		EntFireByHandle(ClientCmd, "Command", "r_cleardecals", -1, player, null);
		
		if (!(player.GetTeam() & 2) || !IsEntityAlive(player))
			continue;
		
		if (Ware_Minigame.no_collisions)
			player.SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);
		if (Ware_Minigame.thirdperson)
			player.SetForcedTauntCam(1);

		local scope = player.GetScriptScope();
		local data = scope.ware_data;
		scope.ware_minidata.clear();
		data.passed = Ware_Minigame.start_pass;
		data.passed_effects = false;
		data.mission = 0;
		Ware_MinigamePlayers.append(data);
	}
	
	local player_count = Ware_MinigamePlayers.len();
	local location;
	if (player_count > 12 && ((Ware_Minigame.location + "_big") in Ware_Location))
		location = Ware_Location[Ware_Minigame.location + "_big"];
	else
		location = Ware_Location[Ware_Minigame.location];
		
	local custom_teleport = "OnTeleport" in Ware_MinigameScope;
	if (location != Ware_MinigameLocation)
	{
		Ware_MinigameLocation = location;
		if (!custom_teleport)
			location.Teleport(Ware_MinigamePlayers.map(@(data) data.player));
	}
	
	if (custom_teleport)
		Ware_MinigameScope.OnTeleport(Ware_MinigamePlayers.map(@(data) data.player));
	
	if (Ware_Minigame.allow_damage)
		SetPropBool(GameRules, "m_bTruceActive", false);
	
	if ("OnStart" in Ware_MinigameScope)
		Ware_MinigameScope.OnStart();
		
	Ware_Minigame.cb_on_take_damage			= Ware_MinigameCallback("OnTakeDamage");
	Ware_Minigame.cb_on_player_attack		= Ware_MinigameCallback("OnPlayerAttack");
	Ware_Minigame.cb_on_player_death		= Ware_MinigameCallback("OnPlayerDeath");
	Ware_Minigame.cb_on_player_say			= Ware_MinigameCallback("OnPlayerSay");
	Ware_Minigame.cb_on_player_voiceline	= Ware_MinigameCallback("OnPlayerVoiceline");
	Ware_Minigame.cb_on_player_touch		= Ware_MinigameCallback("OnPlayerTouch");
	Ware_Minigame.cb_on_update				= Ware_MinigameCallback("OnUpdate");
	
	local event_prefix = "OnGameEvent_";
	local event_prefix_len = event_prefix.len();
	foreach (key, value in Ware_MinigameScope)
	{
		if (typeof(value) == "function" && typeof(key) == "string" && key.find(event_prefix, 0) == 0)
		{
				local event_name = key.slice(event_prefix_len); 
				if (event_name.len() > 0)
				{
					if (!(event_name in GameEventCallbacks))
					{
						GameEventCallbacks[event_name] <- [];
						RegisterScriptGameEventListener(event_name);
					}
					
					GameEventCallbacks[event_name].push(Ware_MinigameScope);
					Ware_MinigameEvents.append(event_name);
				}
		}
	}
	
	Ware_TextManager.KeyValueFromFloat("holdtime", Ware_Minigame.duration + Ware_Minigame.end_delay);
	
	local overlay, overlay2;
	if (Ware_Minigame.custom_overlay == null)
	{
		overlay = format("hud/tf2ware_ultimate/minigames/%s", minigame);
	}
	else if (Ware_Minigame.custom_overlay.len() > 0)
	{
		if (Ware_Minigame.custom_overlay.slice(0, 3) == "../")
			overlay = format("hud/tf2ware_ultimate/%s", Ware_Minigame.custom_overlay.slice(3));
		else
			overlay = format("hud/tf2ware_ultimate/minigames/%s", Ware_Minigame.custom_overlay);
	}
	else
	{
		overlay = "";
	}
	
	if (Ware_Minigame.custom_overlay2 != null)
	{
		overlay2 = Ware_Minigame.custom_overlay2; 
		if (overlay2.slice(0, 3) == "../")
			overlay2 = format("hud/tf2ware_ultimate/%s", overlay2.slice(3));
		else
			overlay2 = format("hud/tf2ware_ultimate/minigames/%s", overlay2);
			
		Ware_MinigameOverlay2Set = true;
	}

	foreach (data in Ware_MinigamePlayers)
	{	
		local player = data.player;
		local mission = data.mission;
		
		if (mission == 0)
		{
			Ware_ShowScreenOverlay(player, overlay);
			if (Ware_MinigameOverlay2Set)
				Ware_ShowScreenOverlay2(player, overlay2);
		}
		else if (mission == 1)
		{
			Ware_ShowScreenOverlay(player, overlay);
		}
		else if (mission == 2)
		{
			Ware_ShowScreenOverlay2(player, overlay2);
		}
	}
	
	Ware_PlayMinigameSound(null, Ware_Minigame.music);
	
	Ware_MinigamePreEndTimer = CreateTimer(function() 
		{ 
			Ware_MinigameEnded = true;
			if ("OnEnd" in Ware_MinigameScope) 
				Ware_MinigameScope.OnEnd();
				
			if (Ware_Minigame.start_pass)
			{
				foreach (data in Ware_MinigamePlayers)
				{
					if (data.passed && !data.passed_effects)
					{
						Ware_ShowPassEffects(data.player);
						data.passed_effects = true;
					}
				}
			}
				
			if (Ware_Minigame.suicide_on_end)
				Ware_SuicideFailedPlayers();
		}, 
		Ware_Minigame.duration
	);
	Ware_MinigameEndTimer = CreateTimer(
		@() Ware_EndMinigameInternal(), 
		Ware_Minigame.duration + Ware_Minigame.end_delay
	);
}

function Ware_EndMinigame()
{
	if (Ware_MinigameEnded)
		return;
		
	FireTimer(Ware_MinigamePreEndTimer);
	KillTimer(Ware_MinigameEndTimer);
	
	Ware_MinigameEndTimer = CreateTimer(
		@() Ware_EndMinigameInternal(),
		Ware_Minigame.end_delay
	);
}

function Ware_EndMinigameInternal()
{
	Ware_MinigamesPlayed++;
	
	foreach (name, value in Ware_MinigameSavedConvars)
		SetConvarValue(name, value);
	Ware_MinigameSavedConvars.clear();
	
	local player_count = 0;
	local respawn_players = [];
	foreach (player in Ware_Players)
	{
		if (!(player.GetTeam() & 2))
			continue;
			
		player.RemoveAllObjects(false);
			
		if (Ware_Minigame.no_collisions)
			player.SetCollisionGroup(COLLISION_GROUP_PLAYER);
		if (Ware_Minigame.thirdperson)
			player.SetForcedTauntCam(0);
			
		if (IsEntityAlive(player))
		{
			local data = player.GetScriptScope().ware_data;
			
			local melee = data.melee;
			if (melee)
			{
				foreach (attribute, value in data.melee_attributes)
					melee.RemoveAttribute(attribute);
			}
			data.melee_attributes.clear();
			
			foreach (attribute in data.attributes)
				player.RemoveCustomAttribute(attribute);
			data.attributes.clear();
			
			player.SetHealth(player.GetMaxHealth());
			SetPropInt(player, "m_nImpulse", 101); // refill ammo						
			Ware_StripPlayer(player, true);
		}
		else
		{
			respawn_players.append(player);
		}
		
		player_count++;
	}

	Ware_CheckHomeLocation(player_count);
	
	foreach (player in respawn_players)
		player.ForceRespawn();
	
	if (Ware_MinigameLocation != Ware_MinigameHomeLocation)
	{
		Ware_MinigameHomeLocation.Teleport(Ware_MinigamePlayers.map(@(data) data.player));
		Ware_MinigameLocation = Ware_MinigameHomeLocation;
	}
	
	if (Ware_Minigame.allow_damage)
		SetPropBool(GameRules, "m_bTruceActive", true);
		
	Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_STOP);

	local all_passed = true;
	local all_failed = true;
	
	foreach (data in Ware_MinigamePlayers)
	{
		if (data.passed)
			all_failed = false;
		else
			all_passed = false;
	}
	
	if (all_passed || all_failed)
	{
		local overlay = all_passed ? "hud/tf2ware_ultimate/default_victory_all" : "hud/tf2ware_ultimate/default_failure_all";
		local sound = all_passed ? "victory" : "failure_all";
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player;
			Ware_PlayGameSound(player, sound);
			Ware_ShowScreenOverlay(player, overlay);
			if (Ware_MinigameOverlay2Set)
				Ware_ShowScreenOverlay2(player, null);	
		}
	}
	else
	{
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player;
			Ware_PlayGameSound(player, data.passed ? "victory" : "failure");
			Ware_ShowScreenOverlay(player, data.passed ? "hud/tf2ware_ultimate/default_victory" : "hud/tf2ware_ultimate/default_failure");
			if (Ware_MinigameOverlay2Set)
				Ware_ShowScreenOverlay2(player, null);
		}		
	}
	
	foreach (event_name in Ware_MinigameEvents)
		GameEventCallbacks[event_name].pop();
	Ware_MinigameEvents.clear();
		
	foreach (entity in Ware_Minigame.entities)
		if (entity.IsValid())
			entity.Kill();
	
	foreach (name, v in Ware_Minigame.cleanup_names)
		EntFire(name, "Kill");
		
	foreach (timer in Ware_Minigame.timers)
		KillTimer(timer);
	
	Ware_Minigame = null;
	Ware_MinigameScope.clear();
	Ware_MinigameOverlay2Set = false;
	
	if (Ware_MinigamesPlayed > 0 && Ware_MinigamesPlayed % 5 == 0)
		CreateTimer(@() Ware_Speedup(), 2.0);
	else
		CreateTimer(@() Ware_BeginIntermission(), 2.0);
}

function Ware_OnUpdate()
{
	if (Ware_Minigame == null)
		return;
		
	if (!Ware_MinigameEnded)
	{
		if (Ware_Minigame.end_below_min)
		{
			local stop = true;
			local alive_count = 0;
			foreach (data in Ware_MinigamePlayers)
			{
				if (IsEntityAlive(data.player) && ++alive_count >= Ware_Minigame.min_players)
				{
					stop = false;
					break;
				}
			}
			
			if (stop)
				Ware_EndMinigame();
		}
		else if (Ware_Minigame.end_dead_team)
		{
			local stop = true;
			local red_alive = false;
			local blue_alive = false;
			foreach (data in Ware_MinigamePlayers)
			{
				local player = data.player;
				if (IsEntityAlive(player))
				{
					local team = player.GetTeam();
					if (team == TF_TEAM_RED)
						red_alive = true;
					else if (team == TF_TEAM_BLUE)
						blue_alive = true;
					
					if (red_alive && blue_alive)
						break;
				}
			}
			
			if (!red_alive || !blue_alive)
				Ware_EndMinigame();			
		}
	}

	if (!Ware_Minigame.cb_on_update) // can happen if a minigame script errors on load
		return;
	
	Ware_Minigame.cb_on_update();
	
	if (Ware_Minigame.cb_on_player_attack.func)
	{
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player;
			local weapon = player.GetActiveWeapon();
			if (weapon)
			{
				local fire_time = GetPropFloat(weapon, "m_flLastFireTime");
				local scope = weapon.GetScriptScope();
				if (fire_time > scope.last_fire_time)
				{
					Ware_Minigame.cb_on_player_attack(player);
					scope.last_fire_time = fire_time;
				}
			}
		}
	}
	
	if (Ware_Minigame.cb_on_player_voiceline.func)
	{
		for (local scene; scene = FindByClassname(scene, "instanced_scripted_scene");)
		{
			scene.KeyValueFromString("classname", "ware_voiceline");
			MarkForPurge(scene);
			
			local player = GetPropEntity(scene, "m_hOwner");	
			if (player)
			{
				local name = GetPropString(scene, "m_szInstanceFilename");
				Ware_Minigame.cb_on_player_voiceline(player, name.tolower());
			}
		}
	}
	
	if (Ware_Minigame.cb_on_player_touch.func)
	{
		local candidates = [];
		local bloat_maxs = Vector(0.05, 0.05, 0.05);
		local bloat_mins = bloat_maxs * -1.0;
		
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player;
			if (IsEntityAlive(player))
			{
				local origin = player.GetOrigin();
				candidates.append(
				[
					player, 
					origin + player.GetBoundingMins() + bloat_mins, 
					origin + player.GetPlayerMaxs() + bloat_maxs
				]);
			}
		}
		
		local intersections = {};
		local candidates_len = candidates.len();
		for (local i = 0; i < candidates_len; ++i)
		{
			local candidate_a = candidates[i];
			if (candidate_a in intersections)
				continue;
			
			for (local j = i + 1; j < candidates_len; ++j)
			{
				local candidate_b = candidates[j];
				if (candidate_b in intersections)
					continue;
				
				if (IntersectBoxBox(candidate_a[1], candidate_a[2], candidate_b[1], candidate_b[2]))
				{
					local player_a = candidate_a[0];
					local player_b = candidate_b[0];			
					intersections[player_a] <- player_b;
					intersections[player_b] <- player_a;
				}
			}
		}
		
		foreach (player, other_player in intersections)
			Ware_Minigame.cb_on_player_touch(player, other_player);
	}
	
	return -1;
}

ClearGameEventCallbacks();

function OnScriptHook_OnTakeDamage(params)
{
	if (params.damage_custom == TF_DMG_CUSTOM_SUICIDE)
		return;
		
	if (Ware_Minigame == null)
	{
		if (params.damage_type & DMG_FALL)
		{
			params.damage = 0;
			params.early_out = true;		
		}
		
		return;
	}
		
	if (Ware_Minigame.friendly_fire)
	{
		params.force_friendly_fire = true;
	}
	else
	{
		local victim = params.const_entity;
		local attacker = params.attacker;
		if (victim.IsPlayer()
			&& attacker
			&& attacker != victim
			&& attacker.IsPlayer()
			&& victim.GetTeam() == attacker.GetTeam())
		{
			params.damage = 0;
			params.early_out = true;
			return;
		}
	}
	
	if (Ware_Minigame.cb_on_take_damage(params) == false)
	{
		params.damage = 0;
		params.early_out = true;
		return;
	}
}

function OnGameEvent_teamplay_round_start(params)
{
	Ware_SetTimeScale(1.0);
	
	if (IsInWaitingForPlayers())
		return;
	
	if (Ware_Started)
		return;		
	Ware_Started = true;

	SetPropBool(GameRules, "m_bTruceActive", true);
	
	Ware_MinigameRotation.clear();
	foreach (minigame in Ware_Minigames)
	{
		if (minigame[0])
			Ware_MinigameRotation.append(minigame[1]);
	}
	
	Ware_BeginIntermission();
}

function PlayerPostSpawn()
{
	if (Ware_TimeScale != 1.0)
		self.AddCustomAttribute("voice pitch scale", Ware_GetPitchFactor(), -1);
		
	local player_class = self.GetPlayerClass();
	if (player_class == TF_CLASS_DEMOMAN)
	{
		for (local wearable = self.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		{
			MarkForPurge(wearable);
			if (wearable.GetClassname() == "tf_wearable_demoshield")
			{
				SetPropBool(self, "m_Shared.m_bShieldEquipped", false);
				wearable.Kill();
				break;
			}
		}		
	}
	else if (player_class == TF_CLASS_SNIPER)
	{
		for (local wearable = self.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		{
			MarkForPurge(wearable);
			if (wearable.GetClassname() == "tf_wearable_razorback")
			{
				wearable.Kill();
				break;
			}
		}	
	}
}

function OnGameEvent_player_spawn(params)
{
    local player = GetPlayerFromUserID(params.userid);
    if (player == null)
		return;
		
	if (params.team == TEAM_UNASSIGNED)
	{
		MarkForPurge(player);
		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		scope.ware_data <- Ware_PlayerData(player);
		scope.ware_minidata <- {};
		Ware_Players.append(player);
		return;
	}
	
	local data = player.GetScriptScope().ware_data;
	
	Ware_DeferredPDAKill(data);
	
	// this is to fix persisting attributes if restarting mid-minigame
	local melee = data.melee;
	if (melee && melee.IsValid())
	{
		foreach (attribute, value in data.melee_attributes)
			melee.RemoveAttribute(attribute);
	}
	data.attributes.clear();
	data.melee_attributes.clear();
	
	data.team = params.team;	
	if (params.team & 2)
	{
		if (!data.start_sound)
			EntFireByHandle(player, "CallScriptFunction", "Ware_PlayStartSound", 2.0, null, null);
		
		local melee = Ware_ParseLoadout(player);
		if (melee != null)
			player.Weapon_Switch(melee);
			
		EntFireByHandle(player, "CallScriptFunction", "PlayerPostSpawn", -1, null, null);
		
		player.AddHudHideFlags(HIDEHUD_BUILDING_STATUS|HIDEHUD_CLOAK_AND_FEIGN|HIDEHUD_PIPES_AND_CHARGE);
		player.SetCustomModel("");
	}
}

function OnGameEvent_player_changeclass(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (player && !IsEntityAlive(player) && !IsInWaitingForPlayers())
		SetPropFloat(player, "m_flDeathTime", Time()); // no late respawns
}

function OnGameEvent_player_death(params)
{
	local ammos = [];
	for (local ammo; ammo = FindByClassname(ammo, "tf_ammo_pack");)
	{
		MarkForPurge(ammo);
		ammos.append(ammo);
	}
	
	foreach (ammo in ammos)
		ammo.Kill();
	
	if (Ware_Minigame == null)
		return;
		
	if (Ware_Minigame.fail_on_death == true)
	{
		local victim = GetPlayerFromUserID(params.userid);
		if (victim != null)
			Ware_PassPlayer(victim, false);
	}
	
	Ware_Minigame.cb_on_player_death(params);
}

function OnGameEvent_player_disconnect(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (!player)
		return;
		
	local data = player.GetScriptScope().ware_data;
	local idx = Ware_MinigamePlayers.find(data);
	if (idx != null)
		Ware_MinigamePlayers.remove(idx);
		
	idx = Ware_Players.find(player);
	if (idx != null)
		Ware_Players.remove(idx);
}

function OnGameEvent_player_say(params)
{
	if (Ware_Minigame == null)
		return;
		
    local player = GetPlayerFromUserID(params.userid);
    if (player == null)
		return;
	
	// TODO: return value should indicate whether to hide message
	Ware_Minigame.cb_on_player_say(player, params.text);
}

__CollectGameEventCallbacks(this);

Ware_FindStandardEntities();
Ware_SetupLocations();
