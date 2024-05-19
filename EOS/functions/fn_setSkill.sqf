/*
Version: 1.0.0 [2024-05-19]

Author: Emek1501 [ASE]

Description:
Sätter färdigheter för grupper baserat på skill-typ och svårighetsgrad.

Variables:
- EOS_DAMAGE_MULTIPLIER: Justerar skadehanteringen.
- EOS_KILLCOUNTER: Aktiverar räkning av dödade enheter.

Remarks:
Skriptet hämtar och applicerar färdighetsinställningar på varje enhet i gruppen baserat på den angivna skill-typen och svårighetsgraden.

Parameter(s):
- _grp: Gruppen som färdigheterna ska tillämpas på.
- _skillType: Typ av enhetsfärdigheter som ska tillämpas (t.ex. "INFskill" för infanteri).
- _difficulty: Svårighetsgrad för färdigheterna.

Important Notes:
- Färdighetsinställningar måste vara korrekt definierade i missionNamespace för varje _skillType.
- Om EOS_DAMAGE_MULTIPLIER och EOS_KILLCOUNTER är aktiverade, justeras skadehantering och dödsräkning för enheterna.

Potential Errors:
- Om färdighetsinställningarna inte är korrekt definierade kan standardvärden användas vilket kan leda till oväntade AI-beteenden.

Returns:
- Inga specifika returer, färdigheter appliceras direkt på enheterna.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_setSkill.sqf] starts at %1", _timestamp];

// Hämta gruppen och färdighetsarrayen från funktionens argument
private _grp=(_this select 0);
private _skillType = (_this select 1);
private _difficulty = (_this select 2);
private "_skillSet";
					
//_skillset = server getvariable _difficulty;
// Hämta färdighetsinställningarna från missionnamespace eller använd standardvärden
_difficulty = missionnamespace getvariable ["difficultyLevel", 1];
diag_log format ["fn_setSkill: Difficulty Level - %1", _difficulty];

// Logga svårighetsgraden och skilltypen
diag_log format ["fn_setSkill: Difficulty Level - %1, Skill Type - %2", _difficulty, _skillType];

// Hämta rätt färdighetsset baserat på skilltypen och svårighetsgraden
switch (_skillType) do {
    case "INFskill": {
        _skillSet = missionNamespace getVariable ["INFskill", []];
        diag_log format ["fn_setSkill: Applying Infantry skillset - %1", _skillSet];
    };
    case "ARMskill": {
        _skillSet = missionNamespace getVariable ["ARMskill", []];
        diag_log format ["fn_setSkill: Applying Armour skillset - %1", _skillSet];
    };
    case "LIGskill": {
        _skillSet = missionNamespace getVariable ["LIGskill", []];
        diag_log format ["fn_setSkill: Applying Light Vehicle skillset - %1", _skillSet];
    };
    case "AIRskill": {
        _skillSet = missionNamespace getVariable ["AIRskill", []];
        diag_log format ["fn_setSkill: Applying Helicopter skillset - %1", _skillSet];
    };
    case "STAskill": {
        _skillSet = missionNamespace getVariable ["STAskill", []];
        diag_log format ["fn_setSkill: Applying Static Weapon skillset - %1", _skillSet];
    };
    default {
        diag_log format ["fn_setSkill: Unknown skill type %1. Applying default Infantry skillset.", _skillType];
        _skillSet = missionNamespace getVariable ["INFskill", []];
    };
};

// Kontrollera att _skillSet är definierad innan den används
if (count _skillSet == 9) then {
	// Logga skillSet detaljer
    diag_log format ["fn_setSkill: SkillSet Details - %1", _skillSet];
	// Iterera över varje enhet i gruppen för att tilldela färdigheter och event handlers
	{
		_unit = _x;

		// Applicera färdigheter till varje enhet i gruppen
		_x setSkill ["aimingAccuracy", _skillSet select 0];
		_x setSkill ["aimingShake", _skillSet select 1];
		_x setSkill ["aimingSpeed", _skillSet select 2];
		_x setSkill ["commanding", _skillSet select 3];
		_x setSkill ["courage", _skillSet select 4];
		_x setSkill ["general", _skillSet select 5];
		_x setSkill ["reloadSpeed", _skillSet select 6];
		_x setSkill ["spotDistance", _skillSet select 7];
		_x setSkill ["spotTime", _skillSet select 8]; 

		// Hämta EOS variabler för skadehantering och dödsräkning från missionNamespace
		EOS_DAMAGE_MULTIPLIER = missionNamespace getVariable ["EOS_DAMAGE_MULTIPLIER", []];
		EOS_KILLCOUNTER = missionNamespace getVariable ["EOS_KILLCOUNTER", []];
			
		// Om EOS_DAMAGE_MULTIPLIER är annorlunda än 1, justera skadehanteringen
		if (EOS_DAMAGE_MULTIPLIER != 1) then {
			_unit removeAllEventHandlers "HandleDamage";
			_unit addEventHandler ["HandleDamage",
			{ _damage = ( _this select 2 ) * EOS_DAMAGE_MULTIPLIER;
			_damage }
			];
		};

		// Om EOS_KILLCOUNTER är aktiverat, lägg till event handler för dödsräkning
		if (EOS_KILLCOUNTER) then {
			_unit addEventHandler ["killed", 
			"null=[] execVM eos_fnc_killCounter_path"
			]
		};
	// Här kan ytterligare anpassade skript läggas till för varje enhet
	} forEach (units _grp);
} else {
	//diag_log "fn_setSkill: _skillSet is undefined.";
	diag_log format ["fn_setSkill: _skillSet is undefined or incomplete - %1", _skillSet];
};