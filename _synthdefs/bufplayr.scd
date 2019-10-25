(
var func = {arg numchannels = 1;
	var gate = \gate.kr(1);
	var pos = \pos.ar(0);
	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var rev = \rev.ar(1);
	var reverse = TWChoose.kr(1, [1, -1], [1-rev, rev]);
	var loop = \loop.ar(0);
	var rate = \rate.ar(1);
	var asr = {
		var atk = \atk.ar(0.01);
		var suslevel = \suslevel.ar(1);
		var rel = \rel.ar(0.1);
		var curve = \curve.ar(0);
		var ts = \ts.ar(1);
		var env = Env.asr(atk, suslevel, rel, curve).ar(gate:gate, doneAction:Done.freeSelf, timeScale:ts);
		env;
	};
	var aeg = asr.();
	var sig = PlayBuf.ar(numchannels, buf, rate * reverse, gate, numframes * pos, loop);
	sig = sig * aeg * \vel.ar(1);
	sig = Splay.ar(sig, \spread.ar(1), center:\center.ar(0));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * \amp.kr(-3.dbamp);
	Out.ar(\out.kr(0), sig);
};

SynthDef(\bufplayr_1chan, {
	func.(1);
}).add;

SynthDef(\bufplayr_2chan, {
	func.(2);
}).add;
)


b = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/patches4/2019-10-23/2055/SC_191023_205513.aiff");

~bufplayr_1 = ();

Ndef(\bufplayr_1).play;
Ndef(\bufplayr_1).stop;

(
var objName = \bufplayr_1;
var synthEnvir = topEnvironment[objName];
var synth = \bufplayr_2chan;
var view, playView, sfv, busView;

var seqView = {

	var msv, view, prout, numpos, rnd;

	if (synthEnvir[\positions].isNil) {
		synthEnvir[\positions] = [0, 0, 0, 0];
	};

	numpos = NumberBox()
	.normalColor_(Color.white)
	.minWidth_(25)
	.value_(synthEnvir[\positions].size)
	.action_({arg ctrl;
		var newsize = ctrl.value;
		var positions = synthEnvir[\positions];
		if (newsize > positions.size) {
			var size = newsize - positions.size;
			var newvals = Array.fill(size, {0.0});
			positions = positions ++ newvals;
		}{
			positions = positions[0..(newsize.asInt-1)];
		};
		synthEnvir[\positions] = positions;
		msv.value_(synthEnvir[\positions]);
	});

	rnd = Button().action_({arg ctrl;
		var positions = synthEnvir[\positions];
		var new = Array.fill(positions.size, {rrand(0.0, 1.0)});
		synthEnvir[\positions] = new;
		msv.valueAction_(synthEnvir[\positions]);
	});

	msv = MultiSliderView().value_(synthEnvir[\positions])
	.elasticMode_(1)
	.showIndex_(true)
	.value_(synthEnvir[\positions])
	.thumbSize_(300/synthEnvir[\positions].size)
	.drawRects_(true)
	.isFilled_(true)
	.action_({arg ctrl;
		synthEnvir[\positions] = ctrl.value;
	});

	view = View().layout_(VLayout(
		HLayout(numpos, rnd),
		msv
	));

	prout = Prout({
		inf.do({arg i;
			var positions = synthEnvir[\positions];
			var num = i.mod(positions.size);
			var pos = positions[num];
			pos.yield;
			{msv.index = num}.defer;
		});
	});
	[view, prout];

}.();

var specs = [
	\atk -> ControlSpec(0, 30, \lin, 0, 0.01),
	\sustain -> ControlSpec(0, 30, \lin, 0, 0.5),
	\rel -> ControlSpec(0, 30, \lin, 0, 0.29),
	\suslevel -> ControlSpec(0, 1, \lin, 0, 0.7),
	\curve -> ControlSpec(-24, 24, \lin, 0, 0),
	\ts -> ControlSpec(0, 100, \lin, 0, 1),
	\rate -> ControlSpec(0.1, 4, \lin, 0, 1),
	\pos -> ControlSpec(0, 1, \lin, 0, 0),
	\rev -> ControlSpec(0, 1, \lin, 0, 0),
	\loop -> ControlSpec(0, 1, \lin, 1, 0),
	\amp -> ControlSpec(0, 10, \lin, 0, 0.3),
	\spread -> ControlSpec(0, 1, \lin, 0, 1),
	\center -> ControlSpec(-1, 1, \lin, 0, 0),
	\pan -> ControlSpec(-1, 1, \lin, 0, 0)
];
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
	Pbind(
		\buf, Pif(Pfunc({synthEnvir[\buf].isNil}), b, Pfunc({synthEnvir[\buf]})),
		\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
		\pos, seqView[1]
	) <> Pdef(\bufplayrbase) <> (evt:synthEnvir, ndef:objName, monitor:monitor)
});

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
	seqView[0]
));

envir[objName] = node;
view;

)

~bufplayr_1[\pos] = 0
~bufplayr_1[\amp] = -3.dbamp
~bufplayr_1[\rel] = 1;
~bufplayr_1[\sustain] = 1;

Pdef(\bufplayrbase).clear;
Pdef(\bufplayr_1).clear;

Pdef(\bufplayr_1).play;
Pdef(\bufplayr_1).stop;


App.saveWorkspace("patches4", rec:true);

~loopr_1[\rev] = 0.5