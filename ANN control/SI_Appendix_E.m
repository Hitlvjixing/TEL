
clearvars; clc; close all;

%% 1. Simulation settings 
P.T          = 6;
P.tEnd       = 1000;
P.x0         = [-3; 2];
P.W0         = zeros(5,1);
P.q          = [8; 7];           % b1=56, b2=14; 
P.eta        = 400;
P.kappaBar   = 1e-3;
P.h          = 1e-3;             % raw recording interval
P.hLearn     = 2e-5;             % RK4 substep during learning
P.hPost      = 1e-3;             % RK4 substep after freezing
P.hNoise     = 1e-3;             % noise refresh and zero-order-hold interval
P.noiseSigma = [0.003; 0.003];    % PARENT Gaussian standard deviations
P.noiseCut   = 3;                
P.seed       = 20261011;
P.dAmp       = [0.15, 0.12];       
P.dPeriod    = [0.2, 0.3];       
P.dOmega     = 2*pi./P.dPeriod;  % rad/s

P.metricStart = 20;
P.lateMetricStart = 700;
P.stopBound   = 1e6;

P.activation.alpha = 0.7;
P.activation.rho = 0.3;
P.activation.epsilon = 0.1;
P.activation.gamma = 0.1;

%% 2. Construct coefficients
P = prepareSourceParameters(P);
selfCheckConstruction(P);
R = simulateSourceTEL(P);

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

%% 3. Figure 1: 0--12 s (2x2)
figure(1)
set (gcf,'unit','inches','position', [0.5 1 8 4.8]);

