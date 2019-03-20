~ktl = NanoKtl.new;
4.do { |scene|
	8.do { |i|
		var index = i+1;
		~ktl.mapCCS(scene, ('kn'++(index)).asSymbol, {|ch, cc, val|
			var value;
			"sc % kn %: %.\n".postf(scene, index,[ch, cc, val]) ;
			value = ch.linlin(0,127,-16.0,16.0).asInt / 4;
			value.postln;
			~loops[i].set(\rate, value);
			// ~loops[i].set(\dur, 4/value);
		});
		~ktl.mapCCS(scene, ('sl'++(index)).asSymbol, {|ch, cc, val|
			var value;
			"sc % sl %: %.\n".postf(scene, index,[ch, cc, val]) ;
			value = ch.linlin(0,127,0,1.27);
			value.postln;
			~loops[i].set(\amp, value);
		});
		~ktl.mapCCS(scene, ('bu'++(index)).asSymbol, {|ch, cc, val|
			var value;
			"sc % bu %: %.\n".postf(scene, index,[ch, cc, val]) ;
			value = ch.linlin(0,127,0,1);
			value.postln;
			(~loops[i]).postln;
			~loops[i].set(\rec, value);
		});
		~ktl.mapCCS(scene, ('bd'++(index)).asSymbol, {|ch, cc, val|
			var value;
			"sc % bd %: %.\n".postf(scene, index,[ch, cc, val]) ;
			value = ch.linlin(0,127,0,1.27);
			value.postln;
			// ~loops[i].set(\feedback, value);
			~buffers[i].zero;
		});
	};
};

// ~ktl.free;