create_clock -period 20 -waveform {0 10} CLOCK_50
create_clock -period 20 -waveform {0 10} CLOCK2_50
create_clock -period 20 -waveform {0 10} CLOCK3_50
create_clock -period 20 -waveform {0 10} CLOCK4_50
derive_pll_clocks
derive_clock_uncertainty