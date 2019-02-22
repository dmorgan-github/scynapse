(
view: {arg objName, envir, components;

	var load;
	var dict = List.new;
	var proxy = NodeProxy.audio(s, 2);

	var view = View().layout_(VLayout().margins_(0).spacing_(0)).minWidth_(200);

	var dragsink = DragSink()
	.string_("<-  ")
	.background_(Color.clear)
	.canReceiveDragHandler_({
		true;
	})
	.receiveDragHandler_({arg v;
		var obj = View.currentDrag.value;
		var node = obj[\node];
		var name = obj[\name];
		dict.add( (name:name, node:node) );
		load.();
	})
	.maxHeight_(35)
	.minWidth_(35);

	var ctrls = View().layout_(GridLayout().margins_(0).spacing_(0));
	var playView = components[\playView].(objName, proxy, view);
	var eqView = components[\eqView].(objName, proxy, envir, view);

	var size = 30;
	var keys = Order.new;

	load = {arg force = false;

		var num = dict.size;
		var key = dict[num-1][\name];
		var node = dict[num-1][\node];
		var issignal = (node[0].class == Function);

		proxy[num] = \mix -> {node.ar};
		ctrls.layout.add(StaticText().string_(key).font_(Font(size:8)), 0, num, align:\center);
		num.do({arg i;
			var row = i + 1;
			if (row == (num)) {
				// we're in the new row so add all columns
				var rowheader = View().layout_(HLayout(
					StaticText().string_(key + i).font_(Font(size:8)),
					Knob().action_({arg ctrl;
						var key = ('mix' ++ num).asSymbol;
						proxy.set(key, ctrl.value);
					})
					.value_(1)
					.fixedSize_(25)
				));
				ctrls.layout.add(rowheader, num, 0);
				num.do({arg j;
					var disable = ((issignal && (i == j)) || (dict[j][\node][0].class == Function));
					ctrls.layout.add(
						Knob()
						.fixedSize_(40)
						.mode_(\vert)
						.enabled_(disable == false)
						.action_({arg ctrl;
							// we go from row as input to column

							// node at current column
							var current = dict[j][\node];
							// node at current row
							var src = dict[i][\node];

							if (ctrl.value > 0) {
								ctrl.background = Color.blue;
							} {
								ctrl.background = Color.grey;
							};

							if (current[i].isNil) {
								current[i] = \mix -> {src.ar};
							};
							current.set((\mix ++ i).asSymbol, ctrl.value);

						}),
						num, j+1);
				});
			} {
				// we're in a previously created row so just add new col
				ctrls.layout.add(
					Knob()
					.mode_(\vert)
					.fixedSize_(40)
					.enabled_(issignal == false)
					.action_({arg ctrl;

						var current = node;
						var src = dict[i][\node];

						if (ctrl.value > 0) {
							ctrl.background = Color.blue;
						} {
							ctrl.background = Color.grey;
						};

						if (current[i].isNil) {
							current[i] = \mix -> {src.ar};
						};
						current.set((\mix ++ i).asSymbol, ctrl.value);
					}),
					row, num);
			}
		});
	};

	view.layout.add(playView);
	view.layout.add(eqView);
	view.layout.add(dragsink);
	view.layout.add(ctrls);

	envir[objName] = proxy;
	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});

	view;
}
)