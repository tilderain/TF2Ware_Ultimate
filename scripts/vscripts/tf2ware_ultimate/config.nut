Ware_Minigames <-
[
	"airblast"        
	"avoid_props"     
	"avoid_trains"    
	"backstab"        
	"bombs"           
	"build_this"      
	"break_barrel"    
	"bullseye"        
	"bumpers"         
	"caber_king"      
	"catch_cubes"     
	"catch_money"
	"change_class"    
	"count_bombs"     
	"disguise"        
	"dont_touch"      
	"double_jump"
	"extinguish"
	"flood"           
	"ghost"           
	"goomba"          
	"headshot"        
	"halloween_fight" 
	"hit_player"      
	"hit_balls"       
	"hot_potato"      
	"jarate"          
	"kamikaze"        
	"kart"            
	"land_platform"   
	"laugh"           
	"limbo"
	"math"            
	"melee_arena"     
	"merasmus"        
	"most_bombs"      
	"move"            
	"parachute"       
	"pickup_plate"    
	"piggyback"       
	"pirate"          
	"pop_jack",       
	"projectile_jump" 
	"rocket_jump"
	"rocket_rain"     
	"sap"             
	"sawrun"          
	"say_word"        
	"shark"        
	"shoot_barrel"
	"shoot_gifts"     
	"shoot_target"    
	"simon_says"      
	"spycrab"         
	"stand_near"      
	"stay_ground"     
	"street_fighter"  
	"stun"            
	"sumo"
	"swim_up"         
	"taunt_kill"      
	"touch_sky"       
	"type_color"      
	"water_war"       
]

Ware_Bossgames <-
[
	"basketball"
	"cuddly_heavies"
	"falling_platforms"
	"ghostbusters"
	"gioca_jouer"
	"grand_prix"
	"jump_rope"
	"mandrill"
	"monoculus"
	"obstacle_course"
	"slender"
	"frogger"
	"wild_west"
]

Ware_Themes <-
[
	// path           name in case we want to display it anywhere
	["_default",      "TF2Ware Ultimate"],
	["ds_jimmyt",     "Jimmy T. (DS - Touched!)"],
	["ds_orbulon"     "Orbulon (DS - D.I.Y.)"],
	["wii_katandana", "Kat & Ana (Wii)"],
	["wii_mona",      "Mona (Wii)"],
	
]

Ware_GameSounds <-
{
	default_sounds =
	[
		"boss"
		"break"
		"break_end"
		"failure"
		"failure_all"
		"gameclear"
		"gameover"
		"intro"
		"lets_get_started"
		"mapend"
		"results"
		"speedup"
		"victory"
	]
	
	themable_sounds =
	[
		"failure"
		"intro"
		"results"
		"victory"
	]
}

Ware_MinigameMusic <-
[
	"actfast" 
	"actioninsilence" 
	"adventuretime" 
	"bigjazzfinish" 
	"bliss" 
	"brassy" 
	"casino"
	"catchme" 
	"cheerful" 
	"circus" 
	"clumsy" 
	"cozy" 
	"dizzy" 
	"drumdance" 
	"falling" 
	"farm" 
	"fastbros"
	"fencing"
	"funkymoves" 
	"getmoving" 
	"getready" 
	"golden" 
	"goodtimes" 
	"heat" 
	"keepitup" 
	"knockout" 
	"letsgetquirky" 
	"limbo"
	"makemegroove" 
	"moomoofarm"
	"morning" 
	"nearend" 
	"ohno" 
	"piper" 
	"pumpit" 
	"question"
	"ringring"
	"rockingout",
	"settingthescene" 
	"sillytime" 
	"slowfox" 
	"spotlightsonyou" 
	"steadynow"
	"streetfighter" 
	"surfin" 
	"survivor" 
	"sweetdays" 
	"takeabreak" 
	"thethinker" 
	"train" 
	"undergroundbros" 
	"underwater"
	"wildwest" 
]

Ware_BossgameMusic <-
[
	"basketball"
	"cuddly"
	"effort"
	"falling"
	"frogger",
	"ghostbusters"	
	"giocajouer"
	"grandprix"
	"jumprope"
	"mandrill"
	"monoculus"
	"slender"
	"staredown"
	"steadynow"
]

foreach (sound in Ware_GameSounds.default_sounds)    PrecacheSound(format("tf2ware_ultimate/music_game/_default/%s.mp3", sound))
foreach (sound in Ware_MinigameMusic)                PrecacheSound(format("tf2ware_ultimate/music_minigame/%s.mp3", sound))
foreach (sound in Ware_BossgameMusic)                PrecacheSound(format("tf2ware_ultimate/music_bossgame/%s.mp3", sound))