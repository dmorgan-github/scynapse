(
view: {arg name, envir;

	var view = View().layout_(VLayout().margins_(0).spacing_(0))
	.minWidth_(400)
	.minHeight_(245);

	var nodeX = NodeProxy.control.source_({
		var val = \val.kr(0);
		val;
	});

	var nodeY = NodeProxy.control.source_({
		var val = \val.kr(0);
		val;
	});

	view.layout.add(
		HLayout(nil,
			DragSource()
			.background_(Color.clear)
			.object_((node:nodeX,name:name))
			.string_("X-->")
			.maxWidth_(30)
			.minWidth_(30)
			.align_(\right),

			DragSource()
			.background_(Color.clear)
			.object_((node:nodeY,name:name))
			.string_("Y-->")
			.maxWidth_(30)
			.minWidth_(30)
			.align_(\right)
		)
	);

	view.layout.add(Slider2D().action_({arg ctrl;
		nodeX.set(\val, ctrl.x.linlin(0,1,-1,1));
		nodeY.set(\val, ctrl.y.linlin(0,1,-1,1));
		NotificationCenter.notify(view, \status, "x: " ++ ctrl.x ++ " y: " ++ ctrl.y);
	}));

	view.onClose_({
		"destroy".debug("xy");
		[nodeX, nodeY].do({arg node;
			node.clear;
			node.free;
			node = nil;
		});
	});
}
)
//[\view].("", ()).front;


