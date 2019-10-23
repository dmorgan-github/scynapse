(
view: {arg objName, envir, components;

	var synthEnvir = {
		var envir = topEnvironment[objName];
		if (envir.isNil){
			topEnvironment[objName] = ();
		};
		envir;
	}.();

	var synth = {

		if (SynthDescLib.global.at(\subtractr).isNil) {
			SynthDef(\subtractr, {
				var gate = \gate.kr(1);
				var numvoices = 2;
				var ddepth = \ddepth.kr(0.1);
				var drate = \drate.kr(0.1);
				var detune = LFNoise2.ar(drate.dup(numvoices)).bipolar(ddepth).midiratio;
				var freq = \freq.ar(261);

				var fm = {arg freq;
					var index = \index.kr(0);
					var ivel = \ivel.kr(0.1);
					var idur = \idur.kr(0.1);
					var ratio = \ratio.kr(2);
					var iline = Line.ar(index, index * ivel, idur) * freq * ratio;
					var mod = SinOsc.ar(freq * ratio) * iline;
					mod;
				};

				var adsr = {
					var da = Done.freeSelf;
					var atk = \atk.kr(0.01);
					var dec = \dec.kr(0.1);
					var rel = \rel.kr(0.1);
					var curve = \curve.kr(-4);
					var suslevel = \suslevel.kr(0.5);
					var ts = \ts.kr(1);
					var env = Env.adsr(atk, dec, suslevel, rel, curve:curve).ar(doneAction:da, gate:gate, timeScale:ts);
					env;
				};

				var filter = {arg sig, aeg, cutoff=1200, vel=1, res=0, freqamt=0, curve=(-4);
					var famt = \freqamt.kr(freqamt);
					var ffreq = \cutoff.kr(cutoff) + (freq * famt);
					var fvel = max(\fvel.kr(vel), 0.001);
					var fcurve = K2A.ar(\fcurve.kr(curve));
					var fres = \res.kr(res);
					var feg = aeg.lincurve(0, 1, ffreq, ffreq * fvel, curve:fcurve).clip(20, 20000);
					//var feg = Env.perc(0.01, \dec.kr, fcurve).kr(gate:trig, timeScale:\ts.kr(1))
					//.linlin(0, 1, ffreq, ffreq * fvel).clip(20, 20000);
					//var feg = Env([ffreq, ffreq, ffreq * fvel], [0, \dec.kr], fcurve).kr(gate:trig).clip(20, 20000);

					sig = MoogFF.ar(sig, feg, fres.linlin(0, 1, 0, 4)) * 4;
					//sig = MoogLadder.ar(sig, feg, fres) * 4;
					//sig = MoogVCF.ar(sig, feg, res);
					//sig = SVF.ar(sig, feg, fres, 1, 1, 0, 1, 0);
					//sig = DFM1.ar(sig, feg, fres.clip(0.001, 1.0)) * 1;
					//sig = RLPF.ar(sig, feg, (1-fres).clip(0.001, 1.0));
					//sig = BLowPass4.ar(sig, feg, (1-fres).clip(0.001, 1.0));
					//sig = BLowPass.ar(sig, feg, (1-fres).clip(0.001, 1.0));
					sig;
				};

				var tri = {arg freq;
					var sig = VarSaw.ar(freq, 0, \triwidth.ar(0.5));
					var fold = \trifold.kr(1);
					sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
					sig = LeakDC.ar(sig);
					sig * AmpCompA.kr(freq);
				};

				var saw = {arg freq;
					//var sig = Saw.ar(freq);
					var timbre = \sawtimbre.ar(0);
					var sawcurve = \sawcurve.ar(0);
					var sig = SyncSaw.ar(freq, freq + timbre).lincurve(-1, 1, -1, 1, sawcurve);
					sig * AmpCompA.kr(freq);
				};

				var square = {arg freq;
					var sig = Pulse.ar(freq, \squarewidth.ar(0.5));
					sig * AmpCompA.kr(freq);
				};

				var sine = {arg freq;
					var mod = fm.(freq) * \sinefm.kr(0);
					var sig = SinOsc.ar(freq + mod);
					var fold = \sinefold.kr(1);
					sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
					sig = LeakDC.ar(sig);
					sig * AmpCompA.kr(freq);
				};

				var noise = {
					var sig = WhiteNoise.ar;
					sig;
				};

				var aeg = adsr.();

				var sig = [
					tri.(freq * detune * \trifreqmul.kr(1)) * \tri.kr(1),
					saw.(freq * detune * \sawfreqmul.kr(2)) * \saw.kr(0.2),
					square.(freq * detune * \squarefreqmul.kr(4)) * \square.kr(0.1),
					sine.(freq * detune * \sinefreqmul.kr(1)) * \sine.kr(0.2),
					noise.() * \noise.kr(0)
				].sum;
				sig = sig * aeg * \vel.kr(1);
				sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
				sig = LeakDC.ar(sig);

				sig = filter.(sig, aeg);
				sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
				sig = sig * \amp.kr(-3.dbamp);
				Out.ar(\out.kr(0), sig);

			}, metadata:(
				specs:(
					ddepth: ControlSpec(0, 1, \lin, 0, 0.1),
					drate: ControlSpec(0.0, 1.0, \lin, 0, 0.1),
					freq: \freq.asSpec,
					index: ControlSpec(0, 100, \lin, 0.0, 1),
					ivel: ControlSpec(0, 100, \lin, 0, 1),
					idur: ControlSpec(0, 1, \lin, 0, 1),
					ratio: ControlSpec(0, 100, \lin, 0, 1),
					atk: ControlSpec(0, 30, \lin, 0, 0.01),
					dec: ControlSpec(0, 30, \lin, 0, 0.2),
					sustain: ControlSpec(0, 30, \lin, 0, 0.5),
					rel: ControlSpec(0, 30, \lin, 0, 0.29),
					suslevel: ControlSpec(0, 1, \lin, 0, 0.7),
					curve: ControlSpec(-24, 24, \lin, 0, -4),
					ts: ControlSpec(0, 100, \lin, 0, 1),
					freqamt: ControlSpec(0, 4, \lin, 0, 0),
					cutoff: ControlSpec(1, 18000, 'exp', 0, 100),
					fvel: ControlSpec(0, 20, \lin, 0, 10),
					fcurve: ControlSpec(-24, 24, \lin, 0, -4),
					res: ControlSpec(0, 1, \lin, 0, 0.5),
					triwidth: ControlSpec(0, 1, \lin, 0, 0.5),
					trifold: ControlSpec(1, 10, \lin, 0, 1),
					sawtimbre: ControlSpec(0, 1, \lin, 0, 0.1),
					sawcurve: ControlSpec(-4, 4, \lin, 0, 0),
					squarewidth: ControlSpec(0, 1, \lin, 0, 0.5),
					trifreqmul: ControlSpec(0, 12, \lin, 0, 1),
					tri: ControlSpec(0, 1, \lin, 0, 1),
					sawfreqmul: ControlSpec(0, 12, \lin, 0, 1),
					saw: ControlSpec(0, 1, \lin, 0, 0),
					squarefreqmul: ControlSpec(0, 12, \lin, 0, 1),
					square: ControlSpec(0, 1, \lin, 0, 0),
					sinefreqmul: ControlSpec(0, 12, \lin, 0, 1),
					sine: ControlSpec(0, 1, \lin, 0, 0),
					sinefm: ControlSpec(0, 1, \lin, 0, 0),
					sinefold: ControlSpec(1, 10, \lin, 0, 1),
					noise: ControlSpec(0, 1, \lin, 0, 0),
					pre: ControlSpec(0, 1, \lin, 0, 1),
					vel: ControlSpec(0, 1, \lin, 0, 1),
					spread: ControlSpec(0, 1, \lin, 0, 1),
					center: ControlSpec(0, 1, \lin, 0, 0),
					pan: ControlSpec(-1, 1, \lin, 0, 0),
					amp: ControlSpec(0, 1, \lin, 0, 0.1)
				)
			)).add;
		};

	}.();

	var node = NodeProxy.audio(s, 2);
	var view = View().layout_(VLayout().margins_(1).spacing_(1));

	var synthView = {arg envir, name;

		var metadata = SynthDescLib.global.at(\subtractr).metadata;
		var specs = metadata[\specs];
		var scrollView = ScrollView(bounds:Rect(0,0,160,300).center_(Window.availableBounds.center))
		.name_(name);

		var ctrlView = {arg key, label, color;

			var controlSpec = specs[key];
			var myval = envir[key] ?? controlSpec.default;

			var stack, view;
			var font = Font(size:10);
			var li = LevelIndicator(bounds:Rect(width:20, height:18)).value_(controlSpec.unmap(myval));
			var labelView = StaticText().string_(label ++ ": ").font_(font).stringColor_(Color.white);
			var st = StaticText().string_(myval).font_(font).stringColor_(Color.white);
			var nb = NumberBox().font_(font).value_(myval).background_(Color.white);

			envir[key] = myval;
			stack = StackLayout(
				View()
				.layout_(
					StackLayout(
						View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
						li
						.style_(\continuous)
						.meterColor_(color.alpha_(0.5))
						.warningColor_(color.alpha_(0.5))
						.criticalColor_(color.alpha_(0.5))
						.background_(color.alpha_(0.2))
					)
					.mode_(\stackAll)
					.margins_(0)
					.spacing_(0)
				)
				.mouseMoveAction_({arg ctrl, x, y, mod;
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					if (mod == 0) {
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						envir[key] = mappedVal;
					}
				})
				.mouseUpAction_({arg ctrl, x, y, mod;
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					if (mod == 0) {
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						envir[key] = mappedVal;
					}
				}),
				nb
				.action_({arg ctrl;
					var val = ctrl.value;
					li.value = controlSpec.unmap(val);
					st.string_(val);
					envir[key] = val;
					stack.index = 0;
				}),
			).mode_(\stackOne)
			.margins_(0)
			.spacing_(0);

			view = View()
			.layout_(stack)
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				if (mod == 262144) {
					stack.index = 1;
				}
			})
			.fixedWidth_(150)
			.fixedHeight_(25);
			view
		};

		var view = View()
		.name_(name)
		.layout_(VLayout().margins_(1).spacing_(1));

		var filterView = View().layout_(VLayout(
			ctrlView.(\cutoff, \cutoff, Color.blue),
			ctrlView.(\fvel, \vel, Color.blue),
			ctrlView.(\fcurve, \curve, Color.blue),
			ctrlView.(\res, \res, Color.blue),
			ctrlView.(\freqamt, \freqamt, Color.blue),
			nil
		).margins_(2).spacing_(1));

		var detuneView = View().layout_(VLayout(
			ctrlView.(\ddepth, \ddepth, Color.red),
			ctrlView.(\drate, \drate, Color.red),
			nil
		).margins_(2).spacing_(1));

		var triView = View().layout_(VLayout(
			ctrlView.(\tri, \tri, Color.green),
			ctrlView.(\trifreqmul, \freqmul, Color.green),
			ctrlView.(\triwidth, \width, Color.green),
			ctrlView.(\trifold, \fold, Color.green),
			nil
		).margins_(2).spacing_(1));

		var sawView = View().layout_(VLayout(
			ctrlView.(\saw, \saw, Color.cyan),
			ctrlView.(\sawfreqmul, \freqmul, Color.cyan),
			ctrlView.(\sawtimbre, \timbre, Color.cyan),
			ctrlView.(\sawcurve, \curve, Color.cyan),
			nil
		).margins_(2).spacing_(1));

		var squareView = View().layout_(VLayout(
			ctrlView.(\square, \square, Color.magenta),
			ctrlView.(\squarefreqmul, \freqmul, Color.magenta),
			ctrlView.(\squarewidth, \width, Color.magenta),
			nil
		).margins_(2).spacing_(1));

		var sineView = View().layout_(VLayout(
			ctrlView.(\sine, \sine, Color.yellow),
			ctrlView.(\sinefreqmul, \freqmul, Color.yellow),
			ctrlView.(\sinefold, \fold, Color.yellow),
			ctrlView.(\sinefm, \fm, Color.yellow),
			ctrlView.(\index, \index, Color.yellow),
			ctrlView.(\ivel, \ivel, Color.yellow),
			ctrlView.(\idur, \idur, Color.yellow),
			ctrlView.(\ratio, \ratio, Color.yellow)
		).margins_(2).spacing_(1));

		var noiseView = View().layout_(VLayout(
			ctrlView.(\noise, \noise, Color.gray),
		).margins_(2).spacing_(2));

		var ampView = View().layout_(VLayout(
			ctrlView.(\amp, \amp, Color.blue),
			nil
		).margins_(2).spacing_(1));

		var envView = View().layout_(VLayout(
			ctrlView.(\atk, \atk, Color.red),
			ctrlView.(\dec, \dec, Color.red),
			ctrlView.(\sustain, \sustain, Color.red),
			ctrlView.(\suslevel, \suslevel, Color.red),
			ctrlView.(\rel, \rel, Color.red),
			ctrlView.(\ts, \ts, Color.red),
		).margins_(2).spacing_(1));

		view.layout.add(envView);
		view.layout.add(filterView);
		view.layout.add(detuneView);
		view.layout.add(triView);
		view.layout.add(sawView);
		view.layout.add(squareView);
		view.layout.add(sineView);
		view.layout.add(noiseView);
		view.layout.add(ampView);
		scrollView.canvas = view;
		scrollView;
	}.(synthEnvir, objName);

	envir[objName] = node;
	envir[objName].play;
	{envir[objName].stop}.defer(5);

	Pdef(\subtractrbase, {arg evt, ndef, monitor=true;

		var metadata = SynthDescLib.global.at(\subtractr).metadata;
		var specs = metadata[\specs];
		var node = Ndef(ndef);
		if (node.isMonitoring.not and: monitor){
			node.play;
		};
		Penvir(evt,
			Pbind(
				\instrument, \subtractr,
				\out, Pfunc({node.bus.index}),
				\group, Pfunc({node.group}),

				// filter
				\cutoff, Pif(Pfunc({~cutoff.isNil}), specs[\cutoff].default, Pfunc({~cutoff})),
				\fvel, Pif(Pfunc({~fvel.isNil}), specs[\fvel].default, Pfunc({~fvel})),
				\fcurve, Pif(Pfunc({~fcurve.isNil}), specs[\fcurve].default, Pfunc({~fcurve})),
				\res, Pif(Pfunc({~res.isNil}), specs[\res].default, Pfunc({~res})),
				\freqamt, Pif(Pfunc({~freqamt.isNil}), specs[\freqamt].default, Pfunc({~freqamt})),

				// detune
				\ddepth, Pif(Pfunc({~ddepth.isNil}), specs[\ddepth], Pfunc({~ddepth})),
				\drate, Pif(Pfunc({~drate.isNil}), specs[\drate].default, Pfunc({~drate})),

				// env
				\atk, Pif(Pfunc({~atk.isNil}), specs[\atk].default, Pfunc({~atk})), // * Pkey(\dur),
				\dec, Pif(Pfunc({~dec.isNil}), specs[\dec].default, Pfunc({~dec})), // * Pkey(\dur),
				\sustain, Pif(Pfunc({~sustain.isNil}), 0.5, Pfunc({~sustain})), // * Pkey(\dur),
				\rel, Pif(Pfunc({~rel.isNil}), specs[\rel].default, Pfunc({~rel})), // * Pkey(\dur),
				\suslevel, Pif(Pfunc({~suslevel.isNil}), specs[\suslevel].default, Pfunc({~suslevel})),
				\ts, Pif(Pfunc({~ts.isNil}), specs[\ts].default, Pfunc({~ts})),

				// triangle
				\tri, Pif(Pfunc({~tri.isNil}), specs[\tri].default, Pfunc({~tri})),
				\trifreqmul, Pif(Pfunc({~trifreqmul.isNil}), specs[\trifreqmul].default, Pfunc({~trifreqmul})),
				\triwidth, Pif(Pfunc({~triwidth.isNil}), specs[\triwidth].default, Pfunc({~triwidth})),
				\trifold, Pif(Pfunc({~trifold.isNil}), specs[\trifold].default, Pfunc({~trifold})),

				// saw
				\saw, Pif(Pfunc({~saw.isNil}), specs[\saw].default, Pfunc({~saw})),
				\sawfreqmul, Pif(Pfunc({~sawfreqmul.isNil}), specs[\sawfreqmul].default, Pfunc({~sawfreqmul})),
				\sawtimbre, Pif(Pfunc({~sawtimbre.isNil}), specs[\sawtimbre].default, Pfunc({~sawtimbre})),
				\sawcurve, Pif(Pfunc({~sawcurve.isNil}), specs[\sawcurve].default, Pfunc({~sawcurve})),

				// square
				\square, Pif(Pfunc({~square.isNil}), specs[\square].default, Pfunc({~square})),
				\squarefreqmul, Pif(Pfunc({~squarefreqmul.isNil}), specs[\squarefreqmul].default, Pfunc({~squarefreqmul})),
				\squarewidth, Pif(Pfunc({~squarewidth.isNil}), specs[\squarewidth].default, Pfunc({~squarewidth})),

				// noise
				\noise, Pif(Pfunc({~noise.isNil}), specs[\noise].default, Pfunc({~noise})),

				// sine
				\sine, Pif(Pfunc({~sine.isNil}), specs[\sine].default, Pfunc({~sine})),
				\sinefreqmul, Pif(Pfunc({~sinefreqmul.isNil}), specs[\sinefreqmul].default, Pfunc({~sinefreqmul})),
				\sinefold, Pif(Pfunc({~sinefold.isNil}), specs[\sinefold].default, Pfunc({~sinefold})),
				\sinefm, Pif(Pfunc({~sinefm.isNil}), specs[\sinefm].default, Pfunc({~sinefm})),

				// fm
				\index, Pif(Pfunc({~index.isNil}), specs[\index].default, Pfunc({~index})),
				\ivel, Pif(Pfunc({~ivel.isNil}), specs[\ivel].default, Pfunc({~ivel})),
				\idur, Pif(Pfunc({~idur.isNil}), specs[\idur].default, Pfunc({~idur})),
				\ratio, Pif(Pfunc({~ratio.isNil}), specs[\ratio].default, Pfunc({~ratio})),

				\amp, Pif(Pfunc({~amp.isNil}), specs[\amp].default, Pfunc({~amp}))
			)
		)
	});

	Pdef(objName,
		Pbind(
			\dur, 1,
			\degree, 0,
			\octave, 5,
			\vel, 1,
		) <> Pdef(\subtractrbase) <> (evt:synthEnvir, ndef:objName, monitor:false)
	);

	view.layout.add(synthView);

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
	});

	view;
}
)