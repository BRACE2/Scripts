function [acc, vel, disp, dt]= readv2p(filename)

fid=fopen(filename,'r');
for i=1:45
    tline = fgetl(fid);
end
tlinehead=fgetl(fid);
newStr = split(tlinehead);
dt = str2num(cell2mat(newStr(10))); 
% read the acceleration data
j=0;
while ischar(tline)
    %disp(tline)
    tline = fgetl(fid);
    if length(tline)<80
        if (tline(end)==')'||tline(end)==' ')
            break
        else
            tline = fgetl(fid);
            break
        end
    else
        tline1=tline(1:10);
        j=j+1;
        acc(j) = str2num(tline1);
        tline2=tline(11:20);
        j=j+1;
        acc(j) = str2num(tline2);
        tline3=tline(21:30);
        j=j+1;
        acc(j) = str2num(tline3);
        tline4=tline(31:40);
        j=j+1;
        acc(j) = str2num(tline4);
        tline5=tline(41:50);
        j=j+1;
        acc(j) = str2num(tline5);
        tline6=tline(51:60);
        j=j+1;
        acc(j) = str2num(tline6);
        tline7=tline(61:70);
        j=j+1;
        acc(j) = str2num(tline7);
        tline8=tline(71:80);
        j=j+1;
        acc(j) = str2num(tline8);
    end
end

% read the velocity data
j=0;
while ischar(tline)
    %disp(tline)
    tline = fgetl(fid);
    if length(tline)<80
        if (tline(end)==')'||tline(end)==' ')
            break
        else
            tline = fgetl(fid);
            break
        end
    else
        tline1=tline(1:10);
        j=j+1;
        vel(j) = str2num(tline1);
        tline2=tline(11:20);
        j=j+1;
        vel(j) = str2num(tline2);
        tline3=tline(21:30);
        j=j+1;
        vel(j) = str2num(tline3);
        tline4=tline(31:40);
        j=j+1;
        vel(j) = str2num(tline4);
        tline5=tline(41:50);
        j=j+1;
        vel(j) = str2num(tline5);
        tline6=tline(51:60);
        j=j+1;
        vel(j) = str2num(tline6);
        tline7=tline(61:70);
        j=j+1;
        vel(j) = str2num(tline7);
        tline8=tline(71:80);
        j=j+1;
        vel(j) = str2num(tline8);
    end
end

% read the displacement data
j=0;
while ischar(tline)
    %disp(tline)
    tline = fgetl(fid);
    if (tline(end)==')' || tline(end)=='-')
        break
    elseif length(tline)<80
        break
    else
        tline1=tline(1:10);
        j=j+1;
        disp(j) = str2num(tline1);
        tline2=tline(11:20);
        j=j+1;
        disp(j) = str2num(tline2);
        tline3=tline(21:30);
        j=j+1;
        disp(j) = str2num(tline3);
        tline4=tline(31:40);
        j=j+1;
        disp(j) = str2num(tline4);
        tline5=tline(41:50);
        j=j+1;
        disp(j) = str2num(tline5);
        tline6=tline(51:60);
        j=j+1;
        disp(j) = str2num(tline6);
        tline7=tline(61:70);
        j=j+1;
        disp(j) = str2num(tline7);
        tline8=tline(71:80);
        j=j+1;
        disp(j) = str2num(tline8);
    end
end