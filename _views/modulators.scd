(
view: {arg name, envir, config, util;

	var view, subview, presets;
	var height = 20;

	envir[name] = NodeProxy.control;
	envir[name].fadeTime = 1;
	envir[name][0] = config[\synth];

	view = View().layout_(VLayout().margins_(2).spacing_(2)).minWidth_(300)
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
		"destroy: ".debug(name);
	});

	subview = util[\specsView].(name, config[\specs], envir[name], envir, view);
	view.layout.add(subview);

	view;
};
)

