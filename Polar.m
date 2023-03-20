clc
close

a = axes();
a.NextPlot = 'add';

data
plot(data, 'bo-');

d = FixData(data);


plot(d, 'ro-');
