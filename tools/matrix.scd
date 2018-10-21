(

view: {arg objName, envir, util;

	var view = View().layout_(VLayout().margins_(0).spacing_(0));
	var size = 50;
	var keys = Order.new;
	var poll = 20;
	var clock;

	var load = {

		var foo = {
			view.children.do({arg child;
				child.remove();
			});
		}.();

		var header = View().layout_(HLayout(nil, nil).margins_(1).spacing_(1));

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
		view.layout.add(header);

		keys.do({arg rowkey, i;

			var row = View().layout_(HLayout(
				StaticText().string_(rowkey).fixedWidth_(size),
				Slider().fixedHeight_(size).fixedWidth_(size/3).thumbSize_(8).action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,64);
					envir[rowkey].fadeTime = val;
				})
				.value_(envir[rowkey].fadeTime.linlin(0,64,0,1)),
				Slider().fixedHeight_(size).fixedWidth_(size/3).thumbSize_(8).action_({arg ctrl;
					envir[rowkey].vol = ctrl.value;
				})
				.value_(envir[rowkey].vol),
				Button().states_([
					["play", Color.white, Color.grey],
					["stop", Color.white, Color.blue]
				])
				.fixedWidth_(30)
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						envir[rowkey].play(fadeTime:envir[rowkey].fadeTime);
					} {
						envir[rowkey].stop(fadeTime:envir[rowkey].fadeTime);
					}
				})
				.value_(envir[rowkey].isMonitoring.if(1,0)),
			).margins_(1).spacing_(1));

			keys.do({arg colkey, j;
				row.layout.add(
					Slider().orientation_(\vertical)
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
						} {
							[colkey, i].debug("is a function so ignoring");
						}
					})
					.value_(envir[colkey].get(('mix' ++ i).asSymbol))
					.enabled_((envir[colkey][i].class == Function).if(false,true))
				);
			});
			view.layout.add(row);
		});

	};

	load.();

	// how do you stop an app clock?
	AppClock.sched(poll, {
		load.();
		poll;
	});

	view;
}
)