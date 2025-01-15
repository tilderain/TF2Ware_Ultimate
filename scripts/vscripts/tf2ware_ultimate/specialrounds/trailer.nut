
special_round <- Ware_SpecialRoundData
({
	name = "Trailer Footage"
	author = "pokemonPasta"
	description = "This is a temporary special round just featuring minigames in the \"home\" location, and with no speedups. It'll be removed once the trailer is complete."
	
	speedup_threshold = INT_MAX // turn off speedups
})

Trailer_Minigames <- [
	"avoid_props"     
	"avoid_trains"    
	"backstab"        
	"bombs"          
	"break_barrel"
	"build_this"      
	"bullseye"        
	"caber_king"      
	"catch_money"     
	"change_class"    
	"count_bombs"     
	"disguise"
	"dodge_laser"
	"dont_touch"      
	"double_jump"     
	"extinguish"      
	"flood"           
	"ghost"           
	"goomba"          
	"grapple_player"
	"headshot"        
	"hit_player"      
	"hot_potato"      
	"jarate"          
	"kamikaze"        
	"laugh"           
	"math"            
	"merasmus"        
	"most_bombs"      
	"move"            
	"projectile_jump" 
	"rocket_rain"     
	"sandvich"
	"sap"             
	"simon_says"
	"spycrab"         
	"stand_near"      
	"stay_ground"     
	"stun"            
	"swim_up"         
	"touch_sky"       
	"type_color"
	"type_word"        
	"water_war"
	"witch"
]

Trailer_MinigameRotation <- []

function GetMinigameName(is_boss)
{
	if (is_boss)
		return null
	
	if (Trailer_MinigameRotation.len() == 0)
	{
		Trailer_MinigameRotation = clone(Trailer_Minigames)
	}
	
	return RemoveRandomElement(Trailer_MinigameRotation)
}
