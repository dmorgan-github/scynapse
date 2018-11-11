(
view: {arg objName, envir, util;

	var clock = TempoClock.new(60/60).permanent_(true);

	var trig = NodeProxy(s, \control, 1).source_({
		var trig = \trig.tr;
		trig;
	});

	var freq = NodeProxy(s, \control, 1).source_({
		var freq = \freq.kr(432);
		freq;
	});

	var div = 0.25;
	var beats = 16;
	var size = 15;
	var octave = 5;
	var scalename = \dorian;
	var root = 0;
	var len = beats**2;
	var view = View().layout_(VLayout());

	var headers = (0..(beats-1)).collect({arg num;
		UserView()
		.background_(Color.blue.alpha_(0))
		.fixedSize_(size)
		.drawFunc_({
			Pen.color = Color.black;
			Pen.addRect(Rect(0,0,size,size));
			Pen.perform(\stroke);
		})
	});

	var lights = View().layout_(HLayout(*headers).margins_(1).spacing_(1));
	var probs = Array.fill(len, 0);
	var cells = (0..(len-1)).collect({arg num;
		UserView()
		.background_(Color.white.alpha_(0))
		.fixedSize_(size)
		.drawFunc_({
			Pen.color = Color.black;
			Pen.addRect(Rect(0,0,size,size));
			Pen.perform(\stroke);
		})
		.mouseMoveAction_({arg ctrl, x, y, modifiers;
			var alpha = 1-y.linlin(0,size,0,1);
			ctrl.background_(Color.white.alpha_(alpha));
			probs[num] = alpha;
		})
	}).clump(beats);

	var pattern = Pdef(objName, Spawner({arg sp;

		inf.do({arg i;

			var num = i%beats;
			var degree, weights;

			headers.do({arg header;
				{header.background_(Color.white.alpha_(0))}.defer(s.latency)
			});
			{headers[num].background_(Color.white.alpha_(1))}.defer(s.latency);

			weights = probs.clump(beats).flop[num];
			if (weights.sum > 0) {
				var event, scale;
				degree = (0..(beats-1)).wchoose(weights.normalizeSum);
				degree = beats-degree-1;
				scale = Scale.at(scalename);
				event = (type:\set, id: freq.nodeID, args:#[\freq], degree:degree, octave:octave, root:root, scale:scale);
				sp.par(Pn(event,1));
				event = (type:\set, id: trig.nodeID, args:#[\trig]);
				sp.par(Pn(event,1));
			};
			sp.wait(div);
		});

	}));

	var ctrlView = View().layout_(HLayout(
		NumberBox().action_({arg ctrl;
			clock.tempo = ctrl.value;
		})
		.normalColor_(Color.grey)
		.value_(clock.tempo)
		.maxHeight_(size)
		.minWidth_(size*1.5),
		Button()
		.states_([[">"],["[]"]])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				pattern.play(argClock:clock);
			} {
				pattern.stop;
			}
		})
		.fixedSize_(size),
		//Button()
		//.states_([["r"]])
		//.action_({arg ctrl;
		//	pattern.reset;
		//})
		//.fixedSize_(size),
		NumberBox().action_({arg ctrl;
			octave = ctrl.value;
		})
		.normalColor_(Color.grey)
		.value_(octave)
		.maxHeight_(size),
		NumberBox().action_({arg ctrl;
			root = ctrl.value;
		})
		.normalColor_(Color.grey)
		.value_(root)
		.maxHeight_(size),
		PopUpMenu()
		.action_({arg ctrl;
			scalename = ctrl.item.asSymbol;
		})
		.items_(Scale.names)
		.maxHeight_(size)
		.value_(Scale.names.indexOf(scalename)),
		DragSource()
		.background_(Color.clear)
		.object_((node:trig,name:"trig: " ++ objName))
		.string_("-->")
		.align_(\right)
		.minWidth_(30),
		DragSource()
		.background_(Color.clear)
		.object_((node:freq,name:"freq: " ++ objName))
		.string_("-->")
		.align_(\right)
		.minWidth_(30)
	));

	view.layout.add(ctrlView);
	view.layout.add(lights);
	view.layout.add(GridLayout.rows(*cells).margins_(1).spacing_(1));

	view.onClose_({
		envir[objName].clear();
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
			trig.clear;
			freq.clear;
			pattern.stop;
			pattern.clear;
		}.defer();
	});
}
)

