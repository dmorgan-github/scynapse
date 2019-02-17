(
Fdef(\launcher, {arg tracks=8, scenes=8;
	var cols = scenes;
	var rows = tracks;
	var buttons = Array.fill(tracks*cols, {Button()});
	var scenebtns = Array.fill(cols, {Button()});
	var view  = View().layout_(GridLayout.rows(
		*(
			[
				[nil] ++
				(0..cols-1).collect({arg num;
					var text = "scene %".format(num+1);
					scenebtns[num]
					.states_([[text,nil,Color.gray],[text,nil,Color.blue]])
					.action_({arg ctrl;
						buttons.clump(cols).do({arg row;
							if (ctrl.value == 1) {
								scenebtns.do({arg btn;
									if (btn != ctrl) {
										btn.valueAction_(0)
									}
								});
								row[num].valueAction_(1)
							}{
								row[num].valueAction_(0)
							}

						})
					})
				})
			]
			++
			(0..rows-1).collect({arg num;
				[StaticText().string_("track %".format(num+1)).minWidth_(50)] ++
				(0..cols-1).collect({arg i;
					var key = "t%_%".format(num+1,i+1).asSymbol;
					var index = (num * cols) + i;
					var button = buttons[index];
					button
					.states_([[key,nil,Color.gray],[key,nil,Color.blue]])
					.action_({arg ctrl;
						if (ctrl.value == 1) {
							"on".debug(key);
							buttons.clump(cols)[num].do({arg btn;
								if (btn != ctrl) {
									btn.valueAction_(0);
								}
							});
							if (Pdef(key).source.isNil) {
								ctrl.value = 0
							}{
								Pdef(key).play;
							}
						}{
							"off".debug(key);
							Pdef(key).stop;
						}
					})

				});
			})
		)
	));
	view.alwaysOnTop_(true).front;
});
(
view: {
	Fdef(\launcher).();
}
)
)