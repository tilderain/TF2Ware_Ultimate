
minigame <- Ware_MinigameData
({
	name           = "Escape the Factory"
	author         = "pokemonPasta"
	description    = "Escape the Factory!"
	duration       = 80.0
	end_delay      = 1.1
	location       = "factory"
	music          = "escape_factory"
	fail_on_death  = true
	convars =
	{
		tf_avoidteammates = 0
	}
})

endzone <- FindByName(null, "plugin_Bossgame2_WinArea")

paths <-
[
	path1 <- ["erboss_p1a_block", "erboss_p1a_block_prop"],
	path2 <- ["erboss_p1a_direct", "erboss_p1a_directprop"]
]

path <- RandomElement(paths)

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_ENGINEER)
	
	endzone.ValidateScriptScope()
	endzone.GetScriptScope().OnStartTouch <- OnEndzoneTouch
	endzone.GetScriptScope().first <- true
	endzone.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	foreach(str in path)
	{
		for (local ent; ent = FindByName(ent, str);)
			EntityAcceptInput(ent, "Disable")
	}
}

function OnEndzoneTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid() && !Ware_IsPlayerPassed(player))
	{
		local hms = FloatToTimeHMS(Ware_GetMinigameTime())
		if (first)
		{
			Ware_ChatPrint(null, "{player} {color}reached the end first in {%d}:{%02d}!", 
				player, TF_COLOR_DEFAULT, hms.minutes, hms.seconds)
			first = false
		}
		else
		{
			Ware_ChatPrint(player, "{color}You reached the end in {%d}:{%02d}!", 
				TF_COLOR_DEFAULT, hms.minutes, hms.seconds)
		}
		
		Ware_PassPlayer(player, true)
		Ware_CreateTimer(@() Ware_ShowScreenOverlay(player, null), 0.02)
	}
}

function OnEnd()
{
	endzone.DisconnectOutput("OnStartTouch", "OnStartTouch")
	
	foreach(str in path)
	{
		for (local ent; ent = FindByName(ent, str);)
			EntityAcceptInput(ent, "Enable")
	}
}

function CheckEnd()
{
	local alive_players = Ware_GetAlivePlayers()
	local alive_count = alive_players.len()
	if (alive_count == 0)
		return true
		
	local passed_players = alive_players.filter(@(i, player) Ware_IsPlayerPassed(player))
	return passed_players.len() == alive_count
}
