minigame <- Ware_MinigameData();
minigame.name = "Parachute";
minigame.description = "Land on the Platform!"
minigame.duration = 6.0;
minigame.location = "boxarena";
minigame.music = "dizzy";
minigame.thirdperson = true;
minigame.convars = 
{
	tf_parachute_deploy_toggle_allowed = 1
}

local platform_model = "models/props_coldfront/waste_base.mdl";
PrecacheModel(platform_model);
local platform;

function OnStart()
{
	Ware_SetGlobalLoadout(RandomInt(0, 1) ? TF_CLASS_SOLDIER : TF_CLASS_DEMOMAN, "B.A.S.E. Jumper");
	
	platform = Ware_SpawnEntity("prop_dynamic",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 0, 286),
		model = platform_model,
		solid = SOLID_VPHYSICS,
	})
}

function OnTeleport()
{
	Ware_TeleportPlayersCircle(Ware_MinigameLocation.center + Vector(0, 0, 800), 512.0);
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (GetPropEntity(player, "m_hGroundEntity") == platform)
			Ware_PassPlayer(player, true);
	}
}