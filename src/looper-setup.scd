// s.options.inDevice = "Built-in Input";
s.options.memSize = s.options.memSize * 2;
s.boot.meter;
s.meter;
s.scope(2).style_(2).window.bounds_(Rect(0,1024, 400,400));
s.makeWindow;

s.waitForBoot {
	"looper-synthdefs.scd".loadRelative;
	"loading synthdefs".postln;
	s.sync;

	"synthdefs loaded".postln;
	s.freeAll;
	~tempo = TempoClock.default.tempo;
	~buffers = ();
	~buflength = 16.0; // seconds
	8.do {|i| ~buffers.put(i, Buffer.alloc(s, ~buflength * s.sampleRate)); };

	s.sync;

	"looper.scd".loadRelative;

	s.sync;

	"looper-nanoktl.scd".loadRelative;
};