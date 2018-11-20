(
view: {arg objName, envir, components;

	var numvoices = 2;
	var scalename = \dorian;
	var note = 'C';
	var octave = 5;
	var tuningname = \et12;
	var tunings = Tuning.names.select({arg name; Tuning.at(name).size == 12 });

	var nodefunc = {arg scalename = \dorian, note = 'C', octave = 5, tuningname = \et12;

		var scale = Scale.at(scalename).copy.tuning_(tuningname);
		var root = (note ++ octave).asSymbol.namemidi;

		{
			var buf = scale.degrees.as(LocalBuf);
			var in = \in.kr;
			var degree = root + DegreeToKey.kr(buf, in, scale.pitchesPerOctave);
			degree.midicps;
		};
	};

	var node = NodeProxy.control(s, 1).source_(nodefunc.(scalename, note, octave, tuningname));

	var specs = [
		\in -> [0,24,\lin,0,0]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var ctrlView = View().layout_(HLayout(
		PopUpMenu().items_(Scale.names).action_({arg ctrl;
			scalename = ctrl.item;
			node[0] = nodefunc.(scalename, note, octave, tuningname);
		})
		.value_(Scale.names.indexOf(scalename)),
		PopUpMenu().items_(tunings)
		.action_({arg ctrl;
			tuningname = ctrl.item;
			node[0] = nodefunc.(scalename, note, octave, tuningname);
		})
		.value_(tunings.indexOf(tuningname)),
		PopUpMenu()
		.items_(['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'])
		.action_({arg ctrl;
			note = ctrl.item;
			node[0] = nodefunc.(scalename, note, octave, tuningname);
		})
		.value_(note),
		PopUpMenu().items_((-2..8)).action_({arg ctrl;
			octave = ctrl.item;
			node[0] = nodefunc.(scalename, note, octave, tuningname);
		})
		.value_((-2..8).indexOf(octave))
	));

	envir[objName] = node;
	view.layout.add(ctrlView);
	view.layout.add(specsView);

	view.onClose_({
		envir[objName].clear();
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer();
	});
}
)
