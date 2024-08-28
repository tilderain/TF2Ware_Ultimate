
sandbag_model <- "models/tf2ware_ultimate/sandbag.mdl"
sandbags <- []

minigame <- Ware_MinigameData
({
	name           = "Home-Run Contest"
	author         = "pokemonPasta"
	description    = "Home-Run Contest!"
	duration       = INT_MAX.tofloat() // going to always end manually. may reduce this a bit in case something breaks.
	location       = "homerun_contest"
	music          = "homerun_contest"
})

function OnPrecache()
{
	PrecacheModel(sandbag_model)
}

// TODO: Create a podium for each player.
// function OnTeleport()
// {
	
// }

function OnStart()
{
	foreach(player in Ware_MinigamePlayers)
	{
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.sandbag <- SpawnEntityFromTableSafe("prop_physics_override", {
			model = sandbag_model,
			origin = player.GetOrigin() + Vector(0, 150, 40)
			angles = QAngle(0, -90, 0)
		})
		
		local sandbag = minidata.sandbag
		EntityAcceptInput(sandbag, "Sleep")
		sandbag.ValidateScriptScope()
		local scope = sandbag.GetScriptScope()
		scope.percent <- 0.0
		scope.player <- player // this might cause null reference issues if a player disconnects, maybe kill the sandbag if a player leaves?
		sandbags.append(sandbag)
		
		Ware_ShowText(player, CHANNEL_MINIGAME, format("Sandbag: %d%%", scope.percent), Ware_GetMinigameRemainingTime())
	}
}

function OnTakeDamage(params)
{
	local ent = params.const_entity
	local inflictor = params.inflictor
	
	if (!inflictor.IsPlayer() || !inflictor.IsValid())
		return
	
	local sandbag = Ware_GetPlayerMiniData(inflictor).sandbag
	
	if (ent == sandbag)
	{
		sandbag.GetScriptScope().percent += params.damage
		local percent = sandbag.GetScriptScope().percent
		
		params.damage_force = percent / 100.0
		
		Ware_ShowText(inflictor, CHANNEL_MINIGAME, format("Sandbag: %d%%", percent), Ware_GetMinigameRemainingTime())
		printl(percent)
	}
	else if (ent == inflictor)
	{
		params.damage == 0.0
	}
}
