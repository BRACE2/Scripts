# Claudio Perez
# To install dependencies, run
#
#   pip install quakeio
#

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

	  timeSeries Path $tag -dt $series(dt) -values $series(values)
    return [list $series(shape) $series(dt)]
}

::oo::class create ResponseHistory {
    variable dt 
    variable algorithm
    variable current_series_tag
    variable current_pattern_tag
    variable num_steps
    variable dt

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
          *   {set args [lassign $args [lshift $pos_args]]}
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


