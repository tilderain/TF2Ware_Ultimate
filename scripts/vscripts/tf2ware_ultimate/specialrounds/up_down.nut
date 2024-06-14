
special_round <- Ware_SpecialRoundData
({
	name = "Up and Down"
	author = "pokemonPasta"
	description = "The speed will change randomly throughout the round."
})

function OnSpeedup()
{
	CreateTimer(@() Ware_BeginIntermission(false), 0.0)
}

function OnBeginIntermission(is_boss)
{
	// TODO: allow random speed for bosses when gioca jouer is fixed
	// prefer bosses to have random timescale like in micro as it's fun to occasionally have to do them at a different speed like that,
	// but gioca jouer just doesn't work at different scales.
	// ideally also fix beep block at different scales, but that's less of a problem.
	if (is_boss)
		Ware_SetTimeScale(1.0)
	else
		Ware_SetTimeScale(RandomFloat(0.6, 2.0))
	
	foreach (player in Ware_Players)
		{
			Ware_PlayGameSound(player, "intro")
			Ware_ShowScreenOverlay(player, null)
			Ware_ShowScreenOverlay2(player, null)
		}
		
	CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
}
