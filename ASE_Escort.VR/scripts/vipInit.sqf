//SET HOLDACTION ON VIP
	
	[	vip, 									//target
		"escort VIP", 							//title
		"images\holdAction_follow_start_ca.paa",//idleIcon
		"images\holdAction_follow_start_ca.paa",//progressIcon
		"alive vip && player distance player < 5",//conditionShow (params: target,this)
		"true", 								//conditionProgress - (_target, _caller, _actionId, _arguments)
		{}, 									//codeStart - params ["_target", "_caller", "_actionId", "_arguments"]; code executed when action starts
		{}, 									//codeProgress - run code on every tick
		{										//codeCompleted - run code on completion of hold. Spec arguments passed to the code _target, _caller, _actionId, _arguments
			[_target, player, 10, ""] execVM "scripts\fn_escort.sqf"; //"_target", "_caller", "_actionId", "_arguments"
			//{ [_target, true,{},true] execVM "scripts\fn_escort.sqf";} remoteExec ["call",0,true];
			{ cutText ["VIP: Lead the way.", "PLAIN"]; } remoteExec ["call", call BIS_fnc_listPlayers select { _x distance vip < 20 }];
		},	
		{}, 											//codeInterrupted - code executed on interrupted
		[], 											//arguments - arguments passed to codeStart, codeProgress, codeCompleted and codeInterrupted TODO TEST Removed toggle
		1, 												//duration of hold in seconds
		0 												//priority - actions are arranged in descending order according to this value
	] remoteExec ["BIS_fnc_holdActionAdd", 0, true];//adds the action to every client and JIP