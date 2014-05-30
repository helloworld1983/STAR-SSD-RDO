shiftreg_inst : shiftreg PORT MAP (
		clock	 => clock_sig,
		enable	 => enable_sig,
		sclr	 => sclr_sig,
		shiftin	 => shiftin_sig,
		q	 => q_sig
	);
