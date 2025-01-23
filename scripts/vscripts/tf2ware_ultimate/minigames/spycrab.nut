minigame <- Ware_MinigameData
({
	name           = "Spycrab"
	author         = ["Mecha the Slag", "ficool2"]
	description    = "Do the spycrab!"
	duration       = 3.5
	end_delay      = 0.5
	music          = "sillytime"
	suicide_on_end = true
})

sprite_model <- "sprites/tf2ware_ultimate/spycrab.vmt"

function OnPrecache()
{
	PrecacheSprite(sprite_model)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY)
	Ware_CreateTimer(@() Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit"), 1.0)
	
	Ware_SpawnEntity("env_sprite_oriented",
	{
		origin     = Ware_MinigameLocation.center + Vector(0, 0, 2000)
		angles     = QAngle(90, 0, 0)
		model      = sprite_model
		scale      = 5
		rendermode = kRenderTransColor
		spawnflags = 1,	
	})

}

function OnPlayerVoiceline(player, voiceline)
{
	if (voiceline.find("taunt05.vcd") != null)
	{
		if (Ware_PassPlayer(player, true))
			Ware_GiveBonusPoints(player)
	}
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if ((player.GetFlags() & FL_DUCKING) && (player.EyeAngles().x < -70.0))
			Ware_PassPlayer(player, true)
		else if (!Ware_IsPlayerPassed(player))
			Ware_ChatPrint(player, "Spycrabs must look up and crouch!")
	}
}