hale_model <- "models/player/saxton_hale/saxton_hale.mdl"

hale_start_sound <- "TF2Ware_Ultimate.HaleStart"
hale_jump_sound <- "TF2Ware_Ultimate.HaleJump"
hale_rage_sound <- "TF2Ware_Ultimate.HaleRage"
hale_talk_sound <- "TF2Ware_Ultimate.HaleRamble"
hale_death_sound <- "TF2Ware_Ultimate.HaleDeath"

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
		// TODO: Rage and Jump HUD and Logic
		// TODO: On Rage, scare nearby players for 30/X seconds with X being total players on server, with a min of 1 second
		// The REALLY old VSH to reference: https://github.com/FlaminSarge/Versus-Saxton-Hale/blob/master/addons/sourcemod/scripting/saxtonhale.sp#L4074
		
		local player = data.player
		local rage = data.halerage
		local jump = data.halecharge
		local text = ""

		if (jump >= 0)
		{
			text = "Jump charge: " + jump.tostring() + " percent. Look up and stand up to use super-jump."
		}
		else
		{
			text = "Super Jump will be ready again in: " + jump.tostring()
		}

		if (rage >= 100)
		{
			text += " RAGE meter: " + rage.tostring() + " percent!"
		}
		else
		{
			text += " Call Medic to activate RAGE."
		}

		Ware_ShowText(player, CHANNEL_MISC, text, 0.2, rage >= 100 ? "255 0 0" : "255 255 255", -1.0, 0.13)
	}
}

function OnCalculateScore(data)
{
	if (!data.passed)
	{
		local rage = data.halerage + 20
		if(rage > 100)
			rage = 100
		
		data.halerage = rage
	}
}

// TODO: Voice overrides

function OnEnd()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		
		local special_melee = data.special_melee
		
		player.SetCustomModelWithClassAnimations("")
		Ware_TogglePlayerWearables(player, true)
		
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