"looper-setup.scd".loadRelative;
(
s.freeAll;
~tempo = TempoClock.default.tempo;
~buffers = ();
~buflength = 16.0; // seconds
8.do {|i| ~buffers.put(i, Buffer.alloc(s, ~buflength * s.sampleRate)); };
)
(
~loops = ();
~loops.collect(_.free);
~masterLoopDur = nil;
~setMasterLoopDur.value(4);
~buffers.size.do { |i|
	// ~loops.put( i, Synth(\loop, [in:2, bufnum: ~buffers[i]])	);
	var bufnum = ~buffers[i];
	~loops.put( i, Synth(\bufrd, [in:2, bufnum: bufnum, clock:~tempo]));
	[i, bufnum].postln;
};

~sync = {|loopnum| ~tempo.playNextBar(~loops[loopnum].set(\t_reset, 1));};
~clearBuffer = {|loopnum| ~buffers[loopnum].zero; ["clear: "++loopnum].postln;};
~clearAll = {|loopnum| ~buffers.do { |buf| buf.zero;}; ["clear all"].postln;};

~reset = {|loopnum|
	// ~tempo.schedAbs( ~tempo.nextBeat, {
	["reset: "++loopnum].postln;

	// ~loops[loopnum].set(\t_reset, 1);
	~loops[loopnum].set(\amp, 0.5);
	~loops[loopnum].set(\out, 0);
	~loops[loopnum].set(\pan, 0);
	~loops[loopnum].set(\feedback, 1);
	~loops[loopnum].set(\reclevel, 1);
	~loops[loopnum].set(\rate, 1);
	~loops[loopnum].set(\dur, 1);
	~loops[loopnum].set(\start, 0);
	~loops[loopnum].set(\rec, 0);
	// ~loops[loopnum].set(\loop, 0);
	// ~clearBuffer.value(loopnum);
	// ~sync.value(loopnum);
	// });
};
~resetAll = {|loopnum| ~loops.size.do { |loopnum| ~reset.value(loopnum);}; };

~valuesBuffer = (
	\amp: 0,
	\reclevel: 0,
	\feedback: 0,
);

~erase = {|loopnum, value|
	~valuesBuffer.keys.do { |param|
		~loops[loopnum].get(param, { |old|
			var paramvalue;
			if (value > 0) {
				paramvalue = 0;
				~valuesBuffer[param] = old;
			} {
				paramvalue = ~valuesBuffer[param];
			};
			~loops[loopnum].set(param, paramvalue);
			["erasing: "++(value.asBoolean), "\\"++param, "old: "++old, "val: "++paramvalue].postln;
		});
	};
	// recording needs to be on when erasing, so value needs to be inverted
	~loops[loopnum].set(\rec, (value-1).abs);
};

~toggleMetro = {|loopnum, value| ~loops[loopnum].set(\metro, (value > 0))};

// max duration of the loops
~isStretched = false; // used by controls
~setMaxLoopDur = { |seconds, stretch|
	var rateRatio = seconds / if(~masterLoopDur != nil, ~masterLoopDur, seconds);
	// rateRatio.postln;
	if (stretch == nil) {stretch = ~isStretched};
	["seconds: "++seconds, "stretch: "++stretch].postln;
	~masterLoopDur = seconds;
	// ~setTempo.value(1/seconds)

	~tempo = 1/seconds;
	~loops.do { |loop|
		loop.set(\clock, ~tempo);
		// rescale parameters
		loop.get(\dur, { |dur| loop.set(\dur, dur); });
		// FIX: Stretch scaling is not very precise
		if (stretch) { loop.get(\rate, { |rate| loop.set(\rate, (rate / rateRatio)); rate.asStringPrec(2).postln;}) };
	}

	// ["seconds: "++seconds, "dur: "++~masterLoopDur, "ratio: "++rateRatio].postln;
};

// un-normalize parameters
~paramsMap = (
	\rate: { | value | value.linlin(0.0, 1.0, -4.0, 4.0).asStringPrec(2).asFloat},
	\start: { | value | value},
	// \dur: { | value | value.linlin(0.0, 1.0, 0, 1024).asInt / 256},
	\dur: { | value | value.linlin(0.0, 1.0 * ~masterLoopDur, 0.001, 1.0).asStringPrec(2).asFloat},
	\amp: { | value | value.linexp(0.0, 1.0, 0.001, 1.0) - 0.001},
	\feedback: { | value | value.linlin(0.0, 1.0, 0.0, 1.27)},
	\rec: { | value | value},
	\erase: { | value | value}, // 0=1, 1=0
	\clearBuf: { | value | value},
	\t_reset: { | value | value},
	\reset: { | value | value},
	\sync: { | value | value},
	\maxdur: { | value | value},
	\metro: { | value | (value > 0)},
);

// Input values must be normalized
~set = {|loopnum, param, value|
	value = ~paramsMap[param].value(value);

	switch (param,
		{\clearBuf}, {~clearBuffer.value(loopnum)},
		{\reset}, {~reset.value(loopnum)},
		{\erase}, {~erase.value(loopnum, value)},
		{~loops[loopnum].set(param.asSymbol, value)}
	);

	["loop: "++loopnum, param++": "++value].postln;
};

~sndInput = Synth(\mic, [out:2]);
"looper-nanoktl.scd".loadRelative;
)

