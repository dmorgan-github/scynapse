(
var size = 25;
Fdef(\scynapse_matrix, {arg objName, envir, win;

	var load;
	var map = Order.new;
	var slot = 0;
	var proxy = NodeProxy.audio(s, 2);
	var view = View().layout_(VLayout().margins_(1).spacing_(1));
	var slotoffset = 50;

	var dragsink = TextField()
	.background_(Color.grey)
	.canReceiveDragHandler_({
		true;
	})
	.receiveDragHandler_({arg v;
		var obj = View.currentDrag.value;
		var node = obj[\node];
		var name = obj[\name];
		map.put(slot, (name:name, node:node, controls:List.new));
		load.();
		slot = slot + 1;
		dragsink.string_(name);
	})
	.maxHeight_(35)
	.minWidth_(35)
	.action_({arg ctrl;
		var name = ctrl.value.replace($\\, "").asSymbol;
		var node = envir[name];
		if (node.isNil){
			var msg = "node % doesn't exist in environment".format(name);
			NotificationCenter.notify(view, \status, msg);
		} {
			map.put(slot, (name:name, node:node, controls:List.new));
			load.();
			slot = slot + 1;
		}
	});

	var ctrls = View().layout_(GridLayout().margins_(1).spacing_(1));
	var playView = Fdef(\scynapse_components_playview).(objName, proxy, view);
	var size = 30;

	load = {

		var currentSlot = slot;
		var num = map.indices.size;
		var key = map[currentSlot][\name];
		var node = map[currentSlot][\node];
		var controls = map[currentSlot][\controls];
		var issignal = (node[0].class == Function);
		var label = if (key.asString.size > 15) {
			key.asString.split($_).collect({arg val; val[0]}).join("");
		}{
			key;
		};

		var header = StaticText()
		.string_(label)
		.font_(Font(size:8))
		.minWidth_(40)
		.maxWidth_(40);
		var temp, rowheader;

		proxy[slotoffset + currentSlot] = \mix -> {node.ar};
		ctrls.layout.add(header, 0, currentSlot+1, align:\center);
		controls.add(header);

		// add new row
		// row header
		rowheader = View().layout_(HLayout(
			Button()
			.states_([["X"]])
			.action_({
				controls.do({arg ctrl;
					ctrl.remove();
				});
				// remove current node from matrix output
				proxy[slotoffset + currentSlot] = nil;
				map.indicesDo({arg val, key, index;
					if (key == currentSlot) {
						map.removeAtSlot(index);
					};
					// remove current node as source
					// from all fx
					val[\node][currentSlot] = nil;
					// remove sources from current node
					node[key] = nil;
				});
			})
			.fixedSize_(15),
			StaticText().string_(label).font_(Font(size:8)).minWidth_(100),
			Knob()
			.mode_(\vert)
			.action_({arg ctrl;
				var key = ('mix' ++ (slotoffset + currentSlot)).asSymbol;
				proxy.set(key, ctrl.value);
			})
			.value_(1)
			.fixedSize_(size)
		).margins_(1).spacing_(1)).background_(Color.rand.alpha_(0.2));
		ctrls.layout.add(rowheader, currentSlot + 1, 0, align:\left);
		controls.add(rowheader);

		// add row controls
		map.indicesDo({arg valj, keyj, j;

			var disable = ((issignal && (i == j)) || (map[keyj][\node][0].class == Function));
			temp = Knob()
			.fixedSize_(size)
			.mode_(\vert)
			.enabled_(disable == false)
			.action_({arg ctrl;
				// we go from row as input to column
				// node at current column
				var current = map[keyj][\node];
				// node at current row
				var src = map[currentSlot][\node];

				if (ctrl.value > 0) {
					ctrl.background = Color.blue;
				} {
					ctrl.background = Color.grey;
				};

				if (current[currentSlot].isNil) {
					current[currentSlot] = \mix -> {src.ar};
				};
				current.set((\mix ++ currentSlot).asSymbol, ctrl.value);
			});
			// add to current slot row + 1 for header row
			ctrls.layout.add(temp, currentSlot+1, keyj+1);
			// add row controls to previously created columns
			map[keyj][\controls].add(temp);
			// add row controls to current object
			controls.add(temp);
		});

		{
			var width = win.sizeHint.width;
			var height = win.sizeHint.height;
			win.resizeTo(width + size, height);
		}.defer(0.2);

		// add new control to existing columns
		map.indicesDo({arg val, keyi, i;

			if (keyi < currentSlot) {

				temp = Knob()
				.mode_(\vert)
				.fixedSize_(size)
				.enabled_(issignal == false)
				.action_({arg ctrl;

					var current = node;
					var src = map[keyi][\node];

					if (ctrl.value > 0) {
						ctrl.background = Color.blue;
					} {
						ctrl.background = Color.grey;
					};

					if (current[keyi].isNil) {
						current[keyi] = \mix -> {src.ar};
					};
					current.set((\mix ++ keyi).asSymbol, ctrl.value);
				});
				ctrls.layout.add(temp, keyi+1, currentSlot+1);
				map[keyi][\controls].add(temp);
				controls.add(temp);
			}
		});
	};

	view.layout.add(playView);
	view.layout.add(dragsink);
	view.layout.add(ctrls);
	envir[objName] = proxy;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		map.indicesDo({arg vali, keyi, i;
			map.indicesDo({arg valj, keyj, j;
				vali[\node][keyj] = nil;
			});
		});
	});

	view;

});

(
view: Fdef(\scynapse_matrix)
)

)