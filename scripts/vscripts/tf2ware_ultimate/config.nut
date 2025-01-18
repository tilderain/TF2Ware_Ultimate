// TODO: load these from a file

Ware_BossThreshold      <- 20    // amount of minigames played before boss
Ware_SpeedUpThreshold   <- 5     // number of minigames before applying speedup
Ware_SpeedUpInterval    <- 0.15  // speedup factor
Ware_SpecialRoundChance <- 10    // e.g. 20 means 1 in 20 chance of a special round happening. set to 0 to disable.
Ware_PointsMinigame     <- 1     // points for winning a minigame
Ware_PointsBossgame     <- 5     // points for winning a bossgame
Ware_BonusPoints        <- false // Whether or not bonus points will be awarded. If false this is still available as a special round.

Ware_Minigames <-
[
	"airblast"        
	"avoid_props"     
	"avoid_trains"    
	"backstab"        
	"basketball"
	"bombs"          
	"boxing"
	"break_barrel"
	"break_box"
	"build_this"      
	"bullseye"        
	"bumpers"         
	"caber_king"      
	"catch_cubes"     
	"catch_money"     
	"change_class"    
	"count_bombs"     
	"disguise"
	"dodge_laser"
	"dont_touch"      
	"double_jump"     
	"extinguish"      
	"flipper_ball"    
	"flood"           
	"ghost"           
	"goomba"          
	"grapple_cutout"     
	"grapple_player"
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
	"eat_plate"    
	"piggyback"       
	"pirate"
	"pole_stack"
	"pop_jack"        
	"projectile_jump" 
	"rocket_jump"     
	"rocket_rain"     
	"sandvich"
	"sap"             
	"sawrun"
	"shark"           
	"shoot_barrel"    
	"shoot_gifts"     
	"shoot_target"    
	"simon_says"
	"sniper_war"
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
	"trivia"
	"type_color"
	"type_time"
	"type_word"        
	"watch_fall"
	"water_war"
	"witch"
]

Ware_Bossgames <-
[
	"beep_block"
	"cuddly_heavies"
	"escape_factory"
	"falling_platforms"
	"frogger"
	"ghostbusters"
	"gioca_jouer"
	//"homerun_contest" // NOTE: Not ready for public test yet. Please comment out before any public tests.
	"jump_rope"
	"mandrill"
	"mercenary_kart"
	"monoculus"
	"obstacle_course"
	"slender"
	"typing"
	"wild_west"
]

Ware_SpecialRounds <-
[
	"adrenaline_shot"
	"all_in"
	"bonk"
	"bonus_points"
	"boss_rush"
	"cocanium"
	"collisions"
	"extended_round"
	"fov"
	"inclinity_problem"
	//"invisible" // TODO need a better performance implementation
	"low_gravity"
	"math_only"
	"mirrored_world"
	"no_movingback"
	"non_stop"
	"nostalgia"
	"opposite_day"
	"random_score"
	"reversed_text"
	"simon"
	//"size_matters" // TODO fix stuck issues
	"skull"
	"slow_mo"
	"sudden_death"
	"team_battles"
	"thirdperson"
	"time_attack"
	"two_bosses"
	"up_down"
	"wipeout"
	
	"trailer" // TODO: Remove after trailer is done
]

// only for precaching purposes
Ware_GameOverlays <-
[
	"__logo_text"
	"__logo_textless"
	"chalkboard"
	"countdown_1"
	"countdown_2"
	"countdown_3"
	"countdown_4"
	"countdown_5"
	"countdown_6"
	"countdown_7"
	"countdown_8"
	"countdown_9"
	"countdown_10"
	"default_boss"
	"default_failure"
	"default_failure_all"
	"default_speed"
	"default_victory"
	"default_victory_all"
	"minigame_blank"
	"slow_down"
	"special_round"
]

