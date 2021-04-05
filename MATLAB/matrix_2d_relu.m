function y = matrix_2d_relu(x)

[m,n] = size(x);

%     RELU
    for i = 1:m
        for j = 1:n
            if x(i,j) < 0 
                y(i,j) = 0;
            else 
                y(i,j) = x(i,j);
            end
        end
    end