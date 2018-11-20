{
	(
		eqView: {arg name, node, envir, containerView;

			var view = View().layout_(VLayout().spacing_(2).margins_(2)).background_(Color.grey.alpha_(0.6));
			var userview = UserView().minHeight_(100);
			var lofreq = 339;
			var hifreq = 4000;
			var minfreq = 20;
			var maxfreq = 11000;
			var mindb = -60;
			var maxdb = 18;
			var midfreq = (lofreq+hifreq)/2;
			var stack, fsv;

			node.filter(110, {arg in;

				var sig = in;

				var lo_freq = \lo_freq.kr(100).lag(0.2);
				var lo_db = \lo_db.kr(0).lag(0.2);

				var mid_freq = \mid_freq.kr(1000).lag(0.2);
				var mid_db = \mid_db.kr(0).lag(0.2);

				var hi_freq = \hi_freq.kr(10000).lag(0.2);
				var hi_db = \hi_db.kr(0).lag(0.2);

				sig = BPeakEQ.ar(sig, lo_freq, 1, lo_db);
				sig = BPeakEQ.ar(sig, mid_freq, 1, mid_db);
				sig = BPeakEQ.ar(sig, hi_freq, 1, hi_db);
				sig = RemoveBadValues.ar(sig);
				sig;

			}).set(\wet110, 0);

			userview.drawFunc = {arg ctrl;

				var width = ctrl.bounds.width;
				var height = ctrl.bounds.height;

				var lowxpos = lofreq.explin(minfreq,maxfreq,0,width);
				var hixpos = hifreq.explin(minfreq,maxfreq,0,width);

				Pen.strokeColor = Color.red;
				Pen.moveTo(lowxpos@0);
				Pen.lineTo(lowxpos@height);
				Pen.fillStroke;

				Pen.strokeColor = Color.blue;
				Pen.moveTo(hixpos@0);
				Pen.lineTo(hixpos@height);
				Pen.fillStroke;
			};

			stack = StackLayout(
				userview,
				fsv = FreqScopeView()
				.active_(true)
				.freqMode_(1)
				.inBus_(node.bus.index)
			).mode_(1);
			view.layout.add(stack);
			view.layout.add(HLayout(

				RoundButton()
				.extrude_(true)
				.border_(1)
				.states_([
					['power', Color.gray(0.2), Color.white(0.75).alpha_(0.25)],
					['power', Color.red(0.8), Color.white(0.75).alpha_(0.25)]])
				.action_({arg bt;
					switch(bt.value,
					1, { node.set(\wet110, 1) },
					0, { node.set(\wet110, 0) });
				})
				.fixedSize_(17)
				.value_(0),

				Knob().action_({arg ctrl;
					var val = ctrl.value;
					var msg = "lo db " ++ val.linlin(0,1,mindb,maxdb);
					node.set(\lo_db, val.linlin(0,1,mindb,maxdb));
					NotificationCenter.notify(containerView, \status, msg);
				})
				.fixedSize_(30)
				.mode_(\vert)
				.value_(0.linlin(mindb,maxdb,0,1)),

				Knob().action_({arg ctrl;
					var val = ctrl.value;
					var msg = "mid db " ++ val.linlin(0,1,mindb,maxdb);
					node.set(\mid_db, val.linlin(0,1,mindb,maxdb));
					NotificationCenter.notify(containerView, \status, msg);
				})
				.fixedSize_(30)
				.mode_(\vert)
				.value_(0.linlin(mindb,maxdb,0,1)),

				Knob().action_({arg ctrl;
					var val = ctrl.value;
					var msg = "hi db " ++ val.linlin(0,1,mindb,maxdb);
					node.set(\hi_db, val.linlin(0,1,mindb,maxdb));
					NotificationCenter.notify(containerView, \status, msg);
				})
				.fixedSize_(30)
				.mode_(\vert)
				.value_(0.linlin(mindb,maxdb,0,1))
			));

			view.layout.add(HLayout(
				NumberBox().action_({arg ctrl;

					lofreq = ctrl.value;
					midfreq = (lofreq+hifreq)/2;

					node.set(\lo_freq, lofreq);
					node.set(\mid_freq, midfreq);

					userview.refresh;
				})
				.value_(lofreq)
				.normalColor_(Color.white)
				.maxWidth_(50)
				.clipLo_(minfreq)
				.clipHi_(maxfreq),

				NumberBox().action_({arg ctrl;

					hifreq = ctrl.value;
					midfreq = (lofreq+hifreq)/2;

					node.set(\hi_freq, hifreq);
					node.set(\mid_freq, midfreq);

					userview.refresh;
				})
				.value_(hifreq)
				.normalColor_(Color.white)
				.maxWidth_(50)
				.align_(\right)
				.clipLo_(minfreq)
				.clipHi_(maxfreq),
			));

			view.onClose_({
				["eqView", fsv].debug("close ");
				fsv.kill;
			});

			view;
		},

		specsView: {arg name, specs, node, envir, containerView;

			var mappers = ();
			var view = View()
			.layout_(GridLayout().margins_(4).spacing_(4)).background_(Color.grey.alpha_(0.3))
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
				var coloffset = ((row + 5) % 2).asInt * 5;

				var k = assoc.key;
				var v = assoc.value;

				var specKey = k.asSymbol;
				var spec = if (v == \set) {\set} {v.asSpec};

				var layout = view.layout;

				var rs = Knob()
				.mode_(\vert)
				.enabled_(false)
				.fixedSize_(25);

				var slider = Knob()
				.mode_(\vert)
				.enabled_(true)
				.fixedSize_(25);

				var numberbox = NumberBox();
				var height = 20;

				if (specs.size < 4) {
					myrow = row;
					coloffset = 0;
				};

				if (mappers[k].isNil) {
					mappers[k] = NodeProxy();
				};

				if (spec == \set) {

				} {
					mappers[k][0] = {
						var center = \center.kr(0);
						var depth = \depth.kr(1);
						var min = (center + (depth * center).neg);
						var max = (center + (depth * center));
						\val.kr.range(min, max).round(spec.step).clip(spec.minval, spec.maxval);
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
						var size = 13;
						var width = 2;
						Pen.color = Color.black;
						Pen.width = width;
						Pen.strokeOval(Rect(0,5,size,size))
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

							if (color.isNil.not) {
								dragSink.drawFunc_({
									var size = 13;
									var width = 1;
									Pen.color = color;
									Pen.width = width;
									Pen.fillOval(Rect(0,5,size,size))
								});
								dragSink.refresh;
							}
						} {
							var msg = "node % doesn't exist in environment".format(name);
							NotificationCenter.notify(containerView, \status, msg);
						}
					})
					.fixedWidth_(15);

					dragSink.setContextMenuActions(
						MenuAction("Delete", {

							rs.enabled_(false);
							if (spec == \set) {
								node.set(specKey, nil);
							} {
								mappers[k].set(\val, spec.map(slider.value).linlin(spec.minval, spec.maxval,-1,1));
							};

							dragSink.drawFunc_({
								var size = 13;
								var width = 2;
								Pen.color = Color.black;
								Pen.width = width;
								Pen.strokeOval(Rect(0,5,size,size))
							})
							.refresh;
						});
					);

					//[myrow, coloffset].postln;
					layout.add(StaticText().string_(k).maxWidth_(50), myrow, coloffset + 0);
					layout.add(dragSink, myrow, coloffset + 1);
				};

				///////////////////////////////////
				if (spec != \set) {
					layout.add(
						rs.action_({arg ctrl;
							var val = ctrl.value;
							var msg = "depth: " ++ val;
							mappers[k].set(\depth, val);
							NotificationCenter.notify(containerView, \status, msg);
						}), myrow, coloffset + 2
					);

					layout.add(
						slider
						.action_({arg ctrl;
							var msg;
							var val = spec.map(ctrl.value);
							msg = k ++ " " ++ val;
							mappers[k].set(\center, val);
							numberbox.value_(val);
							NotificationCenter.notify(containerView, \status, msg);
						})
						.value_(spec.unmap(spec.default)), myrow, coloffset + 3
					);

					layout.add(
						numberbox
						.fixedWidth_(40)
						.action_({arg ctrl;
							var ctrlval = ctrl.value;
							var val = spec.unmap(ctrlval);
							mappers[k].set(\val, ctrlval.linlin(spec.minval, spec.maxval, -1, 1));
							slider.valueAction_(val);
						})
						.clipLo_(spec.minval)
						.clipHi_(spec.maxval)
						.normalColor_(Color.white)
						.value_(spec.default), myrow, coloffset + 4
					);
				};
			});

			view;
		},

		playView: {arg name, node, containerView;

			var height = 20;
			var wetKey = ("wet" ++ 100).asSymbol;
			var view = View().layout_(HLayout().margins_(4).spacing_(4));
			var outBus = 0;
			var privateBus = node.bus.index;

			view.layout.add(
				Knob()
				.fixedSize_(25)
				.mode_(\vert)
				.value_(1.linlin(0,4,0,1))
				.action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,4);
					NotificationCenter.notify(containerView, \status, "vol: " ++ val.asString);
					node.vol = val;
				})
			);

			view.layout.add(
				Knob()
				.fixedSize_(25)
				.mode_(\vert)
				.value_(1)
				.action_({arg ctrl;
					node.set(wetKey, ctrl.value);
					NotificationCenter.notify(containerView, \status, "wet: " ++ ctrl.value.asString);
				})
			);

			view.layout.add(
				NumberBox()
				.fixedSize_(30@height)
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
				.fixedSize_(30@height)
				.states_([ [">", Color.white], ["[]", Color.white, Color.blue] ])
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						node.play(fadeTime:node.fadeTime);
					} {
						node.stop(fadeTime:node.fadeTime);
					}
				})
			);

			view.layout.add(
				Button()
				.fixedSize_(30@height)
				.states_([ ["M", Color.white], ["M", Color.white, Color.new(red:1, green:0.64705882352941, blue:0)] ])
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						node.set(\vol, 0);
					} {
						node.set(\vol, 1);
					}
				})
			);

			view.layout.add(
				Button()
				.fixedSize_(30@height)
				.states_([ ["sc"] ])
				.action_({arg ctrl;
					node.scope;
				})
			);

			view.layout.add(nil);

			view;
		},

		multiInputsView: {arg node, mainView;

			var view = View().layout_(VLayout().spacing_(1).margins_(1));

			var addRow = {

				var row = View().layout_(HLayout().spacing_(1).margins_(1));
				var dragSink;
				var num = -1;
				var name;


				dragSink = UserView()
				.drawFunc_({
					var size = 13;
					var width = 2;
					Pen.color = Color.black;
					Pen.width = width;
					Pen.strokeOval(Rect(0,5,size,size))
				})
				.canReceiveDragHandler_({
					var obj = View.currentDrag;
					var node = obj[\node];
					(node.rate == \audio);
				})
				.fixedWidth_(15)
				.receiveDragHandler_({arg v;

					var obj = View.currentDrag.value;
					var input = obj[\node];
					var color = obj[\color];
					var msg;

					name = obj[\name];
					msg = "inuput: " ++ name;

					if (num < 0) {
						num = node.objects.indices.select({arg val; val < 100}).last ? num;
						num = num + 1;
					};

					node[num] = \mix -> { input.ar; };
					if (color.isNil.not) {
						dragSink.drawFunc_({
							var size = 13;
							var width = 1;
							Pen.color = color;
							Pen.width = width;
							Pen.fillOval(Rect(0,5,size,size))
						});
						dragSink.refresh;
					};
					//node[num].set(('mix' ++ num).asSymbol, 1);
					NotificationCenter.notify(mainView, \status, msg);
				})
				.fixedHeight_(20)
				.minWidth_(100); // width gets jacked up

				row.layout.add(dragSink);

				row.layout.add(

					LevelIndicator(bounds:Rect(width:50, height:18))
					.style_(\led)
					.meterColor_(Color.blue().alpha_(1))
					.warningColor_(Color.blue().alpha_(1))
					.criticalColor_(Color.blue().alpha_(1))
					.numSteps_(10)
					.minWidth_(150)
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
				}).fixedSize_(20));

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

				}).fixedSize_(20));
				view.layout.add(row);
			};
			addRow.();
			view;
		}

	);//[\playView].( \bobo, (), View()).front;

}.();
