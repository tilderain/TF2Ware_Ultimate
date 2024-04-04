minigame <- Ware_MinigameData();
minigame.name = "Caber King"
minigame.description = "Survive!"
minigame.duration = 3.5;
minigame.music = "falling";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_delay = 0.5;
minigame.custom_overlay = "survive";

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Ullapool Caber");
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_BLAST)
	{
		params.damage = 100;
		params.damage_type = params.damage_type & (~DMG_SLOWBURN); // no falloff
	}
}