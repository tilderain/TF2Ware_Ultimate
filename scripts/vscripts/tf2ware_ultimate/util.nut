// by ficool2

foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps)
		
FindByClassname        <- Entities.FindByClassname.bindenv(Entities)
FindByClassnameNearest <- Entities.FindByClassnameNearest.bindenv(Entities)
FindByName             <- Entities.FindByName.bindenv(Entities)

SetConvarValue  <- Convars.SetValue.bindenv(Convars)
GetConvarValue  <- Convars.GetStr.bindenv(Convars)

function Min(a, b)
{
    return (a <= b) ? a : b
}

function Max(a, b)
{
    return (a >= b) ? a : b
}

function Clamp(val, min, max)
{
	return (val < min) ? min : (max < val) ? max : val
}

function Round(x)
{
    if (x < 0.0)
        return (x - 0.5).tointeger()
    else
        return (x + 0.5).tointeger()
}

function Snap(x, y)
{
	return Round(x / y) * y
}

function SnapVector(vec, y)
{
	return Vector(Snap(vec.x, y), Snap(vec.y, y), Snap(vec.z, y))
}

function Lerp(t, A, B)
{
    return A + (B - A) * t
}

function VectorFormat(vec)
{
	return format("Vector(%g, %g, %g)", vec.x, vec.y, vec.z)
}

function RemapValClamped(v, A, B, C, D)
{
	local cv = (v - A) / (B - A)
	if (cv <= 0.0)
		return C
	if (cv >= 1.0)
		return D
	return C + (D - C) * cv
}

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

function RandomIndex(arr)
{
	return RandomInt(0, arr.len() - 1)
}

function RandomElement(arr)
{
	return arr[RandomIndex(arr)]
}

function RemoveRandomElement(arr)
{
	return arr.remove(RandomIndex(arr))
}

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

function IntersectBoxBox(a_mins, a_maxs, b_mins, b_maxs) 
{
    return (a_mins.x <= b_maxs.x && a_maxs.x >= b_mins.x) &&
           (a_mins.y <= b_maxs.y && a_maxs.y >= b_mins.y) &&
           (a_mins.z <= b_maxs.z && a_maxs.z >= b_mins.z)
}

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

function MarkForPurge(entity)
{
	SetPropBool(entity, "m_bForcePurgeFixedupStrings", true)
}

function CreateEntitySafe(classname)
{
	local entity = Entities.CreateByClassname(classname)
	MarkForPurge(entity)
	return entity
}

function SpawnEntityFromTableSafe(classname, keyvalues)
{
	local entity = SpawnEntityFromTable(classname, keyvalues)
	MarkForPurge(entity)
	return entity
}

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

function FireTimer(timer)
{
	if (timer && timer.IsValid())
	{
		timer.GetScriptScope().InputTrigger()
		KillTimer(timer)
	}
}

function KillTimer(timer)
{
	if (timer && timer.IsValid())
	{
		timer.TerminateScriptScope()
		timer.Kill()
	}
}

function IsEntityAlive(player)
{
	return GetPropInt(player, "m_lifeState") == 0
}

function SetEntityColor(entity, r, g, b, a)
{
    local color = (r) | (g << 8) | (b << 16) | (a << 24)
    SetPropInt(entity, "m_clrRender", color)
}

function EntityEntFire(entity, input, parameter = "", delay = 0.0, activator = null, caller = null)
{
	EntFireByHandle(entity, input, parameter, delay, activator, caller);
}

