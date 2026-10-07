clc
clear all %#ok<*CLALL>
close all

runs = 3;
meanUp = zeros(runs,1);
meanDown = meanUp;
meanUpL23 = meanUp;
meanDownL23 = meanUp;
meanUpL4 = meanUp;
meanDownL4 = meanUp;
meanUpL5 = meanUp;
meanDownL5 = meanUp;
meanUpL6 = meanUp;
meanDownL6 = meanUp;
meanUpL23PY = meanUp;
meanDownL23PY = meanUp;
meanUpL23IN = meanUp;
meanDownL23IN = meanUp;
meanUpL4PY = meanUp;
meanDownL4PY = meanUp;
meanUpL4IN = meanUp;
meanDownL4IN = meanUp;
meanUpL5PY = meanUp;
meanDownL5PY = meanUp;
meanUpL5IN = meanUp;
meanDownL5IN = meanUp;
meanUpL6PY = meanUp;
meanDownL6PY = meanUp;
meanUpL6IN = meanUp;
meanDownL6IN = meanUp;
meanUpPY = meanUp;
meanUpIN = meanUp;
meanUpL23RS = meanUp;
meanUpL23EF = meanUp;
meanUpL23IB = meanUp;
meanUpL4RS = meanUp;
meanUpL4IB = meanUp;
meanUpL5RS = meanUp;
meanUpL5EF = meanUp;
meanUpL5IB = meanUp;
meanUpL5RIB = meanUp;
meanUpL5SIB = meanUp;
meanUpL5ND = meanUp;
meanUpL6RS = meanUp;
meanUpL6EF = meanUp;
meanUpL6IB = meanUp;
meanUpRS = meanUp;
meanUpEF = meanUp;
meanUpIB = meanUp;
meanUpRIB = meanUp;
meanUpSIB = meanUp;
meanUpND = meanUp;
meanDownPY = meanUp;
meanDownIN = meanUp;
meanDownL23RS = meanUp;
meanDownL23EF = meanUp;
meanDownL23IB = meanUp;
meanDownL4RS = meanUp;
meanDownL4IB = meanUp;
meanDownL5RS = meanUp;
meanDownL5EF = meanUp;
meanDownL5IB = meanUp;
meanDownL5RIB = meanUp;
meanDownL5SIB = meanUp;
meanDownL5ND = meanUp;
meanDownL6RS = meanUp;
meanDownL6EF = meanUp;
meanDownL6IB = meanUp;
meanDownRS = meanUp;
meanDownEF = meanUp;
meanDownIB = meanUp;
meanDownRIB = meanUp;
meanDownSIB = meanUp;
meanDownND = meanUp;
for i = 1:runs
    fileName = ['up_state_parameters' num2str(i) '.dat'];
    up_state_parameters = load(fileName);
    meanUp(i) = up_state_parameters(1);
    meanDown(i) = up_state_parameters(2);
    meanUpL23(i) = up_state_parameters(3);
    meanDownL23(i) = up_state_parameters(4);
    meanUpL4(i) = up_state_parameters(5);
    meanDownL4(i) = up_state_parameters(6);
    meanUpL5(i) = up_state_parameters(7);
    meanDownL5(i) = up_state_parameters(8);
    meanUpL6(i) = up_state_parameters(9);
    meanDownL6(i) = up_state_parameters(10);
    meanUpL23PY(i) = up_state_parameters(11);
    meanDownL23PY(i) = up_state_parameters(12);
    meanUpL23IN(i) = up_state_parameters(13);
    meanDownL23IN(i) = up_state_parameters(14);
    meanUpL4PY(i) = up_state_parameters(15);
    meanDownL4PY(i) = up_state_parameters(16);
    meanUpL4IN(i) = up_state_parameters(17);
    meanDownL4IN(i) = up_state_parameters(18);
    meanUpL5PY(i) = up_state_parameters(19);
    meanDownL5PY(i) = up_state_parameters(20);
    meanUpL5IN(i) = up_state_parameters(21);
    meanDownL5IN(i) = up_state_parameters(22);
    meanUpL6PY(i) = up_state_parameters(23);
    meanDownL6PY(i) = up_state_parameters(24);
    meanUpL6IN(i) = up_state_parameters(25);
    meanDownL6IN(i) = up_state_parameters(26);
    meanUpPY(i) = up_state_parameters(27);
    meanUpIN(i) = up_state_parameters(28);
    meanUpL23RS(i) = up_state_parameters(29);
    meanUpL23EF(i) = up_state_parameters(30);
    meanUpL23IB(i) = up_state_parameters(31);
    meanUpL4RS(i) = up_state_parameters(32);
    meanUpL4IB(i) = up_state_parameters(33);
    meanUpL5RS(i) = up_state_parameters(34);
    meanUpL5EF(i) = up_state_parameters(35);
    meanUpL5IB(i) = up_state_parameters(36);
    meanUpL5RIB(i) = up_state_parameters(37);
    meanUpL5SIB(i) = up_state_parameters(38);
    meanUpL5ND(i) = up_state_parameters(39);
    meanUpL6RS(i) = up_state_parameters(40);
    meanUpL6EF(i) = up_state_parameters(41);
    meanUpL6IB(i) = up_state_parameters(42);
    meanUpRS(i) = up_state_parameters(43);
    meanUpEF(i) = up_state_parameters(44);
    meanUpIB(i) = up_state_parameters(45);
    meanUpRIB(i) = up_state_parameters(46);
    meanUpSIB(i) = up_state_parameters(47);
    meanUpND(i) = up_state_parameters(48);
    meanDownPY(i) = up_state_parameters(49);
    meanDownIN(i) = up_state_parameters(50);
    meanDownL23RS(i) = up_state_parameters(51);
    meanDownL23EF(i) = up_state_parameters(52);
    meanDownL23IB(i) = up_state_parameters(53);
    meanDownL4RS(i) = up_state_parameters(54);
    meanDownL4IB(i) = up_state_parameters(55);
    meanDownL5RS(i) = up_state_parameters(56);
    meanDownL5EF(i) = up_state_parameters(57);
    meanDownL5IB(i) = up_state_parameters(58);
    meanDownL5RIB(i) = up_state_parameters(59);
    meanDownL5SIB(i) = up_state_parameters(60);
    meanDownL5ND(i) = up_state_parameters(61);
    meanDownL6RS(i) = up_state_parameters(62);
    meanDownL6EF(i) = up_state_parameters(63);
    meanDownL6IB(i) = up_state_parameters(64);
    meanDownRS(i) = up_state_parameters(65);
    meanDownEF(i) = up_state_parameters(66);
    meanDownIB(i) = up_state_parameters(67);
    meanDownRIB(i) = up_state_parameters(68);
    meanDownSIB(i) = up_state_parameters(69);
    meanDownND(i) = up_state_parameters(70);
    if i == 3 
        fileName = ['up_state_parameters' num2str(i+3) '.dat'];
        up_state_parameters = load(fileName);
        meanDownL6IB(i) = up_state_parameters(64);
    end
