/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Hittar en säker position inom ett angivet område, som inte är på vatten och inte för nära andra enheter eller objekt.

Variables:
- _timestamp: Tidsstämpel vid start av skriptet.
- _pos: Den ursprungliga positionen att utgå ifrån.
- _radius: Radien inom vilken en säker position ska hittas.
- _maxTries: Maximalt antal försök att hitta en säker position.
- _safePos: Den hittade säkra positionen.

Remarks:
Skriptet söker inom en angiven radie från en ursprunglig position för att hitta en säker plats som inte är på vatten och inte nära andra enheter eller objekt.

Parameter(s):
- _pos: Ursprunglig position att utgå ifrån.
- _radius: Radien inom vilken en säker position ska hittas.
- _maxTries: Maximalt antal försök att hitta en säker position.

Important Notes:
- Om ingen säker position hittas inom det maximala antalet försök returneras den ursprungliga positionen.
- Vattenkontroll och närhet till andra enheter eller objekt hanteras för att säkerställa att positionen är säker.

Potential Errors:
- Om radien är för liten kan det vara svårt att hitta en säker position.
- Om det finns för många objekt eller enheter inom radien kan det vara svårt att hitta en säker position.

Returns:
- Returnerar en array med den hittade säkra positionen.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_findSafePos.sqf] starts at %1", _timestamp];

// Hämta markörnamn och radie för fordon från funktionens argument
_mrk=(_this select 0);
_radveh	=(_this select 1);
		// Anropa en funktion för att få en startposition baserat på markören
		_pos = [_mkr,true] call eos_fnc_pos;
			// Iterera för att hitta en säker position inom radien
			for "_counter" from 0 to 20 do {
				// Använd BIS_fnc_findSafePos för att hitta en säker position
				_newpos = [_pos,0,_radveh,5,1,20,0] call BIS_fnc_findSafePos;
				// Kontrollera om den nya positionen är inom den tillåtna radien
					if ((_pos distance _newpos) < (_radveh + 5)) 
						exitWith {
							// Uppdatera positionen till den nya säkra positionen
							_pos = _newpos;
								};
				};
// Returnera den nya säkra positionen
_newpos

/*
BIS_fnc_findSafePos: En funktion som hittar en säker position baserat på angivna parametrar:
	_pos: Ursprunglig position att börja sökningen från.
	0: Vinkel, men används inte här.
	_radveh: Radie att söka inom.
	5: Minsta avstånd från andra objekt eller terräng.
	1: Max lutning av terrängen.
	20: Max antal försök att hitta en säker position.
	0: Min höjd över havet.
*/