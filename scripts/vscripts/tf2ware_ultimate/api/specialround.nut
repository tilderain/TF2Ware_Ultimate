// by ficool2 and pokemonpasta

// Settings for a special round
class Ware_SpecialRoundData
{
	function constructor(table = null)
	{
		min_players      = 0
		convars          = {}
		reverse_text     = false
		allow_damage     = false
		force_collisions = false
		opposite_win     = false
		boss_count       = 1
		boss_threshold   = Ware_BossThreshold
		
		if (table)
		{
			foreach (key, value in table)
				this[key] = value
		}
	}
	
	// == Mandatory settings ==
	
	// Visual name
	name             		 = null
	// Who made this?
	// Unused for now but might be used for credits in the future
	author           		 = null
	// Description shown in chat
	description      		 = null
	
	// == Optional settings ==
	// Minimum amount of players needed to start, default is 0
	min_players      		 = null
	// Table of convars to set for this special round
	// Reverted to previous values after special round ends	
	convars          		 = null
	// Reverse all text! Default is false
	reverse_text     		 = null
	// Always allow damage, including between minigames, default is false
	allow_damage     		 = null
	// Always enable collisions between players, default is false
	force_collisions 		 = null
	// Inverted win condition, e.g. not passing means you win, default is false
	opposite_win			 = null
	// Amount of bosses to play, default is 1
	boss_count       		 = null
	// Amount of minigames played before a boss, default is Ware_BossThreshold in config.nut
	boss_threshold           = null
	
	// == Callbacks == 
	// If these functions exist in a special round's scope, they are passed to the appropriate points in the code.
	// Game events in a special round scope are also supported in the typical format (e.g. "OnGameEvent_player_builtobject(params)")
	// Note some of these callbacks replace crucial parts of the gameplay loop.
	// If the logic in these functions isn't replicated properly, gameplay may get stuck.
	// e.g. Normally Ware_Speedup calls Ware_BeginIntermission at the end.
	//      If you include OnSpeedup in the scope but don't call Ware_BeginIntermission or something else in the gameplay loop, the game will get stuck after speedup.
	
	// GetMinigame(is_boss)       - Replaces the minigame selection process in Ware_StartMinigame. Return a minigame name for it to be attempted to be selected.
	cb_get_minigame            = null
	// GetOverlay2()              - Replaces the default secondary overlay texture in Ware_ShowScreenOverlay2 (see player.nut). Return an overlay texture for it to be set.
	cb_get_overlay2            = null
	// GetPlayerRoll(player)      - Replaces the z value in player QAngles on spawn and teleport.
	cb_get_player_roll         = null
	// GetValidPlayers()          - Replaces Ware_GetValidPlayers, which is used when selecting players to play a minigame.
	// Return an array of players in this function and those players will be assigned to play a minigame and added to Ware_MinigamePlayers.
	cb_get_valid_players       = null
	// OnCalculateScore(data)     - Replaces score calculation at the end of a minigame.
	// This function is called for each player in Ware_MinigamePlayers, and passes that player's data each time.
	cb_on_calculate_score      = null
	// OnCalculateTopScorers(top_players) - Replaces assignment to Ware_MinigameTopScorers, which is used for assigning top scorer particle effects
	// and determining the winner at the end of the game. top_players is a reference to Ware_MinigameTopScorers, so append players to the passed array.
	cb_on_calculate_topscorers = null
	// OnDeclareWinners(top_players, top_score, winner_count) - Replaces winner declaration in Ware_GameOver. Passes some relevant information that might be used
	// for replacement info.
	cb_on_declare_winners      = null
	// OnPlayerDisconnect(params) - Called by OnGameEvent_player_disconnect, and passes its parameters.
	cb_on_player_disconnect	   = null
	// OnPlayerSpawn(player)      - Called by OnGameEvent_player_spawn and passes the player that spawned.
	cb_on_player_spawn         = null
	// OnPlayerInventory(player)  - Called by OnGameEvent_post_inventory_application. This happens when a player spawns, but is intended for manipulating loadouts.
	cb_on_player_inventory     = null
	// OnBeginIntermission(is_boss) - Replaces the logic in Ware_BeginIntermission. Note there are some debug functions that are always called.
	// This replaces a core part of the gameplay loop and if Ware_StartMinigame or another appropriate function isn't called, the game will stop.
	cb_on_begin_intermission   = null
	// OnMinigameStart()          - Called by Ware_StartMinigame when a minigame starts. This is after a minigame has been chosen, so you can refer to Ware_Minigame and similar.
	cb_on_minigame_start       = null
	// OnMinigameEnd()            - Called by Ware_EndMinigame when a minigame ends. This is before the minigame is cleaned up, so you can still refer to Ware_Minigame and similar.
	cb_on_minigame_end         = null
	// OnSpeedup()                - Called by Ware_Speedup and replaces the speedup logic in a similar rway to cb_on_begin_intermission.
	cb_on_speedup              = null
	// OnTakeDamage(params)       - Called by OnTakeDamage in main.nut and functions as normal.
	cb_on_take_damage          = null
	// OnUpdate()                 - Called by Ware_OnUpdate every frame.
	cb_on_update               = null
}

// Rolls and starts a special round
function Ware_BeginSpecialRound()
{
	Ware_BeginSpecialRoundInternal()
}

// Ends the current special round if present
function Ware_EndSpecialRound()
{
	Ware_EndSpecialRoundInternal()
}