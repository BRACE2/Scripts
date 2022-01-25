close all;
clear all;
clc;

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
g = 981;                                           %acceleration of gravity in cm/sec^2
%% Inputs

inputname = ''; %input('Do you want to input folder name [Y/N]:', 's');
if isempty(inputname) || inputname == 'N' || inputname == 'n'
    inputname  =  'N';
    FolderName = 'RioDell_Petrolia_Processed_Data';    %Name of folder with processed CSMIP data files for main EQ
   %FolderName = 'RioDell_Petrolia_AS'  %Name of folder with processed CSMIP data files for aftershock
else
    FolderName = input('Folder name is:', 's');
end

FolderName

Minperiod = 0.18;                                  %Min period range to specify peak amplitude
Maxperiod = 0.90;                                  %Max period range to specify peak amplitude



% In terms of input and output channels, five cases can be considered:

%Case 1: Input in transverse direction, output in transverse direction
         %Input channels: 3; Output channels: 7  
%Case 2: Input in longitudinal direction, output in longitudinal direction
         %Input channels: 1; Output channel: 11
%Case 3: Input in longitudinal direction, output in vertical direction
         %Considering that the bridge is similar to a frame in the longitudinal direction, 
         %shaking along this direction results in long. translational accelerations as well
         %as bending & rotation of the deck, causing vertical accelerations on deck nodes.
         %Case 3 makes use of this behavior to identify the long. mode. The influence vector
         %of long. ground motions on vertical accelerations is zero, which is a concern,
         %but this is still a useful case. 
         %Input channels: 1; Output channels: 6
%Case 4: Input in longitudinal direction, output in longitudinal & vertical directions.
%        This is a case that can only be applied to OKID-ERA-DC. Therefore, it is the same
%        as Case 3 in TFE, and similar to Case 3 in OKID-ERA-DC, except that the output
%        channels is a combination of longitudinal & vertical channels.
         %Input channels: 1; Output channels: 6
%Case 5: Input in vertical direction, output in vertical direction
         %Input channels: 2; Output channel: 6

casenumber = '';% input('Which case # (I/O): 1 (T/T), 2 (L/L), 3 (L/V), 4 (L/L+V), or 5 (V/V)? [1]:', 's');
if isempty(casenumber)
    casenumber  =  '1';
end
Case = strcat('Case',casenumber);

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 1: Transfer Function (TF) Estimate %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Case == 'Case1'
    OutChan = 7;                               %Output channel #, generally, it is on bridge
    InpChan = 3;                               %Input channel #, generally, it is at base
end
         
if Case == 'Case2'
    OutChan = 11;                              %Output channel #, generally, it is on bridge
    InpChan = 1;                               %Input channel #, generally, it is at base
end
         
if Case == 'Case3'
    OutChan = 6;                               %Output channel #, generally, it is on bridge
    InpChan = 1;                               %Input channel #, generally, it is at base
end

if Case == 'Case4'
    OutChan = 6;                               %Output channel #, generally, it is on bridge
    InpChan = 1;                               %Input channel #, generally, it is at base
end

if Case == 'Case5'
    OutChan = 6;                               %Output channel #, generally, it is on bridge
    InpChan = 2;                               %Input channel #, generally, it is at base
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

% plot the accelerations in input & output channels
figure;
ts = 0:dt:(length(acc)-1)*dt;
plot(ts,acc/g);
hold on;
xlabel('Time [Sec]');
ylabel('A [g]');
xlim ([0.0 (length(acc)-1)*dt]);
str  =  {'Time history of',strcat('Channel  = ',num2str(Channel))};
text(0.5,acc_amp/g*.75,str)
 
