(
view: {arg objName, envir, components;

	var view = View().layout_(VLayout());

	var node = NodeProxy.audio(s, 2).source_({
		var sig = SoundIn.ar([0,1]);
		sig;
	});

	var playView = components[\playView].(objName, node, view);
	var eqView = components[\eqView].(objName, node, envir, view);

	envir[objName] = node;
	view.layout.add(StaticText().string_("Sound In").minWidth_(50));
	view.layout.add(playView);
	view.layout.add(eqView);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)

