class Aeolus extends AIInfo {
	function GetAuthor()      { return "Tinus Bruins"; }
	function GetName()        { return "Aeolus"; }
	function GetDescription() { return "A.I. with an personality and tries to improve its existing infrastructure"; }
	function GetVersion()     { return 1; }
	function GetDate()        { return "1836-07-14"; }
	function CreateInstance() { return "Aeolus"; }
	function GetShortName()   { return "AEOL"; }
	function GetAPIVersion()  { return "1.5"; }

	function GetSettings(){
		AddSetting({
			name = "use_air",
			description = "Enable air",
			easy_value = 1,
			medium_value = 1,
			hard_value = 1,
			custom_value = 1,
			flags = AICONFIG_BOOLEAN
		});
		AddSetting({
			name = "use_rail",
			description = "Enable rail",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = AICONFIG_BOOLEAN
		});
		AddSetting({
			name = "use_road",
			description = "Enable road",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = AICONFIG_BOOLEAN
		});
		AddSetting({
			name = "use_road",
			description = "Enable water",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = AICONFIG_BOOLEAN
		});
		AddSetting({
			name = "debug",
			description = "I like candy",
			easy_value = 1,
			medium_value = 1,
			hard_value = 1,
			custom_value = 0,
			flags = AICONFIG_BOOLEAN | AICONFIG_INGAME
		});
 	}
}
/* Tell the core we are an AI */
RegisterAI(Aeolus());
