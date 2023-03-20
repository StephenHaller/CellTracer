clear
clc

path = "./geo_new";
Name = "REALLYTHEONE.dat";

DB = ADatabase();
DB.Read(Name);

a = dir(path);

n = length(a);

k = 1;
id = nan(n, 1);

for i = 1 : n
    
    file = a(i);
    
    %
    if ~file.isdir
        
        %fprintf("%3d. %s\n", i, file.name);
    
        name = string(file.name);     
        s = strsplit(name, '.');
        id(i) = str2double(s(1));
          
        k = k + 1;
        
    end

end

id(isnan(id)) = [];

n = length(id);

fprintf("%d .dat file(s) found in ""%s""\n", n, path);



k = 0;

inc = nan(n, 1);
exc = nan(n, 1);

for i = 1 : n
    
    if DB.IsEntryByID(id(i))
        
        inc(i) = id(i);
        
        k = k + 1;
        
    else
        
        exc(i) = id(i);
        
    end

end

inc(isnan(inc)) = [];
exc(isnan(exc)) = [];

m = DB.Count;

fprintf("%d .dat file(s) map in ""%s"" (%d of %d | %1.1f%% of the database covered)\n", k, Name, k, m, k / m * 100);

fprintf("Includes: \n");
fprintf("\t%d\n", inc)

fprintf("Excludes: \n");
fprintf("\t%d\n", exc)

DB.Print();


n = DB.Count();

ni = nan(n, 1);

for i = 1 : n

    ni(i) = DB.entries(i).id;


end

ni(isnan(ni)) = [];


ni = setdiff(ni, inc);

fprintf("\n");
fprintf("No .dat file found (%d): \n", length(ni));
fprintf("\t%d\n", ni);






m = length(DB.types);
            
fprintf("Database (%d types)\n\n", m);
   
kk = 0;

for i = 1 : m
                
	type = DB.types(i);
                
    e = DB.GetEntriesByType(type);

    n = length(e);
    
    k = 0;
    
    % database set
    for j = 1 : n
        
        
        
       	bool = ismember(e(j).id, inc);
        
        if bool 
        
            k = k + 1;
        
        end
        
    end
       
    kk = kk + k;
    
    fprintf("%-16s:\t\t%d of %d\n", type, k, n);
                
end

kk