(
var rootpath = PathName(Document.current.path).parentPath;
var viewsPath = rootpath ++ "_views/";
var recorders = List.new;
var envir = if (~p.isNil.not) { ~p.envir } { currentEnvironment };

// init
var init = {
	"init".postln;
	Font.setDefault(Font("Courier New", 10));
	~bufs = ~bufs ? ();
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

var alwaysOnTop = {arg view;

	Button().states_([ ["--"], ["__"] ]).action_({arg ctrl;
		if (ctrl.value == 1) {
			view.alwaysOnTop = true;
		}{
			view.alwaysOnTop = false;
		}
	}).maxSize_(15);
};

var recordStems = {

	var key = Date.getDate.asSortableString;

	"recordStems".postln;

	envir.keysValuesDo({arg k,v;
		if (v.class == NodeProxy) {
			if (v.rate == \audio) {
				var rec;
				var folder = Platform.recordingsDir ++ "/stems/" ++ key ++ "/";
				//folder.debug("recording stems");
				if (File.exists(folder).not) {
					File.mkdir(folder)
				};
				rec = v.record(folder ++ k ++ ".aiff");
				recorders.add(rec);
			}
		}
	});

	{
		recorders.do({arg rec;
			rec.unpause;
		});
	}.defer(1);

};

var stopRecordStems = {

	recorders.do({arg rec;
		rec.pause;
		rec.close;
		rec.free;
		rec = nil;
	});

	recorders = List.new;
};

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
	var components = File.open(rootpath ++ "_components.scd", "r").readAllString.interpret;
	var win, obj;
	var status = StaticText().string_("").font_(Font().size_(9));
	var color = Color.rand;

	envir.keysValuesDo({arg k,v;
		if (v.class == NodeProxy and: k.asString.beginsWith(objName) )  {
			count = count + 1;
		}
	});

	objName = (objName ++ count.asString).asSymbol;

	// if the module provides its own view
	// we can load it directly
	obj = File.open(file, "r").readAllString.interpret;
	if (obj[\view].isNil.not) {
		view = obj[\view].(objName, envir, components);
	} {
		// otherwise we will search for an appropriate view
		var viewObj;
		viewPath = findView.(file);
		viewObj = File.open(viewPath, "r").readAllString.interpret;
		view = viewObj[\view].(objName, envir, obj, components);
	};

	if (view.isNil) {
		"view object not present %".format(file).debug("loadView");
	} {

		if (view.class == View) {
			win = View().layout_(VLayout().spacing_(1).margins_(1)).palette_(QPalette.dark).name_(objName);//.minWidth_(300);

			NotificationCenter.register(view, \status, win, {arg msg;
				status.string_(msg);
			});

			win.layout.add(
				HLayout(
					alwaysOnTop.(win),
					StaticText().string_(objName ++
						if (envir[objName].isNil.not) {
							" (bus: " ++ envir[objName].bus.index.asString ++ ")";
						}{
							""
						}
					),
					if (envir[objName] != nil) {
						DragSource()
						.background_(color)
						.object_((node:envir[objName],name:objName,color:color))
						.string_("-->")
						.maxWidth_(30)
						.minWidth_(30)
						.align_(\right)
					}
				)
			);

			//win.backgroundImage_(Image.new("/Users/david/projects/droptableuser/images/OwDjxLVFZ9rTkVlpNvwsrNgk_dreamt.jpg"));
			win.layout.add(view);
			win.layout.add(status);
			win.front;
		} {
			"% %".format(view.class, file).debug("loadView");
		}
	}
};

var show = {arg path;

	var fadeTime = 30;
	var height = 250;
	var width = 300;
	var top = Window.screenBounds.height - height;
	var left = Window.screenBounds.width - width;
	var fontSize = 10;
	var letterWidth = fontSize * 0.6;

	var draw, scrollView;
	var win = Window("Browser", Rect(left, top, width, height));
	var view = win.view.layout_(HLayout().margins_(2).spacing_(2)).palette_(QPalette.dark);
	//.backgroundImage_(Image.new("/Users/david/projects/droptableuser/images/OwDjxLVFZ9rTkVlpNvwsrNgk_dreamt.jpg"));

	var ctrlView = View().layout_(HLayout(

		Button()
		.states_([ ["--"], ["__"] ]).action_({arg ctrl;
			if (ctrl.value == 1) {
				view.alwaysOnTop = true;
			}{
				view.alwaysOnTop = false;
			}
		})
		.fixedSize_(20@20),

		Button()
		.states_([ ["rec"], ["stop", Color.red] ] )
		.action_({arg ctrl; if (ctrl.value == 1) {s.record} {s.stopRecording} })
		.fixedSize_(35@20),

		Button()
		.states_([ ["stems"], ["stop", Color.red] ] )
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				recordStems.();
			} {
				stopRecordStems.();
			}
		})
		.fixedSize_(40@20),

		NumberBox().action_({arg ctrl;
			fadeTime = ctrl.value;
		})
		.value_(fadeTime)
		.normalColor_(Color.white)
		.fixedSize_(25@20),

		Button().states_([["[]"]]).action_({
			envir.keysValuesDo({arg k, v;
				v.stop(fadeTime:fadeTime);
			})
		})
		.fixedSize_(20@20);
	));

	scrollView = ScrollView()
	.autohidesScrollers_(true)
	.hasVerticalScroller_(true)
	.hasHorizontalScroller_(true);
	scrollView.decorator = FlowLayout(scrollView.bounds);

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

	view.layout.add(VLayout(ctrlView, scrollView));
	view.layout.add(
		ServerMeterView.new(s, win, numIns:0, numOuts:2).view.minHeight_(50).minWidth_(75)
	);
	draw.(path, scrollView);
	view.front;
};

show.(rootpath);
)




