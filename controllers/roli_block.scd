

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

(
view: {arg objName, envir, components;

	var defs = List.new;
	var source;
	var view = View().layout_(VLayout());
	var connectView = View().layout_(HLayout(
		PopUpMenu()
		.items_([""] ++ MIDIClient.sources.collect(_.name))
		.action_({arg ctrl;
			var val = ctrl.value - 1;
			source = MIDIClient.sources.at(val);
			MIDIIn.connect(device:source);
		})
	));
	var registerNote = {arg chan, noteOn, noteOff;
		var chanlabel = chan ?? "all";
		var key = (objName ++ '_' ++ chanlabel ++ '_noteOn').asSymbol;
		MIDIdef.noteOn(key, {arg ...args;
			var note = args[1];
			var vel = args[0];
			var chan = args[2];
			noteOn.(note, vel, chan);
		}, chan:chan, srcID: source.uid);
		defs.add(key);

		key = (objName ++ '_noteOff').asSymbol;
		MIDIdef.noteOff(key, {arg ...args;
			var note = args[1];
			var vel = args[0];
			var chan = args[2];
			noteOff.(note, chan);
		}, chan:chan, srcID: source.uid);
		defs.add(key);
	};
	var registerCc = {arg chan, name, func, spec;
		var chanlabel = chan ?? "all";
		var key = (objName ++ '_' ++ chanlabel ++ '_cc').asSymbol;
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
		View().layout_(
			VLayout(
				StaticText().string_("chan: " ++ (chan ?? "all")),
				HLayout(
					StaticText().string_("note").fixedWidth_(25),
					Button().string_("x").fixedSize_(10),
					DragSink().string_("<-  ")
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
					StaticText().string_("cc").fixedWidth_(25),
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
			)
		).background_(Color.rand.alpha_(0.2))
	};
	var tab1 = View().layout_(
		VLayout(
			map_view.(nil),
			GridLayout.rows(
				[
					map_view.(1),
					map_view.(0),
				],
				[
					map_view.(3),
					map_view.(2),
				]
			).margins_(1).spacing_(2),
			nil
		)
	);
	var tab2 = View().layout_(
		VLayout(
			map_view.(nil),
			nil
		)
	);
	var tab3 = View().layout_(
		VLayout(
			map_view.(nil),
			nil
		)
	);
	var tab4 = View().layout_(
		VLayout(
			map_view.(nil),
			nil
		)
	);
	var stackView = StackLayout(tab1, tab2, tab3, tab4).mode_(\stackOne);

	var tabs = HLayout(
		Button().string_("2x2").action_({
			//freedefs.();
			stackView.index = 0;
		}),
		Button().string_("5x5").action_({
			//freedefs.();
			stackView.index = 1
		}),
		Button().string_("4x4").action_({
			//freedefs.();
			stackView.index = 2
		}),
		Button().string_("1x1").action_({
			//freedefs.();
			stackView.index = 3
		})
	);
	view.layout.add(connectView);
	view.layout.add(tabs);
	view.layout.add(stackView);

	NotificationCenter.register(view, \close, view, {arg msg;
		freedefs.();
		MIDIIn.disconnect(device:source);
		msg.debug("clean up");
	});

	view;
}
)
