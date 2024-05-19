/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Hanterar bastionszoner och deras enheter, inklusive skapandet av patruller och fordon, samt hantering av attacker och förstärkningar.

Variables:
- VictoryColor, hostileColor, bastionColor: Färger för markörer baserat på zonstatus.

Remarks:
Skriptet hanterar aktivering av bastionszoner, spawnenheter och deras beteenden, samt logik för attacker och zonkontroll.

Parameter(s):
- _mkr: Markeringsposition.
- _infantry: Infanterikonfiguration (antal, storlek).
- _LVeh: Lätta fordon (antal, storlek).
- _AVeh: Bepansrade fordon (antal).
- _SVeh: Statisk/helikopterkonfiguration (antal).
- _settings: Inställningar för EOS (fraktion, markörens alfa, sida, höjdbegränsning, debug).
- _basSettings: Basinställningar (paus, vågor, timeout, EOS-zon, tipsmeddelanden).
- _initialLaunch: Initial startindikator.

Important Notes:
- Detta skript måste köras på servern.
- Inställningar och konfigurationer måste vara korrekt definierade för att undvika fel.

Potential Errors:
- Felaktiga markörnamn eller odefinierade inställningar kan orsaka skriptfel och oväntade beteenden.

Returns:
- Inga specifika returer, enheter och patruller hanteras inom bastionszonen.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_b_core.sqf] starts at %1", _timestamp];

