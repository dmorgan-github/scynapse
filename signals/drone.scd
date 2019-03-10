(
view: {arg objName, envir, components;

	var harms = 12;
	var nodefunc = {arg harms = 12;

		{
			var rq = \rq.kr(0.005);
			var which = \which.kr(2);
			var focus = \focus.kr(1);
			var detune = \detune.kr(0.01);
			var detdepth = \detdepth.kr(5);
			var freq = \freq.kr(60) * LFNoise2.kr(detdepth).range(1 + detune.neg, 1 + detune);

			var noise = SelectXFocus.kr(which,
				[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1), StandardL.ar],
				focus,
				wrap:true);

			var sig = RLPF.ar(noise, freq * (1..harms), 0.005).flatten * (0..(harms-1)).collect({arg val;
				var amp = harms/(val+1);
				var key = ('h' ++ val).asSymbol;
				key.kr(amp);
			}).normalizeSum;

			var sigodd = sig.select({arg sig, i; i.odd});
			var sigeven = sig.select({arg sig, i; i.even});
			Splay.ar([sigodd.sum, sigeven.sum], \spread.kr(1), center:\center.kr(0)) * \amp.kr(-20.dbamp) * \vol.kr(1);
		};
	};

	var node = NodeProxy.audio(s, 2).source_(nodefunc.(harms));

	var specs = [
		\trig -> \set,
		\freq -> \set,
		\rq -> [0,1,\lin,0, 0.005],
		\detdepth -> [(1/128), 20, \lin, 0, 5],
		\detune -> [0, 1, \lin, 0, 0.01],
		\which -> [0, 3, \lin, 1, 1],
		\focus -> [0,1, \lin, 0, 1],
		\amp -> [0, 1, \lin, 0, 0.1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = components[\playView].(objName, node, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var eqView = components[\eqView].(objName, node, envir, view);
	var multi = MultiSliderView().size_(harms).elasticMode_(1).isFilled_(true).fillColor_(Color.grey);
	var pulseView = View().layout_(VLayout(
		NumberBox().maxDecimals_(0).action_({arg ctrl;
			var num = ctrl.value;
			envir[objName][0] = nodefunc.(num);
			multi.size_(num).value_(Array.fill(num, {arg i; 1/(i+1); }));
		})
		.normalColor_(Color.white)
		.value_(harms),

		multi.action_({arg ctrl;
			ctrl.value.do({arg val, i;
				var key = ('h' ++ i).asSymbol;
				node.set(key, val);
			});
		}).value_(Array.fill(harms, {arg i; 1/(i+1); }))
	));

	envir[objName] = node;
	view.layout.add(playView);
	view.layout.add(eqView);
	view.layout.add(pulseView);
	view.layout.add(specsView);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
		NotificationCenter.notify(view, \close, objName);
	});
}
)
