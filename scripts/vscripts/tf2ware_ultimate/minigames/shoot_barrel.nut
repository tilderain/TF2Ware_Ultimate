minigame <- Ware_MinigameData();
minigame.name = "Shoot 10 Gifts";
minigame.description = "Shoot the Barrel!";
minigame.location = "targetrange";
minigame.no_collisions = true;
minigame.duration = 5.0;
minigame.music = "wildwest";
minigame.custom_overlay = "shoot_barrel";

local barrel_model = "models/props_farm/wooden_barrel.mdl";
local hit_sound = "Player.HitSoundBeepo";

PrecacheModel(barrel_model);
PrecacheScriptSound(hit_sound);

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Reserve Shooter");	

	Ware_CreateTimer(@() SpawnBarrel(), 0.1);
}

function SpawnBarrel()
{
	local lines = Ware_MinigameLocation.lines;
	local line = lines[RandomIndex(lines)];
	local origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1]);
	local angles = QAngle(0, -90, 0);
	local barrel = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = barrel_model,
		origin = origin,
		angles = angles,
		health = 1,
	});
	barrel.AddEFlags(EFL_NO_DAMAGE_FORCES);
	barrel.SetPhysVelocity(Vector(RandomFloat(-700, 700), 0, RandomFloat(1000, 1100)));
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker;
		if (attacker && attacker.IsPlayer())	
		{
			EmitSoundOnClient(hit_sound, attacker);
			Ware_PassPlayer(attacker, true);
			return false;
		}	
	}
}