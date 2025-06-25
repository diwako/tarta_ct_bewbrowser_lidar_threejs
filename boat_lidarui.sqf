/*
	i runthis code in the debug console

*/

("MyHudLayer" call BIS_fnc_rscLayer) cutRsc ["boat_lidarui", "PLAIN"]; // Add our Display to the HUD
[pfhandler] call CBA_fnc_removePerFrameHandler;



//if (isNil "startpos") then {
startpos = getPosWorldVisual player;


fn_tarta_lidarCast = {
	params["_castObj","_castDir", "_castPos" ,["_amplitude", 45], ["_depth", 100] ]; 
	_elementz= [];	
	
	for "_i" from 0 to 100 do{
		
		_amp = tan (_amplitude);
		_raw = (_castDir vectoradd [ random [-_amp,0, _amp], random 0.1, -1 ] ) vectorMultiply _depth; 
		_pos = (_castObj modelToWorldVisual _raw );
		//_raw = _castPos vectoradd (_castDir vectorMultiply _depth);
		//_pos = _raw vectoradd ([ random [-_amp,0, _amp], random 0.1, -1 ] vectorMultiply _depth);
		_elementz pushBack [_castPos, _pos , _castObj];
	}; 
	_newdots = [];
	_intersecs = lineIntersectsSurfaces [_elementz];	
	{
		_intersec = _x;
		if (_intersec isEqualTo []) then {continue};
		_intersec = _intersec select 0 select 0;
		drawIcon3D ["\A3\ui_f\data\map\markers\handdrawn\dot_CA.paa", [0,1,0,1],_intersec,0.3,0.3,45, "", 0, 0.005 , "TahomaB"];
		_newdots pushBack _intersec; //(_intersec vectorDiff startpos);  
	}foreach _intersecs;
	
	

	_newdots apply {_x vectorDiff startpos};
	
	
};


//[[0,0,-1], getPosWorld player vectorAdd [0,0,-2] ] call fn_tarta_lidarCast 

fnc_draw = {
	private _origin = startpos;
	private _castObj = vehicle player;
   
	private _pos = getPosatl player; 
	private _relPos = _pos vectorDiff _origin;
	
	private _camPos = _castObj modelToWorldVisual [0, -25, 10];
	private _relCamPos = _camPos vectorDiff _origin;
	
	private _CastDir = [0,0,-1];	

	private _dots = [_castObj, _CastDir, _pos, 60 ] call fn_tarta_lidarCast; 
	/*if (speed vehicle player> 0) then { //only if moving 
		private _dots = [_castObj, _CastDir, _pos ] call fn_tarta_lidarCast; 
	};*/ 
			
	private _ctrl  = (boat_lidarui#0) displayCtrl 1337;
	// Enviar a JS
	private _js = format [
		"updateLidar(%1,%2,%3);",
		str _relPos,
		str [0,0,-50],//str _relCamPos,
		str _dots
	];
	_ctrl ctrlWebBrowserAction [ "execJS", _js];
	systemchat str _relPos; 
	systemchat str _relCamPos;
	systemchat str "";
};

pfhandler = [{call fnc_draw}, 0.03, ["some","params",1,2,3]] call CBA_fnc_addPerFrameHandler; //30 fps for a more consistent cloud of points 

_ctrl  = (boat_lidarui#0) displayCtrl 1337;
_ctrl ctrlWebBrowserAction ["OpenDevConsole"];