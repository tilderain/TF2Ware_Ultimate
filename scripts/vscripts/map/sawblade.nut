local sawblade;
local move_sound = "SawMill.Blade";
local touch_sound = "SawMill.BladeImpact";
local touched = false;

PrecacheScriptSound(move_sound);
PrecacheScriptSound(touch_sound);

function OnPostSpawn()
{
	for (local ent = self.FirstMoveChild(); ent != null; ent = ent.NextMovePeer())
	{
		if (ent.GetClassname() == "prop_dynamic")
		{
			sawblade = ent;
			break;
		}
	}
	
	local param = GetPropInt(self, "m_toggle_state") == 0 ? "Close" : "Open";
	EntFireByHandle(self, param, "", -1, null, null);
}

function Enable()
{
	EmitSoundOn(move_sound, self);
}

function Disable()
{
	StopSoundOn(move_sound, self);
}

function OnStartTouch()
{
	activator.TakeDamage(1000.0, DMG_SAWBLADE, self);
	DispatchParticleEffect("env_sawblood", activator.GetCenter(), Vector());
	EmitSoundOn(touch_sound, sawblade);
	
	if (!touched)
	{
		if (sawblade != null)
			sawblade.SetSkin(1);
		touched = true;
	}
}
