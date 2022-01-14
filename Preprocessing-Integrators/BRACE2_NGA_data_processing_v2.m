close all;
clear all;
clc;

% Data processing of raw acceleration data in .v1 files. It applies to both
% ground motion and measured structural response 

% The code consists of four main parts.
% 1st part conducts pre-processing of data and includes baseline correction
% and filtering
% 2nd part performs double integration and other methods to compute velocity and
% displacement from acceleration data
% 3rd part plots the results and compared against CESMD v2 files
% 4th part generate files in PEER format using the processed data. These
% can be uploaded to NGA-W2 or a structural response version of the
% database

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 0: Reading/Setting information %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Constants
g=981;                                           %acceleration of gravity in cm/sec^2
%% Inputs

% Some of the input can be adjusted to be input from the command prompt
EQname='Petrolia';                     % Earthquake Name
EQdate=' 12/20/2021';                  % Earthquake Date, this is for the PEER file in Part 4 
MT='GM';                               % Options are 'GM' for ground motions and 'SM' for structural motions
FolderName=strcat(EQname,'_',MT);      % Folder Name
%StationName='NP1023';
%StationName='NP1023_V';
StationName='BKPETL';
%StationName='BKPETL_V';

Preprocess='Yes';                      % Options are 'Yes' or 'No'
                                       % 'Yes' includes baseline correction and filtering
BLorder=1;                             % Order of the polynomial used for baseline correction
                                       % 0: constant, 1: linear, etc.

Filtertype='Trap';                       % Options are 1)'BW' : Butterworth, 2) 'CI' : Chebychev Type I, 
                                       % 3) 'CII' : Chebychev Type II, 4) 'Trap' : Trapezoidal                                        
                                       
FLorder=3;                             % Order of the filter used in Butterworth and Chebychev filters
lowcut=0.30;                           % lower cutoff frequency used in bandpass filter, applies to all filter types
highcut=23.0;                          % higher cutoff frequency used in bandpass filter, applies to all filter types

Integtype='FD';                      % Options are 1)'Trap' : Trapezoidal rule, 2) 'Simp' : Simpson's rule, 
                                       % 3) 'NM' : Newmark difference equations, 4) 'RK5' : Fifth order Runge-Kutta
                                       % 5) 'FD' : Frequency domain
                                                                          
%% Read the raw and processed data
FileName=StationName;
rawfilename=strcat(FolderName,'_v1','/',FileName,'.v1');        % file name of the raw acc data
processedfilename=strcat(FolderName,'_v2','/',FileName,'.v2');  % file name of the processed acc data

% readv1p is a function that reads raw accelerometer data (in g's) & time step from CSMIP format .v1 files.
% This format is same for historical data & real-time data for the Hayward Bridge.  
[rawacc, dtr]=readv1p(rawfilename);   % raw acceleration (g) and time step from '.v1' file 
rawacc=rawacc'*g;                     % Create a column vector with units of cm/s2
tr=0:dtr:dtr*(length(rawacc)-1);      % time vector for raw data

% readv2p is a function that reads processed accelerometer, velocity, and displacement data (in cm/s2, cm/s, and cm) 
% & time step from CSMIP format .v2 files.
% This format is same for historical data & real-time data for the Hayward Bridge.  
[procacc, procvel, procdisp, dtp]=readv2p(processedfilename);
                                     % processed acceleration (cm/s2), velocity (cm/s), displacement (cm),
                                     % and time step from '.v2' file
procacc=procacc'; procvel=procvel'; procdisp=procdisp'; % create column vectors
tp=0:dtp:dtp*(length(procacc)-1);                       %  time vector for processed data

%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 1: Preprocess: Filtering and Baseline Correction %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if strcmp(Preprocess, 'Yes')
   % 1) Baseline correction
   accbl=detrend(rawacc,BLorder);
   
   % 2) Filter
   if strcmp(Filtertype, 'BW')
       % Option 1: Butterworth filter
       [b,a] = butter(FLorder,[lowcut/(2/dtr) highcut/(2/dtr)],'bandpass');
       accf= filter(b,a,accbl);       
   elseif strcmp(Filtertype, 'CI')
       % Option 2: Type I Chebychev filter
       [b,a] = cheby1(FLorder,3,[lowcut/(2/dtr) highcut/(2/dtr)],'bandpass');
       accf= filter(b,a,accbl);
   elseif strcmp(Filtertype, 'CII')
       % Option 3: Type II Chebychev filter
       [b,a] = cheby2(FLorder,3,[lowcut/(2/dtr) highcut/(2/dtr)],'bandpass');
       accf= filter(b,a,accbl);
   elseif strcmp(Filtertype, 'Trap')
       % Option 4: Trapezoidal filter
       filterstr = [lowcut lowcut+0.005 highcut highcut+0.005];  % filter cutoffs (Hz), trapezoidal filter
                                                                 % filter is 0 when f<f1 or f>f4 (complete filter)
                                                                 % filter is 1 when f2<f<f3 (complete pass)
                                                                 % filter varies linearly between 0 and 1 when f1<f<f2 or f3<f<f4
                                                                 % f1 and f2 values are what is currently being used by CGS for the Hayward bridge
                                                                 % and probably other structures I think
       [accf,t1f] = trapfilter(accbl,dtr,filterstr);  % acc1f is the filtered acceleration vector and t1f is the corresponding time vector       
   end
