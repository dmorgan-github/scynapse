(
var size = 20;

Fdef(\scynapse, {arg environment, rootpath;

	var viewsPath = rootpath ++ "_views/";
	var palette = QPalette.auto(Color.grey, Color.black);
	var recorders = List.new;
	var proxyspace = \p;
	var getenvir = {

		if (environment.isNil.not) {
			"using supplied environment".postln;
			environment;
		}{
			if (currentEnvironment.class == ProxySpace) {
				"using proxy space".postln;
				currentEnvironment.envir;
			}{
				"using currentEnvironment".postln;
				currentEnvironment;
			}
		}
	};

	// init
	var init = {
		var bufs = getenvir.()[\bufs];
		if (bufs.isNil) {
			getenvir.()[\bufs] = ();
		};
		Font.setDefault(Font("Courier New", 10));
		nil;
	}.value;

	var browse = {arg path;

		var folder = PathName.new(path);
		if (folder.isFolder, {

			var folders = folder.folders;
			var files = folder.files;
			[folders, files];
		}, {
			[];
		});
	};

	//var doclist = View().layout_(VLayout(nil)).minWidth_(100);
	//var docmap = ();

	var findView = {arg path;

		var result = "";
		var pathname = PathName(path);
		var name = pathname.fileNameWithoutExtension;
		var search = viewsPath ++ name ++ ".scd";

		if (File.exists(search)) {
			result = search;
		} {

			var findFolder = {arg path, count = 3;

				var folderName = PathName(path).folderName;
				var search = viewsPath ++ folderName ++ ".scd";

				if (File.exists(search)) {
					search;
				} {
					var myPath = PathName(path).pathOnly.trim("/");
					if (count > 0) {
						findFolder.(myPath, count - 1);
					}
				}
			};

			result = findFolder.(path);
		};

		result;
	};

	var loadView = {arg file;

		var view, count = 1, viewPath;
		var objName = PathName(file).fileNameWithoutExtension;
		var win, obj;
		var status = StaticText().string_("").font_(Font().size_(9));
		var color = Color.rand;
		var envir = getenvir.();
		//var opendoc;

		envir.keysValuesDo({arg k,v;
			if (k.asString.beginsWith(objName) )  {
				count = count + 1;
			}
		});

		objName = (objName ++ '_' ++ count.asString).asSymbol;

		// if the module provides its own view
		// we can load it directly
		win = View();
		obj = File.open(file, "r").readAllString.interpret;
		if (obj[\view].isNil.not) {
			view = obj[\view].(objName, envir, win);
		} {
			// otherwise we will search for an appropriate view
			var viewObj;
			viewPath = findView.(file);
			viewObj = File.open(viewPath, "r").readAllString.interpret;
			view = viewObj[\view].(objName, envir, obj);
		};

		if (view.isNil) {
			"view object not present %".format(file).debug("loadView");
		} {

			if (view.class == View) {
				win.layout_(VLayout().spacing_(0).margins_(0))
				.palette_(palette)
				.name_(objName)
				.minHeight_(150)
				.minWidth_(150)
				.background_(Color.rand.alpha_(0.1));

				NotificationCenter.register(view, \status, win, {arg msg;
					status.string_(msg);
				});

				/*
				NotificationCenter.register(view, \close, win, {arg msg;
					var key = msg.asSymbol;
					if (docmap[key].isNil.not){
						docmap[key].remove();
					};
					msg.debug("onclose");
				});
				*/

				win.layout.add(
					HLayout(
						StaticText().string_(objName),
						nil,
						if (envir[objName] != nil) {
							DragSource()
							.background_(color)
							.object_((node:envir[objName],name:objName,color:color))
							.string_("-->")
							.fixedSize_(15)
							.font_(Font(size:8))
							.align_(\right);
						}
					).margins_(1).spacing_(1)
				);

				win.layout.add(view);
				win.layout.add(status);

				if (view.onClose.isNil) {
					"adding default close handler".debug("loadView");
					win.onClose_({
						if (envir[objName].class == NodeProxy) {
							envir[objName].clear();
							{
								envir[objName] = nil;
								envir.removeAt(objName);
								"destroy: ".debug(objName);
								envir[objName] = nil;
							}.defer(envir[objName].fadeTime + 1);
						};
						NotificationCenter.notify(view, \close, objName);
					});
				};

				/*
				opendoc = StaticText().string_(objName).mouseUpAction_({
					win.front;
				})
				.stringColor_(Color.white);
				doclist.layout.insert(opendoc, 0);
				docmap[objName] = opendoc;
				*/

				win.front;
			} {
				"% %".format(view.class, file).debug("loadView");
			}
		}
	};

	var show = {arg path;

		var fadeTime = 30;
		var height = 225;
		var width = 200;
		var top = Window.screenBounds.height - height;
		var left = 0;//Window.screenBounds.width - width;
		var fontSize = 10;
		var letterWidth = fontSize * 0.6;

		var draw, scrollView;
		var win = Window("Browser", Rect(left, top, width:width, height:height));
		var view = win.view.layout_(HLayout().margins_(2).spacing_(2)).palette_(palette);
		var envir = getenvir.();

		scrollView = ScrollView()
		.autohidesScrollers_(true)
		.hasVerticalScroller_(true)
		.hasHorizontalScroller_(true);
		scrollView.decorator = FlowLayout(scrollView.bounds);

		// TODO: this needs to be re-written
		// to not use the layout decorator mumbojumbo
		draw = {arg path, view;

			var pathName = PathName.new(path);
			var info = browse.(path);
			var folders = info[0];
			var files = info[1];
			var len = path.size * letterWidth;
			var textWidth = width * 0.9;

			view.removeAll;
			view.decorator.reset;

			if (pathName.fullPath != rootpath) {
				StaticText.new(view, letterWidth@fontSize )
				.string_("^")
				.stringColor_(Color.white)
				.mouseDownAction_({
					draw.(pathName.parentPath, view);
				});
				view.decorator.nextLine;
			};

			folders
			.select({arg p; p.folderName.beginsWith("_").not})
			.do({arg path;

				StaticText.new(view, textWidth@fontSize )
				.string_("> " ++ path.folderName)
				.stringColor_(Color.white)
				.mouseDownAction_({
					draw.(path.fullPath, view);
				});
				view.decorator.nextLine;
			});

			files
			.select({arg p; p.fileName.beginsWith("_").not;})
			.select({arg p; p.fileName.endsWith("scd")})
			.do({arg path;

				StaticText.new(view, letterWidth@fontSize )
				.string_("+ ")
				.stringColor_(Color.white)
				.mouseDownAction_({
					loadView.(path.fullPath);
				});

				StaticText.new(view, textWidth@fontSize )
				.string_(path.fileName)
				.stringColor_(Color.white)
				.mouseDownAction_({
					loadView.(path.fullPath);
				});

				view.decorator.nextLine;
			});
		};

		view.layout.add(VLayout(scrollView));
		//view.layout.add(doclist);
		view.layout.add(
			ServerMeterView.new(s, win, numIns:0, numOuts:2).view.minHeight_(50).minWidth_(75)
		);
		draw.(path, scrollView);
		view.front;
	};

	show.(rootpath);
});

Fdef(\scynapse_components_ctrlview, {arg key, spec, color, envir=(), cb={};

	var controlSpec = spec;
	var myval = envir[key] ?? controlSpec.default;

	var stack, view;
	var font = Font(size:8);
	var li = LevelIndicator().value_(controlSpec.unmap(myval));
	var labelView = StaticText().string_(key ++ ": ").font_(font).stringColor_(Color.white);
	var st = StaticText().string_(myval.trunc(0.001)).font_(font).stringColor_(Color.white);
	var nb = NumberBox()
	.font_(font)
	.value_(myval)
	.background_(Color.white)
	.minDecimals_(3)
	.clipLo_(controlSpec.minval)
	.clipHi_(controlSpec.maxval);
	var dragsrc;

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
				st.string_(mappedVal.trunc(0.001));
				nb.value = mappedVal;
				envir[key] = mappedVal;
				cb.(key, mappedVal);
			};
		})
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			var val = controlSpec.default;
			if (count == 2) {
				li.value = controlSpec.unmap(val);
				st.string_(val.trunc(0.001));
				nb.value = val;
				envir[key] = val;
				cb.(key, val);
			} {
				if (mod == 0) {
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					li.value = val;
					st.string_(mappedVal.trunc(0.001));
					nb.value = mappedVal;
					envir[key] = mappedVal;
					cb.(key, mappedVal);
				};
			};
		}),
		nb
		.action_({arg ctrl;
			var val = ctrl.value;
			li.value = controlSpec.unmap(val);
			st.string_(val);
			envir[key] = val;
			cb.(key, val);
			stack.index = 0;
		}),
	).mode_(\stackOne)
	.margins_(0)
	.spacing_(0);

	dragsrc = {
		var obj = (
			name: key,
			cb:{arg val;
				envir[key] = val;
				cb.(key, val);
				{
					li.value = controlSpec.unmap(val);
					st.string_(val)
				}.defer;
			},
			spec:spec
		);

		DragSource()
		.background_(Color.clear)
		.object_(obj)
		.string_("-->")
		.fixedWidth_(25)
	};

	view = View().layout_(HLayout(
		View()
		.layout_(stack)
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			if (mod == 262144) {
				stack.index = 1;
			}
		}).fixedHeight_(25),
		dragsrc.(),
	).margins_(0).spacing_(1));

	view;

});

