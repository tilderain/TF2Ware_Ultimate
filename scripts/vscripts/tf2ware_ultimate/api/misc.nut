// by ficool2 and pokemonpasta

// Show a message to player chat with TF2Ware formatting
// Behaves similar to format() and printf() in Squirrel
// The text will be automatically reversed during the "Reversed Text" special round
// Target can either be null (show it for everyone) or a specific player
// Available formatters:
// {player} - Outputs player name in their team color
// {color} - Sets the upcoming text color in RGB hex format
// {int} - Integer value
// {float} - Float value
// {str} - String value
// If no formatter is matched, he output will be formatted with C-style rules using Squirrel's built-in format function
// E.g. {%g} will print the value in scientific notation
function Ware_ChatPrint(target, fmt, ...) 
{
	local reversed = Ware_SpecialRound && Ware_SpecialRound.reverse_text
	local result = reversed ? "" : "\x07FFCC22[TF2Ware] "
	
	local start = 0
	local end = fmt.find("{")
	local i = 0
	while (end != null) 
	{
		result += fmt.slice(start, end)
		start = end + 1
		end = fmt.find("}", start)
		if (end == null)
			break
		local word = fmt.slice(start, end)
		
		if (word == "player")
		{
			local player = vargv[i++]

			local team = player.GetTeam()
			if (team == TF_TEAM_RED)
				result += "\x07" + TF_COLOR_RED
			else if (team == TF_TEAM_BLUE)	
				result += "\x07" + TF_COLOR_BLUE
			else
				result += "\x07" + TF_COLOR_SPEC
			result += GetPlayerName(player)
		}
		else if (word == "color")
		{
			result += "\x07" + vargv[i++]
		}
		else if (word == "int" || word == "float")
		{
			result += vargv[i++].tostring()
		}
		else if (word == "str")
		{
			result += vargv[i++]
		}
		else 
		{
			result += format(word, vargv[i++])
		}
		
		start = end + 1
		end = fmt.find("{", start)
	}
	
	result += fmt.slice(start)
	
	if (reversed)
		result = "\x07FFCC22[eraW2FT] \x07" + TF_COLOR_DEFAULT + ReverseString(result)

	ClientPrint(target, HUD_PRINTTALK, result)
}

// Show an error message to the server console and in chat
// Uses printf style formatting
function Ware_Error(...)
{
	vargv.insert(0, this)
	vargv[1] = "\x07FF0000ERROR:\x07FBECCB " + vargv[1]
	local msg = format.acall(vargv)
	printl(msg)
	ClientPrint(null, HUD_PRINTTALK, msg)
}

// Slaps an entity by giving it random horizontal velocity and extra vertical velocity
function Ware_SlapEntity(entity, scale)
{
	local vel = entity.GetAbsVelocity()
	vel.x += RandomFloat(-1.0, 1.0) * scale
	vel.y += RandomFloat(-1.0, 1.0) * scale
	vel.z += scale * 2.0
	entity.Teleport(false, Vector(), false, QAngle(), true, vel)
}

// Spawns a particle that follows a given entity
// Optionally can follow an attachment in the model
function Ware_SpawnParticle(entity, name, attach_name = "", attach_type = PATTACH_ABSORIGIN_FOLLOW)
{
	Ware_ParticleSpawnerQueue.push(
	{
		name = name
		attach_name = attach_name
		attach_type = attach_type
	})
	EntFireByHandle(Ware_ParticleSpawner, "StartTouch", "", -1, entity, entity)
}

// Updates the global material rendering state
// Curently, this is only used by overlay textures to reverse their text during a special round
function Ware_UpdateGlobalMaterialState()
{
	// water_lod_control provides 2 global float variables that are read by client material proxies
	// unfortunately, mastercomfig overrides these and it results in corrupted rendering
	// to prevent that, do a dummy update of the network vars so the entity is re-transmitted
	if (WaterLOD && WaterLOD.IsValid())
		WaterLOD.Kill()
	
	WaterLOD = SpawnEntityFromTableSafe("water_lod_control",
	{
		cheapwaterstartdistance = 0
		cheapwaterenddistance = Ware_SpecialRound && Ware_SpecialRound.reverse_text ? 1 : 0
	})
}

// Proxy to communicate information from VScript to SourceMod plugins
function Ware_SourcemodRoutine(name, keyvalues)
{
	keyvalues.id <- "tf2ware_ultimate"
	keyvalues.routine <- name
	// unused event repurposed for vscript <-> sourcemod communication
	SendGlobalGameEvent("player_rematch_change", keyvalues)
}