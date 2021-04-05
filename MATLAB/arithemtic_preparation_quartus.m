clear;

bits = 9; %% Arithmetic
N = 2^(bits-1);

%% Read 3 Different Channels Of Input Image

input_image(:,:,1) = trun(dlmread('ship0.txt').*N);
input_image(:,:,2) = trun(dlmread('ship1.txt').*N);
input_image(:,:,3) = trun(dlmread('ship2.txt').*N);

fileID0 = fopen('ship_0.mif','w');
fileID1 = fopen('ship_1.mif','w');
fileID2 = fopen('ship_2.mif','w');

fprintf(fileID0,'WIDTH=9; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=DEC; \nCONTENT BEGIN \n');
for i = 1:80 
        if i~=8
            fprintf(fileID0,'%d : %d; \n\n',(i-1),input_image(i,:,1));
        else
            fprintf(fileID0,'%d : %d; \nEND;\n',(i-1),input_image(i,:,1));
        end
end

fprintf(fileID1,'WIDTH=9; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=DEC; \nCONTENT BEGIN \n');
for i = 1:8 
        if i~=8
            fprintf(fileID1,'%d : %d; \n\n',(i-1),bias_1(i));
        else
            fprintf(fileID1,'%d : %d; \nEND;\n',(i-1),bias_1(i));
        end
end

% fprintf(fileID0,'%d \n',bias_0);
% fprintf(fileID1,'%d \n',bias_1);
fclose(fileID0);

%% TEST WINDOW

fileID = fopen('test_window.txt','w');
test_window = [input_image(1,1:5,1) input_image(2,1:5,1) input_image(3,1:5,1) input_image(4,1:5,1) input_image(5,1:5,1)];
fprintf(fileID,'%d \r\n', test_window);
fclose(fileID);

%% FILTER KERNELS AND BIAS

kernel_0_file = trun(dlmread('conv0_kernel.txt').*N);
kernel_1_file = trun(dlmread('conv1_kernel.txt').*N);

