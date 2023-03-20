function PlotGenerator(path, name, poly)

% initialize figure and axes
a = gca();
f = figure();
copyobj(a, f);
a = f.CurrentAxes;

% X axis
x_min = 0.5;
x_max = 250.5;
dx = 1;

% Y axis
y_min = 0.5;
y_max = 250.5;
dy = 1;

% plot size
x = 6.0;                  % width (inches)
y = 6.0;                  % height (inches)
FontSize = 6;

% figure file name and path
filename = sprintf("%s%s", name, '_ext');
filepath = path;

% axis labels
xlabel = 'Strain (%)';
ylabel = 'Force (pN)';

% set values
f.PaperUnits = 'inches';
f.PaperPosition = [0, 0, x, y];
f.Color = [1, 1, 1];
f.Units = 'inches';
f.Position = [4, 4, x, y];

% axis properties
a.FontSize = FontSize;
a.FontName='Arial';
a.LineWidth = 0.5;
a.NextPlot = 'add';
a.TickDir = 'out';
a.Units = 'inches';
a.Position = [0, 0, x, y];

% X axis
a.XLim = [x_min, x_max];
a.XTick = (a.XLim(1) : dx : a.XLim(2));
a.XColor = [0, 0, 0];
a.XAxis.TickLabelFormat = '%5.0f';
%a.XAxis.Scale = 'log';

% Y axis
a.YLim = [y_min, y_max];
a.YTick = (a.YLim(1) : dy : a.YLim(2));
a.YColor = [0, 0, 0];
a.YAxis.TickLabelFormat = '%5.0f';
%a.YAxis.Scale = 'log';

% Xlabel
a.XLabel.String = xlabel;
a.XLabel.FontSize = FontSize;

% Ylabel
a.YLabel.String = ylabel;
a.YLabel.FontSize = FontSize;

%--------------------------------------------------------------------------
% plot polylineset data
%--------------------------------------------------------------------------




% save file
print(f, sprintf('%s\\%s.tif', filepath, filename), '-painters', '-dtiffn', '-r600');

end


