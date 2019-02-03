(
view: {arg objName, envir, components;

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

	var algoPopup;

	var defaultAmp = 0.5;

	var defaultAtk = 0.001;

	var defaultSusLevel = 0.7;

	var defaultDecay = 0.05;

	var defaultSus = 0.8541;

	var defaultRel = 0.0949;

	var controllerEnv = Env([0,1,defaultSusLevel,defaultSusLevel,0],[defaultAtk,defaultDecay,defaultSus,defaultRel],\sin);

	var modEnv = Env([1,1,1,1,1],[0.25,0.25,0.25,0.25],\lin);

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

		var susLevel = \susLevel.kr(defaultSusLevel);
		var atk = \atk.kr(defaultAtk);
		var decay = \decay.kr(defaultDecay);
		var sus = \sus.kr(defaultSus);
		var rel = \rel.kr(defaultRel);
		var env = Env([0,1,susLevel,susLevel,0],[atk,decay,sus,rel],\sin).kr(gate:trig);

		var ctrls = Array.fill(6, {arg i;
			var env = ('c' ++ i ++ 'env').asSymbol.kr(controllerEnv.asArray);
			var amp = ('c' ++ i ++ 'amp').asSymbol.kr(1);
			var ts = ('c' ++ i ++ 'env_ts').asSymbol.kr(1);
			var envgen = EnvGen.kr(env, gate:trig, levelScale:amp, timeScale:ts);
			[freq * ('c' ++ i).asSymbol.kr(1) + LFNoise2.kr(0.01).range(-5,5), 0, envgen]
		});

		var mods = Array.fill2D(6, 6, {arg r, c;
			var key = ('m' ++ r ++ '_' ++ c);
			key.asSymbol.kr(0);
		}) * 2pi; // in radians

		var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0)});

		sig = sig * AmpCompA.kr(freq) * env * \amp.kr(defaultAmp);

		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	}).filter(1, {arg in;

		var sig = in;
		var lo_freq = \lo_freq.kr(100).lag(0.2);
		var lo_db = \lo_db.kr(0).lag(0.2);
		var mid_freq = \mid_freq.kr(1000).lag(0.2);
		var mid_db = \mid_db.kr(0).lag(0.2);
		var hi_freq = \hi_freq.kr(10000).lag(0.2);
		var hi_db = \hi_db.kr(0).lag(0.2);

		sig = BPeakEQ.ar(sig, lo_freq, 1, lo_db);
		sig = BPeakEQ.ar(sig, mid_freq, 1, mid_db);
		sig = BPeakEQ.ar(sig, hi_freq, 1, hi_db);
		sig;

	}).set(\wet1, 0);

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

	var gridBoxes = Array.fill2D(6, 6, {arg r, c;
		NumberBox().minHeight_(15).minWidth_(30)
		.action_({arg ctrl;
			setMod.(r, c, ctrl.value);
		})
		.clipLo_(0)
		.clipHi_(2)
		.decimals_(2)
		.normalColor_(Color.white)
	});

	var grid = GridLayout.rows(

		// grid with column headers and row headers
		*(0..6).collect({arg k;
			if (k == 0) {
				(0..6).collect({arg i;
					if (i == 0) {
						nil
					} {
						StaticText().string_(i).align_(\center);//.stringColor_(Color.black);
					}
				});
			} {
				(0..6).collect({arg i;
					var color = Color.clear;
					if ((k-1) == (i-1)) {color = Color.blue.alpha_(0.2)};
					if (i == 0) {
						StaticText().string_(k)
					} {
						gridBoxes[k-1][i-1].background_(color)
					}
				})
			}
		})
	).margins_(1).spacing_(0);

	var envViews = (0..5).collect({arg i;

		EnvelopeView()
		.minHeight_(50)
		.drawLines_(true)
		.selectionColor_(Color.red)
		.drawRects_(true)
		.resize_(5)
		.step_(0.0)
		.thumbSize_(10)
		.keepHorizontalOrder_(true)
		.setEnv(modEnv)
		.action_({arg ctrl;
			var key = ('c' ++ i ++ 'env').asSymbol;
			node.set(key,ctrl.asEnv);
		})
		.fillColor_(Color.blue);
	});

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

		envViews.do({arg v, i;
			var key = ('c' ++ i ++ 'env').asSymbol;
			v.setEnv(modEnv);
			v.valueAction_(modEnv.asArray);
		});
		chans.do({arg i;
			var key = ('c' ++ i ++ 'env').asSymbol;
			channels[i].valueAction_(1);
			envViews[i].setEnv(controllerEnv);
			envViews[i].valueAction_(modEnv.asArray);
		});


		vals.do({arg val;
			gridBoxes[val[0]][val[1]].valueAction_(0.15).background_(Color.gray);
		});
	};

	var freqViews = (0..5).collect({arg i;

		NumberBox()
		.minHeight_(15)
		.minWidth_(30)
		.clipLo_(0)
		.clipHi_(14)
		.decimals_(4)
		.action_({arg ctrl;
			var key = ('c' ++ i).asSymbol;
			var val = ctrl.value;
			node.set(key, val);
		})
		.value_(1)
		.normalColor_(Color.white)
	});

	var specs = [
		\trig -> \set,
		\freq -> \set,
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
		//\vrate -> [0, 10, \lin, 0, 6],
		//\vdepth -> [0, 1, \lin, 0, 0],
		//\vdelay -> [0, 1, \lin, 0, 0],
		//\vonset -> [0, 1, \lin, 0, 0],
		//\vrateVar -> [0, 1, \lin, 0, 0.04],
		//\vdepthVar -> [0, 1, \lin, 0, 0.1],
		//susLevel: [0,1,\lin,0,0.5]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2)).minWidth_(400).minHeight_(700);
	var playView = components[\playView].(objName, node, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var controllersView = View().layout_(VLayout().margins_(3).spacing_(3));

	view.layout.add(playView);

	2.do({arg r;

		if (r > 0) {
			controllersView.layout.add(
				StaticText().string_(" ").background_(Color.black).maxHeight_(2)
			);
		};

		controllersView.layout.add(
			HLayout(
				*(0..2).collect({arg c;

					var num = (3 * r + c);
					VLayout(
						HLayout(
							channels[num],
							StaticText().string_("#" ++ (num+1)),
							nil
						),
						// controller freq ratio
						freqViews[num],

						envViews[num],
						HLayout(
							StaticText().string_("Level Scale"),
							Slider().orientation_(\horizontal).value_(1).maxHeight_(15).maxWidth_(50)
							.action_({arg ctrl;
								var key = ('c' ++ num ++ 'amp').asSymbol;
								node.set(key,ctrl.value);
							})
						),
						HLayout(
							StaticText().string_("Time Scale"),
							Slider().orientation_(\horizontal).value_(1).maxHeight_(15).maxWidth_(50)
							.action_({arg ctrl;
								var key = ('c' ++ num ++ 'env_ts').asSymbol;
								node.set(key, ctrl.value);
							})
						)
					)
				});
			);
		);
	});

	// algo, randomize
	view.layout.add(
		HLayout(
			StaticText().string_("algo"),
			algoPopup = PopUpMenu()
			.items_([""] ++ Array.fill(32, {arg i; i + 1}))
			.action_({arg ctrl;
				loadAlgo.(ctrl.value)
			}).maxHeight_(15),
			nil,
			Button().states_([["Randomize"]]).action_({arg ctrl;

				var num = (1..32).choose;
				algoPopup.valueAction_(num);
				freqViews.do({arg v,i;

					var val = if (channels[i].value) { (1..4).choose } { (rrand(1.0,14.0).dup(14) ++ (1.0..14.0)).choose };
					v.valueAction_(val);

					6.do({arg r;
						6.do({arg c;
							var val = gridBoxes[r][c].value;
							if (val > 0) {
								val = rrand(0.01, 0.15);
								gridBoxes[r][c].valueAction_(val);
							}
						})
					})
				});
			})
		).spacing_(5)
	);

	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));
	view.layout.add(StaticText().string_("Controllers"));
	view.layout.add(controllersView);
	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));
	view.layout.add(StaticText().string_("Modulators"));
	view.layout.add(grid);
	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));

	view.layout.add(StaticText().string_("Envelope"));

	view.layout.add(
		HLayout(
			VLayout(
				Knob().value_(defaultAtk).action_({arg ctrl;
					var key = \atk;
					node.set(key,ctrl.value);
				}).mode_(\vert),
				StaticText().string_("A").align_(\center)
			),
			VLayout(
				Knob().value_(defaultDecay).action_({arg ctrl;
					var key = \decay;
					node.set(key,ctrl.value);
				}).mode_(\vert),
				StaticText().string_("D").align_(\center)
			),
			VLayout(
				HLayout(
					Knob().value_(defaultSus).action_({arg ctrl;
						var key = \sus;
						node.set(key,ctrl.value);
					}).mode_(\vert),
					Slider().maxHeight_(35).maxWidth_(15).thumbSize_(10).value_(defaultSusLevel)
					.action_({arg ctrl;
						var key = \susLevel;
						node.set(key,ctrl.value);
					})
				),
				StaticText().string_("S").align_(\center)
			),
			VLayout(
				Knob().value_(defaultRel).action_({arg ctrl;
					var key = \rel;
					node.set(key,ctrl.value);
				}).mode_(\vert),
				StaticText().string_("R").align_(\center)
			),
			VLayout(
				Knob().value_(defaultAmp).action_({arg ctrl;
					var key = \amp;
					node.set(key,ctrl.value);
				}).mode_(\vert),
				StaticText().string_("Output").align_(\center)
			)
		)
	);

	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));

	view.layout.add(StaticText().string_("EQ"));

	view.layout.add(HLayout(
		Slider2D().fixedSize_(45).action_({arg ctrl;
			node.set(\lo_freq, ctrl.x.linlin(0,1,0.1,1000));
			node.set(\lo_db, ctrl.y.linlin(0,1,-18,18));
		}).x_(100.linlin(0,1000,0,1)).y_(0.linlin(-18,18,0,1)),

		Slider2D().fixedSize_(45).action_({arg ctrl;
			node.set(\mid_freq, ctrl.x.linlin(0,1,1000,10000));
			node.set(\mid_db, ctrl.y.linlin(0,1,-18,18));
		}).x_(1000.linlin(1000,10000,0,1)).y_(0.linlin(-18,18,0,1)),

		Slider2D().fixedSize_(45).action_({arg ctrl;
			node.set(\hi_freq, ctrl.x.linlin(0,1,10000,20000));
			node.set(\hi_db, ctrl.y.linlin(0,1,-18,18));
		}).x_(10000.linlin(10000,20000,0,2)).y_(0.linlin(-18,18,0,1))
	));

	view.layout.add(Slider().action_({arg ctrl;
		node.set(\wet1, ctrl.value);
	}).value_(0).orientation_(\horizontal));

	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));
	//view.layout.add(StaticText().string_("Vibrato"));
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
