(

var oscEnv = Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin);

SynthDef(\poly1, {

	var freq_in = \freq.kr(432);

	var trig = \gate.kr(1);
	var susLevel = \susLevel.kr(0.7);
	var atk = \atk.kr(0.001);
	var decay = \decay.kr(0.05);
	var rel = \rel.kr(0.0949);
	var curve = \curve.kr(-4);
	var env = Env.adsr(atk, decay, susLevel, rel, curve:curve).kr(gate:trig, doneAction:Done.freeSelf);

	var osc1 = {

		var freq_mul = \osc1_freq_mul.kr(1);

		var detune = LFNoise2.kr(0.01).range(-5,5);

		var freq = Vibrato.ar(K2A.ar(freq_in * freq_mul + detune),
			\osc1_vrate.kr(6),
			\osc1_vdepth.kr(0.0),
			\osc1_vdelay.kr(0),
			\osc1_vonset.kr(0),
			\osc1_vrateVar.kr(0.04),
			\osc1_vdepthVar.kr(0.1)
		);

		var sig = SinOsc.ar(freq);
		var env = \osc1_env.kr(oscEnv.asArray);
		var level = \osc1_level.kr(1);
		var ts = \osc1_ts.kr(1);
		var envgen = EnvGen.kr(env, gate:1, levelScale:level, timeScale:ts);

		sig * envgen;
	};

	var osc2 = {

		var freq_mul = \osc2_freq_mul.kr(1);

		var detune = LFNoise2.kr(0.01).range(-5,5);

		var freq = Vibrato.ar(K2A.ar(freq_in * freq_mul + detune),
			\osc2_vrate.kr(6),
			\osc2_vdepth.kr(0.0),
			\osc2_vdelay.kr(0),
			\osc2_vonset.kr(0),
			\osc2_vrateVar.kr(0.04),
			\osc2_vdepthVar.kr(0.1)
		);

		var width = \osc2_width.kr(0.5);
		var sig = VarSaw.ar(freq, 0, width:width);
		var env = \osc2_env.kr(oscEnv.asArray);
		var level = \osc2_level.kr(1);
		var ts = \osc2_ts.kr(1);
		var envgen = EnvGen.kr(env, gate:1, levelScale:level, timeScale:ts);

		sig * envgen;
	};

	var osc3 = {

		var freq_mul = \osc3_freq_mul.kr(1);

		var detune = LFNoise2.kr(0.01).range(-5,5);

		var freq = Vibrato.ar(K2A.ar(freq_in * freq_mul + detune),
			\osc3_vrate.kr(6),
			\osc3_vdepth.kr(0.0),
			\osc3_vdelay.kr(0),
			\osc3_vonset.kr(0),
			\osc3_vrateVar.kr(0.04),
			\osc3_vdepthVar.kr(0.1)
		);

		var sig = Saw.ar(freq);
		var env = \osc3_env.kr(oscEnv.asArray);
		var level = \osc3_level.kr(1);
		var ts = \osc3_ts.kr(1);
		var envgen = EnvGen.kr(env, gate:1, levelScale:level, timeScale:ts);

		//sig = BLowPass4.ar(sig, 1200, 0.5);

		sig * envgen;
	};

	var osc4 = {

		var freq_mul = \osc4_freq_mul.kr(1);

		var mod = \osc4_mod.kr(1);

		var detune = LFNoise2.kr(0.01).range(-5,5);

		var freq = Vibrato.ar(K2A.ar(freq_in * freq_mul + detune),
			\osc4_vrate.kr(6),
			\osc4_vdepth.kr(0.0),
			\osc4_vdelay.kr(0),
			\osc4_vonset.kr(0),
			\osc4_vrateVar.kr(0.04),
			\osc4_vdepthVar.kr(0.1)
		);

		var env = \osc4_env.kr(oscEnv.asArray);
		var level = \osc4_level.kr(1);
		var ts = \osc4_ts.kr(1);
		var envgen = EnvGen.kr(env, gate:1, timeScale:ts);

		var sig = PMOsc.ar(freq * freq_mul, freq * freq_mul * mod, envgen);

		sig * level;
	};

	var sig = [osc1.(), osc2.(), osc3.(), osc4.()];

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	sig = sig * AmpCompA.kr(freq_in) * env * \amp.kr(0.5);

	Out.ar(\out.kr(0), sig);

}).add;
)


