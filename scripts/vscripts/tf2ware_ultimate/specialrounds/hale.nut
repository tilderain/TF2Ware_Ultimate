hale_start_sound <- "TF2Ware_Ultimate.HaleStart"
hale_jump_sound <- "TF2Ware_Ultimate.HaleJump"
hale_rage_sound <- "TF2Ware_Ultimate.HaleRage"
hale_talk_sound <- "TF2Ware_Ultimate.HaleRamble"
hale_death_sound <- "TF2Ware_Ultimate.HaleDeath"
hale_win_sound <- "TF2Ware_Ultimate.HaleWin"

hale_rage  <- {}
hale_jumptime  <- {}

special_round <- Ware_SpecialRoundData
({
	name = "Versus Saxton Hale"
	author = ["Batfoxkid"]  // Put OG modeler and voice actor here
	description = "Everyone is SAXTON HALE!"
	category = "weapon"
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

function ApplyHaleEffects(player)
{
	local data = Ware_GetPlayerData(player)
	local melee

	if (!data.special_melee || !data.special_melee.IsValid())
	{
		melee = CreateEntitySafe("tf_weapon_shovel")
		SetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 5)
		SetPropBool(melee, "m_AttributeManager.m_Item.m_bInitialized", true)
		melee.DispatchSpawn()
	}

	if (melee)
		Ware_EquipSpecialMelee(player, melee, null)
}

::ApplyHaleModel <- function()
{
	if (Ware_IsSpecialRoundSet("hale"))
	{
		self.SetCustomModelWithClassAnimations("models/player/saxton_hale/saxton_hale.mdl")
		Ware_TogglePlayerWearables(self, false)
		Ware_AddPlayerAttribute(self, "voice pitch scale", 0, -1)

		// Allow hats as this model can hides it's own
		for (local wearable = self.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
		{
			if (IsWearableHat(wearable))
				Ware_ToggleWearable(wearable, true)
		}
	}
}

function OnStart()
{
	hale_rage <- {}
	hale_jumptime  <- {}

	foreach (player in Ware_GetValidPlayers())
		ApplyHaleEffects(player)

	Ware_PlaySoundOnAllClients(hale_start_sound)
}

function OnPlayerInventory(player)
{
	ApplyHaleEffects(player)
}

function OnPlayerSpawn(player)
{
	// Delay some stuff to make sure our stuff is set
	EntityEntFire(player, "CallScriptFunction", "ApplyHaleModel", 0.1)
}

function OnUpdate()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		local rage = GetHaleRage(player)
		local jump = GetHaleJump(player)
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
				SetHaleJump(player, jump)
			}
		}
		else if ((buttons & IN_ATTACK2) || (buttons & IN_DUCK))
		{
			// Charging jump
			if (jump == 0.0)
			{
				jump = time
				SetHaleJump(player, jump)
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

				SetHaleJump(player, -(time + 5.0))
			}
			else
			{
				jump = 0.0
				SetHaleJump(player, jump)
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
		else if (GetHaleRage(player) >= 100)
		{
			// RAGE
			SetHaleRage(player, 0)

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
		local player = data.player

		local rage = GetHaleRage(player) + 20
		if(rage > 100)
			rage = 100

		SetHaleRage(player, rage)

		Ware_PlaySoundOnClient(player, hale_death_sound)
	}
}

function OnEnd()
{
	foreach (player in Ware_Players)
	{
		player.SetCustomModelWithClassAnimations("")
		Ware_TogglePlayerWearables(player, true)
		Ware_RemovePlayerAttribute(player, "voice pitch scale")

		Ware_DestroySpecialMelee(player)
	}
}

function GetHaleRage(player)
{
	return player.entindex() in hale_rage ? hale_rage[player.entindex()] : 0
}

function SetHaleRage(player, rage)
{
	hale_rage[player.entindex()] <- rage
}

function GetHaleJump(player)
{
	return player.entindex() in hale_jumptime ? hale_jumptime[player.entindex()] : 0
}

function SetHaleJump(player, time)
{
	hale_jumptime[player.entindex()] <- time
}