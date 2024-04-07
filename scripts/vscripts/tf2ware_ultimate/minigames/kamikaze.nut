minigame <- Ware_MinigameData();
minigame.name = "Kamikaze";
minigame.description = "Avoid the Kamikaze!"
minigame.description2 = "Explode 2 players!"
minigame.duration = 4.0;
minigame.music = "falling";
minigame.min_players = 3;
minigame.end_delay = 0.5;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.custom_overlay = "avoid_kamikaze";
minigame.custom_overlay2 = "explode_players";

local bomb_model = "models/custom/dirty_bomb_cart.mdl";
local bomb_sound = "pl_hoodoo/alarm_clock_ticking_3.wav";
local bomb_particle = "rocketpack_exhaust_smoke";
local warning_sound = "items/cart_explode_trigger.wav";
local explode_particle = "hightower_explosion";
local explode_sound = "items/cart_explode.wav";
local kamikaze;
local players_killed = 0;
local player_threshold = 2;

local bomb;
PrecacheModel(bomb_model);
PrecacheSound(bomb_sound);
PrecacheSound(warning_sound);
PrecacheSound(explode_sound);

function OnStart()
{
	kamikaze = Ware_MinigamePlayers[RandomIndex(Ware_MinigamePlayers)].player;
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		if (player == kamikaze)
		{
			Ware_PassPlayer(player, false);
			Ware_SetPlayerMission(player, 2);
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS);		
			EmitSoundOn(bomb_sound, player);
			
			local particle = Ware_SpawnEntity("info_particle_system",
			{
				origin = player.EyePosition(),
				effect_name = bomb_particle,
				start_active = true
			});
			
			EntFireByHandle(particle, "SetParent", "!activator", -1, player, null);
			
			bomb = Ware_SpawnWearable(player, bomb_model);
			SetPropInt(bomb, "m_fEffects", 0);
			SetEntityParent(bomb, player, "flag");
		}
		else
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT);
		}
	}	
}

function OnEnd()
{
	if (kamikaze.IsValid())
	{		
		local kamikaze_pos = kamikaze.GetOrigin();
		local particle = Ware_SpawnEntity("info_particle_system",
		{
			origin = kamikaze_pos
			effect_name = explode_particle,
			start_active = true
		});
		
		kamikaze.EmitSound(explode_sound);
		Ware_RadiusDamagePlayers(kamikaze_pos, 700.0, 350.0, kamikaze);
		ScreenShake(kamikaze_pos, 1024.0, 25.0, 2.5, 4096.0, 0, true);
	}
	
	if (bomb.IsValid())
		bomb.Destroy();
}

function OnTakeDamage(params)
{
	return (params.damage_type & DMG_BLAST) != 0;
}

function OnPlayerDeath(params)
{
	local victim = GetPlayerFromUserID(params.userid);

	if (params.damagebits & DMG_BLAST)
	{
		players_killed++;
		if (players_killed > player_threshold && kamikaze.IsValid())
			Ware_PassPlayer(kamikaze, true);
	}
	
	if (victim != kamikaze)
		Ware_PassPlayer(victim, false);
}