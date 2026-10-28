vga_pll1_inst : vga_pll1 PORT MAP (
		areset	 => areset_sig,
		inclk0	 => inclk0_sig,
		c0	 => c0_sig,
		locked	 => locked_sig
	);