Ware_FakeSpecialRounds <-
[
	// imported from micro
	"Episode Three"
	"Tea Fortress 2"
	"Ghost Fortress 2"
	"Tentacle Fortress 2"
	"Awesomemod2"
	"1 Versus All"
	"Mirrors Edge"
	"Saxtoner"
	"Half-Life 3 "
	"The Hidden"
	"Gordon!"
	"Thrilling"
	"Skin Testing"
	"Scorched Cows"
	"Nuclear Warfare"
	"Spaghett"
	"Geometry Wars"
	"Project Gotham Racing 3"
	"Launch Hour"
	"Sonic 2006"
	"I Updated My F-List!"
	"Nanomachines, Son"
	"Robotnik's Potatoship"
	"Mighty Switch Force! Mega Drive Edition"
	"Harbl Hotel"
	"You're Falling For Some Big Idiot"
	"Yesterday, You Said Tomorrow So Just..."
	"Do It!!"
	"Honnouji Academy Graduation Day!!!"
	"Hardcore Really Hardcore Really Hardcore"
	"Paradise Mirage!"
	"Someone Help Me Get Me Out Of Here"
	"No Style, No Grace"
	"Get A Load Of This"
	"Ooo Banana"
	"Dong Expansion"
	"Stocking Best Waifu"
	"I'm Really Feeling It"
	"Chance Time"
	"Nudisto Beeeeeach"
	"Smoke Weed Everyday"
	"Drop It Like It's Hot"
	"Gotta Go Fast"
	"Waifu Shittalking"
	"No Waifu No Laifu"
	"It's A Me, Mario"
	"The Memes, Jack"
	"Train Rain"
	"John Madden"
	"Not The Bees"
	"#Removemaths"
	"I'll Make You Eat Those Words"
	"You're A Kid Now"
	"You're A Squid Now"
	"Spooky Scary Skeletons"
	"Rattle Me Bones"
	"Who's Been Drawing Dicks?"
	"Knock Knock It's Knuckles"
	"& Knuckles"
	"I Think We Better Think Of Something"
	"Snow Halation"
	"Love Live! Nico Nico Niinfected"
	"We Get Signal"
	"Nothing At All Different"
	"Except My Optical Specks"
	"Phantom Thieves"
	"Shujin Academy Exams"
	"Told You, You Didn't See It Coming"
	"My Mind Is Too Fast For Eyes"
	"You're Done Innnnn"
	"Oraoraoraoraoraora!"
	"Mudamudamudamudamuda!"
	"The Fat Controller"
	"Xxx Yyy Xxx Yyy"
	"Extreeeme"
	"Giant Enemy Crab"
	"Oh Shit, I'm Sorry"
	"School Prison!"
	"Green Hill Zone, Yet Again"
	"Somebody Set Us Up The Bomb"
	"Your Head A Splode"
	"Nico Nico Nii!"
	"You'll Never See It Coming"
	"Why? Why? Whyyyyy?"
	"Za Warudo"
	"Awaken My Masters!"
	"Dr. Robotnik's Mean Bean Machine"
	"You Got Boost Power!"
	"Boosto! Boosto! Boosto!"
	"Door Stuck!"
	"Bird Up!"
	"The Eric Andre Show"
	"Who Killed Hannibal?"
	"Big Guy For You"
	"100% Black"
	"Oh My God Jc A Bomb!"
	"Rip And Tear"
	"Interior Crocodile Alligator"
	"Todokete"
	"Garbage Day!"
	"Here Comes Pacman"
	"Multi-Track Drifting!"
	"Pool's Closed"
	"Aurora Borealis?"
	"Go To Bed"
	"I Ate Those Food"
	"Now Where Could My Pipe Be?"
	"Honk Honk!"
	"Aeiou"
	"John Madden!"
	"Looking Cool Joker!"
	"Big Bonus!"
	"All Holes Filled Landscaping"
	"Mekakushi Code"
	"Arms Outstretched"
	"World Is A Fuck"
	"Duwang"
	"Cans.Wav"
	"Shaun!"
	"Spurs That Jingle, Jangle, Jingle"
	"Panasonic Blu-Ray $99"
	"Let Me Test My New Nerve Gas"
	
	// we should come up with some more too, maybe take out some of the less funny ones above
	"The Flowey Map"
	"28 Stab Wounds"
	"Marioooooo?"
	"Fake Crash"
	"SCP On Raiden"
	"🇭 🇮  🇱 🇮 🇳 🇺 🇽  🇺 🇸 🇪 🇷 🇸"
	"🥹🥹🥹"
	"Giant Enemy Spider"
	"The Giant Rat Who Makes All Of The Rules"
	"Build Your Own Minigame"
	"Rules of Nature"
	"Hey Buddy I Think You Got The Wrong Door"
		
	// from forum post
	"Mandrill Maze Mayhem"
	"A Normal Round"
	"Lag Spike"
	"Family Guy Funny Moments"
	"It's Raw"
	"iFunny Watermark"
	"Feed And Seed"
	"With A Free Toy"
	"All Tables"
	"Police Have Been Called"
	"Go Outside"
	"Please Wrap It Up"
	"Source 2"
	"Instant RTV"
	"The Heavy Update"
	"Turn-Based Mode"
	"███████████████████████"
	"Power Word: Kill"
	"Live Action Remaster"
	"lolololololololol"
	"[Obscure Reference]"
	"I Waited 0.15 Seconds To Show My Message And All I Got Was This."
	"Surely This Wont Crash This Time."
	"Big Shit"
	"B1 Is Kinda Overhyped"
	"(⌐■‿■)"
	"No Fun Allowed"
	"A Wallelujah Chorus"
	"Wa-Elegy"
	"( ̿°̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ͜ʖ ̿̿̿̿̿̿̿̿̿̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿ ̿̿°̿)"
	"٠●•۩۞۩[̲̅Nσ̲̅σ̲̅Ь̲̲̅̅۰̲̅đ̲̲̅̅σ̲̅ώ̲̅ŋ̲̲̲̅̅̅]۩۞۩•●٠"
	" (ノ^_^)╯┻━┻ ┬─┬ ,( ^_^ノ)"
	"1v1 No Items Final Destination"
	"Sends You Back To Valve Servers"
	"Opening tf2_32.exe"
	"No Refunds!"
	"All Class Bison"
	"Instant Win"
	"The Entire Shrek Movie"
	"Pizza Time Lap 2"
	"[Hyperlink Blocked]"
	"Fight The Strongest Fairy"
	"$BIG WINS!!!!$"
	"Versus: Goku!"
	"Peggle...2!"
	"Type-Attack 6: The Typeining"
	"A Sisyphean Task"
	"Team Warzone 2"
	"Actually Just Warioware: Smooth Moves For the Nintendo Wii"
	"Ya LOST!!!!"
	"All of the Above"
	"Huh?"
	"Now With New Funky Mode!!!"
	"You're on Your Way to: Wutville"
	"Netflix Adaptation"
	"Persona 6"
	"Quirky Earthbound-Inspired Boss Round"
	"Player Versus Map"
	"Competitive Mode"
	"Rocket Jump!"
	"Turtle Only"
	"Randomized Music"
	"High Gravity"
	"trade_plaza Sniper Battle"
	"Ubisoft Tower Climbing"
	"Hi Mom"
	"Tartarus Floor 135"
	"Shoutouts To Simpleflips"
	"Battle Royale"
	"90s Drifting"
	"CPU vs. CPU"
	"Rat Cafe"
	"Magic Missile!"
	"Is he stupid?"
	"FALL OFF YOUR VERY ARMS"
	"That's obese! :D"
	"Mann in the Machine"
	"I heard you're pretty strong"
	"$400,000"
	"23 CLEAR MOVIES"


]