% compute the response spectrum [requires specifying damping ratio] & Fourier Amplitude (FA) 
% spectrum. A very small damping ratio is used such that the response spectrum & TF
% are not affected by the damping ratio.
dmp = 0.001;
per = 0.02:0.01:1;
% respspec is the function that computes response spectrum
% MyFFT is the function that computes the FA spectrum
SA  =  respspec(dt,dmp,per,acc');
[ff1,FFA]  =  MyFFT(dt,acc,1);
if jj == 1
    SA1 = SA;
    FFA1 = FFA;
    % Plot the response spectrum of the input channel
    figure;
    plot(per,SA1/g);
    hold on;
    xlabel('Period [Sec]');
    ylabel('Sa [g]');
    str  =  {'Response spectrum of the input channel',strcat('Channel  = ',num2str(InpChan)),strcat('Damping ratio (%)  = ',num2str(dmp*100))};
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
    str  =  {'Response spectrum of the output channel',strcat('Channel  = ',num2str(OutChan)),strcat('Damping ratio (%)  = ',num2str(dmp*100))};
    text(0.4,max(SA2)/g*0.85,str)
    
    % Compute and plot the transfer function
    figure;
    TT = SA2./SA1;
    plot(per,TT);
    hold on;
    xlabel('Period [Sec]');
    ylabel('Transfer function  =  SA(response) / SA(input)');

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
    if TT(i)<Amp1
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
Amp = max(TT(indmin:indmax));
ind1 = find(TT == Amp);
Period2 = per(ind1);

% compute the damping ratio using the Half-power bandwidth method 
Amp1 = Amp/sqrt(2);

cond = 1;
i = ind1;
while cond == 1
    i = i-1;
    if TT(i)<Amp1
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
str  =  {strcat('Output Channel #  = ',num2str(OutChan)),strcat('Input Channel #  = ',num2str(InpChan))};
text(0.5,Ampap*0.95,str)

str  =  {'Based on Absolute Peak',strcat('Period (sec)  = ',num2str(Period)),strcat('Damping ratio (%)  = ',num2str(dmpratio))};
text(0.5,Ampap*0.75,str)

str  =  {'Based on User Specified Range',strcat('Period (sec)  = ',num2str(Period2)),strcat('Damping ratio (%)  = ',num2str(dmpratio2))};
text(0.5,Ampap*0.55,str)

% Plot the transfer function based on FFT
figure;
Tf = 1./ff1;
TF = FFA2./FFA1;
plot(Tf,TF);
hold on;
xlabel('Period [sec]');
ylabel('Transfer function  =  FFA(response) / FFA(input)');
xlim ([Minperiod 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% End of PART 1: Transfer Function Estimate %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 2: OKID-ERA-DC (Observer Kalman filter Identification -
                        %Eigen Realization with Direct Correlations)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Description of the Methodology: 
% More information on OKID-ERA-DC method can be found in 
% Section 3.4.6 of (Arici & Mosalam, 2006). Equations below refer to this report. 
% OKID-ERA-DC is a Multiple Input - Multiple Output (MIMO) System Identification (SI) method
% that consists of the following steps:
% 1. Data pre-processing (baseline correction, filtering & decimation)
% 2. Identify observer Kalman filters using Observer Kalman filter Identification (OKID)
%    methodology. This step basically consists of developing a simple observer model of
%    a system from a MIMO ARX structure, Eq. (3.76), which is broken into these 6 steps:
% 2a. Determine Markov parameters (M) in a least squares sense, Eq. (3.76).
% 2b. Establish the Hankel matrix (H) from the Markov parameters, (Eq. 3.80).
% 2c. Use H to compute system matrices A, B & C, in which modal information is embedded.
% 2d. Obtain the modal information from matrices A, B & C.
% 2e. Spatial & temporal validation of the identified modes.
% 2f. Back calculate (estimate) the output accelerations with the state-space system &
%     check against the actual output accelerations.
%%%

%% Inputs

% In terms of input and output channels, five cases can be considered as
% described below.

% Note that the input and output channels are common to OKID-ERA-DC and
% SRIM.

%Case 1: Input in transverse direction, output in transverse direction
         %Input channels: 17, 3, 20; Output channels: 9, 7, 4  
%Case 2: Input in longitudinal direction, output in longitudinal direction
         %Input channels: 1; Output channel: 11
%Case 3: Input in longitudinal direction, output in vertical direction
         %Considering that the bridge is similar to a frame in the longitudinal direction, 
         %shaking along this direction results in long. translational accelerations as well
         %as bending & rotation of the deck, causing vertical accelerations on deck nodes.
         %Case 3 makes use of this behavior to identify the long. mode. The influence vector
         %of long. ground motions on vertical accelerations is zero, which is a concern,
         %but this is still a useful case. 
         %Input channels: 1; Output channels: 10, 8, 6
%Case 4: Input in longitudinal direction, output in longitudinal & vertical directions.
         %This is a case that can only be applied to OKID-ERA-DC. Therefore, it is the same
         %as Case 3 in TFE, and similar to Case 3 in OKID-ERA-DC, except that the output
         %channels is a combination of longitudinal & vertical channels.
         %Input channels: 1; Output channels: 11, 10, 8, 6
%Case 5: Input in vertical direction, output in vertical direction
         %Input channels: 2; Output channel: 10, 8, 6
         
if Case=='Case1'
    anac = [17 3 20 9 7 4]; %Channel #s, 1st 3 are input channels & 2nd 3 are output channels
    inpchns=1:3;          %Specify the indices of input channels
    outchns=4:6;          %Specify the indices of output channels
end

if Case=='Case2'
    anac = [1 11];
    inpchns=1;            %Specify the indices of input channels
    outchns=2;            %Specify the indices of output channels
end

if Case=='Case3'
    anac = [1 10 8 6];
    inpchns=1;            %Specify the indices of input channels
    outchns=2:4;          %Specify the indices of output channels
end

if Case=='Case4'
    anac = [1 11 10 8 6];
    inpchns=1;            %Specify the indices of input channels
    outchns=2:5;          %Specify the indices of output channels
end

if Case=='Case5'
    anac = [2 10 8 6];
    inpchns=1;            %Specify the indices of input channels
    outchns=2:4;          %Specify the indices of output channels
end

% Modelparameters
div=1;     %A parameter used for decimating data. 1 uses entire data without downsampling.
mro=10;    %Model reduction order
orm=4;     %Order of the model. # of computed and plotted modes depend on orm.
           %For orm=2, one mode is found, for orm=4, two modes are found.
           %For case 1, one mode is transverse and the other is torsion.
           %For all other cases, the second mode is a higher mode.
           %Sometimes higher orm still gives fewer modes, e.g. orm=8 for case 1 gives
           %three modes, but one of them is invalid according to the EMAC & MPC criteria.
kmax=100;  %Number of computed Markov parameters, indicated as 1000 on page 43 of
           %(Arici & Mosalam, 2006). However, it was input as 100 in the code.
           % kmax=100 runs much faster & both kmax=100 & 1000 give the same results.

% Important output variables:
%  1. freqdamp variable is a matrix that includes the information of identified
%     frequencies, damping ratios & validation of the modes with MPC & EMAC criteria
%     Each row of freqdamp corresponds to a mode. Columns are as follows:
%     1)frequency, 2)damping ratio, 3)order index, 4)condition number, 5)input EMAC, 
%     6)output EMAC, 7)MPC. If values in columns 5-7 are > 0.5, identified mode is valid.
%  2. modeshape stores the mode shape information for identified modes.
%  3. RMSEpred: root mean square error of the predicted output from
%     identified parameters with respect to the actual output. 
%  4. Markovparamerror: root mean square error used to validate accurate
%     computation of Markov parameters
%% Read the acceleration from all the input and output channels