subplot('Position',[0.08,0.63,0.4,0.35]);
plot(R.t(is),R.X(is,1),'LineWidth',linewidth,'Color',color1); hold on;
xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,shortWindow]); ylim([-3.2,0.85]);
xlabel('time(s)','FontName','times new roman');
ylabel('$x_1$','interpreter','latex','FontName','times new roman');
annotation('textarrow', [0.3242, 0.2856], [0.8702, 0.9], ...
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
xlim([0,shortWindow]); ylim([-0.15,2.15]);
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
xlim([0,shortWindow]); ylim([-1.1,0.3]);
xlabel('time(s)','FontName','times new roman');
ylabel('$u$','interpreter','latex','FontName','times new roman',...
    'Units','Normalized',...       % 归一化单位，不受数据范围影响
    'Position',[-0.1137, 0.5, 0],...  % x=0.5（水平居中），y=1.02（坐标轴顶部上方）
    'HorizontalAlignment','center'); % 文字水平居中
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
xlim([0,shortWindow]); ylim([-5.1,6.5]);
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
axes('Position',[.2236 .6793 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t(is),R.X(is,1),'LineWidth',linewidth,'Color',color1); hold on;grid on;
xlim([2 8]);
ylim([-0.35 0.1]);
set(gca,'FontName','Times New Roman','FontSize',11);

axes('Position',[.7098 .7205 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t(is),R.X(is,2),'LineWidth',linewidth,'Color',color2); hold on;grid on;
xlim([2 8]);
ylim([-0.08 0.4]);
set(gca,'FontName','Times New Roman','FontSize',11);

%% 4. Figure 2: 0--1000 s (2x2)
figure(2)
set (gcf,'unit','inches','position', [0.5 1 8 4.8]);

subplot('Position',[0.08,0.63,0.4,0.35]);
plot(R.t,R.X(:,1),'LineWidth',linewidth,'Color',color1); hold on;
%xline(Tc,'Color', [0, 0, 0]/255,'linestyle','-.','linewidth',1.2);hold on;
xlim([0,P.tEnd]); ylim([-3.2,0.85]);
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
xlim([0,P.tEnd]); ylim([-0.15,2.15]);
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
xlim([0,P.tEnd]); ylim([-1.1,0.35]);
xlabel('time(s)','FontName','times new roman');
ylabel('$u$','interpreter','latex','FontName','times new roman',...
    'Units','Normalized',...       % 归一化单位，不受数据范围影响
    'Position',[-0.1137, 0.5, 0],...  % x=0.5（水平居中），y=1.02（坐标轴顶部上方）
    'HorizontalAlignment','center'); % 文字水平居中
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
xlim([0,P.tEnd]); ylim([-5.1,3]);
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
axes('Position',[.2236 .6793 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t,R.X(:,1),'LineWidth',linewidth,'Color',color1); hold on;grid on;
xlim([995 1000]);
ylim([-4.5e-4 5.5e-4]);
set(gca,'FontName','Times New Roman','FontSize',11);
ax = gca;% 获取当前坐标轴句柄
ax.XTick = [995,997.5,1000]; %修改刻度
ax.YTick = [-3e-4,0, 3e-4];

axes('Position',[.7098 .7205 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t,R.X(:,2),'LineWidth',linewidth,'Color',color2); hold on;grid on;
xlim([995 1000]);
ylim([-1.3e-2 1.3e-2]);
set(gca,'FontName','Times New Roman','FontSize',11);
ax = gca;% 获取当前坐标轴句柄
ax.XTick = [995,997.5,1000]; %修改刻度

axes('Position',[.2236 .2019 .226 .16],'Box','on');  %前两位左下角位置 后两位 宽度和高度
plot(R.t,R.U,'LineWidth',linewidth1,'Color',color3); hold on;grid on;
xlim([995 1000]);
ylim([-2.5e-2 2.5e-2]);
set(gca,'FontName','Times New Roman','FontSize',11);
ax = gca;% 获取当前坐标轴句柄
ax.XTick = [995,997.5,1000]; %修改刻度
% ax.YTick = [-3e-3,0, 3e-3];



%% Local functions
function P = prepareSourceParameters(P)
    P.q = P.q(:);
    assert(numel(P.q)==2 && all(isfinite(P.q)) && ...
        all(P.q==round(P.q)) && P.q(1)>P.q(2) && P.q(2)>2, ...
        'TEL:Exponents','Require distinct integer exponents q1>q2>2.');
    assert(P.T>0 && P.tEnd>P.T && P.eta>0 && P.kappaBar>0);
    assert(isequal(size(P.x0),[2,1]) && isequal(size(P.W0),[5,1]));
    assert(all(isfinite([P.x0;P.W0;P.q])));

    Q = [ones(2,1),-P.q];
    qbar2 = P.q.*(P.q-1);
    P.b = Q\(-qbar2);
    expected = [prod(P.q);sum(P.q)-1];
    assert(norm(P.b-expected,inf)<1e-10, ...
        'TEL:CoefficientConstruction','Q-based and polynomial-based gains disagree.');
    P.charPolynomial = [1,-(P.b(2)+1),P.b(1)];
    P.charRoots = roots(P.charPolynomial);
    assert(norm(sort(P.charRoots)-sort(P.q),inf)<1e-9);

    % The five zero-bias feature directions are retained.
    P.B = [1,0;0,1;1,1;2,0;0,2];
    A=P.activation;
    assert(all(isfinite([A.alpha,A.rho,A.epsilon,A.gamma])) && ...
        A.alpha>0 && A.alpha<1 && A.rho>=0 && A.rho<=1 && ...
        A.epsilon>0 && A.gamma>0,'TEL:Activation','Invalid activation settings.');
    P.activation.slopeAtZero=A.gamma*((1-A.rho)+A.rho*A.epsilon^(A.alpha-1));

    % a_i: x1^ideal(t)=sum a_i*(T-t)^q_i.
    % x1^ideal=sum c_i*r^q_i, c_i=a_i*T^q_i.
    V0 = [ones(1,2);-P.q.'/P.T];
    c = V0\P.x0;
    a = c./(P.T.^P.q);
    P.construction.q = P.q;
    P.construction.Q = Q;
    P.construction.qbar2 = qbar2;
    P.construction.b = P.b;
    P.construction.normalizedModalCoefficients = c;
    P.construction.a = a;
    P.construction.initialStateResidual = V0*c-P.x0;
    P.construction.coefficientResidual = Q*P.b+qbar2;
    uNN0 = P.W0.'*activationFeatures(P.B*P.x0,P.activation);
    uIdeal0 = -(P.b(1)*P.x0(1)+P.b(2)*P.T*P.x0(2))/P.T^2;
    P.construction.uNN0WithoutNoise = uNN0;
    P.construction.uIdeal0 = uIdeal0;
    P.construction.initialNominalTELError = P.T^2*(uNN0-uIdeal0);

    assert(all(isfinite([P.T,P.tEnd,P.eta,P.kappaBar,P.h,P.hLearn, ...
        P.hPost,P.hNoise,P.noiseCut,P.metricStart,P.stopBound])));
    assert(P.h>0 && P.hLearn>0 && P.hPost>0 && P.hNoise>0);
    assert(P.noiseCut>0 && P.stopBound>0 && P.metricStart>=P.T && P.metricStart<P.tEnd);
    assert(isequal(size(P.noiseSigma),[2,1]) && ...
        all(isfinite(P.noiseSigma)) && all(P.noiseSigma>=0));
    assert(numel(P.dAmp)==2 && numel(P.dOmega)==2 && ...
        all(isfinite([P.dAmp(:);P.dOmega(:)])));
    assert(numel(P.dPeriod)==2 && all(isfinite(P.dPeriod)) && all(P.dPeriod>0));
    assert(norm(P.dOmega-2*pi./P.dPeriod,inf)<1e-12, ...
        'TEL:DisturbancePeriod','Set dPeriod; dOmega must equal 2*pi./dPeriod.');
    assert(P.seed>=1 && P.seed<2147483647 && P.seed==round(P.seed));
    ratio = [P.T/P.h,P.tEnd/P.h,P.hNoise/P.h,P.h/P.hLearn,P.h/P.hPost, ...
        P.metricStart/P.h];
    assert(all(ratio>=1) && all(abs(ratio-round(ratio))<1e-7), ...
        'TEL:TimeGrid','T,tEnd,metricStart,hNoise align with h; hLearn,hPost divide h.');

    % Controller receives only this structure
    P.controller.T = P.T;
    P.controller.b = P.b;
    P.controller.B = P.B;
    P.controller.activation = P.activation;
    P.controller.eta = P.eta;
    P.controller.kappaBar = P.kappaBar;
    P.plant.dAmp = P.dAmp;
    P.plant.dOmega = P.dOmega;
end

function selfCheckConstruction(P)
    pairs = [4,3;6,5;8,7]; targets = [12,6;30,10;56,14];
    for j=1:3
        q=pairs(j,:).'; b=[ones(2,1),-q]\(-q.*(q-1));
        assert(norm(b-targets(j,:).',inf)<1e-11);
    end
    assert(norm(P.construction.initialStateResidual,inf)<1e-11*max(1,norm(P.x0,inf)));
    assert(norm(P.construction.coefficientResidual,inf)<1e-10);
    xm=[0.21;-0.17]; W=[0.10;-0.20;0.30;-0.40;0.50]; t=0.37*P.T;
    [u,e,dW] = sourceController(t,xm,W,P.controller,true);
    phi=activationFeatures(P.B*xm,P.activation); tau=P.T-t;
    assert(abs(u-W.'*phi)<1e-12);
    assert(abs(e-(tau^2*u+P.b(1)*xm(1)+P.b(2)*tau*xm(2)))<1e-12);
    assert(norm(dW+P.eta*(phi*e+P.kappaBar*W),inf)<1e-10);
    [~,~,dWafter] = sourceController(P.T,xm,W,P.controller,false);
    assert(all(dWafter==0));
    assert(all(activationFeatures(zeros(5,1),P.activation)==0));
    z=[-3;-0.01;0;0.01;3];
    f=activationFeatures(z,P.activation);
    assert(max(abs(f+activationFeatures(-z,P.activation)))<1e-13);
    assert(all(abs(f)<=1));
    dz=1e-7;
    slope=(activationFeatures(dz,P.activation)- ...
        activationFeatures(-dz,P.activation))/(2*dz);
    assert(abs(slope-P.activation.slopeAtZero)<1e-6*max(1,abs(slope)));
    assert(P.lateMetricStart>=P.T && P.lateMetricStart<P.tEnd && ...
        abs(P.lateMetricStart/P.h-round(P.lateMetricStart/P.h))<1e-7);
end

function R = simulateSourceTEL(P)
    nStep=round(P.tEnd/P.h); nT=round(P.T/P.h);
    noiseStride=round(P.hNoise/P.h);
    delta=boundedNoise(floor(nStep/noiseStride)+1,P);
    R.t=(0:nStep).'*P.h;
    R.X=zeros(nStep+1,2); R.U=zeros(nStep+1,1);
    R.Ustate=zeros(nStep+1,1); % diagnostic evaluation
    R.E=nan(nStep+1,1); R.D=zeros(nStep+1,1);
    R.Noise=zeros(nStep+1,2); R.Wnorm=zeros(nStep+1,1);
    R.tW=(0:nT).'*P.h; R.W=zeros(nT+1,5);
    y=[P.x0;P.W0]; maxWeightDrift=0;

    for k=0:nStep
        t=k*P.h; row=k+1;
        dk=delta(:,floor(k/noiseStride)+1);
        xm=y(1:2)+dk;
        [u,em]=sourceController(t,xm,y(3:7),P.controller,k<nT);
        R.X(row,:)=y(1:2).'; R.U(row)=u;

        R.Ustate(row)=y(3:7).'*activationFeatures(P.B*y(1:2),P.activation);
        R.D(row)=plantDisturbance(t,P.plant);
        R.Noise(row,:)=dk.'; R.Wnorm(row)=norm(y(3:7));
        if k<=nT
            R.E(row)=em; R.W(row,:)=y(3:7).';
        end
        if k==nT, R.Wfinal=y(3:7); end
        if k>=nT, maxWeightDrift=max(maxWeightDrift,max(abs(y(3:7)-R.Wfinal))); end
        if k==nStep, break; end

        learn=k<nT;
        if learn, nSub=round(P.h/P.hLearn); else, nSub=round(P.h/P.hPost); end
        hs=P.h/nSub;
        for j=0:nSub-1
            ts=t+j*hs;
            a=sourceRHS(ts,y,dk,P.controller,P.plant,learn);
            b=sourceRHS(ts+hs/2,y+hs*a/2,dk,P.controller,P.plant,learn);
            c=sourceRHS(ts+hs/2,y+hs*b/2,dk,P.controller,P.plant,learn);
            d=sourceRHS(ts+hs,y+hs*c,dk,P.controller,P.plant,learn);
            y=y+(hs/6)*(a+2*b+2*c+d);
            if any(~isfinite(y)) || max(abs(y))>P.stopBound
                error('TEL:IntegrationFailure', ...
                    'Integration failed at t=%.9g s; reduce hLearn/hPost. No clipping used.',ts+hs);
            end
        end
    end

    assert(maxWeightDrift==0,'TEL:Freeze','Weights changed after T.');
    R.P=P;
    R.construction=P.construction;
    R.audit.learningLaw='NC Methods (26); five fixed smooth mixed features';
    R.audit.errorDefinition='NC (24): tau^2*u+b1*xm1+b2*tau*xm2';
    R.audit.disturbanceKnownToController=false;
    R.audit.aUsedByController=false;
    R.audit.maxWeightDriftAfterT=maxWeightDrift;
    R.audit.coefficientResidual=P.construction.coefficientResidual;
    R.audit.initialStateResidual=P.construction.initialStateResidual;
    R.audit.statistics='Raw record grid, trapezoidal RMS; not continuous-time extrema';

    R.metrics.xT=R.X(nT+1,:);
    R.metrics.normXT=norm(R.metrics.xT);
    R.metrics.peakAbsU=max(abs(R.U));
    R.metrics.maxPositiveX1=max(0,max(R.X(:,1)));
    ip=R.t>=P.metricStart; duration=R.t(end)-R.t(find(ip,1));
    R.metrics.postWindow=[P.metricStart,P.tEnd];
    R.metrics.rmsPostX=sqrt(trapz(R.t(ip),R.X(ip,:).^2,1)/duration);
    R.metrics.rmsPostU=sqrt(trapz(R.t(ip),R.U(ip).^2)/duration);
    R.metrics.peakPostX=max(abs(R.X(ip,:)),[],1);
    R.metrics.peakPostU=max(abs(R.U(ip)));
    R.metrics.rmsPostAcceleration=sqrt(trapz(R.t(ip),(R.U(ip)+R.D(ip)).^2)/duration);
    R.UmeasurementNoise=R.U-R.Ustate;
    il=R.t>=P.lateMetricStart;
    tl=R.t(il); dl=tl(end)-tl(1);
    R.metrics.lateWindow=[P.lateMetricStart,P.tEnd];
    R.metrics.rmsLateX=sqrt(trapz(tl,R.X(il,:).^2,1)/dl);
    R.metrics.peakLateX=max(abs(R.X(il,:)),[],1);
    R.metrics.rmsLateU=sqrt(trapz(tl,R.U(il).^2)/dl);
    R.metrics.rmsLateMeasurementNoise=sqrt(trapz(tl,R.UmeasurementNoise(il).^2)/dl);
    R.metrics.rmsLateAcceleration=sqrt(trapz(tl,(R.U(il)+R.D(il)).^2)/dl);
    R.metrics.peakAbsW=max(abs(R.W(:)));
    R.metrics.meanLateU=trapz(tl,R.U(il))/dl;
    R.metrics.meanLateD=trapz(tl,R.D(il))/dl;

    shortEnd=min(P.T+6,P.tEnd);
    insetStart=max(P.T,shortEnd-2);
    R.periodicAudit.short=recordWindowStatistics(R,[P.T,shortEnd]);
    R.periodicAudit.inputInset=recordWindowStatistics(R,[insetStart,shortEnd]);
    R.periodicAudit.periodSeconds=P.dPeriod;
    R.periodicAudit.frequencyHz=1./P.dPeriod;
    R.periodicAudit.angularFrequency=P.dOmega;
    R.periodicAudit.short.cycles=diff(R.periodicAudit.short.window)./P.dPeriod;
    R.periodicAudit.inputInset.cycles=diff(R.periodicAudit.inputInset.window)./P.dPeriod;

    K=P.activation.slopeAtZero*(R.Wfinal.'*P.B);
    R.Afrozen=[0,1;K]; R.eigFrozen=eig(R.Afrozen);
    R.noiseSensitivity.K=K;
    R.noiseSensitivity.parentSigma=P.noiseSigma.';
    R.noiseSensitivity.sampleStd=std(delta,0,2).';
    R.noiseSensitivity.sampleMean=mean(delta,2).';
    R.noiseSensitivity.sampleMaxAbs=max(abs(delta),[],2).';
    R.noiseSensitivity.sampleCorrelation=corrcoef(delta.');
    Z=erf(P.noiseCut/sqrt(2));
    normalDensity=exp(-P.noiseCut^2/2)/sqrt(2*pi);
    truncVariance=1-2*P.noiseCut*normalDensity/Z;
    R.noiseSensitivity.theoreticalTruncatedStd=(P.noiseSigma*sqrt(truncVariance)).';
    assert(all(max(abs(delta),[],2)<=P.noiseCut*P.noiseSigma), ...
        'TEL:NoiseBound','A noise sample lies outside its stated bound.');
    R.noiseSensitivity.absoluteBound=(P.noiseCut*P.noiseSigma).';
    R.noiseSensitivity.linearizedDirectNoiseRMS= ...
        norm(K.*R.noiseSensitivity.sampleStd);
end

function S=recordWindowStatistics(R,window)
    rows=R.t>=window(1) & R.t<=window(2);
    tt=R.t(rows); xx=R.X(rows,2);
    assert(numel(tt)>=2,'TEL:StatisticsWindow','Statistics need at least two records.');
    duration=tt(end)-tt(1);
    S.window=[tt(1),tt(end)];
    S.meanU=trapz(tt,R.U(rows))/duration;
    S.meanD=trapz(tt,R.D(rows))/duration;
    S.rangeU=[min(R.U(rows)),max(R.U(rows))];
    S.rangeD=[min(R.D(rows)),max(R.D(rows))];
    S.rmsU=sqrt(trapz(tt,R.U(rows).^2)/duration);
    S.rmsX=sqrt(trapz(tt,R.X(rows,:).^2,1)/duration);
    S.meanAcceleration=S.meanU+S.meanD;
    S.velocityChangeRate=(xx(end)-xx(1))/duration;
    S.balanceResidual=S.meanAcceleration-S.velocityChangeRate;
end

function [u,em,dW] = sourceController(t,xm,W,C,learning)
    phi=activationFeatures(C.B*xm,C.activation);
    u=W.'*phi;
    tau=max(C.T-t,0);
    em=tau^2*u+C.b(1)*xm(1)+C.b(2)*tau*xm(2);
    if nargout>2
        if learning
            dW=-C.eta*(phi*em+C.kappaBar*W);
        else
            dW=zeros(5,1);
        end
    end
end

function dy = sourceRHS(t,y,delta,C,D,learning)
    xm=y(1:2)+delta;
    [u,~,dW]=sourceController(t,xm,y(3:7),C,learning);
    dy=[y(2);u+plantDisturbance(t,D);dW];
end

function d = plantDisturbance(t,D)
    d=D.dAmp(1)*sin(D.dOmega(1)*t)+D.dAmp(2)*cos(D.dOmega(2)*t);
end

function delta = boundedNoise(n,P)
    delta=zeros(2,n); state=double(P.seed);
    for j=1:n
        while true
            state=mod(16807*state,2147483647); u1=state/2147483647;
            state=mod(16807*state,2147483647); u2=state/2147483647;
            r=sqrt(-2*log(u1)); z=r*[cos(2*pi*u2);sin(2*pi*u2)];
            if all(abs(z)<=P.noiseCut)
                delta(:,j)=P.noiseSigma.*z;
                break;
            end
        end
    end
end

function phi=activationFeatures(z,A)
    v=A.gamma*z;
    if A.rho==0
        phi=tanh(v);
    else
        fractional=v.*(v.^2+A.epsilon^2).^((A.alpha-1)/2);
        phi=(1-A.rho)*tanh(v)+A.rho*tanh(fractional);
    end
end

