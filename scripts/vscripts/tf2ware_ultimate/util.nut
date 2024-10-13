// by ficool2

// Folded stuff for easier usage
foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps)
		
FindByClassname        <- Entities.FindByClassname.bindenv(Entities)
FindByClassnameNearest <- Entities.FindByClassnameNearest.bindenv(Entities)
FindByName             <- Entities.FindByName.bindenv(Entities)

SetConvarValue  <- Convars.SetValue.bindenv(Convars)
GetConvarValue  <- Convars.GetStr.bindenv(Convars)

// Return the minimum value of a and b
function Min(a, b)
{
    return (a <= b) ? a : b
}

// Return the maximum value of a and b
function Max(a, b)
{
    return (a >= b) ? a : b
}

// Return a value clamped between the boundaries of min and max
function Clamp(val, min, max)
{
	return (val < min) ? min : (max < val) ? max : val
}

// Round number to the nearest whole integer
function Round(x)
{
    if (x < 0.0)
        return (x - 0.5).tointeger()
    else
        return (x + 0.5).tointeger()
}

// Snap a number to the interval y
function Snap(x, y)
{
	return Round(x / y) * y
}

// Snap a vector to the interval y
function SnapVector(vec, y)
{
	return Vector(Snap(vec.x, y), Snap(vec.y, y), Snap(vec.z, y))
}

// Lerp a value between A and B, t being percentage from 0 to 1
function Lerp(t, A, B)
{
    return A + (B - A) * t
}

// Remap a value from the range A - B into C - D
// If the value is outside of the boundary, it is clamped
function RemapValClamped(v, A, B, C, D)
{
	local cv = (v - A) / (B - A)
	if (cv <= 0.0)
		return C
	if (cv >= 1.0)
		return D
	return C + (D - C) * cv
}

// Returns true if the two AABBs are intersecting
function IntersectBoxBox(a_mins, a_maxs, b_mins, b_maxs) 
{
    return (a_mins.x <= b_maxs.x && a_maxs.x >= b_mins.x) &&
           (a_mins.y <= b_maxs.y && a_maxs.y >= b_mins.y) &&
           (a_mins.z <= b_maxs.z && a_maxs.z >= b_mins.z)
}

// Format a vector in Squirrel form
function VectorFormat(vec)
{
	return format("Vector(%g, %g, %g)", vec.x, vec.y, vec.z)
}

// Randomly shuffle up an array
function Shuffle(arr)
{
	for (local i = arr.len() - 1; i > 0; i--)
	{
		local j = RandomInt(0, i)
		local t = arr[j]
		arr[j] = arr[i]
		arr[i] = t
	}
}

// Return a random index into the array
function RandomIndex(arr)
{
	return RandomInt(0, arr.len() - 1)
}

// Return a random element from the array
function RandomElement(arr)
{
	return arr[RandomIndex(arr)]
}

// Remove and return a random element frm the array
function RemoveRandomElement(arr)
{
	return arr.remove(RandomIndex(arr))
}

// Returns either true or false at random
function RandomBool()
{
	return RandomInt(0, 1) == 1
}

// Reverse a string, with color markers fixed up
function ReverseString(str)
{
	local result = ""
	local stack = []
	
	local len = str.len()
	for (local i = 0; i < len; i++) 
	{
		local c = str.slice(i, i + 1)
		if (c == "\x07" && i + 6 < len) 
		{
			// TODO this doesn't work right, no color markers for now
			//stack.push(str.slice(i, i + 7))
			i += 6;
		} 
		else 
		{
			stack.push(c)
		}
	}
	
	len = stack.len()
	for (local i = 0; i < len; i++)
		result += stack.pop()
	
	return result
}

// Splits the float time into HMS format
// Returns a table of "hours", "minutes" and "seconds"
function FloatToTimeHMS(time)
{
	local h, m, s
	s = Round(time)
	h = s / 3600
	s -= h * 3600
	m = s / 60
	s = s % 60
	return { hours = h, minutes = m, seconds = s }
}

