foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps);
		
FindByClassname <- Entities.FindByClassname.bindenv(Entities);
FindByName      <- Entities.FindByName.bindenv(Entities);

SetConvarValue  <- Convars.SetValue.bindenv(Convars);
GetConvarValue  <- Convars.GetStr.bindenv(Convars);

function Lerp(t, A, B)
{
    return A + (B - A) * t;
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

function RunDelayedCode(code, delay)
{
	EntFireByHandle(World, "RunScriptCode", code, delay, null, null);
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

function IsEntityAlive(player)
{
	return GetPropInt(player, "m_lifeState") == 0;
}

function SetEntityParent(entity, parent)
{
	EntFireByHandle(entity, "SetParent", "!activator", -1, parent, null);
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


function PlaySoundOnClient(player, name, volume, pitch)
{
	EmitSoundEx(
	{
		sound_name = name,
		volume = volume
		pitch = pitch,
		entity = player,
		filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
	});
}

function PlaySoundOnAllClients(name, volume, pitch)
{
	EmitSoundEx(
	{
		sound_name = name,
		volume = volume
		pitch = pitch,
		filter_type = RECIPIENT_FILTER_GLOBAL
	});
}

function GetPlayerName(player)
{
    return GetPropString(player, "m_szNetname");
}