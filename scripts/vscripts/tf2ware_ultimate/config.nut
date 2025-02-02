Ware_CfgPath <- "tf2ware_ultimate/%s.cfg"

function Ware_LoadConfigFile(file_name)
{
	// try load the config from "scriptdata" first
	local cfg_name = format(Ware_CfgPath, file_name)
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
	// default values (should match settings.cfg)
	// incase they aren't present there
	Ware_BossThreshold        <- 20
	Ware_SpeedUpThreshold     <- 5
	Ware_SpeedUpInterval      <- 0.15
	Ware_SpecialRoundInterval <- 3
	Ware_PointsMinigame       <- 1
	Ware_PointsBossgame       <- 5
	Ware_BonusPoints          <- 0
		
	local settings_map = 
	{
		boss_threshold         = "Ware_BossThreshold"
		speedup_threshold      = "Ware_SpeedUpThreshold"
		speedup_interval       = "Ware_SpeedUpInterval"
		// removed: special_round_chance = "Ware_SpecialRoundChance" 
		specialround_interval  = "Ware_SpecialRoundInterval"
		points_minigame        = "Ware_PointsMinigame"
		points_bossgame        = "Ware_PointsBossgame"
		bonus_points           = "Ware_BonusPoints"
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
			this[settings_map[key]] = value.find(".") != null ? value.tofloat() : value.tointeger()
		}
	}
}

function Ware_LoadConfigList(file_name, list, expected_version = 0, version_callback = null)
{
	local file = Ware_LoadConfigFile(file_name)
	local lines = split(file, "\r\n", true)

	// legacy configs had no VERSION header
	local version = 0
	if (lines.len() >= 1)
	{
		if (startswith(lines[0], "VERSION "))
			version = lines.remove(0).slice(8).tointeger()
	}
	
	if (version < expected_version && version_callback)
	{
		version_callback(version, lines)
		Ware_WriteConfigList(file_name, expected_version, lines)
	}	
	
	foreach (line in lines)
	{
		if (!startswith(line, "//"))
			list.append(line)
	}

	return version
}

function Ware_LoadConfigMinigames()
{
	// bump this when new entries are added, and fill in the loop below
	local latest_version = 0
	Ware_LoadConfigList("minigames", Ware_Minigames, latest_version, function(version, lines)
	{
		for (local v = version + 1; v <= latest_version; v++)
		{
			//if (v == 1)
			//	lines.append("test")
		}
	})
}

function Ware_LoadConfigBossgames()
{
	// bump this when new entries are added, and fill in the loop below
	local latest_version = 0
	Ware_LoadConfigList("bossgames", Ware_Bossgames, latest_version, function(version, lines)
	{
		for (local v = version + 1; v <= latest_version; v++)
		{
			//if (v == 1)
			//	lines.append("test")
		}
	})
}

function Ware_LoadConfigSpecialRounds()
{
	// bump this when new entries are added, and fill in the loop below
	local latest_version = 1
	Ware_LoadConfigList("specialrounds", Ware_SpecialRounds, latest_version, function(version, lines)
	{
		for (local v = version + 1; v <= latest_version; v++)
		{
			if (v == 1)
				lines.append("hale")
		}
	})
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
	Ware_LoadConfigMinigames()
	Ware_LoadConfigBossgames()
	Ware_LoadConfigSpecialRounds()
	Ware_LoadConfigList("fake_specialrounds", Ware_FakeSpecialRounds)	
	Ware_LoadConfigList("overlays", Ware_GameOverlays)	
	Ware_LoadConfigThemes()
	Ware_LoadConfigMeleeAttributes()
}

function Ware_WriteConfigList(file_name, version, lines)
{	
	local cfg_name = format(Ware_CfgPath, file_name)
	local buffer = "VERSION " + version
	foreach (line in lines)
		buffer += line + "\n"
	StringToFile(cfg_name, buffer)
}

// everytime music is changed AND the map is *publicly* updated
// this must be incremented to prevent caching errors
// if you change this make sure to update any sounds in level_sounds.txt too!
const WARE_MUSICVERSION = 2

// keep in sync with sourcemod plugin
WARE_PLUGINVERSION <- [1, 2, 5]

Ware_LoadConfig()