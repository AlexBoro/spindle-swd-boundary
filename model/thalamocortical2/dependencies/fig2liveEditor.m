function [figH, axes] = fig2liveEditor(fig, xLim, yLim, legendPosition, figSize, tight)
% [figH, axes] = fig2liveEditor(fig, xLim, yLim, legendPosition, figSize)
%
% Function converts a traditional matlab figure into a Live Editor figure.
% Input: fig - is either a figure handle or a figure filename.
%        xLim - x-axis limits (optional).
%        yLim - y-axis limits (optional).
%        legendPosition - legend position string (optional).
%        figSize - figure Size. Increase the size if axes labels don't fit.
%        tight - tight fit the figure and its labels if axes labels are cut
%                off. This property messes up legends if multiple figure
%                are displayed side by side.
%        figPos.
% Output figH - a figure handle of the Live Editor figure.
%        axes - an axes handle.

if nargin < 6
  tight = false;
end

if nargin < 5
  figSize = [];
end

if nargin < 4
  legendPosition = [];
end

if nargin < 3
  yLim = [];
end

if nargin < 2
  xLim = [];
end

if ischar(fig)
  fig = openfig(fig);
end

if ~isa(fig, 'matlab.ui.Figure')
  error('The supplied input is not a figure handle');
end

% Copy old figure to the new figure
figH = figure;
for child = 1:numel(fig.Children)
  if strcmp(fig.Children(child).Type,'axes')
    set(fig.Children(child), 'Parent',figH);
    axes = gca;
    remainingAxes = numel(fig.Children);
    if remainingAxes <= child
      break
    end
  end
end

% Adjust the new figure
if ~isempty(xLim)
  xlim(xLim);
end

if ~isempty(yLim)
  ylim(yLim);
end

if ~isempty(legendPosition)
  for child = 1:numel(figH.Children)
    if strcmp(figH.Children(child).Type,'legend')
      set(figH.Children(child), 'Location',legendPosition);
      break
    end
  end
end

if ~isempty(figSize)
  if numel(figSize) == 1
    figSize = [figSize figSize];
  end
  resizeFig(figH, gca, figSize(1), figSize(2), [0 0], [0 0], 0);
end

if tight
  figH = tightfig(figH);
end

if ischar(fig)
  close(fig);
end