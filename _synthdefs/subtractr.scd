(
SynthDef(\subtractr, {

	var gate = \gate.kr(1);
	var numvoices = 2;
	var ddepth = \ddepth.kr(0.1);
	var drate = \drate.kr(0.1);
	var detune = [1, 1.01];//LFNoise2.ar(drate.dup(numvoices)).bipolar(ddepth).midiratio;
	var freq = Vibrato.ar(\freq.ar(261), \vrate.ar(6), \vdepth.ar(0.0));

	var fm = {arg freq;
		var index = \index.kr(0);
		var ivel = \ivel.kr(0.1);
		var idur = \idur.kr(0.1);
		var ratio = \ratio.kr(2);
		var iline = Line.ar(index, index * ivel, idur) * freq * ratio;
		var mod = SinOsc.ar(freq * ratio) * iline;
		mod;
	};

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

	var filter = {arg sig, aeg, cutoff=1200, vel=1, res=0, freqamt=0, curve=(-4);
		var famt = \freqamt.kr(freqamt);
		var ffreq = \cutoff.kr(cutoff) + (freq * famt);
		var fvel = max(\fvel.kr(vel), 0.001);
		var fcurve = K2A.ar(\fcurve.kr(curve));
		var fres = \res.kr(res);
		var feg = aeg.lincurve(0, 1, ffreq, ffreq * fvel, curve:fcurve).clip(20, 20000);
		//var feg = Env.perc(0.01, \dec.kr, fcurve).kr(gate:trig, timeScale:\ts.kr(1))
		//.linlin(0, 1, ffreq, ffreq * fvel).clip(20, 20000);
		//var feg = Env([ffreq, ffreq, ffreq * fvel], [0, \dec.kr], fcurve).kr(gate:trig).clip(20, 20000);

		sig = MoogFF.ar(sig, feg, fres.linlin(0, 1, 0, 4)) * 4;
		//sig = MoogLadder.ar(sig, feg, fres) * 4;
		//sig = MoogVCF.ar(sig, feg, res);
		//sig = SVF.ar(sig, feg, fres, 1, 1, 0, 1, 0);
		//sig = DFM1.ar(sig, feg, fres.clip(0.001, 1.0)) * 1;
		//sig = RLPF.ar(sig, feg, (1-fres).clip(0.001, 1.0));
		//sig = BLowPass4.ar(sig, feg, (1-fres).clip(0.001, 1.0));
		//sig = BLowPass.ar(sig, feg, (1-fres).clip(0.001, 1.0));
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
		//var sig = Saw.ar(freq);
		var timbre = \sawtimbre.ar(0);
		var sawcurve = \sawcurve.ar(0);
		var sig = SyncSaw.ar(freq, freq + timbre).lincurve(-1, 1, -1, 1, sawcurve);
		sig * AmpCompA.kr(freq);
	};

	var square = {arg freq;
		var sig = Pulse.ar(freq, \squarewidth.ar(0.5));
		sig * AmpCompA.kr(freq);
	};

	var sine = {arg freq;
		var mod = fm.(freq) * \sinefm.kr(0);
		var sig = SinOsc.ar(freq + mod);
		var fold = \sinefold.kr(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq);
	};

	var noise = {
		var sig = WhiteNoise.ar;
		sig;
	};

	var aeg = adsr.();

	var sig = [
		tri.(freq * detune * \trifreqmul.kr(1)) * \tri.kr(1),
		saw.(freq * detune * \sawfreqmul.kr(1)) * \saw.kr(0),
		square.(freq * detune * \squarefreqmul.kr(1)) * \square.kr(0),
		sine.(freq * detune * \sinefreqmul.kr(1)) * \sine.kr(0),
		noise.() * \noise.kr(0)
	].sum;
	sig = sig * aeg * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = LeakDC.ar(sig);

	sig = filter.(sig, aeg);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * \amp.kr(-3.dbamp);
	Out.ar(\out.kr(0), sig);

}, metadata:(
	specs:[
		\atk -> ControlSpec(0, 30, \lin, 0, 0.01),
		\dec -> ControlSpec(0, 30, \lin, 0, 0.2),
		\rel -> ControlSpec(0, 30, \lin, 0, 0.29),
		\suslevel -> ControlSpec(0, 1, \lin, 0, 0.7),
		\curve -> ControlSpec(-24, 24, \lin, 0, -4),
		\ts -> ControlSpec(0, 100, \lin, 0, 1),

		\cutoff -> ControlSpec(1, 18000, 'exp', 0, 100),
		\fvel -> ControlSpec(0, 20, \lin, 0, 10),
		\fcurve -> ControlSpec(-24, 24, \lin, 0, -4),
		\res -> ControlSpec(0, 1, \lin, 0, 0.5),
		\freqamt -> ControlSpec(0, 4, \lin, 0, 0),

		\tri -> ControlSpec(0, 1, \lin, 0, 1),
		\trifreqmul -> ControlSpec(0, 12, \lin, 0, 1),
		\triwidth -> ControlSpec(0, 1, \lin, 0, 0.5),
		\trifold -> ControlSpec(1, 10, \lin, 0, 1),

		\saw -> ControlSpec(0, 1, \lin, 0, 0),
		\sawfreqmul -> ControlSpec(0, 12, \lin, 0, 1),
		\sawtimbre -> ControlSpec(0, 1, \lin, 0, 0.1),
		\sawcurve -> ControlSpec(-4, 4, \lin, 0, 0),

		\square -> ControlSpec(0, 1, \lin, 0, 0),
		\squarefreqmul -> ControlSpec(0, 12, \lin, 0, 1),
		\squarewidth -> ControlSpec(0, 1, \lin, 0, 0.5),

		\sine -> ControlSpec(0, 1, \lin, 0, 0),
		\sinefreqmul -> ControlSpec(0, 12, \lin, 0, 1),
		\sinefm -> ControlSpec(0, 1, \lin, 0, 0),
		\sinefold -> ControlSpec(1, 10, \lin, 0, 1),

		\index -> ControlSpec(0, 100, \lin, 0.0, 1),
		\ivel -> ControlSpec(0, 100, \lin, 0, 1),
		\idur -> ControlSpec(0, 1, \lin, 0, 1),
		\ratio -> ControlSpec(0, 100, \lin, 0, 1),

		\noise -> ControlSpec(0, 1, \lin, 0, 0),

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
)
).add
)
