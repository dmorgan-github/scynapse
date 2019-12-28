(
view: {arg objName, envir, components;

	var in_node, node, vstcntrl, view, synth;
	var parentGroup = Group.new(Server.default).debug(\parent);
	var innerGroup = Group.new(parentGroup).debug(\inner);
	var fxGroup;
	var vsts, func;

	SynthDef.new(objName, {
		var in = \in.kr(0);
		var sig = VSTPlugin.ar(input:In.ar(in, 2), numOut:2, id:objName) * \amp.kr(1);
		ReplaceOut.ar(\in.kr(0), sig);
	}).add;

	node = NodeProxy.audio(s, 2);
	node.group_(innerGroup).play;

	func = {arg path;
		var inbus = node.bus;
		fxGroup = Group.new(target:node.group.debug(\node), addAction:\addAfter);

		synth = Synth(objName, [in: inbus], target:fxGroup.debug(\fx), addAction:\addToTail);
		vstcntrl = VSTPluginController(synth, objName);
		vstcntrl.open(path, editor:true);
	};

	vsts = PathName("/Library/Audio/Plug-Ins/VST").entries.collect({arg pn;
		var fp = pn.fullPath.asString;
		var name = fp[0..(fp.size-2)];
		var path = PathName(name).pathOnly;
		name = PathName(name).fileNameWithoutExtension;
		path = path ++ name;
	});

	view = View().layout_(VLayout());
	view.layout.add(PopUpMenu().items_([""] ++ vsts).action_({arg ctrl;
		var item = ctrl.item;
		if (item != "") {
			func.(item);
		}
	}));
	view.layout.add(Button().action_({ vstcntrl.editor; }));
	view.layout.add(Knob().mode_(\vert).action_({arg ctrl; fxGroup.set(\amp, ctrl.value); }).value_(1));
	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		// not sure why this needs to be deferred
		// otherwise it crashes the server
		{
			synth.release;
			synth.free;
			fxGroup.free;
			innerGroup.free;
			parentGroup.free;
		}.defer(2);
	});

	view;
}
)