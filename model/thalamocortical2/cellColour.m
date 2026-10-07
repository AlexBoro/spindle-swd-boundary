function colourCode = cellColour(cellStr)

if strcmpi(cellStr, 'Cx23')
    colourCode = [255 225 0]/255; %[255 255 0]./255; % yellow
elseif strcmpi(cellStr, 'Cx23i')
    colourCode = [255 255 100]./255; % light yellow
elseif strcmpi(cellStr, 'Cx4')
    colourCode = [255 90 0]./255; % red orange
elseif strcmpi(cellStr, 'Cx4i')
    colourCode = [255 165 0]./255; % orange
elseif strcmpi(cellStr, 'Cx5')
    colourCode = [220 20 60]./255; %[255 0 0]./255; % red
elseif strcmpi(cellStr, 'Cx5i')
    colourCode = [254 184 198]./255; %[173 153 173]./255; % pink
elseif strcmpi(cellStr, 'Cx6')
    colourCode = [181 101 29]./255; % brown
elseif strcmpi(cellStr, 'Cx6i')
    colourCode = [222 184 135]./255; % light brown
elseif strcmpi(cellStr, 'TC') || strcmpi(cellStr, 'TCFO') || strcmpi(cellStr, 'TC_FO')
    colourCode = [0 152 255]./255; % light blue
elseif strcmpi(cellStr, 'TC2') || strcmpi(cellStr, 'TCHO') || strcmpi(cellStr, 'TC_HO')
    colourCode = [0 0 255]./255; % dark blue
elseif strcmpi(cellStr, 'NRT') || strcmpi(cellStr, 'NRTFO') || strcmpi(cellStr, 'NRT_FO')
    colourCode = [0 232 70]./255; % light green
elseif strcmpi(cellStr, 'NRT2') || strcmpi(cellStr, 'NRTHO') || strcmpi(cellStr, 'NRT_HO')
    colourCode = [0 132 70]./255; % dark green
end