nc = length(anac);                                 % number of channels

for r=1:nc
   if anac(r)<10
       fname = strcat(FolderName,'/','CHAN00',num2str(anac(r)),'.v2');
   else
       fname = strcat(FolderName,'/','CHAN0',num2str(anac(r)),'.v2');
   end
   % read the acceleration and time step using the function readv2
   [a to] = readv2(fname);
   dat(:,r)=a;
end

d = size(dat,1); % total number of time steps
dur = d*to;      % total duration

% Sampling Frequency and Nyquist Frequency
fo=1/to;
fn = fo/2;

%% 1. Data Pre-Processing 

% Data pre-processing consists of three actions:
% a) Baseline correction, b) Filtering, c) Decimating the data and downsampling

% Steps a and b are mostly needed when raw data is used from .V1 files and can be
% skipped when processed .V2 files are used. Here, both steps are currently commented out as
% already the processed data are used with .V2 files

% a) Baseline correction and removing the mean from the data using the function dtrend

%datnn = dtrend(dat);
datnn = dat;

% b) Filtering the data

%Below commands use a Type II Chebychev filter, but any other filter is also possible
% cutof=10;
%[b,a] = cheby2(9,30,1/div-0.001);
%datnn= filter(b,a,datnn);

% c) Decimating the data                
datn = datnn(1:div:d,:);    % decimating data by selecting every div-th point.
                          % Currebtly, div=1, so all data is used.
to = to*div;                % sampling time increases due to decimating the data.
dn = d/div;                 % total number of time steps after decimating = 
                          % total number of acceleration samples per channel 

dati = datn(:,inpchns);     % accelerations at input channels after pre-processing,
                          % dati is a matrix with size dn x inpchns.
                          % # of rows is dn & # of columns is inpchns.
dato = datn(:,outchns);     % accelerations at output channels after pre-processing,
                          % dato is a matrix with size dn x outchns.
                          % # of rows is dn & # of columns is outchns.

%% 2a. Obtain Observer Markov Parameters

% Note that main Step 2 develops Eq. 3.76. Therefore, it is not part of the code.
% Accordingly, the code continues with Step 2a to compute Observer Markov parameters in Eq. 3.76.
% The Markov parameters are computed in two steps:
% i) The Observer Markov matrices are computed from Eq. 3.76 using a linear regression approach
% ii) Compute the system Markov parameters from the Markov matrices using recursive relations

% defining several parameters
temsiz = size(dato);
temsizi = size(dati);
m = temsiz(2);       %# of columns of dato = number of output channels  
l = temsiz(1);       %# of rows of dato = # of rows of dati = # of acceleration samples per channel
r = temsizi(2);      %# of columns of dati = number of input channels

p = mro;             %assign input model reduction order to variable p, consistent with Eq. 3.76  

% Compute matrix U that represents ARX equation of current output on p time steps of past output
% & input values (Eq. 3.76)
U = zeros((m+r)*p+r,l);
U(1:r,:)=dati';
for b=2:p+1
   U((b-2)*(r+m)+1+r:(b-2)*(r+m)+r+r+m,b:l)=[dati(1:l-b+1,1:r)';dato(1:l-b+1,1:m)'];
end

% i) Compute the matrix of Observer Markov Parameter Matrix (M) in Eq 3.76 using Linear Regression
[uu,s,v] = svd(U,0);     %svd: Singular Value Decomposition function in Matlab
                       %s is a diagonal matrix with the singular values
wr = diag(s);            %singular values are extracted from the diagonal matrix using diag function
pg=(r+m)*p+r;
for lop=1:(r+m)*p+r
   if wr(lop)<=0.001
      pg = lop;
      break
   end
end
    
pss = v(:,1:pg)*s(1:pg,1:pg)^-1*uu(:,1:pg)';
M = dato'*pss;           %M: Observer Markov Parameter Matrix

% Fit for multiple regression
ypreo = M*U;

for i=1:m
   temsump = sum((dato(:,i)-ypreo(i,:)').^2);
   Jpre(i)=temsump/(sum(dato(:,i).^2));
end

Markovparamerror = sum(Jpre)/m;  % RMSE between actual output & y on left hand side in Eq. 3.76
                               % It should be quite small (e.g., 10^-3) for accurately computed Markow parameters
sprintf('Simulation Error Average for OKID-ERA-DC %0.4g',Markovparamerror)

% ii) Compute Markov parameters (Y) using recursive relations in Eqs. 3.78 & 3.79

% Matrix D is directly equal to the Observer Markov parameter matrix (Eq. 3.77)
D = M(:,1:r);  % D: Direct Transmission term, one of 4 system matrices of state space model
             % Eqs. 3.31-3.34 define the four system matrices, A, B, C & D
Y{1}=D;
% First p steps (Eq. 3.78)
for ol=1:p
   sumt = zeros(m,r);
   for lok=1:ol
      sumt = M(:,r+(lok-1)*(r+m)+1+r:r+(lok-1)*(r+m)+r+m)*Y{ol-lok+1}+sumt;
   end
   Y{ol+1}=M(:,r+(ol-1)*(r+m)+1:r+(ol-1)*(r+m)+r)+sumt;
end

% From p+1 to rest (Eq. 3.79)
for ol = p+1:dn+kmax
   sumt = zeros(m,r);
   for lok=1:p
      sumt = sumt+M(:,r+(lok-1)*(r+m)+1+r:r+(lok-1)*(r+m)+r+m)*Y{ol-lok+1};
   end
   Y{ol+1}=+sumt;
end
% Now, the Markow parameters Y have been computed. 

%% 2b. Establish Hankel matrix (H) from the Markov parameters (Y) (Eq. 3.80) 

% psz=1000;   psz is replaced by kmax and used as an imput parameter
% Obtain Hankel Matrix of Zeroth Order & First Order
for hj=1:kmax
    for jh=1:l
        H0((hj-1)*m+1:hj*m,(jh-1)*r+1:jh*r)=Y{jh+hj};
        H1((hj-1)*m+1:hj*m,(jh-1)*r+1:jh*r)=Y{jh+hj+1};
    end
end

%% 2c. Use H matrix to compute system matrices A, B & C wheer modal information is embedded.

[R1,Sis,S1] = svd(H0); %singular value decomposition

n = orm;               %assign order of model input to variable n, consistent with Eqs. 3.81-3.84  

A = Sis(1:n,1:n)^(-0.5)*R1(:,1:n)'*H1*S1(:,1:n)*Sis(1:n,1:n)^(-0.5); %A: state transition matrix (Eqs. 3.32 & 3.82)
Qb = Sis(1:n,1:n)^0.5*S1(:,1:n)';   
B = Qb(:,1:r);                                                       %B: input influence matrix (Eqs. 3.32 & 3.83)
Pb = R1(:,1:n)*Sis(1:n,1:n)^0.5;    
C = Pb(1:m,:);                                                       %C: output influence matrix (Eqs. 3.34 & 3.84)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2d. Obtain the modal information from the system matrices A, B & C
   % This includes determination of: a) modal frequencies, b) damping ratios & c) mode shapes 

