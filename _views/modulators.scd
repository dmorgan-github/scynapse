(
view: {arg name, envir, config

	var view, subview, presets;
	var height = 20;

	envir[name] = NodeProxy.audio(s, 1);
	envir[name].fadeTime = 1;
	envir[name][0] = config[\synth];

	view = View().layout_(VLayout().margins_(2).spacing_(2)).minWidth_(150);
	subview = Fdef(\scynapse_components_specsview).(name, config[\specs], envir[name], envir, view);
	view.layout.add(subview);

	view;
};
)

