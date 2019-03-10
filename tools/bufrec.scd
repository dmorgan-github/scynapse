(
view: {arg name, envir, components;

	var inputs, specsView;
	var filterSlot = 100;
	var oscfunc, li, oscfunc2;
	var levelskey = ('/' ++ name ++ 'levels').asSymbol;
	var durkey = ('/' ++ name ++ 'dur');
	var recbutton;
	var specs;

	var view = View()
	.layout_(VLayout().spacing_(2).margins_(2));

	envir[name] = NodeProxy.audio(s, 2);
	envir[name].fadeTime = 1;
	envir[name].filter(filterSlot, {arg in;

		var trig = \trig.tr(0);
		var buf = \buf.kr;
		var run = \run.kr(0);
		var secs = (BufFrames.kr(buf) / BufSampleRate.kr(buf));

		var imp = Impulse.kr(10);
		var delimp = Delay1.kr(imp);

		var imp2 = Impulse.kr(1);
		var steps = Stepper.kr(imp2, trig, 0, secs.round + 1, 1);

		var sig = RecordBuf.ar(in * \input.kr(0.dbamp),
			buf,
			offset:0,
			recLevel:\reclevel.kr(1),
			preLevel:\prelevel.kr(0),
			run:run,
			loop:0,
			trigger:trig
		);

		SendReply.kr(imp2 * (steps < secs + 1) * run, durkey, [steps, secs]);
		SendReply.kr(imp, levelskey, [Amplitude.kr(sig), K2A.ar(Peak.ar(sig, delimp).lag(0, 3))]);
		Silence.ar;
	});

	specs = [
		\input -> [0, 10, \lin, 0, 1]
	];

	inputs = components[\multiInputsView].(envir[name], view);
	specsView = components[\specsView].(name, specs, envir[name], envir, view);
	view.layout.add(inputs);
	view.layout.add(VLayout(

		DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var bufnum = obj[\bufnum];
			(bufnum.isNil.not);
		})
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var bufnum = obj[\bufnum];
			var bufname = obj[\name];

			if (bufnum.isNil.not) {
				var buf = s.cachedBufferAt(bufnum);
				envir[name].set(\buf, buf);
				v.string = bufname;
			} {
				var msg = "bufnum % doesn't exist in environment".format(bufnum);
				NotificationCenter.notify(view, \status, msg);
			}
		}),

		HLayout(

			recbutton = Button()
			.states_([[">"], ["[]"]])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					envir[name].set(\trig, 1, \run, 1)
				}{
					envir[name].set(\trig, 0, \run, 0)
				}
			}),

			Button()
			.states_([ ["sc"] ])
			.action_({arg ctrl;
				envir[name].scope;
			})
		),

		li = LevelIndicator(bounds:Rect(100, 100, 100, 400));
	));

	view.layout.add(specsView);

	oscfunc = OSCFunc({arg msg;
		{
			li.value = msg[3].ampdb.linlin(-40, 0, 0, 1);
			li.peakLevel = msg[4].ampdb.linlin(-40, 0, 0, 1);
		}.defer;
	}, levelskey, s.addr);

	oscfunc2 = OSCFunc({arg msg;
		{
			var current = msg[3];
			var total = msg[4];
			if (current >= total) {
				recbutton.valueAction_(0)
			};
			NotificationCenter.notify(view, \status, "%/%".format(current, total));
		}.defer;
	}, durkey, s.addr);

	view.onClose_({
		"destroy: ".debug(name);
		envir[name].clear;
		envir[name] = nil;
		oscfunc.free;
		oscfunc2.free;
		NotificationCenter.notify(view, \close, name);
	});
}
)