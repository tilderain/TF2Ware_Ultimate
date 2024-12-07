arenas <-
[
	"circlepit"
	"sumobox"
]

minigame <- Ware_MinigameData
({
	name          = "Sumo Kart"
	author        = "pokemonPasta"
	music         = "underwater"
	duration      = 14.0
	end_delay     = 0.5
	description   = "Push Away the Enemies!"
	location      = RandomElement(arenas)
	min_players   = 2
	allow_damage  = true
	fail_on_death = true
	start_pass    = true
	start_freeze  = true
	collisions    = true
	convars       =
	{
		tf_halloween_kart_fast_turn_speed = 200
		tf_halloween_kart_impact_force = "1.25f"
	}
	
	max_scale = 1.0
})

function OnStart()
{
	Ware_SetGlobalCondition(TF_COND_HALLOWEEN_KART)
}

function OnCheckEnd()
{
	return Ware_GetAlivePlayers().len() == 1
}