if (!isServer) then {
	diag_log "EOS b_core: Denna kod måste köras på servern";
} else {
	private [
		 "_fGroup",            // Variabel för grupp av fordon eller helikoptrar
        "_cargoType",         // Variabel för typ av last
        "_vehType",           // Variabel för fordonstyp
        "_CHside",            // Variabel för sida som helikoptrar tillhör
        "_mkrAgl",            // Variabel för markörens riktning
        "_initialLaunch",     // Variabel för initial start
        "_pause",             // Variabel för paus innan attack
        "_eosZone",           // Variabel för EOS-zon
        "_hints",             // Variabel för att visa tipsmeddelanden
        "_waves",             // Variabel för antal vågor av förstärkningar
        "_aGroup",            // Variabel för infanterigrupper
        "_side",              // Variabel för sida (vän, fiende, etc.)
        "_actCond",           // Variabel för aktiveringsvillkor
        "_enemyFaction",      // Variabel för fiendens fraktion
        "_mAH",               // Variabel för markörens alfa-värde vid hög synlighet
        "_mAN",               // Variabel för markörens alfa-värde vid låg synlighet
        "_distance",          // Variabel för avstånd
        "_grp",               // Variabel för grupp
        "_cGroup",            // Variabel för bepansrade fordonsgrupper
        "_bGroup",            // Variabel för lätta fordonsgrupper
        "_CHType",            // Variabel för helikoptertyp
        "_time",              // Variabel för tid
        "_timeout",           // Variabel för timeout
        "_faction",           // Variabel för fraktion
		"_difficulty"		  // Variabel för svårighetsgrad
	];

	// Hämta segerfärg från missionNamespace, standard är grön
	private _victoryColor = missionNamespace getVariable ["VictoryColor", "colorGreen"];
	// Hämta fiendens färg från missionNamespace, standard är röd
	private _hostileColor = missionNamespace getVariable ["hostileColor", "colorRed"];
	// Hämta färg för bastion från missionNamespace, standard är orange
	private _bastionColor = missionNamespace getVariable ["bastionColor", "colorOrange"];

		_mkr=(_this select 0); // Markören som representerar zonen
		_mPos=markerpos(_this select 0); // Hämtar markörens position
		_mkrX=getMarkerSize _mkr select 0; // Hämtar markörens bredd
		_mkrY=getMarkerSize _mkr select 1; // Hämtar markörens höjd
		_mkrAgl=markerDir _mkr; // Hämtar markörens riktning
		_infantry=(_this select 1); // Infanterikonfiguration
		_PApatrols=_infantry select 0; // Antal infanteripatruller
		_PAgroupSize=_infantry select 1; // Storlek på infanterigrupper
		_LVeh=(_this select 2); // Lätta fordon
		_LVehGroups=_LVeh select 0; // Antal lätta fordonsgrupper
		_LVgroupSize=_LVeh select 1; // Storlek på lätta fordonsgrupper
		_AVeh=(_this select 3); // Bepansrade fordon
		_AVehGroups=_AVeh select 0; // Antal bepansrade fordonsgrupper
		_SVeh=(_this select 4); // Statisk/helikopterkonfiguration
		_CHGroups=_SVeh select 0; // Antal helikoptergrupper
		_fSize=_SVeh select 1; // Storlek på helikoptergrupper
		_settings=(_this select 5); // Inställningar för EOS
		_faction=_settings select 0; // Fraktion
		_mA=_settings select 1; // Markörens alfa-inställning
		_side=_settings select 2; // Sida (vän, fiende, etc.)
		_heightLimit=if (count _settings > 4) then { // Kontroll för höjdbegränsning
			_settings select 4
		} else { // Om det finns fler än fyra inställningar
			false // Annars standard till false
		};
		_debug=if (count _settings > 5) then { // Kontroll för debugläge
			_settings select 5
		} else { // Om det finns fler än fem inställningar
			false // Annars standard till false
		};
		_difficulty = if (count _settings > 6) then {
			_settings select 6
		} else {
			2
		};
		_basSettings=(_this select 6); // Basinställningar
		_pause=_basSettings select 0; // Paus före attack
		_waves=_basSettings select 1; // Antal vågor av attacker
		_timeout=_basSettings select 2; // Timeout för attacker
		_eosZone=_basSettings select 3; // EOS-zon flagga
		_hints=_basSettings select 4; // Tipsmeddelanden
		_initialLaunch= if (count _this > 7) then { // Kontroll för initial start
			_this select 7} else { // Om det finns fler än sju parametrar
				false // Annars standard till false
			};

		_Placement=(_mkrX + 500); // Placering baserat på markörens bredd + 500

		// Justera anropen för att inkludera svårighetsgraden
		_difficulty = missionNamespace getVariable ["difficultyLevel", 1];

		if (_mA==0) then {
			_mAH = 1;
			_mAN = 0.5;
		}; // Om markörens alfa är 0, sätt högt alfa till 1 och lågt till 0.5
		if (_mA==1) then {
			_mAH = 0;
			_mAN = 0;
		}; // Om markörens alfa är 1, sätt både högt och lågt alfa till 0
		if (_mA==2) then {
			_mAH = 0.5;
			_mAN = 0.5;
		}; // Om markörens alfa är 2, sätt både högt och lågt alfa till 0.5
		
		if (_side==EAST) then {
			_enemyFaction="east";
		}; // Om sidan är EAST, sätt fiendens fraktion till öst
		if (_side==WEST) then {
			_enemyFaction="west";
		}; // Om sidan är WEST, sätt fiendens fraktion till väst
		if (_side==INDEPENDENT) then {
			_enemyFaction="GUER";
		}; // Om sidan är INDEPENDENT, sätt fiendens fraktion till gerilla
		if (_side==CIVILIAN) then {
			_enemyFaction="civ";
		}; // Om sidan är CIVILIAN, sätt fiendens fraktion till civil

		if ismultiplayer then { // Om spelet är multiplayer
			if (_heightLimit) then { // Om höjdbegränsning är satt
				_actCond="{vehicle _x in thisList && isplayer _x && ((getPosATL _x) select 2) < 5} count playableunits > 0"; // Villkor: fordon i listan, är spelare och höjd mindre än 5
			} else {
				_actCond="{vehicle _x in thisList && isplayer _x} count playableunits > 0"; // Villkor: fordon i listan och är spelare
			};
		} else {
			if (_heightLimit) then {
				_actCond="{vehicle _x in thisList && isplayer _x && ((getPosATL _x) select 2) < 5} count allUnits > 0"; // Villkor: fordon i listan, är spelare och höjd mindre än 5 för alla enheter
			} else {
			} else {
				_actCond="{vehicle _x in thisList && isplayer _x} count allUnits > 0"; // Villkor: fordon i listan och är spelare för alla enheter
			};
		};

	// Skapar och konfigurerar aktiveringstriggers för EOS-zon							
	_basActivated = createTrigger ["EmptyDetector",_mPos];  // Skapa tom detektortrigger vid markeringsposition
	_basActivated setTriggerArea [_mkrX,_mkrY,_mkrAgl,FALSE]; // Ställ in triggerområdet baserat på markeringsstorlek och riktning
	_basActivated setTriggerActivation ["ANY","PRESENT",true];  // Aktivera trigger när någon enhet är närvarande
	_basActivated setTriggerStatements [_actCond,"",""];  // Ange aktiveringsvillkor för triggern

	// Ställer in markörens färg och genomskinlighet för bastion				
	_mkr setmarkercolor _bastionColor; // Sätt markörfärgen till bastionens färg
	_mkr setmarkeralpha _mAN; // Sätt markörens genomskinlighet till låg alfa	

	// Väntar tills basaktiveringen triggas	
	waituntil {triggeractivated _basActivated};
	_mkr setmarkercolor _bastionColor; // Återställ markörfärgen till bastionens färg
	_mkr setmarkeralpha _mAH; // Sätt markörens genomskinlighet till hög alfa

	// Skapa och konfigurera aktiveringstriggers för bastion	
	_bastActive = createTrigger ["EmptyDetector",_mPos];  // Skapa tom detektortrigger för bastion vid markeringsposition
	_bastActive setTriggerArea [_mkrX,_mkrY,_mkrAgl,FALSE];  // Ställ in triggerområdet baserat på markeringsstorlek och riktning
	_bastActive setTriggerActivation ["any","PRESENT",true]; // Aktivera trigger när någon enhet är närvarande
	_bastActive setTriggerTimeout [1, 1, 1, true]; // Ställ in triggerns timeout
	_bastActive setTriggerStatements [_actCond,"",""]; // Ange aktiveringsvillkor för triggern

	// Skapa och konfigurera rensningstriggers för bastion						
	_bastClear = createTrigger ["EmptyDetector",_mPos];  // Skapa tom detektortrigger för rensning vid markeringsposition
	_bastClear setTriggerArea [(_mkrX+(_Placement*0.3)),(_mkrY+(_Placement*0.3)),_mkrAgl,FALSE]; // Ställ in triggerområdet för rensning 
	_bastClear setTriggerActivation [_enemyFaction,"NOT PRESENT",true]; // Aktivera trigger när fiendefraktionen inte är närvarande 
	_bastClear setTriggerStatements ["this","",""]; // Ange aktiveringsvillkor för triggern 

	// Om en paus är begärd och det inte är en initial start, pausa spelet							
	if (_pause > 0 and !_initialLaunch) then {
		for "_counter" from 1 to _pause do {
			if (_hints) then  {
				hint format ["Attack ETA : %1",(_pause - _counter)]; // Visa tips om återstående tid till attack
			};
			sleep 1; // Pausa skriptet i 1 sekund
		};
	};

	// SPAWN PATROLS		
	_aGroup=[];
	for "_counter" from 1 to _PApatrols do {	
		_pos = [_mPos, _Placement, random 360] call BIS_fnc_relPos;
		_grp=[_pos,_PAgroupSize,_faction,_side] call EOS_fnc_spawngroup;	
		_aGroup set [count _aGroup,_grp];
		if (_debug) then {
			PLAYER SIDECHAT (format ["Spawned Patrol: %1",_counter]);
			0= [_mkr,_counter,"patrol",getpos (leader _grp)] call EOS_debug
		};
	};	
											
	//SPAWN LIGHT VEHICLES		
	_bGrp=[];
	for "_counter" from 1 to _LVehGroups do {
		_newpos = [_mPos, (_Placement +200), random 360] call BIS_fnc_relPos;
		if (surfaceiswater _newpos) then {
			_vehType=8;_cargoType=10;
		} else {
			_vehType=7;
			_cargoType=9;
		};
				
		_bGroup=[_newpos,_side,_faction,_vehType]call EOS_fnc_spawnvehicle;					
					
		if ((_LVgroupSize select 0) > 0) then{
			0=[(_bGroup select 0),_LVgroupSize,(_bGroup select 2),_faction,_cargoType] call eos_fnc_setcargo;
		};
															
		0=[(_bGroup select 2),"LIGskill",_difficulty] call eos_fnc_grouphandlers;
		_bGrp set [count _bGrp,_bGroup];		
		if (_debug) then {
			player sidechat format ["Light Vehicle:%1 - r%2",_counter,_LVehGroups];
			0= [_mkr,_counter,"Light Veh",(getpos leader (_bGroup select 2))] call EOS_debug
		};
	};	
			
	//SPAWN ARMOURED VEHICLES
	_cGrp=[];
	for "_counter" from 1 to _AVehGroups do {
		_newpos = [_mPos, _Placement, random 360] call BIS_fnc_relPos;
		if (surfaceiswater _newpos) then {
			_vehType=8;
		} else {
			_vehType=2;
		};
		_cGroup=[_newpos,_side,_faction,_vehType]call EOS_fnc_spawnvehicle;
						
		0=[(_cGroup select 2),"ARMskill",_difficulty] call eos_fnc_grouphandlers;	
		_cGrp set [count _cGrp,_cGroup];					
		if (_debug) then {
			player sidechat format ["Armoured:%1 - r%2",_counter,_AVehGroups];
			0= [_mkr,_counter,"Armour",(getpos leader (_cGroup select 2))] call EOS_debug
		};
	};

	//SPAWN HELICOPTERS		
	_fGrp=[];
	for "_counter" from 1 to _CHGroups do {
		if ((_fSize select 0) > 0) then {
			_vehType=4
		} else {
			_vehType=3
		};
		_newpos = [(markerpos _mkr), 1500, random 360] call BIS_fnc_relPos;	
		_fGroup=[_newpos,_side,_faction,_vehType,"fly"]call EOS_fnc_spawnvehicle;	
		_CHside=_side;
		_fGrp set [count _fGrp,_fGroup];
							
		if ((_fSize select 0) > 0) then {
			_cargoGrp = createGroup _side;
			0=[(_fGroup select 0),_fSize,_cargoGrp,_faction,9] call eos_fnc_setcargo;
			0=[_cargoGrp,"INFskill",_difficulty] call eos_fnc_grouphandlers;
			_fGroup set [count _fGroup,_cargoGrp];
			null = [
				_mkr,
				_fGroup,
				_counter
			] spawn compile preprocessFileLineNumbers eos_fnc_transportUnload_path;
		} else {
			_wp1 = (_fGroup select 2) addWaypoint [(markerpos _mkr), 0];  
			_wp1 setWaypointSpeed "FULL";  
			_wp1 setWaypointType "SAD";
		};

		// Ställ in helikoptergruppens färdigheter
        0 = [(_fGroup select 2),"AIRskill",_difficulty] call eos_fnc_grouphandlers;

		if (_debug) then {
			player sidechat format ["Chopper:%1",_counter];
			0= [_mkr,_counter,"Chopper",(getpos leader (_fGroup select 2))] call EOS_debug
		};
	};	

	// ADD WAYPOINTS
	{
		[
			_x, 
			1500,
			15,
			[],
			[_mpos],
			true,
			true,
			1
		] spawn lambs_wp_fnc_taskHunt;
	}foreach _aGroup;
		
	{
		[
			_x select 2, 
			1500,
			15,
			[],
			[_mpos],
			true,
			true,
			1
		] spawn lambs_wp_fnc_taskHunt;
	}foreach _cGrp;
		
	{
		_pos = [_mPos, (_mkrX + 50), random 360] call BIS_fnc_relPos;
		[
			_x select 2, 
			1500,
			15,
			[],
			[_pos],
			true,
			true,
			1
		] spawn lambs_wp_fnc_taskHunt;
	}foreach _bGrp;	
		
		
	waituntil {triggeractivated _bastActive};	

	for "_counter" from 1 to _timeout do {
		if (_hints) then  {
			if (_waves > 1) then {
				hint format ["Next wave ETA : %1",(_timeout - _counter)];
			};
		};
		sleep 1;
		if (!triggeractivated _bastActive || getmarkercolor _mkr == "colorblack") exitwith {			
			hint "Zone lost. You must re-capture it";
			_mkr setmarkercolor _hostileColor;
			_mkr setmarkeralpha _mAN;
						
			if (_eosZone) then {
				null = [
					_mkr,
					[_PApatrols,_PAgroupSize],
					[_PApatrols,_PAgroupSize],
					[_LVehGroups,_LVgroupSize],
					[_AVehGroups,0,0,0],
					[_faction,_mA,350,_CHside]
				] spawn compile preprocessFileLineNumbers EOS_core_path;

			};
			_waves=0;
		};				
	};
										
	_waves=(_waves - 1);
		
	if (triggeractivated _bastActive and triggeractivated _bastClear and (_waves < 1) ) then {
		if (_hints) then  {
			hint "Waves complete";
		};
		_mkr setmarkercolor _victoryColor;
		_mkr setmarkeralpha _mAN;
					
	} else {
		if (_waves >= 1) then {
			if (_hints) then  {hint "Reinforcements inbound";};
			null = [
				_mkr,
				[_PApatrols,_PAgroupSize],
				[_LVehGroups,_LVgroupSize],
				[_AVehGroups],
				[_CHGroups,_fSize],
				_settings,
				[_pause, _waves, _timeout, _eosZone, _hints],
				true
			] spawn compile preprocessFileLineNumbers EOS_Bastion_core_path;
		};
	};
		
	waituntil {getmarkercolor _mkr == "colorblack" OR getmarkercolor _mkr == _victoryColor OR getmarkercolor _mkr == _hostileColor or !triggeractivated  _bastActive};
	if (_debug) then {
		player sidechat "delete units";
	};							
	{
		{
			deleteVehicle _x
		} foreach units _x;
	} foreach _aGroup;
						
	if (count _cGrp > 0) then {				
		{				
			_vehicle = _x select 0;
			_crew = _x select 1;
			_grp = _x select 2;
			{
				deleteVehicle _x
			} forEach (_crew);		
			if (!(vehicle player == _vehicle)) then {
				{
					deleteVehicle _x
				} forEach[_vehicle];
			};												
			{
				deleteVehicle _x
			} foreach units _grp;
			deleteGroup _grp;
		} foreach _cGrp;
	};
						
	if (count _bGrp > 0) then {				
		{			
			_vehicle = _x select 0;
			_crew = _x select 1;
			_grp = _x select 2;
			{deleteVehicle _x} forEach (_crew);		
			if (!(vehicle player == _vehicle)) then {
				{deleteVehicle _x} forEach[_vehicle];
			};												
			{deleteVehicle _x} foreach units _grp;
			deleteGroup _grp;
		}foreach _bGrp;
	};
														
	// CACHE HELICOPTER TRANSPORT
	if (count _fGrp > 0) then {			
		{	
			_vehicle = _x select 0;
			_crew = _x select 1;
			_grp = _x select 2; 
			_cargoGrp = _x select 3;		
			{deleteVehicle _x} forEach (_crew);
			if (!(vehicle player == _vehicle)) then {
				{deleteVehicle _x} forEach[_vehicle];
			};													
			{deleteVehicle _x} foreach units _grp;
			deleteGroup _grp;
			{deleteVehicle _x} foreach units _cargoGrp;
			deleteGroup _cargoGrp;
																		
		}foreach _fGrp;
	};	
						
	deletevehicle _bastActive;
	deletevehicle _bastClear;
	deletevehicle _basActivated;
	if (getmarkercolor _mkr == "colorblack") then {
		_mkr setmarkeralpha 0;
	};
};