// Marks an entity as purged for the stringtable
// For internal use only
function MarkForPurge(entity)
{
	SetPropBool(entity, "m_bForcePurgeFixedupStrings", true)
}

// Precache a material
function PrecacheMaterial(material)
{
    local entity = SpawnEntityFromTableSafe("vgui_screen", { overlaymaterial = material })
    local index = GetPropInt(entity, "m_nOverlayMaterial")
    entity.Destroy()
    return index
}

// Precache a sprite material
function PrecacheSprite(sprite)
{
	PrecacheModel(sprite)
	return true
}

// Precache an overlay texture
function PrecacheOverlay(overlay)
{
	PrecacheModel(overlay + ".vmt")
	return true
}

// Precache a particle
function PrecacheParticle(name)
{
	PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = name })
	return true
}

// Create an entity that doesn't leak the stringtable
// Always use this instead of raw Entities.CreateByClassname
function CreateEntitySafe(classname)
{
	local entity = Entities.CreateByClassname(classname)
	MarkForPurge(entity)
	return entity
}

// Spawn an entity that doesn't leak the stringtable
// Always use this instead of raw SpawnEntityFromTable
function SpawnEntityFromTableSafe(classname, keyvalues)
{
	local entity = SpawnEntityFromTable(classname, keyvalues)
	MarkForPurge(entity)
	return entity
}

// Creates a timer that executes the given function after a delay
// The function may return a float value to repeat the function again after the new delay
// If the function returns nothing or null, the timer is killed
// Returns a handle to the timer, like an entity
function CreateTimer(on_timer_func, delay)
{
	local relay = CreateEntitySafe("logic_relay")
	relay.ValidateScriptScope()
	local relay_scope = relay.GetScriptScope()
	relay_scope.scope <- this
	relay_scope.repeat <- false
	
	SetInputHook(relay, "Trigger", 
	function()
	{
		local delay = (on_timer_func.bindenv(scope))()
		if (delay != null)
		{
			repeat = true
			EntFireByHandle(self, "Trigger", "", delay, null, null)
		}
		return false
	}
	function() 
	{
		if (repeat)
			repeat = false
		else if (self.IsValid()) 
			self.Kill()
	})
	
	EntFireByHandle(relay, "Trigger", "", delay, null, null)
	return relay
}

// Executes the function of a timer
function FireTimer(timer)
{
	if (timer && timer.IsValid())
	{
		timer.GetScriptScope().InputTrigger()
		KillTimer(timer)
	}
}

// Kills the timer, it will not execute any pending function
function KillTimer(timer)
{
	if (timer && timer.IsValid())
	{
		timer.TerminateScriptScope()
		timer.Kill()
	}
}

// Returns true if entity is alive
function IsEntityAlive(player)
{
	return GetPropInt(player, "m_lifeState") == 0
}

// Sets an entity's rendering color
function SetEntityColor(entity, r, g, b, a)
{
    local color = (r) | (g << 8) | (b << 16) | (a << 24)
    SetPropInt(entity, "m_clrRender", color)
}

// Convenience wrapper for EntFireByHandle
function EntityEntFire(entity, input, parameter = "", delay = 0.0, activator = null, caller = null)
{
	EntFireByHandle(entity, input, parameter, delay, activator, caller);
}

// Convenience wrapper for AcceptInput
function EntityAcceptInput(entity, input, parameter = "", activator = null, caller = null)
{
	return entity.AcceptInput(input, parameter, activator, caller)
}

// Returns true if the entity is a hat wearable
function IsWearableHat(entity)
{
	if (!startswith(entity.GetClassname(), "tf_wearable"))
		return false
	
	return entity.LookupBone("bip_head") >= 0
}

