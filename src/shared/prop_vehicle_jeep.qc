#ifdef SERVER
class prop_vehicle_jeep:prop_vehicle_driveable
{
	void(void) prop_vehicle_jeep;
};

void
prop_vehicle_jeep::prop_vehicle_jeep(void)
{
	m_vecSeatOffest = [0,0,0];
	model = "models/buggy.mdl";
}
#endif
