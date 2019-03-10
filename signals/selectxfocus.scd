(
view: {arg objName, envir, components;


	var modfunc = {arg freq, trig, dur = 1;

		var	modratio = \modratio.kr(2);
		var modenvhi = \modenvhi.kr(3);
		var modenvlo = \modenvlo.kr(0.01);
		var modenvdur = \modenvdur.kr(1);
		var modenvcurve = \modenvcurve.kr(4);

		var modindex = freq
		* modratio
		* Env([modenvhi, modenvhi, modenvlo], [0, dur * modenvdur], modenvcurve).kr(gate:trig);

		var mod = SinOsc.ar(freq * modratio) * modindex;
		mod * \fm.kr(0);
	};

	var nodefunc = {

		var trig = \trig.tr;
		var freq = Vibrato.kr(
			\freq.kr(432).lag(\lag.kr(0.1)),
			\vrate.kr(6),
			\vdepth.kr(0.001)
		);

		var susLevel = \susLevel.kr(0.7);
		var curve = \curve.kr(-4);
		var env = Env(
			[0,1,susLevel,susLevel,0],
			[\atk.kr(0.01), \dec.kr(0.3), \sus.kr(1), \rel.kr(1)],
			curve:curve
		).kr(gate:trig, timeScale:\ts.kr(1));

		var mod = modfunc.(freq, trig, \atk.kr + \dec.kr + \sus.kr + \rel.kr);

		var vcos = [
			{
				var freqmult = \vco1_freqmult.kr(1);
				SinOsc.ar(freq * freqmult + mod);
			},
			{
				var freqmult = \vco2_freqmult.kr(1);
				var width = \vco2_width.kr(0.2);
				var sig = VarSaw.ar(freq * freqmult, width: width);
				sig;
			},
			{
				var freqmult = \vco3_freqmult.kr(1);
				var sync = \vco3_sync.kr(1.5);
				var sig = SyncSaw.ar(freq * freqmult, freq * freqmult * sync);
				sig;
			},
			{
				var sig = PinkNoise.ar;
				sig;
			}
		].collect(_.());

		var which = \which.kr(1);
		var focus = \focus.kr(1);
		var sig = SelectXFocus.ar(which, vcos, focus, true);

		var depth = \filtdepth.kr(1);
		var ffreqmult = \filtmult.kr(2);
		var ffreqmax = (freq * ffreqmult * depth);
		var ffreqmin = (freq * ffreqmult * depth.reciprocal);
		var res = \res.kr(0.5);

		sig = MoogFF.ar(sig, env.exprange(ffreqmin, ffreqmax).clip(20, 20000), res.linlin(0,1,0,4));

		sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	};

	var node = NodeProxy.audio(s, 2).source_(nodefunc);

	var specs = [
		\trig -> \set,
		\freq -> \set,
		\ddepth -> [(1/128), 20, \lin, 0, 5],
		\detune -> [0, 1, \lin, 0, 0.01],
		\atk -> [0, 1, \lin, 0, 0.01],
		\dec -> [0, 1, \lin, 0, 0.3],
		\sus -> [0, 1, \lin, 0, 1],
		\susLevel -> [0,1,\lin,0,0.7],
		\rel -> [0, 1, \lin, 0, 1],
		\curve -> [-24, 24, \lin, 0, -4],
		\ts -> [0, 64, \lin, 0, 1],
		\lag -> [0, 1, \lin, 0, 0],
		\amp -> [0, 1, \lin, 0, 0.1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0],
		\which -> [0, 3, \lin, 1, 1],
		\focus -> [0, 1, \lin, 0, 0.5],
		\vco1_freqmult -> [1, 8, \lin, 0, 1],
		\vco2_freqmult -> [1, 8, \lin, 0, 1],
		\vco3_freqmult -> [1, 8, \lin, 0, 1],
		\vco2_width -> [0, 1, \lin, 0, 0.5],
		\vco3_sync -> [1, 4, \lin, 0, 1],
		\filtdepth -> [0, 8, \lin, 0, 2],
		\filtmult -> [0, 8, \lin, 0, 1],
		\res -> [0, 1, \lin, 0, 0.5],
		\modratio -> [0.1, 8, \lin, 0, 2],
		\modenvhi -> [0.001, 12, \lin, 0, 1],
		\modenvlo -> [0.001, 12, \lin, 0, 1],
		\modenvdur -> [0, 1, \lin, 0, 1],
		\modenvcurve -> [-24, 25, \lin, 0, 0],
		\fm -> [0, 1, \lin, 0, 0]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = components[\playView].(objName, node, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var eqView = components[\eqView].(objName, node, envir, view);

	envir[objName] = node;
	view.layout.add(playView);
	view.layout.add(eqView);
	view.layout.add(specsView);
	view;
}
)
