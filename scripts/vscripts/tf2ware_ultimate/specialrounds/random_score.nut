
special_round <- Ware_SpecialRoundData
({
	name = "Randomized Scores"
	author = "pokemonPasta"
	description = "Each minigame will be worth a random amount of points."
})

random_score <- 0

function OnBeginIntermission(is_boss)
{
	random_score = RandomInt(1, 20)
	if (RandomInt(0, 14) == 0)
		random_score *= -1
	
	Ware_ShowText(Ware_Players, CHANNEL_MINIGAME, format("The next %s will be worth %d point%s", 
		is_boss ? "boss" : "minigame", random_score, random_score == 1 ? "" : "s"), Ware_GetThemeSoundDuration("intro"))
	
	Ware_PlayGameSound(null, "intro")
	foreach (player in Ware_Players)
	{
		Ware_ShowScreenOverlay(player, null)
		Ware_ShowScreenOverlay2(player, null)
	}
	
	CreateTimer(@() Ware_StartMinigame(is_boss), Ware_GetThemeSoundDuration("intro"))
}

function OnCalculateScore(data)
{
	if (data.passed)
		data.score += random_score
}