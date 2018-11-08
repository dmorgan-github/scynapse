(
view:{arg objName, envir, util;

	var node = NodeProxy.audio(s, 2).source_({

		var trig = \trig.tr;
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var noise = SelectXFocus.kr(which,
			[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
			focus,
			wrap:true);

		var in = noise * Decay2.kr(trig, \atk.kr(0.01), \decay.kr(1));
		var numFreqs = 6;
		var detune = \detune.kr(0);

		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var ffreqs = (0..numFreqs-1).collect({arg i;
			(\f ++ i).asSymbol.kr(1);
		}) + detune;

		var amps = (0..numFreqs-1).collect({arg i;
			(\a ++ i).asSymbol.kr(1/numFreqs);
		});

		var rings = (0..numFreqs-1).collect({arg i;
			(\r ++ i).asSymbol.kr(1);
		});

		var sig = DynKlank.ar(`[ffreqs, amps, rings], in, freq_in);

		sig = sig * AmpCompA.kr(freq_in) * \amp.kr(-12.dbamp);

		Pan2.ar(sig.asArray.sum, \pan.kr(0));
	});

	var specs = [
		\trig -> \set,
		\freq -> \set,
		\which -> [0, 2, \lin, 1, 0],
		\focus -> [0,1, \lin, 0, 1],
		\atk -> [0, 1, \lin, 0, 0.01],
		\decay -> [0, 1, \lin, 0, 1],
		\pan -> [-1, 1, \lin, 0, 0],
		\amp -> [0, 1, \lin, 0, 0.1]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = util[\playView].(objName, node, view);
	var specsView = util[\specsView].(objName, specs, node, envir, view);
	var eqView = util[\eqView].(objName, node, envir, view);

	var ctrls = (0..5).collect({arg num;
		HLayout(
			Slider2D()
			.action_({arg ctrl;
				var freq = ctrl.x.linlin(0,1,1,20);
				var ring = ctrl.y;
				var fkey = ('f' ++ num).asSymbol;
				var rkey = ('r' ++ num).asSymbol;
				node.set(fkey, freq, rkey, ring);
			})
			.x_(1.linlin(1,20,0,1))
			.y_(1),
			Slider()
			.thumbSize_(10)
			.orientation_(\vertical)
			.action_({arg ctrl;
				var key = ('a' ++ num).asSymbol;
				node.set(key, ctrl.value)
			})
			.value_(1/num)
		)
	});

	var resView = View().layout_(VLayout(
		HLayout(*ctrls[0..2]),
		HLayout(*ctrls[3..5])
	)).minHeight_(120);

	view.layout.add(playView);
	view.layout.add(resView);
	view.layout.add(eqView);
	view.layout.add(specsView);

	envir[objName] = node;
	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)
