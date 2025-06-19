params["_reb"];

// Позиция центра эффекта
_pos = getPosATL _reb;

// Менее плотный и более тёмный дым
_smoke = "#particlesource" createVehicleLocal _pos;
_smoke setParticleParams [["\A3\data_f\cl_basic",1,0,1], "", "Billboard", 1, 8, [0,0,0], [0,0.5,0.3], 0.5, 0.7, 0.5, 0, [1,2,3], [[0.05,0.05,0.05,0.5],[0.05,0.05,0.05,0.3],[0.05,0.05,0.05,0]], [1], 1, 0, "", "", _reb];
_smoke setParticleRandom [0.3, [0.1,0.1,0], [0.3,0.3,0.3], 0.3, 0.05, [0,0,0,0.05], 0.1, 0.1];
_smoke setDropInterval 0.1; // реже частицы

// Маленький огонь
_fire = "#particlesource" createVehicleLocal _pos;
_fire setParticleClass "MediumDestructionFire";
_fire setDropInterval 0.05;

sleep 15;

deleteVehicle _reb;