if (!isMultiplayer) then
{
	 switchableUnits
}
else
{
	if (isDedicated) then
	{
		 ((call BIS_fnc_listPlayers) - entities "HeadlessClient_F")
	}
	else
	{
		(allPlayers - entities "HeadlessClient_F")
	};
};