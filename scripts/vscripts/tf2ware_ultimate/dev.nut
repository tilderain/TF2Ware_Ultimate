DEVELOPER_STEAMID3 <-
{
	"[U:1:53275741]"  : 1 // ficool2
	"[U:1:111328277]" : 1 // pokemonPasta
}

function Ware_DevCommandTitle(player)
{
	if (GetPlayerSteamID3(player) in DEVELOPER_STEAMID3)
		return "Developer"
	else if (player == Ware_ListenHost)
		return "Host"
	else
		return "Admin"
}

function Ware_DevCommandForceMinigame(player, text, is_boss, once)
{
	local gamename = is_boss ? "Ware_DebugForceBossgame" : "Ware_DebugForceMinigame"
	local args = split(text, " ")
	
	if (args.len() >= 1)
		ROOT[gamename] = args[0]
	else
		ROOT[gamename] = ""
		
	ROOT[gamename + "Once"] = once	
	
	local name = is_boss ? "bossgame" : "minigame"
	if (once)
		Ware_ChatPrint(player, "{str} set next {str} to '{str}'", Ware_DevCommandTitle(player), name, ROOT[gamename])	
	else
		Ware_ChatPrint(player, "{str} forced {str} '{str}'", Ware_DevCommandTitle(player), name, ROOT[gamename])	
}

Ware_DevCommands <-
{
	"nextminigame"  : function(player, text) { Ware_DevCommandForceMinigame(player, text, false, true)  }
	"nextbossgame"  : function(player, text) { Ware_DevCommandForceMinigame(player, text, true, true)   }
	"forceminigame" : function(player, text) { Ware_DevCommandForceMinigame(player, text, false, false) }
	"forcebossgame" : function(player, text) { Ware_DevCommandForceMinigame(player, text, true, false)  }
	"nexttheme": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
		{
			local theme = args[0]
			if (theme == "default" || theme == "tf2ware_classic")
				Ware_DebugNextTheme = "_" + theme
			else
				Ware_DebugNextTheme = theme
		}
		else
			Ware_DebugNextTheme = ""
		Ware_ChatPrint(null, "{str} forced next theme to '{str}'", Ware_DevCommandTitle(player), Ware_DebugNextTheme)
	}
	"forcetheme": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
		{
			local theme = args[0]
			if (theme == "default" || theme == "tf2ware_classic")
				Ware_DebugForceTheme = "_" + theme
			else
				Ware_DebugForceTheme = theme
		}
		else
			Ware_DebugForceTheme = ""
		Ware_ChatPrint(null, "{str} forced theme to '{str}'", Ware_DevCommandTitle(player), Ware_DebugForceTheme)
	}
	"nextspecial": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
		{
			if (args.len() >= 2)
			{
				Ware_DebugNextSpecialRound = "double_trouble"
				Ware_DebugNextSpecialRound2 = [args[0], args[1]]
			}
			else
			{
				Ware_DebugNextSpecialRound = args[0]
			}
		}
		else
		{
			Ware_DebugNextSpecialRound = ""
		}
		Ware_ChatPrint(null, "{str} forced next special round to '{str}'", Ware_DevCommandTitle(player), Ware_DebugNextSpecialRound)
	}
	"shownext": function(player, text)
	{
		local vars = [
			"Ware_DebugForceMinigame",
			"Ware_DebugForceMinigameOnce",
			"Ware_DebugForceBossgame",
			"Ware_DebugForceBossgameOnce",
			"Ware_DebugNextTheme",
			"Ware_DebugForceTheme",
			"Ware_DebugNextSpecialRound"
		]
		foreach(var in vars)
		{
			local value = ROOT[var]
			if (typeof(value) == "string")
				ClientPrint(player, HUD_PRINTCONSOLE, format("* %s = \"%s\"", var, value))
			else if (typeof(value) == "bool")
				ClientPrint(player, HUD_PRINTCONSOLE, format("* %s = %s", var, value ? "true" : "false"))
		}
		Ware_ChatPrint(player, "Values printed to console.")
	}
	"restart" : function(player, text)
	{
		SetConvarValue("mp_restartgame_immediate", 1)
		// TODO these should be "host" or "admin" if a non-dev executes it
		Ware_ChatPrint(null, "{str} has forced a restart", Ware_DevCommandTitle(player))
	}
	"gameover" : function(player, text)
	{
		Ware_DebugGameOver = true
		Ware_ChatPrint(null, "{str} has forced a game over", Ware_DevCommandTitle(player))		
	}
	// I never remember which word is the right one, so let's have both
	"stop" : function(player, text)
	{
		Ware_DebugStop = true
		Ware_ChatPrint(null, "{str} has forced the game to pause", Ware_DevCommandTitle(player))
	}
	"pause" : function(player, text)
	{
		Ware_DebugStop = true
		Ware_ChatPrint(null, "{str} has forced the game to pause", Ware_DevCommandTitle(player))
	}
	"resume" : function(player, text)
	{
		Ware_DebugStop = false
		Ware_ChatPrint(null, "{str} has resumed the game", Ware_DevCommandTitle(player))
	}
	"end" : function(player, text)
	{
		if (Ware_Minigame)
		{
			Ware_ChatPrint(null, "{str} has ended the current {str}...", 
				Ware_DevCommandTitle(player), Ware_Minigame.boss ? "bossgame" : "minigame")
			Ware_EndMinigame()
		}
		else
		{
			Ware_ChatPrint(player, "No minigame is currently running.")
		}
	}
	"remove": function(player, text)
	{
		local remove_target = function(target, arrs)
		{
			local removals = 0
			foreach(arr in arrs)
			{
				local idx = arr.find(target)
				if (idx != null)
				{
					arr.remove(idx)
					removals++
				}
			}
			if (removals > 0)
				Ware_ChatPrint(player, "Successfully removed {str} from {int} array{str}", target, removals, removals == 1 ? "" : "s")
			else
				Ware_ChatPrint(player, "Failed to remove {str} from any arrays", target)
		}
		
		local args = split(text, " ")
		if (args.len() > 0)
		{
			local target = args[1]
			switch (args[0]) {
				case "mini":
					remove_target(target, [Ware_Minigames, Ware_MinigameRotation])
					break
				case "boss":
					remove_target(target, [Ware_Bossgames, Ware_BossgameRotation])
					break
				case "special":
					remove_target(target, [Ware_SpecialRounds, Ware_SpecialRoundRotation])
					break
			}
		}
		else
		{
			Ware_ChatPrint(player, "Arguments: [mini/boss/special] [name]")
		}
	}
	"givescore" : function(player, text)
	{
		local args = split(text, " ", false)
		if (args.len() > 0)
		{
			local arg = 0
			local target = player
			if (args.len() > 1)
				target = Ware_FindPlayerByName(args[arg++])
			if (target)
			{
				local points = args[arg].tointeger()
				Ware_ChatPrint(player, "Gave {int} points to {player}", points, target)
				if (target != player)
					Ware_ChatPrint(target, "{str} has given you {int} points", Ware_DevCommandTitle(player), points)
				Ware_GetPlayerData(target).score += points
			}
			else
			{
				Ware_ChatPrint(player, "Player not found")
			}
		}
		else
		{
			Ware_ChatPrint(player, "Arguments: [player name] <score>")
		}
	}
	// TODO remove this on release
	"run" : function(player, text)
	{
		try
		{
			local quotes = split(text, "'")
			local quote_len = quotes.len() - 1
			if (quote_len > 0)
			{
				text = ""
				foreach (i, quote in quotes)
				{
					text += quote
					if (i != quote_len)
						text += "\""
				}		
			}
			local code = "return (function() {" + text + "}).call(ROOT)"
			printf("[TF2Ware] %s '%s' executed code: %s\n", Ware_DevCommandTitle(player), GetPlayerName(player), code)
			local ret = compilestring(code)()
			ClientPrint(player, HUD_PRINTTALK, "\x07FFFFFFRETURN: " + ret)
		}
		catch (e)
		{
			ClientPrint(player, HUD_PRINTTALK, "\x07FF0000ERROR: " + e)
		}	
	}
	"timescale" : function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
		{
			local scale = args[0].tofloat()
			Ware_SetTimeScale(scale)
			Ware_ChatPrint(null, "{str} has forced timescale to {%g}", Ware_DevCommandTitle(player), scale)
		}
		else		
		{
			Ware_ChatPrint(player, "Missing required scale parameter")
		}
	}
	"help" : function(player, text)
	{
		local cmds = []
		foreach (name, func in Ware_DevCommands)
			if (name != "help")
				cmds.append(name)
		foreach(name, func in Ware_PublicCommands)
			if (name != "help" && !(name in Ware_DevCommands))
				cmds.append(name)
		cmds.sort(@(a, b) a <=> b)
		foreach (name in cmds)
			ClientPrint(player, HUD_PRINTCONSOLE, "* " + name)
		Ware_ChatPrint(player, "See console for list of commands")
	}
}