Fdef(\scynapse_components_eqview, {arg name, node, envir, containerView;

	var view = View()
	.layout_(VLayout().spacing_(1).margins_(1))
	.background_(Color.grey.alpha_(0.6));
	var userview = UserView();
	var lofreq = 339;
	var hifreq = 4000;
	var minfreq = 20;
	var maxfreq = 11000;
	var mindb = -60;
	var maxdb = 18;
	var midfreq = (lofreq+hifreq)/2;
	var stack, fsv;

	view.layout.add(
		StackLayout(
			ChannelEQ(numChannels:2, bus:node.bus.index, target:node.group)
			.gui.window.view.minHeight_(350/1.6).minWidth_(505/1.5).background_(Color.white.alpha_(0.5)),

			fsv = FreqScopeView()
			.active_(true)
			.freqMode_(1)
			.inBus_(node.bus.index)
		)
		.mode_(1)

	);

	view.onClose_({
		["eqView", fsv].debug("close ");
		fsv.kill;
	});

	view;

});

Fdef(\scynapse_components_specsview, {arg name, specs, node, envir, containerView;

	var ctrlView = Fdef(\scynapse_components_ctrlview);
	var scrollView = ScrollView(bounds:Rect(0,0,160,300));
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2))
	.onClose_({
		specs.do({arg assoc;
			var key = assoc.key;
			node.unset(key);
		});
	});
	var cb = {arg key, val;
		node.set(key, val)
	};

	// TODO: need to do something with this
	var moduleEnvir = ();

	specs.do({arg assoc;
		var k = assoc.key;
		var v = assoc.value;
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, moduleEnvir, cb);
		view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	scrollView;
});

