fclose all
clc

file1 = './txt/Angle.txt';
file2 = './txt/AngleFix.txt';

fid1 = fopen(file1, 'r');
fid2 = fopen(file2, 'w');

% header
str = fgetl(fid1);
fprintf(fid2, '%s%s\n', str, 'Fix');

% header
str = fgetl(fid1);
fprintf(fid2, '%s\n', str);

n = 8;

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

        [d, t, a] = FixData(col);

        %
        data_fix(1 : numel(col), j) = d;
        t_final(j) = t;
        a_final(j) = a;  
        
        
        a = gca();
        a.YLim = [-120, 120];
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
    
end


fclose(fid1);
fclose(fid2);