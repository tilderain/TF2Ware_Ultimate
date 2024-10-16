local mode = RandomInt(0, 1)
mode = 1

minigame <- Ware_MinigameData
({
	name            = mode == 1 ? "Grapple the Deer" : "Grapple the Cow"
	author          = "ficool2"
	description     = mode == 1 ? "Smack the deer!" : "Smack the cow!"
	duration        = 10.5
	location        = "boxarena"
	music           = "farm"
	custom_overlay  = mode == 1 ? "grapple_deer" : "grapple_cow"
})

cutout_models <-
[
	"models/props_2fort/cow001_reference.mdl"
	"models/props_sunshine/deer_cutout001.mdl"
]
cutout_model <- cutout_models[mode]

function OnPrecache()
{
	foreach (model in cutout_models)
		PrecacheModel(model)
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
	
	local angles = mode == 1 ? QAngle(0, 90, 0) : QAngle(0, 0, 0)
	
	local lightorigin = Ware_SpawnEntity("info_target",
	{
		origin     = Ware_MinigameLocation.center + Vector(-830, -780, 584)
		spawnflags = 1
	})
	printl(lightorigin.GetOrigin())
	
	local prop = Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(-960, 0, 584)
		angles = angles
		model  = cutout_model
		solid  = SOLID_BBOX
	})
	SetPropEntity(prop, "m_hLightingOrigin", lightorigin)
	prop = Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(-960, -500, 584)
		angles = angles
		model  = cutout_model
		solid  = SOLID_BBOX
	})
	SetPropEntity(prop, "m_hLightingOrigin", lightorigin)
	prop = Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(-960, 500, 584)
		angles = angles
		model  = cutout_model
		solid  = SOLID_BBOX
	})
	SetPropEntity(prop, "m_hLightingOrigin", lightorigin)
}

function OnTakeDamage(params)
{
	local attacker = params.attacker
	if (attacker
		&& attacker.IsPlayer()
		&& (params.damage_type & DMG_BLAST)
		&& params.const_entity.GetModelName() == cutout_model)
	{
		Ware_PassPlayer(attacker, true)
	}
}