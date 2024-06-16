// by ficool2 and pokemonpasta

// Show a message to player chat with TF2Ware formatting
// Behaves similar to format() and printf() in Squirrel
// The text will be automatically reversed during the "Reversed Text" special round
// Target can either be null (show it for everyone) or a specific player
// Available formatters:
//   {player} - Outputs player name in their team color. 
//              This adds a color marker, so if you are putting text after the player name
//              make sure to add a {color} formatter, usually with TF_COLOR_DEFAULT!
//   {color}  - Adds a color marker (sets the upcoming text color) in RGB hex format
//   {int}    - Integer value
//   {float}  - Float value
//   {str}    - String value
// If no formatter is matched,
//   the output will be formatted with C-style rules using Squirrel's built-in format function
//   E.g. {%g} will print the value in scientific notation
// If no {color} or {player} exists at the beginning of the text
//   a TF_COLOR_DEFAULT marker will be automatically prepended
function Ware_ChatPrint(target, fmt, ...) 
{
	local reversed = Ware_SpecialRound && Ware_SpecialRound.reverse_text
	local result
	
	if (reversed)
	{
		result = ""
	}
	else
	{
		 result = "\x07FFCC22[TF2Ware] "
		 if (!startswith(fmt, "{color}") && !startswith(fmt, "{player}"))
			result += "\x07" + TF_COLOR_DEFAULT
	}
	
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

// Shows text on the screen, with the same properties as the game_text entity
// Text can be reversed by a special round
// "players" can either be an array of players or a player handle
function Ware_ShowText(players, channel, text, holdtime, color = "255 255 255", x = -1.0, y = 0.3)
{
	if (Ware_SpecialRound && Ware_SpecialRound.reverse_text)
		text = ReverseString(text)
	
	local text_mgr = Ware_TextManager
	Ware_TextManagerQueue.push(
	{ 
		message  = text
		color    = color
		holdtime = holdtime
		x		 = x
		y        = y
		channel  = channel
	})
	
	EntityEntFire(text_mgr, "FireUser1")
	if (typeof(players) == "array")
	{
		foreach (player in players)
			EntFireByHandle(text_mgr, "Display", "", -1, player, null)
	}
	else
	{
		EntFireByHandle(text_mgr, "Display", "", -1, players, null)
	}
	EntityEntFire(text_mgr, "FireUser2")
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