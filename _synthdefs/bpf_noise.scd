(
SynthDef(\bpf_noise, {

	var gate = \gate.kr(1);
	var numvoices = 2;
	var ddepth = \ddepth.kr(0.1);
	var drate = \drate.kr(0.1);
	var detune = [1, 1.01];//LFNoise2.ar(drate.dup(numvoices)).bipolar(ddepth).midiratio;
	var freq = Vibrato.ar(\freq.ar(261), \vrate.ar(6), \vdepth.ar(0.0));

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

	var osc1 = {arg freq;
		var sig = WhiteNoise.ar;
		var rq = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var vol_comp = (rq ** -1) * (400 / freq ** 0.5);
		sig = BBandPass.ar(sig, freq, rq);
		sig * vol_comp;
	};

	var filter = {arg sig;
		LPF.ar(sig, 880);
	};

	var aeg = adsr.();

	var sig = [
		osc1.(freq * detune)
	].sum;
	sig = sig * aeg * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = LeakDC.ar(sig);

	sig = filter.(sig);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * \amp.kr(-3.dbamp);
	Out.ar(\out.kr(0), sig);
}).add;
)