else
   accf=rawacc; 
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 2: Double integration to compute displacements %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate the time vector
t=0:dtr:dtr*(length(accf)-1);

if strcmp (Integtype,'Trap') % Option 1: Trapezoidal rule
    
    % Integrate acc to compute velocity
    for i=1:length(accf)
        velTR(i)=trapz(accf(1:i))*dtr;
    end
    
    % Integrate velocity to compute displacement
    for i=1:length(velTR)
        dispTR(i)=trapz(velTR(1:i))*dtr;
    end
    
    velfinal=velTR;
    dispfinal=dispTR;
    legfinal='Trapezoidal Rule';
    
end

if strcmp (Integtype,'Simp') % Option 2: Simpson rule
    
    % Integrate acc to compute velocity
    t1=0:dtr/2:t(end);
    
    % First generate the intermediate points using spline interpolation
    accfinterp=interp1(t,accf,t1,'spline');
    
    % compute velocity
    velSP(1)=0;
    for i=2:length(accf)
        velSP(i)=velSP(i-1)+dtr/6*(accfinterp(2*i-3)+4*accfinterp(2*i-2)+accfinterp(2*i-1));
    end
    
    % Integrate velocity to compute displacement
    t1=0:dtr/2:t(end);
    
    % First generate the intermediate points using spline interpolation
    velSPinterp=interp1(t,velSP,t1,'spline');
    
    % compute displacement
    dispSP(1)=0;
    for i=2:length(velSP)
        dispSP(i)=dispSP(i-1)+dtr/6*(velSPinterp(2*i-3)+4*velSPinterp(2*i-2)+velSPinterp(2*i-1));
    end
    
    velfinal=velSP;
    dispfinal=dispSP;
    legfinal='Simpson Rule';
end

if strcmp (Integtype,'NM')||strcmp (Integtype,'FD') % Option 3: Velocity and displacement using Newmark difference equations

    gama=1/2;
    beta=1/4;
    
    velNM(1)=0;
    dispNM(1)=0;
    for i=1:length(accf)-1
        velNM(i+1)=velNM(i)+((1-gama)*dtr)*accf(i)+(gama*dtr)*accf(i+1);
        dispNM(i+1)=dispNM(i)+dtr*velNM(i)+((0.5-beta)*dtr^2)*accf(i)+(beta*dtr^2)*accf(i+1);
    end

    velfinal=velNM;
    dispfinal=dispNM;    
    legfinal='Newmark difference equations';
    
end

