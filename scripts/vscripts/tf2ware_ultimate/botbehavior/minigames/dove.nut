//TODO: shoot at random birds

local GRENADE_SPEED = 1800    // hammer units/s
local GRAVITY = 800.0           // hammer units/s²
local ITERATIONS = 5            // Number of prediction refinements

function CalculateAimPosition(demomanOrigin, targetOrigin, targetVelocity) {
    local predictedPosition = targetOrigin
    local timeOfFlight = 0.0
    
    // Iteratively refine prediction
    for (local i = 0; i < ITERATIONS; i++) {
        local delta = predictedPosition - demomanOrigin
        local horizontalDistance = Vector(delta.x, delta.y, 0).Length()
        
        // Calculate required pitch angle
        timeOfFlight = horizontalDistance / GRENADE_SPEED
        local verticalOffset = delta.z + targetVelocity.z * timeOfFlight
        
        // Solve vertical motion equation: verticalOffset = v0*sinθ*t - 0.5*g*t²
        local sinTheta = (verticalOffset + 0.5 * GRAVITY * timeOfFlight * timeOfFlight) / (GRENADE_SPEED * timeOfFlight)
        sinTheta = Clamp(sinTheta, -1.0, 1.0)
        
        // Update prediction with new time of flight
        timeOfFlight = horizontalDistance / (GRENADE_SPEED * cos(asin(sinTheta)))
        predictedPosition = targetOrigin + targetVelocity * timeOfFlight
    }
    
    return predictedPosition
}

function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("base_boss", bot.GetOrigin(), 2500)
	if (prop)
	{
    	local loco = bot.GetLocomotionInterface()
        local dest = CalculateAimPosition(bot.GetOrigin(), prop.GetCenter(), prop.GetAbsVelocity())
    	loco.FaceTowards(dest)
		BotLookAt(bot, dest, 9999.0, 9999.0)
    	loco.Approach(prop.GetCenter(), 999.0)
		if (RandomInt(0,4) == 0)
			bot.PressFireButton(-1)
    	//if (RandomInt(0,50) == 0)
    	//    loco.Jump()
	}
}
