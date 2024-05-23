
// TODO:
//		- overall make the jumping on ramp more intuitive
//		- fix specific issues with ramp
//			- sometimes randomly stop
//			- can't jump if you crouch
//			- sometimes you "jump" but you dont actually go up in any way

arenas <-
[
	"beepblockskyway_micro"
	//"beepblockskyway_ultimate"
]

minigame <- Ware_MinigameData
({
	name           = "Beep Block Skyway"
	author         = "pokemonPasta"
	description    = "Get to the End!"
	custom_overlay = "get_end"
	duration       = 160.0
	end_delay      = 1.1
	location       = RandomElement(arenas)
	music          = "beepblockskyway"
	fail_on_death  = true
	no_collisions  = true
})

// variables
tempo            <- 0.0
tempo_increase   <- 1.2 // after interrupt
beat             <- 0.0
bgm_offset       <- 0.0
interrupted      <- false
interrupt_timer  <- 60
ramp_speed_limit <- 600 // velocity in any axis. probably hu/s but idk. not overall magnitude.

// audio
if (RandomInt(0, 128) == 0)
	minigame.music = "beepblockskyway-twelve"

beep_sound <- "tf2ware_ultimate/beep_block_beep.mp3"
swap_sound <- "tf2ware_ultimate/beep_block_door.mp3"
hurryup_sound <- "tf2ware_ultimate/hurryup.mp3"
tele_sound <- "Building_Teleporter.Send"
PrecacheSound(beep_sound)
PrecacheSound(swap_sound)
PrecacheSound(hurryup_sound)
PrecacheScriptSound(tele_sound)

// brushes
green_blocks    <- []
yellow_blocks   <- []
active_blocks   <- RandomElement([green_blocks, yellow_blocks])
inactive_blocks <- active_blocks == green_blocks ? yellow_blocks : green_blocks

// trigger brushes
endzone <- FindByName(null, "plugin_Bossgame5_WinArea")
tele1   <- FindByName(null, "BeepBlock_Tele1")
tele2   <- FindByName(null, "BeepBlock_Tele2")
ramp    <- FindByName(null, "BeepBlock_RampTrigger")

function OnStart()
{
	if (minigame.music == "beepblockskyway")
	{
		BeepBlock_SetTempo(120.0)
		bgm_offset = 0.028
	}
	else
	{
		BeepBlock_SetTempo(140.0)
		bgm_offset = -0.097
	}
	
	Ware_SetGlobalLoadout(TF_CLASS_ENGINEER)
	
	// fixes tilting from fall damage on ramp near the end of _ultimate arena
	Ware_SetGlobalCondition(TF_COND_GRAPPLINGHOOK)
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.on_ramp <- false
	}
	
	
	// separate entities are needed to keep bounding box within separate areas and not break visibility
	// these do/while loops append all beatblocks to their appropriate array, and then BeepBlock_FireInput
	// checks for array and fires across all entities in array
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
	
	endzone.ValidateScriptScope()
	endzone.GetScriptScope().OnStartTouch <- OnEndzoneTouch
	endzone.GetScriptScope().first <- true
	endzone.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	tele1.ValidateScriptScope()
	tele1.GetScriptScope().OnStartTouch <- OnTele1Touch
	tele1.GetScriptScope().tele_sound <- tele_sound
	tele1.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	tele2.ValidateScriptScope()
	tele2.GetScriptScope().OnStartTouch <- OnTele2Touch
	tele2.GetScriptScope().tele_sound <- tele_sound
	tele2.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	ramp.ValidateScriptScope()
	ramp.GetScriptScope().OnStartTouch <- OnRampTouch
	ramp.GetScriptScope().OnEndTouch <- OnEndRampTouch
	ramp.ConnectOutput("OnStartTouch", "OnStartTouch")
	ramp.ConnectOutput("OnEndTouch", "OnEndTouch")
	
	// using return in the timer for each subsequent sequence seems to add up a lot of processing delays over time
	// instead, we create all the sequences at the start, offset every 2 bars using i
	// this has more consistent timing, though it is a bit less flexible
	local sequence_count = ceil(minigame.duration / (8.0 * beat))
	for (local i = 0; i < sequence_count; i++)
	{
		Ware_CreateTimer(function() {
			if (!interrupted)
				BeepBlock_Sequence()
		}, bgm_offset + (6.0 * beat) + i * (8.0 * beat))
	}
}

