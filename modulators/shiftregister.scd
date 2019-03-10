(
view: {arg objName, envir, components;

	var num = 5;
	var nodefunc = {arg num = 5;

		{
			var trig = \trig.kr;
			var in = \in.kr;
			var buf = LocalBuf(num);
			var count = PulseCount.kr(trig);

			Demand.kr(trig, 0, Dbufwr(in, buf, count));
			Demand.kr(trig, 0, Dbufrd(buf, count + (1..num))).reverse;
		};
	};

	var specs = [
		\trig -> \set,
		\in -> \set
	];

	var node = NodeProxy.control(s, 5).source_(nodefunc.(num));

	var nodes = (0..(num-1)).collect({arg val;
		NodeProxy.control.source_({node.kr[val]});
	});

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var ctrlView = View().layout_(VLayout(
		*(0..(num-1)).collect({arg val;
			DragSource()
			.background_(Color.clear)
			.object_((node:nodes[val],name:(objName ++ " src " ++ val)))
			.string_("-->")
			.maxWidth_(30)
			.minWidth_(30)
			.align_(\right)
		})
	));

	envir[objName] = node;
	view.layout.add(ctrlView);
	view.layout.add(specsView);

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		nodes.do({arg node;
			node.clear();
			node = nil
		});
	});

	view;

	/*
	view.onClose_({
		envir[objName].clear();
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
			nodes.do({arg node;
				node.clear();
				node = nil
			});
		}.defer();
		NotificationCenter.notify(view, \close, objName);
	});
	*/

}
)