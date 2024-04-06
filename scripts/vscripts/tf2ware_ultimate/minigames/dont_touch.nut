
minigame <- Ware_MinigameData();
minigame.name = "Don't Touch Anyone";
minigame.description = "Don't Touch Anyone!";
minigame.duration = 6.0;
minigame.music = "takeabreak";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_delay = 0.5;
minigame.convars =
{
	mp_friendlyfire = 1
};

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Force-a-Nature");
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local weapon = player.GetActiveWeapon();
		
		weapon.SetClip1(1);
		Ware_SetPlayerAmmo(player, TF_AMMO_PRIMARY, 0);
	}
}

function OnPlayerTouch(player1, player2)
{
	if (player1)
		Ware_SuicidePlayer(player1);
	
	if (player2)
		Ware_SuicidePlayer(player2);
}
