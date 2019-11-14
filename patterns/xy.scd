(

view: {arg objName, envir, components;

	//var clock = TempoClock.new(60/60).permanent_(true);
	var specsContainerView = View().layout_(VLayout().margins_(0).spacing_(0));
	var view = View().layout_(VLayout());
	var gridlayout;
	var gridctrls;
	var rows = 4;
	var cols = 4;
	var data = rows.collect({ cols.collect({  rrand(0, 12) } )});
	var scale = Scale.at(\major), tuning = \et12;
	var synthEnvir;
	var id;

	var nb = {
		NumberBox()
		.step_(1)
		.fixedSize_(25)
		.normalColor_(Color.grey);
	};

	var rnd = {
		if (0.3.coin) {
			99
		}{
			linrand(12)
		}
	};

	var gridView = {
		var view = View();
		gridctrls = rows.collect({arg row;
			cols.collect({arg col;
				nb.().action_({arg ctrl;
					data[row][col] = ctrl.value;
				}).value_(data[row][col])
			});
		});

		gridlayout = GridLayout.rows(*gridctrls);
		view.layout = gridlayout;
		view;
	};

	var addrow = {arg num;

		if (num > rows) {
			var diff = num - rows;
			diff.do({arg val;
				var current = rows+val;
				var newrow = cols.collect({arg col;
					nb.()
					.value_(0)
					.action_({arg ctrl;
						data[current][col] = ctrl.value;
					});
				});
				// update controls so we can remove later
				gridctrls = gridctrls.add(newrow);
				// update data for pattern
				data = data.add(cols.collect({0}));
				// update display
				newrow.do({arg btn, i;
					gridlayout.add(btn.valueAction_(rnd.()), current, i);
				});
			});
		}{
			var diff = rows - num;
			// update data for pattern
			data = data[0..(num-1)];

			// update the display by removing
			// the controls
			diff.do({arg i;
				var toremove = rows-1-i;
				gridctrls[toremove].do({arg cell;
					cell.remove();
				});
			});
			// update the grid of controls
			gridctrls = gridctrls[0..(num-1)];
		};
		rows = num;
		gridctrls.do({arg row;
			row.do({arg cell;
				cell
				.background_(Color.black)
				.normalColor_(Color.grey)
			});
		});
		//[gridctrls.shape, data.shape, rows, cols].postln;
	};

	var addcol = {arg num;

		if (num > cols) {
			var diff = num - cols;
			// update the grid of controls so we can remove them
			gridctrls = gridctrls.collect({arg row, i;
				diff.do({arg val;
					var current = cols+val;
					var btn = nb.()
					.action_({arg ctrl;
						data[i][current] = ctrl.value;
					});
					row = row.add(btn);
					// update the display
					gridlayout.add(btn, i, current);
				});
				row;
			});

			// update data for pattern
			// and update the value for the control
			data = data.collect({arg row, i;
				diff.do({arg j;
					var current = cols+j;
					var val = rnd.();
					row = row.add(val);
					gridctrls[i][current].value_(val);
				});
				row;
			});
		}{
			var diff = cols - num;
			// update data for pattern
			data = data.collect({arg row;
				row[0..(num-1)]
			});

			// update the list of controls
			gridctrls = gridctrls.collect({arg row;
				diff.do({arg i;
					var toremove = cols-1-i;
					// update the display
					row[toremove].remove();
				});
				row[0..(num-1)]
			});
		};
		cols = num;
		gridctrls.do({arg row;
			row.do({arg cell;
				cell
				.background_(Color.black)
				.normalColor_(Color.grey)
			});
		});
		//[gridctrls.shape, data.shape, rows, cols].postln;
	};

	var ctrlsView = {
		var view = View().layout_(HLayout(

			Button()
			.fixedSize_(15)
			.states_([[">", nil, nil],["[]", nil, nil]])
			.action_({arg ctrl;
				if (id.isNil.not) {
					if (ctrl.value == 1) {
						Pdef(id).play();
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
					scale = Scale.at(\major).copy.tuning_(tuning)
				}{
					scale = Scale.at(ctrl.item.asSymbol).copy.tuning_(tuning)
				};
				if (synthEnvir.isNil.not) {
					synthEnvir[\scale] = scale;
				}
			}),
			PopUpMenu()
			.items_([""] ++ Tuning.names.select({arg val; (Tuning.at(val).size == 12.0)}))
			.action_({arg ctrl;
				if (ctrl.item == "") {
					tuning = \et12;
				}{
					tuning = ctrl.item.asSymbol;
				};
				scale = scale.copy.tuning_(tuning);
				if (synthEnvir.isNil.not) {
					synthEnvir[\scale] = scale;
				}
			}),
			NumberBox()
			.step_(1)
			.clipLo_(1)
			.clipHi_(64)
			.value_(rows)
			.action_({arg ctrl;
				var num = ctrl.value.asInt;
				addrow.(num);
			})
			.normalColor_(Color.grey),
			NumberBox()
			.step_(1)
			.clipLo_(1)
			.clipHi_(64)
			.value_(cols)
			.action_({arg ctrl;
				var num = ctrl.value.asInt;
				addcol.(num);
			})
			.normalColor_(Color.grey),
			Button()
			.string_("rnd")
			.action_({arg ctrl;
				var shape = data.shape;
				shape[0].do({arg row;
					shape[1].do({arg col;
						var val = rnd.();
						gridctrls[row][col].valueAction_(val);
					});
				});
			})
			.maxWidth_(30)
		));
		view;
	};

	var build_pattern = {arg context;

		var prev;
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

			if (node.isMonitoring.not and: monitor){
				node.play;
			};
			Penvir(evt,
				Pbind(*myspecs)
			)
		});

		Pdef(id,
			Pbindef((id ++ '_set').asSymbol, \vel, 1) <>
			Pbind(
				\dur, Pif(Pfunc({synthEnvir[\dur].isNil}), 1, Pfunc({synthEnvir[\dur]})),
				\legato, Pif(Pfunc({synthEnvir[\legato].isNil}), 1, Pfunc({synthEnvir[\legato]})),
				\scale, Pif(Pfunc({synthEnvir[\scale].isNil}), Scale.chromatic, Pfunc({synthEnvir[\scale]})),
				\xstep, Pif(Pfunc({synthEnvir[\xstep].isNil}), 1, Pfunc({synthEnvir[\xstep]})),
				\ystep, Pif(Pfunc({synthEnvir[\ystep].isNil}), 1, Pfunc({synthEnvir[\ystep]})),
				\xdir, Pif(Pfunc({synthEnvir[\xdir].isNil}), 1, Pfunc({synthEnvir[\xdir]})),
				\ydir, Pif(Pfunc({synthEnvir[\ydir].isNil}), 1, Pfunc({synthEnvir[\ydir]})),
				\xrepeat, Pif(Pfunc({synthEnvir[\xrepeat].isNil}), 1, Pfunc({synthEnvir[\xrepeat]})),
				\yrepeat, Pif(Pfunc({synthEnvir[\yrepeat].isNil}), 1, Pfunc({synthEnvir[\yrepeat]})),
				\x, Pseries(0, Pkey(\xstep) * Pif(Pfunc({arg evt; evt[\xdir] == 2}), -1, 1)).stutter(Pkey(\xrepeat)),
				\y, Pseries(0, Pkey(\ystep) * Pif(Pfunc({arg evt; evt[\ydir] == 2}), -1, 1)).stutter(Pkey(\yrepeat)),
				\pitch_data, Pfunc({arg evt;
					var shape = data.shape;
					var y = evt[\y].mod(shape[0]);
					var x = evt[\x].mod(shape[1]);
					var val = data[y][x];
					if (val == 99) {
						val = Rest()
					};

					{
						if (prev.isNil.not) {
							if (prev.isClosed.not) {
								prev
								.background_(Color.white)
								.normalColor_(Color.black);
							}
						};
						if (gridctrls[y][x].isNil.not) {
							prev = gridctrls[y][x]
							.background_(Color.blue.alpha_(0.2))
							.normalColor_(Color.white);
						}
					}.defer;

					val;
				}),
				\degree, Pkey(\pitch_data),
				\ctranspose, Pif(Pfunc({synthEnvir[\ctranspose].isNil}), 0, Pfunc({synthEnvir[\ctranspose]})),
				\mtranspose, Pif(Pfunc({synthEnvir[\mtranspose].isNil}), 0, Pfunc({synthEnvir[\mtranspose]})),
				\octave, Pif(Pfunc({synthEnvir[\octave].isNil}), 5, Pfunc({synthEnvir[\octave]})),
				//\vel, Pif(Pfunc({synthEnvir[\vel].isNil}), 1, Pfunc({synthEnvir[\vel]})),
				//\tempo, Pif(Pfunc({synthEnvir[\tempo].isNil}), 1, Pfunc({synthEnvir[\tempo]})),
			) <> Pdef(\synthbase) <> (evt:synthEnvir, ndef:ndef, monitor:true)
		);

		specs = [
			\xstep -> ControlSpec(1, 5, \lin, 1, 1),
			\ystep -> ControlSpec(1, 5, \lin, 1, 1),
			\xdir -> ControlSpec(1, 2, \lin, 1, 1),
			\ydir -> ControlSpec(1, 2, \lin, 1, 1),
			\xrepeat -> ControlSpec(1, 8, \lin, 1, 1),
			\yrepeat -> ControlSpec(1, 8, \lin, 1, 1),
			\legato -> ControlSpec(1/16, 64, \lin, 0, 1),
			\dur -> ControlSpec(1/16, 64, \lin, 0, 1),
			\octave -> ControlSpec(0, 8, \lin, 1, 4),
			\ctranspose -> ControlSpec(0, 11, \lin, 1, 0),
			\mtranspose -> ControlSpec(0, 11, \lin, 1, 0),
			//\tempo -> ControlSpec(0, 6, \lin, 0, 1),
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

	NotificationCenter.register(view, \close, view, {arg msg;
		if (id.isNil.not) {
			Pdef(id).stop;
			Pdef(id).clear;
			Pdef((id ++ '_set').asSymbol).stop;
			Pdef((id ++ '_set').asSymbol).clear;
		};
		//clock.free;
		msg.debug("clean up");
	});

	view.layout.add(drag_sink.());
	view.layout.add(ctrlsView.());
	view.layout.add(HLayout(gridView.(), nil, specsContainerView));
	view;
}
)


