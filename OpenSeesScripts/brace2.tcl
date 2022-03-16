package provide brace2 0.1

set dir [file dirname [file normalize [info script]]]

# Create the namespace
namespace eval brace2 {
  set this_namespace brace2::
  source [file join $dir ResponseHistoryLib.tcl]
  source [file join $dir StaticAnalysis.tcl]
  source [file join $dir ColSectionLib.tcl]
  namespace eval io {
    source [file join $dir LibIO.tcl]
  }
}
source [file join $dir ReadMPR.tcl]
source [file join $dir units.tcl]

proc py {args} {
    eval "[exec python.exe {*}$args]"
}

