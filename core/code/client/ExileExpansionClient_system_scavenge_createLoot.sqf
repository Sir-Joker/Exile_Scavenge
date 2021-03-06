/**
 * ExileExpansionClient_system_scavenge_createLoot
 *
 * Exile Expansion Mod
 * www.reality-gaming.eu
 * © 2017 Exile Expansion Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
params [["_configName", "", [""]]];

private _lootHolder = objNull;
private _configReference = missionConfigFile >> "CfgExileScavenge";
private _loot = getArray (_configReference >>_configName >> "items");
private _chance = getNumber (_configReference >> _configName >> "chance");
private _searchtime = getNumber (_configReference >> _configName >> "searchtime");
private _timeToSearch = 0;
private _maxloot = getNumber (_configReference >> _configName >> "maxitems");
private _animationsList = getArray (_configReference >> _configName >> "animations");
private _animationToPlay = _animationsList call BIS_fnc_selectRandom;
private _player = player;
private _playerScavengeEvent = true;
private _currentObject = cursorObject;
private _objectsList = missionNamespace getVariable ["ExileClientSavengedObjects", []];

_player setVariable ["CanScavenge", false];

( ["ExileScavengeUI"] call BIS_fnc_rscLayer ) cutRsc [ "ExileScavengeUI", "PLAIN", 1, false ];

if (_animationToPlay != "") then {
	_startAnimTime = time;
	_player playMove _animationToPlay;
	waitUntil {animationState _player != _animationToPlay};
} else {
	_player playAction "Crouch";
};

if ( typeName _searchtime  == "SCALAR" ) then {
	_timeToSearch = _searchtime;
};

private _searchradius = 1.5;
private _searchPos = getPosATL _player;

private _playerInSearchArea = [_player, _searchPos, _searchradius] spawn {
	params["_player", "_searchPos", "_searchradius", "_playerScavengeEvent"];
	waitUntil {
		_player distanceSqr _searchPos >  ( _searchradius^2 )
	}
};

for "_sleep" from _timeToSearch to 0 step -0.01 do
{
	private _progress = linearConversion [0, _timeToSearch, _sleep, 0, 1];
	(uiNamespace getVariable "ExileScavengeUI" displayCtrl 2000);
	(uiNamespace getVariable "ExileScavengeUI" displayCtrl 2001) ctrlSetTextColor [1, 0.706, 0.094, _sleep % 1];
	(uiNamespace getVariable "ExileScavengeUI" displayCtrl 2002) progressSetPosition _progress;
	sleep 0.01;
	if ( scriptDone _playerInSearchArea ) exitWith {
		_playerScavengeEvent = true;
	};
};

(["ExileScavengeUI"] call BIS_fnc_rscLayer) cutRsc ["Default", "PLAIN", 1, false];
if ( scriptDone _playerInSearchArea ) then {
	["ErrorTitleOnly", ["Scavange interrupted!"]] call ExileClient_gui_toaster_addTemplateToast;
	_playerScavengeEvent = false;
	_player setVariable ["CanScavenge", true];
};
terminate _playerInSearchArea;

if ( _playerScavengeEvent ) then {
	if ((random 100) < _chance) then {
		_objectsList pushBack _currentObject;
		missionNamespace setVariable ["ExileClientSavengedObjects", _objectsList];
		[_objectsList, player] remoteExecCall ["ExileExpansionServer_object_player_setScavengedObjects", 2];
		private _posPlayer = getPosATL _player;
		private _lootHolder = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
		_lootHolder setPosATL _posPlayer;
		["SuccessTitleOnly", ["You've found something!"]] call ExileClient_gui_toaster_addTemplateToast;
		for "_i" from 0 to floor(random _maxloot) do	{
			_lootHolder addItemCargoGlobal [(selectRandom _loot), 1];
		};
		_player setVariable ["CanScavenge", true];
		_player action ["GEAR",_lootHolder];
	} else {
		_objectsList pushBack _currentObject;
		missionNamespace setVariable ["ExileClientSavengedObjects", _objectsList];
		[_objectsList, player] remoteExecCall ["ExileExpansionServer_object_player_setScavengedObjects", 2];
		["ErrorTitleOnly", ["Could not find anything."]] call ExileClient_gui_toaster_addTemplateToast;
		_player setVariable ["CanScavenge", true];
	};
};

if !(isNull _lootHolder) then {
	waitUntil
	{
		uiSleep 1;
		player distance2D _lootHolder > 150
	};
	deleteVehicle _lootHolder;
};
