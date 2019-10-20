{
	var size = 15;
	(
		eqView: {arg name, node, envir, containerView;

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
		},

		specsView: {arg name, specs, node, envir, containerView;

			var ctrlView = {arg key, spec, color;

				var controlSpec = spec;
				var myval = controlSpec.default;
				var stack, view;
				var font = Font(size:10);
				var li = LevelIndicator(bounds:Rect(width:20, height:18)).value_(controlSpec.unmap(myval));
				var labelView = StaticText().string_(key ++ ": ").font_(font).stringColor_(Color.white);
				var st = StaticText().string_(myval).font_(font).stringColor_(Color.white);
				var nb = NumberBox().font_(font).value_(myval).background_(Color.white);

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
							node.set(key, mappedVal);
						}
					})
					.mouseUpAction_({arg ctrl, x, y, mod;
						var val = x.linlin(0, ctrl.bounds.width, 0, 1);
						var mappedVal = controlSpec.map(val);
						if (mod == 0) {
							li.value = val;
							st.string_(mappedVal);
							nb.value = mappedVal;
							node.set(key, mappedVal);
						}
					}),
					nb
					.action_({arg ctrl;
						var val = ctrl.value;
						li.value = controlSpec.unmap(val);
						st.string_(val);
						node.set(key, val);
						stack.index = 0;
					}),
				).mode_(\stackOne)
				.margins_(0)
				.spacing_(0);

				view = View()
				.layout_(stack)
				.mouseDownAction_({arg ctrl, x, y, mod, num, count;
					if (mod == 262144) {
						stack.index = 1;
					}
				})
				.fixedWidth_(150)
				.fixedHeight_(25)
				.background_(Color.red);
				view;
			};

			//var mappers = ();
			var scrollView = ScrollView(bounds:Rect(0,0,160,300));
			var view = View().layout_(VLayout().margins_(0.5).spacing_(0.5))
			.onClose_({
				specs.do({arg assoc;
					var key = assoc.key;
					node.unset(key);
				});
				//mappers.do({arg v;
				//	v.clear;
				//	v = nil;
				//});
			});

			specs.do({arg assoc;
				var k = assoc.key;
				var v = assoc.value;
				var ctrl = ctrlView.(k, v.asSpec, Color.rand);
				view.layout.add(ctrl);
			});

			view.layout.add(nil);
			scrollView.canvas = view;
			scrollView;
		},

		specsView2: {arg name, specs, node, envir, containerView;

			var mappers = ();
			var view = View()
			.layout_(GridLayout().margins_(0).spacing_(0)).background_(Color.grey.alpha_(0.3))
			.onClose_({
				specs.do({arg assoc;
					var key = assoc.key;
					node.unset(key);
				});
				mappers.do({arg v;
					v.clear;
					v = nil;
				});
			});

			specs.do({arg assoc, row;

				var myrow = (row/2).floor.asInt;
				var coloffset = ((row + 4) % 2).asInt * 4;

				var k = assoc.key;
				var v = assoc.value;

				var specKey = k.asSymbol;
				var spec = if (v == \set) {\set} {v.asSpec};

				var layout = view.layout;

				var numberbox = NumberBox()
				.decimals_(3)
				.fixedHeight_(size)
				.fixedWidth_(30)
				.font_(Font(size:8));

				var rs = Knob()
				.mode_(\vert)
				.enabled_(false)
				.fixedSize_(size);

				var slider;
				var stack = StackLayout(

					slider = Slider()
					.orientation_(\horizontal)
					.fixedHeight_(size)
					.minWidth_(60)
					.thumbSize_(7)
					.background_(Color.white.alpha_(0)),

					StaticText()
					.string_(k)
					.align_(\center)
					.font_(Font(size:8, bold:true))
					.stringColor_(Color.white)
				)
				.mode_(\stackAll);

				var height = 20;

				if (specs.size < 4) {
					myrow = row;
					coloffset = 0;
				};

				if (mappers[k].isNil) {
					mappers[k] = NodeProxy(s, \audio);
				};

				if (spec == \set) {

				} {
					mappers[k][0] = {
						var center = \center.kr(0);
						var depth = \depth.kr(1);
						var min = (center + (depth * center).neg);
						var max = (center + (depth * center));
						\val.ar.linlin(-1, 1, min, max).round(spec.step).clip(spec.minval, spec.maxval);//.poll(0.5, name);
					};
					mappers[k].set(
						\val, spec.default.linlin(spec.minval, spec.maxval, -1, 1),
						\center, spec.default,
						\depth, 0
					);
					node.set(k, mappers[k]);
				};

				if (spec == \buf) {
				} {
					var dragSink = UserView()
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
						(node.rate == \control);
					})
					.receiveDragHandler_({arg v;

						var obj = View.currentDrag.value;
						var lfo = obj[\node];
						var name = obj[\name];
						var color = obj[\color];

						if (lfo.isNil.not) {
							rs.enabled_(true);
							if (spec == \set) {
								node.set(specKey, lfo);
							} {
								mappers[k].set(\val, lfo);
							};

							if (color.isNil) {
								color = Color.gray;
							};

							dragSink.drawFunc_({
								var size = 10;
								var width = 1;
								Pen.color = color;
								Pen.width = width;
								Pen.fillOval(Rect(2,3,size,size))
							});
							dragSink.refresh;

						} {
							var msg = "node % doesn't exist in environment".format(name);
							NotificationCenter.notify(containerView, \status, msg);
						}
					})
					.fixedWidth_(size);

					dragSink.setContextMenuActions(
						MenuAction(specKey, {specKey.postln}),
						MenuAction("Delete", {

							rs.enabled_(false);
							if (spec == \set) {
								node.set(specKey, nil);
							} {
								mappers[k].set(\val, spec.map(slider.value).linlin(spec.minval, spec.maxval,-1,1));
							};

							dragSink.drawFunc_({
								var size = 10;
								var width = 1;
								Pen.color = Color.black;
								Pen.width = width;
								Pen.strokeOval(Rect(2,3,size,size))
							})
							.refresh;
						});
					);

					layout.add(dragSink, myrow, coloffset);
				};

				///////////////////////////////////
				if (spec != \set) {

					slider.action = {arg ctrl;
						var msg;
						var val = spec.map(ctrl.value);
						msg = k ++ " " ++ val;
						mappers[k].set(\center, val);
						numberbox.value_(val);
						NotificationCenter.notify(containerView, \status, msg);
					};
					slider.value = spec.unmap(spec.default);

					layout.add(
						rs.action_({arg ctrl;
							var val = ctrl.value;
							var msg = "depth: " ++ val;
							mappers[k].set(\depth, val);
							NotificationCenter.notify(containerView, \status, msg);
						}), myrow, coloffset + 1
					);

					layout.add(
						stack, myrow, coloffset + 2
					);

					layout.add(
						numberbox
						.action_({arg ctrl;
							var ctrlval = ctrl.value;
							var val = spec.unmap(ctrlval);
							mappers[k].set(\val, ctrlval.linlin(spec.minval, spec.maxval, -1, 1));
							slider.valueAction_(val);
						})
						.clipLo_(spec.minval)
						.clipHi_(spec.maxval)
						.normalColor_(Color.white)
						.value_(spec.default), myrow, coloffset + 3
					);
				};
			});

			view;
		},

		playView: {arg name, node, containerView;

			var height = 20;
			var wetKey = ("wet" ++ 100).asSymbol;
			var view = View().layout_(HLayout().margins_(1).spacing_(1));
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

			/*
			view.layout.add(
				Knob()
				.fixedSize_(size)
				.mode_(\vert)
				.value_(1)
				.action_({arg ctrl;
					node.set(wetKey, ctrl.value);
					NotificationCenter.notify(containerView, \status, "wet: " ++ ctrl.value.asString);
				})
			);
			*/

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
						node.play(fadeTime:node.fadeTime);
					} {
						node.stop(fadeTime:node.fadeTime);
					}
				})
			);

			/*
			view.layout.add(
				Button()
				.fixedSize_(size)
				.states_([ ["M", Color.white], ["M", Color.white, Color.new(red:1, green:0.64705882352941, blue:0)] ])
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						node.set(\vol, 0);
					} {
						node.set(\vol, 1);
					}
				})
			);
			*/

			/*
			view.layout.add(
				Button()
				.fixedHeight_(size)
				.fixedWidth_(size*3)
				.states_([ ["scope"] ])
				.action_({arg ctrl;
					node.scope;
				})
			);
			*/

			view.layout.add(nil);

			view;
		},

		multiInputsView: {arg node, mainView;

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
		}

	);

}.();
