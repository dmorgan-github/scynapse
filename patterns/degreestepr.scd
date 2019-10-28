//
(
view: {arg objName, envir, components;

	var view, specsContainerView = View().layout_(VLayout().margins_(0).spacing_(0));
	var rows = 24;
	var cols = 16;
	var data = rows.collect({ cols.collect({0})});
	var grid, headers;
	var synthEnvir;
	var id;

	var getprout = {
		var prout = Prout({
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
					degree = degree-23*(-1);
				});
				degrees.clear;
				rows.do({arg row;
					var degree = rows-1-row;
					var cell = data[degree][col];
					if (cell == 1) {
						degrees.add(degree);
					}
				});
				if (degrees.size == 0) {
					Rest().yield;
				} {
					degrees.yield;
				}
			});
		});
		prout
	};

	var build_pattern = {arg context;

		var specs;
		var ndef, specsView, synth;
		var synthspecs = context[\specs];
		id = context[\name];
		ndef = id;
		synthEnvir = context[\context];
		synth = synthEnvir[\synth];

		Pdef(\synthbase, {arg evt, ndef, monitor=true;
			var node = Ndef(ndef);
			var myspecs = synthspecs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				if (evt[key].isNil) {
					evt[key] = spec.default;
				};
				[key, Pfunc({evt[key]})]
			}).flatten ++ [\instrument, synth, \out, Pfunc({node.bus.index}), \group, Pfunc({node.group})];
			//if (node.isMonitoring.not and: monitor){
			//	node.play;
			//};
			Penvir(evt,
				Pbind(*myspecs)
			)
		});

		Pdef(id,
			Pbind(
				\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
				\legato, Pif(Pfunc({synthEnvir[\legato].isNil}), 1, Pfunc({synthEnvir[\legato]})),
				\scale, Pif(Pfunc({synthEnvir[\scale].isNil}), Scale.chromatic, Pfunc({synthEnvir[\scale]})),
				\pitch_data, getprout.(),
				\degree, Pkey(\pitch_data),
				\octave, Pif(Pfunc({synthEnvir[\octave].isNil}), 5, Pfunc({synthEnvir[\octave]})),
				\vel, Pif(Pfunc({synthEnvir[\vel].isNil}), 1, Pfunc({synthEnvir[\vel]})),
			) <> Pdef(\synthbase) <> (evt:synthEnvir, ndef:ndef, monitor:true)
		);

		specs = [
			\legato -> ControlSpec(1/16, 64, \lin, 0, 1),
			\dur -> ControlSpec(1/16, 64, \lin, 0, 1),
			\octave -> ControlSpec(0, 8, \lin, 1, 4)
		];
		specsView = components[\pSpecsView].(objName, specs, synthEnvir, view);
		specsContainerView.removeAll;
		specsContainerView.layout.add(specsView);
	};

	var drag_sink = {
		DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			true;
		})
		.receiveDragHandler_({arg v;
			var obj = View.currentDrag.value;
			build_pattern.(obj);
			v.string_(obj[\name]);
		})
		.maxHeight_(35)
		.minWidth_(35);
	};

	var playView = {
		View().layout_(HLayout(
			Button()
			.fixedSize_(15)
			.states_([[">", nil, nil],["[]", nil, nil]])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					Pdef(id).play;
				}{
					Pdef(id).stop;
				}
			})
			.value_(0),
			nil
		));
	};

	var gridView = {

		var black = [1,3,6,8,10];
		var view;

		var nums = cols.collect({arg col;
			StaticText().string_(col+1).fixedSize_(12);
		});

		headers = cols.collect({arg col;
			StaticText().string_("").fixedSize_(12).background_(Color.blue.alpha_(0.3));
		});

		grid = cols.collect({arg col;
			[nums[col]] ++
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

		view = View()
		.layout_(GridLayout.columns(*grid).margins_(1).spacing_(1));
		view;
	};

	view = View().layout_(VLayout(
		drag_sink.(),
		playView.(),
		HLayout(gridView.(), specsContainerView)
	));

	NotificationCenter.register(view, \close, view, {arg msg;
		Pdef(id).clear;
		msg.debug("clean up");
	});

	view;
};
)