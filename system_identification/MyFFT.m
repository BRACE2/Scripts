function [ff,psdResult] = MyFFT(dt,signal,numfig)
%***********************************************************
%     Power Density calculation
%     dt - time increment
%     signal - input signal vector
%     nn - number of points in overlapping window (code finds the maximum one)
%***********************************************************

nPoints = length(signal); %   nPoints - number of points in the signal
nn = 2;
while (nn<nPoints),
   nn = nn*2;
end

%nn=nn/2;

%nn = 1024;

fscan=1/dt;  %scanning frequency
nn1=nn/2+1;

Y0=fft(signal,nn);
Pyy0=abs(Y0/length(signal));

f=(fscan/(nn))*(0:nn1);

ff = f(1:nn1);
psdResult = Pyy0(1:nn1);
%psdResult = Y0(1:nn1);


% if numfig==1
% figure;
% semilogx(f(1:nn1),Pyy0(1:nn1),'r');
% else
% hold on
% semilogx(f(1:nn1),Pyy0(1:nn1),'b');
% hold off
% end
%title ('POWER SPECTRAL DENSITY: input - red');
%axis([0 30 0 4]);
%ylabel('PSD');
%xlabel('Frequency, Hz');
%grid;




