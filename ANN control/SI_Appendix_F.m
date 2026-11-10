
clearvars; clc; close all;

%% 1. Parameters 
P.T          = 6;
P.tEnd       = 1000;
P.x0         = [1.1; 0.6];
P.W0         = zeros(5,1);
P.q          = [10; 9];          % b1=90, b2=18
P.eta        = 100;
P.kappaBar   = 1e-3;
P.h          = 1e-3;             % recording interval, seconds
P.hNoise     = 1e-3;             % noise refresh/hold interval, seconds
P.hLearn     = 2e-5;             % RK4 substep before T
P.hPost      = 1e-3;             % RK4 substep after T
P.noiseSigma = [0.003; 0.003];    % PARENT Gaussian standard deviations
P.noiseCut   = 3;                % symmetric truncation by rejection sampling
P.seed       = 20261019;         

P.dAmp       = [0.11, 0.16];     % acceleration disturbance amplitudes
P.dPeriod    = [0.15, 0.25];       % periods in seconds
P.dOmega     = 2*pi./P.dPeriod;  % rad/s; 

P.activation.alpha   = 0.7;
P.activation.rho     = 0.3;
P.activation.epsilon = 0.1;
P.activation.gamma   = 0.1;

P.plant.quadratic       = 0.1;
P.plant.cross           = -0.2;
P.plant.inputModulation = 0.2;
P.metricStart           = 20;
P.lateMetricStart       = 700;
P.stopBound             = 1e6;  

%% 2. Simulate 
P = prepareParametersF(P);
R = simulateTELF(P);


%% 3. Figure F1: 0--12 s, with 2--8 s state insets
m = 15;
linewidth  = 1.3;
linewidth1 = 0.9;
color1 = '#4CBFED';
color2 = 'r';
color3 = '#1b4f34';
color4 = 'b';
color5 = '#EDB021';
color6 = '#78AB31';

shortWindow = 12;
Tc=6;
is = R.t <= shortWindow;

figure(1)
set (gcf,'unit','inches','position', [0.5 1 8 4.8]);

subplot('Position',[0.08,0.63,0.4,0.35]);
plot(R.t(is),R.X(is,1),'LineWidth',linewidth,'Color',color1); hold on;
xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,shortWindow]); ylim([-0.13,1.25]);
xlabel('time(s)','FontName','times new roman');
ylabel('$x_1$','interpreter','latex','FontName','times new roman');
annotation('textarrow', [0.3255, 0.2869], [0.9114, 0.9412], ...
        'String', '$t = T_p$', 'interpreter','latex',...
        'FontName', 'Times New Roman', ...
        'FontSize', 13, ...
        'Color', 'k', ...
        'LineWidth', 0.5, ...
        'HeadStyle', 'vback2'); %  创建带箭头的文本标注
