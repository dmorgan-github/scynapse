(
SynthDef(\pluck, {

	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var adsr = {
		var da = Done.none;
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0.1);
		var rel = \rel.kr(0.1);
		var suslevel = \suslevel.kr(0.5);
		var ts = \ts.kr(1);
		var atkcurve = \atkcurve.kr(-4);
		var deccurve = \deccurve.kr(-4);
		var relcurve = \relcurve.kr(-4);
		var env = Env.adsr(
			attackTime:atk, decayTime:dec, sustainLevel:suslevel, releaseTime:rel,
			curve:[atkcurve, deccurve, relcurve]
		);
		var aeg = env.kr(doneAction:da, gate:gate, timeScale:ts);
		aeg = aeg * \aeglfo.kr(1);
		// control life cycle of synth
		env.kr(doneAction:Done.freeSelf, gate:\gate.kr, timeScale:ts);

		aeg;
	};

	var pluck = {arg freq;
		var noise = WhiteNoise.ar;
		var decay = \decay.kr(1.0);
		var coef = \coef.kr(0.5);
		var sig = Pluck.ar(noise, gate, 0.03, freq.reciprocal, decay, coef);
		sig * AmpCompA.kr(freq);
	};

	var aeg = adsr.();

	var sig = [
		pluck.(freq)
	].sum;

	sig = LeakDC.ar(sig);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * aeg * \vel.kr(1);
	sig = sig * \amp.kr(-3.dbamp);
	Out.ar(\out.kr(0), sig.softclip);

}, metadata:(
	specs:[
		\atk -> ControlSpec(0, 30, \lin, 0, 0.01),
		\dec -> ControlSpec(0, 30, \lin, 0, 0.2),
		\rel -> ControlSpec(0, 30, \lin, 0, 0.29),
		\suslevel -> ControlSpec(0, 1, \lin, 0, 0.7),
		\atkcurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\deccurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\relcurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\ts -> ControlSpec(0, 100, \lin, 0, 1),
		\aeglfo -> ControlSpec(1, 1, \lin, 1, 1),

		\decay -> ControlSpec(-12, 12, \lin, 0, 1),
		\coef -> ControlSpec(-1, 1, \lin, 0, 0.5),

		\detunehz -> ControlSpec(0, 100, \lin, 0, 0),
		\bend -> ControlSpec(-12, 12, \lin, 0, 0), // semitones
		\vrate -> ControlSpec(0, 440, \lin, 0, 6),
		\vdepth -> ControlSpec(0, 1, \lin, 0, 0),
		\vel -> ControlSpec(0, 1, \lin, 0, 1),
		\spread -> ControlSpec(0, 1, \lin, 0, 1),
		\center -> ControlSpec(0, 1, \lin, 0, 0),
		\pan -> ControlSpec(-1, 1, \lin, 0, 0),
		\amp -> ControlSpec(0, 1, \lin, 0, 0.1)
	]
)
).add
)