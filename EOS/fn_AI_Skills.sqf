/*
Author: Emek1501 [ASE]

Description:
Hanterar AI-färdigheter baserat på den angivna svårighetsgraden. Justerar enheternas färdigheter såsom aimingAccuracy, commanding, courage etc.

Variables:
- difficultyLevel: Svårighetsgrad (1 = lätt, 2 = medium, 3 = svår, etc.)

Remarks:
Skriptet justerar AI-färdigheter baserat på svårighetsgraden som anges i missionNamespace.

Parameter(s):
- _skillType: Typ av enhetsfärdigheter som ska tillämpas (t.ex. "INFskill" för infanteri).
- _difficulty: Svårighetsgrad för färdigheterna.

Important Notes:
- För att detta skript ska fungera korrekt måste svårighetsgraden vara inställd i missionNamespace.
- Färdighetsinställningar måste vara korrekt definierade i missionNamespace för varje _skillType.

Potential Errors:
- Om svårighetsgraden inte är korrekt inställd kan standardvärden användas vilket kan leda till oväntade AI-beteenden.

Returns:
- Inga specifika returer, färdigheter appliceras direkt på enheterna.
*/


/*
   Hantera AI-skills baserat på svårighetsgrad
   Parameter: 0 = lätt, 1 = medium, 2 = svår
   aimingAccuracy[] = {0,0,1,1};
   aimingShake[] = {0,0,1,1};
   aimingSpeed[] = {0,0.5,1,1};
   commanding[] = {0,0,1,1};
   courage[] = {0,0,1,1};
   general[] = {0,0,1,1};
   reloadSpeed[] = {0,0,1,1};
   spotDistance[] = {0,0,1,1};
   spotTime[] = {0,0,1,1};
*/
// Initierar tidsstämpel och loggar start av skriptet.
private _timeStamp = diag_tickTime;
diag_log format ["[fn_AI_Skills.sqf] starts at %1", _timestamp];

// Hämta svårighetsgraden från missionNamespace
private _difficulty = missionNamespace getVariable ["difficultyLevel", 1];
diag_log format ["fn_AI_Skills: Difficulty Level - %1", _difficulty];

// Definiera färdigheter baserat på svårighetsgrad
private [
	"_InfskillSet",
	"_ArmSkillSet",
	"_LigSkillSet",
	"_AIRskillSet",
	"_STAskillSet"
];