[v d] = eig(A);        %eigenvectors (d) & eiegenvalues (v) of the matrix A 
cnd = condeig(A);      %condeig(A): gives a vector of condition numbers for the eigenvalues of A
kit = log(diag(d));    %logarithm of the eigenvalues

% a) Determination of modal frequencies (Eqs. 3.46 & 3.39)
sj1=kit./to;              %to is the time step
freq1=((sj1.*conj(sj1)).^0.5)/(2*pi);

% selection of proper roots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if freq1(1,1)==freq1(2,1)
   freq1(1,2)=1;
end

if freq1(n,1)==freq1(n-1,1)
   freq1(n,2)=1;
end

for hw=2:n-1
   if freq1(hw,1)==freq1(hw+1,1) | freq1(hw,1)==freq1(hw-1,1);
      freq1(hw,2)=1;
   end
end

% b) Determination of damping ratios (Eqs. 3.46 & 3.39) 

damp1=-(real(sj1))./(2*pi*freq1);

% Represent the identified frequency & damping information of the proper roots in a matrix
koun=1;
for lk=1:2:n                        % from 1 to the model order, n
   if freq1(lk,2)==1                % 1 indicates that it is a proper root
       freqdmp(koun,1)=freq1(lk);   % first column: identified frequency 
       freqdmp(koun,2)=damp1(lk);   % second column: identified damping ratio
       freqdmp(koun,3)=lk;          % third column: model order index (1:n)
       freqdmp(koun,4)=cnd(lk);     % condition number of the eigenvalue
       koun = koun+1;
   end
end

% c) Determination of mode shapes
mod = C*v;                  %mode shapes (Eq. 3.40), v is the eigenvectors of matrix A
inm = v^-1*B;               %initial modal contribution
   
kss = size(freqdmp,1);

%extract mode shapes from mod corresponding to a frequency
for q=1:kss
   modeshape(1:m,q)=mod(1:m,freqdmp(q,3)); 
end

for q=1:kss
   [mit om] = max(abs(real(modeshape(:,q))));
   modeshape(:,q)=real(modeshape(:,q))*1/mit*sign(real(modeshape(om,q)));
end

% Plot the mode shape together with frequency & damping ratio information
modeplot(modeshape,freqdmp,Case);


%% 2e. Validation Analysis

% Two criteria are used for selection of identified genuine modes, in terms of spatial & temporal consistency. 
% a) Modal Phase Collinearity (MPC) testing spatial consistency of identification results.
%    Modes having MPC value above 0.5 (mpc parameter below) are considered as genuine modal quantities.
% b) Extended Modal Amplitude Coherence (EMAC), evaluates temporal consistency of the identification results.
%    Both output EMAC & input EMAC can be computed. Input EMAC requires the controllability matrix.
%    Because the controllability matrix is not estimated by all considered SI methods,
%    this criterion is computed, but not used.
%    Modes with output EMAC values < 0.5 are considered spurious & therefore not reported.

% a) Modal Phase Collinearity (MPC) [Eqs. 3.85-3.87]
for q=1:n
   sxx(:,q)=real(mod(:,q))'*real(mod(:,q));
   syy(:,q)=imag(mod(:,q))'*imag(mod(:,q));
   sxy(:,q)=real(mod(:,q))'*imag(mod(:,q));
   nu(q)=(syy(:,q)-sxx(:,q))/(2*sxy(:,q));
   lam(1,q)=(sxx(:,q)+syy(:,q))/2+sxy(:,q)*(nu(q)^2+1)^0.5;
   lam(2,q)=(sxx(:,q)+syy(:,q))/2-sxy(:,q)*(nu(q)^2+1)^0.5;
   mpc(q)=((lam(1,q)-lam(2,q))/(lam(1,q)+lam(2,q)))^2;
end

% b) Extended Modal Amplitude Coherence (EMAC)

qlin = v^-1*Qb;  % Controllability Matrix used for the input-EMAC
plin = Pb*v;     % Observability Matrix used for the output-EMAC

lamb = v^-1*A*v;
bkh = v^-1*B;
for hn=1:n
   for ll=0:l-1
      qhat(hn,ll*r+1:ll*r+r)=bkh(hn,:)*(lamb(hn,hn))^ll;
   end
