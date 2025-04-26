// by ficool2

// bunch of hacks to fix -enablefakeip for a better lobby hosting experience until TF2 fixes them on the C++ side
// 1) item server connection doesn't work on first map load, restart the map to fix this
// 2) Create Server dialog sets LAN mode, revert that so internet connections work
//
// this also fetches the server IP/password for easy copypasting via !ware_ip
// note: this code is intentionally disabled for dedicated servers

if (!("Ware_HostPresent" in this))
{
	Ware_HostPresent      		  <- false
	Ware_ServerIP       		  <- null
	Ware_ServerPassword 		  <- null
	Ware_SDR            		  <- false
	Ware_SDRFilename    		  <- ""
}

function Ware_SDRUpdate()
{
	if (Ware_HostPresent)
		return
	// these won't work until a player exists in the map
	if (!GetListenServerHost() && !IsDedicatedServer())
		return
		
	Ware_HostPresent = true
	if (!IsDedicatedServer())
	{	
		if (!Ware_Plugin && Convars.GetStr("sv_password").len() == 0)
		{
			// leaving the server open without the plugin is dangerous
			// this will generate a random password
			SendToConsole("sv_password " + GenerateHash(8))
		}
		
		// TODO add these tags on dedicated
		local tags = Convars.GetStr("sv_tags")
		if (tags.find("ware") == null)
		{
			if (tags.len() > 0)
				SendToConsole(format("sv_tags \"%s,ware\"", tags))
			else
				SendToConsole("sv_tags ware")
		}
		
		Ware_SDRCheck()
	}
}

function Ware_SDRCheck()
{
	local logfile = Convars.GetStr("con_logfile")
	local lt = {}
	LocalTime(lt)
	// unfortunately cannot wipe a log file (StringToFile writes a null byte...)
	// so need to create a unique one for each session
	Ware_SDRFilename = format("tf2ware_ultimate/lobby/%d_%d_%d_%d_%d_%d.log", 
		lt.year, lt.month, lt.day, lt.hour, lt.minute, lt.second)
	// workaround a bug where folder isn't initially created
	StringToFile("tf2ware_ultimate/lobby/create.log", "")
	SendToConsole(format("con_logfile \"scriptdata/%s\"", Ware_SDRFilename))
	SendToConsole("status")
	SendToConsole("sv_password")
	SendToConsole(format("con_logfile \"%s\"", logfile))
	SendToConsole("script Ware_SDRInit()")
}

function Ware_SDRRestartMap()
{
	// safety check: only allow this if SendToConsole changed the parameter
	if (Convars.GetStr("ai_debug_loners") == "-1")
	{		
		printl("[TF2Ware] Restarting map to workaround LAN and -enablefakeip item server bug")
		SendToConsole("sv_lan 0")
		SendToConsole("map " + GetMapName())	
	}
}
	
function Ware_SDRInit()
{
	try
	{
		local filename = Ware_SDRFilename
		local buffer = FileToString(filename)
		if (!buffer)
			throw format("Failed to load log file buffer %s", filename)
		
		local prefix_ip       = "udp/ip  : "
		local prefix_public   = "(public IP from Steam: "
		local prefix_password = "\"sv_password\""
		local prefix_sdr      = "local:"
		
		local lines = split(buffer, "\r\n", false)
		if (lines.len() == 0)
			throw format("Log file buffer %s is empty", filename)
		
		foreach (line in lines)
		{
			if (startswith(line, "udp/ip"))
			{
				local idx
				if (line.find(prefix_sdr) != null && (idx = line.find(prefix_ip)) != null)
				{					
					// use this dummy convar to track across map sessions if the session was restarted already						
					if (Convars.GetStr("ai_debug_loners") == "0")
					{
						// note: this generates a new IP
						SendToConsole("ai_debug_loners -1")
						SendToConsole("script Ware_SDRRestartMap()")
					}
					
					local ip_start = line.slice(idx + prefix_ip.len())
					Ware_ServerIP = ip_start.slice(0, ip_start.find(" "))
					Ware_SDR = true
					printl("[TF2Ware] Retrieved server IP successfully (SDR)")
				}
				else if ((idx = line.find(prefix_public)) != null)
				{
					local port_start = line.find(":", prefix_ip.len())
					local port = line.slice(port_start, line.find(" ", port_start))
					local ip_start = idx + prefix_public.len()
					local ip = line.slice(ip_start, line.find(")",  ip_start))
					Ware_ServerIP = ip + port
					Ware_SDR = false					
					printl("[TF2Ware] Retrieved server IP successfully (No SDR)")
				}
				else
				{
					printl("[TF2Ware] Unknown 'status' IP format, server IP cannot be retrieved")
				}
			}
			else if (startswith(line, prefix_password))
			{
				local password_start = line.find("\"", prefix_password.len())
				Ware_ServerPassword = line.slice(password_start + 1, line.find("\"", password_start + 1))
				
				printl("[TF2Ware] Retrieved server password successfully")
			}
		}
	}
	catch (e)
	{
		printl("[TF2Ware] Error when parsing server status: " + e)
	}	
	
	if (Ware_ServerIP == null)
		printl("[TF2Ware] Failed to detect server IP")
	if (Ware_ServerPassword == null)
		printl("[TF2Ware] Failed to detect server password")
}