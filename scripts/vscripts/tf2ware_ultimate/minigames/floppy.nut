minigame <- Ware_MinigameData
({
	name          = "Floppy Scout"
	author        = "tilderain"
	description   = "Get to the end!"
	duration      = 8.5
	location      = "boxarena"
	music         = "golden"
	thirdperson   = true
	custom_overlay = "get_end"
})

goal_vectors <- null

pipe_model <- "models/props_mining/generator_pipe01.mdl"

kill_sound <- "Halloween.skeleton_break"

function OnPrecache()
{
	PrecacheSprite(pipe_model)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players, 
		Ware_MinigameLocation.center + Vector(0, -700, 600), 
		QAngle(0, 90, 0), 
		1600.0, 
		60.0, 120.0)
}

function SpawnPipewall(org)
{
	local add = RandomInt(-200,400)
	for(local i=0; i<24; i++)
    {
        // Generate pipes vertically from -2 to 3 (6 layers) to extend past the gap
        for(local j=-2; j<=3; j++)
        {
			if(j==0) continue
            local angles = QAngle(0,0,0)
            local beam = Ware_SpawnEntity("prop_physics_override", 
            {
                origin       = org + Vector(-880,0,add) + Vector(i*120, 0, 300 + j*165)
                model        = pipe_model
                spawnflags   = SF_PHYSPROP_TOUCH
                minhealthdmg = 999999 // Don't destroy on touch    
                health = INT_MAX
                modelscale = 1
                angles = angles
            })
            beam.SetMoveType(MOVETYPE_NONE, 0)
            beam.SetCollisionGroup(TFCOLLISION_GROUP_RESPAWNROOMS)
        }
    }
	local hurt = Ware_SpawnEntity("trigger_hurt",
	{
		origin     = org
		damage     = 1000
		damagetype = DMG_SLASH
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	hurt.SetSolid(SOLID_BBOX)
	hurt.SetSize(org + Vector(-200,-200,-800), org + Vector(200,200,800))
	DebugDrawBox(vec3_zero, hurt.GetBoundingMinsOriented(), hurt.GetBoundingMaxsOriented(), 255, 0, 0, 20, 5.0)
}

function OnStart()
{
    Ware_SetGlobalLoadout(TF_CLASS_SCOUT, null, { "air dash count" : 9999 })    
    local highest_scale = 1.0
    foreach(player in Ware_MinigamePlayers)
        if (player.GetModelScale() > highest_scale)
            highest_scale = player.GetModelScale()
    
    local beam_height = 100.0 * highest_scale
	SpawnPipewall(Ware_MinigameLocation.center + Vector(0,300,0))
	//SpawnPipewall(Ware_MinigameLocation.center + Vector(0,10,0))
	SpawnPipewall(Ware_MinigameLocation.center + Vector(0,-300,0))

	goal_vectors = Ware_MinigameLocation.center + Vector(0,400,0)
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{		
		if(player.GetFlags() & FL_ONGROUND)
			Ware_SuicidePlayer(player)
		if (player.GetOrigin().y > goal_vectors.y)
			Ware_PassPlayer(player, true)
	}
}

function OnEnd()
{

}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer())
	{
		if (params.damage_type & DMG_CLUB)
		{
			local attacker = params.attacker
			if (victim.IsPlayer() && attacker && attacker.IsPlayer())
			{
				victim.SetAbsVelocity(victim.GetAbsVelocity() + Vector(0, 0, 300))
				Ware_PushPlayerFromOther(victim, attacker, 250.0)
				return false
			}
		}
		else if (params.damage_type & DMG_SLASH) // prop touch
		{
			// the attacker is the player, so recover the true attacker from the damage position
			local attacker = FindByClassnameNearest("prop_physics", params.damage_position, 0.0)
			if (attacker)
			{
				victim.TakeDamageEx(
					attacker, 
					attacker,
					null, 
					Vector(RandomFloat(19999, -19999), RandomFloat(19999, -19999), -999999),
					attacker.GetOrigin(), 
					999.9, 
					(DMG_CRUSH|DMG_CRIT)
				)
				
				victim.EmitSound(Ware_MinigameScope.kill_sound)
				
				local ragdoll = GetPropEntity(victim, "m_hRagdoll")
				if (ragdoll)
				{
					MarkForPurge(ragdoll)
					SetPropFloat(victim, "m_flTorsoScale", -1)
					SetPropFloat(ragdoll, "m_flTorsoScale", -1)
				}
				
				return false
			}
		}
	}
}