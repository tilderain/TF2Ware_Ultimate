

function ClosestPointOnOBB(point, origin, angles, mins, maxs)
{
    // Get orthogonal basis vectors from wall angles
    local forward = angles.Forward()
    local right = angles.Left()
    local up = angles.Up()
    
    // Transform point to wall's local space
    local localPoint = point - origin
    local localX = localPoint.Dot(forward)
    local localY = localPoint.Dot(right)
    local localZ = localPoint.Dot(up)
    
    // Clamp local coordinates to OBB bounds
    localX = Clamp(localX, mins.x, maxs.x)
    localY = Clamp(localY, mins.y, maxs.y)
    localZ = Clamp(localZ, mins.z, maxs.z)
    
    // Transform clamped point back to world space
    return origin + forward * localX + right * localY + up * localZ
}

function OnUpdate(bot)
{
    local prop
    local lowest_dist = 999999
    local botOrigin = bot.GetOrigin()
    local mission = Ware_GetPlayerMission(bot)

    // Find nearest enemy player
    for (local other; other = FindByClassnameWithin(other, "player", bot.GetOrigin(), 4000);)
    {
        if (other != bot && other.IsValid() && other.IsAlive() && other.GetTeam() != bot.GetTeam())
        {
            local otherOrigin = other.GetOrigin()
            local dist = VectorDistance2D(botOrigin, otherOrigin)
            if (dist < lowest_dist)
            {
                lowest_dist = dist
                prop = other
            }
        }
    }

    if (prop && bot.IsAlive())
    {
        local propOrigin = prop.GetOrigin()
        local escape_dist = 650
        local escapeDir = botOrigin - propOrigin
        escapeDir.z = 0
        escapeDir.Norm()

        local dest = botOrigin
        local walls = Ware_MinigameLocation.walls  // Access wall array
        local closestWall = null
        local minWallDist = 100  // Distance threshold for wall following

        // Mission 0: Enhanced wall-following behavior with repulsion
        if (mission == 0)
        {
            local repulsion = Vector(0, 0, 0)
            local closestPointOnWall = null
            local nearWallCount = 0 // Track how many walls are close

            foreach (wall in walls)
            {
                if (!wall.IsValid()) continue

                // Get wall properties for OBB calculation
                local wallOrigin = wall.GetOrigin()
                local wallAngles = wall.GetAbsAngles()
                local wallMins = wall.GetBoundingMinsOriented()
                local wallMaxs = wall.GetBoundingMaxsOriented()

                // Calculate closest point on wall's OBB to bot
                local closestPoint = ClosestPointOnOBB(botOrigin, wallOrigin, wallAngles, wallMins, wallMaxs)
                local wallDist = VectorDistance2D(botOrigin, closestPoint)


                // Apply repulsion if bot is near the wall
                if (wallDist < 50)
                {
                    nearWallCount++ // Increment close wall counter
                    local dir = botOrigin - closestPoint
                    dir.z = 0
                    if (dir.LengthSqr() > 0.001) {
                        dir.Norm()
                        repulsion += dir * (50 - wallDist)
                    }
                }

                // Update closest wall for wall-following
                if (wallDist < minWallDist)
                {
                    minWallDist = wallDist
                    closestWall = wall
                    closestPointOnWall = closestPoint
                }
            }

            // Calculate movement direction if near a wall
            if (closestWall && minWallDist < 100)
            {
                DebugDrawLine(botOrigin, closestPointOnWall, 0, 255, 0, true, 0.125)
                // FIX: Use wall's actual orientation vectors
                local wallAngles = closestWall.GetAbsAngles()
                local wallForward = wallAngles.Forward()
                local wallRight = wallAngles.Left()

                // Determine primary wall axis (longest dimension)
                local wallMins = closestWall.GetBoundingMinsOriented()
                local wallMaxs = closestWall.GetBoundingMaxsOriented()
                local wallSize = wallMaxs - wallMins

                // Use longest axis for wall-following direction
                local wallParallel = wallSize.x > wallSize.y ? wallForward : wallRight

                // Flatten to horizontal and normalize
                wallParallel = Vector(wallParallel.x, wallParallel.y, 0)
                if (wallParallel.LengthSqr() > 0.0001) {
                    wallParallel.Norm()
                } else {
                    wallParallel = Vector(1, 0, 0)  // Fallback if invalid vector
                }

                // Choose direction away from enemy
                if (escapeDir.Dot(wallParallel) < 0) {
                    wallParallel = wallParallel.Scale(-1)  // Correct way to invert vector
                }

                // Blend wall-following direction with repulsion
                local moveDir = wallParallel
                if (repulsion.LengthSqr() > 0.1)
                {
                    local repulsionLen = repulsion.Length()
                    repulsion.Norm()

                    // Increase repulsion influence when near multiple walls (e.g., corners)
                    local repulsionFactor = nearWallCount >= 2 ? 0.5 : 0.2
                    moveDir = wallParallel.Scale(1.0 - repulsionFactor) + repulsion.Scale(repulsionFactor)
                    moveDir.Norm()
                }

                dest = botOrigin + moveDir.Scale(escape_dist)
                DebugDrawLine(botOrigin, dest, 255, 0, 0, true, 0.125)
            }
            else
            {
                dest = botOrigin + escapeDir.Scale(escape_dist)
            }
        }
        // Mission 1: Maintain original fleeing behavior
        else if (mission == 1)
        {
            dest = propOrigin + (prop.GetAbsVelocity() * 0.5)
        }

        // Execute movement and aiming
        BotLookAt(bot, dest, 9999.0, 9999.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(dest)
        DebugDrawLine(botOrigin, dest, 0, 0, 255, true, 0.125)  // Blue: Default path

        // Movement conditions
        if (mission == 1 || (mission == 0 && VectorDistance2D(botOrigin, propOrigin) < escape_dist))
            loco.Approach(dest, 999.0)

        // Occasional attack
        if (RandomInt(0,10) == 0)
            bot.PressFireButton(-1)
    }
}