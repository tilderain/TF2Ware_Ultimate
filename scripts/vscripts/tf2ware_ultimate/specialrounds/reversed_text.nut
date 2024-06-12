special_round <- Ware_SpecialRoundData
({
	name = "Reversed Text"
	author = "ficool2"
	description = "All text is reversed!"
	reverse_text = true
})

function OnStart()
{
	// the text reads the water_lod_control entity to check if it should reverse
	SetPropFloat(WaterLOD, "m_flCheapWaterEndDistance", 1)
}

function OnEnd()
{
	SetPropFloat(WaterLOD, "m_flCheapWaterEndDistance", 0)
}