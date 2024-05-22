/*
 * GarageDefinitions.sqf
 *
 * A garage definition tells the script how to spawn a vehicle in relation to it. The garage definitions
 * array below is an array with garage definitions. A garage definition is in itself an array with the
 * following items (at the following indexes):
 *
 * 0: The class name of the building.
 * 1: The building position index. Use a scalar from 0 and up to set a building position as reference.
 *    Set -1 to use the building itself as reference (like if the building does not have any building
 *    positions.
 * 2: Reference position offset on format [x, y, z]. Relative the building position (or the building),
 *    how much is necessary to tweak the position to get the vehicle exactly correct at position?
 *    Example: Value [0, 1, 0] will put the vehicle on position, but move it one meter deeper into the
 *             building (building seen from "behind").
 * 3: The rotation angle of the vehicle, relative the building.
 *
 * The function PARKEDVEHICLES_InvestigateClosestBuilding can help when creating new garage definitions.
 */

PARKEDVEHICLES_GarageDefinitions = [
	/* Primary Altis, Stratis and Malden */
	["Land_i_Garage_V1_F", 2, [-0.5, -1, 0], 90],
	["Land_MilOffices_V1_F", -1, [-7, 11, 0.1], 270],
	["Land_FuelStation_Shed_F", 0, [0, 0, 0.1], 0],
	["Land_i_Stone_HouseBig_V2_F", -1, [6.5, -1, 0], 180],
	["Land_i_Stone_HouseSmall_V2_F", -1, [0, -7, 0], 90],
	
	/* Primary Tanoa */
	["Land_FuelStation_02_workshop_F", 5, [0.1, 3, 0.6], 180],
	["Land_GarageShelter_01_F", 2, [-0.1, 1.5, 0], 180],
	["Land_i_Shed_Ind_F", 2, [0, 2.5, 0], 270],
	["Land_FuelStation_01_shop_F", -1, [0, -8, 0], 270],
	["Land_Supermarket_01_F", -1, [9, -4, 0], 0],
	["Land_House_Big_03_F", 4, [2, -1, 0], 90],
	
	/* Chernarus */
	["Land_Barn_Metal",-1,[0,-1,0.01],90],
	["Land_Shed_Ind02",-1,[8,-4,0.01],0],
	["Land_A_FuelStation_Shed",-1,[-3,-1.4,0.01],175],
	["Land_Farm_Cowshed_a",-1,[2,-8,0.01],270],
	["Land_Ind_Pec_02",-1,[-0.45,0.41,0.01],180], // Huge
	["Land_HouseV_1I4",-1,[-5.5,-5,0.01],0],
	["Land_HouseV_1L2",-1,[-7,-2,0.01],180]
];
