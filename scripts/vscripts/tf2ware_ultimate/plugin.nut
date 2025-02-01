// by ficool22

function Ware_CheckPlugin()
{
	Ware_PluginVersionString = Convars.GetStr("ware_version")
	if (IsDedicatedServer() || Ware_PluginVersionString != null)
	{
		Ware_Plugin = true
		if (Ware_PluginVersionString == null)
		{
			local plugin_msg = "** TF2Ware Ultimate requires the SourceMod plugin installed on dedicated servers"
			ClientPrint(null, HUD_PRINTTALK, "\x07FF0000" + plugin_msg)
			printl(plugin_msg)
			Ware_NeedsPlugin = true
		}
		else
		{
			Ware_NeedsPlugin = false
			printl("\tVScript: TF2Ware Ultimate linked to SourceMod plugin")
			
			foreach (i, digit in split(Ware_PluginVersionString, "."))
				Ware_PluginVersion[i] = digit.tointeger()				
				
			// killswitch for security
			if (Ware_PluginVersion[0] <= 1 && Ware_PluginVersion[1] <= 2 && Ware_PluginVersion[2] <= 3)
			{
				local plugin_msg = "** You must update to the latest plugin version. TF2Ware Ultimate will not start until you update the plugin."
				ClientPrint(null, HUD_PRINTTALK, "\x07FF0000" + plugin_msg)
				printl(plugin_msg)
				Ware_NeedsPlugin = true
			}
			else
			{
				Ware_PluginLegacyEvents = Ware_PluginVersion[0] <= 1 && Ware_PluginVersion[1] <= 2 && Ware_PluginVersion[2] <= 1
			}
		}
	}
}

function Ware_CheckPluginOutdated()
{
	if (Ware_PluginVersionString == null)
		return
	
	Ware_PluginOutdated = Ware_PluginVersionString != WARE_PLUGINVERSION
	if (Ware_PluginOutdated)
	{
		local msg = format("** SourceMod plugin version is outdated. Expected version %s, got %s", WARE_PLUGINVERSION, Ware_PluginVersionString)
		ClientPrint(null, HUD_PRINTTALK, "\x07FF0000" + msg)
		printl(msg)
	}
}

function Ware_LinkPlugin()
{
	if (!("Ware_Plugin" in this))
	{
		Ware_Plugin <- false
		Ware_PluginVersion <- array(3, 9)
		Ware_PluginVersionString <- ""
		Ware_PluginOutdated <- false
		Ware_PluginLegacyEvents <- false
		Ware_NeedsPlugin <- false
		Ware_CheckPlugin()
		printl("\tVScript: TF2Ware Ultimate Started")
	}
	else if (Ware_NeedsPlugin)
	{
		Ware_CheckPlugin()
	}
	
	Ware_CheckPluginOutdated()
}