kernel_0 = reshape(kernel_0_file.', [5,5,3,8]); %% me tono se matlab kai order f sth python douleyei
kernel_1 = reshape(kernel_1_file.', [4,4,8,8]); %% me tono se matlab kai order f sth python douleyei

bias_0 = trun(dlmread('conv0_bias.txt').*N);
bias_1 = trun(dlmread('conv1_bias.txt').*N);
for i = 1:8
    bias_1_binary(i) = sdec2bin(bias_1(i),bits);
end

%% 2'S COMPLEMENT BINARY CONVERSION


for i = 1:5
    for j = 1:5
        for k = 1:3
            for l =  1:8
                kernel_0_binary(i,j,k,l) = sdec2bin(kernel_0(i,j,k,l),bits);
            end
        end
    end
end

for i = 1:4
    for j = 1:4
        for k = 1:8
            for l =  1:8
                kernel_1_binary(i,j,k,l) = sdec2bin(kernel_1(i,j,k,l),bits);
            end
        end
    end
end


%% WRITE TO FILES

%% bias files, signed decimal, easy
fileID0 = fopen('bias_0.mif','w');
fileID1 = fopen('bias_1.mif','w');

fprintf(fileID0,'WIDTH=9; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=DEC; \nCONTENT BEGIN \n');
for i = 1:8 
        if i~=8
            fprintf(fileID0,'%d : %d; \n\n',(i-1),bias_0(i));
        else
            fprintf(fileID0,'%d : %d; \nEND;\n',(i-1),bias_0(i));
        end
end

fprintf(fileID1,'WIDTH=9; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=DEC; \nCONTENT BEGIN \n');
for i = 1:8 
        if i~=8
            fprintf(fileID1,'%d : %d; \n\n',(i-1),bias_1(i));
        else
            fprintf(fileID1,'%d : %d; \nEND;\n',(i-1),bias_1(i));
        end
end

% fprintf(fileID0,'%d \n',bias_0);
% fprintf(fileID1,'%d \n',bias_1);
fclose(fileID0);
fclose(fileID1);

%% kernel files, not that easy

% % FOR CONV LAYER 0
fileID0 = fopen('weights_0_0.mif','w'); %% channel 0
fileID1 = fopen('weights_0_1.mif','w'); %% channel 1
fileID2 = fopen('weights_0_2.mif','w'); %% channel 2


% row-row each kernel
for i=1:8
    for j = 1:3
        kernel_0_binary_reshaped_row(:,j,i) = reshape(kernel_0_binary(:,:,j,i).',[25,1,1]);   
    end
end

kernel_0_binary_strcat = strcat(kernel_0_binary_reshaped_row(1,:,:), kernel_0_binary_reshaped_row(2,:,:), kernel_0_binary_reshaped_row(3,:,:), kernel_0_binary_reshaped_row(4,:,:), kernel_0_binary_reshaped_row(5,:,:), kernel_0_binary_reshaped_row(6,:,:), kernel_0_binary_reshaped_row(7,:,:), kernel_0_binary_reshaped_row(8,:,:), kernel_0_binary_reshaped_row(9,:,:), kernel_0_binary_reshaped_row(10,:,:), kernel_0_binary_reshaped_row(11,:,:), kernel_0_binary_reshaped_row(12,:,:), kernel_0_binary_reshaped_row(13,:,:), kernel_0_binary_reshaped_row(14,:,:), kernel_0_binary_reshaped_row(15,:,:), kernel_0_binary_reshaped_row(16,:,:), kernel_0_binary_reshaped_row(17,:,:), kernel_0_binary_reshaped_row(18,:,:), kernel_0_binary_reshaped_row(19,:,:), kernel_0_binary_reshaped_row(20,:,:), kernel_0_binary_reshaped_row(21,:,:), kernel_0_binary_reshaped_row(22,:,:), kernel_0_binary_reshaped_row(23,:,:), kernel_0_binary_reshaped_row(24,:,:), kernel_0_binary_reshaped_row(25,:,:));


fprintf(fileID0,'WIDTH=225; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=BIN; \nCONTENT BEGIN \n');
for i = 1:8 
        if i~=8
            fprintf(fileID0,'%d : %s; \n\n',(i-1),(kernel_0_binary_strcat{1,1,i}));
        else
            fprintf(fileID0,'%d : %s; \nEND;\n',(i-1),(kernel_0_binary_strcat{1,1,i}));
        end
end

fprintf(fileID1,'WIDTH=225; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=BIN; \nCONTENT BEGIN \n');
for i = 1:8 
        if i~=8
            fprintf(fileID1,'%d : %s; \n\n',(i-1),(kernel_0_binary_strcat{1,2,i}));
        else
            fprintf(fileID1,'%d : %s; \nEND;\n',(i-1),(kernel_0_binary_strcat{1,2,i}));
        end
end

fprintf(fileID2,'WIDTH=225; \nDEPTH=8; \nADDRESS_RADIX=UNS; \nDATA_RADIX=BIN; \nCONTENT BEGIN \n');
for i = 1:8 
        if i~=8
            fprintf(fileID2,'%d : %s; \n\n',(i-1),(kernel_0_binary_strcat{1,3,i}));
        else
            fprintf(fileID2,'%d : %s; \nEND;\n',(i-1),(kernel_0_binary_strcat{1,3,i}));
        end
end

fclose(fileID0);
fclose(fileID1);
fclose(fileID2);

% FOR CONV LAYER 1
fileID0 = fopen('weights_1_0.coe','w'); %% filter 0
fileID1 = fopen('weights_1_1.coe','w'); %% filter 1
fileID2 = fopen('weights_1_2.coe','w'); %% filter 2
fileID3 = fopen('weights_1_3.coe','w'); %% filter 3
fileID4 = fopen('weights_1_4.coe','w'); %% filter 4
fileID5 = fopen('weights_1_5.coe','w'); %% filter 5
fileID6 = fopen('weights_1_6.coe','w'); %% filter 6
fileID7 = fopen('weights_1_7.coe','w'); %% filter 7
fileID8 = fopen('weights_1_8.coe','w'); %% filter 8
fileID9 = fopen('weights_1_9.coe','w'); %% filter 9
fileID10 = fopen('weights_1_10.coe','w'); %% filter 10
fileID11 = fopen('weights_1_11.coe','w'); %% filter 11
fileID12 = fopen('weights_1_12.coe','w'); %% filter 12
fileID13 = fopen('weights_1_13.coe','w'); %% filter 13
fileID14 = fopen('weights_1_14.coe','w'); %% filter 14
fileID15 = fopen('weights_1_15.coe','w'); %% filter 15
fileID16 = fopen('weights_1_16.coe','w'); %% filter 16
fileID17 = fopen('weights_1_17.coe','w'); %% filter 17
fileID18 = fopen('weights_1_18.coe','w'); %% filter 18
fileID19 = fopen('weights_1_19.coe','w'); %% filter 19
fileID20 = fopen('weights_1_20.coe','w'); %% filter 20
fileID21 = fopen('weights_1_21.coe','w'); %% filter 21
fileID22 = fopen('weights_1_22.coe','w'); %% filter 22
fileID23 = fopen('weights_1_23.coe','w'); %% filter 23
fileID24 = fopen('weights_1_24.coe','w'); %% filter 24
fileID25 = fopen('weights_1_25.coe','w'); %% filter 25
fileID26 = fopen('weights_1_26.coe','w'); %% filter 26
fileID27 = fopen('weights_1_27.coe','w'); %% filter 27
fileID28 = fopen('weights_1_28.coe','w'); %% filter 28
fileID29 = fopen('weights_1_29.coe','w'); %% filter 29
fileID30 = fopen('weights_1_30.coe','w'); %% filter 30
fileID31 = fopen('weights_1_31.coe','w'); %% filter 31


% row-row each kernel
for i=1:32
    for j = 1:32
        kernel_1_binary_reshaped_row(:,j,i) = reshape(kernel_1_binary(:,:,j,i).',[16,1,1]);   
    end
end

kernel_1_binary_strcat = strcat(kernel_1_binary_reshaped_row(1,:,:), kernel_1_binary_reshaped_row(2,:,:), kernel_1_binary_reshaped_row(3,:,:), kernel_1_binary_reshaped_row(4,:,:), kernel_1_binary_reshaped_row(5,:,:), kernel_1_binary_reshaped_row(6,:,:), kernel_1_binary_reshaped_row(7,:,:), kernel_1_binary_reshaped_row(8,:,:), kernel_1_binary_reshaped_row(9,:,:), kernel_1_binary_reshaped_row(10,:,:), kernel_1_binary_reshaped_row(11,:,:), kernel_1_binary_reshaped_row(12,:,:), kernel_1_binary_reshaped_row(13,:,:), kernel_1_binary_reshaped_row(14,:,:), kernel_1_binary_reshaped_row(15,:,:), kernel_1_binary_reshaped_row(16,:,:));

fprintf(fileID0,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID0,'%s, \n',(kernel_1_binary_strcat{1,i,1}));
        else
            fprintf(fileID0,'%s;',(kernel_1_binary_strcat{1,i,1}));
        end
end

fprintf(fileID1,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID1,'%s, \n',(kernel_1_binary_strcat{1,i,2}));
        else
            fprintf(fileID1,'%s;',(kernel_1_binary_strcat{1,i,2}));
        end
end

fprintf(fileID2,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID2,'%s, \n',(kernel_1_binary_strcat{1,i,3}));
        else
            fprintf(fileID2,'%s;',(kernel_1_binary_strcat{1,i,3}));
        end
end
fprintf(fileID3,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID3,'%s, \n',(kernel_1_binary_strcat{1,i,4}));
        else
            fprintf(fileID3,'%s;',(kernel_1_binary_strcat{1,i,4}));
        end
end

fprintf(fileID4,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID4,'%s, \n',(kernel_1_binary_strcat{1,i,5}));
        else
            fprintf(fileID4,'%s;',(kernel_1_binary_strcat{1,i,5}));
        end
end

fprintf(fileID5,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID5,'%s, \n',(kernel_1_binary_strcat{1,i,6}));
        else
            fprintf(fileID5,'%s;',(kernel_1_binary_strcat{1,i,6}));
        end
end
fprintf(fileID6,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID6,'%s, \n',(kernel_1_binary_strcat{1,i,7}));
        else
            fprintf(fileID6,'%s;',(kernel_1_binary_strcat{1,i,7}));
        end
end

fprintf(fileID7,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID7,'%s, \n',(kernel_1_binary_strcat{1,i,8}));
        else
            fprintf(fileID7,'%s;',(kernel_1_binary_strcat{1,i,8}));
        end
end

fprintf(fileID8,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID8,'%s, \n',(kernel_1_binary_strcat{1,i,9}));
        else
            fprintf(fileID8,'%s;',(kernel_1_binary_strcat{1,i,9}));
        end
end
fprintf(fileID9,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID9,'%s, \n',(kernel_1_binary_strcat{1,i,10}));
        else
            fprintf(fileID9,'%s;',(kernel_1_binary_strcat{1,i,10}));
        end
end

fprintf(fileID10,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID10,'%s, \n',(kernel_1_binary_strcat{1,i,11}));
        else
            fprintf(fileID10,'%s;',(kernel_1_binary_strcat{1,i,11}));
        end
end

fprintf(fileID11,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID11,'%s, \n',(kernel_1_binary_strcat{1,i,12}));
        else
            fprintf(fileID11,'%s;',(kernel_1_binary_strcat{1,i,12}));
        end
end
fprintf(fileID12,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID12,'%s, \n',(kernel_1_binary_strcat{1,i,13}));
        else
            fprintf(fileID12,'%s;',(kernel_1_binary_strcat{1,i,13}));
        end
end

fprintf(fileID13,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID13,'%s, \n',(kernel_1_binary_strcat{1,i,14}));
        else
            fprintf(fileID13,'%s;',(kernel_1_binary_strcat{1,i,14}));
        end
end

fprintf(fileID14,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID14,'%s, \n',(kernel_1_binary_strcat{1,i,15}));
        else
            fprintf(fileID14,'%s;',(kernel_1_binary_strcat{1,i,15}));
        end
end
fprintf(fileID15,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID15,'%s, \n',(kernel_1_binary_strcat{1,i,16}));
        else
            fprintf(fileID15,'%s;',(kernel_1_binary_strcat{1,i,16}));
        end
end

fprintf(fileID16,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID16,'%s, \n',(kernel_1_binary_strcat{1,i,17}));
        else
            fprintf(fileID16,'%s;',(kernel_1_binary_strcat{1,i,17}));
        end
end

fprintf(fileID17,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID17,'%s, \n',(kernel_1_binary_strcat{1,i,18}));
        else
            fprintf(fileID17,'%s;',(kernel_1_binary_strcat{1,i,18}));
        end
end
fprintf(fileID18,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID18,'%s, \n',(kernel_1_binary_strcat{1,i,19}));
        else
            fprintf(fileID18,'%s;',(kernel_1_binary_strcat{1,i,19}));
        end
end

fprintf(fileID19,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID19,'%s, \n',(kernel_1_binary_strcat{1,i,20}));
        else
            fprintf(fileID19,'%s;',(kernel_1_binary_strcat{1,i,20}));
        end
end

fprintf(fileID20,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID20,'%s, \n',(kernel_1_binary_strcat{1,i,21}));
        else
            fprintf(fileID20,'%s;',(kernel_1_binary_strcat{1,i,21}));
        end
end
fprintf(fileID21,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID21,'%s, \n',(kernel_1_binary_strcat{1,i,22}));
        else
            fprintf(fileID21,'%s;',(kernel_1_binary_strcat{1,i,22}));
        end
end

fprintf(fileID22,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID22,'%s, \n',(kernel_1_binary_strcat{1,i,23}));
        else
            fprintf(fileID22,'%s;',(kernel_1_binary_strcat{1,i,23}));
        end
end

fprintf(fileID23,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID23,'%s, \n',(kernel_1_binary_strcat{1,i,24}));
        else
            fprintf(fileID23,'%s;',(kernel_1_binary_strcat{1,i,24}));
        end
end
fprintf(fileID24,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID24,'%s, \n',(kernel_1_binary_strcat{1,i,25}));
        else
            fprintf(fileID24,'%s;',(kernel_1_binary_strcat{1,i,25}));
        end
end

fprintf(fileID25,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID25,'%s, \n',(kernel_1_binary_strcat{1,i,26}));
        else
            fprintf(fileID25,'%s;',(kernel_1_binary_strcat{1,i,26}));
        end
end

fprintf(fileID26,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID26,'%s, \n',(kernel_1_binary_strcat{1,i,27}));
        else
            fprintf(fileID26,'%s;',(kernel_1_binary_strcat{1,i,27}));
        end
end

fprintf(fileID27,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID27,'%s, \n',(kernel_1_binary_strcat{1,i,28}));
        else
            fprintf(fileID27,'%s;',(kernel_1_binary_strcat{1,i,28}));
        end
end
fprintf(fileID28,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID28,'%s, \n',(kernel_1_binary_strcat{1,i,29}));
        else
            fprintf(fileID28,'%s;',(kernel_1_binary_strcat{1,i,29}));
        end
end

fprintf(fileID29,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID29,'%s, \n',(kernel_1_binary_strcat{1,i,30}));
        else
            fprintf(fileID29,'%s;',(kernel_1_binary_strcat{1,i,30}));
        end
end

fprintf(fileID30,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID30,'%s, \n',(kernel_1_binary_strcat{1,i,31}));
        else
            fprintf(fileID30,'%s;',(kernel_1_binary_strcat{1,i,31}));
        end
end
fprintf(fileID31,'memory_initialization_radix=2; \nmemory_initialization_vector= \n',(kernel_1_binary_strcat{1,1,i}));
for i = 1:32 
        if i~=32
            fprintf(fileID31,'%s, \n',(kernel_1_binary_strcat{1,i,32}));
        else
            fprintf(fileID31,'%s;',(kernel_1_binary_strcat{1,i,32}));
        end
end

%% IMAGE TEST WINDOW

% 
% %% IMAGE FILES, MEDIUM
% 
% fileID0 = fopen('image_binary_row_0.coe','w'); %% channel 0
% fileID1 = fopen('image_binary_row_1.coe','w'); %% channel 1
% fileID2 = fopen('image_binary_row_2.coe','w'); %% channel 2
% 
% % to binary
% for i = 1:80
%     for j = 1:80
%         for k = 1:3
%             image_binary(i,j,k) = sdec2bin(input_image(i,j,k),bits);
%         end
%     end
% end
% 
% % row-row each channel
% % for j = 1:3
% %     image_binary_reshaped_row(:,j) = reshape(image_binary(:,:,j).',[6400,1]);   
% % end
% 
% image_binary_row_strcat = [];
% % concatanate each row binary string
% for i = 1:80
%     for j = 1:80
%         for k = 1:3 
%             image_binary_row_strcat(:,j,k) = strcat(image_binary_row_strcat,image_binary(i,j,k));
%         end
%     end
% end
