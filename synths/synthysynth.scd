(
view: {arg objName, envir, components;

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

	var synthView = {arg envir, name, synth;

		var metadata = SynthDescLib.global.at(synth).metadata;
		var specs = metadata[\specs];
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

		var view = View()
		.name_(name)
		.layout_(VLayout().margins_(1).spacing_(1));

		var controlsView = View().layout_(VLayout(
			*specs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				ctrlView.(key, spec, Color.rand);
			})
		).margins_(2).spacing_(1));

		// TODO: we don't need to recreate this each time
		Pdef(\synthysynthbase, {arg evt, ndef, monitor=true;
			var node = Ndef(ndef);
			specs = specs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				if (currentEnvironment[key].isNil) {
					currentEnvironment[key] = spec.default;
				};
				[key, Pfunc({currentEnvironment[key]})]
			}).flatten ++ [\instrument, synth, \out, Pfunc({node.bus.index}), \group, Pfunc({node.group})];

			if (node.isMonitoring.not and: monitor){
				node.play;
			};
			Penvir(evt,
				Pbind(*specs)
			)
		});
		Pdef(objName, {arg monitor=false;
			Pbind(
				\dur, 1,
				\degree, 0,
				\octave, 5,
				\vel, 1,
			) <> Pdef(\synthysynthbase) <> (evt:synthEnvir, ndef:objName, monitor:monitor)
		});

		view.layout.add(controlsView);
		scrollView.canvas = view;
		scrollView;
	};

	var update = {arg synth;
		var view = synthView.(synthEnvir, objName, synth);
		containerView.removeAll;
		containerView.layout.add(view);
	};

	envir[objName] = node;
	// need to initialize the bus and group
	// by calling play and then stopping
	envir[objName].play;
	{envir[objName].stop}.defer(5);

	view.layout.add(PopUpMenu()
		.items_([" "] ++ validsynths)
		.action_({arg ctrl;
			var name = ctrl.item;
			update.(name.asSymbol);
	}));

	view.layout.add(containerView);

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
	});

	view;
}
)