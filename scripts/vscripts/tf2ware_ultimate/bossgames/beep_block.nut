
arenas <-
[
	"beepblockskyway_micro"
	"beepblockskyway_ultimate"
]

minigame <- Ware_MinigameData
({
	name           = "Beep Block Skyway"
	author         = "pokemonPasta"
	description    = "Get to the End!"
	custom_overlay = "get_end"
	duration       = 160.0
	end_delay      = 1.0
	location       = RandomElement(arenas)
	music          = "beepblockskyway"
	fail_on_death  = true
	no_collisions  = true
})

if (RandomInt(0, 128) == 0)
	minigame.music = "beepblockskyway-twelve"

if (minigame.music == "beepblockskyway")
{
	tempo <- 120.0 // bpm
	bgm_offset <- 0.028
}
else
{
	tempo <- 140.0
	bgm_offset <- -0.05
}

beat <- 60.0 * (1 / tempo)

beep_sound <- "tf2ware_ultimate/beep_block_beep.mp3"
swap_sound <- "tf2ware_ultimate/beep_block_door.mp3"
tele_sound <- "Building_Teleporter.Send"
PrecacheSound(beep_sound)
PrecacheSound(swap_sound)
PrecacheScriptSound(tele_sound)

green_blocks    <- []
yellow_blocks   <- []
active_blocks   <- RandomElement([green_blocks, yellow_blocks])
inactive_blocks <- active_blocks == green_blocks ? yellow_blocks : green_blocks

trigger <- FindByName(null, "plugin_Bossgame5_WinArea")
tele1   <- FindByName(null, "BeepBlock_Tele1")
tele2   <- FindByName(null, "BeepBlock_Tele2")

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_ENGINEER)
	
	// fixes tilting from fall damage on ramp near the end of _ultimate arena
	Ware_SetGlobalCondition(TF_COND_GRAPPLINGHOOK)
	
	// separate entities are needed to keep bounding box
	// within separate areas and not break visibility
	local ent = null
	do{
		ent = FindByName(ent, "beatblock_green")
		if (ent)
			green_blocks.append(ent)
	}
	while (ent)
	
	do{
		ent = FindByName(ent, "beatblock_yellow")
		if (ent)
			yellow_blocks.append(ent)
	}
	while (ent)
	
	BeepBlock_FireInput(green_blocks, "Alpha", "255")
	BeepBlock_FireInput(yellow_blocks, "Alpha", "255")
	
	BeepBlock_FireInput(active_blocks, "Enable")
	BeepBlock_FireInput(inactive_blocks, "Disable")
	
	trigger.ValidateScriptScope()
	trigger.GetScriptScope().OnStartTouch <- OnEndzoneTouch
	trigger.GetScriptScope().first <- true
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	tele1.ValidateScriptScope()
	tele1.GetScriptScope().OnStartTouch <- OnTele1Touch
	tele1.GetScriptScope().tele_sound <- tele_sound
	tele1.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	tele2.ValidateScriptScope()
	tele2.GetScriptScope().OnStartTouch <- OnTele2Touch
	tele2.GetScriptScope().tele_sound <- tele_sound
	tele2.ConnectOutput("OnStartTouch", "OnStartTouch")
	
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

function OnUpdate()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player
		SetPropEntity(player, "m_hGroundEntity", active_blocks[1])
	}
}

// no fall damage, but trigger_hurt uses fall damage so we check for that too
function OnTakeDamage(params)
{
	if ((params.damage_type & DMG_FALL) && params.inflictor.GetClassname() != "trigger_hurt")
		params.damage = 0.0
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

function BeepBlock_FireInput(target, action, params = "")
{
	if (typeof(target) == "array")
	{
		foreach(ent in target)
			EntFireByHandle(ent, action, params, -1, null, null)
	}
	else
		EntFireByHandle(target, action, params, -1, null, null)
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

function OnTele1Touch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		PlaySoundOnClient(player, tele_sound)
		Ware_AddPlayerAttribute(player, "increased jump height", 1.28, Ware_GetMinigameRemainingTime())
	}
}

function OnTele2Touch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		PlaySoundOnClient(player, tele_sound)
		Ware_AddPlayerAttribute(player, "increased jump height", 1.0, Ware_GetMinigameRemainingTime())
	}
}

function OnEnd()
{
	trigger.DisconnectOutput("OnStartTouch", "OnStartTouch")
	tele1.DisconnectOutput("OnStartTouch", "OnStartTouch")
	
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
