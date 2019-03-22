~ktl.free;
~ktl = NanoKtl.new;
~nanoktlparams = (
	// index of each symbol corresponds to scene number.
	// So first symbol will correspond to \kn1.
	// \controlname: [scene1param, scene2param, scene3param, scene4param]

	// main buttons
	// \rew: '0_47',
	// \play: '0_45',
	// \fwd: '0_48',
	// \loop: '0_49',
	// \stop: '0_46',
	// \rec: '0_44',

	\kn: [ \rate,  \dur, nil, nil],
	\sl: [ \amp,  \start, \feedback, nil],
	\bu: [ \rec,  \reset, \metro, \resize],
	\bd: [ \erase, \clearBuf,  nil, \stretch],
);
4.do { |scene|
	scene = scene + 1;
	// ["......................", "scene: "++scene].postln;
	8.do { |i|
		[\kn, \sl, \bu, \bd].do { |ktl|
			var index = i + 1;
			var ktlname = (ktl++index).asSymbol;
			var param = ~nanoktlparams[ktl].asArray[scene-1];
			if (param != nil) {
				[ktlname, param].postln;
				~ktl.mapCCS( scene, ktlname, { |val| ~set.value(i, param, val.linlin(0, 127, 0.0, 1.0)); });
			};
		};
	}
};

// set max buffer dur
~ktl.mapCCS(4, \kn9, { |val| ~setMaxLoopDur.value(val.linlin(0, 127, 0.0, 16.0).asStringPrec(2).asFloat)});
// stretch
// ~ktl.mapCCS( 1, \sl9, { |val| ~setMaxLoopDur.value(val.linlin(0, 127, 0.0, 16.0).asStringPrec(2).asFloat, true); });
// ~ktl.mapCCS( 1, \bu9, { |val| ~isStretched = val.asBoolean; });
// ~ktl.mapCCS( 1, \bd9, { |val| ~isStretched = val.asBoolean; });
~ktl.mapCCS(0, \rec, ~clearAll);
~ktl.mapCCS(0, \loop, ~resetAll);

~nanoktlparams[\bd][3]