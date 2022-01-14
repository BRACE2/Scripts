function [acc, dt]= readv1p(filename)

fid=fopen(filename,'r');
for i=1:27
    tline = fgetl(fid);
end
tlinehead=fgetl(fid);
newStr = split(tlinehead);
smprate = str2num(cell2mat(newStr(6)));
dt = 1/smprate;
j=0;
while ischar(tline)
    %disp(tline)
    tline = fgetl(fid);
    if (tline(end)==')')
        break
    elseif length(tline)<72
        break
    else
        tline1=tline(1:9);
        j=j+1;
        acc(j) = str2num(tline1);
        tline2=tline(10:18);
        j=j+1;
        acc(j) = str2num(tline2);
        tline3=tline(19:27);
        j=j+1;
        acc(j) = str2num(tline3);
        tline4=tline(28:36);
        j=j+1;
        acc(j) = str2num(tline4);
        tline5=tline(37:45);
        j=j+1;
        acc(j) = str2num(tline5);
        tline6=tline(46:54);
        j=j+1;
        acc(j) = str2num(tline6);
        tline7=tline(55:63);
        j=j+1;
        acc(j) = str2num(tline7);
        tline8=tline(64:72);
        j=j+1;
        acc(j) = str2num(tline8);
    end
end