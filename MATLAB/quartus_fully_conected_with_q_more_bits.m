function y = quartus_fully_conected_with_q_more_bits(input_vector)

    % Fully connected layer input size, layer width, output classes
    sizes = [4*4*32 , 128 , 2];
    
    N = 2^8;
    
    % Weights and biases
    layer0_weights = trun(dlmread('dense_weights.txt').*N);
    layer0_bias = trun(dlmread('dense_bias.txt').*N);
    
    layer1_weights = trun(dlmread('dense1_weights.txt').*N);
    layer1_bias = trun(dlmread('dense1_bias.txt').*N);
    
    
%     size(layer0_weights.')
%     size(input_vector.')
%     size(layer0_bias)

    % matrix multiplication
    layer0 =  trun((trun(((layer0_weights.') * (input_vector.')))./2 + layer0_bias)./N);
    layer0_relu = relu(layer0);
    
%     
%     size(layer1_weights.')
%     size(layer0)
%     size(layer1_bias);

    
    layer1 = trun(((((layer1_weights.') * (layer0_relu))./2)  + layer1_bias)./N);
    
%     size(layer1);

    y = layer1;
end
    
    