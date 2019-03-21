~ktl.free;
~ktl = NanoKtl.new;
~nanoktlparams = (
	// index of each symbol corresponds to scene number.
	// So first symbol will correspond to \kn1.
	// \controlname: [scene1param, scene2param, scene3param, scene4param]
	\kn: [ \rate,  \dur, nil, nil],
	\sl: [ \amp,  \start, \feedback, nil],
	\bu: [ \rec,  \t_reset,  \reset, nil],
	\bd: [ \erase, \sync,  \clearBuf,  nil],
);
4.do { |scene|
	["......................", "scene: "++scene].postln;
	8.do { |i|
		[\kn, \sl, \bu, \bd].do { |ktl|
			var index = i + 1;
			var ktlname = (ktl++index).asSymbol;
			var param = ~nanoktlparams[ktl].asArray[scene-1];
			if (param != nil) {
				// ["ktl: "++ktl, "sc: "++scene, "ktlname: "++ktlname, "param: "++param].postln;
				[ktlname, param].postln;
				~ktl.mapCCS( scene, ktlname, { |val| ~set.value(i, param, val.linlin(0, 127, 0.0, 1.0)); });
			};
		};
	}
};

// ~ktl.free;