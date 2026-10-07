function f = arrangeImages(titleStr, layout, margin, inHorMargin, inVertMargin, horSpacing, vertSpacing, imH, axesShape, ratio)
f = figProperties(titleStr, 'normalized', [0, .005, .97, .90], 'w', 'on');
horMargin = margin + inHorMargin;
vertMargin = margin + inVertMargin;
if strcmp('landscape', layout)
    paperWidth = 29.7;
    paperHeight = 21.0;
elseif strcmp('portrait', layout)
    paperWidth = 21.0;
    paperHeight = 29.7;
end

horSpace = paperWidth-2*horMargin-(size(imH,2)-1)*horSpacing;
vertSpace = paperHeight-2*vertMargin-(size(imH,1)-1)*vertSpacing;
if strcmp('fill', axesShape)
    width = horSpace/size(imH,2);
    height = vertSpace/size(imH,1);
elseif strcmp('custom', axesShape)
    width = ratio(1);
    height = ratio(2);
elseif strcmp('rectangle', axesShape)
    if (ratio(1)*size(imH,2))/(ratio(2)*size(imH,1)) >= horSpace/vertSpace
        width = horSpace/size(imH,2);
        height = (ratio(2)/ratio(1))*width;
        vertMargin = vertMargin + (vertSpace - horSpace);
    else
        height = vertSpace/size(imH,1);
        width = (ratio(1)/ratio(2))*height;
    end
end

count = 1;
for row = 1:size(imH,1)
    for column = 1:size(imH,2)
        left = horMargin + (column-1)*(width+horSpacing);
        bottom = vertMargin + (size(imH,1)-row)*(height+vertSpacing);
        position = [left bottom width height];
        subplot(3,3,count)
        axesProperties({}, 1, 'normal', 'off', 'w', 15, 2, 2, [0 0], 'out', 'off', 'w', {}, [], [], 'off', 'w', {}, [], []);
        set(gca, 'Units', 'centimeters', 'Position', position);
        imshow(imH{row,column})
        count = count + 1;
    end
end