end

f1 = figProperties('Up-state durations for different cortical cell types at different R_i levels', 'normalized', [0, .005, .97, .90], 'w', 'on');
hold on
gap1 = 1;
for i = 1:runs
    if meanUpRS(i)
        bar(0+i, meanUpRS(i), 'g');
    end
    if meanUpEF(i)
        bar(gap1+3+i, meanUpEF(i), 'b');
    end
    if meanUpIB(i)
        bar(2*gap1+6+i, meanUpIB(i), 'm');
    end
    if meanUpRIB(i)
        bar(3*gap1+9+i, meanUpRIB(i), 'r');
    end
    if meanUpND(i)
        bar(4*gap1+12+i, meanUpND(i), 'y');
    end
    if meanUpIN(i)
        bar(5*gap1+15+i, meanUpIN(i), 'c');
    end
end
gap2 = 3;
bar(4*gap1+20+gap2, mean(meanUpRS), 'g');
bar(4*gap1+21+gap2, mean(meanUpEF), 'b');
bar(4*gap1+22+gap2, mean(meanUpIB), 'm');
bar(4*gap1+23+gap2, mean(meanUpRIB), 'r');
bar(4*gap1+24+gap2, mean(meanUpND), 'y');
bar(4*gap1+25+gap2, mean(meanUpIN), 'c');
for i = 1:runs
    mean([meanUpRS(i) meanUpEF(i) meanUpIB(i) meanUpRIB(i) meanUpND(i) meanUpIN(i)])
    bar(4*gap1+25+2*gap2+i, mean([meanUpRS(i) meanUpEF(i) meanUpIB(i) meanUpRIB(i) meanUpND(i) meanUpIN(i)]), 'k');
end
hold off

