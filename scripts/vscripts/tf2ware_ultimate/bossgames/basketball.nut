minigame <- Ware_MinigameData();
minigame.name = "Basketball";
minigame.description = "Score 7 Goals!";
minigame.custom_overlay = "score_goals_7";
minigame.duration = 31.4;
minigame.location = "ballcourt";
minigame.music = "basketball";
minigame.start_pass = false;
minigame.no_collisions = true;

local trigger;

local hoop_sound = "Halloween.PumpkinDrop";
local prop_model = "models/props_training/target_demoman.mdl";

PrecacheScriptSound(hoop_sound);
PrecacheModel(prop_model);

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Grenade Launcher");
	
	foreach (data in Ware_MinigamePlayers)
	{
		// make grenades pass through
		SetPropInt(data.player, "m_takedamage", DAMAGE_NO);
		Ware_GetPlayerMiniData(data.player).points <- 0;
	}
	
	EntFire("boss4_door", "Unlock");	
	EntFire("boss4_door", "Open");
		
	trigger = FindByName(null, "basketball_trigger");
	MarkForPurge(trigger);
	trigger.ValidateScriptScope();
	trigger.GetScriptScope().OnHoopTouch <- OnHoopTouch;
	trigger.ConnectOutput("OnStartTouch", "OnHoopTouch");
	
	local prop = Ware_SpawnEntity("prop_dynamic_override",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 850, 0),
		angles = QAngle(0, -90, 0),
		model  = prop_model,
		health = 300,
		OnBreak = "barkley,Disable"
	});
}

function OnHoopTouch()
{
	local owner = GetPropEntity(activator, "m_hThrower");
	if (owner)
	{	
		EmitSoundOnClient(hoop_sound, owner);
		if (++Ware_GetPlayerMiniData(owner).points >= 7)
			Ware_PassPlayer(owner, true);
		activator.Kill();
	}
}

function OnUpdate()
{
	for (local grenade; grenade = FindByClassname(grenade, "tf_projectile_pipe");)
	{
		MarkForPurge(grenade);	
		grenade.RemoveSolidFlags(FSOLID_TRIGGER);
		grenade.KeyValueFromString("classname", "ware_projectile_pipe");
	}
}

function OnEnd()
{
	EntFire("barkley", "Enable");
	EntFire("boss4_door", "Close");
 	EntFire("boss4_door", "Lock");	
	
	trigger.DisconnectOutput("OnStartTouch", "OnHoopTouch");
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
		SetPropInt(data.player, "m_takedamage", DAMAGE_YES);
}