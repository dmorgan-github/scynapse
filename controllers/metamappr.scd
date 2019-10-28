(
view: {arg objName, envir, components;

	var xcolor = Color.rand;
	var ycolor = Color.rand;
	var nodes = Order.new().add([0.5, 0.5]);
	var view, ylayout = VLayout().margins_(0).spacing_(0);
	var xlayout = HLayout().margins_(0).spacing_(0);
	var ymods = Order.new, xmods = Order.new;
	var ev = EnvelopeView()
	.thumbWidth_(60.0)
	.thumbHeight_(15.0)
	.drawLines_(true)
	.drawRects_(true)
	.minWidth_(300)
	.minHeight_(300)
	.selectionColor_(Color.red)
	.value_(nodes.asArray.flop)
	.action_({arg ctrl;
		var node0;
		var vals = ctrl.value.flop;
		nodes.indices.do({arg index, i;
			nodes[index] = vals[i];
		});
		node0 = nodes[0];
		ymods.indices.do({arg index;
			var obj = ymods[index];
			var cb = obj[\cb];
			var min = obj[\min];
			var max = obj[\max];
			var curve = obj[\curve];
			var val = node0 - nodes[index];
			cb.(val[1].linlin(-1, 1, min, max));
		});
		xmods.indices.do({arg index;
			var obj = xmods[index];
			var cb = obj[\cb];
			var min = obj[\min];
			var max = obj[\max];
			var curve = obj[\curve];
			var val = node0 - nodes[index];
			cb.(val[0].linlin(-1, 1, min, max));
		});
	});

	var ctrlView = {arg index, obj, color;

		var view;
		var spec = obj[\spec];

		view = View().layout_(HLayout(
			Button()
			.string_("x")
			.action_({arg ctrl;
				nodes.removeAt(index);
				ev.value = nodes.asArray.flop;
				view.remove;
				if (obj[\axis] == \y) {
					ymods.removeAt(index);
				}{
					xmods.removeAt(index);
				}
			})
			.fixedSize_(25),
			StaticText().string_(obj[\name]),
			nil
		).margins_(0).spacing_(0))
		.background_(color.alpha_(0.2));
		view;
	};

	var addView = {
		var view = View().layout_(HLayout(

			DragSink()
			.string_("<-x  ")
			.background_(Color.clear)
			.canReceiveDragHandler_({
				var obj = View.currentDrag;
				obj[\spec].isNil.not;
			})
			.receiveDragHandler_({arg v;
				var index;
				var obj = View.currentDrag.value;
				var name = obj[\name].value;
				if (obj[\spec].isNil.not) {
					nodes = nodes.add([rrand(0.1, 0.9), rrand(0.1, 0.9)]);
					index = nodes.asArray.size - 1;
					ev.value = nodes.asArray.flop;
					ev.connect(index, [0]);
					obj[\min] = obj[\spec].minval;
					obj[\max] = obj[\spec].maxval;
					obj[\curve] = 0;
					xlayout.add(ctrlView.(index, obj, xcolor));
					xmods.put(index, obj);
					ev.setString(index, name);
					ev.setFillColor(index, xcolor);
				}
			})
			.maxHeight_(35)
			.minWidth_(35),

			DragSink()
			.string_("<-y  ")
			.background_(Color.clear)
			.canReceiveDragHandler_({
				var obj = View.currentDrag;
				obj[\spec].isNil.not;
			})
			.receiveDragHandler_({arg v;
				var index;
				var obj = View.currentDrag.value;
				var name = obj[\name].value;
				if (obj[\spec].isNil.not) {
					nodes = nodes.add([rrand(0.1, 0.9), rrand(0.1, 0.9)]);
					index = nodes.asArray.size - 1;
					ev.value = nodes.asArray.flop;
					ev.connect(index, [0]);
					obj[\min] = obj[\spec].minval;
					obj[\max] = obj[\spec].maxval;
					obj[\curve] = 0;
					ylayout.add(ctrlView.(index, obj, ycolor));
					ymods.put(index, obj);
					ev.setString(index, name);
					ev.setFillColor(index, ycolor);
				}
			})
			.maxHeight_(35)
			.minWidth_(35)
		).margins_(0).spacing_(0));
		view;
	};

	ev.setString(0, "0");
	view = View().layout_(
		VLayout(
			addView.(),
			GridLayout.rows(
				[nil, xlayout],
				[View().layout_(ylayout, nil).maxWidth_(150), ev]
			),
			nil
		)
	);

	view;
}
)