function PlayerParentFix()
{
	self.RemoveEFlags(EFL_KILLME)
	for (local wearable = self.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		wearable.AddEFlags(EFL_KILLME)
	
	SetPropInt(self, "m_fEffects", 0)
	SetPropInt(self, "m_iParentAttachment", 0)
}

function SetEntityParent(entity, parent, attachment = null)
{
	if (parent)
	{
		EntFireByHandle(entity, "SetParent", "!activator", -1, parent, null)
		if (attachment)
			EntFireByHandle(entity, "SetParentAttachment", attachment, -1, null, null)
	}
	else
	{
		EntFireByHandle(entity, "ClearParent", "", -1, null, null)
	}
}

function SetPlayerParent(player, parent, attachment = null)
{
	if (parent)
	{
		SetPropInt(player, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL)
		EntFireByHandle(player, "SetParent", "!activator", -1, parent, null)
		if (attachment)
			EntFireByHandle(player, "SetParentAttachment", attachment, -1, null, null)
	}
	else
	{
		// prevent players and their stuff from getting deleted
		player.AddEFlags(EFL_KILLME)
		for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		{
			MarkForPurge(wearable)
			wearable.AddEFlags(EFL_KILLME)
		}
	
		EntFireByHandle(player, "ClearParent", "", -1, null, null)
		EntFireByHandle(player, "CallScriptFunction", "PlayerParentFix", -1, null, null)
	}
}


_PostInputScope <- null
_PostInputFunc  <- null

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

function GetPlayerName(player)
{
    return GetPropString(player, "m_szNetname")
}

function GetPlayerUserID(player)
{
    return GetPropIntArray(PlayerMgr, "m_iUserID", player.entindex())
}

function GetPlayerSteamID3(player)
{
    return GetPropString(player, "m_szNetworkIDString")
}

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
		points = -1
	})

	if (!is_bot) 
		player.RemoveFlag(FL_FAKECLIENT)
}

function NullActivatorFix()
{
	// block input to prevent crashes with null activator
	return activator != null
}

function PlayVocalization(player, sound)
{
	if (player.IsValid() && IsEntityAlive(player))
		player.EmitSound(sound)
}

function BurnPlayer(player, burn_damage, burn_duration, post_touch_callback = null)
{
	local trigger = CreateEntitySafe("trigger_ignite")
	trigger.KeyValueFromInt("spawnflags", 1)
	trigger.KeyValueFromFloat("damage_percent_per_second", burn_damage)
	trigger.KeyValueFromFloat("burn_duration", burn_duration)
	SetInputHook(trigger, "StartTouch", NullActivatorFix, post_touch_callback)
	EntFireByHandle(trigger, "StartTouch", "", -1, player, player)
	EntFireByHandle(trigger, "Kill", "", -1, null, null)
}

function StunPlayer(player, stun_type, stun_effects, stun_duration, move_speed_reduction, post_touch_callback = null)
{
	local trigger = CreateEntitySafe("trigger_stun")
	trigger.KeyValueFromInt("spawnflags", 1)
	trigger.KeyValueFromInt("stun_type", stun_type)
	trigger.KeyValueFromInt("stun_effects", stun_effects.tointeger())
	trigger.KeyValueFromFloat("stun_duration", stun_duration)
	trigger.KeyValueFromFloat("move_speed_reduction", move_speed_reduction)
	SetInputHook(trigger, "EndTouch", NullActivatorFix, post_touch_callback)
	EntFireByHandle(trigger, "EndTouch", "", -1, player, player)
	EntFireByHandle(trigger, "Kill", "", -1, null, null)
}

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

function KillPlayerRagdoll(player)
{
	local ragdoll = GetPropEntity(player, "m_hRagdoll")
	if (ragdoll)
	{
		MarkForPurge(ragdoll)
		ragdoll.Kill()
	}
}

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

// spoof an item to create the disintegration effect
if (!("TriggerHurtDisintegrateProxy" in this) || !TriggerHurtDisintegrateProxy.IsValid())
{
    TriggerHurtDisintegrateProxy <- CreateEntitySafe("tf_weapon_bat")
    NetProps.SetPropInt(TriggerHurtDisintegrateProxy, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 349)
    NetProps.SetPropBool(TriggerHurtDisintegrateProxy, "m_AttributeManager.m_Item.m_bInitialized", true)
    TriggerHurtDisintegrateProxy.DispatchSpawn()
	TriggerHurtDisintegrateProxy.DisableDraw()
    TriggerHurtDisintegrateProxy.AddAttribute("ragdolls become ash", 1, -1)
}
  
function TriggerHurtSmack()
{
	self.TakeDamage(1000, DMG_BULLET, activator)
}

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

function ForceRemovePlayerTaunt(player)
{
    player.RemoveCond(TF_COND_TAUNTING)
    
    // remove the cooldown for next taunt
    player.AddCustomAttribute("gesture speed increase", 99999, -1)
    player.Taunt(TAUNT_BASE_WEAPON, 0)
    player.RemoveCond(TF_COND_TAUNTING)
    player.RemoveCustomAttribute("gesture speed increase")
}
