minigame <- Ware_MinigameData
({
	name           = "Wild West"
	author         = "ficool2"
	description    = "Get Ready to Shoot..."
	duration       = 180.0
	end_delay      = 3.0
	music          = "staredown"
	location       = "dirtsquare"
	custom_overlay = ""
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
})

// 1v1 mode
dueling <- true

mexican_standoff <- false
game_over <- false
shootout <- false
sound_standoff <- "tf2ware_ultimate/mexican_standoff.mp3"

function OnPrecache()
{
	PrecacheSound(sound_standoff)
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/wildwest_ready")
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/wildwest_shoot")
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, null)
	Ware_SetGlobalAttribute("no_attack", 1, -1)
	Ware_SetGlobalAttribute("no_jump", 1, -1)
	
	foreach (player in Ware_MinigamePlayers)
	{
		local minidata = Ware_GetPlayerMiniData(player)
		minidata.holding_attack <- 0
		minidata.hold_warning <- false
		player.AddFlag(FL_ATCONTROLS)
	}
}

function OnTeleport(players)
{
	PlacePlayers(players)
}

function PlacePlayers(players)
{
	EntFire("tf_ragdoll", "Kill")
	
	if (players.len() <= 3)
	{
		mexican_standoff = true
		
		Shuffle(players)
		Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center, 135.0)

		foreach (player in players)
			Ware_GetPlayerMiniData(player).opponent <- null

		Ware_PlayMinigameMusic(null, Ware_Minigame.music, SND_STOP)
		Ware_PlaySoundOnAllClients(sound_standoff)
		
		Ware_CreateTimer(@() GiveGuns(), 2.0)
		return
	}
	else
	{
		mexican_standoff = false
	}
	
	local x_offset = 0.0
	local flip = 0
	local first = true
	local x_spacing = 70.0
	local y_spacing = 150.0
	
	local last_player = null
	
	local candidates = []
	foreach (player in players)
		candidates.append({player = player, latency = GetPlayerLatency(player)})
	candidates.sort(@(a, b) a.latency <=> b.latency)
	
	foreach (candidate in candidates)
	{
		local player = candidate.player

		if (flip % 4 == 0)
		{
			x_offset *= -1.0
			if (first)
				first = false
			else
				x_offset += x_offset < 0.0 ? x_spacing : -x_spacing
		}
	
		if (flip & 1)
		{
			if (dueling)
			{
				Ware_GetPlayerMiniData(player).opponent <- last_player
				Ware_GetPlayerMiniData(last_player).opponent <- player
			}
			
			Ware_TeleportPlayer(player, Ware_MinigameLocation.center + Vector(x_offset, -y_spacing, 0), QAngle(0, 90, 0), vec3_zero)
				
			x_offset += x_offset < 0.0 ? -x_spacing : x_spacing
		}
		else
		{
			Ware_TeleportPlayer(player, Ware_MinigameLocation.center + Vector(x_offset, y_spacing, 0), QAngle(0, 270, 0), vec3_zero)
		}
		
		last_player = player
	
		flip++
	}
	
	if (dueling && (flip & 1))
		Ware_GetPlayerMiniData(last_player).opponent <- null
	
	Ware_CreateTimer(@() GiveGuns(), 2.0)
}

function GiveGuns()
{
	local clip = mexican_standoff ? 6 : 2
	foreach (player in Ware_MinigamePlayers)
	{
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/wildwest_ready")	
	
		if (IsEntityAlive(player) 
			&& (mexican_standoff 
				|| !dueling
				|| Ware_GetPlayerMiniData(player).opponent != null))
		{
			Ware_SetPlayerAmmo(player, TF_AMMO_SECONDARY, 0)
			local weapon = Ware_GivePlayerWeapon(player, "L'Etranger")
			weapon.SetClip1(clip)
		}
	}
	
	local delay
	if (mexican_standoff)
		delay = RandomFloat(15.0, 45.0)
	else
		delay = RandomFloat(3.0, 10.0)
	
	Ware_CreateTimer(@() StartShootout(), delay)
}

function StartShootout()
{
	shootout = true
	
	if (mexican_standoff)
		Ware_PlaySoundOnAllClients(sound_standoff, 0.2, 100, SND_CHANGE_VOL)
	else
		Ware_PlayMinigameMusic(null, Ware_Minigame.music, SND_CHANGE_VOL, 0.2)
	
	foreach (player in Ware_MinigamePlayers)
	{
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/wildwest_shoot")
			
		if (IsEntityAlive(player))
			player.RemoveCustomAttribute("no_attack")
		
		if (player.IsFakeClient())
		{
			local target = player
			Ware_CreateTimer(@() SetPropInt(target, "m_afButtonForced", IN_ATTACK), RandomFloat(0.4, 1.0))
			Ware_CreateTimer(@() SetPropInt(target, "m_afButtonForced", 0), 1.0)
		}
	}	
	
	local delay = mexican_standoff ? 3.5 : 2.5
	Ware_CreateTimer(@() StopShootout(), delay)
}

