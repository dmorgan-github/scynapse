(
view: {arg objName, envir, components;

	// Node
	var node = NodeProxy.audio.source_({
		var gate = \gate.kr(0);
		var trig_in = \trig.tr;
		var seq = \seq.kr;//Impulse.kr(1);
		var ptrn = \ptrn.kr(Array.fill(16, 0));
		var pattern = Demand.kr(seq, 0, Dseq(ptrn, inf));
		var changed = seq * (pattern > 0);
		var pos = Latch.kr(pattern, changed);
		var pos_in = \startPos.kr(0).lag(0.001);

		var buf = \buf.kr(0);
		var trig = SelectX.kr(gate, [seq * (pattern > 0), trig_in]);
		var startPos = SelectX.kr(gate, [pos, pos_in]);
		var rate = SelectX.kr(gate, [1, \rate.kr(1)]);
		var sig = PlayBufCF.ar(1, buf.asArray.sum, rate:rate, trigger:trig, startPos: startPos, loop: 1);
		var id = \replyid.kr(0);
		//var env = Env.asr(curve:\lin).kr(gate:trig);

		SendTrig.kr(trig, id, startPos);
		sig = sig * \amp.kr(-6.dbamp);
		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	});
	var replyid = rrand(100, 1000);

	var pauseCursor = false;
	var oscFunc, buf;
	var view = View().layout_(VLayout()).minHeight_(300).minWidth_(800);
	var sfv;
	var buttons = List.new;
	var positions = Array.fill(16, 0);
	var buttonView = View().layout_(HLayout(
		Button().states_([[">>"]])
		.maxWidth_(30)
		.mouseDownAction_({arg ctrl;
			node.set(\seq, 1);
		}).mouseUpAction_({arg ctrl;
			node.set(\seq, 0);
		}),
		*(0..15).collect({arg i;
			var button = Button()
			.states_([[i, Color.white, Color.gray], [i, Color.black, Color.white]])
			.maxWidth_(30)
			.action_({arg ctrl;
				buttons.do({arg button, j;
					if (j != i) {
						button.value_(0)
					};
				});
				if (positions[i].isNil.not) {
					sfv.timeCursorPosition = positions[i];
					node.set(\startPos, positions[i]);
				};
			})
			.mouseUpAction_({arg ctrl, x, y, modifiers;
				if (modifiers.bitAnd(524288) == 524288) {
					positions[i] = sfv.timeCursorPosition;
				};
				node.set(\ptrn, positions.asArray);
			});
			buttons.add(button);
			button;
		});
	));

	var controlsView = {

		var myView = View().layout_(HLayout().margins_(2).spacing_(2));
		var dragSink, button;

		button = Button()
		.fixedSize_(8)
		.states_([ ["x"] ])
		.font_(Font().size_(9))
		.action_({
			dragSink.string = "";
			button.enabled = false;
		})
		.enabled_(false);

		dragSink = DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var bufnum = obj[\bufnum];
			(bufnum.isNil.not);
		})
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var bufnum = obj[\bufnum];
			var name = obj[\name];

			if (bufnum.isNil.not) {

				buf = s.cachedBufferAt(bufnum);
				buf.loadToFloatArray(action:{arg a;
					{
						sfv.setData(a, channels: buf.numChannels);
						sfv.setSelection (0, [0, buf.numFrames]);
						node.set(\buf, buf.bufnum);
						sfv.mouseUpAction.value(sfv);
					}.defer
				});

				v.string = name;
				button.enabled = true;
			} {
				var msg = "bufnum % doesn't exist in environment".format(bufnum);
				NotificationCenter.notify(view, \status, msg);
				button.enabled = false;
			}
		})
		.maxHeight_(35)
		.minWidth_(35);

		myView.layout.add(dragSink, button);
		myView;
	};

	var specs = [
		\seq -> \set,
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var playView = components[\playView].(objName, node, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	node.set(\replyid, replyid);

	sfv = SoundFileView()
	.background_(Color.gray(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.mouseUpAction = ({arg view;
		node.set(\gate, 0);
	});

	sfv.mouseMoveAction = {arg ctrl, x, y;
		var width = ctrl.bounds.width;
		var height = ctrl.bounds.height;
		var pos = x.linlin(0, width, 0, buf.numFrames);
		var rate = y.linlin(0, height, 24, -24).midiratio;
		sfv.timeCursorPosition = pos;
		node.set(\startPos, pos, \gate, 1, \trig, 1, \rate, rate);
	};
	sfv.setSelectionColor(0, Color.blue(alpha:0.5));

	oscFunc = OSCFunc({arg msg, time;
		var pos = msg[3];
		var id = msg[2];
		{
			if (id == replyid) {
				if (pauseCursor.not) {
					sfv.timeCursorPosition = pos;
					positions.do({arg val, i;
						if (val == pos) {
							buttons[i].value_(1);
						} {
							buttons[i].value_(0);
						}
					});
				}
			}
		}.defer;
	},'/tr');

	view.layout.add(playView);
	view.layout.add(controlsView.());
	view.layout.add(buttonView);
	view.layout.add(sfv);
	view.layout.add(specsView);
	view.keyDownAction_({arg ctrl, char, modifiers, unicode, keycode, key;
		if (key == 16777248) {
			pauseCursor = true;
		}
	});
	view.keyUpAction_({arg ctrl, char, modifiers, unicode, keycode, key;
		if (key == 16777248) {
			pauseCursor = false;
		}
	});

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
			oscFunc.free;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)