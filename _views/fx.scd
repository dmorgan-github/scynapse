(
view: {arg name, envir, config;

	var view, horizontalView, inputs, controls, eq;
	var height = 20;
	var filterSlot = 100;
	var func = {

		var func = config[\synth];
		if ( func.argNames[0] == \self ) {
			func = config[\synth].value(config);
		};
		func;
	};

	envir[name] = NodeProxy.audio(s, 2);
	envir[name].fadeTime = 1;

	config[\init].value(config);
	envir[name][filterSlot] = \filter -> func.value;
	view = View().layout_(VLayout().margins_(2).spacing_(2));
	controls = Fdef(\scynapse_components_specsview).(name, config[\specs], envir[name], envir, view);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(controls);

	// main
	view.layout.add(horizontalView);

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		config[\destroy].value(config);
	});

	view;
};
)