Ware_Themes <-
[
	{
		theme_name = "_default"
		visual_name = "TF2Ware Ultimate"
		sounds = {
			// if any are 0.0 they arent used for intermission timings yet
			// some like "results" will never be greater than 0.0 as it stops playing automatically on restart
			"boss":             4.0
			"failure":          2.0
			"failure_all":      2.0
			"gameclear":        5.0 // these two dont use the duration, it's always 5 seconds after this when results play
			"gameover":         5.0 // ''
			"intro":            4.0
			"lets_get_started": 0.0
			"mapend":           0.0
			"results":          0.0
			"special_round":    15.2 // "Feline Fever ~ Jimmy T - Intro Cutscene" from Warioware Smooth Moves
			"speedup":          4.5
			"victory":          2.0
		}
	},
	
	{
		theme_name = "_tf2ware_classic"
		visual_name = "TF2Ware Classic" // one of the OG slagware themes, this one seems to be original to tf2ware.
		sounds = {
			"failure": 2.377
			"intro":   2.5
			"speedup": 3.250
			"victory": 2.325
		}
	},
	
	{
		theme_name = "3ds_ashley"
		visual_name = "Ashley (3DS)"
		sounds = {
			"failure": 1.968
			"intro":   2.019
			"results": 0.0
			"victory": 2.017
		}
	},
	
	{
		theme_name = "3ds_jimmyt"
		visual_name = "Jimmy T. (3DS)"
		sounds = {
			"failure": 2.08
			"intro":   2.2
			"results": 0.0
			"victory": 2.08
		}
	},
	
	{
		theme_name = "ds_diy_orbulon"
		visual_name = "Orbulon (DS - D.I.Y.)"
		sounds = {
			"boss":     4.119
			"failure":  2.034
			"gameover": 4.267
			"intro":    2.126
			"results":  0.0
			"speedup":  4.3
			"victory":  2.100
		}
	},
	
	{
		theme_name = "ds_diy_shuffle"
		visual_name = "Shuffle (DS - D.I.Y.)"
		sounds = {
			"boss":     4.008
			"failure":  1.9
			"gameover": 4.091
			"intro":    2.039
			"results":  0.0
			"speedup":  3.8
			"victory":  1.997
		}
	},
	
	{
		theme_name = "ds_diy_warioman" // from DIY showcase, should that be counted separately?
		visual_name = "Wario-Man (DS - D.I.Y.)" // another of the classic tf2ware themes, this is one of the ones used in tonyware
		sounds = {
			"boss":     4.004
			"failure":  2.040
			"gameover": 4.309
			"intro":    2.4
			"results":  8.329
			"speedup":  4.001
			"victory":  2.007
		}
	},
	
	{
		theme_name = "ds_touched_jimmyt"
		visual_name = "Jimmy T. (DS - Touched!)"
		sounds = {
			"failure": 2.1
			"intro":   2.183
			"results": 0.0
			"victory": 2.020
		}
	},
	
	{
		theme_name = "ds_touched_wario"
		visual_name = "Wario (DS - Touched!)"
		sounds = {
			"failure": 2.003
			"intro":   2.067
			"results": 0.0
			"victory": 2.05
		}
	},
	
	{
		theme_name = "ds_touched_warioman"
		visual_name = "Wario-Man (DS - Touched!)"
		sounds = {
			"failure": 1.977
			"intro":   2.252
			"results": 0.0
			"victory": 2.0
		}
	},
	
	{
		theme_name = "wii_9volt"
		visual_name = "9-Volt (Wii)"
		sounds = {
			"failure": 2.013
			"intro":   4.025
			"results": 0.0
			"victory": 1.999
		}
	},
	
	{
		theme_name = "wii_18volt"
		visual_name = "18-Volt (Wii)" // this is just the 9volt intro cutscene, but it's a tonyware classic. dunno what else to call it.
		sounds = {
			"failure":  2.005
			"gameover": 4.932
			"intro":    3.992
			"speedup":  7.122
			"victory":  2.003
		}
	},
	
	{
		theme_name = "wii_katandana"
		visual_name = "Kat & Ana (Wii)"
		sounds = {
			"failure": 2.00
			"intro":   4.000
			"results": 0.0
			"victory": 2.115
		}
	},
	
	{
		theme_name = "wii_mona"
		visual_name = "Mona (Wii)"
		sounds = {
			"failure": 2.000
			"intro":   4.1
			"results": 0.0
			"victory": 2.097
		}
	},
]

