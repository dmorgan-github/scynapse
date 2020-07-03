(
var size = 15;

Fdef(\scynapse_components_ctrlview, {arg key, spec, color, envir=(), cb={};

	var controlSpec = spec;
	var myval = envir[key] ?? controlSpec.default;

	var stack, view;
	var font = Font(size:8);
	var li = LevelIndicator().value_(controlSpec.unmap(myval));
	var labelView = StaticText().string_(key ++ ": ").font_(font).stringColor_(Color.white);
	var st = StaticText().string_(myval).font_(font).stringColor_(Color.white);
	var nb = NumberBox()
	.font_(font)
	.value_(myval)
	.background_(Color.white)
	.minDecimals_(3)
	.clipLo_(controlSpec.minval)
	.clipHi_(controlSpec.maxval);
	var dragsrc;

	envir[key] = myval;
	stack = StackLayout(
		View()
		.layout_(
			StackLayout(
				View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
				li
				.style_(\continuous)
				.meterColor_(color.alpha_(0.5))
				.warningColor_(color.alpha_(0.5))
				.criticalColor_(color.alpha_(0.5))
				.background_(color.alpha_(0.2))
			)
			.mode_(\stackAll)
			.margins_(0)
			.spacing_(0)
		)
		.mouseMoveAction_({arg ctrl, x, y, mod;
			var val = x.linlin(0, ctrl.bounds.width, 0, 1);
			var mappedVal = controlSpec.map(val);
			if (mod == 0) {
				li.value = val;
				st.string_(mappedVal);
				nb.value = mappedVal;
				envir[key] = mappedVal;
				cb.(key, mappedVal);
			};
		})
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			var val = controlSpec.default;
			if (count == 2) {
				li.value = controlSpec.unmap(val);
				st.string_(val);
				nb.value = val;
				envir[key] = val;
				cb.(key, val);
			} {
				if (mod == 0) {
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					li.value = val;
					st.string_(mappedVal);
					nb.value = mappedVal;
					envir[key] = mappedVal;
					cb.(key, mappedVal);
				};
			};
		}),
		nb
		.action_({arg ctrl;
			var val = ctrl.value;
			li.value = controlSpec.unmap(val);
			st.string_(val);
			envir[key] = val;
			cb.(key, val);
			stack.index = 0;
		}),
	).mode_(\stackOne)
	.margins_(0)
	.spacing_(0);

	dragsrc = {
		var obj = (
			name: key,
			cb:{arg val;
				envir[key] = val;
				cb.(key, val);
				{
					li.value = controlSpec.unmap(val);
					st.string_(val)
				}.defer;
			},
			spec:spec
		);

		DragSource()
		.background_(Color.clear)
		.object_(obj)
		.string_("-->")
		.fixedWidth_(25)
	};

	view = View().layout_(HLayout(
		View()
		.layout_(stack)
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			if (mod == 262144) {
				stack.index = 1;
			}
		}).fixedHeight_(25),
		dragsrc.(),
	).margins_(0).spacing_(1));

	view;

});

Fdef(\scynapse_components_eqview, {arg name, node, envir, containerView;

	var view = View()
	.layout_(VLayout().spacing_(1).margins_(1))
	.background_(Color.grey.alpha_(0.6));
	var userview = UserView();
	var lofreq = 339;
	var hifreq = 4000;
	var minfreq = 20;
	var maxfreq = 11000;
	var mindb = -60;
	var maxdb = 18;
	var midfreq = (lofreq+hifreq)/2;
	var stack, fsv;

	view.layout.add(
		StackLayout(
			ChannelEQ(numChannels:2, bus:node.bus.index, target:node.group)
			.gui.window.view.minHeight_(350/1.6).minWidth_(505/1.5).background_(Color.white.alpha_(0.5)),

			fsv = FreqScopeView()
			.active_(true)
			.freqMode_(1)
			.inBus_(node.bus.index)
		)
		.mode_(1)

	);

	view.onClose_({
		["eqView", fsv].debug("close ");
		fsv.kill;
	});

	view;

});

Fdef(\scynapse_components_specsview, {arg name, specs, node, envir, containerView;

	var ctrlView = Fdef(\scynapse_components_ctrlview);
	var scrollView = ScrollView(bounds:Rect(0,0,160,300));
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2))
	.onClose_({
		specs.do({arg assoc;
			var key = assoc.key;
			node.unset(key);
		});
	});
	var cb = {arg key, val;
		node.set(key, val)
	};

	// TODO: need to do something with this
	var moduleEnvir = ();

	specs.do({arg assoc;
		var k = assoc.key;
		var v = assoc.value;
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, moduleEnvir, cb);
		view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	scrollView;
});

