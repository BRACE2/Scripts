### Run twice for everything to update
```
pip install -U quakeio opensees
```

### ```makePattern.py``` (location-specific):
1. create rotated OpenSees patterns
    ```
    lassign [py makePattern.py filename.zip] dt step
    ```
    Also see ```test.tcl```

2. make rotated csv for a specific location on bridge
    ```
    python makePattern.py filename.zip --accel
    ```

### ```getSensorResponse.py```: transforms sensor data to the YAML format used by some other tools.

1. Example: write file named ```accel.yaml``` with acceleration data by ```timestep->node->dof```
    ```
    python getSensorResponse.py filename.zip --accel > accel.yaml
    ```

2. Example: write file named ```displ.yaml``` with displacement data
    ```
    python getSensorResponse.py filename.zip --displ > displ.yaml
    ```
