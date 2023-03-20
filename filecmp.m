clear dat geo tif
clc

path = "./dat";

data = dir(path);

n = numel(data);

k = 0;

for i = 1 : n
    
    t = data(i);
    
    if ~t.isdir
        
        file = sprintf("%s%s%s", t.folder, filesep(), t.name);
        
        if isfile(file)
            
            k = k + 1;
            
            t = t.name;
            t = split(t, '.');
            t = t{1};
            t = str2double(t);
            
            dat(k) = t;
            
        end
        
    end
    
end

fprintf("dat: %d\n", numel(dat));

dat = sort(dat);
dat = dat';
dat









path = "./geo";

data = dir(path);

n = numel(data);

k = 0;

for i = 1 : n
    
    t = data(i);
    
    if ~t.isdir
        
        file = sprintf("%s%s%s", t.folder, filesep(), t.name);
        
        if isfile(file)
            
            if strcmp(t.name(1), '.')
                
                continue;
                
            end
            
            k = k + 1;
            
            t = t.name;
            t = split(t, '.');
            t = t{1};
            t = str2double(t);
            
            tif(k) = t;
            
        end
        
    end
    
end

fprintf("geo: %d\n", numel(tif));

tif = sort(tif);
tif = tif';
tif
















return





n = numel(dat);
m = numel(tif);

for i = 1 : n
    
    d = dat(i);
    
    fprintf("%12s%12d", "DAT:", d);
    
    for j = 1 : m
        
        g = tif(j);
        
        if d == g
            
            %fprintf("%12s%12d", "TIF:", g);
            
            s = sprintf("/Users/Stephen/Desktop/tmp/Traced/All/%d.tif", g);
            d = sprintf("/Users/Stephen/Desktop/Analysis/tif/%d.tif", g);
            
            %copyfile(s, d);
            
            break;
            
        end
        
       
    end
 
    fprintf("\n");
    
end




