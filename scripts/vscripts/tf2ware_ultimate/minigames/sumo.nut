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
	duration      = 15.0
	end_delay     = 0.5
	description   = "Push Away the Enemies!"
	location      = RandomElement(arenas)
	min_players   = 2
	allow_damage  = true
	fail_on_death = true
	start_pass    = true
	convars       =
	{
		tf_halloween_kart_fast_turn_speed = 200
		tf_halloween_kart_impact_force = "2f"
	}
})

function OnStart()
{
	Ware_SetGlobalCondition(TF_COND_HALLOWEEN_KART)
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0
}
