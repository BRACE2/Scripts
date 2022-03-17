::oo::class create EigenvalueAnalysis {
  #============================================================
  # Eigenvalue analysis
  # This class orchestrates an eigenvalue analysis using OpenSees 
  #
  # Claudio Perez
  # Summer 2021
  # OpenSees version 3.3.0
  #============================================================
  constructor { } {
  }

  method analyze {args} {
    array set options {-numModes 1 -system {} -file 0 -verbose 0}
    while {[llength $args]} {
        switch -glob -- [lindex "$args" 0] {
            -file   {set args [lassign $args - options(-file)]}
            -v*     {set options(-verbose) 1 ; set args [lrange $args 1 end]}
            --      {set args [lrange $args 1 end] ; break}
            -*      {error "unknown option [lindex $args 0]"}
            *       {set args [lassign $args options(-numModes)]}
            default break
        }
    }

    # Constant parameters.
    set verbose  1
    set PI       3.1415159
    set DOFs     {1 2 3 4 5 6}
    set nodeList [getNodeTags]
    # Initialize variables `omega`, `f` and `T` to
    # empty lists.
    foreach {omega f T} {{} {} {}} {}

    for {set k 1} {$k <= $options(-numModes)} {incr k} {
      recorder Node -node {*}$nodeList -dof {*}$DOFs "eigen $k";
    }

    set eigenvals [eigen $options(-numModes)];

    set T_scale 1.0
    foreach eig $eigenvals {
      lappend omega [expr sqrt($eig)];
      lappend f     [expr sqrt($eig)/(2.0*$PI)];
      lappend T     [expr $T_scale*(2.0*$PI)/sqrt($eig)];
    }

    # print info to `stdout`.
    if {$options(-verbose)} {
      puts "Angular frequency (rad/s): \t$omega\n";
      puts "Frequency (Hz): \t$f\n";
      puts "Periods (sec): \t$T\n";
    }

    if {$options(-file) != 0} {
      set mode_file [open $options(-file) w+]
    }

    for {set m 1} {$m <= 3} {incr m} {
      puts $mode_file "$m:"
      foreach n "$nodeList" {
        puts $mode_file "  $n: \[[join [nodeEigenvector $n $m] {, }]\]";
      }
    }
  }
}