title('(a)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
grid on;

subplot('Position',[0.57,0.63,0.4,0.35]);
plot(R.t(is),R.X(is,2),'LineWidth',linewidth,'Color',color2); hold on;
xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,shortWindow]); ylim([-1.2,0.7]);
xlabel('time(s)','FontName','times new roman');
ylabel('$x_2$','interpreter','latex','FontName','times new roman');
title('(b)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
grid on;

subplot('Position',[0.08,0.15,0.4,0.35]);
plot(R.t(is),R.U(is),'LineWidth',linewidth1,'Color',color3); hold on;
xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,shortWindow]); ylim([-4.5,1.4]);
xlabel('time(s)','FontName','times new roman');
ylabel('$u$','interpreter','latex','FontName','times new roman');
title('(c)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
grid on;

subplot('Position',[0.57,0.15,0.4,0.35]);
tw = [R.tW; shortWindow];
ww = [R.W; R.Wfinal.'];
plot(tw,ww(:,1),'LineWidth',linewidth,'Color',color1,'LineStyle','-'); hold on;
plot(tw,ww(:,2),'LineWidth',linewidth,'Color',color2,'LineStyle','-.');
plot(tw,ww(:,3),'LineWidth',linewidth,'Color',color3,'LineStyle','--');
plot(tw,ww(:,4),'LineWidth',linewidth,'Color',color4,'LineStyle',':');
plot(tw,ww(:,5),'LineWidth',linewidth,'Color',color6,'LineStyle','-');
xlim([0,shortWindow]); ylim([-7.5,2]);
xlabel('time(s)','FontName','times new roman');
ylabel('$\hat W_j$','interpreter','latex','FontName','times new roman');
title('(d)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
legend('$j$=1','$j$=2','$j$=3','$j$=4','$j$=5','interpreter','latex','FontName','times new roman','FontSize',10);
legend('Orientation','horizontal','NumColumns', 3,'Location', [0.6096, 0.397, 0.2836, 0.089])
%xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
grid on;

%% 小图
axes('Position',[.2314 .714 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t(is),R.X(is,1),'LineWidth',linewidth,'Color',color1); hold on;grid on;
xlim([2 8]);
ylim([-0.03 0.1]);
set(gca,'FontName','Times New Roman','FontSize',11);
% ax = gca;% 获取当前坐标轴句柄
% %ax.XTick = [30,35,40,45,50]; %修改刻度
% ax.YTick = [0, 0.03,0.06];

axes('Position',[.7189 .6793 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t(is),R.X(is,2),'LineWidth',linewidth,'Color',color2); hold on;grid on;
xlim([2 8]);
ylim([-0.12 0.04]);
set(gca,'FontName','Times New Roman','FontSize',11);

%% 4. Figure F2
figure(2)
set (gcf,'unit','inches','position', [0.5 1 8 4.8]);

subplot('Position',[0.08,0.63,0.4,0.35]);
plot(R.t,R.X(:,1),'LineWidth',linewidth,'Color',color1); hold on;
%xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,P.tEnd]); ylim([-0.13,1.25]);
xlabel('time(s)','FontName','times new roman');
ylabel('$x_1$','interpreter','latex','FontName','times new roman');
title('(a)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
grid on;

subplot('Position',[0.57,0.63,0.4,0.35]);
plot(R.t,R.X(:,2),'LineWidth',linewidth,'Color',color2); hold on;
%xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,P.tEnd]); ylim([-1.2,0.7]);
xlabel('time(s)','FontName','times new roman');
ylabel('$x_2$','interpreter','latex','FontName','times new roman');
title('(b)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
grid on;

subplot('Position',[0.08,0.15,0.4,0.35]);
plot(R.t,R.U,'LineWidth',linewidth1,'Color',color3); hold on;
%xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,P.tEnd]); ylim([-4.5,1.4]);
xlabel('time(s)','FontName','times new roman');
ylabel('$u$','interpreter','latex','FontName','times new roman');
title('(c)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
grid on;

subplot('Position',[0.57,0.15,0.4,0.35]);
tw2 = [R.tW; P.tEnd];
ww2 = [R.W; R.Wfinal.'];
plot(tw2,ww2(:,1),'LineWidth',linewidth,'Color',color1,'LineStyle','-'); hold on;
plot(tw2,ww2(:,2),'LineWidth',linewidth,'Color',color2,'LineStyle','-.');
plot(tw2,ww2(:,3),'LineWidth',linewidth,'Color',color3,'LineStyle','--');
plot(tw2,ww2(:,4),'LineWidth',linewidth,'Color',color4,'LineStyle',':');
plot(tw2,ww2(:,5),'LineWidth',linewidth,'Color',color6,'LineStyle','-');
xlim([0,P.tEnd]); ylim([-7.5,2]);
xlabel('time(s)','FontName','times new roman');
ylabel('$\hat W_j$','interpreter','latex','FontName','times new roman');
title('(d)','FontName','Times New Roman','FontSize',16,...
        'Units','Normalized',...  % 归一化单位，不受数据范围影响
        'Position',[0.98, 0.8414, 0],...  % 右上角位置（微调避免溢出）
        'HorizontalAlignment','right'); % 文字右对齐，精准贴合右上角
set(gca,'FontName','Times New Roman','FontSize',15);
legend('$j$=1','$j$=2','$j$=3','$j$=4','$j$=5','interpreter','latex','FontName','times new roman','FontSize',10);
legend('Orientation','horizontal','NumColumns', 3,'Location', [0.6096, 0.397, 0.2836, 0.089])
%xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
grid on;

%% 小图
axes('Position',[.2314 .714 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t,R.X(:,1),'LineWidth',linewidth,'Color',color1); hold on;grid on;
xlim([995 1000]);
ylim([-3.5e-4 6e-4]);
set(gca,'FontName','Times New Roman','FontSize',11);
ax = gca;% 获取当前坐标轴句柄
ax.XTick = [995,997.5,1000]; %修改刻度
%ax.YTick = [-3e-3,0, 3e-3];

axes('Position',[.7189 .6793 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t,R.X(:,2),'LineWidth',linewidth,'Color',color2); hold on;grid on;
xlim([995 1000]);
ylim([-0.011 0.012]);
set(gca,'FontName','Times New Roman','FontSize',11);
ax = gca;% 获取当前坐标轴句柄
ax.XTick = [995,997.5,1000]; %修改刻度

axes('Position',[.2314 .2019 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t,R.U,'LineWidth',linewidth1,'Color',color3); hold on;grid on;
xlim([995 1000]);
ylim([-0.035 0.037]);
set(gca,'FontName','Times New Roman','FontSize',11);
ax = gca;% 获取当前坐标轴句柄
ax.XTick = [995,997.5,1000]; %修改刻度


%% Local functions
function P = prepareParametersF(P)
    assert(isequal(size(P.x0),[2,1]) && isequal(size(P.W0),[5,1]), ...
        'TEL:InitialConditions','x0 must be 2-by-1 and W0 must be 5-by-1.');
    P.q=P.q(:);
    assert(numel(P.q)==2 && all(isfinite(P.q)) && ...
        all(P.q==round(P.q)) && P.q(1)>P.q(2) && P.q(2)>2, ...
        'TEL:Exponents','Require distinct integers q1>q2>2.');
    assert(all(isfinite([P.x0;P.W0])));
    assert(all(isfinite([P.T,P.tEnd,P.eta,P.kappaBar,P.h,P.hNoise, ...
        P.hLearn,P.hPost,P.noiseCut,P.metricStart,P.lateMetricStart,P.stopBound])));
    assert(P.T>0 && P.T<12 && P.tEnd>=1000 && P.eta>0 && P.kappaBar>0);
    assert(P.h>0 && P.hNoise>0 && P.hLearn>0 && P.hPost>0);
    assert(P.metricStart>=P.T && P.metricStart<P.tEnd && ...
        P.lateMetricStart>=P.T && P.lateMetricStart<P.tEnd);
    assert(P.noiseCut>0 && P.stopBound>0);
    assert(isequal(size(P.noiseSigma),[2,1]) && ...
        all(isfinite(P.noiseSigma)) && all(P.noiseSigma>=0));
    assert(P.seed>=1 && P.seed<2147483647 && P.seed==round(P.seed));
    ratio=[P.T/P.h,P.tEnd/P.h,P.hNoise/P.h,P.h/P.hLearn, ...
        P.h/P.hPost,P.metricStart/P.h,P.lateMetricStart/P.h];
    assert(all(ratio>=1) && all(abs(ratio-round(ratio))<1e-7), ...
        'TEL:TimeGrid','Recording, noise, integration and switching grids must align.');

    Q=[ones(2,1),-P.q];
    P.b=Q\(-P.q.*(P.q-1));
    assert(norm(P.b-[prod(P.q);sum(P.q)-1],inf)<1e-10);
    P.charPolynomial=[1,-(P.b(2)+1),P.b(1)];
    P.charRoots=roots(P.charPolynomial);
    P.B=[1,0;0,1;1,1;2,0;0,2];

    A=P.activation;
    assert(all(isfinite([A.alpha,A.rho,A.epsilon,A.gamma])) && ...
        A.alpha>0 && A.alpha<1 && A.rho>=0 && A.rho<=1 && ...
        A.epsilon>0 && A.gamma>0,'TEL:Activation','Invalid activation parameters.');
    P.activation.slopeAtZero=A.gamma*((1-A.rho)+A.rho*A.epsilon^(A.alpha-1));
    assert(numel(P.dAmp)==2 && numel(P.dPeriod)==2 && numel(P.dOmega)==2);
    assert(all(isfinite([P.dAmp(:);P.dPeriod(:);P.dOmega(:)])) && ...
        all(P.dAmp>=0) && all(P.dPeriod>0));
    assert(norm(P.dOmega-2*pi./P.dPeriod,inf)<1e-12, ...
        'TEL:Disturbance','Set the periods; dOmega must equal 2*pi./dPeriod.');
    D=P.plant;
    assert(all(isfinite([D.quadratic,D.cross,D.inputModulation])) && ...
        abs(D.inputModulation)<1,'TEL:Plant','The control gain must stay positive.');
    P.plant.dAmp=P.dAmp;
    P.plant.dOmega=P.dOmega;
    P.plant.inputGainBounds=[1-abs(D.inputModulation),1+abs(D.inputModulation)];

    P.controller=struct('T',P.T,'b',P.b,'B',P.B, ...
        'activation',P.activation,'eta',P.eta,'kappaBar',P.kappaBar);
end

function R = simulateTELF(P)
    nStep=round(P.tEnd/P.h); nT=round(P.T/P.h);
    noiseStride=round(P.hNoise/P.h);
    delta=boundedNoiseF(floor(nStep/noiseStride)+1,P);
    R.t=(0:nStep).'*P.h;
    R.X=zeros(nStep+1,2); R.U=zeros(nStep+1,1);
    R.Ustate=zeros(nStep+1,1); 
    R.Noise=zeros(nStep+1,2); R.D=zeros(nStep+1,1);
    R.Acceleration=zeros(nStep+1,1);
    R.F=zeros(nStep+1,1); R.G=zeros(nStep+1,1);
    R.E=nan(nStep+1,1);
    R.tW=(0:nT).'*P.h; R.W=zeros(nT+1,5);
    y=[P.x0;P.W0]; maxWeightDrift=0;
    C=P.controller; D=P.plant;

    for k=0:nStep
        t=k*P.h; row=k+1;
        nu=delta(:,floor(k/noiseStride)+1);
        x=y(1:2); W=y(3:7); xm=x+nu;
        [u,phi]=feedbackOutputF(xm,W,C);
        [a,d,f,g]=plantAccelerationF(t,x,u,D);
        R.X(row,:)=x.'; R.U(row)=u;
        R.Ustate(row)=feedbackOutputF(x,W,C);
        R.Noise(row,:)=nu.'; R.D(row)=d;
        R.Acceleration(row)=a; R.F(row)=f; R.G(row)=g;
        if k<=nT
            [em,~]=learningUpdateF(t,xm,W,phi,a,C,k<nT);
            R.E(row)=em; R.W(row,:)=W.';
        end
        if k==nT, R.Wfinal=W; end
        if k>=nT
            maxWeightDrift=max(maxWeightDrift,max(abs(W-R.Wfinal)));
        end
        if k==nStep, break; end

        learning=k<nT;
        if learning, nSub=round(P.h/P.hLearn); else, nSub=round(P.h/P.hPost); end
        hs=P.h/nSub;

        for j=0:nSub-1
            ts=t+j*hs;
            a1=closedLoopRHSF(ts,y,nu,C,D,learning);
            a2=closedLoopRHSF(ts+hs/2,y+hs*a1/2,nu,C,D,learning);
            a3=closedLoopRHSF(ts+hs/2,y+hs*a2/2,nu,C,D,learning);
            a4=closedLoopRHSF(ts+hs,y+hs*a3,nu,C,D,learning);
            y=y+(hs/6)*(a1+2*a2+2*a3+a4);
            if any(~isfinite(y)) || max(abs(y))>P.stopBound
                error('TEL:IntegrationFailure', ...
                    'Integration failed at t=%.9g s. No clipping was used.',ts+hs);
            end
        end
    end
    assert(maxWeightDrift==0,'TEL:Freeze','Weights changed after T.');
    R.P=P;
    R.UmeasurementNoise=R.U-R.Ustate;
    R.audit.learningLaw='dW=-eta*(phi*em+kappaBar*W); no extra tau^2 factor';
    R.audit.errorDefinition='em=tau^2*a+b1*xm1+b2*tau*xm2';
    R.audit.accelerationSignal='Exact simulated dx2/dt, including d; no extra sensor error';
    R.audit.explicitPlantFeedforward=false;
    R.audit.feedbackUsesNoisyStates=true;
    R.audit.maxWeightDriftAfterT=maxWeightDrift;
    R.audit.statistics='Raw 1-ms records; trapezoidal means/RMS; grid extrema';
    R.metrics.xAtT=R.X(nT+1,:);
    R.metrics.normXAtT=norm(R.metrics.xAtT);
    R.metrics.peakAbsU=max(abs(R.U));
    R.metrics.peakAbsW=max(abs(R.W(:)));
    R.metrics.maxWeightDriftAfterT=maxWeightDrift;
    R.metrics.post=windowStatisticsF(R,[P.metricStart,P.tEnd]);
    R.metrics.late=windowStatisticsF(R,[P.lateMetricStart,P.tEnd]);
    R.metrics.afterT=windowStatisticsF(R,[P.T,12]);
    R.metrics.shortInputInset=windowStatisticsF(R,[10,12]);
    R.metrics.longInset=windowStatisticsF(R,[P.tEnd-5,P.tEnd]);
    R.metrics.tailWindow=R.metrics.late.window;
    R.metrics.tailRMSX=R.metrics.late.rmsX;
    R.metrics.tailRMSU=R.metrics.late.rmsU;
    R.metrics.tailMaxAbsX=R.metrics.late.peakX;
    R.metrics.tailMaxAbsU=R.metrics.late.peakU;

    K=P.activation.slopeAtZero*(R.Wfinal.'*P.B);
    g0=1+P.plant.inputModulation;
    R.noiseSensitivity.K=K;
    R.Afrozen=[0,1;g0*K];
    R.eigFrozen=eig(R.Afrozen);
    R.noiseSensitivity.sampleMean=mean(delta,2).';
    R.noiseSensitivity.sampleStd=std(delta,0,2).';
    R.noiseSensitivity.sampleMaxAbs=max(abs(delta),[],2).';
    R.noiseSensitivity.sampleCorrelation=corrcoef(delta.');
    Z=erf(P.noiseCut/sqrt(2));
    density=exp(-P.noiseCut^2/2)/sqrt(2*pi);
    truncVariance=1-2*P.noiseCut*density/Z;
    R.noiseSensitivity.parentSigma=P.noiseSigma.';
    R.noiseSensitivity.theoreticalTruncatedStd=(P.noiseSigma*sqrt(truncVariance)).';
    R.noiseSensitivity.absoluteBound=(P.noiseCut*P.noiseSigma).';
    R.noiseSensitivity.linearizedDirectNoiseRMS= ...
        norm(K.*R.noiseSensitivity.sampleStd);
    assert(all(max(abs(delta),[],2)<=P.noiseCut*P.noiseSigma), ...
        'TEL:NoiseBound','Noise exceeded the prescribed truncation bounds.');
end

function [u,phi] = feedbackOutputF(xm,W,C)
    phi=activationFeaturesF(C.B*xm,C.activation);
    u=W.'*phi;
end

function [em,dW] = learningUpdateF(t,xm,W,phi,a,C,learning)
    tau=max(C.T-t,0);

    em=tau^2*a+C.b(1)*xm(1)+C.b(2)*tau*xm(2);
    if learning
        dW=-C.eta*(phi*em+C.kappaBar*W);
    else
        dW=zeros(5,1);
    end
end

function dy = closedLoopRHSF(t,y,nu,C,D,learning)
    x=y(1:2); W=y(3:7); xm=x+nu;
    [u,phi]=feedbackOutputF(xm,W,C);
    a=plantAccelerationF(t,x,u,D);
    [~,dW]=learningUpdateF(t,xm,W,phi,a,C,learning);
    dy=[x(2);a;dW];
end

function [a,d,f,g] = plantAccelerationF(t,x,u,D)
    f=D.quadratic*x(1)^2+D.cross*x(1)*x(2);
    g=1+D.inputModulation*cos(x(1));
    d=D.dAmp(1)*sin(D.dOmega(1)*t)+D.dAmp(2)*cos(D.dOmega(2)*t);
    a=f+g*u+d;
end

function phi = activationFeaturesF(z,A)
    v=A.gamma*z;
    fractional=v.*(v.^2+A.epsilon^2).^((A.alpha-1)/2);
    phi=(1-A.rho)*tanh(v)+A.rho*tanh(fractional);
end

function delta = boundedNoiseF(n,P)
    delta=zeros(2,n); state=double(P.seed);
    for j=1:n
        while true
            state=mod(16807*state,2147483647); u1=state/2147483647;
            state=mod(16807*state,2147483647); u2=state/2147483647;
            radius=sqrt(-2*log(u1));
            z=radius*[cos(2*pi*u2);sin(2*pi*u2)];
            if all(abs(z)<=P.noiseCut)
                delta(:,j)=P.noiseSigma.*z;
                break;
            end
        end
    end
end

function S = windowStatisticsF(R,window)
    rows=R.t>=window(1) & R.t<=window(2);
    tt=R.t(rows); duration=tt(end)-tt(1);
    assert(numel(tt)>=2 && duration>0);
    S.window=[tt(1),tt(end)];
    S.rmsX=sqrt(trapz(tt,R.X(rows,:).^2,1)/duration);
    S.rmsU=sqrt(trapz(tt,R.U(rows).^2)/duration);
    S.rmsD=sqrt(trapz(tt,R.D(rows).^2)/duration);
    S.rmsAcceleration=sqrt(trapz(tt,R.Acceleration(rows).^2)/duration);
    S.rmsDirectMeasurementNoise=sqrt(trapz(tt,R.UmeasurementNoise(rows).^2)/duration);
    S.meanU=trapz(tt,R.U(rows))/duration;
    S.meanD=trapz(tt,R.D(rows))/duration;
    S.meanAcceleration=trapz(tt,R.Acceleration(rows))/duration;
    S.rangeU=[min(R.U(rows)),max(R.U(rows))];
    S.rangeX=[min(R.X(rows,:),[],1);max(R.X(rows,:),[],1)];
    S.peakX=max(abs(R.X(rows,:)),[],1);
    S.peakU=max(abs(R.U(rows)));
    xx=R.X(rows,2);
    S.velocityChangeRate=(xx(end)-xx(1))/duration;
    S.accelerationBalanceResidual=S.meanAcceleration-S.velocityChangeRate;
end
