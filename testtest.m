clc

n = 10;

D = rand(n, 3);
M = sqrt(sum(D .^ 2, 2));
N = D ./ M;

data = zeros(n);

for i = 1 : n
                
    a = repmat(N(i, :), [n, 1]);

    data(:, i) = dot(a, N, 2);
                
end

data