end
selsiz = min(size(qlin),size(qhat));

for hnd=1:n
   ql = qlin(hnd,1:selsiz(2));qh = qhat(hnd,1:selsiz(2));
   mac(hnd)=abs(ql*qh')/(abs(ql*ql')*abs(qh*qh'))^0.5;
end

% Output EMAC (Eqs. 3.88-3.89)
% Pick the last block row
pto = plin((kmax-1)*m+1:m*kmax,:); % the identified value at T0
for ds=1:n
   ptop(:,ds)=mod(:,ds)*exp(sj1(ds)*to*(kmax-1));
end

% Computation of rij
for qa=1:n
    for qz=1:m
        Rij(qa,qz)=min((abs(pto(qz,qa))/abs(ptop(qz,qa))),(abs(ptop(qz,qa))/abs(pto(qz,qa))));
        Pij = angle(pto(qz,qa)/ptop(qz,qa));
        Pijn(qa,qz)=Pij;
        if abs(Pij)<=pi/4
            Wij(qa,qz)=1-abs(Pij)/(pi/4);
        else
            Wij(qa,qz)=0;
        end
        emaco(qa,qz)=Rij(qa,qz)*Wij(qa,qz);      % emaco is the ouput emac
    end
end

% Input EMAC
% Pick the last block column
qto = qlin(:,(l-1)*r+1:l*r);
qtop = d^((l-1))*inm;

% EMAC Input Variation
for er=1:l
    qtovar = qlin(:,(er-1)*r+1:er*r);
    qtopvar = d^(er-1)*inm;
		% Computation of rik
        for qak=1:n
            for qzk=1:r
                Rik(qak,qzk)=min((abs(qtovar(qak,qzk))/abs(qtopvar(qak,qzk))),(abs(qtopvar(qak,qzk))/abs(qtovar(qak,qzk))));
                Pik = angle(qtovar(qak,qzk)/qtopvar(qak,qzk));
                if abs(Pik)<=pi/4
                    Wik(qak,qzk)=1-abs(Pik)/(pi/4);
                else
                    Wik(qak,qzk)=0;
                end
                emaci(qak,qzk)=Rik(qak,qzk)*Wik(qak,qzk);
            end
        end
      %Weight for emaci     
      emacif = zeros(n,1);
      for xc=1:n
         sumi=0;
         for lw=1:r
             sumi = emaci(xc,lw)*(inm(xc,lw)*inm(xc,lw)')+sumi;
         end
      	emacif(xc)=sumi/(inm(xc,:)*inm(xc,:)');
      end
   	emacivar(:,er)=emacif;
end

% Computation of rik
for qak=1:n
   for qzk=1:r
      Rik(qak,qzk)=min((abs(qto(qak,qzk))/abs(qtop(qak,qzk))),(abs(qtop(qak,qzk))/abs(qto(qak,qzk))));
      Pik = angle(qto(qak,qzk)/qtop(qak,qzk));
      if abs(Pik)<=pi/4
      	Wik(qak,qzk)=1-abs(Pik)/(pi/4);
   	else
         Wik(qak,qzk)=0;
      end
        emaci(qak,qzk)=Rik(qak,qzk)*Wik(qak,qzk);
   end
end

% Computation of final Input and Ouput EMAC
for xc=1:n
   % Weight for emaco
   sumo=0;
   for la=1:m  
      sumo = emaco(xc,la)*abs(mod(la,xc))^2+sumo;   
   end
   %Weight for emaci     
   sumi=0;
   for lw=1:r
      sumi = emaci(xc,lw)*abs(inm(xc,lw))^2+sumi;
   end
   emacof(xc)=sumo/((mod(:,xc)'*mod(:,xc)));           %emacof is the final output EMAC          
   emacif(xc)=sumi/(inm(xc,:)*inm(xc,:)');             %emacif is the final input EMAC
   emac(xc)=emacof(xc)*emacif(xc);
end
  
% Add the input EMAC, output EMAC, and MPC to the matrix freqdamp
for lih=1:kss(1)
  freqdmp(lih,5)=emacif(freqdmp(lih,3));
  freqdmp(lih,6)=emacof(freqdmp(lih,3));
  freqdmp(lih,7)=mpc(freqdmp(lih,3));
  if freqdmp(lih,6)>0.5 && freqdmp(lih,7)>0.5
      validationm=' valid';
  else
      validationm=' not valid';
  end
  sprintf(scroutput)  
end

%% 2f. Back calculate (estimate) output accelerations with state-space system &
%%     check against actual output accelerations

% Prediction using state space model
ms1=modstruc(A,B,C,D,zeros(n,m));
th1=ms2th(ms1,'d');

[e,r] = resid([dato dati],th1);
[simy] = idsim([dati],th1);                % simy represents the estimated accelerations

for i=1:m
   temsum = sum((dato(:,i)-simy(:,i)).^2);
   Jm(i)=temsum/(sum(dato(:,i).^2));     %Root mean square error of estimated accelerations
end
RMSEpred = sum(Jm)/m;
sprintf('Prediction Error Average for OKID-ERA-DC %0.4g',RMSEpred)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END of PART 2: OKID-ERA-DC (Observer Kalman filter Identification -
%                              Eigen Realization with Direct Correlations)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PART 3: System Realization by Information Matrix (SRIM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Description of the Methodology: 
% More information on SRIM algorithm can be found in Sections 3.4.4 & 3.4.5 of (Arici & Mosalam, 2006).
% Equations below refer to this report. SRIM is a MIMO SI method that is based on state space identification
% using least squares and consists of the following steps:
% 1. Data pre-processing (baseline correction, filtering & decimation). Same as in OKID-ERA-DC.
% 2. Represent the ouput vector in terms of input and state vectors, Eq. (3.57), which is broken into these 6 steps:
% 2a. Determine output (y) & input (u) vectors [Eqs. 3.58 & 3.60].
% 2b. Compute the correlation terms & the coefficient matrix (Eqs. 3.68 & 3.69).
% 2c. Obtain observability matrix using full or partial decomposition (Eqs. 3.72 & 3.74).
% 2d. Use the observability matrix to compute system matrices A, B & C, in which modal information is embedded.
% 2e. Obtain the modal information from matrices A, B & C.
% 2f. Spatial & temporal validation of the identified modes.
% 2g. Back calculate (estimate) the output accelerations with the state-space system &
%     check against the actual output accelerations.
% Notes: Computation of B & D matrices take very long time (not possible to get a result until now)
% becuase of the excessive matrix operations in lines 944-950. Matrices B & D are not needed for computation of
% periods, damping ratios, or mode shapes. However, they are needed for part of step 2f and the entire step 2g.
% Therefore, these steps are not pursued. Relevant compuations are left commented out for now in case we find
% efficient ways of computing these later.
%%KKKKK
% Lines between these can be commented. But for now they are uncommented for testing
%%KKKKK
%%%
         
% Note that the input and output channels are common to OKID-ERA-DC and SRIM.
% They are already input as the OKID-ERA-DC inputs.

% Modelparameters
p = 5;         %# steps used for the identification. Referred to as the prediction horizon in literature
n1 = orm;      %Order of the model. # of computed and plotted modes depend on orm.
             %For orm = 2, one mode is found, for orm = 4, two modes are found.
             %For case 1, one mode is transverse & the other is torsion.
             %For all other cases, the second mode is a higher mode.
             %Sometimes higher orm still gives fewer modes, e.g. orm = 8 for case 1 gives
             %three modes, but one of them is invalid according to the EMAC & MPC criteria.
             %same orm in OKID-ERA-DC is used. It can be changed if needed.

% Important output variables:
%  1. freqdampSRIM variable is a matrix that includes the information of identified
%     frequencies, damping ratios & validation of the modes with MPC & EMAC criteria.
%     Each row of freqdamp corresponds to a mode. Columns are as follows:
%     1)frequency, 2)damping ratio, 3)order index, 4)condition number, 5)MPC. 
%     If values in columns 5 is > 0.5, identified mode is valid.
%  2. modeshapeSRIM stores the mode shape information for identified modes.
%  3. RMSEpredSRIM: root mean square error of the predicted output from
%     identified parameters with respect to the actual output (currently
%     commented out).
%
%% Read the acceleration from all the input and output channels
% This is already done in OKID-ERA-DC. Therefore, not repeated.

%% 1. Data Pre-Processing 

% Data pre-processing consists of three actions:
% a) Baseline correction, b) Filtering, c) Decimating the data & downsampling
% This is already done in OKID-ERA-DC. Therefore, not repeated. Same pre-processed data is used in SRIM.

