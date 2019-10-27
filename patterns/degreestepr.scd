//
(
view: {arg objName, envir, components;

	var context;
	var contextid;
	var rows = 24;
	var cols = 16;
	var data = rows.collect({ cols.collect({0})});
	var grid, headers;

	var getprout = {
		var prout = Prout({
			var degrees = List.new;
			inf.do({arg i;
				var col = i.mod(cols);
				{
					if (i > 0) {
						var prev = (i-1).mod(cols);
						headers[prev].background_(Color.blue.alpha_(0.3));
					};
					headers[col].background_(Color.white);
				}.defer;
				degrees.do({arg degree;
					degree = degree-23*(-1);
				});
				degrees.clear;
				rows.do({arg row;
					var degree = rows-1-row;
					var cell = data[degree][col];
					if (cell == 1) {
						degrees.add(degree);
					}
				});
				if (degrees.size == 0) {
					Rest().yield;
				} {
					degrees.yield;
				}
			});
		});
		prout
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

	/*
	var playView = View().layout_(HLayout(
		NumberBox()
		.fixedHeight_(15)
		.fixedWidth_(25)
		.stringColor_(Color.white)
		.normalColor_(Color.white)
		.action_({arg ctrl;
			if (context.isNil.not) {
				context[\dur] = ctrl.value;
			}
		})
		.value_(1),
		PopUpMenu()
		.maxHeight_(15)
		.items_(["", 3, 4, 5, 6, 7])
		.action_({arg ctrl;
			if (context.isNil.not){
				if (ctrl.value > 0) {
					context[\octave] = ctrl.item;
				}
			}
		})
		.value_(3),
		nil
	));
	*/

	var gridView = {

		var black = [1,3,6,8,10];
		var view;

		headers = cols.collect({arg col;
			StaticText().string_("").fixedSize_(12).background_(Color.blue.alpha_(0.3));
		});

		grid = cols.collect({arg col;
			[headers[col]] ++
			rows.collect({arg row;
				var color = Color.white;
				var num = rows-1-row;
				if (black.includes(num.mod(12))) {
					color = Color.grey.alpha_(0.6);
				};
				Button()
				.fixedSize_(12)
				.states_([ [nil, nil, color], [nil, nil, Color.blue] ])
				.action_({arg ctrl;
					data[rows-1-row][col] = ctrl.value;
				})
			})
		});

		view = View()
		.layout_(GridLayout.columns(*grid).margins_(1).spacing_(1));
		view;
	};

	var view = View().layout_(VLayout(
		dragsrc.(),
		gridView.()
	));

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
	});

	view;
};
)
