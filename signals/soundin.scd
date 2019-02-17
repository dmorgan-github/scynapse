(
view: {arg objName, envir, components;

	var view = View().layout_(VLayout());

	var node = NodeProxy.audio(s, 2).source_({
		var sig = SoundIn.ar([0,1]) * \input.kr(0.dbamp);
		sig = sig * \amp.kr(0.dbamp);
		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	});

	var specs = [
		\input -> [0, 10, \lin, 0, 1],
		\amp -> [0, 10, \lin, 0, 1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var playView = components[\playView].(objName, node, view);
	var eqView = components[\eqView].(objName, node, envir, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);

	envir[objName] = node;
	view.layout.add(StaticText().string_("Sound In").minWidth_(50));
	view.layout.add(playView);
	view.layout.add(eqView);
	view.layout.add(specsView);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)

