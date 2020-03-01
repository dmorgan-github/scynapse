/////////////////////////////////////////
// bd
(
~bd = S(\bd, {arg freq, gate;

	var osc1 = {arg freq;
		var peak = \fpeak.kr(8) * [1.1, 1.3] * Rand(0.99, 1.01);
		var freqmul = Env.perc(0.001, 0.02).ar(gate:1).linlin(0, 1, 1, peak);
		var wn = LPF.ar(WhiteNoise.ar, 280) * XLine.ar(1, 0.01, 0.01) * \noise.kr(0.2);
		var sub = FSinOsc.ar(freq, 0.5) * \sub.kr(0.35);
		var sig = FSinOsc.ar(freq * freqmul, 0.5) + wn + sub;
		sig = [
			LPF.ar(sig, 440),
			(HPF.ar(sig, 440) * 4).tanh
		];
		sig = sig * Env.perc(0.001, \rel2.kr(1)).ar(gate:1);
		sig = BLowShelf.ar(sig, 18, 1, -30);
		sig = BPeakEQ.ar(sig, 40, 1, 2);
		sig = BPeakEQ.ar(sig, 80, 1, 8);
		sig = BPeakEQ.ar(sig, 880, 1, 20);
		sig = BHiShelf.ar(sig, 2000, 1, -20);
		Splay.ar(sig.sum);
	};
	var mix = osc1.('E0'.namecps);
	mix;
})
)

~bd_func = {arg a, b, c; [a, b, c].postln;};
~bd.addDependant(~bd_func);
~bd.dur = [1, 1, 0.5, 1.5].pseq;
~bd.play;
~bd.stop;
~bd.vel = 1;
~bd.amp = 0.5;
~bd.gui({arg k, v; ~bd.set(k, v) });



/////////////////////////////////////////
// record
App.saveWorkspace("presets", rec:true);
s.stopRecording;