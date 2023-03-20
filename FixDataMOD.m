function [data, t, a] = FixDataMOD(data)

w = 4;                                                                      % mod
data = [data(1) * ones(w, 1); data];                                        % mod

d = data;

n = numel(data);

tttt = [0 : 0.5 : (n - w  - 1) / 2]';

plot(tttt, data(w + 1 : end), 'b*');
hold on 
a = gca();

a.XAxis.Label.String = 'Time (hours)';
a.YAxis.Label.String = 'Angle (degrees)';
a.YLim = [-135, 135];
a.XLim = [0, 24];

for i = 2 : n
    
    delta = data(i) - data(i - 1);
    
    if delta < -90
        
        data(i) = 180 + data(i);
        
    
    elseif delta > 90
        
        data(i) = -90 - (90 - data(i));
        
    end
    
end



plot(tttt, data(w + 1 : end), 'r', 'LineWidth', 1);

[d, data];









L = n;
B = @(a, x) (a(1)-a(2))./(1+exp((x-a(3))/a(4)))+a(2);
%a(1): Initial value, a(2): final value, a(3): center, a(4): time constant
% options = optimset('MaxIter',80000, 'MaxFunEvals',80000,...
%     'TolX', 1e-20, 'TolFun', 1e-20,...
%     'Algorithm', 'levenberg-marquardt'); %fitting optionn

time = [1:n];

options = optimset('TolX', 1e-12, 'TolFun', 1e-20, 'MaxFunEvals', 1000);

a0 = [data(1) data(L) round(n/2) 1]';

time = time';

[a, resnorm, residual] = lsqcurvefit(B, a0, time, data, [], [], options); 

% good
fit = B(a, time);

yresid = data - fit;
   SSresid = sum(yresid.^2);
   SStotal = (length(data)-1) * var(data);
   rsq = 1 - SSresid/SStotal;

% data for plotting
%time_fit=(time(1):0.05:time(end))';
time_fit = time;
angle_g_fit=B(a, time_fit);


%plot(fit, 'k');






% fit

rsq



if rsq > 0.8
    
    T.angle_g_initial(:) = data(1); % initial angle
    % [Y, Final_Loc]=min(abs(angle_g_fit-a(2))); % finding when rotation stops
    Final_Loc=find(abs(fit-a(2))<1.0,1,'first');

    if isempty(Final_Loc) == 1
    
        Final_Loc = length(fit);
    
    else
        
    
    end

    T.angle_g_final(:)=angle_g_fit(Final_Loc); % final angle
    T.angle_differenc(:)=abs(angle_g_fit(Final_Loc)-data(1));
    T.stop_time(:)=time_fit(Final_Loc); %Stop time (hours)
    % T.rotation_speed(:)=(a(2)-a(1))/(4*a(4)); % rotation speed (deg/hour)
    T.rotation_speed(:)=(angle_g_fit(Final_Loc)-data(1))...
        /(time_fit(Final_Loc)); % rotation speed (deg/hour)

else
    
    T.angle_g_initial(:)=data(1);  % initial angle
    Final_Loc=nan;
    T.angle_g_final(:)=data(L); % final angle
    T.angle_differenc(:)=0;
    T.stop_time(:)=0; %Stop time (hours)
    T.rotation_speed(:)=0; % rotation speed (deg/hour)
    
end







plot(tttt, angle_g_fit(w + 1 : end), 'k')

Final_Loc

if isnan(Final_Loc) == 1
    
    t = nan;
    a = nan;
    
else
    plot((Final_Loc - w - 1) / 2, angle_g_fit(Final_Loc), 'k+', 'MarkerSize', 64, 'LineWidth',2)

    t = (time_fit(Final_Loc) - 1) * 0.5 - w * 0.5;                          % mod
    a = angle_g_fit(Final_Loc);
    
end




fprintf("Final Time  (hours)   = %1.3f\n", t);
fprintf("Final Angle (degrees) = %1.3f\n", a);


data = data(w + 1 : end);


end

