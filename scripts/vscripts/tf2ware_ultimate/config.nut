Ware_BossThreshold     <- 20
Ware_SpeedUpThreshold  <- 5
Ware_SpeedUpInterval   <- 0.15

Ware_Minigames <-
[
	"airblast"        
	"avoid_props"     
	"avoid_trains"    
	"backstab"        
	"bombs"           
	"break_barrel"    
	"build_this"      
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
	"flipper_ball"    
	"flood"           
	"ghost"           
	"goomba"          
	"grapple_cow"     
	"halloween_fight" 
	"headshot"        
	"hit_balls"       
	"hit_player"      
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
	"pop_jack"        
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
	"treasure_hunt"   
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

Ware_GameSounds <-
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
	"speedup"
	"victory"
]

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

Ware_MeleeAttributeOverrides <- 
{
	// atomizer
	[450] = { "air dash count" : 0 },
	// sandman
	[44] = { "max health additive penalty" : 0 },
	// candy cane
	[317] = 
	{ 
		"drop health pack on kill" : 0,
		"dmg taken from blast increased" : 1,
	},
	// discipilinary action
	[447] =
	{ 
		"speed buff ally" : 0,
		"melee range multiplier" : 1,
		"melee bounds multiplier" : 1,
	},
	// half-zatoichi
	[357] = { "honorbound" : 0 },
	// equalizer
	[128] = 
	{ 
		"mod shovel damage boost" : 0,
		"reduced_healing_from_medics" : 1,
	},
	// escape plan
	[775] = 
	{ 
		"mod shovel speed boost" : 0,
		"reduced_healing_from_medics" : 1,
		"self mark for deat" : 0,
	},
	// pain train
	[154] = { "dmg taken from bullets increased" : 1 },	
	// powerjack
	[214] = { "move speed bonus" : 1 },	
	// eyelander
	[132] = { "max health additive penalty" : 0 },
	// festive eyelander
	[1082] = { "max health additive penalty" : 0 },
	// nessie's nine iron
	[482] = { "max health additive penalty" : 0 },
	// HHH axe
	[266] = { "max health additive penalty" : 0 },	
	// scotman's skullcutter
	[172] = { "move speed penalty" : 1 },	
	// persian persuader
	[404] = 
	{
		"maxammo primary reduced" : 1,
		"maxammo secondary reduced" : 1,
	},	
	// claidheamohmor
	[327] = 
	{
		"dmg taken increased" : 1,
		"maxammo secondary reduced" : 1,
	},		
	// eviction notice
	[426] =
	{ 
		"mult_player_movespeed_active" : 1,
		"mod_maxhealth_drain_rate" : 0,
		"fire rate bonus" : 1.0,
	},	
	// gloves of running urgently
	[239] =
	{ 
		"single wep holster time increased" : 1,
		"mult_player_movespeed_active" : 1,
		"mod_maxhealth_drain_rate" : 0,
	},	
	// festive gloves of running urgently
	[1084] =
	{ 
		"single wep holster time increased" : 1,
		"mult_player_movespeed_active" : 1,
		"mod_maxhealth_drain_rate" : 0,
	},	
	// fists of steel
	[331] =
	{ 
		"dmg from ranged reduced" : 1,
		"dmg from melee increased" : 1,
		"single wep holster time increased" : 1,
		"mult_patient_overheal_penalty_active" : 1,
		"mult_health_fromhealers_penalty_active" : 1,
	},		
	// warrior's spirit
	[310] =
	{ 
		"dmg taken increased" : 1,
		"heal on kill" :- 0,
	},		
	// holiday punch
	[656] = 
	{ 
		"crit does no damage" : 0,
		"tickle enemies wielding same weapon" : 0,
		"crit forces victim to laugh" : 0,
	},
	// HHH axe
	[266] = { "max health additive penalty" : 0 },		
	// gunslinger
	[142] = 
	{ 
		"mod wrench builds minisentry" : 0,
		"max health additive bonus" : 0,
	},
	// eureka effect
	[589] = { "alt fire teleport to spawn" : 0 },
	// southern hospitality
	[155] = { "dmg taken from fire increased" : 1 },	
	// amputator
	[304] =
	{ 
		"enables aoe heal" : 0,
		"health regen" : 0,
	},
	// vita saw
	[173] = { "max health additive penalty" : 0 },
	// bushwacka
	[232] = { "dmg taken increase" : 1 },
	// conniver's kunai
	[356] = { "max health additive penalty" : 0 },
	// spy-cicle
	[649] = { "melts in fire" : 0 },
	// big earner
	[461] = { "max health additive penalty" : 0 },
	// your eternal reward
	[225] = 
	{ 
		"disguise on backstab" : 0,
		"mod_disguise_consumes_cloak" : 0,
	},
}

foreach (sound in Ware_GameSounds)    PrecacheSound(format("tf2ware_ultimate/music_game/%s.mp3", sound))
foreach (sound in Ware_MinigameMusic) PrecacheSound(format("tf2ware_ultimate/music_minigame/%s.mp3", sound))
foreach (sound in Ware_BossgameMusic) PrecacheSound(format("tf2ware_ultimate/music_bossgame/%s.mp3", sound))