minigame <- Ware_MinigameData();
minigame.name = "Most Bombs";
minigame.description = "Shoot the most occuring color!";
minigame.duration = 8.0;
minigame.music = "thethinker";
minigame.custom_overlay = "most_bombs";

local colors = ["red", "yellow", "blue"];
local colors_text = [TF_COLOR_RED, COLOR_YELLOW, TF_COLOR_BLUE];
local color = -1;

local prop_model = "models/Combine_Helicopter/helicopter_bomb01.mdl";
local bomb_sprite = "sprites/tf2ware_ultimate/bomb_%s.vmt";
PrecacheModel(prop_model);

function CreateBomb(sprite_model, chosen)
{
	local pos = Ware_MinigameLocation.center;
	pos += Vector(RandomFloat(-380, 380), RandomFloat(-380, 380), RandomFloat(80, 400));
	
	local prop = Ware_SpawnEntity("prop_physics_override", 
	{
		model = prop_model,
		origin = pos,
		massscale = 0.01,
		rendermode = kRenderNone,
		modelscale = 2
	});
	prop.SetCollisionGroup(TFCOLLISION_GROUP_COMBATOBJECT);
	
	local sprite = Ware_SpawnEntity("env_glow",
	{
		model = sprite_model,
		origin = pos,
		scale = 0.25,
		spawnflags = 1,
		rendermode = kRenderTransColor,
		rendercolor = "255 255 255",
	});
	
	SetEntityParent(sprite, prop);
	
	Ware_SlapEntity(prop, RandomFloat(40, 200));
	
	if (chosen)
		prop.AddEFlags(EFL_USER);
	
	return prop;
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, "Revolver");
	
    local color_counts = array(colors.len());	
    local max = 0;

    foreach (i, color in colors)
    {
        color_counts[i] = RandomInt(6, 15);
        if (color_counts[i] > color_counts[max])
            max = i;
    }

    color_counts[max] += RandomInt(1, 5);
	color = max;
	
    foreach (i, color in colors)
	{
		for (local j = 0; j < color_counts[i]; j++)
			CreateBomb(format(bomb_sprite, color), i == max);
	}
}

function OnTakeDamage(params)
{
	if (!(params.damage_type & DMG_BULLET))
		return;
	
	local entity = params.const_entity; 
	if (entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker;
		if (attacker != null && attacker.IsPlayer())
		{
			if (entity.IsEFlagSet(EFL_USER))
				Ware_PassPlayer(attacker, true);

			Ware_StripPlayer(attacker, true);
		}
	}
}

function OnEnd()
{
	Ware_ChatPrint(null, "{color}The correct color was {color}{str}", TF_COLOR_DEFAULT, colors_text[color], colors[color].toupper());
}