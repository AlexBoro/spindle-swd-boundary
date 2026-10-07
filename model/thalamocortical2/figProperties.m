function f = figProperties(titleStr, units, pos, col, visible)
f = figure('Units', units, 'Position', pos);
f.Name = titleStr;
f.Color = col;
f.Visible = visible;