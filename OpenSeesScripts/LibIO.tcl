proc write_modes {mode_file nmodes} {
  set fid_modes [open $mode_file w+]
  for {set m 1} {$m <= $nmodes} {incr m} {
    puts $fid_modes "$m:"
    foreach n [getNodeTags] {
      puts $fid_modes "  $n: \[[join [nodeEigenvector $n $m] {, }]\]";
    }
  }
  close $fid_modes
}

