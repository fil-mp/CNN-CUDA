function y = fully_conected_no_q(input_vector)

    % Fully connected layer input size, layer width, output classes
    sizes = [4*4*32 , 128 , 2];
    
    % Weights and biases
    layer0_weights = dlmread('dense_weights.txt');
    layer0_bias = dlmread('dense_bias.txt');
    
    layer1_weights = dlmread('dense1_weights.txt');
    layer1_bias = dlmread('dense1_bias.txt');
    
    
    size(layer0_weights.')
    size(input_vector.')
    size(layer0_bias)

    % matrix multiplication
    layer0 =   (layer0_weights.') * (input_vector.') + layer0_bias;
    layer0_relu = relu(layer0);
    
    
    size(layer1_weights.')
    size(layer0)
    size(layer1_bias);

    
    layer1 = (layer1_weights.') * (layer0_relu)  + layer1_bias;
    
    size(layer1);

    y = layer1;
end
    
    
    
