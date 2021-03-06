/**
 * ExileExpansionClient_object_player_scavenge_AddAction
 *
 * Exile Expansion Mod
 * www.reality-gaming.eu
 * © 2017 Exile Expansion Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
private _holdActionID =  0;
private _holdActionIDs = [];

{
	private _textInfo = getText (_x >> "text");
	private _actioniconInfo = getText (_x >> "icon");
	private _idleiconInfo = getText (_x >> "icon");
	private _modelInfo = getArray (_x >> "models");
	private _itemInfo = getArray (_x >> "items");
	private _objectsList = missionNamespace getVariable ["ExileClientSavengedObjects", []];
	private _condition = format ["(((getModelInfo cursorObject) select 0) in %1 && {player distance cursorObject < 5} && !(cursorObject in (missionNamespace getVariable ['ExileClientSavengedObjects', []])) && (player getVariable ['CanScavenge', true]) && (vehicle player == player))", _modelInfo];
	private _configClassName = configName _x;

	_holdActionID =
	[
		player, _textInfo,	_actioniconInfo, _idleiconInfo,	_condition,	"_caller distance _target < 5",	{},
		{
			private _progressTick = _this select 4;
			if (_progressTick % 2 == 0) exitwith {};
			playsound3d [((getarray (configfile >> "CfgSounds" >> "Orange_Action_Wheel" >> "sound")) param [0,""]) + ".wss",player,false,getposasl player,1,0.9 + 0.2 * _progressTick / 24];
		},
		{
			_configClassName = (_this select 3) select 0;
			[_configClassName] call ExileExpansionClient_system_scavenge_action_conditionEvents;
		},
		{},
		[_configClassName], 0.5, 0, false
	] call ExileExpansionClient_gui_holdActionAdd;

	_holdActionIDs pushBack _holdActionID;
} forEach ("true" configClasses (missionConfigFile >> "CfgExileScavenge"));

player setVariable ["ExileScavangeActionIDs", _holdActionIDs];
