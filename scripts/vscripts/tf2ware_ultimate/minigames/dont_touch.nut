minigame <- Ware_MinigameData
({
	name          = "Don't Touch Anyone"
	author        = ["Gemidyne", "pokemonPasta"]
	description   = "Don't Touch Anyone!"
	duration      = 6.0
	end_delay     = 0.5
	music         = "takeabreak"
	min_players   = 2
	start_pass    = true
	allow_damage  = true
	fail_on_death = true
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Force-a-Nature")
	foreach (player in Ware_MinigamePlayers)
	{		
		player.SetHealth(player.GetMaxHealth() * 5)
		
		local weapon = player.GetActiveWeapon()
		if (weapon == null)
			continue
		
		weapon.SetClip1(1)
		Ware_SetPlayerAmmo(player, TF_AMMO_PRIMARY, 0)
	}
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_CLUB)
		return false
}

function OnPlayerTouch(player1, player2)
{
	if (Ware_GetMinigameTime() < 1.5) // grace period
		return
		
    if (player1)
        player1.TakeDamage(1000.0, DMG_BULLET, player2)
}
