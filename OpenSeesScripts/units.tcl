#
# US UNITS
set kips  1.0;				# kips
set in    1.0;				# inches
set sec   1.0;				# seconds
# DEPENDENT UNITS
set ft      [expr $in*12];
set lb      [expr $kips/1000];
set ksi     [expr $kips/$in**2];  
set psi     [expr $lb/$in**2];
set ksi_psi [expr $ksi/$psi];
# CONSTANTS
set g		[expr 386.2*$in/$sec**2];
set pi      [expr acos(-1.0)];
