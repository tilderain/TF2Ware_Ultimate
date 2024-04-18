minigame <- Ware_MinigameData
({
	name          = "Avoid the Trains"
	author		  = "ficool2"
	description   = "Dodge the trains!"
	duration      = 6.0
	music         = "train"
	start_pass    = true
	fail_on_death = true
})	

mode <- RandomInt(0, 1)

start_sound <- "tf2ware_ultimate/train_rain.wav"
train_model <- "models/props_vehicles/train_enginecar.mdl"
PrecacheSound(start_sound)
PrecacheModel(train_model)

function OnStart()
{
	if (mode == 0)
		PlaySoundOnAllClients(start_sound)
	
	local minigame_players = clone(Ware_MinigamePlayers)
	
	local train_count
	if (mode == 0)
		train_count = Max(Min(minigame_players.len() / 3, minigame_players.len()), 1)
	else if (mode == 1)
		train_count = Min(minigame_players.len(), 2)
	
	for (local i = 0; i < train_count; i++)
	{
		local data = RemoveRandomElement(minigame_players)
		SpawnTrain(data.player.GetOrigin())
	}
}

function SpawnTrain(pos)
{
	local train_pos, train_ang, train_vel
	if (mode == 0)
	{
		train_pos = pos + Vector(0, 0, RandomFloat(1950, 2020))
		train_ang = QAngle(90, 0, 0)
		train_vel = Vector(0, 0, RandomFloat(-800, -1000))
	}
	else if (mode == 1)
	{
		local axes = [[1, 0], [-1, 0], [0, -1], [0, 1]]
		local axis = axes[RandomIndex(axes)]
		local offset_x = (Ware_MinigameLocation.maxs.x - Ware_MinigameLocation.mins.x) + 1132.0
		local offset_y = (Ware_MinigameLocation.maxs.y - Ware_MinigameLocation.mins.y) + 1132.0
		local x = RandomFloat(offset_x, offset_x + 150.0)
		local y = RandomFloat(offset_y, offset_y + 150.0)
		train_pos = pos + Vector(x * axis[0], y * axis[1], 0)
		train_ang = QAngle(0, -atan2(axis[1], -axis[0]) * RAD2DEG, 0)
		train_vel = Vector(RandomFloat(-800, -1000) * axis[0], RandomFloat(-800, -1000) * axis[1], 0)
	}
	
	local train = Ware_SpawnEntity("prop_dynamic",
	{
		model  = train_model
		origin = train_pos
		angles = train_ang
	})
	train.SetMoveType(MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT)
	train.SetAbsVelocity(train_vel)
	
	local hurt = Ware_SpawnEntity("trigger_hurt",
	{
		origin     = train_pos
		damage     = 1000
		damagetype = DMG_VEHICLE
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	SetEntityParent(hurt, train)
	hurt.SetSolid(SOLID_BBOX)
	hurt.SetSize(train.GetBoundingMinsOriented(), train.GetBoundingMaxsOriented())
}