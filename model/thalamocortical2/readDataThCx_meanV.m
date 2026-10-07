% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

multiDisp = 0;

list = dir('*dat');
% files = [1, 25, 50, 75, 100];
% for i = 1: size(files, 2)
%     fileName = list(files(i)).name;
% for i = 1:size(list, 1)

%iList = 616;
%iList = [(16:5:86),(116:5:136),(166:5:236),(266:5:286),(316:5:386),(416:5:436),(466:5:536),(566:5:586)];
%iList = [(16:10:86),(116:10:136),(166:10:236),(266:10:286),(316:10:386),(416:10:436),(466:10:536),(566:10:586)];
%iList = [(16:10:86),(116:10:136),(166:10:236),(266:10:286),(316:10:386),(416:10:436),(466:10:536),(566:10:586),(616:10:686),(716:10:786)];
%iList = [(616:20:686),(721:5:781)];
%iList = (621:20:681);
%iList = [(41:40:581),(621:20:681),(721:10:781)];
%iList = (721:20:781);
%iList = 001:040;
%iList = 001:100;
%iList = 101:200;
%iList = 201:300;
%iList = 301:400;
%iList = 401:500;
%iList = 501:600;
%iList = 601:700;
%iList = 701:800;
%iList = 1:20:800;
%iList = [(41:40:81),(161:40:241),(321:40:361),(481:40:521),(621:20:681),(721:20:781)];
iList = [(41:40:81),(161:40:241),(321:40:361),(481:40:521),(621:20:681),(821:20:881),(721:20:781),(921:20:981)];
%iList = 451:1:550;
%iList = [(471:20:531),(621:20:681),(721:20:781)];
%iList = [(21:20:81),(121:10:181)];
%iList = 701;

