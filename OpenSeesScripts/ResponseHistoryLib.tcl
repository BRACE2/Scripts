#
#   Chrystal Chern
#   Claudio Perez
#
# To install dependencies, run
#
#   pip install quakeio
#
# Overview
#   proc read_quake {tag file channel args}
#       Parse motion and create a time series
#
#   class ResponseHistory
#     method patterns {patterns}
#     method analyze <steps> <dt>

proc lshift listVar {
    upvar 1 $listVar l
    set r [lindex $l 0]
    set l [lreplace $l [set l 0] 0]
    return $r
}

proc rayleigh_alpha {eigi eigj {lambdaN 0}} {
  set pi      [expr acos(-1.0)];
  set nEigenI [lindex $eigi 0];
  set nEigenJ [lindex $eigj 0];
  set iDamp [lindex $eigi 1];  # Mode 1 damping ratio
  set jDamp [lindex $eigj 1];  # Mode 2 damping ratio
  if {$lambdaN} {
  } else {
    # number of eigenvalues to compute
    set neig [tcl::mathfunc::max $nEigenI $nEigenJ]
    puts "rayleigh >> running modal analysis to generate Rayleigh damping properties"
    set lambdaN [eigen -fullGenLapack $neig];
    puts "rayleigh >> modal analysis complete; ready for Rayleigh damping"
  }
  set lambdaI [lindex $lambdaN [expr $nEigenI-1]];
  set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];
  set omegaI [expr $lambdaI**0.5];
  set omegaJ [expr $lambdaJ**0.5];
  puts "rayleigh >> omegaI = $omegaI; omegaJ = $omegaJ"
  set TI [expr 2.0*$pi/$omegaI];
  set TJ [expr 2.0*$pi/$omegaJ];
  puts "rayleigh >> TI = $TI; TJ = $TJ"
  set alpha0 [expr 2.0*($iDamp/$omegaI-$jDamp/$omegaJ)/(1/$omegaI**2-1/$omegaJ**2)];
  set alpha1 [expr 2.0*$iDamp/$omegaI-$alpha0/$omegaI**2];
  puts "rayleigh >> alpha0 = $alpha0; alpha1 = $alpha1"
  return [list $alpha0 0.0 0.0 $alpha1];
}

proc read_quake {tag file channel args} {
    # Parse options
    # https://stackoverflow.com/questions/31110082/how-to-create-tcl-proc-with-hyphen-flag-arguments
    array set options {-scale {} -scale 1.0 -quxwoo 1}
    while {[llength $args]} {
        switch -glob -- [lindex "$args" 0] {
            -bar*   {set args [lassign $args - options(-bargle)]}
            -s*     {set args [lassign $args - options(-scale)]}
            -c*     {set args [lassign $args - options(-channel)]}
            -qux*   {set options(-quxwoo) 1 ; set args [lrange $args 1 end]}
            --      {set args [lrange $args 1 end] ; break}
            -*      {error "unknown option [lindex $args 0]"}
            default break
        }
    }
    # Call parser
    array set series [
      exec quakeio -t tcl $file -m station_channel:l=$channel {*}$args
    ]

	  timeSeries Path $tag -dt $series(dt) -values $series(values) -factor $options(-scale)
    return [list $series(shape) $series(dt)]
}

