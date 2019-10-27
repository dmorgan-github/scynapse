(
view: {arg objName, envir, components;

	var msv;

	var positions = [0.5, 0.5, 0.5, 0.5];

	var getprout = {
		Prout({
			inf.do({arg i;
				var num = i.mod(positions.size);
				var pos = positions[num];
				pos.yield;
				{msv.index = num}.defer;
			});
		});
	};

	var dragsrc = {
		var prout = getprout.();
		var obj = (
			name:objName,
			type:\data,
			dur:1,
			pattern:prout
		);

		DragSource()
		.background_(Color.clear)
		.object_(obj)
		.string_("-->")
		.fixedWidth_(25)
	};

	var seqView = {

		var view, numpos, rnd;

		msv = MultiSliderView().value_(positions)
		.elasticMode_(1)
		.showIndex_(true)
		.value_(positions)
		.thumbSize_(300/positions.size)
		.drawRects_(true)
		.isFilled_(true)
		.action_({arg ctrl;
			positions = ctrl.value;
		});

		numpos = NumberBox()
		.normalColor_(Color.white)
		.minWidth_(25)
		.value_(positions.size)
		.action_({arg ctrl;
			var newsize = ctrl.value;
			if (newsize > positions.size) {
				var size = newsize - positions.size;
				var newvals = Array.fill(size, {0.0});
				positions = positions ++ newvals;
			}{
				positions = positions[0..(newsize.asInt-1)];
			};
			msv.value_(positions);
		});

		rnd = Button().action_({arg ctrl;
			var new = Array.fill(positions.size, {rrand(0.0, 1.0)});
			positions = new;
			msv.valueAction_(positions);
		});

		view = View().layout_(VLayout(
			HLayout(numpos, rnd),
			msv
		));

		view;
	};

	var view = View().layout_(VLayout(
		dragsrc.(),
		seqView.()
	));
	view;
}
)