%%
%% 2a. Compute y (output) and u (input) vectors (Eqs. 3.58 & 3.60)

% Note that main Step 2 develops Eq. 3.57. Therefore, it is not part of the code.
% Accordingly, the code continues with Step 2a to compute the output & input vectors.

% Calculate the usable size of the data matrix
dn = size(dat,1)/div;       % total # time steps after decimating 

nsizS = dn-1-p+2;                                   

temsiz = size(dato);
temsizi = size(dati);
m = temsiz(2);              %# of columns of dato  =  number of output channels  
l = temsiz(1);              %# of rows of dato  =  # of rows of dati  =  # of acceleration samples per channel
r = temsizi(2);             %# of columns of dati  =  number of input channels                        
ypS = zeros(r*p,nsizS);     %r is the number of input channels (computed with OKID-ERA-DC) 
                          %p is the number of steps used for the identification. It is an input parameter of SRIM
upS = zeros(r*p,nsizS);
                          
% Compute y (output) & u (input) vectors (Eqs. 3.58 & 3.60)                          
for b = 1:p
   ypS((b-1)*m+1:b*m,1:nsizS) = dato((b-1)+1:nsizS+(b-1),:)';
   upS((b-1)*r+1:b*r,1:nsizS) = dati((b-1)+1:nsizS+(b-1),:)';
end

%% 2b. Compute the correlation terms and the coefficient matrix (Eqs. 3.68 & 3.69).

% Compute the correlation terms (Eq. 3.68)
Ryy = ypS*ypS'/nsizS;
Ruu = upS*upS'/nsizS;
Ruy = upS*ypS'/nsizS;

%Compute the correlation matrix (Eq. 3.69)
Rhh = Ryy-Ruy'*(Ruu\Ruy);

%% 2c. Obtain observability matrix using full or partial decomposition (Eqs. 3.72 & 3.74).

% Obtain observability matrix using full or partial decomposition.
% Full decomposition is used for the rest of the computations.
% Partial decomposition equations are available. They are commented out.

% Full Decomposition Method
[un1,s1,uo1] = svd(Rhh,0);               % Eq. 3.74
Op1 = un1(:,1:n1);                       % Eq. 3.72

% Partial Decomposition Method
%%KKKKK
[un2,s2,uo2] = svd(Rhh(:,1:(p-1)*m),0);
Op2 = un2(:,1:n1);
%%KKKKK

%% 2d. Use the observability matrix to compute system matrices A, B & C, in which modal information is embedded.

% Determine the system matrices A & C (1 & 2 indicate the ones corresponding
% to full & partial decomposition, respectively. 2 is commented out) 
A1 = lsqminnorm(Op1(1:(p-1)*m,:), Op1(m+1:p*m,:));
%%KKKKK
%A2 = lsqminnorm(Op2(1:(p-1)*m,:), Op2(m+1:p*m,:));
%%KKKKK
C1 = Op1(1:m,:);
%%KKKKK
%C2 = Op2(1:m,:);
%%KKKKK

