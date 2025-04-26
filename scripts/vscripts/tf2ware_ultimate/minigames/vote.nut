
mode     <- RandomInt(0, 1)

minigame <- Ware_MinigameData
({
	name           = "Vote"
	author         = ["tilderain"]
	description    = "Stop the count!"
	duration       = 4.0
	music          = "clumsy"
	custom_overlay = mode == 0 ? "vote_yes": "vote_no"
	convars = {
		sv_allow_votes = 1
		sv_vote_holder_may_vote_no = 1
		sv_vote_issue_scramble_teams_cooldown = 0
	}
})

function OnPick()
{
	//return !activevote
	return true
}

function OnStart()
{
	SendGlobalGameEvent("vote_started", 
	{
		issue = "#L4D_TargetID_Player",
		param1 = "Is gaben fat?",
		team = 0,
		initiator = 0,
	})

	SendGlobalGameEvent("vote_options", 
	{
		count = 5,
		option1 = "test",
		voteidx = 1,
	})

	SendToServerConsole("callvote ScrambleTeams")
	SendToConsole("callvote ScrambleTeams")
}

function OnVoteCast(player, vote_option, params)
{
	Ware_ChatPrint(null, "{int}{int}{int}", player, vote_option, params)
}