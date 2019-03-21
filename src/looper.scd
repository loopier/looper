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
~clearBuffer = {|loopnum| ~buffers[loopnum].zero;};

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


~setTempo = { |tempo|
	~tempo = tempo;
	~loops.do { |loop|
		loop.set(\clock, ~tempo);
		// rescale dur
		loop.get(\dur, { |dur| loop.set(\dur, dur) });
	}
};

// max duration of the loops
~setMaxLoopDur = { |seconds|
	~masterLoopDur = seconds;
	~setTempo.value(1/seconds)
};

// un-normalize parameters
~paramsMap = (
	\rate: { | value | value.linlin(0.0, 1.0, -4.0, 4.0).asStringPrec(2).asFloat},
	\start: { | value | value},
	// \dur: { | value | value.linlin(0.0, 1.0, 0, 1024).asInt / 256},
	\dur: { | value | value.asStringPrec(2).asFloat},
	\amp: { | value | value.linexp(0.0, 1.0, 0.001, 1.0) - 0.001},
	\feedback: { | value | value.linlin(0.0, 1.0, 0.0, 1.27)},
	\rec: { | value | value},
	\erase: { | value | value}, // 0=1, 1=0
	\clearBuf: { | value | value},
	\t_reset: { | value | value},
	\reset: { | value | value},
	\sync: { | value | value},
);

// Input values must be normalized
~set = {|loopnum, param, value|
	value = ~paramsMap[param].value(value);

	switch (param,
		{\sync}, {~sync.value(loopnum)},
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

