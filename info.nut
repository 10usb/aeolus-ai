class Aeolus extends AIInfo {
  function GetAuthor()      { return "Tinus Bruins"; }
  function GetName()        { return "Aeolus"; }
  function GetDescription() { return "An attempt to create an AI that does logical actions"; }
  function GetVersion()     { return 1; }
  function GetDate()        { return "1986-07-14"; }
  function CreateInstance() { return "Aeolus"; }
  function GetShortName()   { return "XXXX"; }
  function GetAPIVersion()  { return "1.5"; }
}
/* Tell the core we are an AI */
RegisterAI(Aeolus());
