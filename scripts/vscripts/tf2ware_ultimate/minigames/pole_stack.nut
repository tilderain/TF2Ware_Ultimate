minigame <- Ware_MinigameData
({
	name           = "Pole Stack"
	author         = "ficool2"
	description    = "Land on the pole!"
	duration       = 6.0
	location       = "dirtsquare"
	music          = "fencing"
})

pole_model <- "models/props_trainyard/lightpole.mdl"
pole <- null

function OnPrecache()
{
	PrecacheModel(pole_model)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Stickybomb Jumper")
	
	pole = Ware_SpawnEntity("prop_dynamic_override",
	{
		origin = Ware_MinigameLocation.center
		model  = pole_model
		solid  = SOLID_VPHYSICS
	})
}

function OnUpdate()
{
	local min_height = Ware_MinigameLocation.center.z + 256.0
	foreach (player in Ware_MinigamePlayers)
	{
		local origin = player.GetOrigin()
		if (origin.z < min_height)
			continue
		local ground = GetPropEntity(player, "m_hGroundEntity")
		if (ground && ground == pole)
			Ware_PassPlayer(player, true)
	}
}