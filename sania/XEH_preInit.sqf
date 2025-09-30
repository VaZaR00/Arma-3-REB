

// if (isServer) then {
//     DB_Jammer_maxJamDistance = 300; // Default value in case it's not set
//     publicVariable "DB_Jammer_maxJamDistance";
// };

// if (hasInterface) then {
//     [
//         "DB_Jammer_maxJamDistance", 
//         "SLIDER",   
//         ["Work in progress", ""], 
//         "REB Settings", 
//         [100, 3000, 300, 0], // Min, Max, Default, Decimal places
//         1,
//         {
//             DB_Jammer_maxJamDistance = _this;
//             publicVariable "DB_Jammer_maxJamDistance";
//         }
//     ] call cba_settings_fnc_init;
// };
