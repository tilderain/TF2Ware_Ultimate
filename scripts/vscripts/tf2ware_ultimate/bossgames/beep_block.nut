
minigame <- Ware_MinigameData
({
	name           = "Beep Block Skyway"
	author         = "pokemonPasta"
	description    = "Get to the End!"
	custom_overlay = "get_end"
	duration       = 160.0
	end_delay      = 1.0
	location       = "beepblockskyway"
	music          = "beepblockskyway"
	fail_on_death  = true
	no_collisions  = true
})

if (RandomInt(0, 128) == 0)
	minigame.music = "beepblockskyway-twelve"

if (minigame.music == "beepblockskyway")
{
	tempo <- 120.0 // bpm
	bgm_offset <- 0.029
}
else
{
	tempo <- 140.0
	bgm_offset <- -0.05
}

beat <- 60.0 * (1 / tempo)

beep_sound <- "tf2ware_ultimate/beep_block_beep.mp3"
swap_sound <- "tf2ware_ultimate/beep_block_door.mp3"
PrecacheSound(beep_sound)
PrecacheSound(swap_sound)

green_blocks    <- FindByName(null, "beatblock_green")
yellow_blocks   <- FindByName(null, "beatblock_yellow")
active_blocks   <- RandomElement([green_blocks, yellow_blocks])
inactive_blocks <- active_blocks == green_blocks ? yellow_blocks : green_blocks

trigger <- FindByName(null, "plugin_Bossgame5_WinArea")

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_ENGINEER)
	
	BeepBlock_FireInput(green_blocks, "Alpha", "255")
	BeepBlock_FireInput(yellow_blocks, "Alpha", "255")
	
	BeepBlock_FireInput(active_blocks, "Enable")
	BeepBlock_FireInput(inactive_blocks, "Disable")
	
	trigger.ValidateScriptScope()
	trigger.GetScriptScope().OnStartTouch <- OnEndzoneTouch
	trigger.GetScriptScope().first <- true
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	// using return in the timer for each subsequent sequence seems to add up a lot of processing delays over time
	// instead, we create all the sequences at the start, offset every 2 bars using i
	// this has more consistent timing, though it is a bit less flexible
	for (local i = 0; i < ceil(minigame.duration / (8.0 * beat)); i++)
	{
		Ware_CreateTimer(function() {
			BeepBlock_Sequence()
		}, bgm_offset + (6.0 * beat) + i * (8.0 * beat))
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
	}
}

function BeepBlock_Sequence()
{
	local i = 0
	Ware_CreateTimer(function() {
		if (i++ < 3)
		{
			PlaySoundOnAllClients(beep_sound, 0.6)
			BeepBlock_Beep()
			return beat
		}
		else
		{
			PlaySoundOnAllClients(swap_sound)
			BeepBlock_Swap()
		}
	}, 0.0)
}

function BeepBlock_Beep()
{
	BeepBlock_FireInput(active_blocks, "Alpha", "210")
	
	Ware_CreateTimer(function() {
		BeepBlock_FireInput(active_blocks, "Alpha", "255")
	}, (beat / 2.0))
}

function BeepBlock_Swap()
{
	BeepBlock_FireInput(active_blocks, "Disable")
	BeepBlock_FireInput(inactive_blocks, "Enable")
	
	active_blocks <- inactive_blocks
	inactive_blocks <- active_blocks == green_blocks ? yellow_blocks : green_blocks
}

// note: replace with global fire input function if one is made in util.nut
function BeepBlock_FireInput(entity, action, params = "")
{
	EntFireByHandle(entity, action, params, -1, null, null)
}

function OnEnd()
{
	trigger.DisconnectOutput("OnStartTouch", "OnStartTouch")
	
	BeepBlock_FireInput(green_blocks, "Alpha", "255")
	BeepBlock_FireInput(yellow_blocks, "Alpha", "255")
}

function CheckEnd()
{
	return BeepBlock_CheckEnd()
}

function BeepBlock_CheckEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (IsEntityAlive(player) && !Ware_IsPlayerPassed(player))
			return false
	}
	
	return true
}
