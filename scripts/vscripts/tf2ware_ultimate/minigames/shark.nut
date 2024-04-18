minigame <- Ware_MinigameData
({
	name           = "Shark"
	author         = "ficool2"
	description    = 
	[
		"You are the Shark. Kill 3 players!"
		"Get on the beach and avoid the Shark!"
	]
	duration       = 23.5
	end_delay      = 1.0
	music          = "slowfox"
	location       = "beach"
	allow_damage   = true
	fail_on_death  = true
	no_collisions  = true
	min_players    = 4
	custom_overlay = 
	[
		"avoid_shark"
		"shark_kill"
	]
	convars        =
	{
		mp_teams_unbalance_limit = 0
	}
})

shark <- null
shark_icon <- null
shark_kills <- 0

shark_model <- "models/tf2ware/shark.mdl"
shark_sound <- "TF2Ware_Ultimate.Sharkbite"

PrecacheModel(shark_model)
PrecacheScriptSound(shark_sound)
 
function OnTeleport(players)
{
	shark = RemoveRandomElement(players)

	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center + Vector(3500, 0, -250),
		QAngle(0, -180, 0),
		1300.0,
		65.0, 65.0)
		
	shark.Teleport(true, Ware_MinigameLocation.center + Vector(1500, 0, -200), true, QAngle(), true, Vector())
}

function OnStart()
{
	local blocker = Ware_SpawnEntity("func_forcefield",
	{
		origin  = Ware_MinigameLocation.center + Vector(650, 0, 0)
		teamnum = TF_TEAM_RED
	})
	blocker.SetSolid(SOLID_BBOX)
	blocker.SetSize(Vector(-8, -1000, -1000), Vector(8, 1000, 1000))
	
	shark_icon = Ware_SpawnEntity("handle_dummy", { classname = "shark" } ) // kill icon
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (player == shark)
		{
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_PYRO)
			player.SetForcedTauntCam(1)
			player.SetCustomModel(shark_model)
			player.SetCustomModelRotates(true)
			player.SetCustomModelOffset(Vector(0, 0, -48))
			TogglePlayerWearables(shark, false)
			SetPropFloat(player, "m_PainFinished", 1e30) // disable drowning
			Ware_SetPlayerTeam(player, TF_TEAM_BLUE)
		}
		else
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_SOLDIER)
			Ware_SetPlayerTeam(player, TF_TEAM_RED)
		}
	}
}

function OnUpdate()
{
	local shark_pos = shark.IsValid() ? shark.GetOrigin() : null
	local threshold = Ware_MinigameLocation.center.x + 512.0
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (player == shark)
			continue
		if (!IsEntityAlive(player))
			continue

		local origin = player.GetOrigin()
		if (shark_pos)
		{
			if ((origin - shark_pos).Length() < 110.0)
			{
				shark.EmitSound(shark_sound)
				player.TakeDamage(20000, DMG_BLAST, shark)
				continue
			}
		}
		
		if (origin.x <= threshold && !Ware_IsPlayerPassed(player))
		{
			Ware_ShowScreenOverlay(player, null)
			Ware_PassPlayer(player, true)
		}
	}
}

function OnPlayerDeath(params)
{
	local victim = GetPlayerFromUserID(params.userid)
	if (victim == shark)
	{
		CreateTimer(@() KillPlayerRagdoll(victim), 0.0)
	}
	else
	{
		local attacker = GetPlayerFromUserID(params.attacker)
		if (attacker && attacker == shark)
		{
			if (++shark_kills >= 3)
				Ware_PassPlayer(attacker, true)
		}
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
	if (attacker && victim != attacker)
	{
		if (attacker != shark)
			return false
			
		params.inflictor = shark_icon
	}
}

function OnCleanup()
{
	if (shark.IsValid())
	{
		shark.SetForcedTauntCam(0)
		shark.SetCustomModel("")
		shark.SetCustomModelRotates(false)
		shark.SetCustomModelOffset(Vector())
		TogglePlayerWearables(shark, true)
		SetPropFloat(shark, "m_PainFinished", 0.0)
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers(TF_TEAM_RED).len() == 0
}