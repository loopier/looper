// s.options.inDevice = "Built-in Input";
s.options.memSize = s.options.memSize * 2;
s.boot.meter;
s.meter;
s.scope(2).style_(2).window.bounds_(Rect(0,1024, 400,400));

s.waitForBoot {
/*	~buffers = ();
	8.do {|i| ~buffers.put(i, Buffer.alloc(s, 4.0 * s.sampleRate)); };*/

	SynthDef(\loop, {
		var out = \out.kr(0);
		var pan = \pan.kr(0);
		var in = In.ar(\in.ar(0));
		var amp = \amp.kr(1);
		var feedback = \feedback.kr(1);
		var rec = \rec.kr(0);
		var reclevel = \reclevel.kr(1);
		var prelevel = feedback;
		var dur = \dur.kr(1);
		var bufnum = \bufnum.kr(0);
		var rate = \rate.kr(1);
		var trigger = \trig.kr(1);
		var startpos = \startpos.kr(0) * BufFrames.kr(bufnum);
		var loop = \loop.kr(1);
		var play = PlayBuf.ar(1, bufnum, rate, trigger, startpos, loop, doneAction:0);
		var sig = (play+(in * prelevel * rec)) * amp;
		RecordBuf.ar(in, bufnum, 0, reclevel, prelevel, run:rec, loop:loop, /*trigger:trig,*/ doneAction:0);
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	SynthDef(\bufrd, {
		var out = \out.kr(0);
		var pan = \pan.kr(0);
		var amp = \amp.kr(1);
		// var syncbus = \syncbus.kr(2);
		// var sync = \sync.kr(1);
		var clock = \clock.kr(TempoClock.default.tempo);

		var bufnum = \bufnum.kr(0);
		var rate = \rate.kr(1);
		var t_reset = \t_reset.kr(0);
		var start = \start.kr(0);
		var dur = \dur.kr(1);
		var phase = \phase.kr(0);
		var loop = \loop.kr(0);

		var in = In.ar(\in.ar(2));
		var rec = \rec.kr(0);
		var reclevel = \reclevel.kr(1);
		var feedback = \feedback.kr(1);

		var sig, sigrec, pos, end, resetpos, synctrig;
		// synctrig = In.kr(syncbus);
		// dur = BufDur.kr(buf) * dur;
		rate = BufRateScale.kr(bufnum) * rate;
		resetpos = BufFrames.kr(bufnum) * start;
		// dur = BufDur.kr(bufnum) * dur;
		end = BufFrames.kr(bufnum) * min((start + dur), 1);
		// phase = BufFrames.kr(buf) * phase;
		pos = Phasor.ar(
			trig: Impulse.kr(clock) + t_reset,
			// trig: synctrig+ t_reset,
			// trig: PulseDivider.kr(synctrig, dur) + t_reset,
			rate: rate,
			start: resetpos,
			end: end,
			resetPos:resetpos
		);
		sig = BufRd.ar(1, bufnum, pos, loop);

		BufWr.ar((in * rec * (reclevel/2)) + (sig * feedback), bufnum, pos, loop);

		sig = sig * amp;

		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	SynthDef(\mic, {|out=0, pan=0, amp=1|
		var sig;
		sig = SoundIn.ar * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef(\clock, {
		var tempo = \tempo.kr(1);
		var out = \out.kr(2);
		Out.kr(out, Impulse.kr(1/tempo));
	}).add;

	SynthDef(\metronome, {
		var clock = In.kr(\clockbus.kr(2));
		var out = \out.kr(0);
		var amp = \amp.kr(1);
		var beatsPerBar = \beatsPerBar.kr(4);
		var sig = Decay.kr([clock, PulseDivider.kr(clock, beatsPerBar)], 0.1) * SinOsc.ar([660, 880], 0, 0.1);
		Out.ar(out, sig.sum);
	}).add;
};