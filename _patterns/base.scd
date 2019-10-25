(
Pdef(\synthpatternbase, {arg evt, ndef, specs, monitor=true;
	var node = Ndef(ndef);
	var myspecs = specs.collect({arg assoc;
		var key = assoc.key;
		var spec = assoc.value;
		if (evt[key].isNil) {
			evt[key] = spec.default;
		};
		[key, Pfunc({evt[key]})]
	}).flatten ++ [\instrument, Pif(Pfunc({evt[\synth].isNil}), \default, Pfunc({evt[\synth]})),
		\out, Pfunc({node.bus.index}),
		\group, Pfunc({node.group})
	];

	if (node.isMonitoring.not and: monitor){
		node.play;
	};

	Penvir(evt,
		Pbind(*myspecs)
	)
});
)