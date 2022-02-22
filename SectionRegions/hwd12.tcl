proc py {args} {
    eval "[exec python.exe {*}$args]"
}



wipe;								# Clear memory of all past model definitions
model BasicBuilder -ndm 3 -ndf 6;	# Define the model builder, ndm=#dimension, ndf=#dofs
set dataDir "datahwd12"; # Set data directory
file mkdir $dataDir;  				# Create data output folder
set kips  1.0;				# kips
set in    1.0;				# inches
set sec   1.0;				# seconds
set ft      [expr $in*12];
set lb      [expr $kips/1000];
set ksi     [expr $kips/$in**2];  
set psi     [expr $lb/$in**2];
set ksi_psi [expr $ksi/$psi];
set g		[expr 386.2*$in/$sec**2];
set pi      [expr acos(-1.0)];
set fc            [expr 3.5*$ksi];	                                           # Default (general, if unspecified) 28-day concrete cylinder compressive strength   (+Tension, -Compression)
set fce           [expr 5.0*$ksi];											   # Default (general, if unspecified) Unconfined compressive strength (max[5ksi or 1.3f'c])   (+Tension, -Compression)
set ec0           0.002;													   # Unconfined strain at maximum strength (+Tension, -Compression)
set esp           0.005;													   # Unconfined crushing (cover spalling) strain (+Tension, -Compression)
set Ec            [expr 57000.0*sqrt($fce*$ksi_psi)/$ksi_psi];				   # Default (general, if unspecified) Concrete Modulus of Elasticity
set Uc            0.2;                                                         # Poisson's ratio
set Gc            [expr $Ec/(2.0*(1.0+$Uc))];                                  # Shear Modulus of Elasticity
set wconc	      [expr 143.96*$lb/$ft**3];                         		   # Normal Concrete Weight per Volume                              
set mconc	      [expr (143.96*$lb/$ft**3)/$g];                    		   # Normal Concrete Mass Weight per Volume
set Es           [expr 29000.0*$ksi];				# Steel Tensile Modulus of Elasticity (initial elastic tangent)
set Esh			 [expr 0.02*$Es];					# Tangent at initial strain hardening
set fy           [expr 68.0*$ksi];                	# Yield Strength
set fu			 [expr 95.0*$ksi];					# Ultimate strength
set esh          0.0075;                   			# Strain corresponding to initial strain hardening 
set esu          0.090;                    			# Strain at peak stress
node 201 11758.709 31062.549 [expr 140.750*$ft];
node 2010 11758.709 31062.549 [expr 140.750*$ft]; # Pin Node
node 202 11758.709 31062.549 [expr 192.776*$ft];
node 203 11758.709 31062.549 [expr 196.770*$ft];
node 204 11675.713 30944.873 [expr 197.490*$ft];
node 205 11571.969 30797.777 [expr 198.390*$ft];
node 206 11571.969 30797.777 [expr 194.397*$ft];
node 207 11571.969 30797.777 [expr 140.750*$ft];
node 2070 11571.969 30797.777 [expr 140.750*$ft]; # Pin Node
node 301 13326.879 30097.235 [expr 140.000*$ft];
node 302 13326.879 30097.235 [expr 195.330*$ft];
node 3020 13326.879 30097.235 [expr 195.330*$ft]; # Pin Node
node 303 13326.879 30097.235 [expr 199.570*$ft];
node 304 13227.933 29932.695 [expr 200.530*$ft];
node 305 12935.732 29446.785 [expr 203.370*$ft];
node 306 12935.732 29446.785 [expr 199.070*$ft];
node 3060 12935.732 29446.785 [expr 199.070*$ft]; # Pin Node
node 307 12935.732 29446.785 [expr 126.000*$ft];
node 401 15603.570 29883.836 [expr 137.000*$ft];
node 402 15603.570 29883.836 [expr 189.910*$ft];
node 4020 15603.570 29883.836 [expr 189.910*$ft]; # Pin Node
node 403 15603.570 29883.836 [expr 197.700*$ft];
node 404 15120.738 28901.035 [expr 203.145*$ft];
node 405 14983.164 28621.004 [expr 204.705*$ft];
node 406 14983.164 28621.004 [expr 196.930*$ft];
node 4060 14983.164 28621.004 [expr 196.930*$ft]; # Pin Node
node 407 14983.164 28621.004 [expr 119.000*$ft];
node 501 17372.788 28118.938 [expr 131.000*$ft];
node 502 17372.788 28118.938 [expr 198.740*$ft];
node 5020 17372.788 28118.938 [expr 198.740*$ft]; # Pin Node
node 503 17372.788 28118.938 [expr 204.004*$ft];
node 504 17308.901 27950.657 [expr 204.904*$ft];
node 505 17040.574 27243.878 [expr 208.684*$ft];
node 506 17040.574 27243.878 [expr 203.420*$ft];
node 5060 17040.574 27243.878 [expr 203.420*$ft]; # Pin Node
node 507 17040.574 27243.878 [expr 138.000*$ft];
node 601 19284.324 27591.751 [expr 142.000*$ft];
node 602 19284.324 27591.751 [expr 199.780*$ft];
node 6020 19284.324 27591.751 [expr 199.780*$ft]; # Pin Node
node 603 19284.324 27591.751 [expr 204.020*$ft];
node 604 19203.553 27315.309 [expr 205.460*$ft];
node 605 19047.059 26779.703 [expr 208.250*$ft];
node 606 19047.059 26779.703 [expr 204.010*$ft];
node 6060 19047.059 26779.703 [expr 204.010*$ft]; # Pin Node
node 607 19047.059 26779.703 [expr 144.000*$ft];
node 701 20759.780 27596.583 [expr 144.000*$ft];
node 702 20759.780 27596.583 [expr 198.470*$ft];
node 7020 20759.780 27596.583 [expr 198.470*$ft]; # Pin Node
node 703 20759.780 27596.583 [expr 202.334*$ft];
node 704 20609.812 26947.687 [expr 205.664*$ft];
node 705 20571.982 26784.002 [expr 206.504*$ft];
node 706 20571.982 26784.002 [expr 202.650*$ft];
node 7060 20571.982 26784.002 [expr 202.650*$ft]; # Pin Node
node 707 20571.982 26784.002 [expr 149.500*$ft];
node 801 22434.979 27020.686 [expr 145.000*$ft];
node 802 22434.979 27020.686 [expr 199.690*$ft];
node 8020 22434.979 27020.686 [expr 199.690*$ft]; # Pin Node
node 803 22434.979 27020.686 [expr 203.211*$ft];
node 804 22369.455 26605.829 [expr 205.311*$ft];
node 805 22332.013 26368.768 [expr 206.511*$ft];
node 806 22332.013 26368.768 [expr 202.990*$ft];
node 8060 22332.013 26368.768 [expr 202.990*$ft]; # Pin Node
node 807 22332.013 26368.768 [expr 154.000*$ft];
node 901 24104.380 26573.310 [expr 136.000*$ft];
node 902 24104.380 26573.310 [expr 199.000*$ft];
node 9020 24104.380 26573.310 [expr 199.000*$ft]; # Pin Node
node 903 24104.380 26573.310 [expr 203.028*$ft];
node 904 24088.125 26390.192 [expr 203.947*$ft];
node 905 24038.586 25832.224 [expr 206.748*$ft];
node 906 24038.586 25832.224 [expr 202.720*$ft];
node 9060 24038.586 25832.224 [expr 202.720*$ft]; # Pin Node
node 907 24038.586 25832.224 [expr 156.000*$ft];
node 1001 25885.617 26694.425 [expr 131.000*$ft];
node 1002 25885.617 26694.425 [expr 194.810*$ft];
node 10020 25885.617 26694.425 [expr 194.810*$ft]; # Pin Node
node 1003 25885.617 26694.425 [expr 199.852*$ft];
node 1004 25877.420 26241.067 [expr 202.119*$ft];
node 1005 25872.332 25854.531 [expr 204.052*$ft];
node 1006 25872.332 25854.531 [expr 199.010*$ft];
node 10060 25872.332 25854.531 [expr 199.010*$ft]; # Pin Node
node 1007 25872.332 25854.531 [expr 130.000*$ft];
node 1101 27396.787 26784.776 [expr 141.500*$ft];
node 1102 27396.787 26784.776 [expr 192.090*$ft];
node 11020 27396.787 26784.776 [expr 192.090*$ft]; # Pin Node
node 1103 27396.787 26784.776 [expr 197.154*$ft];
node 1104 27421.866 26193.697 [expr 200.112*$ft];
node 1105 27432.903 25933.542 [expr 201.414*$ft];
node 1106 27432.903 25933.542 [expr 196.350*$ft];
node 11060 27432.903 25933.542 [expr 196.350*$ft]; # Pin Node
node 1107 27432.903 25933.542 [expr 139.000*$ft];
node 1201 29283.281 26610.345 [expr 166.000*$ft];
node 12010 29283.281 26610.345 [expr 166.000*$ft]; # Pin Node
node 1202 29283.281 26610.345 [expr 192.159*$ft];
node 1203 29283.281 26610.345 [expr 195.409*$ft];
node 1204 29300.043 26467.348 [expr 195.903*$ft];
node 1205 29326.939 26237.895 [expr 196.695*$ft];
node 1206 29372.201 25851.750 [expr 198.028*$ft];
node 1207 29370.596 25865.445 [expr 197.981*$ft];
node 1208 29370.596 25865.445 [expr 193.445*$ft];
node 1209 29370.596 25865.445 [expr 156.000*$ft];
node 12090 29370.596 25865.445 [expr 156.000*$ft]; # Pin Node
node 1210 29326.939 26237.895 [expr 194.731*$ft];
node 1211 29326.939 26237.895 [expr 159.000*$ft];
node 12110 29326.939 26237.895 [expr 159.000*$ft]; # Pin Node
node 1301 30813.126 26806.601 [expr 163.750*$ft];
node 13010 30813.126 26806.601 [expr 163.750*$ft]; # Pin Node
node 1302 30813.126 26806.601 [expr 189.331*$ft];
node 1303 30813.126 26806.601 [expr 192.581*$ft];
node 1304 30749.330 26638.286 [expr 193.022*$ft];
node 1305 30685.534 26469.971 [expr 193.463*$ft];
node 1306 30685.534 26469.971 [expr 190.215*$ft];
node 1307 30685.534 26469.971 [expr 161.750*$ft];
node 13070 30685.534 26469.971 [expr 161.750*$ft]; # Pin Node
node 1313 30439.057 25819.668 [expr 151.000*$ft];
node 1314 30439.057 25819.668 [expr 193.333*$ft];
node 1315 30439.057 25819.668 [expr 196.584*$ft];
node 1401 32390.923 27030.687 [expr 158.500*$ft];
node 14010 32390.923 27030.687 [expr 158.500*$ft]; # Pin Node
node 1402 32390.923 27030.687 [expr 186.803*$ft];
node 1403 32390.923 27030.687 [expr 190.053*$ft];
node 1404 32222.481 26812.047 [expr 190.352*$ft];
node 1405 32054.040 26593.407 [expr 190.651*$ft];
node 1406 32054.040 26593.407 [expr 187.402*$ft];
node 1407 32054.040 26593.407 [expr 158.500*$ft];
node 14070 32054.040 26593.407 [expr 158.500*$ft]; # Pin Node
node 1408 32222.481 26812.047 [expr 187.102*$ft];
node 1409 32222.481 26812.047 [expr 158.500*$ft];
node 14090 32222.481 26812.047 [expr 158.500*$ft]; # Pin Node
node 1413 31434.869 25789.667 [expr 150.500*$ft];
node 1414 31434.869 25789.667 [expr 193.182*$ft];
node 1415 31434.869 25789.667 [expr 196.436*$ft];
node 10001 10956.246 31471.424 [expr 195.779*$ft];
node 10002 11134.376 31337.427 [expr 196.224*$ft];
node 10003 11313.673 31204.996 [expr 196.658*$ft];
node 10004 11494.123 31074.141 [expr 197.082*$ft];
node 20001 11980.192 30733.432 [expr 198.159*$ft];
node 20002 12287.718 30526.451 [expr 198.794*$ft];
node 20003 12598.228 30323.972 [expr 199.401*$ft];
node 20004 12911.655 30126.039 [expr 199.978*$ft];
node 30001 13599.389 29713.586 [expr 201.129*$ft];
node 30002 13974.506 29500.805 [expr 201.691*$ft];
node 30003 14353.175 29294.414 [expr 202.215*$ft];
node 30004 14735.289 29094.471 [expr 202.700*$ft];
node 40001 15551.083 28694.603 [expr 203.593*$ft];
node 40002 15985.225 28496.280 [expr 203.992*$ft];
node 40003 16423.012 28306.138 [expr 204.344*$ft];
node 40004 16864.289 28124.242 [expr 204.648*$ft];
node 50001 17604.098 27840.823 [expr 205.081*$ft];
node 500010 17604.098 27840.823 [expr 205.081*$ft]; # In-span hinge node
node 50002 18060.724 27678.668 [expr 205.225*$ft];
node 50003 18439.748 27551.567 [expr 205.335*$ft];
node 50004 18820.722 27430.437 [expr 205.412*$ft];
node 60001 19483.087 27235.365 [expr 205.533*$ft];
node 60002 19763.517 27158.622 [expr 205.592*$ft];
node 60003 20044.806 27085.088 [expr 205.634*$ft];
node 60004 20326.916 27014.773 [expr 205.658*$ft];
node 70001 20959.743 26869.407 [expr 205.648*$ft];
node 70002 21310.743 26796.068 [expr 205.604*$ft];
node 70003 21662.742 26727.682 [expr 205.534*$ft];
node 70004 22015.669 26664.265 [expr 205.436*$ft];
node 80001 22712.048 26554.108 [expr 205.085*$ft];
node 80002 23122.231 26498.529 [expr 204.834*$ft];
node 80003 23399.187 26464.685 [expr 204.557*$ft];
node 80004 23743.626 26427.172 [expr 204.258*$ft];
node 800040 23743.626 26427.172 [expr 204.258*$ft]; # In-span hinge node
node 90001 24446.148 26360.362 [expr 203.584*$ft];
node 90002 24804.172 26330.532 [expr 203.220*$ft];
node 90003 25162.197 26300.702 [expr 202.854*$ft];
node 90004 25520.222 26270.872 [expr 202.486*$ft];
node 100001 26186.309 26231.593 [expr 201.719*$ft];
node 100002 26495.198 26222.119 [expr 201.319*$ft];
node 100003 26804.087 26212.645 [expr 200.917*$ft];
node 100004 27112.976 26203.171 [expr 200.515*$ft];
node 110001 27802.880 26202.537 [expr 199.488*$ft];
node 110002 28183.895 26211.376 [expr 198.835*$ft];
node 110003 28564.909 26220.216 [expr 198.143*$ft];
node 110004 28945.924 26229.055 [expr 197.397*$ft];
node 120001 29526.646 26494.061 [expr 195.445*$ft];
node 1200010 29526.646 26494.061 [expr 195.445*$ft]; # In-span hinge node
node 120002 29879.758 26535.723 [expr 194.631*$ft];
node 120003 30169.615 26569.911 [expr 193.995*$ft];
node 120004 30459.472 26604.098 [expr 193.360*$ft];
node 120005 29603.224 25845.334 [expr 197.570*$ft];
node 1200050 29603.224 25845.334 [expr 197.570*$ft]; # In-span hinge node
node 120006 29798.944 25838.917 [expr 197.342*$ft];
node 120007 30012.315 25832.501 [expr 197.051*$ft];
node 120008 30225.686 25826.084 [expr 196.808*$ft];
node 130001 31043.962 26673.037 [expr 192.337*$ft];
node 130002 31338.594 26707.787 [expr 191.745*$ft];
node 130003 31633.226 26742.538 [expr 191.188*$ft];
node 130004 31927.858 26777.289 [expr 190.665*$ft];
node 130005 30638.228 25813.678 [expr 196.460*$ft];
node 130006 30837.398 25807.689 [expr 196.384*$ft];
node 130007 31036.569 25801.699 [expr 196.353*$ft];
node 130008 31235.740 25795.709 [expr 196.368*$ft];
node 140001 32552.005 26850.906 [expr 189.683*$ft];
node 140002 32881.519 26889.773 [expr 189.240*$ft];
node 140003 33211.033 26928.640 [expr 188.868*$ft];
node 140004 33540.547 26967.506 [expr 188.566*$ft];
node 140005 31783.829 25779.163 [expr 196.639*$ft];
node 140006 32132.789 25768.658 [expr 196.984*$ft];
node 140007 32481.748 25758.154 [expr 197.462*$ft];
node 140008 32830.708 25747.650 [expr 198.074*$ft];
node 1010 10779.297 31606.976 [expr 194.965*$ft];
node 1020 10935.542 31809.096 [expr 193.626*$ft];
node 1021 10935.542 31809.096 [expr 193.626*$ft]; # Fixed end of abutment spring
node 1030 10623.052 31404.856 [expr 196.183*$ft];
node 1031 10623.052 31404.856 [expr 196.183*$ft]; # Fixed end of abutment spring
node 15010 33870.061 27006.373 [expr 188.346*$ft];
node 15020 34094.051 27297.117 [expr 188.604*$ft];
node 15021 34094.051 27297.117 [expr 188.604*$ft]; # Fixed end of abutment spring
node 15030 33646.070 26715.629 [expr 188.089*$ft];
node 15031 33646.070 26715.629 [expr 188.089*$ft]; # Fixed end of abutment spring
node 15040 33179.709 25737.199 [expr 198.822*$ft];
node 15050 33257.634 25838.348 [expr 198.650*$ft];
node 15051 33257.634 25838.348 [expr 198.650*$ft]; # Fixed end of abutment spring
node 15060 33101.704 25635.948 [expr 198.994*$ft];
node 15061 33101.704 25635.948 [expr 198.994*$ft]; # Fixed end of abutment spring
fix 201  1 1 1 1 1 1;
fix 207  1 1 1 1 1 1;
fix 301  1 1 1 1 1 1;
fix 307  1 1 1 1 1 1;
fix 401  1 1 1 1 1 1;
fix 407  1 1 1 1 1 1;
fix 501  1 1 1 1 1 1;
fix 507  1 1 1 1 1 1;
fix 601  1 1 1 1 1 1;
fix 607  1 1 1 1 1 1;
fix 701  1 1 1 1 1 1;
fix 707  1 1 1 1 1 1;
fix 801  1 1 1 1 1 1;
fix 807  1 1 1 1 1 1;
fix 901  1 1 1 1 1 1;
fix 907  1 1 1 1 1 1;
fix 1001  1 1 1 1 1 1;
fix 1007  1 1 1 1 1 1;
fix 1101  1 1 1 1 1 1;
fix 1107  1 1 1 1 1 1;
fix 1201  1 1 1 1 1 1;
fix 1209  1 1 1 1 1 1;
fix 1211  1 1 1 1 1 1;
fix 1301  1 1 1 1 1 1;
fix 1307  1 1 1 1 1 1;
fix 1313  1 1 1 1 1 1;
fix 1401  1 1 1 1 1 1;
fix 1407  1 1 1 1 1 1;
fix 1409  1 1 1 1 1 1;
fix 1413  1 1 1 1 1 1;
fix 1021  1 1 1 1 1 1;
fix 1031  1 1 1 1 1 1;
fix 15021 1 1 1 1 1 1;
fix 15031 1 1 1 1 1 1;
fix 15051 1 1 1 1 1 1;
fix 15061 1 1 1 1 1 1;
set fpHcol [open "./Dimensions/Hcol.txt" r];
set HcolList [read $fpHcol];
close $fpHcol
set fpnLbar [open "./Dimensions/nLbar.txt" r];
set nLbarList [read $fpnLbar];
close $fpnLbar
set fpDLbar [open "./Dimensions/DLbar.txt" r];
set DLbarList [read $fpDLbar];
close $fpDLbar
set fpsTbar [open "./Dimensions/sTbar.txt" r];
set sTbarList [read $fpsTbar];
close $fpsTbar
source ColSectionOctIEu.tcl
source ColSectionOctWideIEu.tcl
for {set ib 2} {$ib <= 11} {incr ib 1} {
	set Dcol [expr 84.0*$in];
	set ic 1;												# Left Column
	set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
	set Hcol [lindex $HcolList [expr ($ib-2)*2]];
	set nLbar [lindex $nLbarList [expr ($ib-2)*2]];
	set DLbar [lindex $DLbarList [expr ($ib-2)*2]];
	set sTbar [lindex $sTbarList [expr ($ib-2)*2]];
	BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
	set ic 2;												# Right Column
	set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
	set Hcol [lindex $HcolList [expr ($ib-2)*2+1]];
	set nLbar [lindex $nLbarList [expr ($ib-2)*2+1]];
	set DLbar [lindex $DLbarList [expr ($ib-2)*2+1]];
	set sTbar [lindex $sTbarList [expr ($ib-2)*2+1]];
	BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
}
set ib 12;
set Dcol [expr 66.0*$in];
set ic 1;												# Left Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 20];
set nLbar [lindex $nLbarList 20];
set DLbar [lindex $DLbarList 20];
set sTbar [lindex $sTbarList 20];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ic 2;												# Right Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 22];
set nLbar [lindex $nLbarList 22];
set DLbar [lindex $DLbarList 22];
set sTbar [lindex $sTbarList 22];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-sectionn
set ic 3;												# Center Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 21];
set nLbar [lindex $nLbarList 21];
set DLbar [lindex $DLbarList 21];
set sTbar [lindex $sTbarList 21];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ib 13;
set Dcol [expr 48.0*$in];
set ic 1;												# Left Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 23];
set nLbar [lindex $nLbarList 23];
set DLbar [lindex $DLbarList 23];
set sTbar [lindex $sTbarList 23];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ic 2;												# Right Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 24];
set nLbar [lindex $nLbarList 24];
set DLbar [lindex $DLbarList 24];
set sTbar [lindex $sTbarList 24];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ib 13;
set Dcol [expr 48.0*$in]; 								# Shorter Width of octagonal column (to flat sides)
set ic 4;												# Single Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 25]; 						# Column Height
set nLbar [lindex $nLbarList 25]; 						# Number of main (outer) longitudinal bars
set DLbar [lindex $DLbarList 25]; 						# Diameter of main (outer) longitudinal bars
set sTbar [lindex $sTbarList 25]; 						# Spacing of transverse spiral reinforcement
set Wcol [expr 72.0*$in]; 								# Longer Width of octagonal column (to flat sides)
set nLbar2 8; 											# Number of secondary (inner) longitudinal bars
set DLbar2 [expr 0.625*$in]; 							# Diameter of secondary (inner) longitudinal bars (#5 rebar)
BuildWideOctColSection $ColSecTag  $Dcol  $Wcol  $nLbar  $nLbar2  $DLbar  $DLbar2  $sTbar; # Fiber cross-section
set ib 14;
set Dcol [expr 48.0*$in];
set ic 1;												# Left Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 26];
set nLbar [lindex $nLbarList 26];
set DLbar [lindex $DLbarList 26];
set sTbar [lindex $sTbarList 26];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ic 2;												# Right Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 28];
set nLbar [lindex $nLbarList 28];
set DLbar [lindex $DLbarList 28];
set sTbar [lindex $sTbarList 28];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ic 3;												# Center Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 27];
set nLbar [lindex $nLbarList 27];
set DLbar [lindex $DLbarList 27];
set sTbar [lindex $sTbarList 27];
BuildOctColSection $ColSecTag  $Dcol  $nLbar  $DLbar $sTbar; # Fiber cross-section
set ib 14;
set Dcol [expr 48.0*$in]; 								# Shorter Width of octagonal column (to flat sides)
set ic 4; 												# Single Column
set ColSecTag [expr 1000*$ib+10*$ic];					# Column's fiber element tag. Follows column numbering scheme.
set Hcol [lindex $HcolList 29]; 						# Column Height
set nLbar [lindex $nLbarList 29]; 						# Number of main (outer) longitudinal bars
set DLbar [lindex $DLbarList 29]; 						# Diameter of main (outer) longitudinal bars
set sTbar [lindex $sTbarList 29]; 						# Spacing of transverse spiral reinforcement
set Wcol [expr 72.0*$in]; 								# Longer Width of octagonal column (to flat sides)
set nLbar2 8; 											# Number of secondary (inner) longitudinal bars
set DLbar2 [expr 0.625*$in]; 							# Diameter of secondary (inner) longitudinal bars (#5 rebar)
BuildWideOctColSection $ColSecTag  $Dcol  $Wcol  $nLbar  $nLbar2  $DLbar  $DLbar2  $sTbar; # Fiber cross-section
set TransfType PDelta;
geomTransf $TransfType 301 0 0 1;				# vecxz is in the +Z direction (deck and cap beams: local z upwards on section, local y horiz left on section facing j)	  
set fpvecxzX [open "./Dimensions/vecxzXcol.txt" r];
set vecxzXList [read $fpvecxzX];
close $fpvecxzX
set fpvecxzY [open "./Dimensions/vecxzYcol.txt" r];
set vecxzYList [read $fpvecxzY];
close $fpvecxzY
set np 4;										# number of Gauss integration points for nonlinear curvature distribution-- np=2 for linear distribution ok
set Dcol [expr 84.0*$in];										# Width of octagonal column (to flat sides)
set RcolDiag	[expr $Dcol*sqrt(4+2*sqrt(2))/(2+2*sqrt(2))];	# Radius of octagonal column (to corners)
set vecxzX 		[lindex $vecxzXList [expr 0]]; 				# X component of vecxz vector for local axis transformation
set vecxzY 		[lindex $vecxzYList [expr 0]]; 				# Y component of vecxz vector for local axis transformation
geomTransf $TransfType 20 $vecxzX $vecxzY 0; 		# PDelta transformation; vecxz is parallel to the length of the cap beam.
element nonlinearBeamColumn 2010   2010   202     $np   2010  20; #(Hinge)
rigidLink beam 202 203;											 #(Rigid)
element nonlinearBeamColumn 2020   2070   206	  $np   2020  20; #(Hinge)
rigidLink beam 206 205;											 #(Rigid)
for {set ib 3} {$ib <= 11} {incr ib 1} {
	set Dcol [expr 84.0*$in];										# Width of octagonal column (to flat sides)
	set RcolDiag	[expr $Dcol*sqrt(4+2*sqrt(2))/(2+2*sqrt(2))];	# Radius of octagonal column (to corners)
	set vecxzX 		[lindex $vecxzXList [expr $ib-2]]; 				# X component of vecxz vector for local axis transformation
	set vecxzY 		[lindex $vecxzYList [expr $ib-2]]; 				# Y component of vecxz vector for local axis transformation
	geomTransf $TransfType [expr 10*$ib] $vecxzX $vecxzY 0; 		# PDelta transformation; vecxz is parallel to the length of the cap beam.
	element nonlinearBeamColumn [expr 1000*$ib+10] [expr 100*$ib+1] [expr 100*$ib+2]	$np   [expr 1000*$ib+10]  [expr 10*$ib]; #(Hinge)
	rigidLink beam [expr 1000*$ib+20] [expr 100*$ib+3];				#(Rigid)
	element nonlinearBeamColumn [expr 1000*$ib+20] [expr 100*$ib+7] [expr 100*$ib+6]	$np   [expr 1000*$ib+20]  [expr 10*$ib]; #(Hinge)
	rigidLink beam [expr 1000*$ib+60] [expr 100*$ib+5];				#(Rigid)
}
set Dcol [expr 66.0*$in];										# Width of octagonal column (to flat sides)
set RcolDiag	[expr $Dcol*sqrt(4+2*sqrt(2))/(2+2*sqrt(2))];	# Radius of octagonal column (to corners)
set vecxzX 		[lindex $vecxzXList 10]; 						# X component of vecxz vector for local axis transformation
set vecxzY 		[lindex $vecxzYList 10]; 						# Y component of vecxz vector for local axis transformation
geomTransf $TransfType 120 $vecxzX $vecxzY 0; 					# PDelta transformation; vecxz is parallel to the length of the cap beam.
element nonlinearBeamColumn 12010   12010   1202     $np   12010  120; #(Hinge)
rigidLink beam 1202 1203;				 						#(Rigid)
element nonlinearBeamColumn 12020   12090   1208     $np   12020  120; #(Hinge)
rigidLink beam 1208 1207;				 						#(Rigid)
element nonlinearBeamColumn 12030   12110   1210     $np   12030  120; #(Hinge)
rigidLink beam 1210 1205;				 						#(Rigid)
set Dcol [expr 48.0*$in];										# Width of octagonal column (to flat sides)
set RcolDiag	[expr $Dcol*sqrt(4+2*sqrt(2))/(2+2*sqrt(2))];	# Radius of octagonal column (to corners)
set vecxzX 		[lindex $vecxzXList 11]; 						# X component of vecxz vector for local axis transformation
set vecxzY 		[lindex $vecxzYList 11]; 						# Y component of vecxz vector for local axis transformation
geomTransf $TransfType 130 $vecxzY $vecxzX 0; 					# PDelta transformation; vecxz is PERPENDICULAR to the length of the cap beam. (local y parallel)
element nonlinearBeamColumn 13010   13010   1302     $np   13010  130; #(Hinge)
rigidLink beam 1302 1303;				 						#(Rigid)
element nonlinearBeamColumn 13020   13070   1306     $np   13020  130; #(Hinge)
rigidLink beam 1306 1305;				 						#(Rigid)
element nonlinearBeamColumn 13040   1313   1314     $np   13040  130; #(Hinge)
rigidLink beam 1314 1315;				 						#(Rigid)
set vecxzX 		[lindex $vecxzXList 12]; 						# X component of vecxz vector for local axis transformation
set vecxzY 		[lindex $vecxzYList 12]; 						# Y component of vecxz vector for local axis transformation
geomTransf $TransfType 140 $vecxzY $vecxzX 0; 					# PDelta transformation; vecxz is PERPENDICULAR to the length of the cap beam. (local y parallel)
element nonlinearBeamColumn 14010   14010   1402     $np   14010  140; #(Hinge)
rigidLink beam 1402 1403;				 						#(Rigid)
element nonlinearBeamColumn 14020   14070   1406     $np   14020  140; #(Hinge)
rigidLink beam 1406 1405;				 						#(Rigid)
element nonlinearBeamColumn 14030   14090   1408     $np   14030  140; #(Hinge)
rigidLink beam 1408 1404;				 						#(Rigid)
element nonlinearBeamColumn 14040   1413   1414     $np   14040  140; #(Hinge)
rigidLink beam 1414 1415;				 						#(Rigid)
source ReadMPR.tcl; 										# Set up ReadMPR procedure for obtaining cap beam section properties
set CSDir "./Dimensions/CapCS/";  							# Directory containing cap beam cross section information
set CSType "Cap"; 											# Cross section type is cap beam
set fpfceCap [open "./Dimensions/fceCap.txt" r];
set fceCapList [read $fpfceCap];
close $fpfceCap
for {set ib 2} {$ib <= 9} {incr ib 1} {
	lassign [ReadMPR $CSDir $CSType $ib {}] A Iy Iz J; # Cross Section properties
	set fceCap [lindex $fceCapList [expr $ib-2]]
	set EcCap [expr 57000.0*sqrt($fceCap*$ksi_psi)/$ksi_psi]
	set GcCap [expr $EcCap/(2.0*(1.0+$Uc))]
	element elasticBeamColumn [expr 10000*$ib+10] [expr 100*$ib+3] [expr 100*$ib+4] $A $EcCap $GcCap $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	element elasticBeamColumn [expr 10000*$ib+20] [expr 100*$ib+4] [expr 100*$ib+5] $A $EcCap $GcCap $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
}
for {set ib 10} {$ib <= 11} {incr ib 1} {
	lassign [ReadMPR $CSDir $CSType $ib {}] A Iy Iz J; # Cross Section properties
	set fceCap [lindex $fceCapList [expr $ib-2]]
	set EcCap [expr 57000.0*sqrt($fceCap*$ksi_psi)/$ksi_psi]
	set GcCap [expr $EcCap/(2.0*(1.0+$Uc))]
	element elasticBeamColumn [expr 10000*$ib+10] [expr 100*$ib+3] [expr 100*$ib+4] $A $EcCap $GcCap $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	element elasticBeamColumn [expr 10000*$ib+20] [expr 100*$ib+4] [expr 100*$ib+5] $A $EcCap $GcCap $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
}
lassign [ReadMPR $CSDir $CSType 12 {}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 120010 1203 1204 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 120020 1204 1205 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 120030 1205 1206 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 120040 1206 1207 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 130010 1303 1304 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 130020 1304 1305 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 140010 1403 1404 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 140020 1404 1405 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
source ReadMPR.tcl; 										# Set up ReadMPR procedure for obtaining deck section properties
set CSDir "./Dimensions/DeckCS/";  							# Directory containing deck cross section information
set CSType "Deck"; 											# Cross section type is deck
lassign [ReadMPR $CSDir $CSType 1 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 10 1010 10001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 11 10001 10002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 12 10002 10003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 13 10003 10004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 14 10004 204 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
for {set ib 2} {$ib <= 4} {incr ib 1} {
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 0}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib] [expr 100*$ib+4] [expr 10000*$ib+1] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 1}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+1] [expr 10000*$ib+1] [expr 10000*$ib+2] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 2}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+2] [expr 10000*$ib+2] [expr 10000*$ib+3] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 3}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+3] [expr 10000*$ib+3] [expr 10000*$ib+4] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 4}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+4] [expr 10000*$ib+4] [expr 100*($ib+1)+4] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
}
lassign [ReadMPR $CSDir $CSType 5 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 50 504 50001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 5 {-NodeNum 1}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 51 500010 50002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 5 {-NodeNum 2}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 52 50002 50003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 5 {-NodeNum 3}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 53 50003 50004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 5 {-NodeNum 4}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 54 50004 604 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
for {set ib 6} {$ib <= 7} {incr ib 1} {
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 0}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib] [expr 100*$ib+4] [expr 10000*$ib+1] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 1}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+1] [expr 10000*$ib+1] [expr 10000*$ib+2] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 2}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+2] [expr 10000*$ib+2] [expr 10000*$ib+3] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 3}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+3] [expr 10000*$ib+3] [expr 10000*$ib+4] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 4}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+4] [expr 10000*$ib+4] [expr 100*($ib+1)+4] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
}
lassign [ReadMPR $CSDir $CSType 8 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 80 804 80001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 8 {-NodeNum 1}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 81 80001 80002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 8 {-NodeNum 2}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 82 80002 80003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 8 {-NodeNum 3}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 83 80003 80004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 8 {-NodeNum 4}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 84 800040 904 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
for {set ib 9} {$ib <= 10} {incr ib 1} {
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 0}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib] [expr 100*$ib+4] [expr 10000*$ib+1] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 1}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+1] [expr 10000*$ib+1] [expr 10000*$ib+2] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 2}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+2] [expr 10000*$ib+2] [expr 10000*$ib+3] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 3}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+3] [expr 10000*$ib+3] [expr 10000*$ib+4] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
	lassign [ReadMPR $CSDir $CSType $ib {-NodeNum 4}] A Iy Iz J; # Cross Section properties
	element elasticBeamColumn [expr 10*$ib+4] [expr 10000*$ib+4] [expr 100*($ib+1)+4] $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
}
lassign [ReadMPR $CSDir $CSType 11 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 110 1104 110001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 11 {-NodeNum 1}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 111 110001 110002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 11 {-NodeNum 2}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 112 110002 110003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 11 {-NodeNum 3}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 113 110003 110004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 11 {-NodeNum 4}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 114 110004 1205 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 120 1204 120001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 1}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 121 1200010 120002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 2}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 122 120002 120003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 3}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 123 120003 120004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 4}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 124 120004 1304 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 5}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 125 1206 120005 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 6}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 126 1200050 120006 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 7}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 127 120006 120007 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 8}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 128 120007 120008 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 12 {-NodeNum 9}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 129 120008 1315 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 130 1304 130001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 1}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 131 130001 130002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 2}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 132 130002 130003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 3}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 133 130003 130004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 4}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 134 130004 1404 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 5}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 135 1315 130005 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 6}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 136 130005 130006 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 7}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 137 130006 130007 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 13 {-NodeNum 8}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 138 130007 130008 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 139 130008 1415 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {-NodeNum 0}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 140 1404 140001 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {-NodeNum 1}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 141 140001 140002 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {-NodeNum 2}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 142 140002 140003 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {-NodeNum 3}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 143 140003 140004 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {-NodeNum 4}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 144 140004 15010 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
lassign [ReadMPR $CSDir $CSType 14 {-NodeNum 5}] A Iy Iz J; # Cross Section properties
element elasticBeamColumn 145 1415 140005 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 146 140005 140006 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 147 140006 140007 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 148 140007 140008 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 149 140008 15040 $A $Ec $Gc $J $Iy $Iz 301 -mass [expr $mconc*$A] -cMass;
element elasticBeamColumn 1000 1020 1010 [expr 1.0e+9] $Ec $Gc [expr 1.0e+9] [expr 1.0e+9] [expr 1.0e+9] 301;	# abut-1
element elasticBeamColumn 1001 1010 1030 [expr 1.0e+9] $Ec $Gc [expr 1.0e+9] [expr 1.0e+9] [expr 1.0e+9] 301;	# abut-1
element elasticBeamColumn 15000 15020 15010 [expr 1.0e+9] $Ec $Gc [expr 1.0e+9] [expr 1.0e+9] [expr 1.0e+9] 301;	# abut-15NE
element elasticBeamColumn 15001 15010 15030 [expr 1.0e+9] $Ec $Gc [expr 1.0e+9] [expr 1.0e+9] [expr 1.0e+9] 301;	# abut-15NE
element elasticBeamColumn 15002 15050 15040 [expr 1.0e+9] $Ec $Gc [expr 1.0e+9] [expr 1.0e+9] [expr 1.0e+9] 301;	# abut-15NR
element elasticBeamColumn 15003 15040 15060 [expr 1.0e+9] $Ec $Gc [expr 1.0e+9] [expr 1.0e+9] [expr 1.0e+9] 301;	# abut-15NR
set rFlag 1;  # Rayleigh damping ON
uniaxialMaterial Elastic 21		[expr 1.0e+15*$kips/$in]; 			# RIGID TRANSLATIONAL AND TORSIONAL STIFFNESS
uniaxialMaterial Elastic 22 	[expr 0.0*$kips/$in]; 				# FREE X and/or Y ROTATIONAL STIFFNESS
source ColSectionOctIEPin.tcl
set Dcol [expr 84.0*$in];
BuildOctColPINSection 290000  $Dcol; # Fiber cross-section for columns at Bents 2-11 (each have diameter 84.0 inches)
set yp1 	[lindex $vecxzXList 0];
set yp2 	[lindex $vecxzYList 0];
element zeroLengthSection 290000 201 2010 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 2 Left Column, Base, DIR = {}. Modeled as a zerolength octagonal section of unreinforced concrete.  Orientation vector sets the local x axis (perpendicular to the section) in the global Z (vertical) direction, and the local y axis parallel to the length of the cap beam.
element zeroLengthSection 290001 207 2070 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 2 Right Column, Base, DIR = {Y}
set yp1 	[lindex $vecxzXList 1];
set yp2 	[lindex $vecxzYList 1];
element zeroLengthSection 390000 302 3020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 3 Left Column, Top, DIR = {X}
element zeroLength 	390001  306 3060 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 3 Right Column, Top, DIR = {X,Y}
set yp1 	[lindex $vecxzXList 2];
set yp2 	[lindex $vecxzYList 2];
element zeroLengthSection 490000 402 4020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 4 Left Column, Top, DIR = {X}
element zeroLength 	490001  406 4060 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 4 Right Column, Top, DIR = {X,Y}
set yp1 	[lindex $vecxzXList 3];
set yp2 	[lindex $vecxzYList 3];
element zeroLengthSection 590000 502 5020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 5 Left Column, Top, DIR = {Y}
element zeroLengthSection 590001 506 5060 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 5 Right Column, Top, DIR = {X}
set yp1 	[lindex $vecxzXList 4];
set yp2 	[lindex $vecxzYList 4];
element zeroLengthSection 690000 602 6020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 6 Left Column, Top, DIR = {X}
element zeroLengthSection 690001 606 6060 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 6 Right Column, Top, DIR = {X}
set yp1 	[lindex $vecxzXList 5];
set yp2 	[lindex $vecxzYList 5];
element zeroLengthSection 790000 702 7020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 7 Left Column, Top, DIR = {X}
element zeroLength 	790001  706 7060 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 7 Right Column, Top, DIR = {X,Y}
set yp1 	[lindex $vecxzXList 6];
set yp2 	[lindex $vecxzYList 6];
element zeroLengthSection 890000 802 8020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 8 Left Column, Top, DIR = {X}
element zeroLength 	890001  806 8060 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 8 Right Column, Top, DIR = {X,Y}
set yp1 	[lindex $vecxzXList 7];
set yp2 	[lindex $vecxzYList 7];
element zeroLengthSection 990000 902 9020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 9 Left Column, Top, DIR = {X}
element zeroLengthSection 990001 906 9060 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 9 Right Column, Top, DIR = {X}
element zeroLength 	1090000  1002 10020 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 10 Left Column, Top, DIR = {X,Y}
element zeroLength 	1090001  1006 10060 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 10 Right Column, Top, DIR = {X,Y}
set yp1 	[lindex $vecxzXList 9];
set yp2 	[lindex $vecxzYList 9];
element zeroLengthSection 1190000 1102 11020 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 11 Left Column, Top, DIR = {X}
element zeroLengthSection 1190001 1106 11060 290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 11 Right Column, Top, DIR = {X}
set Dcol [expr 66.0*$in];
BuildOctColPINSection 1290000  $Dcol; # Fiber cross-section for columns at Bent 12 (each have diameter 66.0 inches) 
set yp1 	[lindex $vecxzXList 10];
set yp2 	[lindex $vecxzYList 10];
element zeroLengthSection 1290000 1201 12010 1290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 12 Left Column, Base, DIR = {Y}
element zeroLengthSection 1290001 1209 12090 1290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 12 Right Column, Base, DIR = {Y}
element zeroLengthSection 1290002 1211 12110 1290000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 12 Center Column, Base, DIR = {Y}
set Dcol [expr 48.0*$in];
BuildOctColPINSection 1390000  $Dcol; # Fiber cross-section for columns at Bents 13-14 (each have diameter 48.0 inches)
set yp1 	[lindex $vecxzXList 11];
set yp2 	[lindex $vecxzYList 11];
element zeroLengthSection 1390000 1301 13010 1390000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 13 Left Column, Base, DIR = {X}
element zeroLength 	1390001  1307 13070 -mat 21 21 21 22 22 21 -dir 1 2 3 4 5 6 -doRayleigh $rFlag; # PIN Bent 13 Right Column, Base, DIR = {X,Y}
set yp1 	[lindex $vecxzXList 12];
set yp2 	[lindex $vecxzYList 12];
element zeroLengthSection 1490000 1401 14010 1390000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 14 Left Column, Base, DIR = {}
element zeroLengthSection 1490001 1407 14070 1390000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 14 Right Column, Base, DIR = {Y}
element zeroLengthSection 1490002 1409 14090 1390000 -orient 0 0 1 $yp1 $yp2 0 -doRayleigh $rFlag; # PIN Bent 14 Center Column, Base, DIR = {Y}
uniaxialMaterial Elastic 501 	[expr 0.0*$kips/$in]; 				# LONGITUDINAL Hinge 5
uniaxialMaterial Elastic 502 	[expr 51520.0*$kips/$in]; 			# TRANSVERSE Hinge 5
uniaxialMaterial Elastic 503 	[expr 1.0e+9*$kips/$in]; 			# VERTICAL Hinge 5
uniaxialMaterial Elastic 801 	[expr 0.0*$kips/$in]; 				# LONGITUDINAL Hinge 8
uniaxialMaterial Elastic 802 	[expr 51520.0*$kips/$in]; 			# TRANSVERSE Hinge 8
uniaxialMaterial Elastic 803 	[expr 1.0e+9*$kips/$in]; 			# VERTICAL Hinge 8
uniaxialMaterial Elastic 1201 	[expr 0.0*$kips/$in]; 				# LONGITUDINAL Hinge 12 NE
uniaxialMaterial Elastic 1202 	[expr 51520.0*$kips/$in]; 			# TRANSVERSE Hinge 12 NE
uniaxialMaterial Elastic 1203 	[expr 1.0e+9*$kips/$in]; 			# VERTICAL Hinge 12 NE
uniaxialMaterial Elastic 1204 	[expr 0.0*$kips/$in]; 				# LONGITUDINAL Hinge 12 NR
uniaxialMaterial Elastic 1205 	[expr 42960.0*$kips/$in]; 			# TRANSVERSE Hinge 12 NR
uniaxialMaterial Elastic 1206 	[expr 1.0e+9*$kips/$in]; 			# VERTICAL Hinge 12 NR
uniaxialMaterial Elastic 504 	[expr 0.0*$kips/$in]; 				# ROTATIONAL
element zeroLength 				500000  50001 500010 -mat 501 502 503 504 504 504 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 456.63 -162.15534 0 0 1 0; # IN-SPAN HINGE BENT 5
element zeroLength 				800000  80004 800040 -mat 801 802 803 504 504 504 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 702.52 -66.80943 0 0 1 0; # IN-SPAN HINGE BENT 8
element zeroLength 				1200000 120001 1200010 -mat 1201 1202 1203 504 504 504 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 353.11 41.662 0 0 1 0; # IN-SPAN HINGE BENT 12 NE
element zeroLength 				1200001 120005 1200050 -mat 1204 1205 1206 504 504 504 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 195.72 -6.42 0 0 1 0; # IN-SPAN HINGE BENT 12 NR
set CW 			[expr 4.0/3.0]; 		# Wall participation coefficient (for wingwall contribution to transverse stiffness)
set CL 			[expr 2.0/3.0]; 		# Wall effectiveness (for wingwall contribution to transverse stiffness)
set CWT 		[expr 1.0/3.0];  		# Multiplier for assumed effective wingwall width = 1/3 of backwall width
set Eb 			[expr 0.50*$ksi]; 		# Elastic modulus for elastomeric bearings
set gapV	    [expr 0.6*$in];  		# The plastic portion of the elastomeric bearing pad which is flexible
set wabut1 		[expr 54.0]; 											# Abutment 1 backwall width (in feet)
set habut1 		[expr 7.0]; 											# Abutment 1 backwall height (in feet)
set theta1 		[expr 0.25]; 											# Abutment 1 skew angle (in degrees)
set Rsk1 		[expr exp(-$theta1/45)]; 								# Abutment 1 skew reduction factor
set kabutl1 	[expr $wabut1*(5.5*$habut1+20.0)*$Rsk1*$kips/$in]; 		# Abutment 1 longitudinal stiffness (in kip/in)
set kabutt1 	[expr $CW*$CL*$CWT*$kabutl1*$kips/$in]; 					# Abutment 1 transverse stiffness (in kip/in)
set pabutl1 	[expr $wabut1*(5.5*$habut1**2.5)*$Rsk1/(1+2.37*$habut1)];# Abutment 1 longitudinal resistance force (in kips)
set pabutt1 	[expr $CW*$CL*$CWT*$pabutl1*$kips]; 					# Abutment 1 transverse resistance force (in kips)
set gap1 		[expr 1.75*$in];  										# Abutment 1 longitudinal gap (in inches)
set lb1 		[expr 2.0*$in]; 										# Abutment 1 elastomeric bearing thickness
set ab1 		[expr 12.0*18.0*$in**2];								# Abutment 1 elastomeric bearing area
set nb1 		[expr 6.0]; 											# Abutment 1 number of elastomeric bearings
set kabutv1 	[expr $nb1*$Eb*$ab1/$lb1]; 								# Abutment 1 vertical initial stiffness (in kip/in)
set wabut15NE 	[expr 75.5]; 											# Abutment 15 NE width (in feet)
set habut15NE 	[expr 5.5]; 											# Abutment 15 NE backwall height (in feet)
set theta15NE 	[expr 66.18]; 											# Abutment 15 NE skew angle (in degrees)
set Rsk15NE 	[expr exp(-$theta15NE/45)]; 							# Abutment 15 NE skew reduction factor
set kabutl15NE 	[expr $wabut15NE*(5.5*$habut15NE+20.0)*$Rsk15NE*$kips/$in];# Abutment 15 NE longitudinal stiffness (in kip/in)
set kabutt15NE 	[expr $CW*$CL*$CWT*$kabutl15NE*$kips/$in]; 				# Abutment 15 NE transverse stiffness (in kip/in)
set pabutl15NE 	[expr $wabut15NE*(5.5*$habut15NE**2.5)*$Rsk15NE/(1+2.37*$habut15NE)];# Abutment 15 NE longitudinal resistance force (in kips)
set pabutt15NE 	[expr $CW*$CL*$CWT*$pabutl15NE*$kips]; 					# Abutment 15 NE transverse resistance force (in kips)
set gap15NE 	[expr 1.0*$in];  										# Abutment 15 NE longitudinal gap (in inches)
set lb15NE 		[expr 1.50*$in]; 										# Abutment 15 NE elastomeric bearing thickness
set ab15NE 		[expr 16.0*20.0*$in**2];								# Abutment 15 NE elastomeric bearing area
set nb15NE 		[expr 6.0]; 											# Abutment 15 NE number of elastomeric bearings
set kabutv15NE 	[expr $nb15NE*$Eb*$ab15NE/$lb15NE]; 					# Abutment 15 NE vertical initial stiffness (in kip/in)
set wabut15NR 	[expr 32.1]; 											# Abutment 15 NR width (in feet)
set habut15NR 	[expr 5.5]; 											# Abutment 15 NR backwall height (in feet)
set theta15NR 	[expr 35.896]; 											# Abutment 15 NR skew angle (in degrees)
set Rsk15NR 	[expr exp(-$theta15NR/45)]; 							# Abutment 15 NR skew reduction factor
set kabutl15NR 	[expr $wabut15NR*(5.5*$habut15NR+20.0)*$Rsk15NR]; 		# Abutment 15 NR longitudinal stiffness (in kip/in)
set kabutt15NR 	[expr $CW*$CL*$CWT*$kabutl15NR*$kips/$in]; 				# Abutment 15 NR transverse stiffness (in kip/in)
set pabutl15NR 	[expr $wabut15NR*(5.5*$habut15NR**2.5)*$Rsk15NR/(1+2.37*$habut15NR)];# Abutment 15 NR longitudinal resistance force (in kips)
set pabutt15NR 	[expr $CW*$CL*$CWT*$pabutl15NR*$kips]; 					# Abutment 15 NR transverse resistance force (in kips)
set gap15NR 	[expr 1.0*$in];  										# Abutment 15 NR longitudinal gap (in inches)
set lb15NR 		[expr 1.50*$in]; 										# Abutment 15 NR elastomeric bearing thickness
set ab15NR 		[expr 16.0*20.0*$in**2];								# Abutment 15 NR elastomeric bearing area
set nb15NR 		[expr 3.0]; 											# Abutment 15 NR number of elastomeric bearings
set kabutv15NR 	[expr $nb15NR*$Eb*$ab15NR/$lb15NR]; 					# Abutment 15 NR vertical initial stiffness (in kip/in)
set cfactor	 	  0.5;
uniaxialMaterial ElasticPPGap 	201 	[expr $kabutl1*$cfactor] [expr -$pabutl1*$cfactor] [expr -$gap1] 1.0e-3 damage; 	# LONGITUDINAL Abutment 1
uniaxialMaterial ElasticPP 		202 	[expr $kabutt1*$cfactor] [expr $pabutt1/$kabutt1]; 									# TRANSVERSE Abutment 1
uniaxialMaterial ENT 			2031 	[expr 3.5*$kabutv1];
uniaxialMaterial ElasticPPGap 	2032 	[expr 1.0e+9] [expr -1.0e+9] -$gapV 1.0e-3 damage;
uniaxialMaterial Parallel 		203 	2031 2032; 																			# VERTICAL Abutment 1
uniaxialMaterial ElasticPPGap 	215 	[expr $kabutl15NE*$cfactor] [expr -$pabutl15NE*$cfactor] [expr -$gap15NE] 1.0e-3 damage; 	# LONGITUDINAL Abutment 15 NE
uniaxialMaterial ElasticPP 		216 	[expr $kabutt15NE*$cfactor] [expr $pabutt15NE/$kabutt15NE]; 								# TRANSVERSE Abutment 15 NE
uniaxialMaterial ENT 			2171 	[expr 3.5*$kabutv15NE];
uniaxialMaterial ElasticPPGap 	2172 	[expr 1.0e+9] [expr -1.0e+9] -$gapV 1.0e-3 damage;
uniaxialMaterial Parallel 		217 	2171 2172; 																					# VERTICAL Abutment 15 NE
uniaxialMaterial ElasticPPGap 	218 	[expr $kabutl15NR*$cfactor] [expr -$pabutl15NR*$cfactor] [expr -$gap15NR] 1.0e-3 damage; 	# LONGITUDINAL Abutment 15 NR
uniaxialMaterial ElasticPP 		219 	[expr $kabutt15NR*$cfactor] [expr $pabutt15NR/$kabutt15NR]; 								# TRANSVERSE Abutment 15 NR
uniaxialMaterial ENT 			2201 	[expr 3.5*$kabutv15NR];
uniaxialMaterial ElasticPPGap 	2202 	[expr 1.0e+9] [expr -1.0e+9] -$gapV 1.0e-3 damage;
uniaxialMaterial Parallel 		220 	2201 2202; 																					# VERTICAL Abutment 15 NR
uniaxialMaterial Elastic 		2000 	[expr 0.0*$kips/$in]; 							# ROTATIONAL
element zeroLength 120000  1021 1020 -mat 202 201 203 2000 2000 2000 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient -156.24 -202.12 0 176.95 -135.55 0; 
element zeroLength 130000  1031 1030 -mat 202 201 203 2000 2000 2000 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 156.24 202.12 0 -176.95 135.55 0; 
element zeroLength 1510000  15021 15020 -mat 216 215 217 2000 2000 2000 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient -223.99 -290.74 0 329.51 38.87 0; 
element zeroLength 1520000  15031 15030 -mat 216 215 217 2000 2000 2000 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 223.99 290.74 0 -329.51 -38.87 0; 
element zeroLength 1550000  15051 15050 -mat 219 218 220 2000 2000 2000 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient -77.97 -101.20 0 348.96 -10.50 0; 
element zeroLength 1560000  15061 15060 -mat 219 218 220 2000 2000 2000 -dir 1 2 3 4 5 6 -doRayleigh $rFlag -orient 77.97 101.20 0 -348.96 10.50 0;
set gravRec ""
lappend gravRec [recorder Node -xml $dataDir/nodeforceZ.out -time -node 1020 1010 1030 201 207 301 307 401 407 501 507 601 607 701 707 801 807 901 907 1001 1007 1101 1107 1201 1209 1211 1301 1307 1313 1401 1407 1409 1413 15020 15030 15050 15060 -dof 3 reaction]
lappend gravRec [recorder Node -xml $dataDir/nodeforceX.out -time -node 1020 1010 1030 201 207 301 307 401 407 501 507 601 607 701 707 801 807 901 907 1001 1007 1101 1107 1201 1209 1211 1301 1307 1313 1401 1407 1409 1413 15020 15030 15050 15060 -dof 1 reaction]
lappend gravRec [recorder Node -xml $dataDir/nodeforceY.out -time -node 1020 1010 1030 201 207 301 307 401 407 501 507 601 607 701 707 801 807 901 907 1001 1007 1101 1107 1201 1209 1211 1301 1307 1313 1401 1407 1409 1413 15020 15030 15050 15060 -dof 2 reaction]
lappend gravRec [recorder Node -xml $dataDir/nodeMoment.out -time -node 1020 1010 1030 201 207 301 307 401 407 501 507 601 607 701 707 801 807 901 907 1001 1007 1101 1107 1201 1209 1211 1301 1307 1313 1401 1407 1409 1413 15020 15030 15050 15060 -dof 4 5 reaction]
lappend gravRec [recorder Node -xml $dataDir/nodemomXY.out -time -node 201 207 302 306 402 406 502 506 702 706 802 806 902 906 1002 1006 1102 1106 1201 1211 1209 1301 1307 1313 1401 1407 1413 -dof 4 5 reaction]
lappend gravRec [recorder Node -file $dataDir/nodeDisp.out -time -node 1408 1302 -dof 1 2 3 disp]
lappend gravRec [recorder Node -file $dataDir/nodeAcc.out -time -node 1408 1302 -dof 1 2 3 accel]
file mkdir "$dataDir/ModeShape"; # Output folder
set nPds 8; # Number of periods to analyze
set NodeCor	      [open $dataDir/ModeShape/Nodes.txt w];

