function y = quartus_conv_2d_custom_more_bits(image_flattened_array,kernel_flattened_array,image_width,kernel_width)

%% AUX VARS AND INDEXES

    kernel_size = kernel_width * kernel_width;
    image_size = image_width * image_width;
    out_feature_map = zeros(image_width-kernel_width+1);
    out_feature_map_no_relu = zeros(image_width-kernel_width+1);
    
    acc_out = 0;
    mult_out = 0;

    kernel_x = 1;
    kernel_y = 1;
    pixel_input_index = 1;

    image_x = 1;
    row_times = 1;

%     image_flattened_array
    %%  "HARDWARE" ALGORITHM

    % CONVOLUTION WITH WEIGHTS KERNEL + BIAS
    for window_y = 1:image_width-kernel_width+1

        for window_x = 1:image_width-kernel_width+1

            image_x = window_x;

            for kernel_index = 1:kernel_size            
                if image_x-window_x+1 ~= kernel_width
                    pixel_input_index = (row_times-1)*image_width + (window_y-1)*image_width + image_x; 
                    mult_out = image_flattened_array(1,pixel_input_index) * kernel_flattened_array(1,kernel_index);
                    acc_out = acc_out + floor(mult_out./(2^1));
%                     acc_out = acc_out + mult_out;
                    %debug
%                     if window_x == 1 && window_y == 1  
%                         mult_out
%                     end
                    image_x = image_x + 1;
                else 
                    pixel_input_index = (row_times-1)*image_width + (window_y-1)*image_width + image_x;
                    mult_out = image_flattened_array(1,pixel_input_index) * kernel_flattened_array(1,kernel_index);
                    acc_out = acc_out + floor(mult_out./(2^1));
%                     acc_out = acc_out + mult_out;
                    %debug
%                     if window_x == 1 && window_y == 1  
%                         mult_out
%                     end
                    image_x = window_x;
                    row_times = row_times + 1;
    %                 disp('row of kernel done') ;
                end 
            end       
                    out_feature_map_no_relu(window_y,window_x) = acc_out; % GIATI ANAPODA LEITOURGEI?

                    acc_out = 0;
                    row_times = 1;

    %                 disp('kernel done')       ;
        end
    end
    
    y=out_feature_map_no_relu;
end