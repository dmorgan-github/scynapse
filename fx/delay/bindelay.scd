(
view: {arg objName, envir, components;

	var size = 128;
	var maxdel = 0.5;
	var dels = Buffer.alloc(s, size, 1);
	var fb = Buffer.alloc(s, size, 1);

	var node = NodeProxy.audio(s, 2)
	.filter(100, {arg in;

		var maxdel = 0.5;
		var buf = LocalBuf(size * 2, 1).clear;
		var pulse = Impulse.ar(0.33);
		var chain = FFT(buf, in, 0.25);
		chain = PV_BinDelay(chain, maxdel, \dels.kr, \fb.kr, 0.25);

		//Pan2.ar(in + IFFT(chain), \pan.kr(0));
		Pan2.ar(IFFT(chain), \pan.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);

	})
	.set(\dels, dels, \fb, fb);

	var specs = [
		\pan -> [-1,1,\lin,0,0],
		\amp -> [0,1,\lin,0,1]
	];

	var view = View().layout_(VLayout());

	var playView = components[\playView].(objName, node, view);

	var multiInputsView = components[\multiInputsView].(node, view);

	var specsView = components[\specsView].(objName, specs, node, envir, view);

	var delayView = MultiSliderView().action_({arg ctrl;
		var val = ctrl.currentvalue * maxdel;
		NotificationCenter.notify(view, \status, "del: " ++ ctrl.index ++ " " ++ val);
		dels.set(ctrl.index, val);
	})
	.value_(Array.fill(size, {0}))
	.xOffset_(5)
	.thumbSize_(12.0)
	.valueThumbSize_(15.0)
	.fixedWidth_(300)
	.indexThumbSize_(300/size)
	.gap_(0);

	var fbView = MultiSliderView().action_({arg ctrl;
		NotificationCenter.notify(view, \status, "fb: " ++ ctrl.index ++ " " ++ ctrl.currentvalue);
		fb.set(ctrl.index, ctrl.currentvalue);
	})
	.value_(Array.fill(size, {0}))
	.xOffset_(5)
	.thumbSize_(12.0)
	.thumbSize_(12.0)
	.valueThumbSize_(15.0)
	.fixedWidth_(300)
	.indexThumbSize_(300/size)
	.gap_(0);

	view.layout.add(playView);
	view.layout.add(multiInputsView);
	view.layout.add(delayView);
	view.layout.add(fbView);
	view.layout.add(specsView);

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
			dels.free;
			fb.free;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)