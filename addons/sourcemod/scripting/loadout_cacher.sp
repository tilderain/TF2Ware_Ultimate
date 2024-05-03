#include <sourcemod>
#include <sdktools>
#include <profiler>
#include <dhooks>
#include <tf2_stocks>

#define EF_BONEMERGE 1
#define EF_NODRAW 32
#define EF_BONEMERGE_FASTCULL 128

// Unused EFlag that signals player is cached (can be checked easily by VScript etc)
#define EFL_LOADOUT_CACHED 1073741824 // EFL_NO_PHYSCANNON_INTERACTION

#define TF_CLASS_FIRST 1
#define TF_CLASS_LAST  9

#define MAX_WEARABLES 8
#define MAX_WEAPONS 8

#define MAX_LOADOUT_WEARABLES 3

Handle g_SDKCall_CBasePlayerEquipWearable;
DynamicHook g_DHook_CTFPlayerInitClass;
ArrayList g_Queue_LoadoutCache;
Profiler g_Profiler_InitClass;
int g_PropOffset_EFlags;
int g_PropOffset_Effects;
int g_PropOffset_ModelIndexOverrides;
int g_ModelIndex_Empty;
int g_Entity_ScriptProxy;
bool g_LoadoutCacheParity;

enum struct LoadoutClassCache
{
	int cosmetic_modelindexs[MAX_LOADOUT_WEARABLES];
	int cosmetic_ids[MAX_LOADOUT_WEARABLES];
	int cosmetic_paints[MAX_LOADOUT_WEARABLES];
	int cosmetic_count;
	int melee_entref;
}
enum struct LoadoutCache
{
	int current_class;
	int saved_class;
	int cosmetic_entrefs[MAX_LOADOUT_WEARABLES];
	ArrayList cache_class; // TF_CLASS_LAST size
}
LoadoutCache g_ClientLoadoutCache[MAXPLAYERS + 1];

ConVar loadoutcacher_enable;
ConVar loadoutcacher_profile; 	

public void LoadoutCacher_Start(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBasePlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_SDKCall_CBasePlayerEquipWearable = EndPrepSDKCall();
	if (!g_SDKCall_CBasePlayerEquipWearable)
	{
		LogError("Failed to setup SDKCall for CBasePlayer::EquipWearable");			
		return;
	}
	
	g_DHook_CTFPlayerInitClass = DynamicHook.FromConf(gamedata, "CTFPlayer::InitClass");
	if (!g_DHook_CTFPlayerInitClass)
	{
		LogError("Failed to setup hook for CTFPlayer::InitClass");		
		return;
	}

	loadoutcacher_enable = CreateConVar("loadoutcacher_enable", "1", ""); // allows VScript to detect its loaded
	loadoutcacher_profile = CreateConVar("loadoutcacher_profile", "0", "Measure cost of loadout spawning");
	
	g_Queue_LoadoutCache = new ArrayList();
	g_LoadoutCacheParity = true;
	
	g_ModelIndex_Empty = PrecacheModel("models/empty.mdl", true);
	g_Entity_ScriptProxy = 0;
	
	for (int client = 1; client <= MaxClients; client++)
	{
		InitLoadoutCache(client);

		if (IsClientInGame(client))
			LoadoutCacher_InitClient(client);
	}
	
	HookEvent("player_spawn", LoadoutCacher_OnPlayerSpawnPre, EventHookMode_Pre);
}

public void LoadoutCacher_End()
{
	UnhookEvent("player_spawn", LoadoutCacher_OnPlayerSpawnPre, EventHookMode_Pre);
}

