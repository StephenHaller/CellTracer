fclose all
clc

file1 = './txt/final/Final_Angle.txt';
file2 = './txt/final/Final_AngleFixMOD.txt';

fid1 = fopen(file1, 'r');
fid2 = fopen(file2, 'w');

% header
str = fgetl(fid1);
fprintf(fid2, '%s%s\n', str, 'Fix');

% header
str = fgetl(fid1);
fprintf(fid2, '%s\n', str);

n = 12;

for i = 1 : n
    
    % space
    str = fgetl(fid1);
    fprintf(fid2, '%s\n', str);
    
    % calculating
    str = fgetl(fid1);
    fprintf(fid2, '%s\n', str);
    
    % name
    str = fgetl(fid1);
    fprintf(fid2, '%s\n', str);
    
    name = str;
    
    % ids
    str = fgetl(fid1);   
    fprintf(fid2, '%s\n', str);    
    str(1:12) = [];
    ids = sscanf(str, '%12d');

    m = numel(ids);
    
    % dashes
    str = fgetl(fid1);
    fprintf(fid2, '%s\n', str);  
    
    % initialize
    data = NaN(49, m);
    
    for j = 1 : 49
        
        % data
        str = fgetl(fid1);  
        str(1:12) = [];
        
        for k = 1 : m
 
            dstr = str(1:12);
            
            a = sscanf(dstr, '%12f');
            
            if ~isempty(a)      
                data(j, k) = a;
            end

            str(1:12) = [];
        
        end
    
    end
    
    % fix
    
    data_fix = nan(49, m);
    t_final = nan(1, m);
    a_final = nan(1, m);
    
    
    for j = 1 : m
        
        col = data(:, j);
        col = col(~isnan(col));

        [d, t, a] = FixDataMOD(col);

        %pause(1);
        
        %
        data_fix(1 : numel(col), j) = d;
        t_final(j) = t;
        a_final(j) = a;  
        
        
        a = gca();
        a.YLim = [-135, 135];
        pause(0.25);
        cla(a);
        
    end
    
    
    % write
    for j = 1 : 49
        
        t = 0.5 * (j - 1);
        
        fprintf(fid2, '%12.1f', t);
        
        for k = 1 : m
            
            angle = data_fix(j, k);
            
            if ~isnan(angle)
            
                fprintf(fid2, '%12.3f', angle);
                
            else
                
                fprintf(fid2, '%12s', ' ');
                
            end
            
        end
        
        fprintf(fid2, '\n');
    
    end
    
    fprintf(fid2, '\n');
    
    
    
    fprintf(fid2, '%12s', 'Time');
    for k = 1 : m
        fprintf(fid2, '%12.3f', t_final(k));
    end
    fprintf(fid2, '\n');
    
    
    
    fprintf(fid2, '%12s', 'Angle');
    for k = 1 : m
        fprintf(fid2, '%12.3f', a_final(k));
    end
    fprintf(fid2, '\n');
    
    % other
    fgetl(fid1);
    fgetl(fid1);
    fgetl(fid1);
    
    
    
    
    
    %
    
    %data_fix
    %a_final
    %t_final
    %name
    
    ssss = numel(a_final);
    
    dataf = zeros(2, ssss); 

    dataf(1, :) = data_fix(1, :);

    % only rotate
    %dataf(2, ~isnan(a_final)) = a_final(~isnan(a_final));
    %dataf(:, isnan(a_final)) = [];
    
    % only no rotate
    % get last
    for iiii = 1 : ssss
        
        dataf(2, iiii) = data_fix(find(~isnan(data_fix(:, iiii)) == 1, 1, 'last'), iiii);
        
    end
    
    % remove rotate
    %dataf(:, ~isnan(a_final)) = [];
    
    % fix rotate
    dataf(2, ~isnan(a_final)) = a_final(~isnan(a_final));
    
    mask = zeros(1, ssss);
    
    mask(~isnan(a_final)) = 1;
    mask(isnan(a_final)) = 2;
   
    color = [0, 0, 1; 1, 0, 0];
    
    dataf = dataf';
    
    
    
    AnglePlotterDistDelta(dataf, name);
    AnglePlotterMix(dataf, name, color, mask);
    AnglePlotterDist(dataf, name);
    
    
    data_new{i} = dataf;
    name_new{i} = name;
    color_new{i} = color;
    mask_new{i} = mask;
    
    close all
    
end


fclose(fid1);
fclose(fid2);