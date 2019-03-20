~ktl.free;
~ktl = NanoKtl.new;
4.do { |scene|
	// scene = scene - 1;
	~ktl.mapCCS(scene, \kn1, {|val| ~set.value(scene, \rate, val.linlin(0,127,-16.0,16.0).asInt / 4); });
	~ktl.mapCCS(scene, \kn2, {|val| ~set.value(scene, \start, val.linlin(0,127,0.0, 1.0)); });
	~ktl.mapCCS(scene, \kn3, {|val| ~set.value(scene, \dur, val.linexp(0,127,0.001, ~loopdur - 0.01)); });
	~ktl.mapCCS(scene, \sl1, {|val| ~set.value(scene, \amp, val.linlin(0,127,0.0,1.0));});
	~ktl.mapCCS(scene, \sl2, {|val| ~set.value(scene, \feedback, val / 100);});
	~ktl.mapCCS(scene, \bu1, {|val| ~set.value(scene, \rec, (val > 0).asInt);});
	~ktl.mapCCS(scene, \bu2, {|val| ~set.value(scene, \t_reset, (val > 0).asInt);});
	~ktl.mapCCS(scene, \bu3, {|val| ~sync.value(scene);});
	~ktl.mapCCS(scene, \bd1, {|val| ~clearBuffer.value(scene)});
	~ktl.mapCCS(scene, \bd2, {|val| ~reset.value(scene)});

	~ktl.mapCCS(scene, \kn5, {|val| ~set.value(scene + 3, \rate, val.linlin(0,127,-16.0,16.0).asInt / 4); });
	~ktl.mapCCS(scene, \sl5, {|val| ~set.value(scene + 3, \amp, val.linlin(0,127,0.0,1.0));});
	~ktl.mapCCS(scene, \bu5, {|val| ~set.value(scene + 3, \rec, (val > 0).asInt);});
	~ktl.mapCCS(scene, \bd5, {|val| ~clearBuffer.value(scene + 3)});
};

// ~ktl.free;