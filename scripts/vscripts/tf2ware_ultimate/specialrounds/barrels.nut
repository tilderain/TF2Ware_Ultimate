
special_round <- Ware_SpecialRoundData
({
	name = "Barrels"
	author = "tilderain"
	description = "Explosive barrels will rain from the sky!"
	category = ""
})

local barrels = []

function OnPrecache()
{
	PrecacheModel("models/props_c17/oildrum001_explosive.mdl")
}

function OnUpdate()
{
	if(barrels.len() < 64)
	{	
		if (RandomInt(0, 32) == 0)
			{ 
				local plyOrigin = RandomElement(Ware_Players).GetOrigin()
			
				local barrel = SpawnEntityFromTableSafe("prop_physics_multiplayer",
				{
					//Ware_MinigameLocation.center
					origin	 = plyOrigin + 
								Vector(RandomFloat(-250.0, 250.0), 
									   RandomFloat(-250.0, 250.0),
									   RandomFloat(250.0, 1000.0))
					model	  = "models/props_c17/oildrum001_explosive.mdl"
				})
			barrels.append(barrel)
		}
	}
	else
	{
		if(barrels[0].IsValid())
		{
			barrels[0].TerminateScriptScope()
			barrels[0].Kill()
		}
		barrels.remove(0)
	}

}