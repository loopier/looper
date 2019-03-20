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
~loopdur = 4;
~clock = Synth(\clock, [tempo:~buflength * (~loopdur / ~buflength)]);
~buffers.size.do { |i|
	// ~loops.put( i, Synth(\loop, [in:2, bufnum: ~buffers[i]])	);
	var bufnum = ~buffers[i];
	~loops.put( i, Synth(\bufrd, [in:2, bufnum: bufnum, dur: ~loopdur]));
	[i, bufnum].postln;
};

~set = {|loopnum, param, value| ~loops[loopnum].set(param.asSymbol, value); ["loop: "++loopnum, param++": "++value].postln};
~sync = {|loopnum| ~tempo.playNextBar(~loops[loopnum].set(\t_reset, 1)); ["sync: "++loopnum].postln;};
~clearBuffer = {|loopnum| ~buffers[loopnum].zero; ["clearbuffer: "++loopnum].postln};
~reset = {|loopnum|
	~tempo.schedAbs( ~tempo.beats.ceil, {
		["reset: "++loopnum].postln;

		~loops[loopnum].set(\t_reset, 1);
		~loops[loopnum].set(\amp, 1);
		~loops[loopnum].set(\out, 0);
		~loops[loopnum].set(\pan, 0);
		~loops[loopnum].set(\feedback, 1);
		~loops[loopnum].set(\prelevel, 0.5);
		~loops[loopnum].set(\rate, 1);
		~loops[loopnum].set(\dur, ~loopdur);
		~loops[loopnum].set(\start, 0);
		~loops[loopnum].set(\rec, 0);
		// ~loops[loopnum].set(\loop, 0);
		// ~clearBuffer.value(loopnum);
	});
};

i = Synth(\mic, [out:2]);
"looper-nanoktl.scd".loadRelative;
)



~set.value(1, \loop, 1)
~set.value(1, \loop, 0)
~set.value(1, \dur, 2)
~set.value(4, \loop, 1)
~clock.set(\tempo, 4)
~clock.free

