
//todo better filter
function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("prop_physics", bot.GetOrigin(), 2000)
    local index = GetPropInt(prop, "m_nModelIndex")
    if (prop && index != Ware_MinigameScope.bomb_modelindex)
    {
        BotLookAt(bot, prop.GetOrigin(), 350.0, 600.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(prop.GetOrigin())
        loco.Approach(prop.GetOrigin(), 999.0)
        if (RandomInt(0,50) == 0)
            loco.Jump()
    }
}
