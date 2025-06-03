function OnUpdate(bot)
{

    local prop = FindByClassnameNearest("prop_physics", bot.GetOrigin(), 1000)


    if (prop)
    {
        local dest
        if (VectorDistance2D(bot.GetOrigin(), Ware_MinigameLocation.center) < 200)
            dest = prop.GetOrigin() + Vector(200,200,1000)
        else
            dest = Ware_MinigameLocation.center + Vector(0,0,1000)

        BotLookAt(bot, dest, 9999.0, 9999.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(dest)

        if(VectorDistance2D(bot.GetOrigin(), prop.GetOrigin()) < 150)
            loco.Approach(dest, 999.0)
    }


    //if (RandomInt(0,50) == 0)
    //    loco.Jump()
}

