cd ../../CalTrans.Hayward/Procedures
for model in $(find -maxdepth 1 -name "hwd*.tcl"); do
    modelName=`basename ${model/./} .tcl`
    echo "running $modelName"
    opensees.exe $model
    python -m render data$modelName/modelDetails.json data$modelName/modesPostG.yaml -o data$modelName/modes.html -s 200 --vert 3;
    python -m render data$modelName/modelDetails.json data$modelName/dispsGrav.yaml -o data$modelName/dispsGrav.html -s 200 --vert 3;
    # python Scripts/ModeID.py 
    python Scripts/plotPds.py data$modelName/ data$modelName/;
    # python Scripts/plotRH.py senorsRH.out datahwd10.1.$i/RH.out &&
    # python Scripts/compareRH.py sensorRH.out datahwd10.1.$i/RH.out &&
    # python Scripts/png2md.py datahwd10.1.$i/plot.png &&
    done 