%% Note: A2 & C2 not used herein 

% Computation of system matrices B & D
% Note that these computations are commented out as it is not possible to compute B & D
% because of excessive computation time 

% Output Error Minimization
% Setting up the fi matrix
%%KKKKK
fi = zeros(m*nsizS, n1+m*r+n1*r);
A_p = A1;
CA_powers = zeros(m, size(A1,2), 1+nsizS);
CA_powers(:,:,1) = C1*A_p;
for pwr = 1:nsizS
  A_p = A1*A_p;
  CA_powers(:,:,pwr+1) =  C1*A_p;
end

%
% First block column of fi
fi(1:m,1:n1) = C1;
for df = 2:nsizS
    fi((df-1)*m+1:df*m,1:n1) = CA_powers(:,:,df-1);
end
%
% Second block column of fi
Imm = speye(m,m);
for df = 1:nsizS
    fi((df-1)*m+1:df*m,n1+1:n1+m*r) = kron(dati(df,:),Imm);
end
% 
% Third block column of fi
In1n1 = speye(n1,n1);
c = n1+m*r+1;
d = n1+m*r+n1*r;
fi3 = zeros(m, d-c+1, nsizS-1);

parfor df = 2:nsizS
    a = (df-1)*m+1;
    b = df*m;
    fi3(:,:,df) = block_3(df, m, CA_powers, dati, n1, r, C1);
    %for nmf = 1:df-1
    %    %fi(a:b,c:d) = fi(a:b,c:d) + CA_powers(:,:,df-nmf)*kron(dati(nmf,:),In1n1);
    %    fi((df-1)*m+1:df*m, n1+m*r+1 : n1+m*r+n1*r) = fi((df-1)*m+1:df*m, n1+m*r+1 : n1+m*r+n1*r) + CA_powers(:,:,df-nmf)*kron(dati(nmf,:),In1n1);
    %end
    %fi(a:b,c:d) = cumsum(CA_powers(:,:,df-nmf)*kron(dati(:,:), In1n1))
end
for df = 2:nsizS
    a = (df-1)*m+1;
    b = df*m;
    fi(a:b,c:d) = fi3(:, :, df);
end

% 
dattemp = dato(1:nsizS,:)';
y = dattemp(:);
% 

% teta = pinv(fi)*y;
teta = lsqminnorm(fi,y);

x0 = teta(1:n1);
dcol = teta(n1+1:n1+m*r);
bcol = teta(n1+m*r+1:n1+m*r+n1*r);
% 
n = n1;
D = zeros(m,r);B = zeros(n,r);
% Obtain D
for wq = 1:r
    D(:,wq) = dcol((wq-1)*m+1:wq*m);
end
% 
for ww = 1:r
    B(:,ww) = bcol((ww-1)*n+1:ww*n);
end
%%KKKKK

%% 2e. Obtain the modal information from the system matrices A & C
% This includes determination of: a) modal frequencies, b) damping ratios & c) mode shapes 

[vS dS] = eig(A1);       %eigenvectors (d) & eiegenvalues (v) of matrix A 
cndS = condeig(A1);      %condeig(A): gives a vector of condition numbers for the eigenvalues of A
kitS = log(diag(dS));    %logarithm of the eigenvalues

% a) Determination of modal frequencies (Eqs. 3.46 & 3.39)
sj1S = kitS./to;         %to is the time step
freq1S = ((sj1S.*conj(sj1S)).^0.5)/(2*pi);

% selection of proper roots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if freq1S(1,1) == freq1S(2,1)
   freq1S(1,2) = 1;
end

if freq1S(n,1) == freq1S(n-1,1)
   freq1S(n,2) = 1;
end

for hw = 2:n-1
   if freq1S(hw,1) == freq1S(hw+1,1) || freq1S(hw,1) == freq1S(hw-1,1)
      freq1S(hw,2) = 1;
   end
end

% b) Determination of damping ratios (Eqs. 3.46 & 3.39) 
damp1S = -(real(sj1S))./(2*pi*freq1S);

% Represent the identified frequency & damping information of the proper roots in a matrix
koun = 1;
for lk = 1:2:n                             % from 1 to the model order, n
   if freq1S(lk,2) == 1                    % 1 indicates that it is a proper root
       freqdmpSRIM(koun,1) = freq1S(lk);   % first column: identified frequency 
       freqdmpSRIM(koun,2) = damp1S(lk);   % second column: identified damping ratio
       freqdmpSRIM(koun,3) = lk;           % third column: model order index (1:n)
       freqdmpSRIM(koun,4) = cndS(lk);     % condition number of the eigenvalue
       koun = koun+1;
   end
end

% c) Determination of mode shapes
mod = C1*vS;                  %mode shapes (Eq. 3.40), v is the eigenvectors of matrix A
%%KKKKK
inm = v\B;                 %initial modal contribution
%%KKKKK
   
kss = size(freqdmpSRIM,1);

%extract mode shapes from mod corresponding to a frequency
for q = 1:kss
   modeshapeSRIM(1:m,q) = mod(1:m,freqdmpSRIM(q,3)); 
end

for q = 1:kss
   [mit, om] = max(abs(real(modeshapeSRIM(:,q))));
   modeshapeSRIM(:,q) = real(modeshapeSRIM(:,q))*1/mit*sign(real(modeshapeSRIM(om,q)));
end

% Plot the mode shape together with frequency & damping ratio information
modeplot(modeshapeSRIM,freqdmpSRIM,Case);