Ware_PublicCommands <-
{
	"credits": function(player, text)
	{
		Ware_ChatPrint(player, 
			"{color}TF2Ware{color} Ultimate{color} by ficool2 and pokemonPasta, based on {color}TF2Ware Universe{color} by SLAG.TF, {color}MicroTF2{color} by Gemidyne and {color}TF2Ware v2{color} by TonyBaretta. See console for full list.", 
			COLOR_DARKBLUE, COLOR_LIGHTRED, TF_COLOR_DEFAULT, COLOR_GREEN, TF_COLOR_DEFAULT, COLOR_GREEN, TF_COLOR_DEFAULT, COLOR_GREEN, TF_COLOR_DEFAULT)
		
		ClientPrint(player, HUD_PRINTCONSOLE, "TF2Ware Ultimate Contributors:")
		
		local all_credits = []
		foreach (author, credits in Ware_Authors)
			all_credits.append([author].extend(credits))
		all_credits.sort(@(a, b) a[0].tolower() <=> b[0].tolower())
						
		foreach (credits in all_credits)
		{
			local author = credits.remove(0)
			local text = ""
			local last = credits.len() - 1
			foreach (i, credit in credits)
			{
				text += credit
				if (i < last)
					text += ", "
			}
			ClientPrint(player, HUD_PRINTCONSOLE, format("* %s - %s", author, text))
		}
	}
	"help" : function(player, text)
	{
		local cmds = []
		foreach (name, func in Ware_PublicCommands)
			if (name != "help")
				cmds.append(name)
			
		cmds.sort(@(a, b) a <=> b)
		foreach (name in cmds)
			ClientPrint(player, HUD_PRINTCONSOLE, "* " + name)
		Ware_ChatPrint(player, "See console for list of commands")
	}
}