if strcmp (Integtype,'RK5') % Option 4: 5th order Runge-Kutta (Dormand-Prince)

    % Note that Simpson's rule is equivalent to classic fourth order
    % Runge-Kutta, therefore 4th order Runge-Kutta is not implemented seperately
    
    % fractions of intermediate points within the time step
    pint(1)=0;      pint(2)=3/10;     pint(3)=8/10;    pint(4)=8/9;        pint(5)=1;       % five points are used
    wint(1)=35/384; wint(2)=500/1113; wint(3)=125/192; wint(4)=-2187/6784; wint(5)=11/84;  % corresponding weights
    % note that the weights add up to 1
    % Generate the time vector with intemediate points
    j=0;
    for i=1:length(t)
        for j1=1:4
            t1((i-1)*4+j1)=t(i)+dtr*pint(j1);
            j=j+1;
        end
    end
    t1(j+1)=t(end);
    
    % Generate the intermediate points using spline interpolation
    accfinterp=interp1(t,accf,t1,'spline');
    
    figure;
    plot(t,accf,'r');
    hold on;
    plot(t1,accfinterp,'b');
    hold off;
    
    velRK5(1)=0;
    for i=2:length(accf)
        intrvalue=0;
        for j=1:5
            intrvalue=intrvalue+wint(j)*accfinterp((i-1)*4+j);
        end
        velRK5(i)=velRK5(i-1)+dtr*intrvalue;
    end
    
    % First generate the intermediate points using spline interpolation
    velRK5interp=interp1(t,velRK5,t1,'spline');
    
    % compute displacement
    dispRK5(1)=0;
    for i=2:length(velRK5)
        intrvalue=0;
        for j=1:5
            intrvalue=intrvalue+wint(j)*velRK5interp((i-1)*4+j);
        end
        dispRK5(i)=dispRK5(i-1)+dtr*intrvalue;
    end
    
    velfinal=velRK5;
    dispfinal=dispRK5;    
    legfinal='Fifth order Runge-Kutta';

end
                                                                                       
if strcmp (Integtype,'FD') % Option 5: Compute the displacement in the frequency domain 

    npts = length(accf);
    npts = floor(npts/2)*2;
    fa = fft(accf);
    
    % create frequency vector w in radians
    wf = linspace(1,npts/2,(npts/2))*2*pi/(npts*dtr);
    wr = fliplr(wf);
    w = [wf,wr];
    
    % convert to displacement in the frequency domain
    w2 = w.^2;
    w2=w2';
    fd = -fa./w2;
    
    % convert back to time domain
    y = ifft(fd);
    dispFRD = real(y);
    tFRD = linspace(0,npts*dtr,npts);
    t = tFRD;

    velfinal=velNM;
    dispfinal=dispFRD;    
    legfinal='Frequency domain';

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 3: Plotting the results %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
plot(tr,rawacc/g);
hold on;
plot(t,accf/g,'r');
plot(tp,procacc/g,'g');
legend('Raw','In-house processed','CESMD processed (.v2)')
xlabel('Time [Sec]');
ylabel('Acceleration [g]');

figure;
plot(t,velfinal);
hold on;
plot(tp,procvel,'r');
hold off;
legend(legfinal,'CESMD processed (.v2)')
xlabel('Time [Sec]');
ylabel('Velocity [cm/sec]');

figure;
plot(t,dispfinal);
hold on;
plot(tp,procdisp,'r');
hold off;
legend(legfinal,'CESMD processed (.v2)')
xlabel('Time [Sec]');
ylabel('Displacement [cm]');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 4: Generate files in PEER format using the processed data %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the acceleration file with .AT2 extension
outputaccfile=strcat(FileName,'.AT2');
fileID = fopen(outputaccfile,'w');
fprintf(fileID,'PEER NGA STRONG MOTION DATABASE RECORD\n');
EQ_station_line=strcat(EQname,EQdate,', ',StationName,', NS\n');
fprintf(fileID,EQ_station_line);
fprintf(fileID,'ACCELERATION TIME SERIES IN UNITS OF G\n');
formatSpec_NPTS_dt='NPTS=%7i  DT=%8.4f SEC,\n';
fprintf(fileID,formatSpec_NPTS_dt,length(accf),dtr);

