draw_snap_coord <- 8.0

DRAW_NONE   <- 0
DRAW_CURSOR <- 1
DRAW_BOX    <- 2

function DrawTrace(player)
{
	local eye_pos = player.EyePosition()
	local eye_fwd = player.EyeAngles().Forward()
	
	local trace =
	{
		start = eye_pos
		end = eye_pos + eye_fwd * 8192.0
		ignore = player
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
	
	TraceLineEx(trace)
	
	if (trace.hit)
	{
		draw_cur_normal = trace.plane_normal
		if (draw_snap_coord > 0.0)
			return VectorSnap(trace.pos, draw_snap_coord)
		else
			return trace.pos
	}
		
	return null
}

function DrawThink()
{
	draw_cur_pos = DrawTrace(self)
	if (draw_cur_pos == null)
		return 0.0

	local d = 0.03
	if (draw_state == DRAW_BOX)
	{
		DebugDrawBox(Vector(), draw_anchor_pos, draw_cur_pos, 255, 0, 0, 50, d)
		DebugDrawText(draw_anchor_pos, draw_anchor_pos.tostring(), false, d)
		DebugDrawText(draw_cur_pos, draw_cur_pos.tostring(), false, d)
	}
	else if (draw_state == DRAW_CURSOR)
	{
		local size = 16.0
		
		DebugDrawLine(
			draw_cur_pos + Vector(-size, 0, 0), 
			draw_cur_pos + Vector(size, 0, 0),
			255, 0, 0, false, d)
		DebugDrawLine(
			draw_cur_pos + Vector(0, -size, 0), 
			draw_cur_pos + Vector(0, size, 0),
			0, 255, 0, false, d)
		DebugDrawLine(
			draw_cur_pos + Vector(0, 0, -size), 
			draw_cur_pos + Vector(0, 0, size),
			0, 0, 255, false, d)
		DebugDrawLine(
			draw_cur_pos, 
			draw_cur_pos + draw_cur_normal * size * 2.0,
			255, 125, 0, false, d)
		DebugDrawText(draw_cur_pos, draw_cur_pos.tostring(), false, d)
	}
	
	return -1
}

function DrawBegin()
{
	::draw_cur_pos <- Vector()
	::draw_cur_normal <- Vector()
	::draw_state <- DRAW_CURSOR
	AddThinkToEnt(GetListenServerHost(), "DrawThink")
}

function DrawBox()
{
	::draw_anchor_pos <- DrawTrace(GetListenServerHost())
	if (draw_anchor_pos == null)
	{
		DrawEnd()
		return
	}
	
	::draw_state <- DRAW_BOX
}

function DrawEnd()
{
	if (draw_state == DRAW_BOX)
	{
		local axes = ["x", "y", "z"]
		local backwards = 0
		foreach (v in axes)
			if (draw_anchor_pos[v] < draw_cur_pos[v])
				backwards++
		
		if (backwards == 3)
		{
			printl(VectorFormat(draw_cur_pos))
			printl(VectorFormat(draw_anchor_pos))
		}
		else
		{
			if (backwards > 0)
				printl("WARNING: Mins/Maxs has a backwards axis")
			
			printl(VectorFormat(draw_anchor_pos))
			printl(VectorFormat(draw_cur_pos))
		}
	}
	
	draw_state = DRAW_NONE
	AddThinkToEnt(GetListenServerHost(), "")
}

if ("draw_state" in getroottable())
{
	if (draw_state == DRAW_BOX)
		DrawEnd()
	else if (draw_state == DRAW_CURSOR)
		DrawBox()
	else if (draw_state == DRAW_NONE)
		DrawBegin()
}
else
{
	DrawBegin()
}