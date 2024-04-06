foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps);
		
FindByClassname <- Entities.FindByClassname.bindenv(Entities);
FindByName      <- Entities.FindByName.bindenv(Entities);

SetConvarValue  <- Convars.SetValue.bindenv(Convars);
GetConvarValue  <- Convars.GetStr.bindenv(Convars);

function Min(a, b)
{
    return (a <= b) ? a : b;
}

function Max(a, b)
{
    return (a >= b) ? a : b;
}

function Clamp(val, min, max)
{
	return (val < min) ? min : (max < val) ? max : val;
}

function Lerp(t, A, B)
{
    return A + (B - A) * t;
}

function RemapValClamped(v, A, B, C, D)
{
	local cv = (v - A) / (B - A);
	if (cv <= 0.0)
		return C;
	if (cv >= 1.0)
		return D;
	return C + (D - C) * cv;
}

function Shuffle(arr)
{
	for (local i = arr.len() - 1; i > 0; i--)
	{
		local j = RandomInt(0, i);
		local t = arr[j]; 
		arr[j] = arr[i];
		arr[i] = t;
	}
}

function RandomIndex(arr)
{
	return RandomInt(0, arr.len() - 1);
}

function IntersectBoxBox(a_mins, a_maxs, b_mins, b_maxs) 
{
    return (a_mins.x <= b_maxs.x && a_maxs.x >= b_mins.x) &&
           (a_mins.y <= b_maxs.y && a_maxs.y >= b_mins.y) &&
           (a_mins.z <= b_maxs.z && a_maxs.z >= b_mins.z);
}
function MarkForPurge(entity)
{
	SetPropBool(entity, "m_bForcePurgeFixedupStrings", true);
}

function CreateEntitySafe(classname)
{
	local entity = Entities.CreateByClassname(classname);
	MarkForPurge(entity);
	return entity;
}

function SpawnEntityFromTableSafe(classname, keyvalues)
{
	local entity = SpawnEntityFromTable(classname, keyvalues);
	MarkForPurge(entity);
	return entity;
}

function CreateTimer(on_timer_func, delay)
{
	local relay = CreateEntitySafe("logic_relay");
	relay.ValidateScriptScope();
	local relay_scope = relay.GetScriptScope();
	relay_scope.scope <- this;
	relay_scope.repeat <- false;
	
	SetInputHook(relay, "Trigger", 
		function()
		{
			local delay = (on_timer_func.bindenv(scope))();
			if (delay != null)
			{
				repeat = true;
				EntFireByHandle(self, "Trigger", "", delay, null, null);
			}
			return false;
		}
		function() 
		{
			if (repeat)
				repeat = false;
			else if (self.IsValid()) 
				self.Kill();
		}
	);
	EntFireByHandle(relay, "Trigger", "", delay, null, null);
	return relay;
}

function FireTimer(timer)
{
	if (timer && timer.IsValid())
	{
		timer.GetScriptScope().InputTrigger();
		KillTimer(timer);
	}
}

function KillTimer(timer)
{
	if (timer && timer.IsValid())
	{
		timer.TerminateScriptScope();
		timer.Kill();
	}
}

function IsEntityAlive(player)
{
	return GetPropInt(player, "m_lifeState") == 0;
}

function SetEntityParent(entity, parent, attachment = null)
{
	EntFireByHandle(entity, "SetParent", "!activator", -1, parent, null);
	if (attachment)
		EntFireByHandle(entity, "SetParentAttachment", attachment, -1, null, null);
}

_PostInputScope <- null;
_PostInputFunc  <- null;

function SetInputHook(entity, input, pre_func, post_func)
{
	entity.ValidateScriptScope();
	local scope = entity.GetScriptScope();
	if (post_func)
	{
		local wrapper_func = function() 
		{ 
			_PostInputScope = scope; 
			_PostInputFunc  = post_func;
			if (pre_func)
				return pre_func.call(scope);
			return true;
		};
		
		scope["Input" + input]           <- wrapper_func;
		scope["Input" + input.tolower()] <- wrapper_func;
	}
	else if (pre_func)
	{
		scope["Input" + input]           <- pre_func;
		scope["Input" + input.tolower()] <- pre_func;
	}
}

ROOT.setdelegate(
{
	_delslot = function(k)
	{
		if (_PostInputScope && k == "activator" && "activator" in this)
		{
			_PostInputFunc.call(_PostInputScope);
			_PostInputFunc = null;
		}
		
		rawdelete(k);
	}
});


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
	});
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
	});
}

function GetPlayerName(player)
{
    return GetPropString(player, "m_szNetname");
}

function HealPlayer(player, amount)
{
	local health = player.GetHealth();
	local max_health = player.GetMaxHealth();
	if (amount > max_health - health)
		amount = max_health - health;
	
	if (amount > 0)
	{
		player.SetHealth(health + amount);
		
		SendGlobalGameEvent("player_healonhit",
		{
			amount = amount,
			entindex = player.entindex(),
			weapon_def_index = -1,
		});
	}
}

function TogglePlayerWearables(player, toggle)
{
	for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
	{
		MarkForPurge(wearable);
		wearable.SetDrawEnabled(toggle);
	}
}

function KillWeapon(weapon)
{
	local wearable = GetPropEntity(weapon, "m_hExtraWearable");
	if (wearable)
	{
		MarkForPurge(wearable);
		wearable.Kill();
	}
	
	weapon.Kill();
}