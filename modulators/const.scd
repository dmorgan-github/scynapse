(
view: {arg objName, envir, components;

	var node = NodeProxy(s, \audio, 1).source_({
		var val = \val.ar.poll;
		val;
	});

	var view = View().layout_(VLayout());

	view.layout.add(NumberBox().action_({arg ctrl;
		node.set(\val, ctrl.value);
	}).normalColor_(Color.white));

	envir[objName] = node;
	view;
}
)