"looper-setup.scd".loadRelative;
(
s.freeAll;
~tempo = TempoClock(1);
~buffers = ();
8.do {|i| ~buffers.put(i, Buffer.alloc(s, 4.0 * s.sampleRate)); };
)
(
~loops = ();
~tempo.schedAbs(~tempo.beats.ceil, {
	~sync = Synth(\clock, [tempo:4]);
	~buffers.size.do { |i|
		// ~loops.put( i, Synth(\loop, [in:2, bufnum: ~buffers[i]])	);
		~loops.put( i, Synth(\bufrd, [in:2, bufnum: ~buffers[i]])	);
	};
});
i = Synth(\mic, [out:2]);
"looper-nanoktl.scd".loadRelative;
)


/*
MIDIIn.connectAll;
MIDIIn.disconnectAll
MIDIFunc.cc({arg ...args; args.postln});*/
b.zero
(
s.freeAll;
b = Buffer.alloc(s, 4 * s.sampleRate)!2;
t = TempoClock(1);
)
(
t.schedAbs(t.beats.ceil, {
	a = Synth(\bufrd, [in:2, bufnum:b[0], rec:1, feedback:0.95]);
	e = Synth(\bufrd, [in:2, bufnum:b[1], rec:1, feedback:0.95]);
	c = Synth(\clock);
});
)
c.set(\rate, 0.5);
c.set(\rate, 1);
c.set(\rate, 2);
t.schedAbs(t.nextBar, {a.set(\t_reset, 1);});
t.schedAbs(t.nextBar, {e.set(\t_reset, 1);});
e.set(\t_reset, 1);
a.set(\rec, 0);
e.set(\rec, 0);
a.set(\rec, 1);
a.set(\rate, -1);
a.set(\loop, 0)
a.set(\feedback, 1);
a.set(\feedback, 0.5);
a.set(\feedback, 0);
a.set(\rate, 0.5);
a.set(\rate, 1);
a.set(\rate, 4);
a.set(\sync, 0);
a.set(\sync, 1);
c.set(\sync, 1);
a.set(\dur, 8);
a.free; b.zero;
s.meter