Fdef(\scynapse_components_pspecsview, {arg name, specs, envir, containerView;

	var ctrlView = Fdef(\scynapse_components_ctrlview);
	var scrollView = ScrollView();
	var view = View().layout_(VLayout().margins_(0.5).spacing_(0.5));

	specs.do({arg assoc;
		var k = assoc.key;
		var v = assoc.value;
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, envir);
		view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	scrollView;
});

Fdef(\scynapse_components_playview, {arg name, node, containerView;

	var height = 20;
	var view = View().layout_(HLayout().margins_(1).spacing_(1)).background_(Color.rand.alpha_(0.2));
	var outBus = 0;
	var privateBus = node.bus.index;

	view.layout.add(
		Knob()
		.fixedSize_(size)
		.mode_(\vert)
		.value_(1.linlin(0,4,0,1))
		.action_({arg ctrl;
			var val = ctrl.value.linlin(0,1,0,4);
			NotificationCenter.notify(containerView, \status, "vol: " ++ val.asString);
			node.vol = val;
		})
	);

	view.layout.add(
		NumberBox()
		.fixedSize_(size)
		.alt_scale_(0.01)
		.ctrl_scale_(0.1)
		.shift_scale_(1)
		.value_(1)
		.normalColor_(Color.grey)
		.action_({arg ctrl;
			var val = ctrl.value;
			node.fadeTime = val;
			NotificationCenter.notify(containerView, \status, "fadetime: " ++ val.asString);
		})
	);

	view.layout.add(
		Button()
		.fixedSize_(size)
		.states_([ [nil, Color.green, Color.green], [nil, Color.red, Color.red] ])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				node.play(fadeTime:node.fadeTime, out:outBus);
			} {
				node.stop(fadeTime:node.fadeTime);
			}
		})
	);

	view.layout.add(
		NumberBox()
		.fixedSize_(size)
		.value_(0)
		.action_({arg ctrl;
			var val = ctrl.value;
			outBus = val;
			NotificationCenter.notify(containerView, \status, "out: " ++ val.asString);
		})
		.normalColor_(Color.grey)
		.value_(0);
	);

	view.layout.add(nil);
	view;
});

