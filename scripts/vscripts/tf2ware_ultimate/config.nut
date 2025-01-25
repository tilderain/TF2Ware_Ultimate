function Ware_LoadConfigFile(file_name)
{
	// try load the config from "scriptdata" first
	local cfg_name = format("tf2ware_ultimate/%s.cfg", file_name)
	local file = FileToString(cfg_name)
	if (file)
	{
		return file
	}
	else
	{
		// if not found, load it from our default config
		// scriptdata cannot be read when packed into BSP, so it's stored as code
		local scope = {}
		IncludeScript(format("tf2ware_ultimate/default/%s", file_name), scope)
		
		// write out the default config to scriptdata for future usage
		StringToFile(cfg_name, scope.buffer)
		
		return scope.buffer
	}
}

function Ware_LoadConfigSettings()
{
	local settings_map = 
	{
		boss_threshold       = "Ware_BossThreshold"
		speedup_threshold    = "Ware_SpeedUpThreshold"
		speedup_interval     = "Ware_SpeedUpInterval"
		special_round_chance = "Ware_SpecialRoundChance"
		points_minigame      = "Ware_PointsMinigame"
		points_bossgame      = "Ware_PointsBossgame"
		bonus_points         = "Ware_BonusPoints"
	}
	
	local file = Ware_LoadConfigFile("settings")
	local lines = split(file, "\r\n", true)
	foreach (line in lines)
	{
		if (startswith(line, "//"))
			continue
		local keyvalue = split(line, " =", true)
		local key = keyvalue[0]
		if (key in settings_map)
		{
			local value = keyvalue[1]
			this[settings_map[key]] <- value.find(".") != null ? value.tofloat() : value.tointeger()
		}
	}
}

function Ware_LoadConfigList(file_name, list)
{
	local file = Ware_LoadConfigFile(file_name)
	local lines = split(file, "\r\n", true)
	foreach (line in lines)
	{
		if (startswith(line, "//"))
			continue
		list.append(line)
	}
}

function Ware_LoadConfigThemes()
{
	local file = Ware_LoadConfigFile("themes")
	compilestring(format("Ware_Themes<-[\n%s]", file))()
	
	Ware_InternalThemes <- []
	for (local i = Ware_Themes.len() - 1; i >= 0; i--)
	{
		local theme = Ware_Themes[i]
		if ("internal" in theme)
		{
			Ware_InternalThemes.append(theme)
			Ware_Themes.remove(i)
		}
	}
}

function Ware_LoadConfigMeleeAttributes()
{
	local file = Ware_LoadConfigFile("melee_attributes")
	compilestring(format("Ware_MeleeAttributeOverrides<-{\n%s}", file))()
}

function Ware_LoadConfig()
{
	Ware_Minigames         <- []
	Ware_Bossgames         <- []
	Ware_SpecialRounds     <- []
	Ware_FakeSpecialRounds <- []
	Ware_GameOverlays      <- []
	
	Ware_LoadConfigSettings()
	Ware_LoadConfigList("minigames", Ware_Minigames)
	Ware_LoadConfigList("bossgames", Ware_Bossgames)
	Ware_LoadConfigList("specialrounds", Ware_SpecialRounds)
	Ware_LoadConfigList("fake_specialrounds", Ware_FakeSpecialRounds)	
	Ware_LoadConfigList("overlays", Ware_GameOverlays)	
	Ware_LoadConfigThemes()
	Ware_LoadConfigMeleeAttributes()
}

// everytime music is changed AND the map is *publicly* updated
// this must be incremented to prevent caching errors
// if you change this make sure to update any sounds in level_sounds.txt too!
const WARE_MUSICVERSION = 2

// keep in sync with sourcemod plugin
const WARE_PLUGINVERSION = "1.2.0"

Ware_LoadConfig()