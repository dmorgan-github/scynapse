(
view: {arg objName, envir, components;

	var view = View().layout_(HLayout().spacing_(1).margins_(1));
	var nodes = List.new;

	(0..15).select({arg i; i.even}).do({arg val, i;

		var node = NodeProxy.audio(s, 2).play(out:val);
		var myView = View().layout_(VLayout().spacing_(0).margins_(0));

		var specs = (
			vol: [0,4,\lin,0,1]
		);

		view.layout.add(myView);
		nodes.add(node);
	});

	view;
}
)
//[\view].("", ()).front;


