

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

    local data = Ware_GetPlayerMiniData(bot)

    // Find nearest enemy player
    if (mission == 0)
    {
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
    }
    else
    {
        if((!("prop" in data) || data.prop == null))
        {
            local arr = Shuffle(Ware_MinigamePlayers)
            foreach (other in arr)
            {
                if (other != bot && other.IsValid() && other.IsAlive() && other.GetTeam() != bot.GetTeam())
                {
                    data.prop <- other
                }
            }
        }
        prop = data.prop
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
            local nearWalls = []
            local repulsionNorm = null
            local repulsionStrength = 0

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
                    local dir = botOrigin - closestPoint
                    dir.z = 0
                    if (dir.LengthSqr() > 0.001) {
                        dir.Norm()
                        repulsion += dir * (50 - wallDist)
                        nearWalls.append({wall = wall, point = closestPoint, normal = dir})
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
            repulsionStrength = repulsion.Length()
            if (repulsionStrength > 0) {
                repulsionNorm = repulsion * (1.0 / repulsionStrength)
            }

            // Calculate movement direction if near a wall
            if (closestWall && minWallDist < 200)
            {
                //DebugDrawLine(botOrigin, closestPointOnWall, 0, 255, 0, true, 0.125)
                // Get wall's actual orientation vectors
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
                    wallParallel = wallParallel.Scale(-1)  // Invert direction if needed
                }
    
                // DECISIVE CORNER ESCAPE - PHYSICS BASED
    
                local moveDir = null
                local isCorner = false
                local cornerEscapeVec = Vector(0,0,0)
    
                // 1. Detect corner situations (2+ walls close together)
                if (nearWalls.len() >= 2) 
                {
                    isCorner = true
    
                    // Calculate combined escape direction from all nearby walls
                    foreach (wallData in nearWalls) 
                    {
                        // Get wall's forward vector (long axis)
                        local wallAng = wallData.wall.GetAbsAngles()
                        local wallForward = wallAng.Forward()
                        wallForward.z = 0
                        if (wallForward.LengthSqr() > 0.001) wallForward.Norm()
    
                        // Add perpendicular to wall normal (tangential escape)
                        local tangent = Vector(-wallData.normal.y, wallData.normal.x, 0)
                        cornerEscapeVec += tangent
                    }
    
                    // Choose direction away from enemy
                    if (cornerEscapeVec.Dot(escapeDir) < 0) {
                        cornerEscapeVec = cornerEscapeVec.Scale(-1)
                    }
    
                    cornerEscapeVec.Norm()
                }
    
                // 2. DECISIVE CORNER ESCAPE
                if (isCorner && cornerEscapeVec.LengthSqr() > 0.1) 
                {
                    // Use corner escape vector
                    moveDir = cornerEscapeVec
                    //DebugDrawLine(botOrigin, botOrigin + moveDir.Scale(150), 255, 0, 0, true, 0.125)
                }
                else 
                {
                    // WALL FOLLOWING: Use wall-parallel direction
                    moveDir = wallParallel
                    //DebugDrawLine(botOrigin, botOrigin + moveDir.Scale(150), 0, 0, 255, true, 0.125)
                }

                // 5. SET DESTINATION
                dest = botOrigin + moveDir.Scale(escape_dist)
                //DebugDrawLine(botOrigin, dest, 255, 165, 0, true, 0.125) // Orange: Final path
    
                // 6. IMPROVED STUCK ESCAPE WITH CORNER DETECTION
                local velocity = bot.GetAbsVelocity().Length2D()
                if (velocity > 80) 
                {
                    local escapeVec = null
    
                    if (isCorner) {
                        // Use pre-calculated corner escape vector
                        escapeVec = cornerEscapeVec
                    }
                    else if (nearWalls.len() > 0) {
                        // Single wall escape - use tangent to closest wall
                        local closestWallData = nearWalls[0]
                        escapeVec = Vector(-closestWallData.normal.y, closestWallData.normal.x, 0)
    
                        // Ensure escape points away from walls
                        if ((botOrigin + escapeVec*50 - closestWallData.point).Length2D() < 40) {
                            escapeVec = escapeVec.Scale(-1)
                        }
                    }
                    else {
                        // Fallback: use enemy escape direction
                        escapeVec = escapeDir
                    }
    
                    escapeVec.Norm()
                    dest = botOrigin + escapeVec * (escape_dist * 1.5)
                    //DebugDrawLine(botOrigin, dest, 255, 255, 0, true, 0.125)

                }
    
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

            if (!prop.IsValid() || !prop.IsAlive())
            {
                data.prop = null
            }
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