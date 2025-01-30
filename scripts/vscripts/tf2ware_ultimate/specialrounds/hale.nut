hale_model <- "models/player/saxton_hale/saxton_hale.mdl"

hale_start_sound <- "TF2Ware_Ultimate.HaleStart"
hale_jump_sound <- "TF2Ware_Ultimate.HaleJump"
hale_rage_sound <- "TF2Ware_Ultimate.HaleRage"
hale_talk_sound <- "TF2Ware_Ultimate.HaleRamble"
hale_death_sound <- "TF2Ware_Ultimate.HaleDeath"
hale_win_sound <- "TF2Ware_Ultimate.HaleWin"

special_round <- Ware_SpecialRoundData
({
	name = "Versus Saxton Hale"
	author = ["Batfoxkid"]  // Put OG modeler and voice actor here
	description = "Everyone is SAXTON HALE!"
	category = "weapon"
})

function OnPrecache()
{
	PrecacheModel(hale_model)
	PrecacheScriptSound(hale_start_sound)
	PrecacheScriptSound(hale_jump_sound)
	PrecacheScriptSound(hale_rage_sound)
	PrecacheScriptSound(hale_talk_sound)
	PrecacheScriptSound(hale_death_sound)
}

function ApplyHaleEffects(player)
{
	local data = Ware_GetPlayerData(player)

	local special_melee = data.special_melee
	if (!special_melee || !special_melee.IsValid())
	{
		special_melee = CreateEntitySafe("tf_weapon_shovel")
		SetPropInt(special_melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 5)
		SetPropBool(special_melee, "m_AttributeManager.m_Item.m_bInitialized", true)
		special_melee.DispatchSpawn()

		player.Weapon_Equip(special_melee)
		local index = data.melee_index
		for (local i = 0; i < MAX_WEAPONS; i++)
		{
			local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
			if (weapon == special_melee)
			{
				SetPropEntityArray(player, "m_hMyWeapons", null, i)
				index = i
				data.melee_index = i
				break
			}
		}

		SetPropEntityArray(player, "m_hMyWeapons", special_melee, index)
		player.Weapon_Switch(special_melee)
		data.special_melee = special_melee
	}

	player.SetCustomModelWithClassAnimations(hale_model)
	Ware_TogglePlayerWearables(player, false)
	Ware_AddPlayerAttribute(player, "voice pitch scale", 0, -1)
}

function OnStart()
{
	local players = Ware_GetValidPlayers()
	foreach (player in players)
	{
		if (player.IsAlive())
		{
			ApplyHaleEffects(player)
		}
	}

	Ware_PlaySoundOnAllClients(hale_start_sound)
}

function OnPlayerInventory(player)
{
	ApplyHaleEffects(player)
}

function OnUpdate()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		local rage = data.halerage
		local jump = data.halejumptime
		local text = ""
		local buttons = GetPropInt(player, "m_nButtons")
		local time = Time()

		if (jump < 0.0)
		{
			// Jump is on cooldown
			jump = -(jump + time);
			if (jump < 0.0)
			{
				data.halejumptime = 0.0
				jump = 0.0
			}
		}
		else if ((buttons & IN_ATTACK2) || (buttons & IN_DUCK))
		{
			// Charging jump
			if (jump == 0.0)
			{
				jump = time
				data.halejumptime = time
			}

			// 1.5s to full charge
			jump = (time - jump) * 66.66667

			if(jump > 100.0)
			{
				jump = 100.0
			}
		}
		else if (jump > 0.0)
		{
			// Jump if possible
			if (player.GetMoveType() == MOVETYPE_WALK)
			{
				local angles = player.EyeAngles()
				if (angles.x < -20.0)
				{
					if (jump > 100.0)
					{
						jump = 100.0
					}

					local velocity = player.GetAbsVelocity()

					velocity.x *= 1.0 + (jump * 0.00275)
					velocity.y *= 1.0 + (jump * 0.00275)
					velocity.z = 750.0 + (jump * 3.25)

					player.SetAbsVelocity(velocity)
					SetPropBool(player, "m_bJumping", true)

					data.halejumptime = -(time + 5.0)
				}
			}

			jump = 0.0
		}

		if (rage >= 100)
		{
			text = "RAGE meter: " + rage.tostring() + " percent!"
		}
		else
		{
			text = "Call Medic to activate RAGE."
		}

		if (jump >= 0.0)
		{
			text += "\nJump charge: " + jump.tointeger().tostring() + " percent. Look up and stand up to use super-jump."
		}
		else
		{
			text += "\nSuper Jump will be ready again in: " + jump.tointeger().tostring()
		}

		Ware_ShowText(player, CHANNEL_MISC, text, 0.2, rage >= 100 ? "255 0 0" : "255 255 255", -1.0, 0.83)
	}
}

function OnPlayerVoiceline(player, voiceline)
{
	if (voiceline in VCD_MAP)
	{
		if (VCD_MAP[voiceline].find(".Medic") == null)
		{
			EmitSoundEx(
			{
				sound_name = hale_talk_sound,
				volume = 0.8,
				pitch = 100 * Ware_GetPitchFactor(),
				entity = player,
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
		}
		else if (data.halerage >= 100)
		{
			// RAGE
			data.halerage = 0

			EmitSoundEx(
			{
				sound_name = hale_talk_rage,
				volume = 1.0,
				pitch = 100 * Ware_GetPitchFactor(),
				entity = player,
				filter_type = RECIPIENT_FILTER_GLOBAL
			})

			local origin = player.GetOrigin()
			local duration = 30.0 / Ware_MinigamePlayers.len()

			player.AddCondEx(TF_COND_NOHEALINGDAMAGEBUFF, duration, null)

			foreach (victim in Ware_MinigamePlayers)
			{
				if (player == victim || !victim.IsAlive())
				{
					continue
				}

				local dist = VectorDistance(origin, victim.GetOrigin())
				if (dist < 600.0)
				{
					activator.StunPlayer(duration, 0.75, TF_STUN_BY_TRIGGER, null)
				}
			}
		}
	}
}

function OnCalculateScore(data)
{
	if (data.passed)
	{
		Ware_PlaySoundOnClient(data.player, hale_win_sound)
	}
	else
	{
		local rage = data.halerage + 20
		if(rage > 100)
			rage = 100

		data.halerage = rage

		Ware_PlaySoundOnClient(data.player, hale_death_sound)
	}
}

function OnEnd()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player

		local special_melee = data.special_melee

		player.SetCustomModelWithClassAnimations("")
		Ware_TogglePlayerWearables(player, true)
		Ware_RemovePlayerAttribute(m_driver, "voice pitch scale")

		if (special_melee)
		{
			local weapon = player.GetActiveWeapon()
			if (weapon == special_melee)
				player.Weapon_Switch(data.melee)

			if (special_melee.IsValid())
				KillWeapon(special_melee)

			data.special_melee = null
		}
	}
}