%% 2f. Validation Analysis

% Two criteria are used for selection of identified genuine modes, in terms of spatial & temporal consistency. 
% a) Modal Phase Collinearity (MPC) testing spatial consistency of identification results.
%    Modes having MPC value above 0.5 (mpc parameter below) are considered as genuine modal quantities.
% b) Extended Modal Amplitude Coherence (EMAC), evaluates temporal consistency of the identification results.
%    Both output EMAC & input EMAC can be computed. Input EMAC requires the controllability matrix.
%    Because the controllability matrix is not estimated by all considered SI methods,
%    this criterion is computed, but not used.
%    Modes with output EMAC values < 0.5 are considered spurious & therefore not reported.

% a) Modal Phase Collinearity (MPC) [Eqs. 3.85-3.87]
for q = 1:n
   a = real(mod(:,q));
   b = imag(mod(:,q));
   sxx(:,q) = a'*a;
   syy(:,q) = b'*b;
   sxy(:,q) = a'*b;
   nu(q) = (syy(:,q)-sxx(:,q))/(2*sxy(:,q));
   lam(1,q) = (sxx(:,q)+syy(:,q))/2+sxy(:,q)*(nu(q)^2+1)^0.5;
   lam(2,q) = (sxx(:,q)+syy(:,q))/2-sxy(:,q)*(nu(q)^2+1)^0.5;
   mpc(q) = ((lam(1,q)-lam(2,q))/(lam(1,q)+lam(2,q)))^2;
end
% a = real(mod(:,:));
% b = imag(mod(:,:));
% sxx(:,:) = a'*a;
% syy(:,:) = b'*b;
% sxy(:,:) = a'*b;
% nu(:) = (syy(:,:)-sxx(:,:))/(2*sxy(:,:));
% lam(1,:) = (sxx(:,:)+syy(:,:))/2 + sxy(:,:)*(nu(:)^2+1)^0.5;
% lam(2,:) = (sxx(:,:)+syy(:,:))/2 - sxy(:,:)*(nu(:)^2+1)^0.5;
% mpc(:) = ((lam(1,:)-lam(2,:))/(lam(1,:)+lam(2,:)))^2;

% b) Extended Modal Amplitude Coherence (EMAC)

% Only EMAC Output is computed as there is no Controllability Matrix

% Note that the computations are commented out as the matrix B is needed

%%KKKKK
plin = Op1*vS;     % Observability Matrix used for the output-EMAC
lamb = vS\A1*vS;
bkh = vS\B;
% Pick the last block row
pto = plin((p-1)*m+1:m*p,:); % the identified value at T0
for ds = 1:n
    ptop(:,ds) = mod(:,ds)*exp(sj1S(ds)*to*(p-1));
end
% Computation of rij
for qa = 1:n
    for qz = 1:m
        Rij(qa,qz) = min((abs(pto(qz,qa))/abs(ptop(qz,qa))),(abs(ptop(qz,qa))/abs(pto(qz,qa))));
        Pij = angle(pto(qz,qa)/ptop(qz,qa));
        Pijn(qa,qz) = Pij;
        if abs(Pij) <= pi/4
           Wij(qa,qz) = 1-abs(Pij)/(pi/4);
        else
           Wij(qa,qz) = 0;
        end
        emaco(qa,qz) = Rij(qa,qz)*Wij(qa,qz);
    end
end
% Computation of final emac
for xc = 1:n
% Weight for emaco
    sumo = 0;
    for la = 1:m  
        sumo = emaco(xc,la)*abs(mod(la,xc))^2+sumo;   
    end
    emacof(xc) = sumo/((mod(:,xc)'*mod(:,xc)));
    emac(xc) = emaco(xc);
end
%%KKKKK

% Add the MPC to the matrix freqdampSRIM
for lih = 1:kss(1)
  freqdmpSRIM(lih,5) = emacof(freqdmpSRIM(lih,3));
  freqdmpSRIM(lih,6) = mpc(freqdmpSRIM(lih,3));
  if freqdmpSRIM(lih,5)>0.5 && freqdmpSRIM(lih,6)>0.5
      validationm = ' valid';
  else
      validationm = ' not valid';
  end
  scroutput = strcat('Mode',num2str(lih), ': Output EMAC =  ',num2str(freqdmpSRIM(lih,5)),', MPC =  ',num2str(freqdmpSRIM(lih,6)), ' -->',' SRIM Identified Mode ',num2str(lih), ' is',validationm);
  sprintf(scroutput) 
end

%% 2g. Back calculate (estimate) output accelerations with state-space system &
%%     check against actual output accelerations

% Note that the computations are commented out as the matrix B is needed

% Prediction using state space model

%%KKKKK
ms1 = modstruc(A1,B,C1,D,zeros(n,m),x0);
th1 = ms2th(ms1,'d');
[e,r] = resid([dato dati],th1);
[simy] = idsim([dati],th1);                % simy represents the estimated accelerations
% 
for i = 1:m
    temsum = sum((dato(:,i)-simy(:,i)).^2);
    Jm(i) = temsum/(sum(dato(:,i).^2));     %Root mean square error of estimated accelerations
end

RMSEpredSRIM = sum(Jm)/m;
sprintf('Prediction Error Average for SRIM %0.4g',RMSEpredSRIM)
%%KKKKK
toc
function fi = block_3(df, m, CA_powers, dati, n1, r, C1)
    In1n1 = speye(n1,n1);
    fi = C1*kron(dati(df-1,:),In1n1);
    for nmf = 1:df-2
        fi = fi + CA_powers(:,:,df-nmf-1)*kron(dati(nmf,:),In1n1);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END of PART 3: : System Realization by Information Matrix (SRIM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
