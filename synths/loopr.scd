(
view: {arg objName, envir, components;

	var synthEnvir = {
		if (topEnvironment[objName].isNil){
			topEnvironment[objName] = ();
		};
		topEnvironment[objName];
	}.();
	var synth = \bufplayr_2chan;
	var view, playView, sfv, busView, specsView, dataSinkView;
	var node = NodeProxy.audio(s, 2);

	var specs = [
		\atk -> ControlSpec(0, 30, \lin, 0, 0.01),
		\sustain -> ControlSpec(0, 30, \lin, 0, 0.5),
		\rel -> ControlSpec(0, 30, \lin, 0, 0.29),
		\suslevel -> ControlSpec(0, 1, \lin, 0, 0.7),
		\curve -> ControlSpec(-24, 24, \lin, 0, 0),
		\ts -> ControlSpec(0, 100, \lin, 0, 1),
		\rate -> ControlSpec(0.1, 4, \lin, 0, 1),
		\rev -> ControlSpec(0, 1, \lin, 0, 0),
		\loop -> ControlSpec(0, 1, \lin, 1, 0),
		\amp -> ControlSpec(0, 10, \lin, 0, 0.3),
		\spread -> ControlSpec(0, 1, \lin, 0, 1),
		\center -> ControlSpec(-1, 1, \lin, 0, 0),
		\pan -> ControlSpec(-1, 1, \lin, 0, 0)
	];

	envir[objName] = node;

	Pdef(\bufplayrbase, {arg evt, ndef, monitor=true;

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
		var key = (objName ++ '_set').asSymbol;
		Pbindef(key,
			\buf, Pif(Pfunc({synthEnvir[\buf].isNil}), b, Pfunc({synthEnvir[\buf]})),
			\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
			\data, 0,
			\pos, Pkey(\data)
		) <> Pdef(\bufplayrbase) <> (evt:synthEnvir, ndef:objName, monitor:monitor)
	});

	specsView = components[\pSpecsView].(objName, specs, synthEnvir, view);

	sfv = SoundFileView()
	.background_(Color.gray(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.mouseUpAction = ({arg ctrl;
		var loFrames, hiFrames;
		var msg;
		//loFrames = ctrl.selection(0)[0];
		//hiFrames = ctrl.selection(0)[1] + loFrames;
		//node.set(\start, loFrames, \end, hiFrames, \trig, 1);
		//msg = "start: %, end: %".format(loFrames, hiFrames);
		//NotificationCenter.notify(view, \status, msg);
	});

	busView = {
		var dragSink = DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var bufnum = obj[\bufnum];
			(bufnum.isNil.not);
		})
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var bufnum = obj[\bufnum].value;
			var name = obj[\name].value;

			if (bufnum.isNil.not) {

				var buf = s.cachedBufferAt(bufnum);
				buf.loadToFloatArray(action:{arg a;
					{
						sfv.setData(a, channels: buf.numChannels);
						sfv.setSelection (0, [0, buf.numFrames]);
						//node.source = srcfunc.(buf.numChannels, numstarts);
						//node.set(\buf, buf.bufnum);
						sfv.mouseUpAction.value(sfv);
					}.defer
				});
				v.string = name;
				synthEnvir[\buf] = buf;
			} {
				//var msg = "bufnum % doesn't exist in environment".format(bufnum);
				//NotificationCenter.notify(view, \status, msg);
			}
		})
		.maxHeight_(35)
		.minWidth_(35);
		dragSink;
	};

	dataSinkView = {
		var dragSink = DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var type = obj[\type];
			(type.isNil.not and: (type == \data));
		})
		.receiveDragHandler_({arg v;
			var obj = View.currentDrag.value;
			var pattern = obj[\pattern].value;
			var name = obj[\name].value;
			var key = (objName ++ '_set').asSymbol;
			v.string = name;
			Pbindef(key, \data, pattern)
		})
		.maxHeight_(35)
		.minWidth_(35);
		dragSink;
	};

	playView = View().layout_(HLayout(

		NumberBox()
		.fixedHeight_(15)
		.fixedWidth_(30)
		.stringColor_(Color.white)
		.normalColor_(Color.white)
		.action_({arg ctrl;
			synthEnvir[\dur] = ctrl.value;
		})
		.value_(synthEnvir[\dur] ?? 1),

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

	view = View().layout_(VLayout(
		playView.(),
		busView.(),
		sfv,
		dataSinkView.(),
		HLayout(specsView.minWidth_(150))
	));

	view;
};
)



