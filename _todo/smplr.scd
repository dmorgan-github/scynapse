(
SynthDef(\smplr, {

	var buf = \buf.kr(0);
	var numFrames = BufFrames.kr(buf);
	var start = \start.kr(0) * numFrames;
	var end = \end.kr(1) * numFrames;
	var rate = \rate.kr(1).reciprocal;
	var size = end-start;
	var dur = size/BufSampleRate.kr(buf);

	var phase = Line.ar(start, end, dur * rate, doneAction:Done.freeSelf);
	var sig = BufRd.ar(1, buf, phase, loop:0, interpolation:4);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
Pdef(\smplr, Pproto({

	var node = topEnvironment[\noise];
	node.play;
	~group = node.group;
	~out = node.bus.index;

}, Pbind(
	\instrument, \smplr,
	\buf, ~bufs[\buf7],
	\start, 0.1,
	\end, 0.13,
	\rate, [0.1, 0.05],

	\delta, 16,

	\amp, 0.1
)))
)