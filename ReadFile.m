function [S, SS, Samples, DivisionPlanes, CellSeperations, CellPinchings, Difficults] = ReadFile(filename)


difficult = 0;


fid = fopen(filename, 'r');

%
Header = fgetl(fid);
Count = GetValue(fgetl(fid), 2);
fgetl(fid);


% 
S = Spline.empty();
SS = Spline.empty();

%
Difficults = [];

for i = 1 : Count
    
    Samples(i) = GetValue(fgetl(fid), 2);           	% Sample: %d
    DivisionPlanes(i) = GetValue(fgetl(fid), 2);    	% DivisionPlane: %d
    CellSeperations(i) = GetValue(fgetl(fid), 2);    	% CellSeperation: %d
    CellPinchings(i) = GetValue(fgetl(fid), 2);      	% CellPinching: %d
    
    Difficults(i) = nan;
    
    if i == 1
        
        tline = fgetl(fid); 
        t = split(tline, ':');

        if strcmp(t{1}, 'Difficult')

            difficult = 1;

            Difficults(i) = GetValue(tline, 2);             % Difficult: %d
            fgetl(fid);                                 % Profile: closed
            
        end

    else
        
        if difficult == 1
            
            Difficults(i) = GetValue(fgetl(fid), 2);  	% Difficult: %d
            
        end
        
        fgetl(fid);                                 % Profile: closed
        
    end
    

 
    
    
    
    
    
    
    S(i) = Spline();
    P = Vect3.empty();
    k = 1;
    line = fgetl(fid);
	while strcmp(line(1), 'v')
        x = GetValue(line, 2);
        y = GetValue(line, 3);
        P(k) = Vect3(x, y, 0);
        line = fgetl(fid);
        k = k + 1;
    end
    
    if ~isempty(P)
        S(i).BuildSpline(P, true);
    end
    
    
    SS(i) = Spline();
    P = Vect3.empty();
    k = 1;
    line = fgetl(fid);

    if isempty(line)
        continue;
    end
    
	while strcmp(line(1), 'v')
        x = GetValue(line, 2);
        y = GetValue(line, 3);
        P(k) = Vect3(x, y, 0);
        line = fgetl(fid);
        if isempty(line)
            break;
        end
        k = k + 1;
    end
    
    if ~isempty(P)
        SS(i).BuildSpline(P, false);
    end
    

    
    
    
end

fclose(fid);










    function value = GetValue(line, index)        
        tmp = split(line);        
        value = str2double(tmp{index});        
    end

end