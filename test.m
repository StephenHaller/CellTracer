clc
close all

f = figure();
a = axes;
a.YDir = 'reverse';
a.NextPlot = 'add';

a.XLim = [-4, 4];
a.YLim = [-4, 4];

n = Vect3(1, 0, 0);

o = Vect3(0, 0, 0);

v = Vect3.Normalize(Vect3(1, 100, 0));

% origin
h = o.Plot();
h.MarkerEdgeColor = 'k';
h.MarkerFaceColor = 'k';

% growth vector
h = Line(o, Vect3.Add(o, n)).Plot();
h.Color = 'k';

% plane
h = Line(o, Vect3.Add(o, v)).Plot();
h.Color = 'r';
h = Line(o, Vect3.Sub(o, v)).Plot();
h.Color = 'r';


t = v;

angle = acos(Vect3.Dot(Vect3.Normalize(n), Vect3.Normalize(t))) / pi() * 180;

c = Vect3.Normalize(Vect3.Cross(n, t));

angle = 90 - angle;

if c.z < 0
                   
    angle = -angle;
                    
end

angle