::oo::class create ResponseHistory {
    variable dt 
    variable algorithm
    variable current_series_tag
    variable current_pattern_tag
    variable num_steps
    variable dt
    variable final_time

    constructor {args} {
        set current_pattern_tag 1
        set current_series_tag 1
        set num_steps 0
        set dt 0

        set algorithm Newton
        
        set Tol				  1.0e-8;
        set maxNumIter	100;
        set printFlag		0;
        set TestType		EnergyIncr;
        test $TestType $Tol $maxNumIter $printFlag;
        
        numberer RCM;

        #                  gamma  beta
        integrator Newmark 0.50   0.25 
    }

    method pattern {args} {
        switch -glob -- [lindex "$args" 0] {
            UniformQuake  {
              set args [uplevel 2 "subst {$args}"]
              set args [lassign $args - dof]
              lassign [brace2::read_quake $current_series_tag {*}$args] num_steps dt
              set final_time [expr {$num_steps*$dt}]
              pattern UniformExcitation $current_pattern_tag $dof -accel $current_series_tag
              incr current_pattern_tag
              incr current_series_tag
            }
            "#*" {}
            "" {}
            * {puts "unknown option [lindex $args 0]"}
            default break
      }
    }

    method patterns {pats} {
      foreach pat [split $pats "\n"] {my pattern {*}$pat}
    }

    method print {} {
      puts "Time step:   $dt"
      puts "Record size: $num_steps"
    }

    method analyze {args} {
      lassign [list $num_steps $dt] n dt
      set pos_args {n dt}
      while {[llength $args]} {
        switch -glob -- [lindex "$args" 0] {
          -n* {set args [lassign $args - n]}
          -dt {set args [lassign $args - dt]}
          *   {set args [lassign $args [brace2::lshift pos_args]]}
        }
      }
      # if {![info exists n]} {set n $num_steps}
      # if {![info exists dt]} {set dt $dt}
      puts "analyzing $n steps with increment $dt"
      analysis Transient;
      for {set ik 1} {$ik <= $n} {incr ik 1} {
          if {[my step $dt] != 0} {return $ik}
      }
    }

    method step {dt} {
      foreach alg "
        $algorithm
        {NewtonLineSearch -type Bisection}
        {NewtonLineSearch -type Secant}
        {NewtonLineSearch -type RegulaFalsi}
        KrylovNewton
        Broyden
        BFGS
      " {
        algorithm {*}$alg
        if {[set ok [analyze 1 $dt]] == 0} {
          algorithm $algorithm; break
        }
      }
        return $ok
    }
}

