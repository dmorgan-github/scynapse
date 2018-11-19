(
view: {arg objName, envir, util;

	var sendbus = Bus.alloc(\audio, s, 2);

	var sendnode = NodeProxy.audio(s, 2).source_({
		var sig = InFeedback.ar(sendbus, 2);
		sig;
	});

	var node = NodeProxy.audio(s, 2)
	.filter(100, {arg in;
		var sig = in;
		var fb = DelayC.ar(LocalIn.ar(2), 1, \delay.kr(0)) * \fb.kr(0.1);
		ReplaceOut.ar(sendbus, fb);
		fb = InFeedback.ar(\return.kr(18), 2);
		LocalOut.ar((fb + sig).tanh);
		sig = (sig + fb);
		Splay.ar(sig, \spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
	});

	var specs = [
		\fb -> [0, 1, \lin, 0, 0.1],
		\delay -> [0, 1, \lin, 0, 0],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0],
		\amp -> [0,1,\lin,0,1]
	];

	var dragsink;
	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = util[\playView].(objName, node, view);
	var multiInputsView = util[\multiInputsView].(node, view);
	var specsView = util[\specsView].(objName, specs, node, envir, view);
	var eqView = util[\eqView].(objName, node, envir, view);
	var ctrlView = View().layout_(HLayout(

		DragSource()
		.background_(Color.clear)
		.object_((node:sendnode,name:"send: " ++ objName))
		.string_("-->")
		.align_(\right),

		DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var node = obj[\node];
			(node.rate == \audio);
		})
		.receiveDragHandler_({arg ctrl;
			var obj = View.currentDrag.value;
			var proxy = obj[\node];
			var name = obj[\name];
			node.set(\return, proxy.bus.index);
			ctrl.string_(name)
		})
	));

	envir[objName] = node;
	//view.layout.add(StaticText().string_(sendbus.index));
	view.layout.add(playView);
	view.layout.add(multiInputsView);
	view.layout.add(eqView);
	view.layout.add(ctrlView);
	view.layout.add(specsView);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
			sendbus.free;
		}.defer(envir[objName].fadeTime + 1);
	});

}
)