function OnUpdate()
{
	if (((Ware_MinigamePlayers.len() > 1 && !endzone.GetScriptScope().first) || floor(Ware_GetMinigameRemainingTime()) == 30.0) && !interrupted)
		BeepBlock_Interrupt()
	
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player
		local minidata = Ware_GetPlayerMiniData(player)
		
		if (minidata.on_ramp && !BeepBlock_ActiveBlockBelow(player))
				player.RemoveCond(TF_COND_HALLOWEEN_SPEED_BOOST)
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

function BeepBlock_Interrupt()
{
	if (interrupted)
		return
	
	interrupted = true
	
	Ware_PlayMinigameSound(null, minigame.music, SND_STOP)
	Ware_ShowGlobalScreenOverlay("hud/tf2ware_ultimate/minigames/hurry_up")
	PlaySoundOnAllClients(hurryup_sound)
	
	Ware_CreateTimer(function() {
		PlaySoundOnAllClients(format("tf2ware_ultimate/v%d/music_bossgame/%s.mp3", WARE_MUSICVERSION, minigame.music),
		1.0, 100 * Ware_GetPitchFactor() * tempo_increase)
		
		BeepBlock_SetTempo(tempo * tempo_increase)
		
		local sequence_count = ceil(Ware_GetMinigameRemainingTime() / (8.0 * beat))
		for (local i = 0; i < sequence_count; i++)
		{
			Ware_CreateTimer(function() {
				BeepBlock_Sequence()
			}, bgm_offset * tempo_increase + (6.0 * beat) + i * (8.0 * beat))
		}
		
		interrupt_timer = Min(60, Round(Ware_GetMinigameRemainingTime()).tointeger())
		
		Ware_CreateTimer(function() {
			--interrupt_timer
			if (interrupt_timer >= 0)
			{
				local string = interrupt_timer >= 10 ? format("0:%s", interrupt_timer.tostring()) : format("0:0%s", interrupt_timer.tostring())
				Ware_ShowMinigameText(null, string, "255 255 0", -1.0, 0.3)
				return 1.0
			}
			else
				Ware_ShowMinigameText(null, "")
		}, 0.0)
	}, 3.0)
	
}

function BeepBlock_SetTempo(desired_tempo)
{
	tempo = desired_tempo
	beat = 60.0 / tempo
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

function BeepBlock_ActiveBlockBelow(player)
{
	local trace = {
		start = player.GetOrigin()
		end = player.GetOrigin() + Vector(0, 0, -100)
		hullmin = player.GetPlayerMins()
		hullmax = player.GetPlayerMaxs()
		mask = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_GRATE)
	}
	
	TraceHull(trace)
	
	return (trace.hit && trace.enthit.GetClassname() == "func_brush")
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
		player.RemoveCustomAttribute("increased jump height")
	}
}

function OnRampTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.on_ramp <- true
		
		// adding and removing this resets the "extra jump" noise so the pitch doesn't go out of bounds
		player.AddFlag(FL_ONGROUND)
		
		player.AddCond(TF_COND_HALLOWEEN_SPEED_BOOST)
		player.RemoveCond(TF_COND_SPEED_BOOST)
		Ware_AddPlayerAttribute(player, "halloween increased jump height", 0.3, Ware_GetMinigameRemainingTime())
		
		player.SetGravity(0.4)
	}
}

function OnEndRampTouch()
{
	local player = activator
	
	if (player.IsPlayer() && player.IsValid())
	{
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.on_ramp <- false
		
		player.RemoveFlag(FL_ONGROUND)
		
		player.RemoveCond(TF_COND_HALLOWEEN_SPEED_BOOST)
		player.RemoveCustomAttribute("halloween increased jump height")
		
		player.SetGravity(1.0)
	}
}

function OnEnd()
{
	endzone.DisconnectOutput("OnStartTouch", "OnStartTouch")
	tele1.DisconnectOutput("OnStartTouch", "OnStartTouch")
	tele2.DisconnectOutput("OnStartTouch", "OnStartTouch")
	ramp.DisconnectOutput("OnStartTouch", "OnStartTouch")
	ramp.DisconnectOutput("OnEndTouch", "OnEndTouch")
	
	BeepBlock_FireInput(green_blocks, "Alpha", "255")
	BeepBlock_FireInput(yellow_blocks, "Alpha", "255")
	
	foreach(data in Ware_MinigamePlayers)
		data.player.SetGravity(1.0)
}

function CheckEnd()
{
	return (BeepBlock_CheckEnd() || interrupt_timer == 0)
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
