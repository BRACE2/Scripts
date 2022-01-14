function SA = respspec(dt,dmp,per,accfr)
%dt=0.01;
%dmp=0.00;
%per=0.0200882608291633;
per=per';
%accfr=load('Acc_50Hz.txt');
% average acceleration
gama=1/2;
beta=1/4;

numper=size(per,1);
m=1;
numdata=size(accfr,1);
t=0:dt:(numdata-1)*dt;
t=t';

for i=1:numper
    if dt/per(i)>0.02
        dtp=per(i)*0.02;
        dtpx=0:dtp:max(t);
        dtpx=dtpx';
        accfrni=interp1(t,accfr,dtpx);
        accfrn=accfrni(1:size(accfrni,1)-1,1);
        numdatan=size(accfrn,1);
        p=-m*accfrn;
    else
        dtp=dt;
        accfrn=accfr;
        p=-m*accfrn;
        numdatan=numdata;
    end    
    k=4*pi^2*m/per(i)^2;
    c=2*dmp*sqrt(k*m);
    kstar=k+gama*c/(beta*dtp)+m/(beta*dtp^2.0);
    acons=m/(beta*dtp)+gama*c/beta;
    bcons=m/(2*beta)+dtp*(gama/(2*beta)-1)*c;
    u=zeros(numdatan,1);
    v=zeros(numdatan,1);
    a=zeros(numdatan,1);
    u(1)=0;
    v(1)=0;
    a(1)=(p(1)-c*v(1)-k*u(1))/m;
    for j=2:numdatan
        deltap=p(j)-p(j-1);
        deltaph=deltap+acons*v(j-1)+bcons*a(j-1);
        deltau=deltaph/kstar;
        deltav=gama*deltau/(beta*dtp)-gama*v(j-1)/beta+dtp*(1-gama/(2*beta))*a(j-1);
        deltaa=deltau/(beta*dtp^2)-v(j-1)/(beta*dtp)-a(j-1)/(2*beta);
        u(j)=u(j-1)+deltau;
        v(j)=v(j-1)+deltav;
        a(j)=a(j-1)+deltaa;
    end
    atot=a+accfrn;
    SA(i,1)=max(abs(atot));
end
    