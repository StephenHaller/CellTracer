clc

S = setdiff(D, G);

n = length(S);

sink = "./geo_process/";

for i = 1 : n
    
    str = sprintf("./dat_new/%i.dat", S(i));
    fprintf("%s\n", str);
    
    copyfile(str, sink);
    
end