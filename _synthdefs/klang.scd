(
SynthDef(\klang, {
	var gate = \gate.kr(1);
	var in_freq = \freq.ar(261);
	var detune = \detuneratio.kr(1);
	var bend = \bend.ar(1);
	var freqbend = Lag.ar(in_freq * bend, 0.005);
	var freq = Vibrato.ar([freqbend, freqbend * detune], \vrate.ar(6), \vdepth.ar(0.0));

	var adsr = {
		var da = Done.freeSelf;
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0.1);
		var rel = \rel.kr(0.1);
		var curve = \curve.kr(-4);
		var suslevel = \suslevel.kr(0.5);
		var ts = \ts.kr(1);
		var env = Env.adsr(atk, dec, suslevel, rel, curve:curve).ar(doneAction:da, gate:gate, timeScale:ts);
		env;
	};

	var aeg = adsr.();
	var sig = DynKlang.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		],
		freq
	);

	sig = sig * aeg * AmpCompA.ar(freq) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = LeakDC.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * \amp.kr(-10.dbamp);
	Out.ar(\out.kr(0), sig);

}, metadata:(

	specs:[
		\atk -> ControlSpec(0, 30, \lin, 0, 0.01),
		\dec -> ControlSpec(0, 30, \lin, 0, 0.2),
		\rel -> ControlSpec(0, 30, \lin, 0, 0.29),
		\suslevel -> ControlSpec(0, 1, \lin, 0, 0.7),
		\curve -> ControlSpec(-24, 24, \lin, 0, -4),
		\ts -> ControlSpec(0, 100, \lin, 0, 1),
		\bend -> ControlSpec(0.9, 1.1, \lin, 0, 1),
		\vrate -> ControlSpec(0, 440, \lin, 0, 6),
		\vdepth -> ControlSpec(0, 1, \lin, 0, 0),
		\ddepth -> ControlSpec(0, 1, \lin, 0, 0.1),
		\drate -> ControlSpec(0.0, 1.0, \lin, 0, 0.1),
		\pre -> ControlSpec(0, 1, \lin, 0, 1),
		\vel -> ControlSpec(0, 1, \lin, 0, 1),
		\spread -> ControlSpec(0, 1, \lin, 0, 1),
		\center -> ControlSpec(0, 1, \lin, 0, 0),
		\pan -> ControlSpec(-1, 1, \lin, 0, 0),
		\amp -> ControlSpec(0, 1, \lin, 0, 0.1)
	]


)).add;
)