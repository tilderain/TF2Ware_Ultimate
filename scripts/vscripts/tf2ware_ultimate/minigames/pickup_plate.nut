items <-
[
	["Sandvich"              , "pickup_plate_sandvich",      "Sandvich",         "models/items/plate.mdl"],
	["Festive Sandvich"      , "pickup_plate_sandvich_xmas", "Festive Sandvich", "models/items/plate_sandwich_xmas.mdl"],
	["Robo-Sandvich"         , "pickup_plate_sandvich_robo", "Robo-Sandvich",    "models/items/plate_robo_sandwich.mdl"],
	["Dalokohs Bar"          , "pickup_plate_chocolate",     "Chocolate Bar",    "models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl"],
	["Fishcake"              , "pickup_plate_fishcake",      "Fishcake",         "models/workshop/weapons/c_models/c_fishcake/plate_fishcake.mdl"],
	["Buffalo Steak Sandvich", "pickup_plate_steak",         "Steak",            "models/workshop/weapons/c_models/c_buffalo_steak/plate_buffalo_steak.mdl"],
	["Second Banana"         , "pickup_plate_banana",        "Banana",           "models/items/banana/plate_banana.mdl"],
]
chosen_item <- RandomElement(items)

minigame <- Ware_MinigameData
({
	name           = "Pickup Plate"
	author         = "ficool2"
	description    = format("Pickup the %s!", chosen_item[2])
	duration       = 9.0
	music          = "catchme"
	location       = "beach"
	custom_overlay = chosen_item[1]
	no_collisions  = true
	thirdperson    = true
})

foreach (item in items) PrecacheModel(item[3])

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center + Vector(500, 0.0, 0),
		QAngle(0, -180, 0),
		1300.0,
		65.0, 65.0)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS)
	
	local offset = 128.0
	local pos = Ware_MinigameLocation.center * 1.0
	pos.y -= offset * 3.0
	pos.z -= 10.0
	
	foreach (item in items)
	{
		local prop = Ware_SpawnEntity("prop_dynamic",
		{
			origin     = pos
			model      = item[3]
			modelscale = 1.5
		})
		local trigger = Ware_SpawnEntity("trigger_multiple",
		{
			origin     = pos,
			spawnflags = SF_TRIGGER_ALLOW_CLIENTS,
		})
		trigger.SetSolid(SOLID_BBOX)
		trigger.SetSize(prop.GetBoundingMins() * 0.7, prop.GetBoundingMaxs() * 0.7)
		trigger.ValidateScriptScope()
		trigger.GetScriptScope().item <- item
		trigger.GetScriptScope().OnStartTouch <- OnTouchPlate
		trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
		
		pos.y += offset
	}
}

function OnTouchPlate()
{
	if (activator && !activator.InCond(TF_COND_STUNNED) && !Ware_IsPlayerPassed(activator))
	{
		if (item == Ware_MinigameScope.chosen_item)
		{		
			Ware_PassPlayer(activator, true)
			Ware_GivePlayerWeapon(activator, item[0])
		}
		else
		{
			Ware_ShowScreenOverlay(activator, "hud/tf2ware_ultimate/minigames/" + "pickup_plate_fail")
			StunPlayer(activator, TF_TRIGGER_STUN_LOSER, true, 10.0, 0.6)
		}
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
		data.player.RemoveCond(TF_COND_STUNNED)
}