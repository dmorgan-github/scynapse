(
~num_smplrs = 8;
~specs = SynthDescLib.global.at(\smplr_2chan).metadata[\specs];
~smplrs = List.new;


~smplr_engine_new = {

	if (~smplrs.size < ~num_smplrs) {
	}
};
)


B(\ofejau, 8);
B(\ofejau).recSoundIn;
B(\ofejau).buf.write("/Users/david/projects/droptableuser/workspaces/s1/ofejau.aiff");


B(\ofejau).play(monitor:false);
B(\ofejau).stop;
B(\ofejau).set(\amp, 0.1);
B(\ofejau).set(\legato, 1);
B(\ofejau).set(\rel, 1);
B(\ofejau).set(\rev, 0.2);
B(\ofejau).set(\dur, 2)
B(\ofejau).set(\start, 0.3);
B(\ofejau).set(\freqmode, 1);
B(\ofejau).set(\octave, 3)
B(\ofejau).set(\harmonic, [1, 2])
B(\ofejau).set(\degree, Pseq([0, 2, 4, -1], inf))

//B(\ofejau).node.stop;
App.scynapse

~rec = B(\ofejau).node.record("/Users/david/projects/droptableuser/workspaces/s1/ofejau_loop.aiff")
~rec2 = Ndef(\matrix_1).record("/Users/david/projects/droptableuser/workspaces/s1/ofejau_loop_fx.aiff");

~rec.unpause;
~rec2.unpause;

~rec.pause;
~rec2.pause;

~rec.close;
~rec2.close;

~rec.free;
~rec2.free;

/////////////////////////////////////////
// record
App.saveWorkspace("s1", rec:true);
B(\ofejau).play(monitor:false, fadeTime:4);
B(\ofejau).node.stop(fadeTime:8)

s.stopRecording;



/////////////////////////////////////////
// \ablovwdh
~ablovwdh = B(\ablovwdh, "/Users/david/projects/droptableuser/workspaces/s1/ofejau_loop_fx.aiff");
~ablovwdh.filter(100, {arg in; JPverb.ar(in, 3, 0, 3);} );
~ablovwdh.node.set(\wet100, 0.4)

~ablovwdh.set(\vel, 1);
~ablovwdh.set(\start, 0.7);
~ablovwdh.set(\dur, 3);
~ablovwdh.set(\rev, 0.1);
~ablovwdh.set(\rel, 1);
~ablovwdh.set(\legato, 0.2);
~ablovwdh.set(\harmonic, [1, 2]);
~ablovwdh.set(\freqmode, 1);
~ablovwdh.set(\octave, [4, 5]-1)

~ablovwdh.pdef.play;
~ablovwdh.pdef.stop;


App.saveWorkspace("s1", rec:true);
~ablovwdh.pdef.play;

s.stopRecording;





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

