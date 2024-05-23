/*
Author: Emek1501 [ASE]

Description:
Detta skript är utformat för att hitta alla byggnader inom en 25-meters radie från en specificerad markeringsposition och skapa AI-enheter på slumpmässiga positioner inom dessa byggnader. 
Enheterna är utrustade med en fördefinierad utrustning och deras positioner loggas. De skapade enheterna lagras sedan i en global variabel för vidare användning.

Variables:
- _position: Lagrar positionen för markören "bPos_1".
- _buildingArray: Array som innehåller alla objekt inom en 25-meters radie från den specificerade positionen.
- _building: Ett enskilt byggnadsobjekt från _buildingArray.
- _buildingPos: Array med giltiga positioner inom en byggnad.
- _randomPos_1: Array med slumpmässiga positioner valda från _buildingPos.
- _loadout: Array som definierar utrustningen för varje AI-enhet.
- _unit: Den skapade AI-enheten.

Remarks:
Skriptet hittar först alla närliggande byggnader och filtrerar bort de utan giltiga byggnadspositioner. 
Det skapar sedan upp till nio AI-enheter på slumpmässiga positioner inom varje giltig byggnad, utrustar dem med fördefinierad utrustning och loggar deras skapelse.

Parameter(s):
Inga

Important Notes:
- Markören "bPos_1" måste finnas på kartan.
- Skriptet beaktar endast objekt med giltiga byggnadspositioner (dvs. positioner där AI kan placeras).
- AI-enheterna skapas med kommandot createAgent och lagras i den globala variabeln "AIUnitsArray_1".

Potential Errors:
- Om inga byggnader hittas inom den specificerade radien, kommer skriptet inte att skapa några AI-enheter.
- Om markören "bPos_1" inte finns, kommer skriptet inte att hitta positionen och kasta ett fel.
- Skriptet förutsätter att AI-enhetstypen "B_Soldier_VR_F" och de specificerade utrustningsföremålen är tillgängliga i spelet.

Returns:
Inget

Example:
[] call compile preprocessFileLineNumbers "ASE_buildingSpawnAI.sqf";
*/

// Definierar en anonym funktion som ska utföras när den kallas.
call {

    // Skapar en variabel för positionen markerad av "bPos_1".
    private _position = markerPos "bPos_1";

    // Hittar alla objekt i närheten av den angivna positionen inom en radie av 25 meter.
    private _buildingArray = nearestObjects [_position, [], 25, true];

    // Filtrerar bort objekt som inte har giltiga byggnadspositioner.
    _buildingArray = _buildingArray select { str (_x buildingPos 0) != "[0,0,0]" };

    // Om mer än en byggnad hittas, reduceras arrayen till endast ett element.
    if (count _buildingArray > 1) then {
        _buildingArray resize 1;
    };

    // Initierar en global variabel för att lagra AI-enheter.
    missionNamespace setVariable ["AIUnitsArray_1", []];

    // Itererar genom varje byggnad i byggnadsarrayen.
    {
        private _building = _x;

        // Hämtar byggnadspositionerna för den aktuella byggnaden.
        private _buildingPos = _building buildingPos -1;

        // Om det finns byggnadspositioner, fortsätt.
        if (count _buildingPos > 0) then {

            // Skapar en array för att lagra slumpmässiga positioner inom byggnaden.
            private _randomPos_1 = [];

            // Itererar genom och väljer slumpmässiga byggnadspositioner.
            for "_i" from 1 to 9 do {
                private _index = selectRandom _buildingPos;
                _randomPos_1 pushBack _index;
                _buildingPos = _buildingPos - [_index];
            };

            // Itererar genom varje slumpmässig position.
            {
                // Definierar en loadout-array med utrustning för enheten.
                private _loadout = [
                    "rhs_weap_ak74m", // Vapen 0
                    "rhs_uniform_vkpo_gloves_alt", // Uniform 1
                    "rhs_6b45_rifleman_2", //Väst 2
                    "rhs_6b47_emr_1", // Hjälm 3
                    "", //Ryggsäck 4
                    ["rhs_30Rnd_545x39_7N10_AK", 1], // Primära vapenmagasin 5
                    "", // Sidovapen 6
                    [""], // Sidovapenmagasin 7
                    "rhs_acc_dtk", // Vapentillbehör 8
                    "", // Vapentillbehör 9
                    "", // Vapentillbehör 10
                    "" // Goggles 11
                    // Lägg till ytterligare utrustning efter behov
                ];

                // Skapar en AI-enhet på den slumpmässiga positionen.
                private _unit = createAgent ["B_Soldier_VR_F", _x, [], 0, "NONE"];
                
                // Sätter enhetens riktning och position.
                [_unit, 153.336] remoteExec ["setDir"];
                _unit disableAI "MOVE";
                _unit setUnitPos "UP";
                [_unit] call BIS_fnc_VRHitpart;

                // Tilldelar utrustningen till enheten.
                _unit addWeapon (_loadout select 0);
                _unit addVest (_loadout select 2);
                _unit addHeadgear (_loadout select 3);
                _unit addPrimaryWeaponItem (_loadout select 8);

                // Hämtar den globala variabeln för AI-enheter, lägger till den nya enheten, och uppdaterar variabeln.
                AIUnitsArray_1 = missionNamespace getVariable ["AIUnitsArray_1", []];
                AIUnitsArray_1 pushBack _unit;
                missionNamespace setVariable ["AIUnitsArray_1", AIUnitsArray_1];

                // Loggar att enheten skapades vid en viss position.
                diag_log format ["%1 created at %2", _unit, _x];

                // Justerar enhetens position beroende på om den är i vatten eller inte.
                if (surfaceIsWater _x) then {
                    _unit setPosASL AGLToASL _x;
                } else {
                    _unit setPosATL _x;
                };
                
            } forEach _randomPos_1;
        };
        
    } forEach _buildingArray;
};



