(
view: {arg name, envir, config, util;

	var view, subview, presets, inputs;
	var height = 20;
	var filterSlot = 100;

	var func = {
		var func = config[\func];
		if ( func.argNames[0] == \self ) {
			func = config[\func].value(config);
		};
		func;
	};

	envir[name] = NodeProxy.control;
	envir[name].fadeTime = 1;
	envir[name][filterSlot] = \filter -> func.value;

	view = View().layout_(VLayout().margins_(2).spacing_(2)).minWidth_(250)
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
		"destroy: ".debug(name);
	});

	inputs = util[\multiInputsView].(envir[name], view);
	subview = util[\specsView].(name, config[\specs], envir[name], envir, view);
	view.layout.add(inputs);
	view.layout.add(subview);

	view;
};
)

