(
view: {arg name, envir, config, components;

	var mainView, horizontalView, inputs, controls, eq;

	envir[name] = NodeProxy.audio(s, 2);
	envir[name].fadeTime = 1;
	envir[name][0] = config[\synth];

	mainView = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear(envir[name].fadeTime);
		{
			"destroy: ".debug(name);
			config[\destroy].value(config);
			envir[name] = nil;
		}.defer(envir[name].fadeTime + 1);
	});

	eq = components[\eqView].(name, envir[name], envir, mainView;);
	controls = components[\specsView].(name, config[\specs], envir[name], envir, mainView);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(controls);

	// main
	mainView.layout.add(components[\playView].(name, envir[name], mainView));
	mainView.layout.add(eq);
	mainView.layout.add(horizontalView);

	mainView;
};
)
