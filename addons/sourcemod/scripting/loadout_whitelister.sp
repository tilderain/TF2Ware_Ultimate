#include <sdktools>
#include <dhooks>

#define SLOT_MELEE 2
#define SLOT_WEARABLES 7
#define SLOT_TAUNTS 11

ConVar mp_tournament;
ConVar mp_tournament_whitelist;
ConVar loadoutwhitelister_enable;

public bool script_allow_loadout = false;

DynamicHook g_DHook_CTFPlayerInitClass;
DynamicDetour g_DDetour_CTFPlayerGetLoadoutItem;

char g_SavedTournamentWhitelist[256];

public void LoadoutWhitelister_Start(GameData gamedata)
{
	g_DHook_CTFPlayerInitClass = DynamicHook.FromConf(gamedata, "CTFPlayer::InitClass");
	if (!g_DHook_CTFPlayerInitClass)
	{
		LogError("Failed to setup hook for CTFPlayer::InitClass");		
		return;
	}
	
	g_DDetour_CTFPlayerGetLoadoutItem = DynamicDetour.FromConf(gamedata, "CTFPlayer::GetLoadoutItem");
	if (!g_DDetour_CTFPlayerGetLoadoutItem)
	{
		LogError("Failed to setup detour for CTFPlayer::GetLoadoutItem");		
		return;
	}
	
	g_DDetour_CTFPlayerGetLoadoutItem.Enable(Hook_Pre, DHookPre_CTFPlayerGetLoadoutItem);
	
	mp_tournament = FindConVar("mp_tournament");
	mp_tournament_whitelist = FindConVar("mp_tournament_whitelist");
	mp_tournament.Flags = mp_tournament.Flags & ~(FCVAR_NOTIFY);	
	mp_tournament_whitelist.GetString(g_SavedTournamentWhitelist, sizeof(g_SavedTournamentWhitelist));
	mp_tournament_whitelist.SetString("cfg/tf2ware_ultimate/item_whitelist.cfg"); // TODO: don't hardcode this here?
	loadoutwhitelister_enable = CreateConVar("loadoutwhitelister_enable", "1", "");
	
	AddCommandListener(ListenerTournamentRestart, "mp_tournament_restart");
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
			LoadoutWhitelister_InitClient(client);
	}
}

public void LoadoutWhitelister_End(bool map_unload)
{
	mp_tournament.Flags = mp_tournament.Flags | (FCVAR_NOTIFY);	
	mp_tournament_whitelist.SetString(g_SavedTournamentWhitelist);
	
	if (g_DDetour_CTFPlayerGetLoadoutItem)
		g_DDetour_CTFPlayerGetLoadoutItem.Disable(Hook_Pre, DHookPre_CTFPlayerGetLoadoutItem);
	
	if (map_unload)
		RemoveCommandListener(ListenerTournamentRestart, "mp_tournament_restart");	
}

public void LoadoutWhitelister_InitClient(int client)
{
	if (g_DHook_CTFPlayerInitClass)
	{
		g_DHook_CTFPlayerInitClass.HookEntity(Hook_Pre, client, DHookPre_CTFPlayerInitClass);
		g_DHook_CTFPlayerInitClass.HookEntity(Hook_Post, client, DHookPost_CTFPlayerInitClass);
	}
}

static bool g_ReloadingWhitelist = false;
static bool g_InRestart = false;
static int g_PrevWPF = 0;

Action ListenerTournamentRestart(int client, const char[] command, int argc)
{
	if (g_ReloadingWhitelist)
	{
		if (g_InRestart)
		{
			GameRules_SetProp("m_bInWaitingForPlayers", g_PrevWPF);
			GameRules_SetProp("m_bAwaitingReadyRestart", 0);
			mp_tournament.SetInt(0, false, false);
			
			g_InRestart = false;
			g_ReloadingWhitelist = false;
			return Plugin_Handled;
		}
		
		g_InRestart = true;
		
		mp_tournament.SetInt(1, false, false);
		g_PrevWPF = GameRules_GetProp("m_bInWaitingForPlayers"); 
		GameRules_SetProp("m_bInWaitingForPlayers", 1);
	}
	
	return Plugin_Continue;
}

public void LoadoutWhitelister_ReloadWhitelist()
{
	LogMessage("Reloading item whitelist...");
	
	int gamerules = FindEntityByClassname(-1, "tf_gamerules");
	if (gamerules == -1)
	{
		LogMessage("No gamerules to reload whitelist with!");
		return;
	}
	
	g_ReloadingWhitelist = true;
	ServerCommand("mp_tournament_restart");
	ServerCommand("mp_tournament_restart"); // hacky but this isn't synchronous
}

static bool g_InitClass = false;
static int g_SavedTournamentValue = 0;

static MRESReturn DHookPre_CTFPlayerInitClass(int client)
{
	g_InitClass = true;
	
	if (loadoutwhitelister_enable.BoolValue)
	{
		g_SavedTournamentValue = mp_tournament.IntValue;
		mp_tournament.SetInt(1, false, false);
	}
	
	return MRES_Ignored;
}

static MRESReturn DHookPre_CTFPlayerGetLoadoutItem(int client, DHookReturn ret, DHookParam param)
{
	if (g_InitClass && loadoutwhitelister_enable.BoolValue && !script_allow_loadout)
	{
		int slot = param.Get(2);
		// remove weapons (except melee) and taunts, keep wearables (whitelist will kill those)
		// TODO: measure impact of having taunts
		if (slot == SLOT_MELEE || (slot >= SLOT_WEARABLES && slot < SLOT_TAUNTS))
		{
		}
		else
		{
			// makes inventory return a null item
			param.Set(2, -1);
		}
			
		// don't print failures
		param.Set(3, false);
		return MRES_ChangedHandled;
	}
	
	return MRES_Ignored;
}

static MRESReturn DHookPost_CTFPlayerInitClass(int client)
{
	g_InitClass = false;
	
	if (loadoutwhitelister_enable.BoolValue)
	{
		mp_tournament.SetInt(g_SavedTournamentValue, false, false);
	}
	
	return MRES_Ignored;
}