/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Hanterar lastning av enheter i fordon, inklusive att tilldela rätt positioner och roller för varje enhet i fordonet.

Variables:
- _timestamp: Tidsstämpel vid start av skriptet.
- _cargo: Array med enheter som ska lastas in i fordonet.
- _vehicle: Fordonet som enheterna ska lastas in i.
- _vehType: Typ av fordon.
- _cargoType: Typ av enheter som ska lastas (t.ex. infanteri, dykare).

Remarks:
Skriptet tilldelar varje enhet en specifik position i fordonet och hanterar deras AI-beteenden och variabler för att säkerställa korrekt lastning och funktion.

Parameter(s):
- _vehicle: Fordonet som enheterna ska lastas in i.
- _cargoType: Typ av enheter som ska lastas (t.ex. infanteri, dykare).
- _faction: Fraktionen som enheterna tillhör.
- _size: Antal enheter som ska lastas i fordonet.

Important Notes:
- Fordon och enheter måste vara korrekt definierade för att säkerställa att lastningen fungerar.
- AI-beteenden och variabler måste vara korrekt inställda för att undvika konflikter och oväntade beteenden.

Potential Errors:
- Om fordonet inte har tillräckligt med utrymme kan enheter inte lastas korrekt.
- Felaktiga enhetstyper kan leda till att enheter inte kan tilldelas rätt positioner i fordonet.

Returns:
- Inga specifika returer, enheterna lastas i fordonet och deras positioner och roller tilldelas korrekt.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_cargo.sqf] starts at %1", _timestamp];

// Kontrollerar om koden körs på servern, vilket är nödvändigt för korrekt synkronisering i multiplayer
if (!isServer) then {
	diag_log "Denna kod måste köras på servern";
} else {
	private ["_unit"];
	private _vehicle=(_this select 0); // fordonet där enheterna placeras
	private _grpSize=(_this select 1); // önskad gruppstorlek som en array [min, max]
	private _grp=(_this select 2); // gruppen som enheterna tillhör
	private _faction=(_this select 3); // fraktionen som enheterna tillhör
	private _cargoType=(_this select 4); // typ av cargo/enheter som ska skapas
	private _debug=true; // debug-läge är avstängt som standard

	// Hämtar en pool av enhetstyper baserat på fraktion och cargo-typ
	private _cargoPool=[_faction,_cargoType] call eos_fnc_getunitpool;
	private _side=side (leader _grp); // sidan (fraktionen) som gruppledaren tillhör

	// FILL EMPTY SEATS	
	// Räkna antalet tomma platser i fordonet	
	private _emptySeats=_vehicle emptyPositions "cargo";
	if (_debug) then {
		hint format ["%1",_emptySeats];
	};

	//GET MIN MAX GROUP
	// Beräkna antalet enheter att skapa baserat på min och max värden
	private _grpMin=_grpSize select 0;
	private _grpMax=_grpSize select 1;
	private _d=_grpMax-_grpMin;				
	private _r=floor(random _d);							
	_grpSize=_r+_grpMin;
			
	// IF VEHICLE HAS SEATS	
	// Kontrollera om det finns tomma platser i fordonet
	if (_emptySeats > 0) then {
	// Begränsa antalet enheter till antalet lediga platser om nödvändigt
	// LIMIT SEATS TO FILL TO GROUP SIZE		
		if 	(_grpSize > _emptySeats) then {
			_grpSize = _emptySeats
		};					
		if (_debug) then {
			hint format ["Seats Filled : %1",_grpSize];
		};	
		// Skapa enheterna och placera dem i fordonet			
		for "_x" from 1 to _grpSize do {					
			_unit=_cargoPool select (floor(random(count _cargoPool)));
			_unit=_unit createUnit [GETPOS _vehicle, _grp]; // enheten skapas vid fordonets position och tilldelas till gruppen
		};
								
		// Flytta enheterna till cargo-platserna i fordonet							
		{
			_x moveincargo _vehicle
		} foreach units _grp;

		{
			_x setVariable ["lambs_danger_disableAI", false];
			_x setVariable ["lambs_danger_dangerRadio", true];
			
		} forEach units _grp;
	};

	_grp setVariable ["lambs_danger_enableGroupReinforce", true, true];
	_grp setVariable ["lambs_danger_disableGroupAI", false];
};