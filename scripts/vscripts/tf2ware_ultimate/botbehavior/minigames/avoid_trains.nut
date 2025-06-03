//todo better dodge mode 1
function OnUpdate(bot)
{

    local prop = FindByClassnameNearest("trigger_hurt", bot.GetOrigin(), 3000)

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

        if (Ware_MinigameMode == 0)
        {
            if(VectorDistance2D(bot.GetOrigin(), prop.GetOrigin()) < 300)
                loco.Approach(dest, 999.0)
        }
        else
        {
            if(VectorDistance2D(bot.GetOrigin(), prop.GetOrigin()) < 800)
                loco.Approach(dest, 999.0)
        }
    }


    //if (RandomInt(0,50) == 0)
    //    loco.Jump()
}