public void LoadoutCacher_OnGameFrame()
{
	// process every 2nd frame only
	g_LoadoutCacheParity = !g_LoadoutCacheParity;
	if (g_LoadoutCacheParity)
		return;
	
	if (!g_Queue_LoadoutCache || g_Queue_LoadoutCache.Length == 0)
		return;
	
	int client = g_Queue_LoadoutCache.Get(0);
	
	// if player switched themselves to spec, move them to back of the queue
	if ((GetClientTeam(client) & 2) == 0)
	{
		g_Queue_LoadoutCache.Erase(0);
		g_Queue_LoadoutCache.Push(client);
		return;
	}
	
	LoadoutCache cache;
	cache = g_ClientLoadoutCache[client];
	if (cache.current_class > TF_CLASS_LAST)
	{	
		for (int i = 0; i < MAX_LOADOUT_WEARABLES; i++)
		{
			int wearable = CreateEntityByName("tf_wearable");
			SetEntProp(wearable, Prop_Send, "m_nModelIndex", g_ModelIndex_Empty);
			SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", 1);
			DispatchSpawn(wearable);
			SDKCall(g_SDKCall_CBasePlayerEquipWearable, client, wearable);
			MarkEntityLoadoutCached(wearable);
			SetEntityDraw(wearable, false);
			cache.cosmetic_entrefs[i] = EntIndexToEntRef(wearable);		
		}
		
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", cache.saved_class);	
		
		g_ClientLoadoutCache[client] = cache;		
		g_Queue_LoadoutCache.Erase(0);
		MarkEntityLoadoutCached(client);	

		// remove all weapons, hats, they will never be given again
		ArrayList children = new ArrayList();
		
		int child = GetEntPropEnt(client, Prop_Data, "m_hMoveChild");
		while (IsValidEntity(child))
		{
			children.Push(child);
			child = GetEntPropEnt(child, Prop_Data, "m_hMovePeer");			
		}	
		
		for (int i = 0; i < children.Length; i++)
		{
			int entity = children.Get(i);
			
			if (IsEntityLoadoutCached(entity))
				continue;

			char classname[32];
			GetEntityClassname(entity, classname, sizeof(classname));

			if (strncmp(classname, "tf_wearable", 11, false) == 0
				|| strcmp(classname, "tf_powerup_bottle") == 0)
			{
				RemoveEntity(entity);
			}
			else if (strncmp(classname, "tf_weapon", 9, false) == 0)
			{
				int wearable = GetEntProp(entity, Prop_Send, "m_hExtraWearable");
				if (IsValidEntity(wearable))
					RemoveEntity(wearable);
				
				wearable = GetEntProp(entity, Prop_Send, "m_hExtraWearableViewModel");
				if (IsValidEntity(wearable))
					RemoveEntity(wearable);	
				
				RemoveEntity(entity);
			}
		}
		
		delete children;

		// respawn one last time as the original desired class		
		TF2_RespawnPlayer(client);			
	}
	else
	{
		if (cache.current_class == TF_CLASS_FIRST)
			cache.saved_class = GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass");
		
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", cache.current_class);
		TF2_RespawnPlayer(client);		
		
		LoadoutClassCache class_cache;
		cache.cache_class.GetArray(cache.current_class - 1, class_cache);
		
		// sourcemod still can't iterate CUtlVector props, sigh	
		int child = GetEntPropEnt(client, Prop_Data, "m_hMoveChild");
		int cosmetics[3] = { -1, -1, -1 };
		while (IsValidEntity(child))
		{
			char classname[32];
			GetEntityClassname(child, classname, sizeof(classname));
			if (strcmp(classname, "tf_wearable", false) == 0)
			{
				char modelname[128];
				GetEntPropString(child, Prop_Data, "m_ModelName", modelname, sizeof(modelname));		
				
				// ignore action wearables like dueling minigame
				if (modelname[0])
				{
					int modelindex = PrecacheModel(modelname, true);
					if (modelindex > 0)
					{		
						cosmetics[class_cache.cosmetic_count] = child;
						class_cache.cosmetic_modelindexs[class_cache.cosmetic_count] = modelindex;
						class_cache.cosmetic_ids[class_cache.cosmetic_count] = GetEntProp(child, Prop_Send, "m_iItemDefinitionIndex");
						// TODO paint
						class_cache.cosmetic_count++;
					}
				}				
			}
			
			if (class_cache.cosmetic_count >= 3)
				break;	
			
			child = GetEntPropEnt(child, Prop_Data, "m_hMovePeer");			
		}
		
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		if (IsValidEntity(melee))
		{
			for (int i = 0; i < MAX_WEAPONS; i++)
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
				if (weapon == melee)
				{
					MarkEntityLoadoutCached(weapon);
					// because children in hierarchy can be out of order
					// this is used to identify what class owns this melee (for vscript)
					SetEntProp(weapon, Prop_Data, "m_iHammerID", cache.current_class);
					class_cache.melee_entref = EntIndexToEntRef(weapon);					
					SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", -1, i);
					break;
				}	
			}
		}

		if (class_cache.cosmetic_count > 0)
		{		
			// allow vscript to access these cosmetics for its own caching purposes
			// current use case is to detect which cosmetics are hats by checking bones			
			
			if (!g_Entity_ScriptProxy)
			{
				g_Entity_ScriptProxy = CreateEntityByName("multisource");
				DispatchKeyValue(g_Entity_ScriptProxy, "classname", "point_commentary_viewpoint"); // preserve
			}

			for (int i = 0; i < 3; i++)
				SetEntPropEnt(g_Entity_ScriptProxy, Prop_Data, "m_rgEntities", cosmetics[i], i);
			SetVariantString("LoadoutCacherAddCosmetics");
			AcceptEntityInput(g_Entity_ScriptProxy, "CallScriptFunction");	
		}		
		
		cache.cache_class.SetArray(cache.current_class - 1, class_cache);
		cache.current_class++;
		g_ClientLoadoutCache[client] = cache;	
	}
}

