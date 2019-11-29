(
var func = {arg numchannels = 2;
	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var rate = \rate.kr(1);
	var start = \start.kr(0);
	var rev = \rev.kr(0);
	var loop = \loop.kr(0);
	var dir = TWChoose.kr(1, [-1, 1], [rev, 1-rev]);
	var sig = PlayBuf.ar(numchannels, buf, BufRateScale.kr(buf) * rate * dir, 1, numframes * start, loop);

	var aeg = {
		var sus = \sus.kr(0.1);
		var atkcurve = \atkcurve.kr(-4);
		var relcurve = \relcurve.kr(4);
		var atk = \atk.kr(0.0);
		var rel = \rel.kr(0.1);
		var env = Env([0,1,1,0], [atk, sus, rel], [atkcurve,0,relcurve]);
		env.kr(gate:1, doneAction:Done.freeSelf);
	};
	sig = sig * aeg.() * \vel.kr(1);
	sig = sig * \amp.kr(-3.dbamp);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = LeakDC.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	Out.ar(\out.kr(0), sig);
};

var specs = [
	\rev -> ControlSpec(0, 1, \lin, 1, 0),
	\start -> ControlSpec(0, 1, \lin, 0, 0),
	\rate -> ControlSpec(0.1, 4.0, \lin, 0, 1),
	\atk -> ControlSpec(0, 1, \lin, 0, 0),
	\rel -> ControlSpec(0, 1, \lin, 0, 0.1),
	\sus -> ControlSpec(0.001, 8, \lin, 0, 1),
	\atkcurve -> ControlSpec(-4,4,\lin,0,4),
	\relcurve -> ControlSpec(-4,4,\lin,0,-4),
	\vel -> ControlSpec(0, 1, \lin, 0, 1),
	\spread -> ControlSpec(0, 1, \lin, 0, 1),
	\center -> ControlSpec(0, 1, \lin, 0, 0),
	\pan -> ControlSpec(-1, 1, \lin, 0, 0),
	\amp -> ControlSpec(0, 1, \lin, 0, 0.1),
];

SynthDef(\smplr_2chan, {
	func.(2)
}, metadata: (
	\specs: specs
)).add;

SynthDef(\smplr_1chan, {
	func.(1)
}, metadata: (
	\specs: specs
)).add;
)