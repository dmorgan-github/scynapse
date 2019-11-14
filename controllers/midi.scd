

/*
MIDIClient.init;
MIDIClient.initialized
MIDIIn.connectAll;

MIDIIn.disconnectAll;
MIDIClient.sources[1]
MIDIdef.freeAll;


(
MIDIdef.polytouch(\poly, {arg val, vel;
	//[\poly, val, vel].postln;
});
MIDIdef.touch(\touch, {arg val, vel;
	//[\touch, val, vel].postln;
})
)
(
MIDIdef.cc(\cc, {arg a, b, c, d;
	[\cc, a, b, c, d].postln;
});
)

(
//MIDIIn.bend = { arg src, chan, bend;    [chan,bend/8192].postln; }; //pitch bend has a 14 bit range and is a bipolar signal (so bend/8192 will remap the range to -1.0 to 1.0)
MIDIdef.bend(\bend, {arg val, chan, src;
	//var st = val.linlin(6290, 10099, -24, 24);
	[\bend, val, val/8192, chan, src].postln;
})
)

MIDIdef.freeAll;
MIDIIn.disconnectAll;

MIDIIn.disconnect(device:MIDIClient.sources.at(1));
MIDIIn.connect(device:MIDIClient.sources.at(1));

MIDIIn.doNoteOnAction(1, 9, 64, 64); // spoof a note on
MIDIIn.doNoteOffAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doControlAction(1, 1, 1, 64); // spoof a cc
MIDIIn.doControlAction(1, 1, 9, 64);
MIDIIn.doControlAction(1, 10, 1, 64);
*/

/*
(
MIDIdef.noteOn(\noteon_learn, {arg ...args;
	var note = args[1];
	var vel = args[0];
	var chan = args[2];
	[\note, note, \vel, vel, \chan, chan].postln;
})
)
MIDIdef(\noteon_learn).free
*/

//MIDIdef(\midi_1_noteoff).free

