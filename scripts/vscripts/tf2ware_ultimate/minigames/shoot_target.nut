local mode = RandomInt(0, 1);

local target_names, target_class;
local gift_model = "models/tf2ware_ultimate/gift.mdl";
local hit_sound = "Player.HitSoundBeepo";

if (mode == 0)
{
	target_names = ["Scout", "Soldier", "Pyro", "Demoman", "Heavy", "Engineer", "Medic", "Sniper", "Spy"];
	foreach (name in target_names)
		PrecacheModel(format("models/props_training/target_%s.mdl", name.tolower()));
	target_class = target_names[RandomInt(0, target_names.len() - 1)];
}
else if (mode == 1)
{
	PrecacheModel(gift_model);
	PrecacheScriptSound(hit_sound);
}

minigame <- Ware_MinigameData();
minigame.name = "Shoot Target";
minigame.location = "targetrange";
minigame.no_collisions = true;

if (mode == 0)
{
	minigame.duration = 4.0;
	minigame.music = "cheerful";
	minigame.description = format("Shoot the %s target!", target_class);
	minigame.custom_overlay = "shoot_target_" + target_class.tolower();
}
else if (mode == 1)
{
	minigame.duration = 29.9
	minigame.music = "pumpit";
	minigame.description = "Shoot the Gift 10 times!";
	minigame.custom_overlay = "shoot_gift_10";
	minigame.convars =
	{
		// make this easier on higher timescales or its near impossible
		phys_timescale = RemapValClamped(Ware_TimeScale, 1.0, 2.0, 1.0, 0.6),	
	}
}

function OnStart()
{
	if (RandomInt(0, 1) == 1)
		Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Sniper Rifle");	
	else
		Ware_SetGlobalLoadout(TF_CLASS_SPY, "Revolver");
		
	if (mode == 0)
	{
		local indices = [0, 1, 2, 3, 4];
		Shuffle(indices);
		
		local target_count = RandomInt(1, 5);
		for (local i = 0; i < target_count; i++)
		{
			local line = Ware_MinigameLocation.lines[indices[i]];
			local name = i == 0 ? target_class : target_names[RandomInt(0, target_names.len() - 1)];
			Ware_SpawnEntity("prop_dynamic",
			{
				model  = format("models/props_training/target_%s.mdl", name.tolower()),
				origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1]),
				angles = QAngle(0, -90, 0),
				solid  = SOLID_VPHYSICS,
				skin   = RandomInt(0, 1),
				health = 99999,
			});
		}
	}
	else if (mode == 1)
	{
		foreach (data in Ware_MinigamePlayers)
			Ware_GetPlayerMiniData(data.player).points <- 0;
			
		Ware_CreateTimer(@() SpawnGift(), 1.0);
	}
}

function SpawnGift()
{
	local line = Ware_MinigameLocation.lines[RandomInt(0, 4)];
	local origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1]);
	local angles = QAngle(0, -90, 0);
	local gift = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = gift_model,
		origin = origin,
		angles = angles,
		health = 99999,
	});
	gift.AddEFlags(EFL_NO_DAMAGE_FORCES);
	gift.SetPhysVelocity(Vector(RandomFloat(-500, 500), 0, RandomFloat(800, 1000)));
	EntFireByHandle(gift, "Kill", "", RemapValClamped(Ware_TimeScale, 1.0, 2.0, 1.5, 3.0), null, null);
	
	return RandomFloat(1.9, 2.3);
}

function OnTakeDamage(params)
{
	local victim = params.const_entity;
	
	if (mode == 0)
	{
		if (victim.GetClassname() == "prop_dynamic")
		{
			local attacker = params.attacker;
			if (attacker && attacker.IsPlayer())	
			{
				local class_name = victim.GetModelName().slice(29);
				class_name = class_name.slice(0, class_name.find(".mdl"));
				
				if (class_name == target_class.tolower())
					Ware_PassPlayer(attacker, true);
				else
					attacker.TakeDamageCustom(victim, victim, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_SUICIDE);
				
				EmitSoundOnClient(class_name + ".PainSevere01", attacker);			
			}
		}
	}
	else if (mode == 1)
	{
		if (victim.GetClassname() == "prop_physics")
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
		}
	}
}