ax1= axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 22, 4/3, 3, [0.01 0], 'out', 'on', 'k', {}, [],...
    [2 gap1+5 2*gap1+8 3*gap1+11 4*gap1+14 5*gap1+17 4*gap1+20+gap2 4*gap1+21+gap2 4*gap1+22+gap2 4*gap1+23+gap2 4*gap1+24+gap2 4*gap1+25+gap2 4*gap1+25+2*gap2+1 4*gap1+25+2*gap2+2 4*gap1+25+2*gap2+3], 'on', 'k', {'Duration (ms)'}, [150 420], [150 285 420]);
ax1.XTickLabel = {'RS','EF','IB','RIB','ND','FS',   'RS','EF','IB','RIB','ND','FS',   'R_{I1}','R_{I2}','R_{I3}','R_{I4}'};
ax1.XTickLabelRotation = 90;
paperSize = resizeFig(f1, ax1, 3*15, (3*15)/(161.9/17.712), [3.55 0.55], [-1.25 0.4], 0);
%paperSize = resizeFig(f1, ax1, 2.5*15, 7.5, [3.55 0.55], [-1.25 0.4], 0);
exportFig(f1, ['durations_up' '.tif'],'-dtiffnocompression','-r300', paperSize);

f2 = figProperties('Down-state durations for different cortical cell types at different R_i levels', 'normalized', [0, .005, .97, .90], 'w', 'on');
hold on
for i = 1:runs
    if meanDownRS(i)
        bar(0+i, meanDownRS(i), 'g');
    end
    if meanDownEF(i)
        bar(gap1+3+i, meanDownEF(i), 'b');
    end
    if meanDownIB(i)
        bar(2*gap1+6+i, meanDownIB(i), 'm');
    end
    if meanDownRIB(i)
        bar(3*gap1+9+i, meanDownRIB(i), 'r');
    end
    if meanDownND(i)
        bar(4*gap1+12+i, meanDownND(i), 'y');
    end
    if meanDownIN(i)
        bar(5*gap1+15+i, meanDownIN(i), 'c');
    end
end
bar(4*gap1+20+gap2, mean(meanDownRS), 'g');
bar(4*gap1+21+gap2, mean(meanDownEF), 'b');
bar(4*gap1+22+gap2, mean(meanDownIB), 'm');
bar(4*gap1+23+gap2, mean(meanDownRIB), 'r');
bar(4*gap1+24+gap2, mean(meanDownND), 'y');
bar(4*gap1+25+gap2, mean(meanDownIN), 'c');
for i = 1:runs
    mean([meanDownRS(i) meanDownEF(i) meanDownIB(i) meanDownRIB(i) meanDownND(i) meanDownIN(i)])
    bar(4*gap1+25+2*gap2+i, mean([meanDownRS(i) meanDownEF(i) meanDownIB(i) meanDownRIB(i) meanDownND(i) meanDownIN(i)]), 'k');
end
hold off

ax2= axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 22, 4/3, 3, [0.01 0], 'out', 'on', 'k', {}, [],...
    [2 gap1+5 2*gap1+8 3*gap1+11 4*gap1+14 5*gap1+17 4*gap1+20+gap2 4*gap1+21+gap2 4*gap1+22+gap2 4*gap1+23+gap2 4*gap1+24+gap2 4*gap1+25+gap2 4*gap1+25+2*gap2+1 4*gap1+25+2*gap2+2 4*gap1+25+2*gap2+3], 'on', 'k', {'Duration (ms)'}, [200 1300], [200 750 1300]);
ax2.XTickLabel = {'\fontsize{36}RS','\fontsize{34}EF','\fontsize{34}IB','\fontsize{34}RIB','\fontsize{34}ND','\fontsize{34}FS',   '\fontsize{34}RS','\fontsize{34}EF','\fontsize{34}IB','\fontsize{34}RIB','\fontsize{34}ND','\fontsize{34}FS',   '\fontsize{34}R\fontsize{16}I(C)','\fontsize{34}R\fontsize{16}I(F)','\fontsize{34}R\fontsize{16}I(I)'};
ax2.XTickLabelRotation = 90;
paperSize = resizeFig(f2, ax2, 3*15, (3*15)/(161.9/17.712), [3.55 2.25], [-1.25 0.4], 0);
%paperSize = resizeFig(f2, ax2, 2.5*15, 7.5, [3.55 2.4], [-1.25 0.4], 0);
exportFig(f2, ['durations_down' '.tif'],'-dtiffnocompression','-r300', paperSize);
