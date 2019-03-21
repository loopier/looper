"looper-setup.scd".loadRelative;
(
s.freeAll;
~tempo = TempoClock(1);
~buffers = ();
~buflength = 16.0; // seconds
8.do {|i| ~buffers.put(i, Buffer.alloc(s, ~buflength * s.sampleRate)); };
)
(
~loops = ();
~loops.collect(_.free);
~loopdur = 4;
~clock = Synth(\clock, [tempo:~buflength * (~loopdur / ~buflength)]);
~buffers.size.do { |i|
	// ~loops.put( i, Synth(\loop, [in:2, bufnum: ~buffers[i]])	);
	var bufnum = ~buffers[i];
	~loops.put( i, Synth(\bufrd, [in:2, bufnum: bufnum, dur: ~loopdur]));
	[i, bufnum].postln;
};

~sync = {|loopnum| ~tempo.playNextBar(~loops[loopnum].set(\t_reset, 1));};
~clearBuffer = {|loopnum| ~buffers[loopnum].zero;};

~reset = {|loopnum|
	~tempo.schedAbs( ~tempo.beats.ceil, {
		["reset: "++loopnum].postln;

		// ~loops[loopnum].set(\t_reset, 1);
		~loops[loopnum].set(\amp, 1);
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
		~sync.value(loopnum);
	});
};

~erase = {|loopnum, value|
	// TODO: it would be nice to get the actual parameters of amp, reclevel and feedback to restore them after erasing

	// recording needs to be on when erasing, so value needs to be inverted
	~loops[loopnum].set(\rec, (value-1).abs);
	~loops[loopnum].set(\amp, value);
	~loops[loopnum].set(\reclevel, value);
	~loops[loopnum].set(\feedback, value);
};

// un-normalize parameters
~paramsMap = (
	\rate: { | value | value.linlin(0.0, 1.0, -4.0, 4.0)},
	\start: { | value | value},
	// \dur: { | value | value.linlin(0.0, 1.0, 0, 1024).asInt / 256},
	\dur: { | value | value},
	\amp: { | value | value.linexp(0.0, 1.0, 0.001, 1.0) - 0.001},
	\feedback: { | value | value.linlin(0.0, 1.0, 0.0, 1.27)},
	\rec: { | value | value},
	\erase: { | value | (value-1).abs}, // 0=1, 1=0
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

