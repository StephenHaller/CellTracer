function AnglePlotter(data, name, color)

close
clc

filename = sprintf('AnglePlot_%s.tif', name);

width = 3;
height = 3;

f = figure();
f.PaperUnits = 'inches';
f.PaperPosition = [0, 0, width, height];
f.Color = [1, 1, 1];
f.Units = 'inches';
f.Position = [4, 4, width, height];

a = axes();
a.FontName = 'Arial';
a.NextPlot = 'add';
a.XLim = [-1, 1];
a.YLim = [-1, 1];
a.DataAspectRatio = [1, 1, 1];
a.XAxis.Visible = 0;
a.YAxis.Visible = 0;
a.Clipping = 'off';

colormap(a, winter);
a.Colormap = color;



a1 = -0.25 * pi();
a2 = 1.25 * pi();


% plot circles
R = 0 : 0.25 : 1;
n = numel(R);
for i = 1 : n 
    r = R(i);    
    PlotCircle(r, a1, a2);   
end

% plot lines
T = a1 : pi() / 8 : a2;
n = numel(T);
for i = 1 : n   
    t = T(i);    
    PlotLine(t, 1);     
end


PlotText(-0.25 * pi(), 1, "+135");
PlotText(0, 1, "+90");
PlotText(0.25 * pi(), 1, "+45");
PlotText(0.50 * pi(), 1, "0");
PlotText(0.75 * pi(), 1, "-45");
PlotText(pi(), 1, "-90");
PlotText(1.25 * pi(), 1, "-135");

% plot data
% Blue -> Green
%data = sortrows(data);

data(:, 3) = data(:, 2) - data(:, 1);
data = sortrows(data, 3);




% fix coordinates
p_i = data > 0;
p_v = data(p_i);
p_v = 90 - p_v;

z_i = data == 0;
z_v = 90;

n_i = data < 0;
n_v = data(n_i);
n_v = 90 - n_v;

data(p_i) = p_v;
data(z_i) = z_v;
data(n_i) = n_v;

% convert to radians
data = data / 180 * pi();

n = size(data, 1);

for i = 1 : n

    %r = 0.75 * (i / n) + 0.25;
    r = i / n;
    
    PlotArc(data(i, 1), data(i, 2), r);
    
end
 


%
h = text(-1.25, -1.25, sprintf("'%s' | n = %d", name, size(data, 1)));
h.FontSize = 8;

% print
print(f, filename, '-painters', '-dtiffn', '-r600');

end

function h = PlotCircle(r, a1, a2)
        
	n = 512;

	theta = linspace(a1, a2, n);

	x = r * cos(theta);
  	y = r * sin(theta);

  	h = plot(x, y, 'k-');
    h.Color = [0.5, 0.5, 0.5];
  	h.LineWidth = 0.5;

end
    
function h = PlotLine(theta, r)
        
 	x = [0, r * cos(theta)];
 	y = [0, r * sin(theta)];
        
	h = plot(x, y, 'k-');
  	h.Color = [0.5, 0.5, 0.5];
    h.LineWidth = 0.5;
        
end  

function h = PlotText(theta, r, str)
        
 	h = text(0, 0, str);
    h.FontSize = 8;
    
    data = h.Extent;
    
    width = data(3);

    offset = 0.1;
    
 	x = (r + offset) * cos(theta) - width / 2;
	y = (r + offset) * sin(theta);

    h.Position = [x, y, 0];

end

function h = PlotArc(a1, a2, r)
        
    n = 64;       
   	a = linspace(a1, a2, n);
    c = linspace(0, 1, n);
    
    x = r * cos(a);
    y = r * sin(a);   
    
    h = patch([x, nan], [y, nan], [c, nan], 'EdgeColor', 'interp');
    
    h.LineWidth = 0.5;
    
    % triangle head
    theta = [-30, 90, 210];
    theta = theta / 180 * pi();
    x = cos(theta);
    y = sin(theta);
    
    v = [x; y; 1, 1, 1];
    
    % scale matrix
    s = 0.025;
    
    S = [s, 0, 0
         0, s, 0
         0, 0, 1];
    
     
    % translation matrix 
    dx = r * cos(a2);
    dy = r * sin(a2);
    
    T = [1, 0, dx
         0, 1, dy
         0, 0, 1];
     
    % rotation matrix
  
    if a1 > a2
        
        t = pi() - a2;
        
    else
        
        %t = a2 + pi() / 2;
        t = 2 * pi() - a2;
        
    end

    R = [ cos(t), sin(t), 0
         -sin(t), cos(t), 0
               0,      0, 1];
        
          
      
    v = T * R * S * v;
    
    v=v';
    
    h = patch(v(:, 1), v(:, 2), 1);
    h.LineStyle = 'none';    
 
end
