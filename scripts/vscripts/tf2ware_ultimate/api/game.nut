// by ficool2 and pokemonpasta

// Sets the current time scale multplier (default is 1.0)
// This will also shift the pitch of sounds
function Ware_SetTimeScale(timescale)
{
	Ware_SetTimeScaleInternal(timescale)
}

function Ware_GetTimeScale()
{
	return Ware_TimeScale
}

// Sets the intermission state
// This is the period between minigames
// The minigame is started when this is finished
function Ware_BeginIntermission(is_boss)
{
	return Ware_BeginIntermissionInternal(is_boss)
}

// Sets the boss state 
// Used when a boss is coming up
// This will then progress into the intermission state (and then start the boss)
function Ware_BeginBoss()
{
	Ware_BeginBossInternal()
}

// Sets the speedup state
// Used when the time scale increases
// This will progress into the intermission state
function Ware_Speedup()
{
	Ware_SpeedupInternal()
}

// Rolls a minigame and starts it
// The minigame ends after it's internal duration timer runs out, or an end condition is met
function Ware_StartMinigame(is_boss)
{
	Ware_StartMinigameInternal(is_boss)
}

// Ends the current minigame/bossgame if present
// This will progress to:
// - Game over, if the played minigame and bossgame count was exhausted
// - Boss, if the minigame count was exhausted
// - Speedup, if the minigame count matches the speed up threshold
// - Intermission, if none of the above are true
function Ware_EndMinigame()
{
	Ware_EndMinigameInternal()
}

// Sets the gameover state
// Sets the winners and losers depending on score, and ends the round
function Ware_GameOver()
{
	Ware_GameOverInternal()
}

// Gets the threshold before a boss is played
// Influenced by special rounds
function Ware_GetBossThreshold()
{
	if (Ware_SpecialRound)
		return Ware_SpecialRound.boss_threshold
	else
		return Ware_BossThreshold
}

// Gets the amount of bossgames to play
// Influenced by special rounds
function Ware_GetBossCount()
{
	if (Ware_SpecialRound)
		return Ware_SpecialRound.boss_count
	else
		return 1
}