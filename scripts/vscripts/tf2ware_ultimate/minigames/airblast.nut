minigame <- Ware_MinigameData
({
	name          = "Airblast"
	author		  = "ficool2"	
	description   = "Airblast!"
	duration      = 4.0
	end_delay     = 0.5
	location      = "circlepit"
	music         = "clumsy"
	min_players   = 2
	start_pass    = true
	allow_damage  = true
	fail_on_death = true
	convars       =
	{
		tf_airblast_cray_power = 1000
	}
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower")
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
		Ware_DisablePlayerPrimaryFire(data.player)
}