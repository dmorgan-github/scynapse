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

	var keyboardView = {

		var map = (
			'z': 0,'s': 1,'x': 2,'d': 3,'c': 4,'v': 5,'g': 6,
			'b': 7,'h': 8,'n': 9,'j': 10,'m': 11,',': 12,
			'q': 12,'2': 13,'w': 14,'3': 15,'e': 16,'r': 17,'5': 18,
			't': 19,'6': 20,'y': 21,'7': 22,'u': 23,'i': 24
		);

		var synths = Order.new;
		var black = [1,3,6,8,10];
		var rows = 24;

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

		var view = View()
		.layout_(VLayout(*keyboard).margins_(0).spacing_(1))
		.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
			var val = map[char.asSymbol];
			if (val.isNil.not) {
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + val;
				var args = [\out, node.bus.index, \gate, 1, \freq, note.midicps] ++ synthEnvir.asPairs();
				var x = Synth(thesynth.asSymbol, args, target:node.nodeID);
				synths[note] = x;
				{x.release}.defer(10)
			};
		})
		.keyUpAction_({arg ctrl, char;
			var val = map[char.asSymbol];
			var octave = synthEnvir[\octave] ?? 5;
			var note = 12 * octave + val;
			synths[note].set(\gate, 0);
		});

		view
	};

	var synthView = {arg envir, name, synth;

		var metadata = SynthDescLib.global.at(synth).metadata;
		var specs = metadata[\specs];
		var specsView = components[\pSpecsView].(name, specs, envir, view);

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
		Pdef(objName,
			Pbindef((objName ++ '_set').asSymbol, \foo, 1) <>
			Pbind(
				\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
				\scale, Pif(Pfunc({synthEnvir[\scale].isNil}), Scale.chromatic, Pfunc({synthEnvir[\scale]})),
				\degree, 0, //Pif(Pfunc({synthEnvir[\degree].isNil}), 0, Pfunc({synthEnvir[\degree]})),
				\octave, Pif(Pfunc({synthEnvir[\octave].isNil}), 5, Pfunc({synthEnvir[\octave]})),
				\vel, Pif(Pfunc({synthEnvir[\vel].isNil}), 1, Pfunc({synthEnvir[\vel]})),
			) <> Pdef(\synthysynthbase) <> (evt:synthEnvir, ndef:objName, monitor:true)
		);

		specsView;
	};

	var playView = View().layout_(HLayout(
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
		PopUpMenu()
		.maxHeight_(15)
		.items_(["", 3, 4, 5, 6, 7])
		.action_({arg ctrl;
			if (ctrl.value > 0) {
				synthEnvir[\octave] = ctrl.item;
			}
		})
		.value_(3),
		nil
	));

	var update = {arg synth;
		var view = synthView.(synthEnvir, objName, synth);
		thesynth = synth;
		containerView.removeAll;
		containerView.layout.add(view);
	};

	node.play;
	envir[objName] = node;
	view.layout.add(PopUpMenu()
		.items_([" "] ++ validsynths)
		.action_({arg ctrl;
			var name = ctrl.item;
			update.(name.asSymbol);
	}));

	view.layout.add(VLayout(playView, HLayout(keyboardView.(), containerView)));
	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
	});

	view;
}
)
