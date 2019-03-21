// s.options.inDevice = "Built-in Input";
s.options.memSize = s.options.memSize * 2;
s.boot.meter;
s.meter;
s.scope(2).style_(2).window.bounds_(Rect(0,1024, 400,400));

s.waitForBoot {
	SynthDef(\bufrd, {
		var out = \out.kr(0);
		var pan = \pan.kr(0);
		var amp = \amp.kr(1);
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

		var metro = \metro.kr(0);
		var metroBeatsPerBar = \metroBeatsPerBar.kr(4);

		var clocktrig, sig, metrosig, pos, end, resetpos;

		clocktrig = Impulse.kr(clock) + t_reset;
		rate = BufRateScale.kr(bufnum) * rate;
		resetpos = BufFrames.kr(bufnum) * start;
		end = BufFrames.kr(bufnum) * min((start + dur), 1);
		pos = Phasor.ar(
			trig: clocktrig,
			rate: rate,
			start: resetpos,
			end: end,
			resetPos:resetpos
		);

		sig = BufRd.ar(1, bufnum, pos, loop);
		metrosig = Decay.kr([clocktrig, PulseDivider.kr(clocktrig, metroBeatsPerBar)], 0.1) * SinOsc.ar([660, 880], 0, 0.1) * metro;

		BufWr.ar((in * rec * (reclevel/2)) + (sig * feedback), bufnum, pos, loop);

		sig = (sig * amp) + metrosig;

		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	SynthDef(\mic, {|out=0, pan=0, amp=1|
		var sig;
		sig = SoundIn.ar * amp;
		Out.ar(out, sig);
	}).add;
};