Ware_InternalThemes <-
[
	// these aren't rolled and should never be set as Ware_Theme, but rather Ware_SetupThemeSounds() checks for them
	// they still get a visual name just in case
	{
		theme_name = "3ds"
		visual_name = "WarioWare Gold (3DS)"
		sounds = {
			"boss":      4.4
			"gameclear": 3.292
			"gameover":  3.371
			"speedup":   4.3
		}
	},
	
	{
		theme_name = "ds_touched"
		visual_name = "WarioWare: Touched! (DS)"
		sounds = {
			"boss":      4.519
			"gameclear": 3.579
			"gameover":  3.684
			"results":   0.0
			"speedup":   4.388
		}
	},
]

Ware_MinigameMusic <-
[
	"actfast" 
	"actioninsilence" 
	"adventuretime" 
	"bigjazzfinish" 
	"bliss" 
	"boxfight"
	"brassy" 
	"casino"
	"catchme" 
	"cheerful" 
	"circus" 
	"clumsy" 
	"countdown"
	"cozy"
	"digging"
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
	"march"
	"moomoofarm"
	"morning" 
	"nearend" 
	"ohno" 
	"piper" 
	"pumpit" 
	"question"
	"ridealong"
	"ringring"
	"rockingout"
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
	"urgent"
	"wildwest"
	"witchhour"
]

