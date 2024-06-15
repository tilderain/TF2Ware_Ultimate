minigame <- Ware_MinigameData
({
	name          = "Grapple the Cow"
	author        = "ficool2"
	description   = "Smack the cow!"
	duration      = 10.5
	location      = "boxarena"
	music         = "farm"
})

cow_model <- "models/props_2fort/cow001_reference.mdl"

function OnPrecache()
{
	PrecacheModel(cow_model)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center + Vector(620, 0, 0),
		QAngle(0, 180, 0),
		1300.0,
		65.0, 65.0)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, ["Ullapool Caber", "Grappling Hook"])

	Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(-960, 0, 584)
		model  = cow_model
		solid  = SOLID_BBOX
	})
	Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(-960, -500, 584)
		model  = cow_model
		solid  = SOLID_BBOX
	})
	Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(-960, 500, 584)
		model  = cow_model
		solid  = SOLID_BBOX
	})
}

function OnTakeDamage(params)
{
	local attacker = params.attacker
	if (attacker
		&& attacker.IsPlayer()
		&& (params.damage_type & DMG_BLAST)
		&& params.const_entity.GetModelName() == cow_model)
	{
		Ware_PassPlayer(attacker, true)
	}
}