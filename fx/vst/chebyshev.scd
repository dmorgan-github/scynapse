(
view: {arg objName, envir, components;

	var in_node, node, vstcntrl, view, synth;

	SynthDef.new(objName, {
		var in = \in.kr(0);
		ReplaceOut.ar(\in.kr(0), VSTPlugin.ar(In.ar(in, 2), 2));
	}).add;

	node = NodeProxy.audio(s, 2);
	//node = NodeProxy.audio(s, 2);

	{
		var inbus = node.bus;
		var group = node.group;
		//var outbus = node.bus;
		synth = Synth(objName, [in: inbus], target:group, addAction:\addAfter);
		vstcntrl = VSTPluginController(synth);
		vstcntrl.open("/Library/Audio/Plug-Ins/VST/++chebyshev");
	}.defer(2);

	view = View().layout_(VLayout());
	view.layout.add(Button().action_({ vstcntrl.gui; }));
	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		// not sure why this needs to be deferred
		// otherwise it crashes the server
		{
			synth.release;
			synth.free;
		}.defer(2);
	});

	view;
}
)