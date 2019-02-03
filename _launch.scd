//~p.push;
(
// have to add an ndef to initialize Ndef.all[\localhost]...why?
var bobo = Ndef(\foo);
var envir = Ndef.all[\localhost].envir;
//var func = File.open(PathName(Document.current.path).parentPath ++ "_main.scd", "r").readAllString.interpret;
//func.(envir);
Fdef(\scynapse).(envir);
)
