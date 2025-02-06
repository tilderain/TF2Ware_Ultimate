minigame <- Ware_MinigameData
({
	name          = "Pick Up That Can"
	author		  = "CzechMate"
	description   = "Pick Up And Trash The Can!"
	duration      = 7.0
	music         = "sweetdays"
})

::trashcan_model <- "models/props_trainstation/trashcan_indoor001b.mdl"
::can_model <- "models/props_junk/popcan01a.mdl"

////////////////////////// --- Settings --- ///////////////////////////////////////////

const PickupDistance = 100.0; // Distance the player can pick up the prop from
const Distance = 60.0;		// Distance from player to the picked up prop
const Outline = true;       // Outline props?
const CanOffset = 100.0;       // X and Y Offset for spawning cans
const CanHeightOffset = 300.0; // Z Offset for spawning cans
const PropFaceSameDirection = false // If true, makes the prop face the same direction as the player (similar to Half-Life 2)
local pickableObjects = ["prop_physics"]; // List of classnames that can be picked up

//////////////////////////////////////////////////////////////////////////////////////

function OnPrecache()
{
	PrecacheModel(can_model)
	PrecacheModel(trashcan_model)
}

function OnStart()
{
	foreach (player in Ware_MinigamePlayers)
	{
            player.ValidateScriptScope();
            player.GetScriptScope().LastButtons <- 0;
            player.GetScriptScope().PickedProp <- player;
            player.GetScriptScope().PlayerThink <- PlayerThink;
            AddThinkToEnt(player, "PlayerThink");
	}
    SpawnTriggerPush()
    Ware_CreateTimer(@() SpawnTrashcan(), 0.3)
    SpawnTriggerMultiple()
	SpawnCans()
}

function OnEnd()
{   
    foreach (player in Ware_MinigamePlayers)
	{
        RemoveEntityThink(player)
	}
}

function SpawnTrashcan() 
{
    local center = Ware_MinigameLocation.center
	center += Vector(0, 0, 20)
    local trashcan = Ware_SpawnEntity("prop_dynamic",
    {
        model = trashcan_model
        origin = center
		solid = 6
    })

    if (Outline)
    {
        local glow = Ware_CreateEntity("tf_glow")
        glow.KeyValueFromString("GlowColor", "0 255 0 255");
        SetPropEntity(glow, "m_hTarget", trashcan);
    }
}

function SpawnCans()
{
	local mins = Ware_MinigameLocation.mins
	local maxs = Ware_MinigameLocation.maxs

	foreach (player in Ware_MinigamePlayers)
	{
        local origin = Vector(
		RandomFloat(Ware_MinigameLocation.mins.x + CanOffset, Ware_MinigameLocation.maxs.x - CanOffset),
		RandomFloat(Ware_MinigameLocation.mins.y + CanOffset, Ware_MinigameLocation.maxs.y - CanOffset),
		Ware_MinigameLocation.center.z + CanHeightOffset)
        
		local can = Ware_SpawnEntity("prop_physics",
		{
			model = can_model
			origin = origin
		})
        can.SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        can.ValidateScriptScope()
        can.GetScriptScope().LastHolder <- null

        if (Outline)
        {
            local glow = Ware_CreateEntity("tf_glow")
            glow.KeyValueFromString("GlowColor", "255 0 111 255");
            SetPropEntity(glow, "m_hTarget", can);
        }
	}
}

function SpawnTriggerMultiple()
{
    local center = Ware_MinigameLocation.center
    local trigger_multiple = Ware_SpawnEntity("trigger_multiple",
    {
        targetname = "trashcan_trigger"
        origin     = center
        spawnflags = 8
    })
    trigger_multiple.SetSize(Vector(-5, -5, 0), Vector(5, 5, 24))
    trigger_multiple.SetSolid(2)

    trigger_multiple.ValidateScriptScope()
	trigger_multiple.GetScriptScope().OnStartTouch <- OnTriggerTouch
	trigger_multiple.ConnectOutput("OnStartTouch", "OnStartTouch")
}

function SpawnTriggerPush()
{
    local center = Ware_MinigameLocation.center
    local trigger_push = Ware_SpawnEntity("trigger_push", 
    {
        targetname = "trashcan_push"
        origin     = center
        pushdir    = QAngle(0, RandomFloat(0, 360), 0)
        speed      = 1000
        spawnflags = 1
    })
    trigger_push.SetSize(Vector(-20, -20, 0), Vector(20, 20, 50))
    trigger_push.SetSolid(2)
    EntFireByHandle(trigger_push, "Disable", "", 0.5, null, null)
}

function OnTriggerTouch()
{
    activator.ValidateScriptScope()
    local player = activator.GetScriptScope().LastHolder
    if (player)
        Ware_PassPlayer(player, true)
    
    activator.Destroy() //If the cans are not removed, they will lag the server due to physics calculations..
}

// Inspired by Prop Kill (https://github.com/Batfoxkid/TF2-Prop-Kill)
function PlayerThink()
{
    local alive = GetPropInt(self, "m_lifeState") == 0
    local buttons = alive ? GetPropInt(self, "m_nButtons") : 0;
    local newButtons = buttons & ~LastButtons;

    local MOUSE1 = (newButtons & Constants.FButtons.IN_ATTACK);
    local MOUSE2 = (newButtons & Constants.FButtons.IN_ATTACK2);

    if (MOUSE1 || MOUSE2)
    {
        if (PickedProp != self && PickedProp.IsValid())
        {
            if(MOUSE1 || MOUSE2) // Drop The Prop
            {
                PickedProp.SetOwner(null);
                PickedProp = self;
            }

        } else {

            local trace = 
            {
                start = self.EyePosition(),
                end = self.EyePosition() + self.EyeAngles().Forward() * (PickupDistance),
                ignore = self,
            }
            
            TraceLineEx(trace);

            if (trace.hit && PickableProp(trace.enthit))
            {
                PickedProp = trace.enthit;
                trace.enthit.SetOwner(self);
                trace.enthit.ValidateScriptScope();
                trace.enthit.GetScriptScope().LastHolder <- self;
            }
        }
    }

    if (PickedProp != self && PickedProp.IsValid())
    {
        local eye_position = self.EyePosition();
        local eye_angles = self.EyeAngles();
        local prop_origin = PickedProp.GetOrigin();
        local prop_angles = PickedProp.GetAbsAngles();
        local velocity = (eye_position + (eye_angles.Forward() * Distance) - prop_origin) * 100;

        if (PropFaceSameDirection)
            prop_angles = eye_angles
        PickedProp.Teleport(false, prop_origin, true, prop_angles, true, velocity);
        PickedProp.SetPhysAngularVelocity(Vector(0.0, 0.0, 0.0));
    }
   
    LastButtons = buttons;
    return -1;
}

::PickableProp <- function(entity)
{
    foreach (pickableObject in pickableObjects)
    {
        if (entity.GetClassname() == pickableObject)
        {
            foreach (player in Ware_MinigamePlayers)
            {
                player.ValidateScriptScope();
                if (player.GetScriptScope().PickedProp == entity)
                    return false;
            }
            return true;
        }
    }
    return false;
}