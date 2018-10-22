(
view: {arg objName, envir, util;

	// this is to handle the presets
	var presets = Order.new;
	var controls = List.new;
	var previous = 0;
	var currentState = {arg preset;

		// save state to current hilighted preset
		// before changing to new selected preset
		var obj = ();
		controls.do({arg ctrl, i;
			obj[ctrl.identityHash] = (ctrl:ctrl, val:ctrl.value)
		});
		presets[previous] = obj;

		if (presets[preset].isNil.not) {
			var obj = presets[preset];
			obj.keysValuesDo({arg k, v;
				v[\ctrl].valueAction_(v[\val]);
			});
		};
		previous = preset;
	};
	var view = View().layout_(VLayout().margins_(0).spacing_(0));
	var presetsView = View().layout_(HLayout(
		*(0..7).collect({arg i;
			var button = Button()
			.states_([["", Color.gray, Color.gray],["", Color.white, Color.white]])
			.fixedSize_(20).action_({arg ctrl;
				//buttons.do({arg button, j;
				//	if (j != i) {
				//		button.value = 0;
				//	}
				//});
				ctrl.states_([["", Color.white, Color.white]]);
				currentState.(i);
			});
			if (i == 0) {
				button.states_([["", Color.white, Color.white]])
			};
			//buttons.add(button);
			button;
		});
	));

	var ctrls = View().layout_(VLayout().margins_(0).spacing_(0));
	var size = 50;
	var keys = Order.new;
	var poll = 5;
	var clock;

	var load = {

		var foo = {
			ctrls.children.do({arg child;
				child.remove();
			});
		}.();

		var header = View().layout_(HLayout(nil, nil).margins_(1).spacing_(1));

		// this is to ensure the same order
		envir.keysDo({arg k, i;
			var result = keys.select({arg val; val == k});
			if (envir[k].rate == \audio) {
				if (result.size == 0) {
					if (keys.lastIndex.isNil) {
						keys[0] = k
					}{
						keys[keys.lastIndex + 1] = k;
					}
				};
			}
		});

		keys.indices.do({arg i;
			var key = keys[i];
			if (envir[key].isNil) {
				keys[i] = nil;
			}
		});

		keys.do({arg k;
			header.layout.add(StaticText().string_(k).fixedWidth_(size).align_(\center));
		});
		ctrls.layout.add(header);

		keys.do({arg rowkey, i;

			var slider1, slider2, button1;
			var row = View().layout_(HLayout(

				StaticText().string_(rowkey).fixedWidth_(size),

				slider1 = Slider().fixedHeight_(size).fixedWidth_(size/3).thumbSize_(8).action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,64);
					envir[rowkey].fadeTime = val;
				})
				.value_(envir[rowkey].fadeTime.linlin(0,64,0,1)),

				slider2 = Slider().fixedHeight_(size).fixedWidth_(size/3).thumbSize_(8).action_({arg ctrl;
					envir[rowkey].vol = ctrl.value;
				})
				.value_(envir[rowkey].vol),

				button1 = Button().states_([
					["play", Color.white, Color.grey],
					["stop", Color.white, Color.blue]
				])
				.fixedWidth_(30)
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						envir[rowkey].play(fadeTime:envir[rowkey].fadeTime);
					} {
						envir[rowkey].stop(fadeTime:envir[rowkey].fadeTime);
					};
				})
				.value_(envir[rowkey].isMonitoring.if(1,0))
				.valueAction_(envir[rowkey].isMonitoring.if(1,0))
			).margins_(1).spacing_(1));

			controls.add(slider1);
			controls.add(slider2);
			controls.add(button1);

			keys.do({arg colkey, j;

				var slider = Slider()
				.orientation_(\vertical)
				.fixedSize_(size)
				.thumbSize_(8)
				.action_({arg ctrl;

					if (ctrl.value > 0) {
						ctrl.background = Color.blue;
					} {
						ctrl.background = Color.grey;
					};

					if (envir[colkey][i].class != Function) {
						if (envir[colkey][i] == nil) {
							envir[colkey][i] = \mix -> {envir[rowkey].ar};
						};
						envir[colkey].set(('mix' ++ i).asSymbol, ctrl.value);
					};
				})
				.value_(envir[colkey].get(('mix' ++ i).asSymbol))
				.valueAction_(envir[colkey].get(('mix' ++ i).asSymbol))
				.enabled_((envir[colkey][i].class == Function).if(false,true));

				row.layout.add(slider);
				controls.add(slider);
			});
			ctrls.layout.add(row);
		});

	};

	load.();

	// how do you stop an app clock?
	//AppClock.sched(poll, {
	//	load.();
	//	poll;
	//});

	view.layout.add(presetsView);
	view.layout.add(ctrls);
	view;
}
)
