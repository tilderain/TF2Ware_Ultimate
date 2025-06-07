
function OnUpdate(bot)
{
    local prop
    local botOrigin = bot.GetOrigin()
    /*local lowest_dist = 999999
    for (local other; other = FindByClassnameWithin(other, "prop_physics", bot.GetOrigin(), 3000);)
    {
        if (true)
        {
            local otherOrigin = other.GetOrigin()
            local dist = VectorDistance2D(botOrigin, otherOrigin)
            //Ware_ChatPrint(null, "{int} {int}", botOrigin, escapeDir)
            if (dist < lowest_dist)
            {
                lowest_dist = dist
                prop = other
            }
        }
    }*/

    prop = FindByClassnameNearest("trigger_hurt", bot.GetOrigin(), 3000)

    if (prop)
    {

        local escape_dist = 1000
        local propOrigin = prop.GetOrigin()
        
        // Calculate direction from prop to bot and extend it further
        local escapeDir = botOrigin - propOrigin
        escapeDir.z = 0
		escapeDir.Norm()
        local dest = botOrigin + escapeDir * escape_dist  // Move 200 units further away from prop
        
        //Ware_ChatPrint(null, "{int} {int}", botOrigin, escapeDir)

        BotLookAt(bot, dest, 9999.0, 9999.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(dest)

        DebugDrawLine(botOrigin, dest, 0, 0, 255, true, 0.125)

        // Only move if too close to prop
        if(VectorDistance2D(botOrigin, propOrigin) < escape_dist)
            loco.Approach(dest, 999.0)

        if (RandomInt(0,10) == 0)
            bot.PressFireButton(-1)
    }
}