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
        local escape_dist = 400
        local escapeDir = botOrigin - propOrigin
        escapeDir.z = 0
        escapeDir.Norm()

        local dest = botOrigin
        local walls = Ware_MinigameLocation.walls  // Access wall array
        local closestWall = null
        local minWallDist = 800  // Distance threshold for wall following

        // Mission 0: Enhanced wall-following behavior with repulsion
        if (mission == 0)
        {
            local repulsion = Vector(0, 0, 0)
            // Find nearest wall within range and compute repulsion
            foreach (wall in walls)
            {
                if (!wall.IsValid()) continue
                
                local wallOrigin = wall.GetOrigin()
                local wallDist = VectorDistance2D(botOrigin, wallOrigin)
                
                if (wallDist < 700)
                {
                    local dir = botOrigin - wallOrigin
                    dir.z = 0
                    dir.Norm()
                    // FIX: Use positive repulsion strength only
                    repulsion += dir * (700 - wallDist)
                }
                
                if (wallDist < minWallDist)
                {
                    minWallDist = wallDist
                    closestWall = wall
                }
            }

            // Calculate movement direction if near a wall
            if (closestWall)
            {
                local wallToBot = botOrigin - closestWall.GetOrigin()
                wallToBot.z = 0
                wallToBot.Norm()
                
                // Get perpendicular direction (tangent to wall)
                local wallParallel = Vector(-wallToBot.y, wallToBot.x, 0)
                
                // Choose direction away from enemy
                if (escapeDir.Dot(wallParallel) < 0)
                    wallParallel = wallParallel * -1

                // Blend wall-following direction with repulsion
                local moveDir = wallParallel
                if (repulsion.LengthSqr() > 0.1) // Significant repulsion detected
                {
                    repulsion.Norm()
                    // Blend: 70% wall-following, 30% repulsion
                    moveDir = (wallParallel * 0.7 + repulsion * 0.3)
                    moveDir.Norm()
                }

                dest = botOrigin + moveDir * escape_dist
                DebugDrawLine(botOrigin, dest, 255, 0, 0, true, 0.125)  // Red: Wall path
            }
            else
            {
                dest = botOrigin + escapeDir * escape_dist  // Default flee direction
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