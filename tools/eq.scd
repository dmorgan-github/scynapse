(
view: {arg objName, envir, components;

	var proxy = NodeProxy.audio(s, 2);
	var view = View().layout_(VLayout().margins_(1).spacing_(1));
	var eqView = components[\eqView].(objName, proxy, view);
	view.layout.add(eqView);
	envir[objName] = proxy;
	view;
}
)