Fdef(\scynapse_components_multiinputsview, {arg node, mainView;

	var view = View().layout_(VLayout().spacing_(1).margins_(1));

	var addRow = {

		var menuaction = MenuAction();
		var row = View().layout_(HLayout().spacing_(1).margins_(1));
		var dragSink;
		var num = -1;
		var name = "";

		dragSink = UserView()
		.drawFunc_({
			var size = 10;
			var width = 1;
			Pen.color = Color.black;
			Pen.width = width;
			Pen.strokeOval(Rect(2,3,size,size))
		})
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var node = obj[\node];
			(node.rate == \audio);
		})
		.fixedWidth_(size)
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var input = obj[\node];
			var color = obj[\color];
			var msg;

			name = obj[\name];
			msg = "inuput: " ++ name;

			menuaction.string = name;

			if (num < 0) {
				num = node.objects.indices.select({arg val; val < 100}).last ? num;
				num = num + 1;
			};

			node[num] = \mix -> { input.ar; };
			if (color.isNil) {
				color = Color.gray;
			};

			dragSink.drawFunc_({
				var size = 10;
				var width = 1;
				Pen.color = color;
				Pen.width = width;
				Pen.fillOval(Rect(2,2,size,size))
			});
			dragSink.refresh;

			NotificationCenter.notify(mainView, \status, msg);
		})
		.fixedHeight_(size);

		dragSink.setContextMenuActions(
			menuaction
		);

		row.layout.add(dragSink);

		row.layout.add(

			LevelIndicator(bounds:Rect(width:20, height:18))
			.style_(\led)
			.meterColor_(Color.blue().alpha_(1))
			.warningColor_(Color.blue().alpha_(1))
			.criticalColor_(Color.blue().alpha_(1))
			.numSteps_(10)
			.fixedHeight_(15)
			.mouseMoveAction_({arg ctrl, x, y, modifiers;
				var val = x.linlin(0, ctrl.bounds.width, 0, 1);
				var msg = "";
				if (num >= 0) {
					var key = ('mix' ++ num).asSymbol;
					node.set(key, val);
					msg = "mix % %".format(name, val);
					ctrl.value = val;
					NotificationCenter.notify(mainView, \status, msg);
				}
			})
			.mouseUpAction_({arg ctrl, x, y, modifiers;
				var val = x.linlin(0, ctrl.bounds.width, 0, 1);
				var msg = "";
				if (num >= 0) {
					var key = ('mix' ++ num).asSymbol;
					node.set(key, val);
					msg = "mix % %".format(name, val);
					ctrl.value = val;
					NotificationCenter.notify(mainView, \status, msg);
				}
			})
			.value_(1)
		);

		row.layout.add(Button().string_("+").action_({
			addRow.();
		}).fixedSize_(size));

		row.layout.add(Button().string_("-").action_({

			row.remove();
			if (num >= 0) {

				var msg = "remove %".format(name);
				node[num] = nil;
				NotificationCenter.notify(mainView, \status, msg);
			};

			if (view.children.size == 0) {
				addRow.();
			};

			{
				var sizeHint = view.sizeHint;
				view.resizeTo(sizeHint.width, sizeHint.height)
			}.defer(0.001)

		}).fixedSize_(size));
		view.layout.add(row);
	};
	addRow.();
	view;
});
)
