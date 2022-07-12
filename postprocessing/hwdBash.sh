cd ../../CalTrans.Hayward/Procedures

# # Run all hwd models in parallel, 6 at a time
# N=6
# for model in $(find -maxdepth 1 -name "hwd*.tcl"); do
#     ((i=i%N)); ((i++==0)) && wait
#     { modelName=`basename ${model/./} .tcl`
#     echo "running $modelName"
#     opensees.exe $model
#     python -m render data$modelName/modelDetails.json data$modelName/modesPostG.yaml -o data$modelName/modes.html -s 200 --vert 3 &&
#     python -m render data$modelName/modelDetails.json data$modelName/dispsGrav.yaml -o data$modelName/dispsGrav.html -s 200 --vert 3 &&
#     # python ../../Scripts/ModeID.py 
#     python ../../Scripts/postprocessing/plotPds.py data$modelName/ data$modelName/; } &
#     # python ../../Scripts/plotRH.py senorsRH.out datahwd10.1.$i/RH.out &&
#     # python ../../Scripts/compareRH.py sensorRH.out datahwd10.1.$i/RH.out &&
#     # python ../../Scripts/png2md.py datahwd10.1.$i/plot.png &&
# done

# # Run all hwd models one at a time
# for model in $(find -maxdepth 1 -name "hwd*.tcl"); do
#     modelName=`basename ${model/./} .tcl`
#     echo "running $modelName"
#     opensees.exe $model
#     python -m render data$modelName/modelDetails.json data$modelName/modesPostG.yaml -o data$modelName/modes.html -s 200 --vert 3 &&
#     python -m render data$modelName/modelDetails.json data$modelName/dispsGrav.yaml -o data$modelName/dispsGrav.html -s 200 --vert 3 &&
#     # python ../../Scripts/ModeID.py 
#     python ../../Scripts/postprocessing/plotPds.py data$modelName/ data$modelName/;
#     # python ../../Scripts/plotRH.py senorsRH.out datahwd10.1.$i/RH.out &&
#     # python ../../Scripts/compareRH.py sensorRH.out datahwd10.1.$i/RH.out &&
#     # python ../../Scripts/png2md.py datahwd10.1.$i/plot.png &&
# done

# cd ~/Documents/GitHub/Scripts/postprocessing
# python compareRH.py RMS ../../CalTrans.Hayward/Procedures/datahwd10.3.0/model/AA_Ch19-20_X.txt ../../CalTrans.Hayward/Procedures/datahwd10.3.1/model/AA_Ch19-20_X.txt
# python compareRH.py RMS ../../CalTrans.Hayward/Procedures/datahwd10.4.0/model/AA_Ch19-20_X.txt ../../CalTrans.Hayward/Procedures/datahwd10.4.1/model/AA_Ch19-20_X.txt
# python ../preprocessing/makePattern.py ../../CalTrans.Hayward/Procedures/Records/berkeley_04jan2018_72948801_ce58658p.zip --accel 0 > inputGMlong.csv
# python ../preprocessing/makePattern.py ../../CalTrans.Hayward/Procedures/Records/berkeley_04jan2018_72948801_ce58658p.zip --accel 1 > inputGMtran.csv
# python compareRH.py RMS inputGMlong.txt ../../CalTrans.Hayward/Procedures/Records/24-25_long_global.txt
# python compareRH.py RMS inputGMtrans.txt ../../CalTrans.Hayward/Procedures/Records/24-25_trans_global.txt
# python ../preprocessing/makePattern.py ../../CalTrans.Hayward/Procedures/Records/berkeley_04jan2018_72948801_ce58658p.zip --accel 0 | python compareRH.py RMS - ../../CalTrans.Hayward/Procedures/Records/24-25_long_global.txt
# python ../preprocessing/makePattern.py ../../CalTrans.Hayward/Procedures/Records/berkeley_04jan2018_72948801_ce58658p.zip --accel 1 | python compareRH.py RMS - ../../CalTrans.Hayward/Procedures/Records/24-25_trans_global.txt
# python ../preprocessing/getSensorResponse.py ../../CalTrans.Hayward/Procedures/Records/berkeley_04jan2018_72948801_ce58658p.zip --accel > accel.yaml

# cd ~/Documents/GitHub/CalTrans.Hayward/Procedures
# opensees.exe hwd10.4.1.tcl

for model in ./hwd10.4.0.tcl ./hwd10.4.1.tcl; do
    modelName=`basename ${model/./} .tcl`
    echo "running $modelName"
    opensees.exe $model;
done
