(
SynthDef(\subtractr, {

	// TODO:
	// https://github.com/markwheeler/passersby/blob/master/lib/Engine_Passersby.sc
	// https://github.com/markwheeler/molly_the_poly/blob/master/lib/Engine_MollyThePoly.sc
	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	/*
	var fm = {arg freq;
		var index = \index.kr(0);
		var ivel = \ivel.kr(0.1);
		var idur = \idur.kr(0.1);
		var ratio = \ratio.kr(2);
		var iline = Line.ar(index, index * ivel, idur);// * freq * ratio;
		var mod = SinOsc.ar(freq * ratio) * iline * index.reciprocal.sqrt;
		mod;
	};
	*/

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

	var filter = {arg sig;
		var famt = \freqamt.kr(0);
		var ffreq = \cutoff.kr(100) + (freq * famt);
		var fvel = max(\fvel.kr(10), 0.001);
		var fres = \res.kr(0.5);

		var f1, f2;
		var which = \fwhich.kr(0);
		var focus = \ffocus.kr(1);
		var fatk = \fatk.kr(0.01);
		var fdec = \fdec.kr(0.21);
		var fsuslevel = \fsuslevel.kr(0.3);
		var frel = \frel.kr(0.1);
		var atkcurve = \fatkcurve.kr(-4);
		var deccurve = \fdeccurve.kr(-4);
		var relcurve = \frelcurve.kr(-4);
		var ts = \fts.kr(1);
		var feg = Env(
			[0, 1, fsuslevel, 0],
			[fatk, fdec, frel],
			[atkcurve, deccurve, relcurve],
			releaseNode:2
		).ar(gate:gate, timeScale:ts)
		.linlin(0, 1, ffreq, ffreq * fvel);

		feg = feg * \feglfo.kr(1);
		feg = feg.clip(20, 20000);
		f1 = MoogFF.ar(sig, feg, fres.linlin(0, 1, 0.001, 4)) * 4;
		f2 = DFM1.ar(sig, feg, fres.clip(0.001, 1.0));
		sig = SelectXFocus.ar(which, [f1, f2], focus);
		sig;
	};

	var tri = {arg freq;
		var sig = VarSaw.ar(freq, 0, \triwidth.ar(0.5));
		var fold = \trifold.kr(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq);
	};

	var saw = {arg freq;
		var sync = \sawsync.ar(1);
		var sig = SyncSaw.ar(freq, freq * sync);
		sig * AmpCompA.kr(freq);
	};

	var pulse = {arg freq;
		var sig = Pulse.ar(freq, \pulsewidth.ar(0.5));
		sig * AmpCompA.kr(freq);
	};

	var sine = {arg freq;
		//var mod = fm.(freq) * \sinefm.kr(0);
		var sig = SinOscFB.ar(freq, \sineskew.kr(0));
		var fold = \sinefold.kr(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq);
	};

	var noise = {
		var sig = PinkNoise.ar;
		sig;
	};

	var aeg = adsr.();

	var vols = [\tri.kr(1), \saw.kr(0), \pulse.kr(0), \sine.kr(0)].normalizeSum.max(0);

	var sig = [
		tri.(freq * \trifreqmul.kr(1)) * vols[0],
		saw.(freq * \sawfreqmul.kr(1)) * vols[1],
		pulse.(freq * \pulsefreqmul.kr(1)) * vols[2],
		sine.(freq * \sinefreqmul.kr(1)) * vols[3],
		noise.() * \noise.kr(0)
	].sum;

	sig = LeakDC.ar(sig);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));

	sig = filter.(sig);
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

		\cutoff -> ControlSpec(20, 18000, \exp, 0, 100),
		\fvel -> ControlSpec(0.001, 20, \lin, 0, 10),
		\res -> ControlSpec(0, 1, \lin, 0, 0.5),
		\freqamt -> ControlSpec(0, 4, \lin, 0, 0),
		\fatk -> ControlSpec(0, 30, \lin, 0, 0.01),
		\fdec -> ControlSpec(0, 30, \lin, 0, 0.2),
		\frel -> ControlSpec(0, 30, \lin, 0, 0.29),
		\fsuslevel -> ControlSpec(0, 1, \lin, 0, 0.7),
		\fatkcurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\fdeccurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\frelcurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\fts -> ControlSpec(0, 100, \lin, 0, 1),
		\fwhich -> ControlSpec(0, 1, \lin, 0, 0),
		\ffocus -> ControlSpec(0, 1, \lin, 0, 1),
		\feglfo -> ControlSpec(1, 1, \lin, 1, 1),

		\tri -> ControlSpec(0, 1, \lin, 0, 1),
		\trifreqmul -> ControlSpec(0.0001, 12, \lin, 0, 1),
		\triwidth -> ControlSpec(0, 1, \lin, 0, 0.5),
		\trifold -> ControlSpec(1, 10, \lin, 0, 1),

		\saw -> ControlSpec(0, 1, \lin, 0, 0),
		\sawfreqmul -> ControlSpec(0.0001, 12, \lin, 0, 1),
		\sawsync -> ControlSpec(1, 5, \lin, 0, 1),

		\pulse -> ControlSpec(0, 1, \lin, 0, 0),
		\pulsefreqmul -> ControlSpec(0.0001, 12, \lin, 0, 1),
		\pulsewidth -> ControlSpec(0, 1, \lin, 0, 0.5),

		\sine -> ControlSpec(0, 1, \lin, 0, 0),
		\sinefreqmul -> ControlSpec(0.0001, 12, \lin, 0, 1),
		\sineskew -> ControlSpec(-1, 1, \lin, 0, 0),
		\sinefold -> ControlSpec(1, 10, \lin, 0, 1),

		\noise -> ControlSpec(0, 1, \lin, 0, 0),

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

