minigame <- Ware_MinigameData();
minigame.name = "Catch the Money";
minigame.description = "Catch the money!"
minigame.duration = 30.0;
minigame.music = "casino";

cash_models  <- 
[
	"models/items/currencypack_small.mdl"
	"models/items/currencypack_medium.mdl"
	"models/items/currencypack_large.mdl"
];
cash_amounts <-
[
	25,
	50,
	100,
];
bomb_model <- "models/props_lakeside_event/bomb_temp.mdl";
touch_sound <- "MVM.MoneyPickup";
explode_sound <- "Weapon_LooseCannon.Explode";

foreach (model in cash_models)
	PrecacheModel(model);
local bomb_modelindex = PrecacheModel(bomb_model);
PrecacheScriptSound(touch_sound);
PrecacheScriptSound(explode_sound);

spawn_rate <- RemapValClamped(Ware_MinigamePlayers.len().tofloat(), 0.0, 16.0, 0.5, 0.02);

local cash_spawned = 0;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, null);

	foreach (data in Ware_MinigamePlayers)
		data.player.SetCurrency(0);
		
	ForceEnableUpgrades(2);
	Ware_CreateTimer(@() CreateMoney(), 0.5);
}

function CreateMoney()
{
	if (cash_spawned < 100)
	{
		local origin = Vector(
			RandomFloat(Ware_MinigameLocation.mins.x + 50.0, Ware_MinigameLocation.maxs.x - 50.0),
			RandomFloat(Ware_MinigameLocation.mins.y + 50.0, Ware_MinigameLocation.maxs.y - 50.0),
			Ware_MinigameLocation.center.z + 500.0);
		
		local idx = RandomIndex(cash_models);
		
		local cash = Ware_SpawnEntity("prop_physics_override", 
		{
			origin = origin,
			model  = cash_models[idx],
			disableshadows = true,
			minhealthdmg = INT_MAX, // don't destroy on touch
			spawnflags = 16, // break on touch	
		});
		
		if (RandomInt(0, 5) == 0)
		{
			SetPropInt(cash, "m_nModelIndex", bomb_modelindex);
			EntFireByHandle(cash, "Kill", "", 7.0, null, null);
		}
		else
		{
			SetPropInt(cash, "m_iHammerID", cash_amounts[idx]);
			cash_spawned++;
		}
	}
		
	return spawn_rate;
}

function OnTakeDamage(params)
{
	local victim = params.const_entity;
	if (victim.IsPlayer())
	{
		if (params.damage_type & DMG_SLASH)
		{
			// the attacker is the player, so recover the true attacker from the damage position
			local attacker = Entities.FindByClassnameNearest("prop_physics", params.damage_position, 0.0);
			if (attacker && !attacker.IsEFlagSet(EFL_USER))
			{
				attacker.AddEFlags(EFL_USER);
				// the kill must be postponed or it may crash because this damage runs from a physics callback
				EntFireByHandle(attacker, "Kill", "", -1, null, null);
					
				if (GetPropInt(attacker, "m_nModelIndex") == bomb_modelindex)
				{
					DispatchParticleEffect("ExplosionCore_MidAir", victim.GetOrigin(), Vector());
					attacker.EmitSound(explode_sound);
					victim.TakeDamage(1000, DMG_BLAST, attacker);
				}
				else
				{	
					local modelname = attacker.GetModelName();
					
					cash_spawned--;
									
					victim.EmitSound(touch_sound);
					victim.AddCurrency(GetPropInt(attacker, "m_iHammerID"));		
					if (victim.GetCurrency() >= 500)
						Ware_PassPlayer(victim, true);
				}
			}
				
			return false;
		}
	}
}

function OnEnd()
{
	local highest_amount = 0;
	local highest_player;
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local currency = player.GetCurrency();
		if (currency > highest_amount)
		{
			highest_amount = currency;
			highest_player = player;
		}
	}
	
	if (highest_player)
		Ware_ChatPrint(null, "{player} {color}is the richest with ${int} collected!", highest_player, TF_COLOR_DEFAULT, highest_amount);
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
		data.player.SetCurrency(0);
		
	ForceEnableUpgrades(0);
}