formatSpec = '%15.7E%15.7E%15.7E%15.7E%15.7E\n';
accfw=accf/g;
lr=length(accf)-floor(length(accf)/5)*5;
for j=1:floor(length(accf)/5)+1
    if j<floor(length(accf)/5)+1
         j1=j-1;
         fprintf(fileID,formatSpec,accfw(5*j1+1),accfw(5*j1+2),accfw(5*j1+3),accfw(5*j1+4),accfw(5*j1+5));
    else
        j1=j-1;
        if lr==1
            fprintf(fileID,formatSpec,accfw(5*j1+1));
        elseif lr==2
            fprintf(fileID,formatSpec,accfw(5*j1+1),accfw(5*j1+2));
        elseif lr==3
            fprintf(fileID,formatSpec,accfw(5*j1+1),accfw(5*j1+2),accfw(5*j1+3));
        elseif lr==4
            fprintf(fileID,formatSpec,accfw(5*j1+1),accfw(5*j1+2),accfw(5*j1+3),accfw(5*j1+4));
        end                        
    end
end
fclose(fileID);

% Generate the velocity file with .VT2 extension
outputvelfile=strcat(FileName,'.VT2');
fileID = fopen(outputvelfile,'w');
fprintf(fileID,'PEER NGA STRONG MOTION DATABASE RECORD\n');
EQ_station_line=strcat(EQname,EQdate,', ',StationName,', NS\n');
fprintf(fileID,EQ_station_line);
fprintf(fileID,'VELOCITY TIME SERIES IN UNITS OF CM/S\n');
formatSpec_NPTS_dt='NPTS=%7i, DT=%8.4f SEC,\n';
fprintf(fileID,formatSpec_NPTS_dt,length(velfinal),dtr);

formatSpec = '%15.7E%15.7E%15.7E%15.7E%15.7E\n';
lr=length(velfinal)-floor(length(velfinal)/5)*5;
for j=1:floor(length(velfinal)/5)+1
    if j<floor(length(velfinal)/5)+1
         j1=j-1;
         fprintf(fileID,formatSpec,velfinal(5*j1+1),velfinal(5*j1+2),velfinal(5*j1+3),velfinal(5*j1+4),velfinal(5*j1+5));
    else
        j1=j-1;
        if lr==1
            fprintf(fileID,formatSpec,velfinal(5*j1+1));
        elseif lr==2
            fprintf(fileID,formatSpec,velfinal(5*j1+1),velfinal(5*j1+2));
        elseif lr==3
            fprintf(fileID,formatSpec,velfinal(5*j1+1),velfinal(5*j1+2),velfinal(5*j1+3));
        elseif lr==4
            fprintf(fileID,formatSpec,velfinal(5*j1+1),velfinal(5*j1+2),velfinal(5*j1+3),velfinal(5*j1+4));
        end                        
    end
end
fclose(fileID);

% Generate the displacement file with .DT2 extension
outputdispfile=strcat(FileName,'.DT2');
fileID = fopen(outputdispfile,'w');
fprintf(fileID,'PEER NGA STRONG MOTION DATABASE RECORD\n');
EQ_station_line=strcat(EQname,EQdate,', ',StationName,', NS\n');
fprintf(fileID,EQ_station_line);
fprintf(fileID,'DISPLACEMENT TIME SERIES IN UNITS OF CM\n');
formatSpec_NPTS_dt='NPTS=%7i, DT=%8.4f SEC,\n';
fprintf(fileID,formatSpec_NPTS_dt,length(dispfinal),dtr);

formatSpec = '%15.7E%15.7E%15.7E%15.7E%15.7E\n';
lr=length(dispfinal)-floor(length(dispfinal)/5)*5;
for j=1:floor(length(dispfinal)/5)+1
    if j<floor(length(dispfinal)/5)+1
         j1=j-1;
         fprintf(fileID,formatSpec,dispfinal(5*j1+1),dispfinal(5*j1+2),dispfinal(5*j1+3),dispfinal(5*j1+4),dispfinal(5*j1+5));
    else
        j1=j-1;
        if lr==1
            fprintf(fileID,formatSpec,dispfinal(5*j1+1));
        elseif lr==2
            fprintf(fileID,formatSpec,dispfinal(5*j1+1),dispfinal(5*j1+2));
        elseif lr==3
            fprintf(fileID,formatSpec,dispfinal(5*j1+1),dispfinal(5*j1+2),dispfinal(5*j1+3));
        elseif lr==4
            fprintf(fileID,formatSpec,dispfinal(5*j1+1),dispfinal(5*j1+2),dispfinal(5*j1+3),dispfinal(5*j1+4));
        end                        
    end
end
fclose(fileID);