function StopShootout()
{
	shootout = false
	
	local final_players = []
	local alive_players = Ware_GetAlivePlayers()
	if (mexican_standoff && alive_players.len() > 1)
	{
		foreach (player in alive_players)
		{
			if (IsEntityAlive(player))
			{
				Ware_ChatPrint(player, "{color} You have all been disqualified for surviving. Cowards!", TF_COLOR_DEFAULT)
				Ware_SuicidePlayer(player)
			}
		}
	}
	else
	{
		foreach (player in Ware_MinigamePlayers)
		{
			if (IsEntityAlive(player))
			{
				if (dueling)
				{
					local opponent = Ware_GetPlayerMiniData(player).opponent
					if (opponent)
					{
						if (opponent.IsValid())
						{
							if (IsEntityAlive(opponent))
							{
								Ware_SuicidePlayer(player)
								Ware_SuicidePlayer(opponent)
								local msg = "{color}You and your opponent have been disqualified for missing!"
								Ware_ChatPrint(player, msg, TF_COLOR_DEFAULT)
								Ware_ChatPrint(opponent, msg, TF_COLOR_DEFAULT)
								continue
							}
						}
						else
						{
							Ware_ChatPrint(player, "{color}Your opponent disconnected so you have been spared...", TF_COLOR_DEFAULT)
						}
					}
					else if (!mexican_standoff)
					{
						Ware_ChatPrint(player, "{color}You had no opponent so you have been spared...", TF_COLOR_DEFAULT)
					}
				}
				
				Ware_StripPlayer(player, true)
				Ware_ShowScreenOverlay(player, null)
				player.AddCustomAttribute("no_attack", 1, -1)	
				final_players.append(player)
			}
		}
	}
	
	local count = final_players.len()
	if (count > 1)
	{
		if (count > 3)
			Ware_PlayMinigameMusic(null, Ware_Minigame.music, SND_CHANGE_VOL, 1.0)
		
		PlacePlayers(final_players)
	}
	else
	{
		if (count == 1)
			Ware_ChatPrint(null, "{player}{color} wins as the best gunslinger!", final_players[0], TF_COLOR_DEFAULT)
		else
			Ware_ChatPrint(null, "{color}Nobody won!", TF_COLOR_DEFAULT)
		
		game_over = true
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer())
	{
		local attacker = params.attacker
		if (attacker && attacker != victim && attacker.IsPlayer())
		{
			if (!mexican_standoff)
			{
				if (dueling)
				{
					local opponent = Ware_GetPlayerMiniData(attacker).opponent
					if (opponent != victim)
						return false
				}
				else
				{
					local victim_side = victim.GetOrigin().y > Ware_MinigameLocation.center.y
					local attacker_side = attacker.GetOrigin().y > Ware_MinigameLocation.center.y
					if (victim_side == attacker_side)
						return false
				}
			}
			
			params.damage *= 5.0
			
			if (GetPropInt(victim, "m_LastHitGroup") == HITGROUP_HEAD)
			{
				params.damage *= 3.0
				params.damage_type = params.damage_type | DMG_CRIT
				params.damage_stats = TF_DMG_CUSTOM_HEADSHOT
			}
		}
	}
}

function OnUpdate()
{
	local time = Time()
	foreach (player in Ware_MinigamePlayers)
	{
		local weapon = player.GetActiveWeapon()
		if (weapon && weapon.GetSlot() == TF_SLOT_PRIMARY)
		{		
			local minidata = Ware_GetPlayerMiniData(player)
		
			// block holding attack before shootout
			local buttons = GetPropInt(player, "m_nButtons")
			if (!shootout)
			{
				if (buttons & IN_ATTACK)
				{
					SetPropFloat(player, "m_Shared.m_flStealthNoAttackExpire", time + 0.1)
					minidata.holding_attack = true
				}
				else
				{
					minidata.holding_attack = false
				}
			}
			else if (shootout)
			{
				if (minidata.holding_attack && (buttons & IN_ATTACK))
					SetPropFloat(player, "m_Shared.m_flStealthNoAttackExpire", time + 0.2)
				else
					minidata.holding_attack = false
			}
			
			if (minidata.holding_attack && !minidata.hold_warning)
			{
				minidata.hold_warning = true
				Ware_ChatPrint(player, "{color}Do not hold the attack button. {color}Your gun will not fire!", TF_COLOR_DEFAULT, COLOR_YELLOW)
			}
		}
	}
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.RemoveFlag(FL_ATCONTROLS)
		SetPropInt(player, "m_afButtonForced", 0)
	}
}

function OnCleanup()
{
	if (mexican_standoff)
		Ware_PlaySoundOnAllClients(sound_standoff, 1.0, 100, SND_STOP)
}

function CheckEnd()
{
	 return game_over
}