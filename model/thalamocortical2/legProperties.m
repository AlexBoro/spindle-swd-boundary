function l = legProperties(legStr, boxStr, legFont, width, locStr)
if ~isempty(legStr)
    l = legend(legStr, 'Box', boxStr, 'FontSize', legFont, 'LineWidth', width, 'Location', locStr);
    position = get(l, 'Position');
    %position(2) = position(2) + 0.03;
    %position(2) = position(2) + 0.02;
    %position(2) = position(2) + 0.01;
    set(l, 'Position', position);
end