// Internal use only
function PlayerParentFix()
{
	self.RemoveEFlags(EFL_KILLME)
	for (local wearable = self.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		wearable.RemoveEFlags(EFL_KILLME)
	
	SetPropInt(self, "m_fEffects", 0)
	SetPropInt(self, "m_iParentAttachment", 0)
}

// Sets an entity's parent, optionally to a given attachment
// If "parent" is null, the entity is unparented
function SetEntityParent(entity, parent, attachment = null)
{
	if (parent)
	{
		entity.AcceptInput("SetParent", "!activator", parent, null)
		if (attachment)
			entity.AcceptInput("SetParentAttachment", attachment, parent, null)
	}
	else
	{
		entity.AcceptInput("ClearParent", "", null, null)
	}
}

// Sets a player's parent
// Unlike SetEntityParent, this is intended when parenting players to another player
// Prevents the player from going invisible
// If "parent" is null, the player is unparented
function SetPlayerParentPlayer(player, parent, attachment = null)
{
	if (parent)
	{
		SetPropInt(player, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL)
	}
	else
	{
		SetPropInt(player, "m_fEffects", 0)
		SetPropInt(player, "m_iParentAttachment", 0)
	}
	
	SetEntityParent(player, parent, attachment)
}

// Internal use only
_PostInputScope <- null
_PostInputFunc  <- null

// Sets functions that execute before and/or after a given input is received on the entity
// Both pre_func and post_func are optional
function SetInputHook(entity, input, pre_func, post_func)
{
	entity.ValidateScriptScope()
	local scope = entity.GetScriptScope()
	if (post_func)
	{
		local wrapper_func = function() 
		{ 
			_PostInputScope = scope
			_PostInputFunc  = post_func
			if (pre_func)
				return pre_func.call(scope)
			return true
		}
		
		scope["Input" + input]           <- wrapper_func
		scope["Input" + input.tolower()] <- wrapper_func
	}
	else if (pre_func)
	{
		scope["Input" + input]           <- pre_func
		scope["Input" + input.tolower()] <- pre_func
	}
}

// Internal wrapper for SetInputHook
ROOT.setdelegate(
{
	_delslot = function(k)
	{
		if (_PostInputScope && k == "activator" && "activator" in this)
		{
			_PostInputFunc.call(_PostInputScope)
			_PostInputFunc = null
		}
		
		rawdelete(k)
	}
})

// Plays a sound on the given client
function PlaySoundOnClient(player, name, volume = 1.0, pitch = 100, flags = 0)
{
	EmitSoundEx(
	{
		sound_name = name,
		volume = volume
		pitch = pitch,
		entity = player,
		flags = flags,
		filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
	})
}

// Plays a sound on all clients
function PlaySoundOnAllClients(name, volume = 1.0, pitch = 100, flags = 0)
{
	EmitSoundEx(
	{
		sound_name = name,
		volume = volume
		pitch = pitch,
		flags = flags,
		filter_type = RECIPIENT_FILTER_GLOBAL
	})
}

// Gets a player's chat name
function GetPlayerName(player)
{
    return GetPropString(player, "m_szNetname")
}

// Gets a player's user ID
function GetPlayerUserID(player)
{
    return GetPropIntArray(PlayerMgr, "m_iUserID", player.entindex())
}

// Gets a player's SteamID3, e.g. [U:1234]
function GetPlayerSteamID3(player)
{
    return GetPropString(player, "m_szNetworkIDString")
}

// Gets a player's latency in seconds
function GetPlayerLatency(player)
{
	return GetPropIntArray(PlayerMgr, "m_iPing", player.entindex()) * 0.001;
}

// Prevents a player's score from counting towards stranges
function BrickPlayerScore(player)
{
	// spoof as bot so this doesn't upload stats to steam
	local is_bot = player.IsFakeClient()
	if (!is_bot) 
		player.AddFlag(FL_FAKECLIENT)

	// this bricks the scoreboard score to always be 0
	// so stranges don't get leveled up by our scoreboard manipulation
	SendGlobalGameEvent("player_escort_score", 
	{
		player = player.entindex(),
		points = -9999999
	})

	if (!is_bot) 
		player.RemoveFlag(FL_FAKECLIENT)
}

// Plays a sound on a player, if they are valid and alive
function PlayVocalization(player, sound)
{
	if (player.IsValid() && player.IsAlive())
		player.EmitSound(sound)
}

// Burns a player
function BurnPlayer(player, burn_damage, burn_duration)
{
	local trigger = CreateEntitySafe("trigger_ignite")
	trigger.KeyValueFromInt("spawnflags", 1)
	trigger.KeyValueFromFloat("damage_percent_per_second", burn_damage)
	trigger.KeyValueFromFloat("burn_duration", burn_duration)
	trigger.AcceptInput("StartTouch", "", player, player)
	trigger.Kill()
}

// Heals (or damages) a player
function HealPlayer(player, amount)
{
	if (amount > 0)
	{
		local health = player.GetHealth()
		local max_health = player.GetMaxHealth()
		if (amount > max_health - health)
			amount = max_health - health
		
		if (amount > 0)
		{
			player.SetHealth(health + amount)
			
			SendGlobalGameEvent("player_healonhit",
			{
				amount = amount,
				entindex = player.entindex(),
				weapon_def_index = -1,
			})
		}
	}
	else if (amount < 0)
	{
		SendGlobalGameEvent("player_healonhit",
		{
			amount = amount,
			entindex = player.entindex(),
			weapon_def_index = -1,
		})
		
		player.TakeDamage(amount * -1, DMG_PREVENT_PHYSICS_FORCE, player)
	}
}

// Stop a player's taunt and cancel the taunt cooldown
function ForceRemovePlayerTaunt(player)
{
	player.RemoveCond(TF_COND_TAUNTING)

	// remove the cooldown for next taunt
	// allow this to work in midair
	local ground = GetPropEntity(player, "m_hGroundEntity")
	SetPropEntity(player, "m_hGroundEntity", World)
	player.AddCustomAttribute("gesture speed increase", 99999, -1)
	player.Taunt(TAUNT_BASE_WEAPON, 0)
	player.RemoveCond(TF_COND_TAUNTING)
	player.RemoveCustomAttribute("gesture speed increase")
	SetPropEntity(player, "m_hGroundEntity", ground)
}

// Removes a player's ragdoll, if it exists
function KillPlayerRagdoll(player)
{
	local ragdoll = GetPropEntity(player, "m_hRagdoll")
	if (ragdoll)
	{
		MarkForPurge(ragdoll)
		ragdoll.Kill()
	}
}

// Removes a weapon, including any attachments it has
function KillWeapon(weapon)
{
	local wearable = GetPropEntity(weapon, "m_hExtraWearable")
	if (wearable)
	{
		MarkForPurge(wearable)
		wearable.Kill()
	}
	
	wearable = GetPropEntity(weapon, "m_hExtraWearableViewModel")
	if (wearable)
	{
		MarkForPurge(wearable)
		wearable.Kill()
	}
	
	weapon.Kill()
}

// Internal use only
if (!("TriggerHurtDisintegrateProxy" in this) || !TriggerHurtDisintegrateProxy.IsValid())
{
	// Spoof an item to create the disintegration effect
    TriggerHurtDisintegrateProxy <- CreateEntitySafe("tf_weapon_bat")
    SetPropInt(TriggerHurtDisintegrateProxy, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 349)
    SetPropBool(TriggerHurtDisintegrateProxy, "m_AttributeManager.m_Item.m_bInitialized", true)
    TriggerHurtDisintegrateProxy.DispatchSpawn()
	TriggerHurtDisintegrateProxy.DisableDraw()
    TriggerHurtDisintegrateProxy.AddAttribute("ragdolls become ash", 1, -1)
}
  
// Trigger hurt effect used by the map
function TriggerHurtSmack()
{
	self.TakeDamage(1000, DMG_BULLET, activator)
}

// Trigger hurt effect used by the map
function TriggerHurtDisintegrate()
{
	if (self.IsValid()) // safety check otherwise this will crash
	{
		if (self.IsPlayer())
		{
			SetPropEntity(TriggerHurtDisintegrateProxy, "m_hOwner", self)
			self.EmitSound("Fire.Engulf")
			self.TakeDamageCustom(
				caller, self, TriggerHurtDisintegrateProxy, 
				Vector(), Vector(), 
				1000, DMG_BURN, TF_DMG_CUSTOM_BURNING)
		}
		else
		{
			self.TakeDamage(1000, DMG_BURN, caller)
		}
	}
}
