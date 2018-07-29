(
w = Window("TEST", Rect(0, 0, 300, 300));
x = View(w);
y = View(w);
z = View(w);
q = Stethoscope.new(server:s, numChannels:2, index:0, bufsize:4096,
zoom:1, rate:'audio', view:x, bufnum:1);
r = FreqScopeView.new(parent:y, bounds:Rect(), server:s);
t = ServerMeterView.new(aserver:s, parent:z, leftUp:0@0, numIns:2, numOuts:2);
w.layout_(HLayout(x, y, z));
w.front;
)


(
var scopeParent, freqScopeParent, meterParent, scope, freq, meter;

w = Window("TEST", Rect(0, 0, 300, 300));
w.layout = HLayout(
    scopeParent = View(),  // don't need (w) here
    freqScopeParent = View(),
    meterParent = View()
);

scope = Stethoscope(server: s, numChannels: 2, index: 0, bufsize:
4096, zoom: 1, rate: 'audio', view: scopeParent, bufnum: 1);
freq = FreqScopeView(parent: freqScopeParent, bounds: Rect(), server: s);
meter = ServerMeterView(aserver: s, parent: meterParent, leftUp: 0@0,
numIns: 2, numOuts: 2);

w.front;
)