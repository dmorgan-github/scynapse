/////////////////////////////////////////
// name

~bobo = ();

~bobo[\r0_len] = 3;
~bobo[\r0_start] = 1;
~bobo[\r0_step] = 2;
~bobo[\r0_dir] = 1;
~bobo[\r0_repeat] = 7;

~bobo[\r1_len] = 3;
~bobo[\r1_start] = 1;
~bobo[\r1_step] = 1;
~bobo[\r1_dir] = -1;
~bobo[\r1_repeat] = 5;

~bobo[\r2_len] = 5;
~bobo[\r2_start] = 0;
~bobo[\r2_step] = 1;
~bobo[\r2_dir] = 1;
~bobo[\r2_repeat] = 3;

~bobo[\begin] = 0;
~bobo[\end] = 2;


(
~data = [
	[10, \, 8, \, \],
	[\, 1, \, 2, \],
	[\, \, -3, -4, -5]
];
)

(
var envir = ~bobo;
var data = ~data;

var offset = {arg i;
	var key = ('r' ++ i ++ '_start').asSymbol;
	if (envir[key].isNil){
		envir[key] = 0;
	};
	Pfunc({envir[key]})
};
var dir = {
	var key = ('r' ++ i ++ '_dir').asSymbol;
	if (envir[key].isNil){
		envir[key] = 1;
	};
	Pfunc({envir[key]})
};
var len = {arg i;
	var key = ('r' ++ i ++ '_len').asSymbol;
	if (envir[key].isNil){
		envir[key] = data[i].size;
	};
	Pfunc({envir[key]});
};
var step = {arg i;
	var key = ('r' ++ i ++ '_step').asSymbol;
	if (envir[key].isNil){
		envir[key] = 1;
	};
	Pfunc({envir[key]});
};
var repeat = {arg i;
	var key = ('r' ++ i ++ '_repeat').asSymbol;
	if (envir[key].isNil){
		envir[key] = 1;
	};
	Pfunc({envir[key]});
};

var begin = {
	var key = ('begin').asSymbol;
	if (envir[key].isNil){
		envir[key] = 0;
	};
	Pfunc({envir[key]});
};

var end = {
	var key = ('end').asSymbol;
	if (envir[key].isNil){
		envir[key] = data.size;
	};
	Pfunc({envir[key]});
};

Pdef(\test,
	Pbind(
		\rows, Ptuple(
			data.collect({arg row, i;
				Pindex(row,
					Pseries(0, step.(i) * dir.(i)).mod(len.(i)) + offset.(i)
				).stutter(repeat.(i));
			})
		),
		\begin, begin.(),
		\end, end.(),
		\bar, Pfunc({arg evt;
			var rows = evt[\rows];
			var begin = evt[\begin].max(0);
			var end = evt[\end].min(data.size);
			rows[begin..end];
		}),
		\degree, Pkey(\bar).collect({arg val; val = val.reject(_.isRest); if (val.isEmpty){Rest()}{val}}),
		\amp, 0.1,
		\vel, Pbjorklund(5, 8).linlin(0, 1, 0.7, 1),
		\octave, Pbjorklund(3, 8).linlin(0, 1, 4, 5),
		\legato, 1,
		\dur, 0.25,
		\scale, Scale.dorian,
		\mtranspose, 0,
		\root, 4
	)
)
)

Pdef(\test).clear;
Pdef(\test).play;
Pdef(\test).stop;


App.pdef(\synth1, \subtractr);
Pdef(\synth1).play;
Pdef(\synth1).stop;
Ndef(\synth1).stop;

~synth1[\dec] = 0.2;
~synth1[\rel] = 0.1;

Pdef(\synth1_p1, Pdef(\test) <> Pdef(\synth1))

Pdef(\synth1_p1).play;
Pdef(\synth1_p1).stop;

App.scynapse

/////////////////////////////////////////
// glitch buf

~bufs = ();

~bufs[\xylo] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/freesoound/422137__14g-panska-niklova-michaela__1-xylophone.wav");

~glitch2;
App.pdef(\glitch2, \grain_2chan);
Ndef(\glitch2).stop;
Ndef(\glitch2).play;

(
var buf = ~bufs[\xylo];
var numFrames = buf.numFrames;
var dur = buf.duration;
Pdef(\glitch_p1, Pbind(
	\buf, ~bufs[\xylo],
	\dur, Pwhite(0.01, 1.0, inf),
	\sus, Pkey(\dur) * Pwhite(1.0, 1.5),
	\start, Pwhite(0.5, 0.7).collect({arg val; if (0.7.coin){val}{Rest()}}),
	\rev, Pwhite(0.0, 1.0),
	\bar, Pxrand([12,24,7,5].midiratio, inf),
	\rate, Pfunc({arg evt; if (0.7.coin) {1} {evt[\bar]} }),
	\flevel, 1,
	\fdepth, 0.5,
	\amp, -3.dbamp
) <> Pdef(\glitch2))
)


Pdef(\glitch_p1).play;
Pdef(\glitch_p1).stop;

(
App.rotary8_osc({arg val, num;
	~glitch2[\start] = val;
});
)

App.rotary8_free();


/////////////////////////////////////////
// glitch3
~bufs[\oh] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/vox/oh-yeah-man-they-definitely-feel-it.wav");

App.pdef(\glitch3, \grain_1chan);
Ndef(\glitch3).stop;
Ndef(\glitch3).play;

(
var buf = ~bufs[\oh];
var numFrames = buf.numFrames;
var dur = buf.duration;
Pdef(\glitc3_p1, Pbind(
	\buf,buf,
	\dur, 1,//Pwhite(0.01, 1.0, inf),
	\sus, Pkey(\dur) * Pwhite(1.0, 1.5),
	\start, Pwhite(0.5, 0.9).collect({arg val; if (0.7.coin){val}{Rest()}}),
	\rev, Pwhite(0.0, 1.0),
	\bar, Pxrand([12,24,7,5].midiratio, inf),
	\rate, Pfunc({arg evt; if (0.7.coin) {1} {evt[\bar]} }),
	\amp, -3.dbamp
) <> Pdef(\glitch3))
)

Pdef(\glitc3_p1).play;
Pdef(\glitc3_p1).stop;

