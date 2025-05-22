
// Constants
const GRENADE_SPEED = 1216.6;    // hammer units/s
const GRAVITY = 800.0;           // hammer units/s²
const ITERATIONS = 5;            // Number of prediction refinements

function CalculateAimPosition(demomanOrigin, targetOrigin, targetVelocity) {
    local predictedPosition = targetOrigin;
    local timeOfFlight = 0.0;
    
    // Iteratively refine prediction
    for (local i = 0; i < ITERATIONS; i++) {
        local delta = predictedPosition - demomanOrigin;
        local horizontalDistance = Vector(delta.x, delta.y, 0).Length();
        
        // Calculate required pitch angle
        timeOfFlight = horizontalDistance / GRENADE_SPEED;
        local verticalOffset = delta.z + targetVelocity.z * timeOfFlight;
        
        // Solve vertical motion equation: verticalOffset = v0*sinθ*t - 0.5*g*t²
        local sinTheta = (verticalOffset + 0.5 * GRAVITY * timeOfFlight * timeOfFlight) / (GRENADE_SPEED * timeOfFlight);
        sinTheta = Clamp(sinTheta, -1.0, 1.0);
        
        // Update prediction with new time of flight
        timeOfFlight = horizontalDistance / (GRENADE_SPEED * cos(asin(sinTheta)));
        predictedPosition = targetOrigin + targetVelocity * timeOfFlight;
    }
    
    return predictedPosition;
}

function OnUpdate(bot)
{
    local prop1 = FindByName(null, "boss4_goal")
    local prop2 = FindByName(null, "boss4_goal2")

    local y = bot.GetOrigin().y

    local dist1 = fabs(prop1.GetOrigin().y - y)
    local dist2 = fabs(prop2.GetOrigin().y - y)


    local prop
    prop = dist1 < dist2 ? prop1 : prop2
    //if(prop.GetOrigin)
    //local prop = FindByClassnameNearest("trigger_multiple", bot.GetOrigin(), 1500)
    if(prop)
    {
        //Ware_ChatPrint(null, "{int}", VectorDistance(prop.GetOrigin(), bot.GetOrigin()))
        //SetPropInt(bot, "m_nButtons", IN_FORWARD)

        local demomanPos = bot.EyePosition();
        local hoopPos = prop.GetOrigin() + Vector(0,0,142.5);
        local hoopVelocity = prop.GetAbsVelocity();  // Adjust based on actual hoop movement

        //local dest = CalculateAimPosition(demomanPos, hoopPos, hoopVelocity)
        local z = VectorDistance(prop.GetOrigin(), bot.EyePosition())
        local dest = prop.GetOrigin() + Vector((prop.GetAbsVelocity().x * 0.925), 0, z/5.25)
        LookAt(bot, dest, 2000, 99999)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(dest)
        loco.Approach(prop.GetOrigin(), 999.0);
        bot.GetActiveWeapon().PrimaryAttack()

        //if (RandomInt(0,50) == 0)
        //    loco.Jump()
    }
}
function NormalizeAngle(target)
{
	target %= 360.0;
	if (target > 180.0)
		target -= 360.0;
	else if (target < -180.0)
		target += 360.0;
	return target;
}

function ApproachAngle(target, value, speed)
{
	target = NormalizeAngle(target);
	value = NormalizeAngle(value);
	local delta = NormalizeAngle(target - value);
	if (delta > speed)
		return value + speed;
	else if (delta < -speed)
		return value - speed;
	return target;
}

function LookAt(bot, target_pos, min_rate, max_rate)
{
    local cur_pos = bot.GetOrigin();
    local cur_vel = bot.GetAbsVelocity();
    local cur_speed = cur_vel.Length();
    local cur_eye_pos = bot.EyePosition();
    local cur_eye_ang = bot.EyeAngles();
    local cur_eye_fwd = cur_eye_ang.Forward();

    local dt = FrameTime();
    local dir = target_pos - cur_eye_pos;
    dir.Norm();
    local dot = cur_eye_fwd.Dot(dir);
    
    local desired_angles = VectorAngles(dir);	
    
    local rate_x = RemapValClamped(fabs(NormalizeAngle(cur_eye_ang.x) - NormalizeAngle(desired_angles.x)), 0.0, 180.0, min_rate, max_rate);
    local rate_y = RemapValClamped(fabs(NormalizeAngle(cur_eye_ang.y) - NormalizeAngle(desired_angles.y)), 0.0, 180.0, min_rate, max_rate);

    if (dot > 0.7)
    {
        local t = RemapValClamped(dot, 0.7, 1.0, 1.0, 0.05);
        local d = sin(1.57 * t); // pi/2
        rate_x *= d;
        rate_y *= d;
    }

    cur_eye_ang.x = NormalizeAngle(ApproachAngle(desired_angles.x, cur_eye_ang.x, rate_x * dt));
    cur_eye_ang.y = NormalizeAngle(ApproachAngle(desired_angles.y, cur_eye_ang.y, rate_y * dt));
        
    bot.SnapEyeAngles(cur_eye_ang);
}