Ware_BossgameMusic <-
[
	"beepblockskyway"
	"beepblockskyway-twelve"
	"cuddly"
	"effort"
	"escape_factory"
	"falling"
	"frogger"
	"ghostbusters"
	"ghostbusters-bustin"
	"giocajouer"
	"grandprix"
	"homerun_contest"
	"jumprope"
	"mandrill"
	"monoculus"
	"slender"
	"staredown"
	"steadynow"	
	"typing-hga"
	"typing-hvd"
	"typing-lod"
	"typing-pta"
	"typing-spc"
	"typing-tuh"
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
	// boston basher
	[325] = 
	{ 
		"hit self on miss" : 0,
	},	
	// discipilinary action
	[447] =
	{ 
		"speed buff ally" : 0,
		"melee range multiplier" : 1,
		"melee bounds multiplier" : 1,
	},
	// half-zatoichi
	[357] = 
	{ 
		"honorbound" : 0
		"restore health on kill" : 0
	},
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
		"self mark for death" : 0,
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
	// killing gloves of boxing
	[43] =
	{ 
		"critboost on kill" : 0,
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

// keep updated with latest map version suffix
// also remember to update the suffixes of the files in /maps
const WARE_MAPVERSION = "b9"

// everytime music is changed AND the map is *publicly* updated
// this must be incremented to prevent caching errors
// if you change this make sure to update any sounds in level_sounds.txt too!
const WARE_MUSICVERSION = 1

foreach (sound in Ware_MinigameMusic) PrecacheSound(format("tf2ware_ultimate/v%d/music_minigame/%s.mp3", WARE_MUSICVERSION, sound))
foreach (sound in Ware_BossgameMusic) PrecacheSound(format("tf2ware_ultimate/v%d/music_bossgame/%s.mp3", WARE_MUSICVERSION, sound))

// precache theme sounds
foreach(theme in Ware_Themes)
{
	foreach(key, value in theme.sounds)
		PrecacheSound(format("tf2ware_ultimate/v%d/music_game/%s/%s.mp3", WARE_MUSICVERSION, theme.theme_name, key))
}
foreach(theme in Ware_InternalThemes)
{
	foreach(key, value in theme.sounds)
		PrecacheSound(format("tf2ware_ultimate/v%d/music_game/%s/%s.mp3", WARE_MUSICVERSION, theme.theme_name, key))
}
