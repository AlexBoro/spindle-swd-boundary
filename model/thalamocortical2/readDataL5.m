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

%for i = [1 ,(5:5:120)]
for i = [1 ,(10:10:480)]
%for i = 241:2:360
%for i = 001:100
%for i = 101:200
%for i = 201:300
%for i = 301:400
%for i = 401:500
%for i = 501:600
    fileName = list(i).name;
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    if multiDisp
        n = length(A)/38;
        A = reshape(A,n,38)';
        t = A(1,:);
        vS = A(2,:);
        %iS = A(3,:);
        %NaPmS = A(3,:);
        %NaPmD = A(4,:);
        NaD = A(17,:);
        KD = A(22,:);
        CaD = A(29,:);
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
        plot(t*1e-3, vS, 'k')
        titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
        set(gcf,'name',titleStr)
        title(titleStr)
        xlabel('Time (s)')
        ylabel('Membrane potential (mV)')
        ylim([-100 50])
        legend('V_m')
        hold off
        %xlim([10 20])
        
        subplot(3,1,2)
        hold on
        plot(t*1e-3, NaD, 'r')
        plot(t*1e-3, CaD, 'g')
        plot(t*1e-3, KD, 'b')
%         plot(t*1e-3, NaiS, 'r')
%         plot(t*1e-3, NaiD, 'g')
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
%         %xlim([10 20])
        
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
        %xlim([10 20])
    else
        n = length(A)/2;
        A = reshape(A,n,2)';
        t = A(1,:);
        vS = A(2,:);
        
        % Plot membrane potential data:
        plot(t*1e-3, vS)
        titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
        set(gcf,'name',titleStr)
        title(titleStr)
        xlabel('Time (s)')
        ylabel('Membrane potential (mV)')
        ylim([-100 50])
        xlim([0 10])
    end
end

% abc = [0.25 0.5 0.5 0.5 1 0.5 0.25 0.5 0.5 0.25];
% efg = [0.25 0.75 0.75 0.75 2.25 0.5 0.25 0.5 0.5 0.25];
% plot(abc)
% hold on
% plot(efg, 'r')
% hold off