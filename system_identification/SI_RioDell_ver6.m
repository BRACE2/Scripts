close all;
clear all;
clc;

options.run_srim          = true;
options.plot_fft_tf       = true;
options.plot_time_history = true;
% System Identification of Rio Dell Bridge. It consists of three main parts.
% 1st part is based on the Transfer Function Estimate (TFE) and identifies the
% natural periods and damping ratios by Gunay & Mosalam (2021).
% 2nd part uses OKID-ERA-DC (Observer Kalman filter Identification -
%                            Eigen Realization with Direct Correlations) methodology
% to identify natural periods, damping ratios & mode shapes (Arici & Mosalam, 2006).
% 3rd part uses the System Realization by Information Matrix (SRIM) algorithm
% to identify natural periods, damping ratios & mode shapes (Arici & Mosalam, 2006).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 0: Reading/Setting information %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Constants
g = 980.7;                                         %acceleration of gravity in cm/sec^2
%% Inputs

inputname = input('Do you want to input folder name [Y/N]:', 's');
if isempty(inputname) || inputname == 'N' || inputname == 'n'
    inputname = 'N';
    FolderName = 'RioDell_Petrolia_Processed_Data';    %Name of folder with processed CSMIP data files for main EQ
else
    FolderName = input('Folder name is:', 's');
end

FolderName

Minperiod = 0.18;                                  %Min period range to specify peak amplitude
Maxperiod = 0.90;                                  %Max period range to specify peak amplitude

% In terms of input and output channels, five cases can be considered:

%Case 1: Input in transverse direction, output in transverse direction
%        Input channels: 3; Output channels: 7
%Case 2: Input in longitudinal direction, output in longitudinal direction
%        Input channels: 1; Output channel: 11
%Case 3: Input in longitudinal direction, output in vertical direction
%       Considering that the bridge is similar to a frame in the longitudinal direction,
%       shaking along this direction results in long. translational accelerations as well
%       as bending & rotation of the deck, causing vertical accelerations on deck nodes.
%       Case 3 makes use of this behavior to identify the long. mode. The influence vector
%       of long. ground motions on vertical accelerations is zero, which is a concern,
%       but this is still a useful case.
%       Input channels: 1; Output channels: 6
%Case 4: Input in longitudinal direction, output in longitudinal & vertical directions.
%        This is a case that can only be applied to OKID-ERA-DC. Therefore, it is the same
%        as Case 3 in TFE, and similar to Case 3 in OKID-ERA-DC, except that the output
%        channels is a combination of longitudinal & vertical channels.
%Input channels: 1; Output channels: 6
%Case 5: Input in vertical direction, output in vertical direction
%Input channels: 2; Output channel: 6

casenumber = input('Which case # (I/O): 1 (T/T), 2 (L/L), 3 (L/V), 4 (L/L+V), or 5 (V/V)? [1]:', 's');
if isempty(casenumber)
    casenumber = '1';
end
Case = strcat('Case',casenumber);

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 1: Transfer Function (TF) Estimate %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch Case
case 'Case1'
    OutChan = 7;           %Output channel #, generally, it is on bridge
    InpChan = 3;           %Input channel #, generally, it is at base

case 'Case2'
    OutChan = 11;          %Output channel #, generally, it is on bridge
    InpChan = 1;           %Input channel #, generally, it is at base

case 'Case3'
    OutChan = 6;           %Output channel #, generally, it is on bridge
    InpChan = 1;           %Input channel #, generally, it is at base

case 'Case4'
    OutChan = 6;           %Output channel #, generally, it is on bridge
    InpChan = 1;           %Input channel #, generally, it is at base

case 'Case5'
    OutChan = 6;           %Output channel #, generally, it is on bridge
    InpChan = 2;           %Input channel #, generally, it is at base
end

% Note: This is a Single Input, Single Output (SISO) TF method and uses one input
% channel and one output channel
%%
% File names of input and output channels
if InpChan<10
    inpfilename = strcat(FolderName,'/','CHAN00',num2str(InpChan),'.V2');
else
    inpfilename = strcat(FolderName,'/','CHAN0',num2str(InpChan),'.V2');
end

if OutChan<10
    outfilename = strcat(FolderName,'/','CHAN00',num2str(OutChan),'.V2');
else
    outfilename = strcat(FolderName,'/','CHAN0',num2str(OutChan),'.V2');
end

