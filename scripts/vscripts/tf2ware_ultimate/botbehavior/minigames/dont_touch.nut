function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("player", bot.GetOrigin(), 1000)

    if (prop)
    {
        local botOrigin = bot.GetOrigin()
        local propOrigin = prop.GetOrigin()
        
        // Calculate direction from prop to bot and extend it further
        local escapeDir = (botOrigin - propOrigin)
		escapeDir.Norm()
        local dest = botOrigin + escapeDir * 200  // Move 200 units further away from prop
        
        BotLookAt(bot, dest, 9999.0, 9999.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(dest)

        // Only move if too close to prop
        if(VectorDistance2D(botOrigin, propOrigin) < 300)
            loco.Approach(dest, 999.0)

        if (RandomInt(0,4) == 0)
            bot.PressFireButton(-1)
    }
}