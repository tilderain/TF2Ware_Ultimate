bat_model <- "models/weapons/c_models/tf2ware/c_bonk_bat.mdl"
bat_modelindex <- PrecacheModel(bat_model)

bat_hit_sound <- "TF2Ware_Ultimate.BonkBatHit"
PrecacheScriptSound(bat_hit_sound)

special_round <- Ware_SpecialRoundData
({
	name = "Bonk"
	author = "ficool2"
	description = "Everyone gets a BONK BAT!"
	allow_damage = true
})

function GiveSpecialMelee(player)
{
	local data = player.GetScriptScope().ware_data
	
	local special_melee = data.special_melee
	if (!special_melee || !special_melee.IsValid())
	{
		special_melee = CreateEntitySafe("tf_weapon_bat")
		SetPropInt(special_melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1123)
		SetPropBool(special_melee, "m_AttributeManager.m_Item.m_bInitialized", true)
		special_melee.DispatchSpawn()
		
		for (local i = 0; i < 4; i++)
			SetPropIntArray(special_melee, "m_nModelIndexOverrides", bat_modelindex, i)
		SetPropBool(special_melee, "m_bBeingRepurposedForTaunt", true)
		SetPropInt(special_melee, "m_nRenderMode", kRenderTransColor)
			
		player.Weapon_Equip(special_melee)
		for (local i = 0; i < MAX_WEAPONS; i++)
		{
			local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
			if (weapon == special_melee)
			{
				SetPropEntityArray(player, "m_hMyWeapons", null, i)
				break
			}
		}
		
		SetPropEntityArray(player, "m_hMyWeapons", special_melee, data.melee_index)
		player.Weapon_Switch(special_melee)
		data.special_melee = special_melee
	}
	
	local special_vm = data.special_vm
	if (!special_vm || !special_vm.IsValid())
	{
		special_vm = Entities.CreateByClassname("tf_wearable_vm")
		SetPropInt(special_vm, "m_nModelIndex", bat_modelindex)
		SetPropBool(special_vm, "m_bValidatedAttachedEntity", true)
		special_vm.DispatchSpawn()
		player.EquipWearableViewModel(special_vm)
		special_vm.KeyValueFromString("classname", "ware_specialvm")
		data.special_vm = special_vm
	}
}

function OnStart()
{
	local players = Ware_GetValidPlayers()
	foreach (player in players)
	{
		if (IsEntityAlive(player))
		{
			GiveSpecialMelee(player)
		}
	}
}

function OnPlayerInventory(player)
{
	GiveSpecialMelee(player)
}

function OnUpdate()
{
	foreach (data in Ware_PlayersData)
	{
		local special_melee = data.special_melee
		local special_vm = data.special_vm
				
		if (special_melee && special_melee.IsValid())
			SetPropBool(special_melee, "m_bBeingRepurposedForTaunt", true)
		else
			special_melee = null
		
		if (special_vm && special_vm.IsValid())
			special_vm.SetDrawEnabled(data.player.GetActiveWeapon() == data.special_melee)
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer())
	{
		local attacker = params.attacker
		if (attacker && attacker.IsPlayer())
		{
			if (params.damage_type & DMG_CLUB)
			{
				local weapon = params.weapon
				if (weapon && GetPropInt(weapon, "m_nModelIndexOverrides") == bat_modelindex)
				{
					params.damage = 1.0
					
					Ware_UngroundPlayer(victim)
					
					local scale = 450.0
					local dir = attacker.EyeAngles().Forward()
					local vel = victim.GetAbsVelocity()
					dir.z = Max(dir.z, 0.0)
					vel += dir * scale
					vel.z += scale
					victim.SetAbsVelocity(vel)				
					victim.EmitSound(bat_hit_sound)
				}
			}
		}
	}
}

function OnEnd()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		
		local special_vm = data.special_vm	
		local special_melee = data.special_melee
		
		if (special_vm)
		{
			if (special_vm.IsValid())
				special_vm.Kill()
			data.special_vm = null
		}
		
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