minigame <- Ware_MinigameData
({
	name           = "Dodge the Lasers"
	author         = "ficool2"
	description    = "Get on a Platform!"
	duration       = 5.0
	music          = "urgent"
	start_pass     = true
	fail_on_death  = true
	
	max_scale = 1.0
})

beam_model <- "sprites/laserbeam.vmt"
empty_model <- "models/empty.mdl"
axes <- [[1, 0], [-1, 0], [0, -1], [0, 1]]

function OnPrecache()
{
	PrecacheModel(beam_model)
	PrecacheModel(empty_model)
}

function OnStart()
{
	local spacing = 1000.0
	for (local i = 0; i < 2; i++)
	{
		SpawnLaser(RandomElement(axes), spacing)
		spacing += RandomFloat(800.0, 1200.0)
	}
}

function SpawnLaser(axis, spacing)
{
	local center = Ware_MinigameLocation.center
	local width_x = Ware_MinigameLocation.maxs.x - Ware_MinigameLocation.mins.x
	local width_y = Ware_MinigameLocation.maxs.y - Ware_MinigameLocation.mins.y
	local offset_x = width_x + spacing
	local offset_y = width_y + spacing
	local laser_center = center + Vector(offset_x * axis[0], offset_y * axis[1], RandomBool() ? 75.0 : 10.0) 
	local laser_pos = laser_center - Vector(axis[1] * width_y * 0.5, axis[0] * width_x * 0.5)
	local laser_width = Vector(width_y * axis[1], width_x * axis[0])
	local laser_vel = Vector(RandomFloat(-700, -900) * axis[0], RandomFloat(-700, -900) * axis[1], 0)	
	local mover = Ware_SpawnEntity("prop_dynamic",
	{
		origin         = center
		model          = empty_model
		disableshadows = true
	})
	mover.SetMoveType(MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT)
	mover.SetAbsVelocity(laser_vel)

	local beam = Ware_CreateEntity("env_beam")
	beam.SetAbsOrigin(laser_pos)
	SetPropVector(beam, "m_vecEndPos", laser_width)
	beam.SetModel(beam_model)
	beam.KeyValueFromString("rendercolor", "255 0 0")
	beam.DispatchSpawn()
	SetPropFloat(beam, "m_fWidth", 14.0)
	SetPropFloat(beam, "m_fEndWidth", 14.0)
	EntityAcceptInput(beam, "TurnOn")
	SetEntityParent(beam, mover)
	
	beam = Ware_CreateEntity("env_beam")
	beam.SetAbsOrigin(laser_pos)
	SetPropVector(beam, "m_vecEndPos", laser_width)
	beam.SetModel(beam_model)
	beam.KeyValueFromString("rendercolor", "255 255 255")
	beam.DispatchSpawn()
	SetPropFloat(beam, "m_fWidth", 6.0)
	SetPropFloat(beam, "m_fEndWidth", 6.0)
	EntityAcceptInput(beam, "TurnOn")
	SetEntityParent(beam, mover)
	
	local trigger = Ware_SpawnEntity("trigger_multiple",
	{
		classname  = "cow_mangler" // kill icon
		origin     = laser_center
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	trigger.SetSolid(SOLID_BBOX)
	
	local dim_x = laser_width.x ? fabs(laser_width.x * 0.5) : 4.0
	local dim_y = laser_width.y ? fabs(laser_width.y * 0.5) : 4.0
	trigger.SetSize(Vector(-dim_x, -dim_y, -4), Vector(dim_x, dim_y, 4))
	trigger.ValidateScriptScope()
	trigger.GetScriptScope().OnStartTouch <- OnLaserTouch
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
	SetEntityParent(trigger, mover)
}

function OnLaserTouch()
{
	if (activator)
		activator.TakeDamageCustom(self, self, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_PLASMA)
}