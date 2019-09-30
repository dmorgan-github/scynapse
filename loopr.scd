(
view: {arg objName, envir, components;

	var buf;
	var navView;
	var synth, player;
	var height = 20;
	var width = 300;
	var osckey = ('/' ++ objName ++ '_data').asSymbol;

	var windowSize = 4096;
	var env = Env.perc;
	var envbuf = Buffer.sendCollection(s, env.discretize(windowSize), 1);

	// Node
	var srcfunc = {arg numchannels = 1;
		"numchannesl: %".format(numchannels).debug(objName);

		{
			var tempo = \bpm.kr(1) * 60.reciprocal;
			var trig = (Impulse.kr(tempo) + \trig.tr(0));
			var buf = \buf.kr(0);
			var rnd = \rnd.kr(0);
			var numframes = BufFrames.kr(buf);
			var start = (\start.kr(0) * 1-rnd) + (rnd * Demand.kr(trig, 0, Dwhite(0, 1)) * numframes);
			var loop = \loop.kr(1);
			var rev = \rev.kr(0);
			var rate = \rate.kr(1) * BufRateScale.kr(buf) * Demand.kr(trig, 0, Dwrand([-1, 1], [rev, 1-rev], inf));
			var ts = \ts.kr(1);
			var phase = Env([0,0,windowSize],[0,1],0).ar(gate:trig, timeScale:ts * tempo.reciprocal);

			var speed = (numframes - start)/BufSampleRate.kr(buf) * rate.reciprocal.abs;
			var replyphase = Env([0, 0, 1],[0,speed],0).ar(gate:trig, timeScale:rate.abs);

			var env = BufRd.ar(1, envbuf, phase);
			var sig = PlayBufCF.ar(numchannels, buf, rate, trig, start, loop);
			sig = sig * env * \amp.kr(-8.dbamp);

			SendReply.kr(Impulse.kr(50), osckey,
				[replyphase.linlin(0, 1, start,  numframes - (numframes * rev))], 1905);
			Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		};
	};
	var node = NodeProxy.audio.source_(srcfunc.());

	var view = View().layout_(VLayout().margins_(2).spacing_(2));

	var controlsView = {

		var myView = View().layout_(HLayout().margins_(2).spacing_(2));
		var dragSink, button;

		button = Button()
		.fixedSize_(8)
		.states_([ ["x"] ])
		.font_(Font().size_(9))
		.action_({
			dragSink.string = "";
			button.enabled = false;
		})
		.enabled_(false);

		dragSink = DragSink()
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

						node.source = srcfunc.(buf.numChannels);
						node.set(\buf, buf.bufnum, \start, 0, \trig, 1);

						sfv.mouseUpAction.value(sfv);
					}.defer
				});

				v.string = name;
				button.enabled = true;
			} {
				var msg = "bufnum % doesn't exist in environment".format(bufnum);
				NotificationCenter.notify(view, \status, msg);
				button.enabled = false;
			}
		})
		.maxHeight_(35)
		.minWidth_(35);

		myView.layout.add(dragSink, button);
		myView;
	};

	var specs = [
		\bpm -> [1, 300, \lin, 0, 60],
		\rnd -> [0, 1, \lin, 0, 0],
		\ts -> [0, 1, \lin, 0, 1],
		\amp -> [0, 10, \lin, 0, 0.3],
		\rate -> [0.1, 4, \lin, 0, 1],
		\rev -> [0, 1, \lin, 0, 0],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var msv = MultiSliderView();
	var positions = [0, 0, 0, 0];

	var sfv = SoundFileView()
	.background_(Color.gray(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.fixedSize_(width@75)
	.mouseUpAction = ({arg ctrl;
		var loFrames, hiFrames;
		var msg;
		loFrames = ctrl.selection(0)[0];
		hiFrames = ctrl.selection(0)[1] + loFrames;
		node.set(\start, loFrames, \end, hiFrames, \trig, 1);
		msg = "start: %, end: %".format(loFrames, hiFrames);
		NotificationCenter.notify(view, \status, msg);
	});

	var oscfunc = OSCFunc({arg msg;
		{ sfv.timeCursorPosition = msg[3] }.defer(0.001)
	}, osckey);

	var eview = EnvelopeView()
	.setEnv(env)
	.action_({arg ctrl;
		envbuf.setn(0, ctrl.asEnv.discretize(windowSize), 1);
	});

	var stepsView = View().layout_(HLayout().margins_(1).spacing_(2));
	stepsView.layout.add(VLayout(
		NumberBox()
		.normalColor_(Color.white)
		.minWidth_(25)
		.value_(positions.size)
		.action_({arg ctrl;

			var newsize = ctrl.value;
			if (newsize > positions.size) {
				var size = newsize - positions.size;
				var newvals = Array.fill(size, {0.0});
				positions = positions ++ newvals;
			}{
				var size = positions.size;
				var toremove = size - newsize;
				toremove.do({arg i;
					var index = size + i - 1;
					positions.removeAt(index);
				});
			};
			msv.value_(positions)
		}),
		Button().action_({arg ctrl;
			positions = Array.fill(positions.size, {rrand(0.0, 1.0)});
			msv.value_(positions);
		})
	));
	stepsView.layout.add(msv
		.elasticMode_(1)
		.value_(positions)
		.thumbSize_(300/4)
		.drawRects_(true)
		.isFilled_(true)
		.action_({arg ctrl;
			positions = ctrl.value;
		})
	);

	sfv.setSelectionColor(0, Color.blue(alpha:0.5));
	view.layout.add(controlsView.());
	view.layout.add(sfv);
	view.layout.add(stepsView);
	view.layout.add(eview);
	view.layout.add(PopUpMenu()
		.items_([\triangle, \perc, \sine, \linen, \adsr])
		.action_({arg val;
			var window = val.item;
			switch(window,
				\triangle, {
					env = Env.triangle;
					envbuf.setn(0, env.discretize(windowSize), 1);
					eview.setEnv(env);
				},
				\perc, {
					env = Env.perc;
					envbuf.setn(0, env.discretize(windowSize), 1);
					eview.setEnv(env);
				},
				\sine, {
					env = Env.sine;
					envbuf.setn(0, env.discretize(windowSize), 1);
					eview.setEnv(env);
				},
				\linen, {
					env = Env.linen;
					envbuf.setn(0, env.discretize(windowSize), 1);
					eview.setEnv(env);
				},
				\adsr, {
					env = Env([0,1,0.5,0.5,0],[0.01,0.3,1,1].normalizeSum,-4);
					envbuf.setn(0, env.discretize(windowSize), 1);
					eview.setEnv(env);
				}
			)
		})
		.value_(1)
	);
	view.layout.add(specsView);

	node.mold;
	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		oscfunc.free;
	});

	view;
};
)