proc modal { num_modes filename {eig_solver -genBandArpack}} {
	# get all node tags
	set nodes [getNodeTags]
	
	# check problem size (2D or 3D) from the first node, we do not support mixed dimesions!!
	set ndm [llength [nodeCoord [lindex $nodes 0]]]
	
	# compute total masses
	if {$ndm == 3} { 
		set ndf_max 6 
		set total_mass {0.0 0.0 0.0 0.0 0.0 0.0}
		set mass_labels {"MX" "MY" "MZ" "MRX" "MRY" "MRZ"}
		set mass_labels1 {"MODE" "MX" "MY" "MZ" "MRX" "MRY" "MRZ"}
	} else {
		set ndf_max 3
		set total_mass {0.0 0.0 0.0}
		set mass_labels {"MX" "MY" "MRZ"}
		set mass_labels1 {"MODE" "MX" "MY" "MRZ"}
	}
	foreach node $nodes {
		set indf [llength [nodeDisp $node]]
		for {set i 0} {$i < $indf} {incr i} {
			set imass [nodeMass $node [expr $i+1]]
			set imass_total [lindex $total_mass $i]
			lset total_mass $i [expr $imass_total + $imass]
		}
	}
	
	# some constants
	set pi [expr acos(-1.0)]
	
	# solve the eigenvalue problem
	set lambdas [eigen $eig_solver $num_modes]
	if {[llength $lambdas] != $num_modes} {
		error "modal - Error: something went wrong in the eigen analysis"
	}
	
	# results for each mode
	set mode_data [lrepeat $num_modes [lrepeat 4 0.0]]
	set mode_MPM [lrepeat $num_modes [lrepeat $ndf_max 0.0]]
	
	# process each mode of vibration
	for {set imode 0} {$imode < $num_modes} {incr imode} {
		
		# compute i-mode data
		set lambda [lindex $lambdas $imode]
		set omega [expr {sqrt($lambda)}]
		set frequency [expr $omega / 2.0 / $pi]
		set period [expr 1.0 / $frequency]
		lset mode_data $imode [list $lambda $omega $frequency $period]
		
		# M = mass matrix
		# V = eigen vector matrix
		# gm = V'* M * V = generalized mass matrix
		# R = influence vector
		# L = V' * M * R = coefficient vector
		# MPMi = L(i)^2 / gm(i,i) / total_mass * 100.0 = modal participation mass ratio (%)
		
		# compute L and gm
		set L [lrepeat $ndf_max 0.0]
		set gm 0.0
		foreach node $nodes {
			# get eigenvector
			set V [nodeEigenvector $node [expr $imode+1]]
			set indf [llength [nodeDisp $node]]
			# for each dof
			for {set i 0} {$i < $indf} {incr i} {
				set Mi [nodeMass $node [expr $i+1]]
				set Vi [lindex $V $i]
				set Li [expr $Mi * $Vi]
				set gm [expr $gm + $Vi * $Vi * $Mi]
				lset L $i [expr [lindex $L $i]+ $Li]
			}
		}
		
		# compute MPM
		set MPM [lrepeat $ndf_max 0.0]
		for {set i 0} {$i < $ndf_max} {incr i} {
			set Li [lindex $L $i]
			set TMi [lindex $total_mass $i]
			set MPMi [expr $Li * $Li]
			if {$gm > 0.0} {set MPMi [expr $MPMi / $gm]}
			if {$TMi > 0.0} {set MPMi [expr $MPMi / $TMi * 100.0]}
			lset MPM $i $MPMi
		}
		lset mode_MPM $imode $MPM
	}
	
	# print results to both stdout and file
	proc multiputs {args} {
		if { [llength $args] == 0 } {
			error "Usage: multiputs ?channel ...? string"
		} elseif { [llength $args] == 1 } {
			set channels stdout
		} else {
			set channels [lrange $args 0 end-1]
		}
		set str [lindex $args end]
		foreach ch $channels {
			puts $ch $str
		}
	}
	
	# open file for output
	set fp [open $filename w]
	
	multiputs stdout $fp "MODAL ANALYSIS REPORT"
	multiputs stdout $fp "\nPROBELM SIZE IS ${ndm}D"
	
	# print mode data
	multiputs stdout $fp "\nEIGENVALUE ANALYSIS"
	set format_string [string repeat "%16s" 5]
	set format_double [string repeat "%16g" 5]
	multiputs stdout $fp [format $format_string "MODE" "LAMBDA" "OMEGA" "FREQUENCY" "PERIOD"]
	for {set i 0} {$i < $num_modes} {incr i} {
		multiputs stdout $fp [format $format_double [expr $i+1] {*}[lindex $mode_data $i]]
	}
	
	multiputs stdout $fp "\nTOTAL MASS OF THE STRUCTURE"
	set format_string [string repeat "%16s" $ndf_max]
	set format_double [string repeat "%16g" $ndf_max]
	multiputs stdout $fp [format $format_string {*}$mass_labels]
	multiputs stdout $fp [format $format_double {*}$total_mass]
	
	# print modal participation masses ratio
	multiputs stdout $fp "\nMODAL PARTICIPATION MASSES (%)"
	set format_string [string repeat "%16s" [expr $ndf_max+1]]
	set format_double [string repeat "%16g" [expr $ndf_max+1]]
	multiputs stdout $fp [format $format_string {*}$mass_labels1]
	for {set i 0} {$i < $num_modes} {incr i} {
		multiputs stdout $fp [format $format_double [expr $i+1] {*}[lindex $mode_MPM $i]]
	}
	
	# print modal participation masses ratio
	multiputs stdout $fp "\nCUMULATIVE MODAL PARTICIPATION MASSES (%)"
	set format_string [string repeat "%16s" [expr $ndf_max+1]]
	set format_double [string repeat "%16g" [expr $ndf_max+1]]
	multiputs stdout $fp [format $format_string {*}$mass_labels1]
	set MPMsum [lrepeat $ndf_max 0.0]
	for {set i 0} {$i < $num_modes} {incr i} {
		set MPMi [lindex $mode_MPM $i]
		for {set j 0} {$j < $ndf_max} {incr j} {
			lset MPMsum $j [expr [lindex $MPMsum $j] + [lindex $MPMi $j]]
		}
		multiputs stdout $fp [format $format_double [expr $i+1] {*}$MPMsum]
	}
	
	# done
	close $fp
	puts "\nModal Analysis done\n"
}
