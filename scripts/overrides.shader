rt2_muzzle_flash1
{
	{
		map "materials/effects/muzzleflash1.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_muzzle_flash2
{
	{
		map "materials/effects/muzzleflash2.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_muzzle_flash3
{
	{
		map "materials/effects/muzzleflash3.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_muzzle_flash4
{
	{
		map "materials/effects/muzzleflash4.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_combinemuzzle_flash1
{
	{
		map "materials/effects/combinemuzzle1.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_combinemuzzle_flash2
{
	{
		map "materials/effects/combinemuzzle2.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_fire_effect1
{
	{
		map "materials/effects/fire_cloud1.vtf"	
		blendFunc add
		rgbGen vertex
	}
}

rt2_fire_effect2
{
	{
		map "materials/effects/fire_embers2.vtf"	
		blendFunc add
		rgbGen vertex
	}
}

rt2_gun_smoke
{
	{
		map "materials/sprites/ar2_muzzle4.vtf"
		blendFunc add
		alphaGen vertex
	}
}

rt2_blood1
{

	{
		map "materials/decals/blood1.vtf"
		blendFunc gl_dst_color gl_src_color
		rgbGen vertex
	}
}

rt2_blood2
{

	{
		map "materials/decals/blood2.vtf"
		blendFunc gl_dst_color gl_src_color
		rgbGen vertex
	}
}

rt2_blood3
{
	polygonOffset
	{
		map "materials/decals/blood3.vtf"
		blendFunc gl_dst_color gl_src_color
		rgbGen vertex
	}
}

rt2_blood4
{
	polygonOffset
	{
		map "materials/decals/blood4.vtf"
		blendFunc gl_dst_color gl_src_color
		rgbGen vertex
	}
}

rt2_bluelaser1
{
	{
		map "materials/effects/bluelaser1.vtf"
		blendFunc add
		tcMod transform 1 1 1 1 0 0 
		rgbGen vertex
	}
}
