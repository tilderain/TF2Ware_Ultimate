//todo pathfind grapple
::BotPathPoint <- class
{
	constructor(area, pos, how)
	{
		this.area = area
		this.pos = pos
		this.how = how
	}

	area = null
	pos = null
	how = null
}

	function UpdatePath(bot, target)
	{

	    local path = []				
	    local path_index = 0

	    local path_target_pos = Vector()		
	    local path_update_time_next = 0.0
	    local path_update_time_delay = 0.0 
	    local path_update_force = false	
	    local path_areas = {}

		ResetPath(bot)

		local path_target_pos = target

		local pos_start = bot.GetOrigin() + Vector(0, 0, 1)
		local pos_end = path_target_pos + Vector(0, 0, 1)
		
		local area_start = NavMesh.GetNavArea(pos_start, 128.0)
		local area_end = NavMesh.GetNavArea(pos_end, 128.0)
		if (area_start == null)
			area_start = NavMesh.GetNearestNavArea(pos_start, 512.0, false, false)
		if (area_end == null)
			area_end = NavMesh.GetNearestNavArea(pos_end, 512.0, false, false)

		if (area_start == null || area_end == null)
			return false

		if (area_start == area_end)
		{
			path.append(BotPathPoint(area_end, pos_end, NUM_TRAVERSE_TYPES))
			return true
		}
		
		if (!NavMesh.GetNavAreasFromBuildPath(area_start, area_end, pos_end, 0.0, TEAM_ANY, false, path_areas))
			return false

		if (path_areas.len() == 0)
			return false

		local area_target = path_areas["area0"]
		local area = area_target
		local area_count = path_areas.len()

		for (local i = 0; i < area_count && area != null; i++)
		{
			path.append(BotPathPoint(area, area.GetCenter(), area.GetParentHow()))
			area = area.GetParent()
		}
		
		path.append(BotPathPoint(area_start, bot.GetOrigin(), NUM_TRAVERSE_TYPES))
		path.reverse()
		
		local path_count = path.len()
		for (local i = 1; i < path_count; i++)
		{
			local path_from = path[i - 1]
			local path_to = path[i]
			
			path_to.pos = path_from.area.ComputeClosestPointInPortal(path_to.area, path_to.how, path_from.pos)
		}

		path.append(BotPathPoint(area_end, pos_end, NUM_TRAVERSE_TYPES))

        local pos = bot.GetOrigin()
        local loco = bot.GetLocomotionInterface()

        //loco.FaceTowards(path[0].pos)
        //loco.Approach(path[0].pos, 999.0)
        foreach(p in path)
        {
            DebugDrawLine(pos, p.pos, 0, 255, 0, true, 0.125)
            pos = p.pos
        }
	}

	function AdvancePath(bot)
	{
		local path_len = path.len()
		if (path_len == 0)
			return false

		if ((path[path_index].pos - bot.GetOrigin()).Length2D() < 32.0)
		{
			path_index++
			if (path_index >= path_len)
			{
				ResetPath(bot)
				return false
			}
		}

		return true
	}

	function ResetPath(bot)
	{
        return
		path_areas.clear()
		path.clear()
		path_index = 0
		path_target_pos = null
	}

	function Move(bot)
	{
		if (path_update_force)
		{
			UpdatePath()
			path_update_force = false
		}
		else if (path_update_time_next <= curtime)
		{
			if (path_target_pos == null || HasVictim() && (path_target_pos - attack_target.GetOrigin()).Length() > 16.0)
			{
				UpdatePath()
				path_update_time_next = curtime + PATH_UPDATE_INTERVAL
			}
		}

		local look_ang = m_angAbsRotation

		if (AdvancePath())
		{
			local path_pos = path[path_index].pos
			
			local move_dir = path_pos - m_vecAbsOrigin
			move_dir.Norm()
			
			local my_forward = m_angAbsRotation.Forward()
			my_forward.x = my_forward.x + 0.1 * (move_dir.x - my_forward.x)
			my_forward.y = my_forward.y + 0.1 * (move_dir.y - my_forward.y)
			
			look_ang = atan2(my_forward.y, my_forward.x)
			look_ang = QAngle(0, look_ang * RAD2DEG, 0)

			if (HasVictim())
			{
				if ((m_vecAbsOrigin - attack_target.GetOrigin()).Length() > MOBSTER_MOVE_RANGE || !IsLineOfSightClear(me, attack_target))
				{
					locomotion.SetDesiredSpeed(MOBSTER_MAX_SPEED)
					locomotion.Approach(path_pos, 1.0)
				}
			}
		}



		me.SetAbsAngles(look_ang)
	}

function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("trigger_multiple", bot.GetOrigin(), 5000)
    UpdatePath(bot, prop.GetOrigin())
    if (prop)
    {
        //BotLookAt(bot, prop.GetOrigin(), 350.0, 600.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(prop.GetOrigin())
        loco.Approach(prop.GetOrigin(), 999.0)
        //if (RandomInt(0,50) == 0)
        //    loco.Jump()
        if (RandomInt(0,4) == 0)
			bot.PressFireButton(1)
    }
}
