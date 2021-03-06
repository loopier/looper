// TODO: Refurbish
// - Use toggles for active/inactive loops (lock?)
// - Active loops may be modified by controls, inactive will not be modified

~loops = ();
~loops.collect(_.free);
~masterLoopDur = nil;
~setMasterLoopDur.value(1);
~buffers.size.do { |i|
	var bufnum = ~buffers[i];
	~loops.put( i, Synth(\bufrd, [in:2, bufnum: bufnum, clock:~tempo]));
	[i, bufnum].postln;
};

~sync = {|loopnum| ~tempo.playNextBar(~loops[loopnum].set(\t_reset, 1));};
~clearBuffer = {|loopnum| ~buffers[loopnum].zero; ["clear: "++loopnum].postln;};
~clearAll = {|loopnum| ~buffers.do { |buf| buf.zero;}; ["clear all"].postln;};

~reset = {|loopnum|
	["reset: "++loopnum].postln;

	~loops[loopnum].set(\amp, 0.25);
	~loops[loopnum].set(\out, 0);
	~loops[loopnum].set(\pan, 0);
	~loops[loopnum].set(\feedback, 1);
	~loops[loopnum].set(\reclevel, 1);
	~loops[loopnum].set(\rate, 1);
	~loops[loopnum].set(\dur, 1);
	~loops[loopnum].set(\start, 0);
	~loops[loopnum].set(\rec, 0);
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

// register loops to be stretched when resizing master loop duration
~stretchLoops = Array.fill(~loops.size, false);
// register loops to be resized when resizing master loop duration
~resizeLoops = Array.fill(~loops.size, false);
// param seconds INT     Duration time in seconds
// param stretch   BOOL  Stretch loops (changing rate)
~setMaxLoopDur = { |seconds, stretch|
	var rateRatio;
	seconds = max(seconds, 0.01);
	if (stretch == nil) {stretch = ~isStretched};

	rateRatio = seconds / if(~masterLoopDur != nil, ~masterLoopDur, seconds);

	~masterLoopDur = seconds;

	~tempo = 1/seconds;
	~loops.do { |loop, index|
		// rescale parameters
		loop.get(\dur, { |dur| loop.set(\dur, dur);});


		if (~resizeLoops[index]) {
			// FIX: loop.set(...) doesn't work (?)
			~loops[index].set(\clock, ~tempo);
		};
		// FIX: Stretch scaling is not very precise
		if (~stretchLoops[index]) {// FIX: loop.set(...) doesn't work (?)
			~loops[index].get(\rate, { |rate|
			~loops[index].set(\clock, ~tempo);
				// FIX: loop.set(...) doesn't work (?)
				~loops[index].set(\rate, (rate / rateRatio));
				// [index, rate.asStringPrec(2)].postln;
			})
		};
	};

	["seconds: "++seconds, "masterdur: "++~masterLoopDur, "tempo: "++~tempo.asStringPrec(2)].postln;
};

// un-normalize parameters
~paramsMap = (
	\rate: { | value | value.linlin(0.0, 1.0, -4.0, 4.0).asStringPrec(2).asFloat},
	\start: { | value | value},
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
	\resize: { | value | (value > 0)},
	\stretch: { | value | (value > 0)},
);
// Input values must be normalized
~set = {|loopnum, param, value|
	value = ~paramsMap[param].value(value);

	switch (param,
		{\stretch}, {~stretchLoops[loopnum] = value},
		{\resize}, {~resizeLoops[loopnum] = value},
		{\clearBuf}, {~clearBuffer.value(loopnum)},
		{\reset}, {~reset.value(loopnum)},
		{\erase}, {~erase.value(loopnum, value)},
		{~loops[loopnum].set(param.asSymbol, value)}
	);

	["loop: "++loopnum, param++": "++value].postln;
};

~sndInput = Synth(\mic, [out:2]);

