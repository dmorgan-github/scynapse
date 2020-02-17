/////////////////////////////////////////
// \imtdeaki
~imtdeaki = B(\imtdeaki, "/Users/david/projects/droptableuser/workspaces/s1/imtdeaki.aiff");
~imtdeaki = B(\imtdeaki, "/Users/david/projects/droptableuser/workspaces/s1/imtdeaki2.aiff");

~imtdeaki = B(\buha, 8);
~imtdeaki.buf.play
~imtdeaki.recSoundIn;

~imtdeaki.buf.write("/Users/david/projects/droptableuser/workspaces/s1/imtdeaki2.aiff");

~imtdeaki.set(\vel, 1);
~imtdeaki.set(\start, Pwhite(0.1, 0.9));
~imtdeaki.set(\dur, 1);
~imtdeaki.set(\rev, 0.2);
~imtdeaki.set(\rel, 1);
~imtdeaki.set(\legato, 1);
~imtdeaki.set(\freqmode, 0);

~imtdeaki.node.stop;
~imtdeaki.node.play;
~imtdeaki.pdef(mono:false, monitor:false).play;
~imtdeaki.pdef.stop;
~imtdeaki.pdef.play;

/////////////////////////////////////////
// record
App.saveWorkspace("s1", rec:true);
~imtdeaki.pdef.play;

s.stopRecording;

App.scynapse


(
OscCtrl.path('/2/play', {arg val;
	var state = val[0];
	if (state.postln == 1) {
		~imtdeaki.pdef.play;
	} {
		~imtdeaki.pdef.stop;
	};
});
OscCtrl.path('/2/rec', {arg val;
	var state = val[0];
	if (state == 1) {
		~imtdeaki.recSoundIn;
	}
	//[\rec, val].postln;
});
OscCtrl.path('/2/overdub', {arg val;
	var state = val[0];
	if (state == 1) {
		~imtdeaki.overdubSoundIn;
	};
});
OscCtrl.path('/2/rev', {arg val;
	var myval = val[0];
	~imtdeaki.set(\rev, myval);
	[\rev, myval].postln
});
)

