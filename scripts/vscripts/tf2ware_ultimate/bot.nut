// by ficool2

class Ware_BotData
{
	function constructor(entity)
	{
		me = entity
		minigame_timers = []
	}
	
	me = null
	minigame_timers = null
}

if (!("Ware_Bots" in this))
{
	Ware_Bots <- []
}

SetConvarValue("tf_bot_difficulty", 0)
SetConvarValue("tf_bot_melee_only", 1)
SetConvarValue("tf_bot_sniper_melee_range", -1)
SetConvarValue("tf_bot_reevaluate_class_in_spawnroom", 0)
SetConvarValue("tf_bot_keep_class_after_death", 1)

Ware_BotMinigameBehaviors <- 
{
	type_word = {}
	catch_cubes = {}
	basketball = {}
	jump_rope = {}
	boxing = {}
	dove = {}
	bullseye = {}
	swim_up = {}
	water_war = {}
	type_color = {}
	type_time = {}
	type_map = {}
	watch_fall = {}
	wanted = {}
	trivia = {}
	treasure_hunt = {}
	touch_sky = {}
	time_jump = {}
	taunt_kill = {}
	sumo = {}
	stun = {}
	street_fighter = {}
	stay_ground = {}
	stand_near = {}
	spycrab = {}
	flipper_ball = {}
	piggyback = {}
	airblast = {}
	airshot = {}
	avoid_props = {}
	avoid_trains = {}
	backstab = {}	
	bombs = {}
	break_barrel = {}
	break_box = {}
	bumpers = {}
	caber_king = {}
	cap = {}
	catch_money = {}
	count_bombs = {}
	change_class = {}
	destroy_barrels = {}
	math = {}
	pop_jack = {}
	projectile_jump = {}
	needle_jump = {}
	halloween_fight = {}
	melee_arena = {}
	hit_balls = {}
	hit_player = {}
	headshot = {}
	sniper_war = {}
}

Ware_BotMinigameBehavior <- null

function Ware_BotLoadBehaviors()
{
	foreach (minigame, scope in Ware_BotMinigameBehaviors)
	{
		local file_name = "tf2ware_ultimate/botbehavior/minigames/" + minigame	
		try
		{			
			IncludeScript(file_name, scope)	
		}
		catch (e)
		{
			Ware_Error("Failed to load '%s.nut'. Missing from disk or syntax error", path)
		}
	}
}

function Ware_BotSetup(bot)
{
	// disables visibility of enemies
	bot.AddBotAttribute(IGNORE_ENEMIES)
	bot.SetMaxVisionRangeOverride(0.01)
	// makes spies not attempt to cloak
	bot.SetMissionTarget(Ware_IncursionDummy)
	// set MISSION_SNIPER which effectively does nothing
	bot.SetMission(3, true)
	bot.GetScriptScope().bot_data <- Ware_BotData(bot)
	
	if (Ware_Bots.find(bot) == null)
		Ware_Bots.append(bot)
}

function Ware_BotDestroy(bot)
{
	local bot_data = bot.GetScriptScope().bot_data
	foreach (timer in bot_data.minigame_timers)
		KillTimer(timer)
}

function Ware_BotUpdate()
{
	if (Ware_Minigame 
		&& Ware_BotMinigameBehavior
		&& "OnUpdate" in Ware_BotMinigameBehavior)
	{
		foreach (bot in Ware_Bots)
			Ware_BotMinigameBehavior.OnUpdate(bot)
	}
	else
	{
		// TODO roam around
	}
}	

function Ware_BotOnMinigameStart()
{
	if (Ware_Minigame.file_name in Ware_BotMinigameBehaviors)
	{
		Ware_BotMinigameBehavior = Ware_BotMinigameBehaviors[Ware_Minigame.file_name]
	
		if ("OnStart" in Ware_BotMinigameBehavior)	
		{
			foreach (bot in Ware_Bots)
				Ware_BotMinigameBehavior.OnStart(bot)
		}
	}
	else
	{
		Ware_BotMinigameBehavior = null
	}
}

function Ware_BotOnMinigameEnd()
{
	foreach (bot in Ware_Bots)
	{
		local bot_data = bot.GetScriptScope().bot_data
		foreach (timer in bot_data.minigame_timers)
			KillTimer(timer)		
		bot_data.minigame_timers.clear()
	}
}

function Ware_BotCreateMinigameTimer(bot, callback, delay)
{
	local timer = CreateTimer(callback, delay)
	bot.GetScriptScope().bot_data.minigame_timers.append(timer)
	return timer
}

