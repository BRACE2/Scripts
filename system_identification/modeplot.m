function d=modeplot(modeshape,freqdmp,Case)

%undeformed shape, x is along the longitudinal direction of the bridge
%                  y is along the transverse direction (direction of the cap beam)
%                  z is the vertical direction (along the column)
if Case=='Case1'
    p1=[0.0     0.0  24.0];
    p2=[119.0   0.0  24.0];
    p5=[265.0   0.0  24.0];
    p3=[119.0 -20.0  24.0];
    p4=[119.0  20.0  24.0];
    p6=[119.0 -20.0   0.0];
    p7=[119.0  20.0   0.0];
    
    coorxg=[p1(1) p2(1) p5(1)];
    cooryg=[p1(2) p2(2) p5(2)];
    coorzg=[p1(3) p2(3) p5(3)];
    
    coorxb=[p3(1) p2(1) p4(1)];
    cooryb=[p3(2) p2(2) p4(2)];
    coorzb=[p3(3) p2(3) p4(3)];
    
    coorxc1=[p6(1) p3(1)];
    cooryc1=[p6(2) p3(2)];
    coorzc1=[p6(3) p3(3)];
    
    coorxc2=[p7(1) p4(1)];
    cooryc2=[p7(2) p4(2)];
    coorzc2=[p7(3) p4(3)];
    
    % mode shape
    % Add the modal amplitudes to the mode shape with some scaling
    for i=1:size(modeshape,2)
        p1d=[0.0     0.0+modeshape(1,i)*20  24.0];
        p2d=[119.0   0.0+modeshape(2,i)*20  24.0];
        p5d=[265.0   0.0+modeshape(3,i)*20  24.0];
        p3d=[119.0 -20.0+modeshape(2,i)*20  24.0];
        p4d=[119.0  20.0+modeshape(2,i)*20  24.0];
        p6d=[119.0 -20.0   0.0];
        p7d=[119.0  20.0   0.0];
        
        coorxgd=[p1d(1) p2d(1) p5d(1)];
        coorygd=[p1d(2) p2d(2) p5d(2)];
        coorzgd=[p1d(3) p2d(3) p5d(3)];
        
        coorxbd=[p3d(1) p2d(1) p4d(1)];
        coorybd=[p3d(2) p2d(2) p4d(2)];
        coorzbd=[p3d(3) p2d(3) p4d(3)];
        
        coorxcd1=[p6d(1) p3d(1)];
        coorycd1=[p6d(2) p3d(2)];
        coorzcd1=[p6d(3) p3d(3)];
        
        coorxcd2=[p7d(1) p4d(1)];
        coorycd2=[p7d(2) p4d(2)];
        coorzcd2=[p7d(3) p4d(3)];
        
        figure;
        plot3(coorxg,cooryg,coorzg,'b');
        hold on;
        plot3(coorxb,cooryb,coorzb,'b');
        plot3(coorxc1,cooryc1,coorzc1,'b');
        plot3(coorxc2,cooryc2,coorzc2,'b');
        
        plot3(coorxgd,coorygd,coorzgd,'r');
        plot3(coorxbd,coorybd,coorzbd,'r');
        plot3(coorxcd1,coorycd1,coorzcd1,'r');
        plot3(coorxcd2,coorycd2,coorzcd2,'r');
        
        hold off;
        grid on;
        ylim ([-100 100]);
        zlim ([0 40]);
        %legend('Undeformed','','','Mode Shape','','');
        
        ntem=num2str(1/freqdmp(i,1),3);
        nte=strcat('T=',ntem,' sec');
        ksim=num2str(freqdmp(i,2),2);
        ksi=strcat('\xi =',ksim);
        
        text(200,0,nte,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
        text(200,-50,ksi,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
    end
end

if Case=='Case2'
    p1=[0.0     0.0  24.0];
    p2=[119.0   0.0  24.0];
    p5=[265.0   0.0  24.0];
    p3=[119.0 -20.0  24.0];
    p4=[119.0  20.0  24.0];
    p6=[119.0 -20.0   0.0];
    p7=[119.0  20.0   0.0];
    
    coorxg=[p1(1) p2(1) p5(1)];
    cooryg=[p1(2) p2(2) p5(2)];
    coorzg=[p1(3) p2(3) p5(3)];
    
    coorxb=[p3(1) p2(1) p4(1)];
    cooryb=[p3(2) p2(2) p4(2)];
    coorzb=[p3(3) p2(3) p4(3)];
    
    coorxc1=[p6(1) p3(1)];
    cooryc1=[p6(2) p3(2)];
    coorzc1=[p6(3) p3(3)];
    
    coorxc2=[p7(1) p4(1)];
    cooryc2=[p7(2) p4(2)];
    coorzc2=[p7(3) p4(3)];
    
    % mode shape
    % Add the modal amplitudes to the mode shape with some scaling
    for i=1:size(modeshape,2)
        p1d=[0.0+modeshape(1,i)*20     0.0  24.0];
        p2d=[119.0+modeshape(1,i)*20   0.0  24.0];
        p5d=[265.0+modeshape(1,i)*20   0.0  24.0];
        p3d=[119.0+modeshape(1,i)*20 -20.0  24.0];
        p4d=[119.0+modeshape(1,i)*20  20.0  24.0];
        p6d=[119.0                   -20.0   0.0];
        p7d=[119.0                    20.0   0.0];
        
        coorxgd=[p1d(1) p2d(1) p5d(1)];
        coorygd=[p1d(2) p2d(2) p5d(2)];
        coorzgd=[p1d(3) p2d(3) p5d(3)];
        
        coorxbd=[p3d(1) p2d(1) p4d(1)];
        coorybd=[p3d(2) p2d(2) p4d(2)];
        coorzbd=[p3d(3) p2d(3) p4d(3)];
        
        coorxcd1=[p6d(1) p3d(1)];
        coorycd1=[p6d(2) p3d(2)];
        coorzcd1=[p6d(3) p3d(3)];
        
        coorxcd2=[p7d(1) p4d(1)];
        coorycd2=[p7d(2) p4d(2)];
        coorzcd2=[p7d(3) p4d(3)];
        
        figure;
        plot3(coorxg,cooryg,coorzg,'b');
        hold on;
        plot3(coorxb,cooryb,coorzb,'b');
        plot3(coorxc1,cooryc1,coorzc1,'b');
        plot3(coorxc2,cooryc2,coorzc2,'b');
        
        plot3(coorxgd,coorygd,coorzgd,'r');
        plot3(coorxbd,coorybd,coorzbd,'r');
        plot3(coorxcd1,coorycd1,coorzcd1,'r');
        plot3(coorxcd2,coorycd2,coorzcd2,'r');
        
        hold off;
        grid on;
        ylim ([-100 100]);
        zlim ([0 40]);
        %legend('Undeformed','','','Mode Shape','','');
        
        ntem=num2str(1/freqdmp(i,1),3);
        nte=strcat('T=',ntem,' sec');
        ksim=num2str(freqdmp(i,2),2);
        ksi=strcat('\xi =',ksim);
        
        text(200,0,nte,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
        text(200,-50,ksi,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
    end
end


if Case=='Case3'
    p1=[0.0     0.0  24.0];
    p9=[20.0     0.0  24.0];
    p8=[80.0     0.0  24.0];
    p2=[119.0   0.0  24.0];
    p10=[192.0  0.0  24.0];
    p5=[265.0   0.0  24.0];
    p3=[119.0 -20.0  24.0];
    p4=[119.0  20.0  24.0];
    p6=[119.0 -20.0   0.0];
    p7=[119.0  20.0   0.0];
    
    coorxg=[p1(1) p9(1) p8(1) p2(1) p10(1) p5(1)];
    cooryg=[p1(2) p9(2) p8(2) p2(2) p10(2) p5(2)];
    coorzg=[p1(3) p9(3) p8(3) p2(3) p10(3) p5(3)];
    
    coorxb=[p3(1) p2(1) p4(1)];
    cooryb=[p3(2) p2(2) p4(2)];
    coorzb=[p3(3) p2(3) p4(3)];
    
    coorxc1=[p6(1) p3(1)];
    cooryc1=[p6(2) p3(2)];
    coorzc1=[p6(3) p3(3)];
    
    coorxc2=[p7(1) p4(1)];
    cooryc2=[p7(2) p4(2)];
    coorzc2=[p7(3) p4(3)];
    
    % mode shape
    % Add the modal amplitudes to the mode shape with some scaling
    for i=1:size(modeshape,2)
        p1d=[0.0      0.0  24.0];
        p9d=[20.0     0.0  24.0+modeshape(1,i)*10];
        p8d=[80.0     0.0  24.0+modeshape(2,i)*10];
        p2d=[119.0    0.0  24.0+modeshape(3,i)*10];
        p10d=[192.0   0.0  24.0+modeshape(3,i)*10];        
        p5d=[265.0   0.0  24.0];
        p3d=[119.0 -20.0  24.0+modeshape(3,i)*10];
        p4d=[119.0  20.0  24.0+modeshape(3,i)*10];
        p6d=[119.0 -20.0   0.0];
        p7d=[119.0  20.0   0.0];

        
        coorxgd=[p1d(1) p9d(1) p8d(1) p2d(1) p10d(1) p5d(1)];
        coorygd=[p1d(2) p9d(2) p8d(2) p2d(2) p10d(2) p5d(2)];
        coorzgd=[p1d(3) p9d(3) p8d(3) p2d(3) p10d(3) p5d(3)];
        
        coorxbd=[p3d(1) p2d(1) p4d(1)];
        coorybd=[p3d(2) p2d(2) p4d(2)];
        coorzbd=[p3d(3) p2d(3) p4d(3)];
        
        coorxcd1=[p6d(1) p3d(1)];
        coorycd1=[p6d(2) p3d(2)];
        coorzcd1=[p6d(3) p3d(3)];
        
        coorxcd2=[p7d(1) p4d(1)];
        coorycd2=[p7d(2) p4d(2)];
        coorzcd2=[p7d(3) p4d(3)];
        
        figure;
        plot3(coorxg,cooryg,coorzg,'b');
        hold on;
        plot3(coorxb,cooryb,coorzb,'b');
        plot3(coorxc1,cooryc1,coorzc1,'b');
        plot3(coorxc2,cooryc2,coorzc2,'b');
        
        plot3(coorxgd,coorygd,coorzgd,'r');
        plot3(coorxbd,coorybd,coorzbd,'r');
        plot3(coorxcd1,coorycd1,coorzcd1,'r');
        plot3(coorxcd2,coorycd2,coorzcd2,'r');
        
        hold off;
        grid on;
        ylim ([-100 100]);
        zlim ([0 40]);
        %legend('Undeformed','','','Mode Shape','','');
        
        ntem=num2str(1/freqdmp(i,1),3);
        nte=strcat('T=',ntem,' sec');
        ksim=num2str(freqdmp(i,2),2);
        ksi=strcat('\xi =',ksim);
        
        text(200,0,nte,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
        text(200,-50,ksi,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
    end
end
    
if Case=='Case4'
    p1=[0.0     0.0  24.0];
    p9=[20.0     0.0  24.0];
    p8=[80.0     0.0  24.0];
    p2=[119.0   0.0  24.0];
    p10=[192.0  0.0  24.0];
    p5=[265.0   0.0  24.0];
    p3=[119.0 -20.0  24.0];
    p4=[119.0  20.0  24.0];
    p6=[119.0 -20.0   0.0];
    p7=[119.0  20.0   0.0];
    
    coorxg=[p1(1) p9(1) p8(1) p2(1) p10(1) p5(1)];
    cooryg=[p1(2) p9(2) p8(2) p2(2) p10(2) p5(2)];
    coorzg=[p1(3) p9(3) p8(3) p2(3) p10(3) p5(3)];
    
    coorxb=[p3(1) p2(1) p4(1)];
    cooryb=[p3(2) p2(2) p4(2)];
    coorzb=[p3(3) p2(3) p4(3)];
    
    coorxc1=[p6(1) p3(1)];
    cooryc1=[p6(2) p3(2)];
    coorzc1=[p6(3) p3(3)];
    
    coorxc2=[p7(1) p4(1)];
    cooryc2=[p7(2) p4(2)];
    coorzc2=[p7(3) p4(3)];
    
    % mode shape
    % Add the modal amplitudes to the mode shape with some scaling
    for i=1:size(modeshape,2)
        p1d=[0.0+modeshape(1,i)*20      0.0  24.0];
        p9d=[20.0                       0.0  24.0+modeshape(2,i)*10];
        p8d=[80.0                       0.0  24.0+modeshape(3,i)*10];
        p2d=[119.0+modeshape(1,i)*20    0.0  24.0+modeshape(4,i)*10];
        p10d=[192.0                     0.0  24.0+modeshape(4,i)*10];        
        p5d=[265.0+modeshape(1,i)*20    0.0  24.0];
        p3d=[119.0+modeshape(1,i)*20  -20.0  24.0+modeshape(4,i)*10];
        p4d=[119.0+modeshape(1,i)*20   20.0  24.0+modeshape(4,i)*10];
        p6d=[119.0                    -20.0   0.0];
        p7d=[119.0                     20.0   0.0];

        
        coorxgd=[p1d(1) p9d(1) p8d(1) p2d(1) p10d(1) p5d(1)];
        coorygd=[p1d(2) p9d(2) p8d(2) p2d(2) p10d(2) p5d(2)];
        coorzgd=[p1d(3) p9d(3) p8d(3) p2d(3) p10d(3) p5d(3)];
        
        coorxbd=[p3d(1) p2d(1) p4d(1)];
        coorybd=[p3d(2) p2d(2) p4d(2)];
        coorzbd=[p3d(3) p2d(3) p4d(3)];
        
        coorxcd1=[p6d(1) p3d(1)];
        coorycd1=[p6d(2) p3d(2)];
        coorzcd1=[p6d(3) p3d(3)];
        
        coorxcd2=[p7d(1) p4d(1)];
        coorycd2=[p7d(2) p4d(2)];
        coorzcd2=[p7d(3) p4d(3)];
        
        figure;
        plot3(coorxg,cooryg,coorzg,'b');
        hold on;
        plot3(coorxb,cooryb,coorzb,'b');
        plot3(coorxc1,cooryc1,coorzc1,'b');
        plot3(coorxc2,cooryc2,coorzc2,'b');
        
        plot3(coorxgd,coorygd,coorzgd,'r');
        plot3(coorxbd,coorybd,coorzbd,'r');
        plot3(coorxcd1,coorycd1,coorzcd1,'r');
        plot3(coorxcd2,coorycd2,coorzcd2,'r');
        
        hold off;
        grid on;
        ylim ([-100 100]);
        zlim ([0 40]);
        %legend('Undeformed','','','Mode Shape','','');
        
        ntem=num2str(1/freqdmp(i,1),3);
        nte=strcat('T=',ntem,' sec');
        ksim=num2str(freqdmp(i,2),2);
        ksi=strcat('\xi =',ksim);
        
        text(200,0,nte,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
        text(200,-50,ksi,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
    end
end

if Case=='Case5'
    p1=[0.0     0.0  24.0];
    p9=[20.0     0.0  24.0];
    p8=[80.0     0.0  24.0];
    p2=[119.0   0.0  24.0];
    p10=[192.0  0.0  24.0];
    p5=[265.0   0.0  24.0];
    p3=[119.0 -20.0  24.0];
    p4=[119.0  20.0  24.0];
    p6=[119.0 -20.0   0.0];
    p7=[119.0  20.0   0.0];
    
    coorxg=[p1(1) p9(1) p8(1) p2(1) p10(1) p5(1)];
    cooryg=[p1(2) p9(2) p8(2) p2(2) p10(2) p5(2)];
    coorzg=[p1(3) p9(3) p8(3) p2(3) p10(3) p5(3)];
    
    coorxb=[p3(1) p2(1) p4(1)];
    cooryb=[p3(2) p2(2) p4(2)];
    coorzb=[p3(3) p2(3) p4(3)];
    
    coorxc1=[p6(1) p3(1)];
    cooryc1=[p6(2) p3(2)];
    coorzc1=[p6(3) p3(3)];
    
    coorxc2=[p7(1) p4(1)];
    cooryc2=[p7(2) p4(2)];
    coorzc2=[p7(3) p4(3)];
    
    % mode shape
    % Add the modal amplitudes to the mode shape with some scaling
    for i=1:size(modeshape,2)
        p1d=[0.0      0.0  24.0];
        p9d=[20.0     0.0  24.0+modeshape(1,i)*10];
        p8d=[80.0     0.0  24.0+modeshape(2,i)*10];
        p2d=[119.0    0.0  24.0+modeshape(3,i)*10];
        p10d=[192.0   0.0  24.0+modeshape(3,i)*10];        
        p5d=[265.0   0.0  24.0];
        p3d=[119.0 -20.0  24.0+modeshape(3,i)*10];
        p4d=[119.0  20.0  24.0+modeshape(3,i)*10];
        p6d=[119.0 -20.0   0.0];
        p7d=[119.0  20.0   0.0];

        
        coorxgd=[p1d(1) p9d(1) p8d(1) p2d(1) p10d(1) p5d(1)];
        coorygd=[p1d(2) p9d(2) p8d(2) p2d(2) p10d(2) p5d(2)];
        coorzgd=[p1d(3) p9d(3) p8d(3) p2d(3) p10d(3) p5d(3)];
        
        coorxbd=[p3d(1) p2d(1) p4d(1)];
        coorybd=[p3d(2) p2d(2) p4d(2)];
        coorzbd=[p3d(3) p2d(3) p4d(3)];
        
        coorxcd1=[p6d(1) p3d(1)];
        coorycd1=[p6d(2) p3d(2)];
        coorzcd1=[p6d(3) p3d(3)];
        
        coorxcd2=[p7d(1) p4d(1)];
        coorycd2=[p7d(2) p4d(2)];
        coorzcd2=[p7d(3) p4d(3)];
        
        figure;
        plot3(coorxg,cooryg,coorzg,'b');
        hold on;
        plot3(coorxb,cooryb,coorzb,'b');
        plot3(coorxc1,cooryc1,coorzc1,'b');
        plot3(coorxc2,cooryc2,coorzc2,'b');
        
        plot3(coorxgd,coorygd,coorzgd,'r');
        plot3(coorxbd,coorybd,coorzbd,'r');
        plot3(coorxcd1,coorycd1,coorzcd1,'r');
        plot3(coorxcd2,coorycd2,coorzcd2,'r');
        
        hold off;
        grid on;
        ylim ([-100 100]);
        zlim ([0 40]);
        %legend('Undeformed','','','Mode Shape','','');
        
        ntem=num2str(1/freqdmp(i,1),3);
        nte=strcat('T=',ntem,' sec');
        ksim=num2str(freqdmp(i,2),2);
        ksi=strcat('\xi =',ksim);
        
        text(200,0,nte,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
        text(200,-50,ksi,'FontName','Times','FontSize',14,'FontAngle','Italic','FontWeight','Bold');
    end
end

