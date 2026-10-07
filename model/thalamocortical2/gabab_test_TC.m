% nb = 8
n = 1:12;
data01 = 0;
data02 = 0;
data03 = 0;
data04 = 0.01;
data05 = 0.1;
data06 = 0.35;
data07 = 0.71; %4.9115 at GABAfullsyn.gbar_b = 10*6*9*8.87*0.61
data08 = 1.3;
data09 = 2;
data10 = 2.8;
data11 = 3.45;
data12 = 4.2;
data = 7.5*[data01 data02 data03 data04 data05 data06 data07 data08 data09 data10 data11 data12];
plot(n,data)
hold on

% nb = 12
n = 1:10;
data01 = 0;
data02 = 0;
data03 = 0;
data04 = 0.0053;
data05 = 0.1782;
data06 = 0.80;
data07 = 2.1; % 5.0952 at GABAfullsyn.gbar_b = 500*6*9*8.87*0.61
data08 = 4.1151;
data09 = 6.4612;
data10 = 8.22;
data = 2.5*[data01 data02 data03 data04 data05 data06 data07 data08 data09 data10];
plot(n,data)

% nb = 16, GABAfullsyn.gbar_b = 23000*6*9*8.87*0.61
n = 1:10;
data01 = 0;
data02 = 0;
data03 = 0;
data04 = 0.002;
data05 = 0.2719;
data06 = 1.7446;
data07 = 5.04;
data08 = 8.6681;
data09 = 10.7618;
data10 = 11.5324;
data = [data01 data02 data03 data04 data05 data06 data07 data08 data09 data10];
plot(n,data)

% nb = 8, KD = 10
n = 1:10;
data01 = 0;
data02 = 0;
data03 = 0.0426;
data04 = 0.4092;
data05 = 1.3957;
data06 = 3.0277;
data07 = 5.0182;
data08 = 6.7182;
data09 = 8.2361;
data10 = 9.2367;
data = [data01 data02 data03 data04 data05 data06 data07 data08 data09 data10];
plot(n,data)

% nb = 12, KD = 0.000042, GABAfullsyn.gbar_b = 0.61
n = 1:10;
data01 = 0;
data02 = 0;
data03 = 0.;
data04 = 0.076;
data05 = 0.6675;
data06 = 2.3438;
data07 = 5.0057;
data08 = 7.7;
data09 = 9.535;
data10 = 11.4694;
data = [data01 data02 data03 data04 data05 data06 data07 data08 data09 data10];
plot(n,data)
hold off

% SWDs: 5-8 spikes per burst in NRT
% Spindles: 3-5 spikes per burst in NRT