count = 0;
cellType = 'FS';
xLim = 0;
for i = iList
    fileName = list(i).name;
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    if multiDisp
        if strcmp(fileName(1:2), 'Cx')
            n = length(A)/40;
            A = reshape(A,n,40)';
            t = A(1,:);
            v = A(2,:);
            %iS = A(3,:);
            %NaPmS = A(3,:);
            %NaPmD = A(4,:);
            NaD = A(17,:);
            KD = A(22,:);
            CaD = A(29,:);
            CaiD = A(30,:);
            %hmD = A(34,:);
            NaiS = A(7,:);
            NaiD = A(18,:);
            AMPAD = A(35,:);
            NMDAD = A(36,:);
            GABAaS = A(37,:);
            GABAbS = A(38,:);

            % Plot membrane potential data:
            subplot(3,1,1) %#ok<*UNRCH>
            hold on
            plot(t*1e-3, v, 'k')
            titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
            set(gcf,'name',titleStr)
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Membrane potential (mV)')
            ylim([-100 50])
            legend('V_m')
            hold off
            if xLim
                xlim([0 10])
            end

            subplot(3,1,2)
            hold on
            plot(t*1e-3, NaD, 'r')
            plot(t*1e-3, CaD, 'g')
            plot(t*1e-3, KD, 'b')
            %plot(t*1e-3, NaiS, 'r')
            %plot(t*1e-3, NaiD, 'g')
            %plot(t*1e-3, CaiD, 'g')
            %plot(t*1e-3, hmD)
            titleStr = sprintf('Channel activation levels');
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Proportion of open channels')
            %ylim([0 1])
            %legend('I_N_a_(_P_)', 'I_h')
            legend('I_N_a', 'I_C_a', 'I_K')
            hold off
    %         subplot(3,1,2)
    %         hold on
    %         plot(t*1e-3, AMPAD+NMDAD+GABAaS+GABAbS, 'b')
    %         titleStr = sprintf('The Net synaptic current');
    %         title(titleStr)
    %         xlabel('Time (s)')
    %         ylabel('Current (nA)')
    %         legend('Net syn current')
    %         hold off
            if xLim
                xlim([0 10])
            end

            subplot(3,1,3)
            hold on
            plot(t*1e-3, AMPAD, 'g')
            plot(t*1e-3, NMDAD, 'm')
            %plot(t*1e-3, AMPAD+NMDAD, 'y')
            plot(t*1e-3, GABAaS, 'r')
            plot(t*1e-3, GABAbS, 'c')
            %plot(t*1e-3, GABAaS+GABAbS, 'b')
            titleStr = sprintf('Synaptic currents');
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Current (nA)')
            %legend('I_A_M_P_A', 'I_N_M_D_A', 'Excitatory', 'I_G_A_B_A_a', 'I_G_A_B_A_b', 'Inhibitory')
            legend('I_A_M_P_A', 'I_N_M_D_A', 'I_G_A_B_A_a', 'I_G_A_B_A_b')
            hold off
            if xLim
                xlim([0 10])
            end
        elseif strcmp(fileName(1:2), 'TC')
            n = length(A)/46;
            A = reshape(A,n,46)';
            t = A(1,:);
            v = A(2,:);
            %i = A(3,:);
            Na = A(7,:);
            K = A(10,:);
            Ca = A(13,:);
            Cai = A(12,:);
            h = A(16,:);
            ho1 = A(17,:);
            ho2 = A(18,:);
            hp1 = A(19,:);
            AMPA = A(37,:);
            NMDA = A(38,:);
            mGluR1a = A(39,:);
            GABAa = A(42,:);
            GABAb = A(43,:);
            eGABAa_R = A(45,:);
            eGABAa_Gn = A(46,:).^4 ./ (A(46,:).^4 + 0.0001);

            % Plot membrane potential data:
            subplot(3,1,1) %#ok<*UNRCH>
            hold on
            plot(t*1e-3, v, 'k')
            titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
            set(gcf,'name',titleStr)
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Membrane potential (mV)')
            ylim([-100 50])
            legend('V_m')
            hold off
            if xLim
                xlim([0 10])
            end

            subplot(3,1,2)
            hold on
            %plot(t*1e-3, Na, 'r')
            %plot(t*1e-3, Ca, 'g')
            %plot(t*1e-3, K, 'b')
            %plot(t*1e-3, Cai, 'g')
            %plot(t*1e-3, h, 'k')
            plot(t*1e-3, eGABAa_R,'r')
            plot(t*1e-3, eGABAa_Gn)
            titleStr = sprintf('Channel activation levels');
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Proportion of open channels')
            %legend('I_N_a', 'I_C_a', 'I_K')
            %legend('I_N_a', 'I_C_a', 'I_K', 'I_h')
            hold off
    %         subplot(3,1,2)
    %         hold on
    %         plot(t*1e-3, AMPA+NMDA+GABAa+GABAb, 'b')
    %         titleStr = sprintf('The Net synaptic current');
    %         title(titleStr)
    %         xlabel('Time (s)')
    %         ylabel('Current (nA)')
    %         legend('Net syn current')
    %         hold off
            if xLim
                xlim([0 10])
            end

            subplot(3,1,3)
            hold on
            plot(t*1e-3, AMPA, 'g')
            plot(t*1e-3, NMDA, 'm')
            %plot(t*1e-3, AMPA+NMDA, 'y')
            plot(t*1e-3, GABAa, 'r')
            plot(t*1e-3, GABAb, 'c')
            %plot(t*1e-3, GABAa+GABAb, 'b')
            %plot(t*1e-3, hp1, 'r')
            %plot(t*1e-3, ho1)
            %plot(t*1e-3, ho2, 'k')
            titleStr = sprintf('Synaptic currents');
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Current (nA)')
            %legend('I_A_M_P_A', 'I_N_M_D_A', 'Excitatory', 'I_G_A_B_A_a', 'I_G_A_B_A_b', 'Inhibitory')
            legend('I_A_M_P_A', 'I_N_M_D_A', 'I_G_A_B_A_a', 'I_G_A_B_A_b')
            %legend('p1', 'o1', 'o2')
            hold off
            if xLim
                xlim([0 10])
            end
        else
            n = length(A)/36;
            A = reshape(A,n,36)';
            t = A(1,:);
            v = A(2,:);
            %i = A(3,:);
            Na = A(7,:);
            K = A(10,:);
            Ca = A(13,:);
            Cai = A(12,:);
            h = A(16,:);
            hp1 = A(18,:);
            hh1 = A(19,:);
            IAHP = A(20,:);
            ICAN = A(23,:);
            Nai = A(27,:);
            AMPA = A(30,:);
            NMDA = A(31,:);
            mGluR1a = A(32,:);
            GABAa = A(35,:);
            gaps = A(36,:);

            % Plot membrane potential data:
            subplot(3,1,1) %#ok<*UNRCH>
            hold on
            plot(t*1e-3, v, 'k')
            titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
            set(gcf,'name',titleStr)
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Membrane potential (mV)')
            ylim([-100 50])
            legend('V_m')
            hold off
            if xLim
                xlim([0 10])
            end

            subplot(3,1,2)
            hold on
            %plot(t*1e-3, Na, 'r')
            %plot(t*1e-3, Ca, 'g')
            %plot(t*1e-3, K, 'b')
            %plot(t*1e-3, IAHP, 'r')
            %plot(t*1e-3, ICAN, 'c')
            plot(t*1e-3, Cai, 'g')
            %plot(t*1e-3, Nai, 'r')
            %plot(t*1e-3, gaps, 'g')
            %plot(t*1e-3, h)
            titleStr = sprintf('Channel activation levels');
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Proportion of open channels')
            legend('I_N_a', 'I_C_a', 'I_K')
            %legend('I_N_a', 'I_C_a', 'I_K', 'I_h')
            %legend('I_C_a', 'I_A_H_P', 'I_C_A_N', 'I_h')
            %legend('Ca^2^+_i')
            hold off
    %         subplot(3,1,2)
    %         hold on
    %         plot(t*1e-3, AMPA+NMDA+GABAa, 'b')
    %         titleStr = sprintf('The Net synaptic current');
    %         title(titleStr)
    %         xlabel('Time (s)')
    %         ylabel('Current (nA)')
    %         legend('Net syn current')
    %         hold off
            if xLim
                xlim([0 10])
            end

            subplot(3,1,3)
            hold on
            plot(t*1e-3, AMPA, 'g')
            plot(t*1e-3, NMDA, 'm')
            %plot(t*1e-3, AMPA+NMDA, 'y')
            plot(t*1e-3, GABAa, 'r')
            %plot(t*1e-3, GABAa, 'b')
            %plot(t*1e-3, hp1)
            %plot(t*1e-3, hh1, 'k')
            titleStr = sprintf('Synaptic currents');
            title(titleStr)
            xlabel('Time (s)')
            ylabel('Current (nA)')
            %legend('I_A_M_P_A', 'I_N_M_D_A', 'Excitatory', 'I_G_A_B_A_a')
            legend('I_A_M_P_A', 'I_N_M_D_A', 'I_G_A_B_A_a')
            hold off
            if xLim
                xlim([0 10])
            end
        end
    else
        n = length(A)/2;
        A = reshape(A,n,2)';
        t = A(1,:);
        v = A(2,:);
        
        % Plot membrane potential data:
        plot(t*1e-3, v)
        titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
        set(gcf,'name',titleStr)
        title(titleStr)
        xlabel('Time (s)')
        ylabel('Membrane potential (mV)')
        ylim([-100 50])
        if xLim
            xlim([0 10])
        end
    end
    
    % Resample:
    if i <= 600
        if i == iList(1)
            dt = 0.25;
            tt = t(1):0.25:t(end);
            vTot = zeros(length(iList),length(tt));
        end
        count = count + 1;
        [tunique, iunique] = unique(t);
        vv = interp1(tunique,v(iunique),tt);
        vTot(count,:) = vv;
    end
end

vMean = mean(vTot(1:count,:));
figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(tt*1e-3, vMean)
if xLim
    xlim([0 10])
end