(
/*
TODO:
x mute
dynamically add channel
remove mapping
implement velocity
implement cc
don't automatically disconnect
midi out
*/
view: {arg objName, envir, components;

	var defs = List.new;
	var source;
	var view = View().layout_(VLayout().margins_(0).spacing_(0));
	var outerView = View();
	var scrollView = ScrollView();
	var blinkers = (0..16).collect({
		StaticText().string_(" ").fixedSize_(10).background_(Color.clear)
	});

	var notes = (0..16).collect({
		StaticText().string_(" ").background_(Color.clear)
	});

	var asStringWithFrac = {arg float, fracSize = 3;
		var val;
		val = float.round( 10 ** (fracSize.neg) );
		(val.asInt.asString ++ "." ++
			( val.abs.frac* (10**fracSize) ).round(1).asInt.asStringToBase(10,fracSize));
	};

	var channels_mute = Array.fill(16, {0});

	var registerBlinker = {
		var key = (objName ++ '_noteon').asSymbol;
		MIDIdef.noteOn(key, {arg ...args;
			var note = args[1];
			var chan = args[2];
			if (channels_mute[chan] == 0) {
				{
					var msg = "% % % hz".format(note.midiname, note, asStringWithFrac.(note.midicps));
					blinkers[chan].background_(Color.yellow);
					notes[chan].string_(msg);
				}.defer;
			}
		}, srcID: source.uid);
		defs.add(key);

		key = (objName ++ '_noteoff').asSymbol;
		MIDIdef.noteOff(key, {arg ...args;
			var chan = args[2];
			if (channels_mute[chan] == 0) {
				{
					blinkers[0].background_(Color.clear);
					blinkers[chan].background_(Color.clear);
					nil;
				}.defer;
			}
		}, srcID: source.uid);
		defs.add(key);
	};

	var source_list = {
		[""] ++ MIDIClient.sources.collect(_.name);
	};
	var source_list_ctrl = PopUpMenu()
	.items_(source_list.())
	.action_({arg ctrl;
		var val = ctrl.value - 1;
		source = MIDIClient.sources.at(val);
		MIDIIn.connect(device:source);
		registerBlinker.();
	})
	.mouseDownAction_({arg ctrl;
		ctrl.items = source_list.();
	});

	var connectView = View().layout_(HLayout(source_list_ctrl));

	var unregister_note = {arg chan;
		var key = (objName ++ '_' ++ chan ++ '_noteOn').asSymbol;
		MIDIdef(key).free;
		key = (objName ++ '_' ++ chan ++ '_noteOff').asSymbol;
		MIDIdef(key).free;
	};

	var registerNote = {arg chan, noteOn, noteOff;
		var key = (objName ++ '_' ++ chan ++ '_noteOn').asSymbol;
		MIDIdef.noteOn(key, {arg ...args;
			var note = args[1];
			var vel = args[0];
			var chan = args[2];
			if (channels_mute[chan] == 0) {
				noteOn.(note, vel, chan);
			}
		}, chan:chan, srcID: source.uid);
		defs.add(key);

		key = (objName ++ '_' ++ chan ++ '_noteOff').asSymbol;
		MIDIdef.noteOff(key, {arg ...args;
			var note = args[1];
			var vel = args[0];
			var chan = args[2];
			if (channels_mute[chan] == 0) {
				noteOff.(note, chan);
			}
		}, chan:chan, srcID: source.uid);
		defs.add(key);
	};
	var registerCc = {arg chan, name, func, spec;
		var key = (objName ++ '_' ++ chan ++ '_cc').asSymbol;
		MIDIdef.cc(key, {arg val, num, chan, src;
			var myval = val/127;
			myval = spec.map(myval);
			func.(myval);
		}, chan:chan, srcID: source.uid);
		defs.add(key);
	};
	var freedefs = {
		defs.do({arg x;
			x.debug(\free);
			MIDIdef(x).free;
		});
	};

	var map_view = {arg chan;
		var ds = DragSink();
		View().layout_(
			VLayout(
				HLayout(
					StaticText().string_("chan: " ++ chan),
					blinkers[chan],
					notes[chan],
					nil
				).spacing_(5),
				HLayout(
					Button().states_([["M"], ["U"]])
					.fixedWidth_(25)
					.fixedHeight_(15)
					.action_({arg ctrl;
						if (ctrl.value == 1) {
							channels_mute[chan] = 1;
						} {
							channels_mute[chan] = 0;
						}
					}),
					StaticText().string_("note").fixedWidth_(25),
					Button().string_("x").fixedSize_(10).action_({arg ctrl;
						unregister_note.(chan);
						ds.string_("<-  ")
					}),
					ds.string_("<-  ")
					.canReceiveDragHandler_({
						source.isNil.not;
					})
					.receiveDragHandler_({arg v;
						if (source.isNil.not) {
							var obj = View.currentDrag.value;
							var name = obj[\name];
							var noteOn = obj[\noteOn];
							var noteOff = obj[\noteOff];
							registerNote.(chan, noteOn, noteOff);
							v.string_(name);
						}
					})
				),
				HLayout(
					StaticText().string_("cc").fixedWidth_(50).align_(\right),
					Button().string_("x").fixedSize_(10),
					DragSink().string_("<-  ")
					.canReceiveDragHandler_({
						source.isNil.not;
					})
					.receiveDragHandler_({arg v;
						if (source.isNil.not) {
							var obj = View.currentDrag.value;
							var name = obj[\name];
							var func = obj[\cb];
							var spec = obj[\spec];
							registerCc.(chan, name, func, spec);
							v.string_(name);
						}
					})
				)
			).margins_(0).spacing_(1)
		).background_(Color.rand.alpha_(0.2))
	};
	var settings = View().layout_(
		VLayout(
			map_view.(0),
			map_view.(1),
			map_view.(2),
			map_view.(3),
			map_view.(4),
			map_view.(5),
			map_view.(6),
			map_view.(7),
			map_view.(8),
			map_view.(9),
			map_view.(10),
			map_view.(11),
			map_view.(12),
			map_view.(13),
			map_view.(14),
			map_view.(15),
			nil
		)
	);

	view.layout.add(connectView);
	view.layout.add(settings);
	scrollView.canvas = view.background_(Color.clear);

	outerView.layout_(VLayout(scrollView).margins_(0).spacing_(0));

	NotificationCenter.register(outerView, \close, outerView, {arg msg;
		freedefs.();
		if (source.isNil.not) {
			MIDIIn.disconnect(device:source);
		};
		msg.debug("clean up");
	});

	outerView.minWidth_(150);
}
)


