(
view: {arg objName, envir, components;

	var synths = Order.new;
	var specs = [];

	var synthEnvir = {
		if (topEnvironment[objName].isNil){
			topEnvironment[objName] = (
				synth:\default
			);
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

	var noteOn = {arg midinote, vel=1;
		// there should only be one synth per note
		if (synths[midinote].isNil) {
			var synth = synthEnvir[\synth];
			var evt = synthEnvir.select({arg val; val.isNumber;});
			var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps] ++ evt.asPairs();
			var x = Synth(synth.asSymbol, args, target:node.nodeID);
			synths[midinote] = x;
		}
	};

	var noteOff = {arg midinote;
		var synth = synths[midinote];
		synth.set(\gate, 0);
		synths.removeAt(midinote);
	};

	var dragsrc = {
		DragSource()
		.background_(Color.clear)
		.object_({
			(
				name:objName,
				noteOn:noteOn,
				noteOff:noteOff,
				node:node,
				specs:specs,
				context:synthEnvir
			)
		})
		.string_("-->")
		.fixedWidth_(25);
	};

	var keyboardView = {
		var map = (
			'z': 0,'s': 1,'x': 2,'d': 3,'c': 4,'v': 5,'g': 6,
			'b': 7,'h': 8,'n': 9,'j': 10,'m': 11,',': 12,
			'q': 12,'2': 13,'w': 14,'3': 15,'e': 16,'r': 17,'5': 18,
			't': 19,'6': 20,'y': 21,'7': 22,'u': 23,'i': 24
		);

		var black = [1,3,6,8,10];
		var rows = 25;

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
				noteOn.(note);
				ctrl.value = 1;
			})
			.mouseUpAction_({arg ctrl;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + num;
				noteOff.(note);
				ctrl.value = 1;
			});
		});

		var view = View()
		.layout_(VLayout(*keyboard).margins_(0).spacing_(1))
		.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
			var val = map[char.asSymbol];
			if (val.isNil.not) {
				var num = rows-1-val;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + val;
				noteOn.(note);
				if (num < keyboard.size) {
					keyboard[num].value = 1;
				}
			};
			nil;
		})
		.keyUpAction_({arg ctrl, char;
			var val = map[char.asSymbol];
			if (val.isNil.not) {
				var num = rows-1-val;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + val;
				noteOff.(note);
				if (num < keyboard.size) {
					keyboard[num].value = 0;
				}
			}
		});

		view
	};

	var synthView = {arg envir, name, synth;
		var metadata = SynthDescLib.global.at(synth).metadata;
		specs = metadata[\specs];
		components[\pSpecsView].(name, specs, envir, view);
	};

	var playView = {
		View().layout_(HLayout(
			Button()
			.fixedSize_(15)
			.states_([[">", nil, nil],["[]", nil, nil]])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					Ndef(objName).play;
				}{
					Ndef(objName).stop;
				}
			})
			.value_(1),
			Button()
			.fixedSize_(15)
			.string_("free all")
			.action_({arg ctrl;
				synths.do({arg x;
					x.free;
				});
			}),
			nil
		));
	};

	var build_pattern = {

		var synth = synthEnvir[\synth];
		var myspecs = specs.collect({arg assoc;
			var key = assoc.key;
			var spec = assoc.value;
			if (synthEnvir[key].isNil) {
				synthEnvir[key] = spec.default;
			};
			[key, Pfunc({synthEnvir[key]})]
		}).flatten ++ [\instrument, synth, \out, Pfunc({node.bus.index}), \group, Pfunc({node.group})];

		Pdef(objName).clear;
		Pdef(objName,
			Penvir(synthEnvir,
				Pbind(*myspecs)
			)
		);
	};

	var update = {arg synth;
		var view;
		synthEnvir[\synth] = synth;
		view = synthView.(synthEnvir, objName, synth);
		containerView.removeAll;
		containerView.layout.add(view);
		build_pattern.();
	};

	node.play;
	envir[objName] = node;

	view.layout.add(HLayout(
		PopUpMenu()
		.items_([" "] ++ validsynths)
		.action_({arg ctrl;
			var name = ctrl.item;
			update.(name.asSymbol);
		}),
		dragsrc.()
	));

	view.layout.add(
		VLayout(
			//dragsrc.(),
			playView.(),
			HLayout(keyboardView.(), containerView)
		)
	);
	NotificationCenter.register(view, \close, view, {arg msg;
		synths.do({arg x;
			x.free;
		});
		msg.debug("clean up");
	});

	view;
}
)
