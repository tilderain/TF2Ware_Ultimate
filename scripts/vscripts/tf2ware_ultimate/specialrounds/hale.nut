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
	pitch_override = 0
})

function OnPrecache()
{
	PrecacheModel("models/player/saxton_hale/saxton_hale.mdl")
	PrecacheScriptSound(hale_start_sound)
	PrecacheScriptSound(hale_jump_sound)
	PrecacheScriptSound(hale_rage_sound)
	PrecacheScriptSound(hale_talk_sound)
	PrecacheScriptSound(hale_death_sound)
}

function ApplyHaleMelee(player)
{
	local data = Ware_GetPlayerData(player)
	local melee

	if (!data.special_melee || !data.special_melee.IsValid())
	{
		melee = CreateEntitySafe("tf_weapon_shovel")
		SetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 195)
		SetPropBool(melee, "m_AttributeManager.m_Item.m_bInitialized", true)
		melee.DispatchSpawn()
	}

	if (melee)
		Ware_EquipSpecialMelee(player, melee, null)
}

function ApplyHaleModel(player)
{
	if (Ware_IsSpecialRoundSet("hale"))
	{
		player.SetCustomModelWithClassAnimations("models/player/saxton_hale/saxton_hale.mdl")
		Ware_TogglePlayerWearables(player, false)

		// Allow hats as this model hides it's own
		for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		{
			if (IsWearableHat(wearable))
				Ware_ToggleWearable(wearable, true)
		}
	}
}

function OnStart()
{
	foreach(player in Ware_Players)
	{
		local special = Ware_GetPlayerSpecialRoundData(player)
		special.hale_rage <- 0
		special.hale_jumptime <- 0.0

		if (player.IsAlive())
		{
			ApplyHaleMelee(player)
			ApplyHaleModel(player)
		}
	}

	Ware_PlaySoundOnAllClients(hale_start_sound)
}

function OnPlayerConnect(player)
{
	local special = Ware_GetPlayerSpecialRoundData(player)
	special.hale_rage <- 0
	special.hale_jumptime <- 0.0
}

function OnPlayerInventory(player)
{
	ApplyHaleMelee(player)
	ApplyHaleModel(player)
}

function OnPlayerSpawn(player)
{
	ApplyHaleModel(player)
}

function OnUpdate()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		if (player.IsAlive())
		{
			local special = Ware_GetPlayerSpecialRoundData(player)
			local rage = special.hale_rage
			local jump = special.hale_jumptime
			local text = ""
			local buttons = GetPropInt(player, "m_nButtons")
			local time = Time()

			if (jump < 0.0)
			{
				// Jump is on cooldown
				jump += time
				if (jump > 0.0)
				{
					jump = 0.0
					special.hale_jumptime = jump
				}
			}
			else if ((buttons & IN_ATTACK2) || (buttons & IN_DUCK))
			{
				// Charging jump
				if (jump == 0.0)
				{
					jump = time
					special.hale_jumptime = jump
				}

				// 1.5s to full charge
				jump = (time - jump) * 66.66667
				if(jump > 100.0)
					jump = 100.0
			}
			else if (jump > 0.0)
			{
				// Jump if possible
				if (player.GetMoveType() == MOVETYPE_WALK && player.EyeAngles().x < -20.0)
				{
					if (jump > 100.0)
						jump = 100.0

					local velocity = player.GetAbsVelocity()

					velocity.x *= 1.0 + (jump * 0.00275)
					velocity.y *= 1.0 + (jump * 0.00275)
					velocity.z = 750.0 + (jump * 3.25)

					player.SetAbsVelocity(velocity)
					SetPropBool(player, "m_bJumping", true)

					EmitSoundEx(
					{
						sound_name = hale_jump_sound,
						volume = 1.0,
						pitch = 100 * Ware_GetPitchFactor(),
						entity = player,
						filter_type = RECIPIENT_FILTER_GLOBAL
					})

					special.hale_jumptime = -(time + 5.0)
				}
				else
				{
					jump = 0.0
					special.hale_jumptime = jump
				}
			}

			if (rage >= 100)
			{
				text = "Call Medic to activate RAGE."
			}
			else
			{
				text = "RAGE meter: " + rage.tostring() + " percent!"
			}

			if (jump >= 0.0)
			{
				text += "\nJump charge: " + jump.tointeger().tostring() + " percent. Look up and stand up to use super-jump."
			}
			else
			{
				text += "\nSuper Jump will be ready again in: " + (-jump).tointeger().tostring()
			}

			Ware_ShowText(player, CHANNEL_MISC, text, 0.2, rage >= 100 ? "255 0 0" : "255 255 255", -1.0, 0.83)
		}
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
		else
		{
			local special = Ware_GetPlayerSpecialRoundData(player)
			if (special.hale_rage >= 100)
			{
				// RAGE
				special.hale_rage = 0

				EmitSoundEx(
				{
					sound_name = hale_rage_sound,
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
						continue

					local dist = VectorDistance(origin, victim.GetOrigin())
					if (dist < 600.0)
					{
						victim.StunPlayer(duration, 0.75, TF_STUN_BY_TRIGGER, null)
					}
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
		local player = data.player
		local special = Ware_GetPlayerSpecialRoundData(player)

		local rage = special.hale_rage + 20
		if(rage > 100)
			rage = 100

		special.hale_rage = rage

		Ware_PlaySoundOnClient(player, hale_death_sound)
	}
}

function OnEnd()
{
	foreach (player in Ware_Players)
	{
		player.SetCustomModel("")
		Ware_TogglePlayerWearables(player, true)
		Ware_RemovePlayerAttribute(player, "voice pitch scale")

		Ware_DestroySpecialMelee(player)
	}
}
