(
view: {arg objName, envir, components;

	var thesynth = \default;

	var synthEnvir = {
		if (topEnvironment[objName].isNil){
			topEnvironment[objName] = ();
		};
		topEnvironment[objName];
	}.();

	var validsynths = SynthDescLib.global.synthDescs.select({arg desc;
		// validate the metadata is
		// in the format we need
		var returnval = false;
		if (desc.metadata.isNil.not) {
			if (desc.metadata[\specs].class == Array) {
				returnval = true;
			}
		};
		returnval;
	}).collect({arg desc; desc.name}).asArray;

	var node = NodeProxy.audio(s, 2);
	var view = View().layout_(VLayout().margins_(1).spacing_(1));
	var containerView = View().layout_(VLayout().margins_(0).spacing_(0));

	var gridView = {

		var map = (
			'z': 0,'s': 1,'x': 2,'d': 3,'c': 4,'v': 5,'g': 6,
			'b': 7,'h': 8,'n': 9,'j': 10,'m': 11,',': 12,
			'q': 12,'2': 13,'w': 14,'3': 15,'e': 16,'r': 17,'5': 18,
			't': 19,'6': 20,'y': 21,'7': 22,'u': 23,'i': 24
		);

		var synths = Order.new;
		var black = [1,3,6,8,10];
		var rows = 24;
		var cols = 16;
		var data = rows.collect({ cols.collect({0})});
		var headers = cols.collect({arg col;
			StaticText().string_("").fixedSize_(12).background_(Color.blue.alpha_(0.3));
		});
		var keyboard = rows.collect({arg i;
			var color = Color.grey;
			var num = rows-1-i;
			if (black.includes(num.mod(12))) {
				color = Color.black;
			};
			Button()
			.states_([[nil, nil, color], [nil, nil, Color.white]])
			.fixedWidth_(20)
			.fixedHeight_(12)
			.mouseDownAction_({arg ctrl;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + num;
				var args = [\out, node.bus.index, \gate, 1, \freq, note.midicps] ++ synthEnvir.asPairs();
				var x = Synth(thesynth.asSymbol, args, target:node.nodeID);
				synths[note] = x;
				ctrl.value = 1;
			})
			.mouseUpAction_({arg ctrl;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + num;
				synths[note].set(\gate, 0);
				ctrl.value = 1;
			});
		});
		var grid = cols.collect({arg col;
			[headers[col]] ++
			rows.collect({arg row;
				var color = Color.white;
				var num = rows-1-row;
				if (black.includes(num.mod(12))) {
					color = Color.grey.alpha_(0.6);
				};
				Button()
				.fixedSize_(12)
				.states_([ [nil, nil, color], [nil, nil, Color.blue] ])
				.action_({arg ctrl;
					data[rows-1-row][col] = ctrl.value;
				})
			})
		});

		var playView = View().layout_(HLayout(
			NumberBox()
			.fixedHeight_(15)
			.fixedWidth_(25)
			.stringColor_(Color.white)
			.normalColor_(Color.white)
			.action_({arg ctrl;
				synthEnvir[\dur] = ctrl.value;
			})
			.value_(1),
			PopUpMenu()
			.maxHeight_(15)
			.items_(["", 3, 4, 5, 6, 7])
			.action_({arg ctrl;
				if (ctrl.value > 0) {
					synthEnvir[\octave] = ctrl.item;
				}
			})
			.value_(3),
			Button()
			.fixedSize_(15)
			.states_([[">", nil, nil], ["[]", nil, nil]])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					Pdef(objName).play;
				}{
					Pdef(objName).stop;
				}
			}),
			Button()
			.fixedSize_(15)
			.states_([["m", nil, nil],["X", nil, nil]])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					Ndef(objName).play;
				}{
					Ndef(objName).stop;
				}
			})
			.value_(1),
			nil
		));

		var view = View()
		.layout_(VLayout(
			playView.(),
			GridLayout.columns([nil] ++ keyboard, *grid).margins_(1).spacing_(1)
		).margins_(0).spacing_(1))
		.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
			var val = map[char.asSymbol];
			//if (val.isNil.not) {
			//	var freq = midinote + val;
			//	var args = [\out, node.bus.index, \gate, 1, \freq, freq.midicps] ++ synthEnvir.asPairs();
			//	var x = Synth(thesynth.asSymbol, args, target:node.nodeID);
			//	synths[freq] = x;
			//	{x.release}.defer(10)
			//};
			val.debug(\keydown);
		})
		.keyUpAction_({arg ctrl, char;
			var val = map[char.asSymbol];
			//var freq = midinote + val;
			//synths[freq].set(\gate, 0);
			val.debug(\keyup);
		});

		var rout = Prout({
			var degrees = List.new;
			inf.do({arg i;
				var col = i.mod(cols);
				{
					if (i > 0) {
						var prev = (i-1).mod(cols);
						headers[prev].background_(Color.blue.alpha_(0.3));
					};
					headers[col].background_(Color.white);
				}.defer;
				degrees.do({arg degree;
					{
						degree = degree-23*(-1);
						keyboard[degree].value = 0;
					}.defer;
				});
				degrees.clear;
				rows.do({arg row;
					var degree = rows-1-row;
					var cell = data[degree][col];
					if (cell == 1) {
						degrees.add(degree);
						{
							keyboard[row].value = 1;
						}.defer;
					}
				});
				if (degrees.size == 0) {
					Rest().yield;
				} {
					degrees.yield;
				}
			});
		});
		[view, rout];
	}.();

	var synthView = {arg envir, name, synth;

		var metadata = SynthDescLib.global.at(synth).metadata;
		var specs = metadata[\specs];
		/*
		var scrollView = ScrollView(bounds:Rect(0,0,160,300));
		var ctrlView = {arg key, spec, color;

			var controlSpec = spec;
			var myval = envir[key] ?? controlSpec.default;
			var label = key;

			var stack, view;
			var font = Font(size:10);
			var li = LevelIndicator(bounds:Rect(width:20, height:18)).value_(controlSpec.unmap(myval));
			var labelView = StaticText().string_(label ++ ": ").font_(font).stringColor_(Color.white);
			var st = StaticText().string_(myval).font_(font).stringColor_(Color.white);
			var nb = NumberBox().font_(font).value_(myval).background_(Color.white);

			envir[key] = myval;
			stack = StackLayout(
				View()
				.layout_(
					StackLayout(
						View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
						li
						.style_(\continuous)
						.meterColor_(color.alpha_(0.5))
						.warningColor_(color.alpha_(0.5))
						.criticalColor_(color.alpha_(0.5))
						.background_(color.alpha_(0.2))
					)
					.mode_(\stackAll)
					.margins_(0)
					.spacing_(0)
				)
				.mouseMoveAction_({arg ctrl, x, y, mod;
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					if (mod == 0) {
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						envir[key] = mappedVal;
					}
				})
				.mouseUpAction_({arg ctrl, x, y, mod;
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					if (mod == 0) {
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						envir[key] = mappedVal;
					}
				}),
				nb
				.action_({arg ctrl;
					var val = ctrl.value;
					li.value = controlSpec.unmap(val);
					st.string_(val);
					envir[key] = val;
					stack.index = 0;
				}),
			).mode_(\stackOne)
			.margins_(0)
			.spacing_(0);

			view = View()
			.layout_(stack)
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				if (mod == 262144) {
					stack.index = 1;
				}
			})
			.fixedWidth_(150)
			.fixedHeight_(25);
			view
		};
		*/

		//var view = View()
		//.name_(name)
		//.layout_(VLayout().margins_(1).spacing_(1));

		var specsView = components[\pSpecsView].(name, specs, envir, view);

		/*
		var controlsView = View().layout_(VLayout(
			*specs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				ctrlView.(key, spec, Color.rand);
			})
		).margins_(2).spacing_(1));
		*/

		// TODO: we don't need to recreate this each time
		Pdef(\synthysynthbase, {arg evt, ndef, monitor=true;
			var node = Ndef(ndef);
			var myspecs = specs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				if (evt[key].isNil) {
					evt[key] = spec.default;
				};
				[key, Pfunc({evt[key]})]
			}).flatten ++ [\instrument, synth, \out, Pfunc({node.bus.index}), \group, Pfunc({node.group})];

			if (node.isMonitoring.not and: monitor){
				node.play;
			};
			Penvir(evt,
				Pbind(*myspecs)
			)
		});
		Pdef(objName, {arg monitor=true;
			Pbind(
				\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
				\scale, Pif(Pfunc({synthEnvir[\scale].isNil}), Scale.chromatic, Pfunc({synthEnvir[\scale]})),
				\degree, gridView[1],
				\octave, Pif(Pfunc({synthEnvir[\octave].isNil}), 5, Pfunc({synthEnvir[\octave]})),
				\vel, Pif(Pfunc({synthEnvir[\vel].isNil}), 1, Pfunc({synthEnvir[\vel]})),
			) <> Pdef(\synthysynthbase) <> (evt:synthEnvir, ndef:objName, monitor:monitor)
		});

		//view.layout.add(specsView);
		//scrollView.canvas = view;
		//scrollView;
		specsView
	};

	var update = {arg synth;
		var view = synthView.(synthEnvir, objName, synth);
		thesynth = synth;
		containerView.removeAll;
		containerView.layout.add(view);
	};

	/*
	var keyboardView = {

		var map = (
			'z': 0,'s': 1,'x': 2,'d': 3,'c': 4,'v': 5,'g': 6,'b': 7,'h': 8,'n': 9,'j': 10,'m': 11,',': 12,
			'q': 12,'2': 13,'w': 14,'3': 15,'e': 16,'r': 17,'5': 18,'t': 19,'6': 20,'y': 21,'7': 22,'u': 23,'i': 24
		);

		var midinote = 60;
		var synths = Order.new;
		var black = [1,3,6,8,10];
		var view = View().layout_(VLayout(
			Button().string_("*").fixedWidth_(20).minHeight_(20).action_({arg ctrl;

			}),
			Button().string_("+").fixedWidth_(20).fixedHeight_(12),
			Button().string_("-").fixedWidth_(20).fixedHeight_(12),
			*(0..23).reverse.collect({arg i;
				var color = Color.grey;
				if ((black ++ (black+12)).includes(i)) {
					color = Color.black;
				};
				Button()
				.states_([[nil, nil, color], [nil, nil, Color.white]])
				.fixedWidth_(20)
				.fixedHeight_(12)
				.mouseDownAction_({arg ctrl;
					var freq = midinote + i;
					var args = [\out, node.bus.index, \gate, 1, \freq, freq.midicps] ++ synthEnvir.asPairs();
					var x = Synth(thesynth.asSymbol, args, target:node.nodeID);
					synths[freq] = x;
					ctrl.value = 1;
				})
				.mouseUpAction_({arg ctrl;
					var freq = midinote + i;
					synths[freq].set(\gate, 0);
					ctrl.value = 1;
				});
			})
		).margins_(0).spacing_(0.5))
		.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
			var val = map[char.asSymbol];
			if (val.isNil.not) {
				var freq = midinote + val;
				var args = [\out, node.bus.index, \gate, 1, \freq, freq.midicps] ++ synthEnvir.asPairs();
				var x = Synth(thesynth.asSymbol, args, target:node.nodeID);
				synths[freq] = x;
				{x.release}.defer(10)
			};
		})
		.keyUpAction_({arg ctrl, char;
			var val = map[char.asSymbol];
			var freq = midinote + val;
			synths[freq].set(\gate, 0);
		})
		.background_(Color.grey.alpha_(0.5));
		//view.layout.add(nil);
		view;
	};
	*/

	envir[objName] = node;
	// need to initialize the bus and group
	// by calling play and then stopping
	//envir[objName].play;

	view.layout.add(PopUpMenu()
		.items_([" "] ++ validsynths)
		.action_({arg ctrl;
			var name = ctrl.item;
			update.(name.asSymbol);
	}));

	//view.layout.add(Button().states_([["midi", nil, Color.clear],["midi", nil, Color.yellow]]));
	view.layout.add(HLayout(gridView[0], containerView));

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
	});

	view;
}
)