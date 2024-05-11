
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

if (RandomInt(0, 120) == 0)
	minigame.music = "beepblockskyway-twelve"

if (minigame.music == "beepblockskyway")
{
	tempo <- 120.0 // bpm
	bgm_offset <- 0.02
}
else
{
	tempo <- 140.0
	bgm_offset <- -0.1
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
	
	BeepBlock_FireInput(active_blocks, "Enable")
	BeepBlock_FireInput(inactive_blocks, "Disable")
	
	trigger.ValidateScriptScope()
	trigger.GetScriptScope().OnStartTouch <- OnEndzoneTouch
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	Ware_CreateTimer(function() {
		BeepBlock_Sequence()
		return (8.0 * beat)
	}, bgm_offset+(6.0 * beat))
}

function OnEndzoneTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
		Ware_PassPlayer(player, true)
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
	BeepBlock_FireInput(active_blocks, "Alpha", "200")
	
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
