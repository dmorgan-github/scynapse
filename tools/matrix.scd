(
view: {arg objName, envir, components;

	var load;
	var dict = ();

	var node = NodeProxy.audio(s, 2);

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
		dict[name.asSymbol] = node;
		load.();
	})
	.maxHeight_(35)
	.minWidth_(35);

	var ctrls = View().layout_(VLayout().margins_(0).spacing_(0));
	var playView = components[\playView].(objName, node, view);
	var size = 30;
	var keys = Order.new;

	load = {arg force = false;

		var num = dict.values.select({arg val; val.rate == \audio}).size;

		if (force || (num != keys.size)) {

			var header = View().layout_(HLayout(nil).margins_(1).spacing_(1));

			// this is to ensure the same order
			dict.keysDo({arg k, i;
				var result = keys.select({arg val; val == k});
				if (dict[k].rate == \audio) {
					if (result.size == 0) {
						if (keys.lastIndex.isNil) {
							keys[0] = k;
							node[0] = \mix -> {dict[k].ar};
							node.set('mix0', 1);
						}{
							var index = keys.lastIndex + 1;
							keys[index] = k;
							node[index] = \mix -> {dict[k].ar};
							node.set(('mix' ++ index).asSymbol, 1);
						}
					};
				}
			});

			keys.indices.do({arg i;
				var key = keys[i];
				if (dict[key].isNil) {
					keys.removeAt(i)
				}
			});

			// clear the ui
			ctrls.children.do({arg child;
				child.remove();
			});
			// add header
			keys.do({arg k;
				header.layout.add(StaticText().string_(k.asString[0..3]).fixedWidth_(size).align_(\center));
			});
			ctrls.layout.add(header);

			keys.do({arg rowkey, i;

				var row = View().layout_(HLayout(

					StaticText().string_(rowkey).fixedWidth_(size),

					Knob().mode_(\vert)
					.fixedSize_(size)
					.action_({arg ctrl;
						//dict[rowkey].vol = ctrl.value;
						var key = ('mix' ++ i).asSymbol;
						[key, ctrl.value].postln;
						node.set(key, ctrl.value);
					})
					.value_(node.get(('mix' ++ i).asSymbol)),

					Button()
					.fixedWidth_(size)
					.states_([ ["M", Color.white], ["M", Color.white, Color.new(red:1, green:0.64705882352941, blue:0)] ])
					.action_({arg ctrl;
						if (ctrl.value == 1) {
							dict[rowkey].set(\vol, 0);
						} {
							dict[rowkey].set(\vol, 1);
						}
					})

				).margins_(1).spacing_(1));

				keys.do({arg colkey, j;

					var slider = Knob()
					.mode_(\vert)
					.fixedSize_(size)
					//.thumbSize_(8)
					.action_({arg ctrl;

						if (ctrl.value > 0) {
							ctrl.background = Color.blue;
						} {
							ctrl.background = Color.grey;
						};

						if (dict[colkey][i].class != Function) {
							if (dict[colkey][i] == nil) {
								dict[colkey][i] = \mix -> {dict[rowkey].ar};
							};
							dict[colkey].set(('mix' ++ i).asSymbol, ctrl.value);
						};
					})
					.value_(dict[colkey].get(('mix' ++ i).asSymbol))
					.valueAction_(dict[colkey].get(('mix' ++ i).asSymbol))
					.enabled_((dict[colkey][i].class == Function).if(false,true));

					row.layout.add(slider);
				});
				ctrls.layout.add(row);
			});
		}
	};

	view.layout.add(playView);
	view.layout.add(dragsink);
	view.layout.add(ctrls);

	envir[objName] = node;
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