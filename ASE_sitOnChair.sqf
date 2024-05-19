/*
    Author: Emek1501

    Description:
    Detta skript hanterar animationer och interaktioner för enheter som sitter och står upp från olika typer av stolar.

    Constants:
    ANIMATIONS - En array som innehåller olika animationer för att sitta och röra sig på stolar.
    CLASSES - En array som innehåller klasser av olika stolar som används i spelet.
    OFFSET - En array som definierar offset-positioner för varje typ av stol.
    DIRECTIONS - En array som innehåller riktningar för enheter som sitter på stolar.

    Functions:
    _fnc_standUp - Hanterar logiken för att en enhet ska resa sig upp från en stol.
    _fnc_sitDown - Hanterar logiken för att en enhet ska sätta sig ner på en stol.
    _fnc_switchMove - Väljer och byter till en slumpmässig sittanimation för en enhet.

	Example:
	[] spawn compile preprocessFileLineNumbers "_fnc_sitOnChair.sqf";
*/

// Definierar olika animationer för att sitta och röra sig på stolar
#define ANIMATIONS [ \
    "HubSittingChairA_idle1", \
    "HubSittingChairA_idle2", \
    "HubSittingChairA_idle3", \
    "HubSittingChairA_move1", \
    "HubSittingChairB_idle1", \
    "HubSittingChairB_idle2", \
    "HubSittingChairB_idle3", \
    "HubSittingChairB_move1", \
    "HubSittingChairC_idle1", \
    "HubSittingChairC_idle2", \
    "HubSittingChairC_idle3", \
    "HubSittingChairC_move1", \
    "HubSittingChairUA_idle1", \
    "HubSittingChairUA_idle2", \
    "HubSittingChairUA_idle3", \
    "HubSittingChairUA_move1", \
    "HubSittingChairUB_idle1", \
    "HubSittingChairUB_idle2", \
    "HubSittingChairUB_idle3", \
    "HubSittingChairUB_move1", \
    "HubSittingChairUC_idle1", \
    "HubSittingChairUC_idle2", \
    "HubSittingChairUC_idle3", \
    "HubSittingChairUC_move1" \
]

// Definierar olika klasser av stolar
#define CLASSES [ \
    "Land_CampingChair_V1_F", \
    "Land_CampingChair_V2_F", \
    "Land_ChairPlastic_F", \
    "Land_OfficeChair_01_F", \
    "Land_RattanChair_01_F", \
    "Land_ArmChair_01_F", \
    "Land_DeskChair_01_black_F" \
]

// Definierar offset-positioner för varje typ av stol
#define OFFSET [ \
    [0, -0.1, -0.45], \
    [0, -0.1, -0.45], \
    [0, 0, -0.5], \
    [0, 0, -0.6], \
    [0, -0.1, -0.5], \
    [0, 0, -0.5], \
    [0, 0, -0.25] \
]

// Definierar riktningar för enheter som sitter på stolar
#define DIRECTIONS [ \
    180, \
    180, \
    90, \
    180, \
    180, \
    0, \
    0 \
]

// Funktion för att en enhet ska resa sig upp från en stol
_fnc_standUp = {
	// Hämta parametrar från input-arrayen
	_chair = _this select 0;  // Stolen
	_unit = _this select 1;   // Enheten
	_oldScript = _this select 2; // Gamla skriptet


	// Stoppar sitt-animationen och tar bort sitt-action från enheten
	[_unit, ""] remoteExec ["_fnc_switchMove", 0];
	_unit removeAction _oldScript ;
	// Lägger till en ny action på stolen för att sätta sig ner igen
	[_chair, ["Sitt ner", { call _fnc_standUp; }]] remoteExec ["addAction", _chair, _sitDown];
};

// Funktion för att en enhet ska sätta sig ner på en stol
_fnc_sitDown = {
	// Hämta parametrar från input-arrayen
	_chair = _this select 0;  // Stolen
	_unit = _this select 1;   // Enheten
	_oldScript = _this select 2; // Gamla skriptet

	// Hämta index och position för sittande, samt riktning från definierade konstanter
	private _index = CLASSES;
	private _sitPosition = OFFSET select _index;
	private _sitDirection = DIRECTIONS select _index;

	// Sätter enheten i sitt-position och riktning
	[_unit, "Crew"] remoteExec ["_fnc_switchMove", 0];
	_unit attachTo [_chair, _sitPosition];
	_unit setDir _sitDirection;

	// Tar bort stå-upp action från stolen och lägger till en stå-upp action på enheten
	_chair removeAction _oldScript ;
	[_unit, ["<t color='#EEAA22'>Stå upp</t>", { call _fnc_standUp; }]] remoteExec ["addAction"];
};

// Funktion för att byta animation till en slumpmässigt vald sittanimation
_fnc_switchMove =
{
	// Hämta parametern (enhet)
   	private _object = _this select 0;

   	// Välj en slumpmässig animation från ANIMATIONS-arrayen
   	private _anim = selectRandom ANIMATIONS;
 
	// Byt animation för enheten
   	_object switchMove _anim;
};