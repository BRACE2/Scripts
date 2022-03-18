package provide brace2 0.1
# Modeling utilities for the BRACE2 project
# Authors:
#   Crystal Chern
#   Claudio Perez

set dir [file dirname [file normalize [info script]]]

namespace eval brace2 {
  set this_namespace brace2::
  source [file join $dir ResponseHistoryLib.tcl]
  source [file join $dir StaticAnalysis.tcl]
  source [file join $dir EigenvalueAnalysis.tcl]
  source [file join $dir ColSectionLib.tcl]
  namespace eval io {
    source [file join $dir LibIO.tcl]
  }
  proc new {type {name ""} args} {
    if {[string match "-*" $name]} {
      set cmd "brace2::$type new $name"
      uplevel 1 "$cmd"
    } elseif {$name eq ""} {
      $type new {*}$args
    } else {
      #set cmd "brace2::$type create $name "
      uplevel 1 "brace2::$type create $name {*}{$args}"
    }
  }
}
source [file join $dir ReadMPR.tcl]
source [file join $dir units.tcl]

proc py {args} {
    eval "[exec python.exe {*}$args]"
}

