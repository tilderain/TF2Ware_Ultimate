// 1 - enabled, 0 - disabled
Ware_Minigames <-
[
	[1, "airblast"        ],
	[1, "avoid_props"     ],
	[1, "backstab"        ],
	[1, "bombs"           ],
	[1, "break_barrel"    ],
	[1, "bullseye"        ],
	[1, "bumpers"         ],
	[1, "caber_king"      ],
	[1, "flood"           ],
	[1, "goomba"          ],
	[1, "headshot"        ],
	[1, "hit_player"      ],
	[1, "kamikaze"        ],
	[1, "math"            ],
	[1, "most_bombs"      ],
	[1, "move"            ],
	[1, "projectile_jump" ],
	[1, "rocket_rain"     ],
	[1, "sawrun"          ],
	[1, "say_word"        ],
	[1, "simon_says"      ],
	[1, "spycrab"         ],
	[1, "stand_near"      ],
	[1, "stay_ground"     ],
	[1, "swim_up"         ],
	[1, "type_color"      ],
];

Ware_Location <- {};

Ware_GameSounds <-
[
	"boss",
	"break",
	"break_end",
	"failure",
	"failure_all",
	"gameover",
	"intro",
	"lets_get_started",
	"speedup",
	"victory"
];

Ware_MinigameMusic <-
[
	"actfast",
	"actioninsilence",
	"cheerful",
	"clumsy",
	"falling",
	"getmoving",
	"getready",
	"goodtimes",
	"heat",
	"ohno",
	"question"
	"sillytime",
	"speculations",
	"spotlightsonyou",
	"thethinker",
	"wildwest",
];

foreach (sound in Ware_GameSounds)
	PrecacheSound(format("tf2ware_ultimate/music_game/%s.mp3", sound));
foreach (sound in Ware_MinigameMusic)
	PrecacheSound(format("tf2ware_ultimate/music_minigame/%s.mp3", sound));