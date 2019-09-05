(
view: {arg objName, envir, components;

	var buf;
	var navView;
	var synth, player;
	var height = 20;
	var width = 300;

	// Node
	var node = NodeProxy.audio.source_({

		var trig = Impulse.kr(\distance.kr(1).reciprocal);
		var warp = \warp.kr(0);
		var curve = \curve.kr(0);
		var buf = \buf.kr(0);
		var start = \start.kr(0);
		var end = \end.kr(1);
		var atk = \atk.kr(0);
		var dec = \dec.kr(0);
		var suslevel = \suslevel.kr(1);
		var sus = \sus.kr(1);
		var rel = \rel.kr(1);
		var ts = \ts.kr(1);
		//var speed = \stretch.kr(1);
		var pitch = \pitch.kr(1);
		//var numframes = BufFrames.kr(buf);
		var startframe = start;//numframes * start;
		//var endframe = numframes * end;
		//var dur = (endframe - startframe) / BufSampleRate.kr(buf);
		//var phasor = Env([start,start,end], [0, dur * speed], warp).ar(gate:trig);
		var env = Env([0,suslevel,suslevel,0], [atk,dec,sus,rel].normalizeSum, curve).ar(gate:trig, timeScale:ts);
		var sig = PlayBuf.ar(1, buf, pitch, trig, startframe, 0);
		/*
		var sig = Warp1.ar(
			numChannels:1,
			bufnum:buf,
			pointer:phasor,
			freqScale:pitch,
			windowSize:16.reciprocal,// LFNoise2.kr(10).range(8,18).reciprocal,
			envbufnum:-1,
			overlaps:16,
			windowRandRatio:0.2,
			interp:4
		);
		*/

		sig = sig * env * \amp.kr(-8.dbamp);

		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	});

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
						node.set(\buf, buf.bufnum);
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
		\distance -> [0.1, 64, \lin, 0, 4],
		//\start -> [0, 1, \lin, 0, 0],
		//\end -> [0, 1, \lin, 0, 1],
		\atk -> [0, 1, \lin, 0, 0.001],
		\dec -> [0, 1, \lin, 0, 0],
		\sus -> [0, 1, \lin, 0, 1],
		\suslevel -> [0,1,\lin,0, 1],
		\rel -> [0, 1, \lin, 0, 0],
		\curve -> [-24, 24, \lin, 0, 6],
		\ts -> [0, 64, \lin, 0, 1],
		\amp -> [0, 1, \lin, 0, 0.3],
		\pitch -> [0.1, 4, \lin, 0, 1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var specsView = components[\specsView].(objName, specs, node, envir, view);

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
		node.set(\start, loFrames, \end, hiFrames);
		msg = "start: %, end: %".format(loFrames, hiFrames);
		NotificationCenter.notify(view, \status, msg);
	});
	sfv.setSelectionColor(0, Color.blue(alpha:0.5));
	view.layout.add(controlsView.());
	view.layout.add(sfv);
	view.layout.add(specsView);

	node.mold;
	envir[objName] = node;

	view;
};
)


