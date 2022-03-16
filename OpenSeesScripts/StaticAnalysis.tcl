::oo::class create GravityAnalysis {
  constructor {} {
    test NormDispIncr 1.0e-8 10 0;	
    algorithm Newton;	
    integrator LoadControl 0.1;
    numberer Plain;
    constraints Transformation;
    system SparseGeneral;
    analysis Static;
  }
  
  method analyze {n} {
    analyze $n;
  }
}


