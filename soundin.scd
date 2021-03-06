(
view: {arg objName, envir, components;

	var view = View().layout_(VLayout());

	var node = NodeProxy.audio(s, 2).source_({
		var sig = SoundIn.ar([0,1]) * \input.ar(0.dbamp);
		sig = sig * \amp.ar(0.dbamp);
		Splay.ar(sig, \spread.ar(1), center:\center.ar(0));
	});

	var specs = [
		\input -> [0, 10, \lin, 0, 1],
		\amp -> [0, 10, \lin, 0, 1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var playView = components[\playView].(objName, node, view);
	envir[objName] = node;
	view.layout.add(StaticText().string_("Sound In").minWidth_(50));
	view.layout.add(playView);
	view.layout.add(specsView);
	view;
}
)

