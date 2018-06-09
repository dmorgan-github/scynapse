(
view: {arg objName, envir, util;

	var algos = {arg num;

		var algos = [

			// 0
			[0, 2] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[3, 4, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 1
			[0, 2] -> [
				[0, 1, 0.15],
				[1, 1, 0.15],
				[2, 3, 0.15],
				[3, 4, 0.15],
				[4, 5, 0.15]
			],

			// 2
			[0, 3] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[3, 4, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 3
			[0, 3] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[3, 4, 0.15],
				[4, 5, 0.15],
				[5, 3, 0.15]
			],

			// 4
			[0, 2, 4] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[5, 5, 0.15]
			],

			// 5
			[0, 2, 4] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[5, 4, 0.15]
			],

			// 6
			[0, 2] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[2, 4, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 7
			[0, 2] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[2, 4, 0.15],
				[4, 5, 0.15],
				[3, 3, 0.15]
			],

			// 8
			[0, 2] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[2, 4, 0.15],
				[4, 5, 0.15],
				[1, 1, 0.15]
			],

			// 9
			[0, 3] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[2, 2, 0.15]
			],

			// 10
			[0, 3] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[5, 5, 0.15]
			],

			// 11
			[0, 2] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[2, 3, 0.15],
				[2, 4, 0.15],
				[2, 5, 0.15],
				[2, 2, 0.15]
			],

			// 12
			[0, 2] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[2, 3, 0.15],
				[2, 4, 0.15],
				[2, 5, 0.15],
				[5, 5, 0.15]
			],

			// 13
			[0, 2] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[2, 3, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[5, 5, 0.15]
			],

			// 14
			[0, 2] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[2, 3, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[1, 1, 0.15]
			],

			// 15
			[0] -> [
				[0, 1, 0.15],
				[0, 2, 0.15],
				[0, 4, 0.15],
				[2, 3, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 16
			[0] -> [
				[0, 1, 0.15],
				[0, 2, 0.15],
				[0, 4, 0.15],
				[2, 3, 0.15],
				[4, 5, 0.15],
				[1, 1, 0.15]
			],

			// 17
			[0] -> [
				[0, 1, 0.15],
				[0, 2, 0.15],
				[0, 3, 0.15],
				[3, 4, 0.15],
				[4, 5, 0.15],
				[2, 2, 0.15]
			],

			// 18
			[0, 3, 4] -> [
				[0, 1, 0.15],
				[1, 2, 0.15],
				[3, 5, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 19
			[0, 1, 3] -> [
				[0, 2, 0.15],
				[1, 2, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[2, 2, 0.15]
			],

			// 20
			[0, 1, 3, 4] -> [
				[0, 2, 0.15],
				[1, 2, 0.15],
				[3, 5, 0.15],
				[4, 5, 0.15],
				[2, 2, 0.15]
			],

			// 21
			[0, 2, 3, 4] -> [
				[0, 1, 0.15],
				[2, 5, 0.15],
				[3, 5, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 22
			[0, 1, 3, 4] -> [
				[1, 2, 0.15],
				[3, 5, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 23
			[0, 1, 2, 3, 4] -> [
				[2, 5, 0.15],
				[3, 5, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 24
			[0, 1, 2, 3, 4] -> [
				[3, 5, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 25
			[0, 1, 3] -> [
				[1, 2, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[5, 5, 0.15]
			],

			// 26
			[0, 1, 3] -> [
				[1, 2, 0.15],
				[3, 4, 0.15],
				[3, 5, 0.15],
				[2, 2, 0.15]
			],

			// 27
			[0, 2, 5] -> [
				[0, 1, 0.15],
				[2, 3, 0.15],
				[3, 4, 0.15],
				[4, 4, 0.15]
			],

			// 28
			[0, 1, 2, 4] -> [
				[2, 3, 0.15],
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 29
			[0, 1, 2, 5] -> [
				[2, 3, 0.15],
				[3, 4, 0.15],
				[4, 4, 0.15]
			],

			// 30
			[0, 1, 2, 3, 4] -> [
				[4, 5, 0.15],
				[5, 5, 0.15]
			],

			// 31
			[0, 1, 2, 3, 4, 5] -> [
				[5, 5, 0.15]
			]
		];

		algos[num];
	};

	var defaultEnv = Env([0,1,0.5,0.5,0],[0.001,0.1,0.6,0.299],\sin);

	var node = NodeProxy.audio(s, 2).source_({

		var trig = \trig.tr(0);

		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var ctrls = Array.fill(6, {arg i;
			var env = ('c' ++ i ++ 'env').asSymbol.kr(defaultEnv.asArray);
			var amp = ('c' ++ i ++ 'amp').asSymbol.kr(1);
			var ts = ('c' ++ i ++ 'env_ts').asSymbol.kr(1);
			[freq * ('c' ++ i).asSymbol.kr(1), 0, EnvGen.kr(env, gate:trig, timeScale:ts) * amp]
		});

		var mods = Array.fill2D(6, 6, {arg r, c;
			var key = ('m' ++ r ++ '_' ++ c);
			var mod = key.asSymbol.kr(0);
			var env = ('m' ++ r ++ '_' ++ c ++ 'env').asSymbol.kr(defaultEnv.asArray);
			var ts = ('m' ++ r ++ '_' ++ c ++ 'env_ts').asSymbol.kr(1);
			var envgen = EnvGen.kr(env, gate:trig, timeScale:ts);
			mod * envgen;
		}) * 2pi; // in radians

		var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0.1)});

		sig = sig * AmpCompA.kr(freq);

		Pan2.ar(Mix.ar(sig), \pan.kr(0));
	});

	var setMod = {arg row, col, val;
		var key = ('m' ++ row ++ '_' ++ col).asSymbol;
		node.set(key, val);
	};

	var channels = (0..5).collect({arg i;
		CheckBox().action_({arg ctrl;
			var key = ('chan' ++ i).asSymbol;
			if (ctrl.value) {
				node.set(key, 1);
			} {
				node.set(key, 0);
			}
		})
	});

	var stack = StackLayout();

	var gridBoxes = Array.fill2D(6, 6, {arg r, c;
		NumberBox().minHeight_(15).minWidth_(30)
		.action_({arg ctrl;
			setMod.(r, c, ctrl.value);
		})
		.clipLo_(0)
		.clipHi_(2)
		.decimals_(2)
		.normalColor_(Color.white)
		.mouseDownAction_({
			var result = 6 * r + c;
			stack.index = result + 6;
		});
	});

	var grid = GridLayout.rows(
		*(0..5).collect({arg k;
			(0..5).collect({arg i;
				var color = Color.clear;
				if (k == i) {color = Color.blue.alpha_(0.2)};
				gridBoxes[k][i].background_(color)
			})
		})
	).margins_(1).spacing_(0);

	var loadAlgo = {arg num;

		// reset
		var mod_vals = algos.(num-1);
		var chans = mod_vals.key;
		var vals = mod_vals.value;

		6.do({arg i;
			channels[i].valueAction_(0);
			6.do({arg k;
				var color = Color.clear;
				if (i == k) {color = Color.blue.alpha_(0.2)};
				gridBoxes[i][k].valueAction_(0).background_(color);
			});
		});

		chans.do({arg i; channels[i].valueAction_(1)});
		vals.do({arg val;
			gridBoxes[val[0]][val[1]].valueAction_(0.15).background_(Color.gray);
		});
	};

	var specs = (
		/*
		trig: \set,
		freq: \set,
		vrate: [0, 10, \lin, 0, 6],
		vdepth: [0, 1, \lin, 0, 0],
		vdelay: [0, 1, \lin, 0, 0],
		vonset: [0, 1, \lin, 0, 0],
		vrateVar: [0, 1, \lin, 0, 0.04],
		vdepthVar: [0, 1, \lin, 0, 0.1],
		susLevel: [0,1,\lin,0,0.5]
		*/
	);

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = util[\playView].(objName, node, view);
	var specsView = util[\specsView].(objName, specs, node, envir, view);

	view.layout.add(playView);

	view.layout.add(HLayout(

		VLayout(*channels),

		VLayout(*(0..5).collect({arg i;
			Knob().fixedSize_(20).value_(1).action_({arg ctrl;

				var key = ('c' ++ i ++ 'amp').asSymbol;
				var val = ctrl.value;
				var result = i;
				stack.index = result;
				node.set(key, val);
			})
			.valueAction_(1)
			.value_(1)
		})),

		VLayout(
			*(0..5).collect({arg i;
				NumberBox()
				.minHeight_(15)
				.minWidth_(30)
				.clipLo_(0)
				.clipHi_(6)
				.decimals_(2)
				.action_({arg ctrl;
					var key = ('c' ++ i).asSymbol;
					var val = ctrl.value;
					node.set(key, val);
				})
				.value_(1)
				.normalColor_(Color.white)
			})
		),
		grid
	));

	view.layout.add(

		VLayout(
			stack = StackLayout(
				*(0..41).collect({arg i;
					View().layout_(
						VLayout(
							StaticText().string_("bobo" ++ i),
							EnvelopeView()
							.minHeight_(100)
							.drawLines_(true)
							.selectionColor_(Color.red)
							.drawRects_(true)
							.resize_(5)
							.step_(0.0)
							.thumbSize_(10)
							.keepHorizontalOrder_(true)
							.setEnv(defaultEnv)
							.action_({arg ctrl;
								var key;
								if (i < 6) {
									key = ('c' ++ i ++ 'env');
								} {
									var r = (i/6).floor;
									var c = i%6;
									key = ('m' ++ r ++ '_' ++ c ++ 'env').asSymbol;
								};
								node.set(key, ctrl.asEnv);
							}),
							HLayout(
								StaticText().string_("time scale").fixedWidth_(65),
								Slider().orientation_(\horizontal).value_(1)
								.action_({arg ctrl;
									var key;
									if (i < 6) {
										key = ('c' ++ i ++ 'env_ts');
									} {
										var r = (i/6).floor;
										var c = i%6;
										key = ('m' ++ r ++ '_' ++ c ++ 'env_ts').asSymbol;
									};
									node.set(key, ctrl.value);
								})
							)
						).margins_(1).spacing_(1)
					)
				})
			),

			HLayout(
				StaticText().string_("algo"),
				PopUpMenu()
				.items_([""] ++ Array.fill(32, {arg i; i + 1}))
				.action_({arg ctrl;
					loadAlgo.(ctrl.value)
				})
			)
		)
	);

	view.layout.add(specsView);

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
};
)