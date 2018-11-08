(
view: {arg objName, envir, util;

	var view = View().layout_(VLayout());

	var node = NodeProxy.audio(s, 2).source_({
		var sig = InFeedback.ar(\bus.kr(16), 2);
		sig;
	});

	envir[objName] = node;
	view.layout.add(StaticText().string_("In Feedback").minWidth_(50));
	view.layout.add(NumberBox().action_({arg ctrl;
		node.set(\bus, ctrl.value)
	}).normalColor_(Color.white)
	);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)

