
/*
	i runthis code in the debug console

*/
setAperture 10000; 
setViewDistance 100;
("MyHudLayer" call BIS_fnc_rscLayer) cutRsc ["lidarui", "PLAIN"]; // Add our Display to the HUD
startpos = eyepos player;

[pfhandler] call CBA_fnc_removePerFrameHandler;

fnc_createDots = {

	_elementz= [];	
	for "_" from 0 to 120 do{
		_direction = eyeDirection player;
		_raw = eyepos player vectoradd (_direction vectorMultiply 50);
		_pos = _raw vectoradd ([random [-0.5, 0 , 0.5],random [-0.5, 0 ,0.5],random [-1, 0 ,1]] vectorMultiply 50);
		_elementz pushBack [eyePos player, _pos, player];
	}; 
	_newdots = [];
	
	_intersecs = lineIntersectsSurfaces [_elementz];	
	{
	
		_intersec = _x;
		if (_intersec isEqualTo []) then {continue};
		_intersec = _intersec select 0 select 0;
		_newdots pushBack (_intersec vectorDiff startpos); 
		
		
	}foreach _intersecs;
	_newdots
};

fnc_draw = {
	private _origin = startpos; 
	private _pos = eyepos player; 
	private _dir = getCameraViewDirection player;
	
	private _relPos = _pos vectorDiff _origin;
	private _relLookAt = _lookAt vectorDiff _origin;
	private _dots = call fnc_createDots;
		
	private _ctrl  = (uioverlay#0) displayCtrl 1337;
	// Enviar a JS
	private _js = format [
		"updateLidar(%1,%2,%3);",
		str _relPos,
		str _dir, 
		str _dots 
	];
	_ctrl ctrlWebBrowserAction [ "execJS", _js];   
};



pfhandler = [{call fnc_draw}, 0] call CBA_fnc_addPerFrameHandler; //30 fps for a more consistent cloud of points 

_ctrl  = (uioverlay#0) displayCtrl 1337;
_ctrl ctrlWebBrowserAction ["OpenDevConsole"];