(
~poly_ui = {

	var defaultAmp = 0.5;

	var defaultAtk = 0.001;

	var defaultSusLevel = 0.7;

	var defaultDecay = 0.05;

	var defaultSus = 0.8541;

	var defaultRel = 0.0949;

	var oscEnv = Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin);

	var node = PbindProxy().set(\instrument, \poly1);

	var view = View().layout_(VLayout())
	.minWidth_(400)
	.minHeight_(700)
	.palette_(QPalette.dark);

	var envViews = (0..3).collect({arg i;

		var num = i + 1;
		var key = ('osc' ++ num ++ '_env').asSymbol;

		EnvelopeView()
		.minHeight_(50)
		.drawLines_(true)
		.selectionColor_(Color.red)
		.drawRects_(true)
		.resize_(5)
		.step_(0.0)
		.thumbSize_(10)
		.keepHorizontalOrder_(true)
		.setEnv(oscEnv)
		.action_({arg ctrl;
			node.set(key, ctrl.asEnv);
		})
		.fillColor_(Color.blue);
	});

	var freqViews = (0..3).collect({arg i;

		var num = i + 1;
		var key = ('osc' ++ num ++ '_freq_mul').asSymbol;

		NumberBox()
		.minHeight_(15)
		.minWidth_(30)
		.clipLo_(0)
		.clipHi_(14)
		.decimals_(4)
		.action_({arg ctrl;
			var val = ctrl.value;
			node.set(key, val);
		})
		.value_(1)
		.normalColor_(Color.white)
	});

	var oscView = View().layout_(VLayout().margins_(3).spacing_(3));

	var oscControls = {arg num, cb;

		VLayout(
			StaticText().string_(num),
			cb.(),
			freqViews[num-1],
			envViews[num-1],
			HLayout(
				StaticText().string_("Level Scale"),
				Slider().orientation_(\horizontal).value_(1).maxHeight_(15).maxWidth_(50)
				.action_({arg ctrl;
					var key = ('osc' ++ num ++ '_level').asSymbol;
					node.set(key, ctrl.value);
				})
			),
			HLayout(
				StaticText().string_("Time Scale"),
				Slider().orientation_(\horizontal).value_(1.linlin(0,20,0,1)).maxHeight_(15).maxWidth_(50)
				.action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,20);
					var key = ('osc' ++ num ++ '_ts').asSymbol;
					node.set(key, val);
				})
			)
		);
	};

	oscView.layout.add(HLayout(
		oscControls.(1, {}),
		oscControls.(2, {
			NumberBox()
			.minHeight_(15)
			.minWidth_(30)
			.clipLo_(0)
			.clipHi_(1)
			.decimals_(4)
			.value_(0.5)
			.normalColor_(Color.white)
			.action_({arg ctrl;
				var key = 'osc2_width';
				node.set(key, ctrl.value);
			})
		})
	));

	oscView.layout.add(HLayout(
		oscControls.(3, {}),
		oscControls.(4, {
			HLayout(
				NumberBox()
				.minHeight_(15)
				.minWidth_(30)
				.clipLo_(0.1)
				.clipHi_(20)
				.decimals_(4)
				.value_(1)
				.normalColor_(Color.white)
				.action_({arg ctrl;
					var key = 'osc4_mod';
					node.set(key, ctrl.value);
				}),

				NumberBox()
				.minHeight_(15)
				.minWidth_(30)
				.clipLo_(0)
				.clipHi_(1)
				.decimals_(4)
				.normalColor_(Color.white)
				.action_({arg ctrl;

				})
			)
		})
	));

	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));

	view.layout.add(StaticText().string_("Oscs"));

	view.layout.add(oscView);

	view.layout.add(StaticText().string_(" ").background_(Color.black).maxHeight_(2));

	view.layout.add(StaticText().string_("Envelope"));

	view.layout.add(
		HLayout(
			VLayout(
				Knob().value_(defaultAtk.linlin(0,20,0,1))
				.action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,20);
					var key = \atk;
					node.set(key, val);
				}),
				StaticText().string_("A").align_(\center)
			),
			VLayout(
				Knob().value_(defaultDecay.linlin(0,20,0,1))
				.action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,20);
					var key = \decay;
					node.set(key, val);
				}),
				StaticText().string_("D").align_(\center)
			),
			VLayout(
				HLayout(
					Knob().value_(defaultSus.linlin(0,20,0,1))
					.action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,20);
					var key = \sustain;
					node.set(key, val);
				}),
					Slider().maxHeight_(35).maxWidth_(15).thumbSize_(10).value_(defaultSusLevel)
					.action_({arg ctrl;
						var key = \susLevel;
						node.set(key,ctrl.value);
					})
				),
				StaticText().string_("S").align_(\center)
			),
			VLayout(
				Knob().value_(defaultRel.linlin(0,20,0,1))
				.action_({arg ctrl;
					var val = ctrl.value.linlin(0,1,0,20);
					var key = \rel;
					node.set(key, val);
				}),
				StaticText().string_("R").align_(\center)
			),
			VLayout(
				Knob().value_(defaultAmp).action_({arg ctrl;
					var key = \amp;
					node.set(key,ctrl.value);
				}),
				StaticText().string_("Output").align_(\center)
			)
		)
	);

	view.front;

	node;
};

)


~poly1 = ~poly_ui.();

~poly = NodeProxy.audio(s, 2);
~poly.play

~poly.group

(
~rtn = Routine({

	var durs = ~combo.(5, [0.125,0.25,0.5,1], [], \slow).postln;
	var degrees = { (0..5).wchoose( (0..5).normalizeSum ) }.dup(durs.size);

	var durSeq = Pseq(durs, inf);
	var degreesSeq = Pseq(degrees, inf);

  	var result = Ptuple([durSeq, degreesSeq], inf).asStream;

	loop({
		result.next.yield;
	});
});

)

(
Pdef(\poly1, Pproto({

	var node = topEnvironment[\poly];
	node.play;
	~group = node.group;
	~out = node.bus.index;

}, ~poly1.set(


	\scale, Scale.minor,
	[\delta, \degree], ~rtn,
	\octave, Pbjorklund(8,11,inf).collect({arg val; if (val == 0) {4}{ [5,6].wchoose([0.7,0.3]) } }),
	\mtranspose, 0,
	\amp, 0.5,
	\sustain, Pkey(\delta),
	\rel, 0.1

)))
)

App.recordWorkspace("ws13");
s.stopRecording

Pdef(\poly1).play;
Pdef(\poly1).stop;

