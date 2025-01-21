minigame <- Ware_MinigameData
({
	name           = "Most Bombs"
	author         = "ficool2"
	description    = "Shoot the most occuring color!"
	duration       = 8.0
	music          = "thethinker"
	custom_overlay = "most_bombs"
})

colors <- ["red", "yellow", "blue"]
colors_text <- [TF_COLOR_RED, COLOR_YELLOW, TF_COLOR_BLUE]
color <- -1

bomb_queue <- []

prop_model  <- "models/tf2ware_ultimate/dummy_sphere.mdl"
bomb_sprite <- "sprites/tf2ware_ultimate/bomb_%s.vmt"

function OnPrecache()
{
	PrecacheModel(prop_model)
	foreach (color in colors)
		PrecacheSprite(format(bomb_sprite, color))
}

function CreateBomb()
{
	if (bomb_queue.len() == 0)
		return
	
	local bomb_data = bomb_queue.remove(0)
	local sprite_model = bomb_data[0]
	local chosen = bomb_data[1]
	
	local pos = Ware_MinigameLocation.center
	pos += Vector(RandomFloat(-380, 380), RandomFloat(-380, 380), RandomFloat(80, 400))
	
	local prop = Ware_SpawnEntity("prop_physics_override", 
	{
		targetname     = "bomb"
		model          = prop_model
		origin         = pos
		massscale      = 0.01
		rendermode     = kRenderTransColor
		renderamt      = 0
		disableshadows = true
	})
	prop.SetCollisionGroup(TFCOLLISION_GROUP_COMBATOBJECT)
	
	local sprite = Ware_SpawnEntity("env_glow",
	{
		model       = sprite_model
		origin      = pos
		scale       = 0.25
		spawnflags  = 1
		rendermode  = kRenderTransColor
		rendercolor = "255 255 255"
	})
	SetEntityParent(sprite, prop)
	
	Ware_SlapEntity(prop, RandomFloat(40, 200))
	
	if (chosen)
		prop.AddEFlags(EFL_USER)
	
	return 0.02
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, "Revolver")
	
    local color_counts = array(colors.len())
    local max = 0

    foreach (i, color in colors)
    {
        color_counts[i] = RandomInt(6, 15)
        if (color_counts[i] > color_counts[max])
            max = i
    }

    color_counts[max] += RandomInt(1, 5)
	color = max
	
    foreach (i, color in colors)
	{
		for (local j = 0; j < color_counts[i]; j++)
		{
			bomb_queue.append([format(bomb_sprite, color), i == max])
		}
	}
	
	Ware_CreateTimer(@() CreateBomb(), 0.0)
}

function OnTakeDamage(params)
{
	if (!(params.damage_type & DMG_BULLET))
		return
	
	local entity = params.const_entity
	if (entity.GetName() == "bomb")
	{
		local attacker = params.attacker
		if (attacker != null && attacker.IsPlayer())
		{
			if (entity.IsEFlagSet(EFL_USER))
				Ware_PassPlayer(attacker, true)

			Ware_StripPlayer(attacker, true)
		}
	}
}

function OnEnd()
{
	Ware_ChatPrint(null, "The correct color was {color}{str}", colors_text[color], colors[color].toupper())
}