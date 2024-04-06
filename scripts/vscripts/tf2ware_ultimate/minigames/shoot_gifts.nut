local gift_model = "models/tf2ware_ultimate/gift.mdl";
local hit_sound = "Player.HitSoundBeepo";

PrecacheModel(gift_model);
PrecacheScriptSound(hit_sound);

minigame <- Ware_MinigameData();
minigame.name = "Shoot 10 Gifts";
minigame.location = "targetrange";
minigame.no_collisions = true;
minigame.duration = 29.9
minigame.music = "pumpit";
minigame.description = "Shoot the Gift 10 times!";
minigame.custom_overlay = "shoot_gift_10";
minigame.convars =
{
	// make this easier on higher timescales or its near impossible
	phys_timescale = RemapValClamped(Ware_TimeScale, 1.0, 2.0, 1.0, 0.6),	
}

function OnStart()
{
	if (RandomInt(0, 1) == 1)
		Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Sniper Rifle");	
	else
		Ware_SetGlobalLoadout(TF_CLASS_SPY, "Revolver");
		
	foreach (data in Ware_MinigamePlayers)
		Ware_GetPlayerMiniData(data.player).points <- 0;
			
	Ware_CreateTimer(@() SpawnGift(), 1.0);
}

function SpawnGift()
{
	local lines = Ware_MinigameLocation.lines;
	local line = lines[RandomIndex(lines)];
	local origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1]);
	local angles = QAngle(0, -90, 0);
	local gift = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = gift_model,
		origin = origin,
		angles = angles,
	});
	gift.AddEFlags(EFL_NO_DAMAGE_FORCES);
	gift.SetPhysVelocity(Vector(RandomFloat(-500, 500), 0, RandomFloat(800, 1000)));
	EntFireByHandle(gift, "Kill", "", RemapValClamped(Ware_TimeScale, 1.0, 2.0, 1.5, 3.0), null, null);
	
	return RandomFloat(1.9, 2.3);
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker;
		if (attacker && attacker.IsPlayer())	
		{
			local minidata = Ware_GetPlayerMiniData(attacker);
			minidata.points++;
			
			EmitSoundOnClient(hit_sound, attacker);
			
			if (minidata.points >= 10)
				Ware_PassPlayer(attacker, true);
		}
		
		return false;
	}
}