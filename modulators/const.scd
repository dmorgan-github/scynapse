(
view: {arg objName, envir, util;

	var node = NodeProxy(s, \control, 1).source_({
		var val = \val.kr;
		val;
	});

	var view = View().layout_(VLayout());

	view.layout.add(NumberBox().action_({arg ctrl;
		node.set(\val, ctrl.value);
	}).normalColor_(Color.white));

	envir[objName] = node;
	view.onClose_({
		envir[objName].clear();
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer();
	});
}
)