Fdef(\scynapse_components_pspecsview, {arg name, specs, envir, containerView;

	var ctrlView = Fdef(\scynapse_components_ctrlview);
	var scrollView = ScrollView();
	var view = View().layout_(VLayout().margins_(0.5).spacing_(0.5));

	specs.do({arg assoc;
		var k = assoc.key;
		var v = assoc.value;
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, envir);
		view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	scrollView;
});

Fdef(\scynapse_components_playview, {arg name, node, containerView;

	var height = 20;
	var view = View().layout_(HLayout().margins_(1).spacing_(1)).background_(Color.rand.alpha_(0.2));
	var outBus = 0;
	var privateBus = node.bus.index;

	view.layout.add(
		Knob()
		.fixedSize_(size)
		.mode_(\vert)
		.value_(1.linlin(0,4,0,1))
		.action_({arg ctrl;
			var val = ctrl.value.linlin(0,1,0,4);
			NotificationCenter.notify(containerView, \status, "vol: " ++ val.asString);
			node.vol = val;
		})
	);

	view.layout.add(
		NumberBox()
		.fixedSize_(size)
		.alt_scale_(0.01)
		.ctrl_scale_(0.1)
		.shift_scale_(1)
		.value_(1)
		.normalColor_(Color.grey)
		.action_({arg ctrl;
			var val = ctrl.value;
			node.fadeTime = val;
			NotificationCenter.notify(containerView, \status, "fadetime: " ++ val.asString);
		})
	);

	view.layout.add(
		Button()
		.fixedSize_(size)
		.states_([ [nil, Color.green, Color.green], [nil, Color.red, Color.red] ])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				node.play(fadeTime:node.fadeTime, out:outBus);
			} {
				node.stop(fadeTime:node.fadeTime);
			}
		})
	);

	view.layout.add(
		NumberBox()
		.fixedSize_(size)
		.value_(0)
		.action_({arg ctrl;
			var val = ctrl.value;
			outBus = val;
			NotificationCenter.notify(containerView, \status, "out: " ++ val.asString);
		})
		.normalColor_(Color.grey)
		.value_(0);
	);

	view.layout.add(nil);
	view;
});

Fdef(\scynapse_components_multiinputsview, {arg node, mainView;

	var view = View().layout_(VLayout().spacing_(1).margins_(1));

	var addRow = {

		var menuaction = MenuAction();
		var row = View().layout_(HLayout().spacing_(1).margins_(1));
		var dragSink;
		var num = -1;
		var name = "";

		dragSink = UserView()
		.drawFunc_({
			var size = 10;
			var width = 1;
			Pen.color = Color.black;
			Pen.width = width;
			Pen.strokeOval(Rect(2,3,size,size))
		})
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var node = obj[\node];
			(node.rate == \audio);
		})
		.fixedWidth_(size)
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var input = obj[\node];
			var color = obj[\color];
			var msg;

			name = obj[\name];
			msg = "inuput: " ++ name;

			menuaction.string = name;

			if (num < 0) {
				num = node.objects.indices.select({arg val; val < 100}).last ? num;
				num = num + 1;
			};

			node[num] = \mix -> { input.ar; };
			if (color.isNil) {
				color = Color.gray;
			};

			dragSink.drawFunc_({
				var size = 10;
				var width = 1;
				Pen.color = color;
				Pen.width = width;
				Pen.fillOval(Rect(2,2,size,size))
			});
			dragSink.refresh;

			NotificationCenter.notify(mainView, \status, msg);
		})
		.fixedHeight_(size);

		dragSink.setContextMenuActions(
			menuaction
		);

		row.layout.add(dragSink);

		row.layout.add(

			LevelIndicator(bounds:Rect(width:20, height:18))
			.style_(\led)
			.meterColor_(Color.blue().alpha_(1))
			.warningColor_(Color.blue().alpha_(1))
			.criticalColor_(Color.blue().alpha_(1))
			.numSteps_(10)
			.fixedHeight_(15)
			.mouseMoveAction_({arg ctrl, x, y, modifiers;
				var val = x.linlin(0, ctrl.bounds.width, 0, 1);
				var msg = "";
				if (num >= 0) {
					var key = ('mix' ++ num).asSymbol;
					node.set(key, val);
					msg = "mix % %".format(name, val);
					ctrl.value = val;
					NotificationCenter.notify(mainView, \status, msg);
				}
			})
			.mouseUpAction_({arg ctrl, x, y, modifiers;
				var val = x.linlin(0, ctrl.bounds.width, 0, 1);
				var msg = "";
				if (num >= 0) {
					var key = ('mix' ++ num).asSymbol;
					node.set(key, val);
					msg = "mix % %".format(name, val);
					ctrl.value = val;
					NotificationCenter.notify(mainView, \status, msg);
				}
			})
			.value_(1)
		);

		row.layout.add(Button().string_("+").action_({
			addRow.();
		}).fixedSize_(size));

		row.layout.add(Button().string_("-").action_({

			row.remove();
			if (num >= 0) {

				var msg = "remove %".format(name);
				node[num] = nil;
				NotificationCenter.notify(mainView, \status, msg);
			};

			if (view.children.size == 0) {
				addRow.();
			};

			{
				var sizeHint = view.sizeHint;
				view.resizeTo(sizeHint.width, sizeHint.height)
			}.defer(0.001)

		}).fixedSize_(size));
		view.layout.add(row);
	};
	addRow.();
	view;
});

(
eqView: Fdef(\scynapse_components_eqview),
specsView: Fdef(\scynapse_components_specsview),
pSpecsView: Fdef(\scynapse_components_pspecsview),
playView: Fdef(\scynapse_components_playview),
multiInputsView: Fdef(\scynapse_components_multiinputsview)
)

)

