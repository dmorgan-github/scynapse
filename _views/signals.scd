(
view: {arg name, envir, config, components;

	var mainView, horizontalView, controls, eq;

	envir[name] = NodeProxy.audio(s, 2);
	envir[name].fadeTime = 1;
	envir[name][0] = config[\synth];

	mainView = View().layout_(VLayout().margins_(2).spacing_(2));
	controls = components[\specsView].(name, config[\specs], envir[name], envir, mainView);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(controls);

	// main
	mainView.layout.add(horizontalView);

	mainView;
};
)