function Ware_BotTryWordTypo(bot, text, chance)
{
	// TODO higher typo chance with longer word
	
	if (RandomFloat(0.0, 1.0) > chance)
		return text
	
	if (text.len() < 2)
		return text
		
	local i = RandomInt(0, text.len() - 2)
	local chars = text.toupper() == text ? text.tolower() : text
	local type = RandomInt(0, 3)
	
	switch (type)
	{
		case 0: // swap
		{
			local tmp = chars[i]
			chars = chars.slice(0, i) + chars[i + 1].tochar() + tmp.tochar() + chars.slice(i + 2)
			break;
		}
		case 1: // omit
		{
			chars = chars.slice(0, i) + chars.slice(i + 1)
			break
		}
		case 2: // repeat
		{
			chars = chars.slice(0, i) + chars[i].tochar() + chars[i].tochar() + chars.slice(i + 1)
			break
		}
		case 3: // wrong
		{
			local keyboard = "abcdefghijklmnopqrstuvwxyz"
			local wrongChar = keyboard[RandomInt(0, keyboard.len() - 1)]
			chars = chars.slice(0, i) + wrongChar.tochar() + chars.slice(i + 1)
			break
		}
	}

	return chars
}


function BotLookAt(bot, target_pos, min_rate, max_rate)
{
    local cur_pos = bot.GetOrigin()
    local cur_vel = bot.GetAbsVelocity()
    local cur_speed = cur_vel.Length()
    local cur_eye_pos = bot.EyePosition()
    local cur_eye_ang = bot.EyeAngles()
    local cur_eye_fwd = cur_eye_ang.Forward()

    local dt = TICKDT
    local dir = target_pos - cur_eye_pos
    dir.Norm()
    local dot = cur_eye_fwd.Dot(dir)
    
    local desired_angles = VectorAngles(dir)	
    
    local rate_x = RemapValClamped(fabs(NormalizeAngle(cur_eye_ang.x) - NormalizeAngle(desired_angles.x)), 0.0, 180.0, min_rate, max_rate)
    local rate_y = RemapValClamped(fabs(NormalizeAngle(cur_eye_ang.y) - NormalizeAngle(desired_angles.y)), 0.0, 180.0, min_rate, max_rate)

    if (dot > 0.7)
    {
        local t = RemapValClamped(dot, 0.7, 1.0, 1.0, 0.05)
        local d = sin(1.57 * t) // pi/2
        rate_x *= d
        rate_y *= d
    }

    cur_eye_ang.x = NormalizeAngle(ApproachAngle(desired_angles.x, cur_eye_ang.x, rate_x * dt))
    cur_eye_ang.y = NormalizeAngle(ApproachAngle(desired_angles.y, cur_eye_ang.y, rate_y * dt))
        
    bot.SnapEyeAngles(cur_eye_ang)
}

//AI generated, please improve (?)
function BotCalculateAimPosition(demomanOrigin, targetOrigin, targetVelocity, projectile_speed) {
    const GRAVITY = 800.0;
    // Calculate initial time estimate (straight-line distance / speed)
    local delta = targetOrigin - demomanOrigin;
    local t = delta.Length() / projectile_speed;
    local MAX_ITER = 10;
    local TOLERANCE = 0.1;

    for (local i = 0; i < MAX_ITER; i++) {
        // Predict target position at time t
        local predictedPos = targetOrigin + targetVelocity * t;
        local toTarget = predictedPos - demomanOrigin;
        
        // Calculate horizontal distance and height difference
        local horizontalDist = Vector(toTarget.x, toTarget.y, 0).Length();
        local verticalDiff = toTarget.z;
        
        // Solve for actual time using projectile motion equations
        local a = 0.25 * GRAVITY * GRAVITY;
        local b = GRAVITY * verticalDiff - projectile_speed * projectile_speed;
        local c = horizontalDist * horizontalDist + verticalDiff * verticalDiff;
        
        // Quadratic equation: a*t^4 + b*t^2 + c = 0
        local discriminant = b*b - 4*a*c;
        if (discriminant < 0) {
            // No valid trajectory, use direct prediction
            t = horizontalDist / projectile_speed;
            break;
        }
        
        local t1_sq = (-b + sqrt(discriminant)) / (2*a);
        local t2_sq = (-b - sqrt(discriminant)) / (2*a);
        
        // Choose smallest positive real solution
        local new_t = t;
        if (t1_sq > 0) {
            new_t = sqrt(t1_sq);
            if (t2_sq > 0) {
                local t2 = sqrt(t2_sq);
                if (t2 < new_t) new_t = t2;
            }
        }
        else if (t2_sq > 0) {
            new_t = sqrt(t2_sq);
        }
        else {
            // No valid time solution
            break;
        }
        
        // Check for convergence
        if (fabs(new_t - t) < TOLERANCE) {
            t = new_t;
            break;
        }
        t = new_t;
    }

    // Final target prediction
    local finalPos = targetOrigin + targetVelocity * t;
    local launchVec = finalPos - demomanOrigin;
    
    // Calculate initial velocity components
    launchVec.x /= t;
    launchVec.y /= t;
    launchVec.z = launchVec.z / t + 0.5 * GRAVITY * t;
    
	DebugDrawLine(demomanOrigin, demomanOrigin + launchVec * 10000, 0, 0, 255, true, 0.125)

    // Return point along launch vector
    return demomanOrigin + launchVec * 10000;
}