void SetEntityDraw(int entity, bool draw)
{
	int effects = GetEntData(entity, g_PropOffset_Effects, 4);
	
	// Using SetEntProp instead of SetEntData to update networking state immediately
	if (draw)
		SetEntProp(entity, Prop_Send, "m_fEffects", effects & (~EF_NODRAW));
	else
		SetEntProp(entity, Prop_Send, "m_fEffects", effects | EF_NODRAW);
}

bool IsEntityLoadoutCached(int entity)
{
	return (GetEntData(entity, g_PropOffset_EFlags, 4) & EFL_LOADOUT_CACHED) != 0;
}

void MarkEntityLoadoutCached(int entity)
{
	int eflags = GetEntData(entity, g_PropOffset_EFlags, 4);
	SetEntData(entity, g_PropOffset_EFlags, eflags | EFL_LOADOUT_CACHED, 4, true);			
}

void InitLoadoutCache(int client)
{
	delete g_ClientLoadoutCache[client].cache_class;
	
	g_ClientLoadoutCache[client].current_class = TF_CLASS_FIRST;
	g_ClientLoadoutCache[client].cache_class = new ArrayList(sizeof(LoadoutClassCache));
	
	for (int i = 0; i < TF_CLASS_LAST; i++)
	{
		LoadoutClassCache class_cache;
		class_cache.cosmetic_count = 0;
		g_ClientLoadoutCache[client].cache_class.PushArray(class_cache);
	}
}

public void LoadoutCacher_InitClient(int client)
{
	if (g_PropOffset_EFlags <= 0)
	{
		g_PropOffset_EFlags = FindDataMapInfo(client, "m_iEFlags");
		if (g_PropOffset_EFlags <= 0)
			SetFailState("Failed to get entity m_iEFlags offset");			

		g_PropOffset_Effects = FindSendPropInfo("CBaseEntity", "m_fEffects");
		if (g_PropOffset_Effects <= 0)
			SetFailState("Failed to get entity m_fEffects offset");	

		g_PropOffset_ModelIndexOverrides = FindSendPropInfo("CBaseEntity", "m_nModelIndexOverrides");
		if (g_PropOffset_ModelIndexOverrides <= 0)
			SetFailState("Failed to get entity m_nModelIndexOverrides offset");			
	}
	
	if (g_DHook_CTFPlayerInitClass)
	{
		g_DHook_CTFPlayerInitClass.HookEntity(Hook_Pre, client, DHookPre_CTFPlayerInitClass);
		g_DHook_CTFPlayerInitClass.HookEntity(Hook_Post, client, DHookPost_CTFPlayerInitClass);
	}
}

