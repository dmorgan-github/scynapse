(
view: {arg objName, envir, components;

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var specs;
	var playView, specsView;

	var node = NodeProxy.audio(s, 1).source_({
		var buf = \buf.kr();
		var pos = \pos.kr(0);
		var sig = PlayBufCF.ar(1, buf, rate:\rate.kr(1), trigger:1, startPos:pos, loop:1);
		var env = Env.asr.kr(gate:1);
		sig = sig * env;
		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	});

	specs = [
		\buf -> \set,
		\rate -> [0.1, 4, \lin, 0, 1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	envir[objName] = node;
	playView = components[\playView].(objName, node, view);
	specsView = components[\specsView].(objName, specs, node, envir, view);

	view.layout.add(playView);
	view.layout.add(specsView);
	view;
}
)