call {
	private _position = markerPos "bPos_1";

	private _buildingArray = nearestObjects [_position, [], 25, true];

	_buildingArray = _buildingArray select { str (_x buildingPos 0) != "[0,0,0]" };


	if (count _buildingArray > 1) then {
		_buildingArray resize 1
	};


    missionNamespace setVariable ["AIUnitsArray_1", []];


	{
		private _building = _x;

		private _buildingPos = _building buildingPos -1;
		if (count _buildingPos > 0) then {

			private _randomPos_1 = [];
			for "_i" from 1 to 9 do {
				private _index = selectRandom _buildingPos;
				_randomPos_1 pushBack _index;
				_buildingPos = _buildingPos - [_index];
			};


			{

				private _loadout = [
					"rhs_weap_ak74m", // Vapen 0
					"rhs_uniform_vkpo_gloves_alt", // Uniform 1
					"rhs_6b45_rifleman_2", //Väst 2
					"rhs_6b47_emr_1", // Hjälm 3
					"", //Ryggsäck 4
					["rhs_30Rnd_545x39_7N10_AK", 1], // Primära vapenmagasin 5
					"", // Sidovapen 6
					[""], // Sidovapenmagasin 7
					"rhs_acc_dtk", //vapentillbehör 8
					"", //vapentillbehör 9
					"", //vapentillbehör 10
					"" //Googles 11
					// Lägg till ytterligare utrustning efter behov
				];



				private _unit = createAgent ["B_Soldier_VR_F", _x, [], 0, "NONE"];
				[_unit, 153.336] remoteExec ["setDir"];
				_unit disableAI "MOVE";
				_unit setUnitPos "UP";
				[_unit] call BIS_fnc_VRHitpart;

				_unit addWeapon (_loadout select 0);
				_unit addVest (_loadout select 2);
				_unit addHeadgear  (_loadout select 3);
				_unit addPrimaryWeaponItem (_loadout select 8);


                AIUnitsArray_1 = missionNamespace getVariable ["AIUnitsArray_1", []];
                AIUnitsArray_1 pushBack _unit;
                missionNamespace setVariable ["AIUnitsArray_1", AIUnitsArray_1];


				diag_log format ["%1 created at %2",_unit, _x];

				if (surfaceIsWater _x) then {
					_unit setPosASL AGLToASL _x;
				} else {
					_unit setPosATL _x;
				};
				
			} forEach _randomPos_1;
		};
		
	} forEach _buildingArray;
};