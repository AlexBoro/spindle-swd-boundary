function margins

clear all %#ok<CLALL>
clc

portrait = 1;
if portrait
    disp('Portrait');
    height = 297;
    width = 210;
    tMargin = 25.4;
    bMargin = 25.4;
    lMargin = 25.4;
    rMargin = 17.7;
else
    disp('Landscape');
    height = 210; %#ok<*UNRCH>
    width = 297;
    tMargin = 25.4;
    bMargin = 17.7;
    lMargin = 25.4;
    rMargin = 25.4;
end

lLabel = 8.167;
rLabel = 0; %8.167;

hSpacer = 1.25;
hlSpacer = 5;
hlSpacer2 = 10;
vSpacer = 1.25; %#ok<*NASGU>
vlSpacer = 10; %15; %5;

plan(1) = 1;
plan(2) = 2;
plan(3) = 1;
plan(4) = 2;
plan(5) = 1;
plan(6) = 2;
plan(7) = 1;
plan(8) = 2;
plan(9) = 1;
plan(10) = 2;
plan(11) = 3;
plan(12) = 2;
plan(13) = 3;

spacings{1} = 'wide';
spacings{2} = 'narrow';
spacings{3} = 'narrow';
spacings{4} = 'wide';
spacings{5} = 'narrow';
spacings{6} = 'wide';
spacings{7} = 'narrow';
spacings{8} = 'wide';
spacings{9} = 'narrow';
spacings{10} = 'wide2';
spacings{11} = 'wide';
spacings{12} = 'wide';
spacings{13} = 'wide';
spacings{14} = 'empty';



disp(' ');
disp('Horizontal lines');
hSpacingSize = 0;
for i = 1:size(spacings,2)
    if strcmp('narrow', spacings{i})
        hSpacingSize = hSpacingSize + hSpacer;
    elseif strcmp('wide', spacings{i})
        hSpacingSize = hSpacingSize + hlSpacer;
    elseif strcmp('wide2', spacings{i})
        hSpacingSize = hSpacingSize + hlSpacer2;
    end
end
vArea = height - tMargin - hSpacingSize - bMargin;

hBandSize = sum(plan);
hBandSize = vArea/hBandSize;

hl = height - tMargin;
count = 1;
disp(['hl ' num2str(count) ': ' num2str(hl)]);
for i = 1:size(plan,2)
    if strcmp('narrow', spacings{i})
        hl = hl - hSpacer;
    elseif strcmp('wide', spacings{i})
        hl = hl - hlSpacer;
    elseif strcmp('wide2', spacings{i})
        hl = hl - hlSpacer2;
    end
    if ~strcmp('empty', spacings{i})
        count = count + 1;
        disp(['hl ' num2str(count) ': ' num2str(hl)]);
    end
    hl = hl - hBandSize*plan(i);
    count = count + 1;
    disp(['hl ' num2str(count) ': ' num2str(hl)]);
end
if strcmp('narrow', spacings{i+1})
    hl = hl - hSpacer;
elseif strcmp('wide', spacings{i+1})
    hl = hl - hlSpacer;
elseif strcmp('wide2', spacings{i})
        hl = hl - hlSpacer2;
end
if ~strcmp('empty', spacings{i+1})
    count = count + 1;
    disp(['hl ' num2str(count) ': ' num2str(hl)]);
end



disp(' ');
disp('Vertical lines');
vSpacingSize = lLabel + rLabel;
hArea = width - lMargin - vSpacingSize - rMargin;

x2 = (hArea-vlSpacer)/2;
x3 = (hArea-2*vlSpacer)/3;
x4 = (hArea-3*vlSpacer)/4;
x8 = (hArea-3*vlSpacer)/8;

disp(['vl 1: ' num2str(lMargin) ' ' num2str(lMargin+lLabel) ' ' num2str(lMargin+lLabel+hArea) ' ' num2str(lMargin+lLabel+hArea+rLabel)]);
disp(['vl 2: ' num2str(lMargin) ' ' num2str(lMargin+lLabel) ' ' num2str(lMargin+lLabel+x2) ' ' num2str(lMargin+lLabel+x2+vlSpacer) ' ' num2str(lMargin+lLabel+hArea) ' ' num2str(lMargin+lLabel+hArea+rLabel)]);
disp(['vl 3: ' num2str(lMargin) ' ' num2str(lMargin+lLabel) ' ' num2str(lMargin+lLabel+x3) ' ' num2str(lMargin+lLabel+x3+vlSpacer) ' ' num2str(lMargin+lLabel+2*x3+vlSpacer) ' ' num2str(lMargin+lLabel+2*x3+2*vlSpacer) ' ' num2str(lMargin+lLabel+hArea) ' ' num2str(lMargin+lLabel+hArea+rLabel)]);
disp(['vl 4: ' num2str(lMargin) ' ' num2str(lMargin+lLabel) ' ' num2str(lMargin+lLabel+x4) ' ' num2str(lMargin+lLabel+x4+vlSpacer) ' ' num2str(lMargin+lLabel+x2) ' ' num2str(lMargin+lLabel+x2+vlSpacer) ' ' num2str(lMargin+lLabel+3*x4+2*vlSpacer) ' ' num2str(lMargin+lLabel+3*x4+3*vlSpacer) ' ' num2str(lMargin+lLabel+hArea) ' ' num2str(lMargin+lLabel+hArea+rLabel)]);
disp(['vl 5: ' num2str(lMargin) ' ' num2str(lMargin+lLabel) ' ' num2str(lMargin+lLabel+x8) ' ' num2str(lMargin+lLabel+x8+vlSpacer) ' ' num2str(lMargin+lLabel+x4) ' ' num2str(lMargin+lLabel+x4+vlSpacer) ' ' num2str(lMargin+lLabel+3*x8+2*vlSpacer) ' ' num2str(lMargin+lLabel+3*x8+3*vlSpacer) ' ' num2str(lMargin+lLabel+x2) ' ' num2str(lMargin+lLabel+x2+vlSpacer) ' ' num2str(lMargin+lLabel+5*x8+4*vlSpacer) ' ' num2str(lMargin+lLabel+5*x8+5*vlSpacer) ' ' num2str(lMargin+lLabel+3*x4+2*vlSpacer) ' ' num2str(lMargin+lLabel+3*x4+3*vlSpacer) ' ' num2str(lMargin+lLabel+7*x8+6*vlSpacer) ' ' num2str(lMargin+lLabel+7*x8+7*vlSpacer) ' ' num2str(lMargin+lLabel+hArea) ' ' num2str(lMargin+lLabel+hArea+rLabel)]);



disp(' ');
disp('Edges');
for i = 1:size(plan,2)-4
    y = hBandSize*plan(i);
    disp(['fig ' num2str(i) ': ' num2str(y) 'x' num2str(hArea)]);
end

y = hBandSize*plan(i+1);
disp(['fig ' num2str(i+1) ': ' num2str(y) 'x' num2str(x2)]);

y = hBandSize*plan(i+2);
disp(['fig ' num2str(i+2) ': ' num2str(y) 'x' num2str(x3) ' ' num2str(y) 'x' num2str(2*x3+vlSpacer)]);

y = hBandSize*plan(i+3);
disp(['fig ' num2str(i+3) ': ' num2str(y) 'x' num2str(x4) ' ' num2str(y) 'x' num2str(2*x4+vlSpacer)]);

y = hBandSize*plan(i+4);
disp(['fig ' num2str(i+4) ': ' num2str(y) 'x' num2str(x8) ' ' num2str(y) 'x' num2str(2*x8+vlSpacer)]);