// Sätt färdighetsnivåer baserat på svårighetsgrad
switch (_difficulty) do {
	case 0: { 
		diag_log "fn_AI_Skills: Setting skills to NOVICE level.";
		//////////////////////////////////////////////////////////NOVICE//////////////////////////////////////////////////////////
		// INFANTRY SKILL
		_InfskillSet = [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];
		// ARMOUR SKILL
		_ArmSkillSet = [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];
		// LIGHT VEHICLE skill
		_LigSkillSet = [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];
		// HELICOPTER SKILL
		_AIRskillSet = [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];
		// STATIC SKILL
		_STAskillSet = [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];
	 };
	case 1: { 
		diag_log "fn_AI_Skills: Setting skills to ROOKIE level.";
		//////////////////////////////////////////////////////////ROOKIE//////////////////////////////////////////////////////////
		// INFANTRY SKILL
		_InfskillSet = [0.35,0.45,0.3,0.4,0.45,0.4,0.43,0.39,0.35];
		// ARMOUR SKILL
		_ArmSkillSet = [0.35,0.45,0.3,0.4,0.45,0.4,0.43,0.39,0.35];
		// LIGHT VEHICLE skill
		_LigSkillSet = [0.35,0.45,0.3,0.4,0.45,0.4,0.43,0.39,0.35];
		// HELICOPTER SKILL
		_AIRskillSet = [0.35,0.45,0.3,0.4,0.45,0.4,0.43,0.39,0.35];
		// STATIC SKILL
		_STAskillSet = [0.35,0.45,0.3,0.4,0.45,0.4,0.43,0.39,0.35];
	 };
	case 2: { 
		diag_log "fn_AI_Skills: Setting skills to RECRUIT level.";
		//////////////////////////////////////////////////////////RECRUIT//////////////////////////////////////////////////////////
		// INFANTRY SKILL
		_InfskillSet = [0.5,0.65,0.6,0.5,0.5,0.5,0.5,0.6,0.6];
		// ARMOUR SKILL
		_ArmSkillSet = [0.5,0.65,0.6,0.5,0.5,0.5,0.5,0.6,0.6];
		// LIGHT VEHICLE skill
		_LigSkillSet = [0.5,0.65,0.6,0.5,0.5,0.5,0.5,0.6,0.6];
		// HELICOPTER SKILL
		_AIRskillSet = [0.5,0.65,0.6,0.5,0.5,0.5,0.5,0.6,0.6];
		// STATIC SKILL
		_STAskillSet = [0.5,0.65,0.6,0.5,0.5,0.5,0.5,0.6,0.6];
	};

	case 3: { 
		diag_log "fn_AI_Skills: Setting skills to VETERAN level.";
		//////////////////////////////////////////////////////////VETERAN//////////////////////////////////////////////////////////
		// INFANTRY SKILL
		_InfskillSet = [0.8,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85];
		// ARMOUR SKILL
		_ArmSkillSet = [0.8,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85];
		// LIGHT VEHICLE skill
		_LigSkillSet = [0.8,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85];
		// HELICOPTER SKILL
		_AIRskillSet = [0.8,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85];
		// STATIC SKILL
		_STAskillSet = [0.8,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85];
	};

	case 4: { 
		diag_log "fn_AI_Skills: Setting skills to EXPERT level.";
		//////////////////////////////////////////////////////////EXPERT//////////////////////////////////////////////////////////
		// INFANTRY SKILL
		_InfskillSet = [0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9];
		// ARMOUR SKILL
		_ArmSkillSet = [0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9];
		// LIGHT VEHICLE skill
		_LigSkillSet = [0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9];
		// HELICOPTER SKILL
		_AIRskillSet = [0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9];
		// STATIC SKILL
		_STAskillSet = [0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9];
	};

	case 5: { 
		diag_log "fn_AI_Skills: Setting skills to SUPER AI level.";
		//////////////////////////////////////////////////////////SUPER AI//////////////////////////////////////////////////////////
		// INFANTRY SKILL
		_InfskillSet = [1,1,1,1,1,1,1,1,1];
		// ARMOUR SKILL
		_ArmSkillSet = [1,1,1,1,1,1,1,1,1];
		// LIGHT VEHICLE skill
		_LigSkillSet = [1,1,1,1,1,1,1,1,1];
		// HELICOPTER SKILL
		_AIRskillSet = [1,1,1,1,1,1,1,1,1];
		// STATIC SKILL
		_STAskillSet = [1,1,1,1,1,1,1,1,1];
	};
};

////////////////////////////////////////////////////////////////////////////////////////
// Logga de aktuella skillSets
diag_log format ["fn_AI_Skills: Setting Infantry skills to %1", _InfskillSet];
diag_log format ["fn_AI_Skills: Setting Armour skills to %1", _ArmSkillSet];
diag_log format ["fn_AI_Skills: Setting Light Vehicle skills to %1", _LigSkillSet];
diag_log format ["fn_AI_Skills: Setting Helicopter skills to %1", _AIRskillSet];
diag_log format ["fn_AI_Skills: Setting Static Weapon skills to %1", _STAskillSet];

// Sätt färdigheterna i missionNamespace
missionnamespace setvariable ["INFskill",_InfskillSet];
missionnamespace setvariable ["ARMskill",_ArmSkillSet];
missionnamespace setvariable ["LIGskill",_LigSkillSet];
missionnamespace setvariable ["AIRskill",_AIRskillSet];
missionnamespace setvariable ["STAskill",_STAskillSet];
diag_log format ["fn_AI_Skills: Skill sets updated in missionNamespace for difficulty %1", _difficulty];
