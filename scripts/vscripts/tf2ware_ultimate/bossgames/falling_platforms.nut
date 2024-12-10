minigame <- Ware_MinigameData
({
	name           = "Falling Platforms"
	author         = "ficool2"
	description    = "Push away the enemies!"
	duration       = 87.0
	end_delay      = 1.0
	location       = "hexplatforms"
	music          = "falling"
	custom_overlay = "push_enemy"
	min_players    = 2	
	start_pass     = true
	start_freeze   = true
	fail_on_death  = true
	allow_damage   = true
	collisions     = true
	convars =
	{
		tf_avoidteammates = 0
	}
})

// https://www.redblobgames.com/grids/hexagons/implementation.html
class Hex
{
	function constructor(_q, _r)
	{
		q = _q
		r = _r
		s = -_q - _r
	}
	
	function _cmp(h) { return q == h.q && r == h.r && s == h.s }
	function _add(h) { return Hex(q + h.q, r + h.r, s + h.s) }
	function _sub(h) { return Hex(q - h.q, r - h.r, s - h.s) }
	function _mul(h) { return Hex(q * h.q, r * h.r, s * h.s) }
	
	function ToScreenspace()
	{
		return Vector2D
		(
			1.73205 * q + 0.866025 * r,
			1.5 * r
		)
	}
	
	function Spawn(origin, size, model, speed)
	{
		local screen = ToScreenspace()
		local position = origin + Vector(screen.x * size, screen.y * size)
		
		entity = Ware_SpawnEntity("func_door",
		{
			origin         = position
			model          = model
			movedir        = "90 0 0"
			speed          = speed
			wait           = -1.0
			forceclosed    = true
			ignoredebris   = true
			disableshadows = true
			disablereceiveshadows = true
		})
		SetPropInt(entity, "m_takedamage", DAMAGE_YES)
	}
	
	q = null
	r = null
	s = null
	entity = null
}

hexes <- []
lower_delay <- 5.0

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY)
	Ware_ChatPrint(null, "Wall climb by hitting the wall!")	
}

function OnTeleport(players)
{
	local center = Ware_MinigameLocation.center * 1.0
	local models = Ware_MinigameLocation.plat_models
	
	local base_z = center.z
	local min_z = -128.0, max_z = 32.0
	local size = 112.0
	local speed = 300.0

	local SpawnHex = function(q, r)
	{
		local hex = Hex(q, r)
		center.z = base_z + Round(RandomFloat(min_z, max_z))
		hex.Spawn(center, size, RandomElement(models), speed)
		hexes.append(hex)
	}
	
	local shape = RandomInt(0, 3)
	local len = players.len()
	local dim = Max(ceil(sqrt(len)).tointeger() + 1, 4)
	if (shape == 0) // parallelogram
	{
		for (local q = 0; q < dim; q++)
		{
			for (local r = 0; r < dim; r++) 
			{
				SpawnHex(q, r)
			}
		}
	}
	else if (shape == 1) // triangle
	{
		for (local q = 0; q < dim; q++) 
		{
			for (local r = 0; r < dim - q; r++) 
			{
				SpawnHex(q, r)
			}
		}	
	}
	else if (shape == 2) // hexagon
	{
		dim = Min(dim - 1, 6); // this is not really right
		local count = 0
		for (local q = -dim; q < dim; q++) 
		{
			local r1 = Max(-dim, -q - dim)
			local r2 = Min( dim, -q + dim)
			for (local r = r1; r < r2; r++)
			{
				SpawnHex(q, r)
			}
		}	
	}
	else if (shape == 3) // rectangle
	{
		local left = 0, right = dim
		local top = 0, bottom = dim
		
		for (local r = top; r < bottom; r++) 
		{
			local r_offset = r >> 1
			for (local q = left - r_offset; q < right - r_offset; q++) 
			{
				SpawnHex(q, r)
			}
		}	
	}
	
	Shuffle(hexes)
	
	lower_delay = (minigame.duration - 17.0) / hexes.len().tofloat()
	Ware_CreateTimer(@() LowerPlatform(), 10.0)
	
	local hex_len = hexes.len()
	local hex_idx = 0
	foreach (player in players)
	{
		local origin = hexes[hex_idx].entity.GetOrigin()
		origin.z += 900.0
		hex_idx = (hex_idx + 1) % hex_len

		local dir = center - origin
		dir.z = 0.0
		dir.Norm()
		Ware_TeleportPlayer(player, origin, VectorAngles(dir), vec3_zero)
	}
}

function LowerPlatform()
{
	local hex = RemoveRandomElement(hexes)
	EntityAcceptInput(hex.entity, "Open")
	
	if (hexes.len() > 1)
		return lower_delay
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
		
	if (victim.IsPlayer())
	{
		if (attacker && attacker.IsPlayer())
		{
			local dir = attacker.EyeAngles().Forward()
			local vel = victim.GetAbsVelocity()
			dir.z = Max(dir.z, 0.0)
			vel += dir * 300.0 * (Min(params.damage, 100.0) / 40.0)
			vel.z += 450.0
			victim.SetAbsVelocity(vel)
			params.damage = 1.0
		}
	}
	else if (victim.GetClassname() == "func_door")
	{
		if (attacker && attacker.IsPlayer())
		{
			local vel = attacker.GetAbsVelocity()
			vel.z = Max(vel.z, 450.0)
			attacker.SetAbsVelocity(vel)
		}
		
		return false
	}
}

function OnCheckEnd()
{
	return Ware_GetAlivePlayers().len() <= 1
}