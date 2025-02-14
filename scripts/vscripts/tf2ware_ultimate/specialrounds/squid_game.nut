special_round <- Ware_SpecialRoundData
({
	name = "Squid Game"
	author = "tilderain"
	description = "You can always kill people!"
	category = ""
	friendly_fire = true
	allow_damage = true
	force_pvp_damage = true
})

function OnMinigameStart()
{
	Ware_Minigame.allow_damage = true
	Ware_Minigame.friendly_fire = true
	foreach (player in Ware_MinigamePlayers)
	{
		player.RemoveSolidFlags(FSOLID_NOT_SOLID)
		Ware_GivePlayerWeapon(player, "Candy Cane", {}, false)
		player.RemoveCustomAttribute("no_attack")
	}

}
