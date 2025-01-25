sawblade <- null
touched <- false

move_sound <- "SawMill.Blade"
touch_sound <- "SawMill.BladeImpact"

function Precache()
{
	PrecacheScriptSound(move_sound)
	PrecacheScriptSound(touch_sound)
}

function OnPostSpawn()
{
	for (local ent = self.FirstMoveChild(); ent != null; ent = ent.NextMovePeer())
	{
		MarkForPurge(ent)
		if (ent.GetClassname() == "trigger_multiple")
		{
			ent.ValidateScriptScope()
			ent.GetScriptScope().OnStartTouch <- OnStartTouch.bindenv(this)
			ent.ConnectOutput("OnStartTouch", "OnStartTouch")
		}
		else if (ent.GetClassname() == "prop_dynamic")
		{
			sawblade = ent
		}
	}
	
	local param = GetPropInt(self, "m_toggle_state") == 0 ? "Close" : "Open"
	EntityAcceptInput(self, param)
	MarkForPurge(self)
}

function Enable()
{
	EmitSoundOn(move_sound, self)
}

function Disable()
{
	StopSoundOn(move_sound, self)
}

function OnStartTouch()
{
	activator.TakeDamage(10000.0, DMG_SAWBLADE, self)
	DispatchParticleEffect("env_sawblood", activator.GetCenter(), Vector())
	EmitSoundOn(touch_sound, sawblade)
	
	if (!touched)
	{
		if (sawblade != null && sawblade.IsValid())
			sawblade.SetSkin(1)
		touched = true
	}
}
