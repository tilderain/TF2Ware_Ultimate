DEVELOPER_STEAMID3 <-
{
	"[U:1:53275741]"  : 1 // ficool2
	"[U:1:111328277]" : 1 // pokemonPasta
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
		Ware_ChatPrint(player, "Setting next {str} to '{str}'", name, ROOT[gamename])	
	else
		Ware_ChatPrint(player, "Forced {str} to '{str}'", name, ROOT[gamename])	
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
		Ware_ChatPrint(player, "Setting next theme to '{str}'", Ware_DebugNextTheme)
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
		Ware_ChatPrint(player, "Forced theme to '{str}'", Ware_DebugForceTheme)
	}
	"nextspecial": function(player, text)
	{
		local args = split(text, " ")
		if (args.len() >= 1)
			Ware_DebugNextSpecialRound = args[0]
		else
			Ware_DebugNextSpecialRound = ""
		Ware_ChatPrint(player, "Forced next special round to '{str}'", Ware_DebugNextSpecialRound)
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
		Ware_ChatPrint(player, "Restarting...")
	}
	"gameover" : function(player, text)
	{
		Ware_DebugGameOver = true
		Ware_ChatPrint(player, "Forcing game over...")		
	}
	"stop" : function(player, text)
	{
		Ware_DebugStop = true
		Ware_ChatPrint(player, "Stopping...")
	}
	"resume" : function(player, text)
	{
		Ware_DebugStop = false
		Ware_ChatPrint(player, "Resuming...")
	}
	"end" : function(player, text)
	{
		if (Ware_Minigame)
		{
			Ware_ChatPrint(player, "Ending current {str}..." Ware_Minigame.boss ? "bossgame" : "minigame")
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
			Ware_ChatPrint(player, "Arguments: [mini/boss/special] [name]")
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
			printl(target)
			if (target)
				Ware_GetPlayerData(target).score += args[arg].tointeger()
			else
				Ware_ChatPrint(player, "Player not found")
		}
		else
		{
			Ware_ChatPrint(player, "Arguments: [player name] <score>")
		}
	}
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
			local code = "return (@() " + text + ").bindenv(ROOT)()"
			printf("Player '%s' executed code: %s\n", GetPlayerName(player), code)
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
			Ware_ChatPrint(player, "Set timescale to {%g}", scale)
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
		local authors = []
		foreach(k, v in Ware_Authors)
		{
			if (authors.find(k) == null)
				authors.append(k)
		}
		authors.sort(@(a, b) Ware_Authors[b] <=> Ware_Authors[a])
		
		Ware_ChatPrint(player, Ware_Credits, COLOR_GREEN, TF_COLOR_DEFAULT, COLOR_GREEN, TF_COLOR_DEFAULT)
		
		ClientPrint(player, HUD_PRINTCONSOLE, "TF2Ware Ultimate Contributors:")
		foreach(author in authors)
			ClientPrint(player, HUD_PRINTCONSOLE, "* " + author)
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