close $NodeCor
for {set k 1} {$k <= $nPds} {incr k 1} {
	lappend gravRec [recorder Node -file $dataDir/ModeShape/mode$k.txt -time -node 1010 1020 1030 201 202 203 204 205 206 207 301 302 303 304 305 306 307 401 402 403 404 405 406 407 501 502 503 504 505 506 507 601 602 603 604 605 606 607 701 702 703 704 705 706 707 801 802 803 804 805 806 807 901 902 903 904 905 906 907 1001 1002 1003 1004 1005 1006 1007 1101 1102 1103 1104 1105 1106 1107 1201 1202 1203 1204 1205 1206 1207 1208 1209 1210 1211 1301 1302 1303 1304 1305 1306 1307 1313 1314 1315 1401 1402 1403 1404 1405 1406 1407 1408 1409 1413 1414 1415 15010 15020 15030 15040 15050 15060 10001 10002 10003 10004 20001 20002 20003 20004 30001 30002 30003 30004 40001 40002 40003 40004 50001 50002 50003 50004 60001 60002 60003 60004 70001 70002 70003 70004 80001 80002 80003 80004 90001 90002 90003 90004 100001 100002 100003 100004 110001 110002 110003 110004 120001 120002 120003 120004 130001 130002 130003 130004 140001 140002 140003 140004 120005 120006 120007 120008 130005 130006 130007 130008 140005 140006 140007 140008 500010 800040 1200010 1200050 -dof 1 2 3 "eigen $k."]
}
lappend gravRec [recorder Node -binary $dataDir/allNodesGrav.disp		-precision 5	-time	-dof 1 2 3 4 5 6 disp]
set wa [eigen $nPds];
set Periods 	[open $dataDir/ModeShape/PeriodsPreG.txt w];
for {set iPd 1} {$iPd <= $nPds} {incr iPd 1} {
	set wwa [lindex $wa $iPd-1];
	set Ta [expr 2*$pi/sqrt($wwa)];
}
close $Periods;
source getVertCosines.tcl
set vecxz301 "0 0 1";
pattern Plain 999 Linear {
	# Cap Beam Element Loads
	set CSDir "./Dimensions/CapCS/";  							# Directory containing cap beam cross section information
	set CSType "Cap"; 											# Cross section type is cap beam
	# Bents 2-11
	for {set ib 2} {$ib <= 11} {incr ib 1} {
		lassign [ReadMPR $CSDir $CSType $ib {}] A Iy Iz J; # Cross Section properties
		lassign [getVertCosines [expr 10000*$ib+10] $vecxz301] cosy cosz cosx curEle;
		eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
		lassign [getVertCosines [expr 10000*$ib+20] $vecxz301] cosy cosz cosx curEle;
		eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
	}
	# Bent 12
	lassign [ReadMPR $CSDir $CSType 12 {}] A Iy Iz J; # Cross Section properties
	for {set eleCtr 0; set eleNum "120010 120020 120030 120040";} {$eleCtr<=3} {incr eleCtr} {
		lassign [getVertCosines [lindex $eleNum $eleCtr] $vecxz301] cosy cosz cosx curEle;
		eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
	}
	# Bent 13 NE
	lassign [ReadMPR $CSDir $CSType 13 {}] A Iy Iz J; # Cross Section properties
	lassign [getVertCosines 130010 $vecxz301] cosy cosz cosx curEle;
	eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
	lassign [getVertCosines 130020 $vecxz301] cosy cosz cosx curEle;
	eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
	# Bent 14 NE
	lassign [ReadMPR $CSDir $CSType 14 {}] A Iy Iz J; # Cross Section properties
	lassign [getVertCosines 140010 $vecxz301] cosy cosz cosx curEle;
	eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
	lassign [getVertCosines 140020 $vecxz301] cosy cosz cosx curEle;
	eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
	# Deck Element Loads
	set CSDir "./Dimensions/DeckCS/";  							# Directory containing deck cross section information
	set CSType "Deck"; 											# Cross section type is deck
	# NE Side
	for {set ib 1} {$ib <= 14} {incr ib 1} {
		for {set ibb 0} {$ibb <= 4} {incr ibb 1} {
			lassign [ReadMPR $CSDir $CSType $ib "-NodeNum $ibb"] A Iy Iz J; # Cross Section properties
			lassign [getVertCosines [expr 10*$ib+$ibb] $vecxz301] cosy cosz cosx curEle;
			eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
			#eleLoad -ele [expr 10*$ib+$ibb] -type -beamUniform 0 [expr -$wconc*$A]; # Uniformly distributed element load acting in vertical (local y) direction of element
		} 
	}
	for {set ib 12} {$ib <= 14} {incr ib 1} {
		for {set ibb 5} {$ibb <= 9} {incr ibb 1} {
			lassign [ReadMPR $CSDir $CSType $ib "-NodeNum $ibb"] A Iy Iz J; # Cross Section properties
			lassign [getVertCosines [expr 10*$ib+$ibb] $vecxz301] cosy cosz cosx curEle;
			eleLoad -ele $curEle -type -beamUniform [expr -$wconc*$A*$cosy] [expr -$wconc*$A*$cosz] [expr -$wconc*$A*$cosx];
			#eleLoad -ele [expr 10*$ib+$ibb] -type -beamUniform 0 [expr -$wconc*$A]; # Uniformly distributed element load acting in vertical (local y) direction of element
		} 
	}
};
   
wipeAnalysis
test NormDispIncr 1.0e-8 10 0;	
algorithm Newton;	
integrator LoadControl 0.1;
numberer Plain;
constraints Transformation;
system SparseGeneral;
analysis Static;
# print -JSON -file $dataDir/modelDetails.json
#
analyze 10;
loadConst -time 0.0;
set wb [eigen -fullGenLapack $nPds];
set Periods 	[open $dataDir/ModeShape/PeriodsPostG.txt w];
for {set iPd 1} {$iPd <= $nPds} {incr iPd 1} {
	set wwb [lindex $wb $iPd-1];
	set Tb [expr 2*$pi/sqrt($wwb)];
}
close $Periods;
for {set ctrRec 0} {$ctrRec<[llength $gravRec]} {incr ctrRec} {
	remove recorder [lindex $gravRec $ctrRec]
}

