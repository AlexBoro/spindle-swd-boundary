% The script file plots voltage and current traces.

clc
close all
clear all
format long
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

multiDisp = 1;

for iFile = 0.0045:0.001:0.0045
    fileName = sprintf('TCdata0.000120_93.0_0.000019200_%1.4f.dat', iFile);
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    if multiDisp
        n = length(A)/46; %#ok<*UNRCH>
        A = reshape(A,n,46)';
        IVC = A(3,:);
        I = A(4,:);
        IKleak = A(5,:);
        INaleak = A(6,:);
        INa = A(7,:)*1e6*Area;
        INam = A(8,:);
        INah = A(9,:);
        IK = A(10,:)*1e6*Area;
        IKn = A(11,:);
        Cai = A(12,:)*1e6;
        ICa = A(13,:)*1e6*Area;
        ICam = A(14,:);
        ICah = A(15,:);
        Ih = A(16,:)*1e6*Area;
        Iho1 = A(17,:);
        Iho2 = A(18,:);
        Ihp1 = A(19,:);
        IAHP = A(20,:);
        IAHPm1 = A(21,:);
        IAHPm2 = A(22,:);
        ICAN = A(23,:)*1e6*Area;
        ICANp1 = A(24,:);
        ICANo = A(25,:);
        INaPm = A(26,:);
        IAm1 = A(27,:);
        IAm2 = A(28,:);
        IAh1 = A(29,:);
        IAh2 = A(30,:);
        IK1m = A(31,:);
        IK2m = A(32,:);
        IK2h1 = A(33,:);
        IK2h2 = A(34,:);
        IHVA = A(35,:)*1e6*Area;
        IHVAm = A(36,:);
        IAMPA = A(37,:);
        INMDA = A(38,:);
        ImGluR1a = A(39,:);
        ImGluR1aR = A(40,:);
        ImGluR1aG = A(41,:);
        IGABAa = A(42,:);
        IGABAb = A(43,:);
        IeGABAa = A(44,:);
        IeGABAa_R = A(45,:);
        IeGABAa_G = A(46,:);
    else
        n = length(A)/2;
        A = reshape(A,n,2)';
    end
        t = A(1,:);
        v = A(2,:);
    
    %Plot membrane potential data:
    f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    set(f1, 'Color', 'w');
    if multiDisp
        leftMargin = 0.03;
        bottomAntiMargin = 0.04;
        width = 0.3; %0.95;
        height = 0.15;
        xRange = [47 67];
        lineWidth = 3;
        
        % Vm:
        subplot(5,1,1) %#ok<*UNRCH>
        plot(t*1e-3, v, 'k', 'LineWidth', lineWidth)
        titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
        set(gcf,'name',titleStr)
        set(gca, 'box', 'off')
        set(gca, 'TickLength', [0 0])
        set(gca, 'LineWidth', lineWidth)
        ylabel('mV')
        yRange = [-85 0];
        ylim(yRange)
        set(gca, 'YTick', [-85 0]);
        set(gca, 'YAxisLocation', 'left');
        %set(gca, 'YColor', 'w');
        xlim(xRange);
        set(gca, 'XColor', 'w');
        p = get(gca, 'Position');
        p = [leftMargin p(2)-bottomAntiMargin width 0.23];
        set(gca, 'Position', p)

        % IT:
        subplot(5,1,2)
        plot(t*1e-3, ICa, 'k', 'LineWidth', lineWidth)
        set(gca, 'box', 'off')
        set(gca, 'TickLength', [0 0])
        set(gca, 'LineWidth', lineWidth)
        ylabel('nA')
        yRange = [-1.2 0];
        ylim(yRange)
        set(gca, 'YTick', yRange);
        set(gca, 'YAxisLocation', 'left');
        %set(gca, 'YColor', 'w');
        xlim(xRange);
        set(gca, 'XColor', 'w');
        p = get(gca, 'Position');
        p = [leftMargin p(2)-bottomAntiMargin width height];
        set(gca, 'Position', p)
        
        % ITwindow:
        subplot(5,1,3)
        %plot(t*1e-3, ICa*1000, 'k', 'LineWidth', lineWidth)
        plot(t*1e-3, IHVA*1000, 'k', 'LineWidth', lineWidth)
        set(gca, 'box', 'off')
        set(gca, 'TickLength', [0 0])
        set(gca, 'LineWidth', lineWidth)
        ylabel('pA')
        yRange = [-5 0];
        ylim(yRange)
        set(gca, 'YTick', yRange);
        set(gca, 'YAxisLocation', 'left');
        %set(gca, 'YColor', 'w');
        xlim(xRange);
        set(gca, 'XColor', 'w');
        p = get(gca, 'Position');
        p = [leftMargin p(2)-bottomAntiMargin width height];
        set(gca, 'Position', p)

        % ICAN:
        subplot(5,1,4)
        plot(t*1e-3, ICAN*1000, 'k', 'LineWidth', lineWidth)
        set(gca, 'box', 'off')
        set(gca, 'TickLength', [0 0])
        set(gca, 'LineWidth', lineWidth)
        ylabel('pA')
        yRange = [-10 0];
        ylim(yRange)
        set(gca, 'YTick', yRange);
        set(gca, 'YAxisLocation', 'left');
        %set(gca, 'YColor', 'w');
        xlim(xRange);
        set(gca, 'XColor', 'w');
        p = get(gca, 'Position');
        p = [leftMargin p(2)-bottomAntiMargin width height];
        set(gca, 'Position', p)
        
        % INaP:
        subplot(5,1,5)
        INaP = INaPm.*(v - 30)*0.00001612;
        plot(t*1e-3, INaP*1000, 'k', 'LineWidth', lineWidth)
        set(gca, 'box', 'off')
        set(gca, 'TickLength', [0 0])
        set(gca, 'LineWidth', lineWidth)
        ylabel('pA')
        yRange = [-1 0];
        ylim(yRange)
        set(gca, 'YTick', yRange);
        set(gca, 'YAxisLocation', 'left');
        %set(gca, 'YColor', 'w');
        xlabel('Time (s)')
        xlim(xRange);
        set(gca, 'XColor', 'w');
        p = get(gca, 'Position');
        p = [leftMargin p(2)-bottomAntiMargin width height];
        set(gca, 'Position', p)
    else
        plot(t*1e-3, v, 'k', 'LineWidth', 3)
        titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
        set(f1,'name',titleStr)
        title(titleStr)
        xlabel('Time (s)')
        ylabel('Membrane potential (mV)')
    end
end


set(gcf,'PaperUnits', 'normalized');
papersize = get(gcf, 'PaperSize');
myfiguresize = [0, 0, 2.65, 1];
set(gcf,'PaperPosition', myfiguresize);
%titleStr = sprintf('Membrane Potential Trace - file %s',fileName(1:end-4));
titleStr = sprintf('Membrane Potential Trace - file %s_gnbar_tau_h_min_itGHK05',fileName);
saveas(gcf, [titleStr '.fig'], 'fig');
print([titleStr '.tif'],'-dtiffnocompression','-r300');

% h = allchild(gcf);
% set (h(2), 'ylim', [-2.5 0])
% print(['Membrane Potential Trace - file TCdata0.000120_93.0_0.000019200_0.0045' '.tif'],'-dtiffnocompression','-r300');