%%
for jj = 1:2
    % Read the input and output channel data using the corresponding filenames
    % jj = 1 corresponds to the input channel
    % jj = 2 corresponds to the output channel
    if jj == 1
        filename = inpfilename;
        Channel = InpChan;
    end
    if jj == 2
        filename = outfilename;
        Channel = OutChan;
    end
    % readv2 is a function that reads accelerometer data & time step from CSMIP format.
    % This format is same for historical data & real-time data for the Hayward Bridge.
    [acc dt] = readv2(filename);
    acc_amp = max(acc(:));
    if options.plot_time_history
    % plot the accelerations in input & output channels
        figure;
        ts = 0:dt:(length(acc)-1)*dt;
        plot(ts,acc/g);
        hold on;
        xlabel('Time [Sec]');
        ylabel('A [g]');
        xlim ([0.0 (length(acc)-1)*dt]);
        str = {'Time history of',strcat('Channel  = ',num2str(Channel))};
        text(0.5,acc_amp/g*.75,str)
    end
    % compute the response spectrum [requires specifying damping ratio] & Fourier Amplitude (FA)
    % spectrum. A very small damping ratio is used such that the response spectrum & TF
    % are not affected by the damping ratio.
    dmp = 0.001;
    per = 0.02:0.01:1;
    % respspec is the function that computes response spectrum
    % MyFFT is the function that computes the FA spectrum
    SA = respspec(dt,dmp,per,acc');
    [ff1,FFA] = MyFFT(dt,acc,1);
    if jj == 1
        SA1 = SA;
        FFA1 = FFA;
        % Plot the response spectrum of the input channel
        figure;
        plot(per,SA1/g);
        hold on;
        xlabel('Period [Sec]');
        ylabel('Sa [g]');
        str = {'Response spectrum of the input channel',strcat('Channel  = ',num2str(InpChan)),strcat('Damping ratio (%)  = ',num2str(dmp*100))};
        text(0.4,max(SA1)/g*0.85,str)

    elseif jj == 2
        SA2 = SA;
        FFA2 = FFA;
        % Plot the response spectrum of the output channel
        figure;
        plot(per,SA2/g);
        hold on;
        xlabel('Period [Sec]');
        ylabel('Sa [g]');
        str = {'Response spectrum of the output channel',strcat('Channel  = ',num2str(OutChan)),strcat('Damping ratio (%)  = ',num2str(dmp*100))};
        text(0.4,max(SA2)/g*0.85,str)

        % Compute and plot the transfer function
        figure;
        TT = SA2./SA1;
        plot(per,TT);
        hold on;
        xlabel('Period [Sec]');
        ylabel('Transfer function = SA(response) / SA(input)');
    end
    clearvars acc;

end

%% Compute the period and damping ratio based on the absolute peak

% compute the period as the value that corresponds to the peak of the spectrum
Ampap = max(TT);
ind1 = find(TT == Ampap);
Period = per(ind1);

% compute the damping ratio using the Half-power bandwidth method
Amp1 = Ampap/sqrt(2);

cond = 1;
i = ind1;
while cond == 1
    i = i-1;
    if TT(i) < Amp1
        slope = (TT(i+1)-TT(i))/(per(i+1)-per(i));
        % T1 is the period to the left of Tn
        T1 = (Amp1-TT(i))/slope+per(i);
        cond = 2;
    end
end

cond = 1;
i = ind1;
while cond == 1
    i = i+1;
    if TT(i) < Amp1
        slope = (TT(i)-TT(i-1))/(per(i)-per(i-1));
        % T2 is the period to the right of Tn
        T2 = (Amp1-TT(i-1))/slope+per(i-1);
        cond = 2;
    end
end

f1 = 1/T1;
f2 = 1/T2;
fn = 1/Period;

dmpratio = (f1-f2)/(2*fn)*100;

plot(Period,Ampap,'o');
hold off;

%% Compute the period and damping ratio according to the user specified period range

% In some cases, the peak spectral amplitude may not be at the dominant period.
% This option allows the user to input a range which covers the expected dominant period,
% such that the identified period and damping ratio are correct.

% If the peak amplitude is at the dominant period, there is no need for this option,
% and the range can be chosen as wide as the entire range.

% Compute the period as the value that corresponds to the peak of the spectrum
indmin = find(per == Minperiod);
indmax = find(per == Maxperiod);
Amp    = max(TT(indmin:indmax));
ind1   = find(TT == Amp);
Period2 = per(ind1);

% compute the damping ratio using the Half-power bandwidth method
Amp1 = Amp/sqrt(2);

cond = 1;
i = ind1;
while cond == 1
    i = i-1;
    if TT(i) < Amp1
        slope = (TT(i+1)-TT(i))/(per(i+1)-per(i));
        % T1 is the period to the left of Tn
        T1 = (Amp1-TT(i))/slope+per(i);
        cond = 2;
    end
end

cond = 1;
i = ind1;
while cond == 1
    i = i+1;
    if TT(i)<Amp1
        slope = (TT(i)-TT(i-1))/(per(i)-per(i-1));
        % T2 is the period to the right of Tn
        T2 = (Amp1-TT(i-1))/slope+per(i-1);
        cond = 2;
    end
end

f1 = 1/T1;
f2 = 1/T2;
fn = 1/Period2;

dmpratio2 = (f1-f2)/(2*fn)*100;

% Add text to the transfer function figure listing the identified period & damping ratio
str = {strcat('Output Channel #  = ',num2str(OutChan)),strcat('Input Channel #  = ',num2str(InpChan))};
text(0.5,Ampap*0.95,str)

str = {'Based on Absolute Peak',strcat('Period (sec)  = ',num2str(Period)),strcat('Damping ratio (%)  = ',num2str(dmpratio))};
text(0.5,Ampap*0.75,str)

str = {'Based on User Specified Range',strcat('Period (sec)  = ',num2str(Period2)),strcat('Damping ratio (%)  = ',num2str(dmpratio2))};
text(0.5, Ampap*0.55,str)
if options.plot_fft_tf
    % Plot the transfer function based on FFT
    figure;
    Tf = 1./ff1;
    TF = FFA2./FFA1;
    plot(Tf,TF);
    hold on;
    xlabel('Period [sec]');
    ylabel('Transfer function = FFA(response) / FFA(input)');
    xlim ([Minperiod 1]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% End of PART 1: Transfer Function Estimate                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc

tic
switch Case
case 'Case1'
    anac = [17 3 20 9 7 4]; %Channel #s, 1st 3 are input channels & 2nd 3 are output channels
    inpchns = 1:3;          %Specify the indices of input channels
    outchns = 4:6;          %Specify the indices of output channels

case 'Case2'
    anac = [1 11];
    inpchns = 1;            %Specify the indices of input channels
    outchns = 2;            %Specify the indices of output channels

case 'Case3'
    anac = [1 10 8 6];
    inpchns = 1;            %Specify the indices of input channels
    outchns = 2:4;          %Specify the indices of output channels

case 'Case4'
    anac = [1 11 10 8 6];
    inpchns = 1;            %Specify the indices of input channels
    outchns = 2:5;          %Specify the indices of output channels

case 'Case5'
    anac = [2 10 8 6];
    inpchns = 1;            %Specify the indices of input channels
    outchns = 2:4;          %Specify the indices of output channels
end

clear dat
nc = length(anac);          % number of channels
for r = 1:nc
    if anac(r)<10
        fname = strcat(FolderName,'/','CHAN00',num2str(anac(r)),'.v2');
    else
        fname = strcat(FolderName,'/','CHAN0',num2str(anac(r)),'.v2');
    end
    % read the acceleration and time step using the function readv2
    [a to] = readv2(fname);
    dat(:,r) = a;
end
d  = size(dat,1);           % total number of time steps
nc = size(dat,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 2: OKID-ERA-DC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
div  =    1;
% Pre-processing
[dati, dato, dn, dt] = PreOkid(dat, to, div, inpchns, outchns);

% set options for OKID-ERA-DC
config_okid.dn   =   dn;
config_okid.mro  =   10;
config_okid.orm  =    4;
config_okid.kmax =  500;
tic
[freqdmp, modeshape, RMSEpred] = OKID_ERA_DC(dati, dato, dt, config_okid);
toc
sprintf('Prediction Error Average for OKID-ERA-DC %0.4g',RMSEpred)
% Plot the mode shape together with frequency & damping ratio 
% information
modeplot(modeshape, freqdmp,Case);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 3: System Realization by Information Matrix (SRIM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if options.run_srim
    config_srim.p   =  5;
    config_srim.to  = to;
    config_srim.dn  = dn;
    config_srim.orm =  4;  % same as OKID_ERA_DC
    tic
    [freqdmpSRIM, modeshapeSRIM, RMSEpredSRIM] = SRIM(dati, dato, config_srim);
    toc

    % Plot the mode shape together with frequency & damping ratio information
    modeplot(modeshapeSRIM, freqdmpSRIM, Case);
    
    sprintf('Prediction Error Average for SRIM %0.4g',RMSEpredSRIM)
end