public void LoadoutCacher_DisconnectClient(int client)
{
	if (g_Queue_LoadoutCache)
	{
		int idx = g_Queue_LoadoutCache.FindValue(client);
		if (idx != -1)
			g_Queue_LoadoutCache.Erase(idx);	
	}
	
	InitLoadoutCache(client);
}

public void LoadoutCacher_UpdateClient(int client)
{
	int classtype = view_as<int>(TF2_GetPlayerClass(client));	
	
	LoadoutCache cache;
	cache = g_ClientLoadoutCache[client];		
	
	LoadoutClassCache class_cache;
	cache.cache_class.GetArray(classtype - 1, class_cache);		
	
	for (int i = 0; i < MAX_LOADOUT_WEARABLES; i++)
	{
		int wearable = EntRefToEntIndex(cache.cosmetic_entrefs[i]);
		if (wearable > 0)
		{
			if (i < class_cache.cosmetic_count)
			{
				SetEntityDraw(wearable, true);
				
				int id = class_cache.cosmetic_ids[i];
				SetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex", id);					
				
				// instead of setting model, change the visual one on the client
				// avoids the server from having to setup new bone cache, physics, etc
				for (int j = 0; j < 4; j++)
				{
					int modelindex = class_cache.cosmetic_modelindexs[i];
					SetEntData(wearable, g_PropOffset_ModelIndexOverrides + j * 4, modelindex, 4, true);			
				}
			}
			else
			{
				SetEntityDraw(wearable, false);
				// for correct bodygroups
				SetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex", -1);		
			}
		}
	}
	
	// Need this to update bodygroups, normally InitClass would do this
	Event inventory_event = CreateEvent("post_inventory_application", true);
	inventory_event.SetInt("userid",  GetClientUserId(client));
	inventory_event.Fire();
}

public Action LoadoutCacher_OnPlayerSpawnPre(Event event, const char[] name, bool dontBroadcast)
{	
	if (loadoutcacher_enable.BoolValue)
	{
		int client = GetClientOfUserId(event.GetInt("userid", -1));
		int team = event.GetInt("team", 0);
		
		if (client > 0 && team != 0)
		{
			if (!IsEntityLoadoutCached(client))
			{
				if (g_Queue_LoadoutCache.FindValue(client) == -1)
					g_Queue_LoadoutCache.Push(client);	
				
				return Plugin_Handled;	
			}
		}
	}

	return Plugin_Continue;
}

static MRESReturn DHookPre_CTFPlayerInitClass(int client)
{
	if (IsEntityLoadoutCached(client))
	{	
		LoadoutCacher_UpdateClient(client);
		return MRES_Supercede;
	}
	
	if (loadoutcacher_profile.BoolValue)
	{
		g_Profiler_InitClass = new Profiler();
		g_Profiler_InitClass.Start();
	}

	return MRES_Ignored;
}

static MRESReturn DHookPost_CTFPlayerInitClass(int client)
{
	if (IsEntityLoadoutCached(client))
		return MRES_Supercede;
	
	if (loadoutcacher_profile.BoolValue)
	{
		char name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name));
						
		g_Profiler_InitClass.Stop();
		float time = g_Profiler_InitClass.Time;
		LogMessage("Client '%s' took %.4f ms to spawn loadout", name, time * 1000.0);
		delete g_Profiler_InitClass;
	}
	
	return MRES_Ignored;
}