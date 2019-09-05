(
view: {arg objName, envir, components;

	var node = NodeProxy.audio(s, 1).filter(100, {arg in;

		var buf = LocalBuf(s.sampleRate * 4, 1).clear;

		var foo = {

			var rec = \rec.kr(0);
			var renv = Env.asr.kr(gate:rec);
			var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);

			RecordBuf.ar(in,
				buf,
				recLevel:renv,
				preLevel:penv,
				run:rec,
				loop:\rec_loop.kr(0),
				trigger:\rec_trig.kr(1)
			);
		}.();

		var trig = \trig.tr;
		var pos = \pos.kr(0);
		var graindur = \graindur.kr(0.5);
		var rate = \rate.kr(1);
		var envbuf = \envbuf.kr(-1).lag(0.01);
		var pan = \pan.kr(0);
		var grainamp = \grainamp.kr(1);
		var loop = \loop.kr(0);

		var amp = Dwhite(grainamp.clip(0,1), 1, inf);
		var panValue = Dwhite(pan.neg, pan, inf);
		var reverse = \reverse.kr(0);
		var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

		var sig = GrainBufJ.ar(2,
			trig,
			dur: graindur,
			sndbuf: buf,
			rate: rate * rev,
			pos: pos,
			loop: loop,
			interp: 4,
			grainAmp: amp,
			pan: panValue,
			envbufnum: envbuf
		);

		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	});

	var specs = [
		\trig -> \set,
		\pos -> [0,1,\lin,0,0],
		\graindur -> [0,2,\lin,0,0.5],
		\rate -> [0,4,\lin,0,1],
		\pan -> [0,1,\lin,0,0],
		\grainamp -> [0,1,\lin,0,1],
		\loop -> [0,1,\lin,1,0],
		\reverse -> [0,1,\lin,0,0],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var buttonsView = View().layout_(HLayout(
		Button().states_([["o"], ["||"]]).action_({arg ctrl;
			if (ctrl.value == 1) {
				node.set(\rec_trig, 1, \rec, 1, \plevel, 0);
			} {
				node.set(\rec_trig, 0, \rec, 0, \plevel, 0);
			}
		}),
		Button().states_([["^"], ["||"]]).action_({arg ctrl;
			if (ctrl.value == 1) {
				node.set(\rec_trig, 1, \rec, 1, \plevel, 1);
			} {
				node.set(\rec_trig, 0, \rec, 0);
			}
		}),
	).margins_(2).spacing_(2));

	view.layout.add(buttonsView);
	view.layout.add(specsView);

	envir[objName] = node;
	view;
};

)

