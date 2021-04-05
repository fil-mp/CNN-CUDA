clear;
clc;
clear all;
clear vars;

Q= 10; %% Arithmetic, image is already 2^8
N = 2^(Q-1);

%% TENSORFLOW RESULTS 

conv_0_tensorflow_file = dlmread('conv1_layer.txt');
conv_0_tensorflow = reshape(conv_0_tensorflow_file.', [76,76,8]);

conv_1_tensorflow_file = dlmread('conv2_layer.txt');
conv_1_tensorflow = reshape(conv_1_tensorflow_file.', [16,16,8]);

pool_0_tensorflow_file = dlmread('pool1_layer.txt');
pool_0_tensorflow = reshape(pool_0_tensorflow_file.', [19,19,8]);

pool_1_tensorflow_file = dlmread('pool2_layer.txt');
% pool_1_tensorflow = reshape(pool_1_tensorflow_file.', [4,4,32]);

pool_1_flattened_tensorflow = dlmread('flattened_layer.txt');

dense_0_weights_tensorflow_file = trun(dlmread('dense_weights.txt').*N);
dense_1_weights_tensorflow_file = trun(dlmread('dense1_weights.txt').*N);
dense_0_bias_tensorflow_file = trun(dlmread('dense_bias.txt').*N);
dense_1_bias_tensorflow_file = trun(dlmread('dense1_bias.txt').*N);

%% INITIALIZATIONS

% input_image = zeros(80,80,3);

% kernel_0 = ones(5,5,3,32);
% bias_0 = ones(32,1);
% 
conv_0 = zeros(76,76,8);
% conv_0_tensorflow = zeros(76,76,32);

pooling_0 = zeros(19,19,8);

% kernel_1 = ones(4,4,32,32);
% bias_1 = ones(1,32);

conv_1 = zeros(16,16,8);

pooling_1 = zeros(4,4,8);

first_reshape = zeros(16,8);

%% Read 3 Different Channels Of Input Image

% input_image(:,:,1) = trun(dlmread('ship0.txt').*N);
% input_image(:,:,2) = trun(dlmread('ship1.txt').*N);
% input_image(:,:,3) = trun(dlmread('ship2.txt').*N);

% imshow(input_image(:,:,1));
% imshow(input_image(:,:,2));
% imshow(input_image(:,:,3));

input_image_file = trun(dlmread('input_layer.txt').*2);
input_image = reshape(input_image_file.', [80,80,3]);

% imshow(dlmread('ship0.txt'));
% imshow(dlmread('ship1.txt'));
% imshow(dlmread('ship2.txt'));

% imshow(input_image(:,:,1)./256);
% imshow(input_image(:,:,2)./256);
% imshow(input_image(:,:,3)./256);

%% FILTER KERNELS AND BIAS

kernel_0_file = trun(dlmread('conv0_kernel.txt').*N);
kernel_1_file = trun(dlmread('conv1_kernel.txt').*N);

% kernel_0_file = dlmread('conv0_kernel.txt');
% kernel_1_file = dlmread('conv1_kernel.txt');

kernel_0 = reshape(kernel_0_file.', [5,5,3,8]); %% me tono se matlab kai order f sth python douleyei
kernel_1 = reshape(kernel_1_file.', [4,4,8,8]); %% me tono se matlab kai order f sth python douleyei

bias_0 = trun(dlmread('conv0_bias.txt').*N);
bias_1 = trun(dlmread('conv1_bias.txt').*N);

% bias_0 = dlmread('conv0_bias.txt');
% bias_1 = dlmread('conv1_bias.txt');

%% CONV-POOL 0/1

% CONV, CONV ACCEPTS FLATTENED ROW-ROW ARRAYS AND RETURNS 2D ARRAY
for i=1:8 %% different filters loop
    for j=1:3 %% different channels loop
        
        image_flattened = reshape(input_image(:,:,j).',1,[]);
        kernel_0_flattened = reshape(kernel_0(:,:,j,i).',1,[]);

        conv_0(:,:,i) = conv_0(:,:,i) + quartus_conv_2d_custom_more_bits(image_flattened,kernel_0_flattened,80,5);
        
        % for vhdl debug
%         if i==1 && j==1
%             conv_2d_custom(image_flattened,kernel_0_flattened,80,5)
%             conv_0(1,1,1)
%         end
%         
%         if i==1 && j==2
%             conv_2d_custom(image_flattened,kernel_0_flattened,80,5)
%             conv_0(1,1,1)
%         end
%                 
%         if i==1 && j==3
%             conv_2d_custom(image_flattened,kernel_0_flattened,80,5)
%             conv_0(1,1,1)
%         end
        
    end
    
    % bias and relu
    conv_0_bias(:,:,i) = conv_0(:,:,i) + bias_0(i);
    conv_0_down(:,:,i) =  floor(conv_0_bias(:,:,i)./N);
    conv_0_relu(:,:,i) = matrix_2d_relu(conv_0_down(:,:,i));
%     conv_0_relu(:,:,i) = matrix_2d_relu(conv_0(:,:,i) + bias_0(i));
    
%         if i==1 && j==3
%             conv_0(1,1,1)
%         end
end

% POOL
for i=1:8
    pooling_0(:,:,i) = pooling(conv_0_relu(:,:,i),76,76,4);
end

%% CONV - POOL 1/1

% CONV, CONV ACCEPTS FLATTENED ROW-ROW ARRAYS AND RETURNS 2D ARRAY
for i=1:8 %% different filters loop
    for j=1:8 %% different channels loop
        
        pooling_0_flattened = reshape(pooling_0(:,:,j).',1,[]);
        kernel_1_flattened = reshape(kernel_1(:,:,j,i).',1,[]);
        conv_1(:,:,i) = conv_1(:,:,i) + quartus_conv_2d_custom_more_bits(pooling_0_flattened,kernel_1_flattened,19,4);
    end
    
    % bias and relu
%     conv_1_relu(:,:,i) = matrix_2d_relu(conv_1(:,:,i) + bias_1(i));
    conv_1_bias(:,:,i) = conv_1(:,:,i) + bias_1(i);
    conv_1_down(:,:,i) =  floor(conv_1_bias(:,:,i)./N);
    conv_1_relu(:,:,i) = matrix_2d_relu(conv_1_down(:,:,i));
end

% POOL
for i=1:8
    pooling_1(:,:,i) = pooling(conv_1_relu(:,:,i),16,16,4);
end

%% Flatten
% Filter-by-filter and then row-by-row?

for i = 1:8
    first_reshape(:,i) = reshape(pooling_1(:,:,i).',1,4*4);
end

pool_layer_output_flattened = reshape(first_reshape.',1,[]);

%% FULLY CONNECTED & OUTPUT LAYER

final_output = quartus_fully_conected_with_q_more_bits(pool_layer_output_flattened);

final_output = final_output./N;




