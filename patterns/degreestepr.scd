//
(
view: {arg objName, envir, components;

	var clock = TempoClock.new(60/60).permanent_(true);
	var view, specsContainerView = View().layout_(VLayout().margins_(0).spacing_(0));
	var rows = 24;
	var cols = 16;
	var black = [1,3,6,8,10];
	var data = rows.collect({ cols.collect({0})});
	var grid, headers;
	var synthEnvir;
	var id;
	var gridlayout;
	var scale = Scale.at(\major);
	var tuning = \et12;

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

	var build_pattern = {arg context;

		var specs;
		var ndef, specsView, synth;
		var synthspecs = context[\specs];
		id = context[\name];
		ndef = id;
		synthEnvir = context[\context];
		synth = synthEnvir[\synth];

		Pdef(\synthbase, {arg evt, ndef, monitor=true;
			var node = Ndef(ndef);
			var myspecs = synthspecs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				if (evt[key].isNil) {
					evt[key] = spec.default;
				};
				[key, Pfunc({evt[key]})]
			}).flatten ++ [\instrument, synth, \out, Pfunc({node.bus.index}), \group, Pfunc({node.group})];
			//if (node.isMonitoring.not and: monitor){
			//	node.play;
			//};
			Penvir(evt,
				Pbind(*myspecs)
			)
		});

		Pdef(id,
			Pbind(
				\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
				\legato, Pif(Pfunc({synthEnvir[\legato].isNil}), 1, Pfunc({synthEnvir[\legato]})),
				\strum, Pif(Pfunc({synthEnvir[\strum].isNil}), 0, Pfunc({synthEnvir[\strum]})),
				\scale, Pif(Pfunc({synthEnvir[\scale].isNil}), Scale.chromatic, Pfunc({synthEnvir[\scale]})),
				\pitch_data, getprout.(),
				\degree, Pkey(\pitch_data),
				\ctranspose, Pif(Pfunc({synthEnvir[\ctranspose].isNil}), 0, Pfunc({synthEnvir[\ctranspose]})),
				\octave, Pif(Pfunc({synthEnvir[\octave].isNil}), 5, Pfunc({synthEnvir[\octave]})),
				\vel, Pif(Pfunc({synthEnvir[\vel].isNil}), 1, Pfunc({synthEnvir[\vel]})),
				\tempo, Pif(Pfunc({synthEnvir[\tempo].isNil}), 1, Pfunc({synthEnvir[\tempo]})),
			) <> Pdef(\synthbase) <> (evt:synthEnvir, ndef:ndef, monitor:true)
		);

		specs = [
			\legato -> ControlSpec(1/16, 64, \lin, 0, 1),
			\strum -> ControlSpec(0, 1, \lin, 0, 0),
			\dur -> ControlSpec(1/16, 64, \lin, 0, 1),
			\octave -> ControlSpec(0, 8, \lin, 1, 4),
			\ctranspose -> ControlSpec(0, 11, \lin, 1, 0),
			\tempo -> ControlSpec(0, 6, \lin, 0, 1),
		];
		specsView = components[\pSpecsView].(objName, specs, synthEnvir, view);
		specsContainerView.removeAll;
		specsContainerView.layout.add(specsView);
	};

	var drag_sink = {
		DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			true;
		})
		.receiveDragHandler_({arg v;
			var obj = View.currentDrag.value;
			build_pattern.(obj);
			v.string_(obj[\name]);
		})
		.maxHeight_(35)
		.minWidth_(35);
	};

	var setscalekeys = {arg scale;
		// there is probably a more elegant way to do this
		var headeroffset = 2;
		var blackkey = Color.grey.alpha_(0.6);
		var degrees = scale.degrees;
		cols.do({arg col;
			// reset all the rows
			(rows).do({arg row;
				var cell = grid[col][row+headeroffset];
				var val = cell.value;
				cell.states_([ [nil, nil, blackkey], [nil, nil, Color.blue] ]);
				cell.value = val;
			});
			// highlight scale degrees
			degrees.do({arg degree;
				var cell = grid[col][rows+headeroffset-1-degree]; //octave 1
				var val = cell.value;
				cell.states_([ [nil, nil, Color.white], [nil, nil, Color.blue] ]);
				cell.value = val;

				cell = grid[col][rows+headeroffset-1-degree-12]; // octave 2
				val = cell.value;
				cell.states_([ [nil, nil, Color.white], [nil, nil, Color.blue] ]);
				cell.value = val;
			});
		});
	};

	var headernum = {arg num;
		StaticText().string_(num).fixedSize_(12);
	};

	var header = {arg num;
		StaticText().string_("").fixedSize_(12).background_(Color.blue.alpha_(0.3));
	};

	var playView = {
		View().layout_(HLayout(
			Button()
			.fixedSize_(15)
			.states_([[">", nil, nil],["[]", nil, nil]])
			.action_({arg ctrl;
				if (id.isNil.not) {
					if (ctrl.value == 1) {
						Pdef(id).play(argClock:clock);
					}{
						Pdef(id).stop;
					}
				}
			})
			.value_(0),
			PopUpMenu()
			.items_([""] ++ Scale.names.select({arg val; (Scale.at(val).pitchesPerOctave == 12.0)}))
			.action_({arg ctrl;
				if (ctrl.item == "") {
					scale = Scale.at(\major);
				}{
					scale = Scale.at(ctrl.item.asSymbol);
				};
				setscalekeys.(scale);
			}),
			PopUpMenu()
			.items_([""] ++ Tuning.names.select({arg val; (Tuning.at(val).size == 12.0)}))
			.action_({arg ctrl;
				if (ctrl.item == "") {
					tuning = \et12;
				}{
					tuning = ctrl.item.asSymbol;
				};
				if (synthEnvir.isNil.not) {
					synthEnvir[\scale] = Scale.chromatic.tuning_(tuning);
				}
			}),
			NumberBox()
			.step_(1)
			.clipLo_(1)
			.clipHi_(128)
			.fixedWidth_(25)
			.normalColor_(Color.white)
			.value_(cols)
			.action_({arg ctrl;

				var num, col, headr, headrnum;
				var newsize = ctrl.value.asInt;

				if (newsize > cols) {

					var diff = newsize - cols;
					diff.do({arg val;

						var num = cols + val;
						// add the header number
						headrnum = headernum.(num+1);
						gridlayout.add(headrnum, 0, num);

						// update the headers
						headr = header.();
						headers = headers.add(headr);
						gridlayout.add(headr, 1, num);

						// update the data for the pattern;
						data = data.collect({arg row;
							row.add(0)
						});

						// update the grid of controls
						// we need this in order to change the colors
						// and to remove them
						grid = grid.add(
							[headrnum] ++
							[headr] ++
							(0..(rows-1)).collect({arg row;
								var myrow = row + 2;
								var mycol = num;
								var btn = Button()
								.fixedSize_(12)
								.states_([ [nil, nil, Color.grey.alpha_(0.6)], [nil, nil, Color.blue] ])
								.action_({arg ctrl;
									data[rows-1-row][mycol] = ctrl.value;
								});
								gridlayout.add(btn, myrow, mycol);
								btn;
							})
						);
					});

					cols = newsize;
					setscalekeys.(scale);
				} {
					var diff;
					data = data.collect({arg val;
						val[0..(newsize-1)];
					});
					diff = cols - newsize;
					diff.do({arg i;
						var num = cols-1-i;
						(rows+2).do({arg j;
							grid[num][j].remove();
						});
					});
					headers = headers[0..(newsize-1)];
					grid = grid[0..(newsize-1)];
					cols = newsize;
				};
			}),
			nil
		));
	};

	var gridView = {

		var view;
		var scrollView = ScrollView();

		var nums = cols.collect({arg col;
			headernum.(col+1);
		});

		headers = cols.collect({arg col;
			header.()
		});

		grid = cols.collect({arg col;
			[nums[col]] ++
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

		gridlayout = GridLayout.columns(*grid).margins_(1).spacing_(1);
		view = View()
		.layout_(gridlayout);

		scrollView.canvas = view;
		scrollView;
	};

	view = View().layout_(VLayout(
		drag_sink.(),
		playView.(),
		HLayout(gridView.(), specsContainerView)
	));

	NotificationCenter.register(view, \close, view, {arg msg;
		if (id.isNil.not) {
			Pdef(id).clear;
		};
		msg.debug("clean up");
	});

	view;
};
)