/**
	Civilian Presence Module, spawna det man vill.
	Om du vill spawna trovärdiga civs så behöver man ibland styra vad modulen väljer.
	
	Lägg in koden i modulens init.
	
	@author Beck [ASE] - Discord Beck#1679
*/
_classes = ["CFP_C_AFRISLAMIC_Civ_1_01", "CFP_C_AFRISLAMIC_Civ_2_01", "CFP_C_AFRISLAMIC_Civ_3_01", "CFP_C_AFRISLAMIC_Civ_4_01", "CFP_C_AFRISLAMIC_Civ_5_01", "CFP_C_AFRISLAMIC_Civ_6_01", "CFP_C_AFRISLAMIC_Civ_7_01", "CFP_C_AFRISLAMIC_Civ_8_01", "CFP_C_AFRISLAMIC_Civ_9_01", "CFP_C_AFRISLAMIC_Civ_10_01", "CFP_C_AFRISLAMIC_Civ_11_01","CFP_C_AFRISLAMIC_Civ_12_01", "CFP_C_AFRCHRISTIAN_Civ_1_01", "CFP_C_AFRCHRISTIAN_Civ_2_01", "CFP_C_AFRCHRISTIAN_Civ_3_01", "CFP_C_AFRCHRISTIAN_Civ_4_01", "CFP_C_AFRCHRISTIAN_Civ_5_01", "CFP_C_AFRCHRISTIAN_Civ_6_01", "CFP_C_AFRCHRISTIAN_Civ_7_01", "CFP_C_AFRCHRISTIAN_Civ_8_01", "CFP_C_AFRCHRISTIAN_Civ_9_01", "CFP_C_AFRCHRISTIAN_Civ_10_01", "CFP_C_AFRCHRISTIAN_Civ_11_01", "CFP_C_AFRCHRISTIAN_Civ_12_01", "CFP_C_AFRCHRISTIAN_Civ_13_01", "CFP_C_AFRCHRISTIAN_Civ_14_01"];  
 _faces = ["AfricanHead_03_sick", "AfricanHead_01",  "AfricanHead_02",  "AfricanHead_03"]; 
_unitClass = selectRandom _classes;  
_this setUnitLoadout _unitClass;  
_uniform = selectRandomWeighted getArray (configfile >> "CfgVehicles" >> _unitClass >> "uniformList");  
_headgear = selectRandomWeighted getArray (configfile >> "CfgVehicles" >> _unitClass >> "headgearList"); 
_facewear = getArray (configfile >> "CfgVehicles" >> _unitClass >> "facewearList");  
_fw = "";
if(count _facewear > 0) then {
   _fw = selectRandomWeighted _facewear;
};

_face = selectRandom _faces; 
_this forceAddUniform _uniform;  
_this addHeadgear _headgear;  
_this linkItem _fw;

if (isServer) then {[_this, _face] remoteExec ["setFace", 0, _this]};