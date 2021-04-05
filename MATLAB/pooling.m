function y = pooling(input,m,n,str)
    ii = 1;
    jj = 1;
    output=zeros(m/str,n/str);
    for i = 1:str:m
        for j = 1:str:n
            %disp(i)
            %disp(j)
            max_value1_0 = max(input(i,j),input(i+1,j));
            max_value1_1 = max(input(i+2,j),input(i+3,j));
            max_value_1 = max(max_value1_0,max_value1_1);
            
            max_value2_0 = max(input(i,j+1),input(i+1,j+1));
            max_value2_1 = max(input(i+2,j+1),input(i+3,j+1));
            max_value_2 = max(max_value2_0,max_value2_1);
            
            max_value3_0 = max(input(i,j+2),input(i+1,j+2));
            max_value3_1 = max(input(i+2,j+2),input(i+3,j+2));
            max_value_3 = max(max_value3_0,max_value3_1);
            
            max_value4_0 = max(input(i,j+3),input(i+1,j+3));
            max_value4_1 = max(input(i+2,j+3),input(i+3,j+3));
            max_value_4 = max(max_value4_0,max_value4_1);
            
            int_max_0 = max(max_value_1,max_value_2);
            int_max_1 = max(max_value_3,max_value_4);
            final_max = max(int_max_0,int_max_1);
            output(ii,jj) = final_max;
            jj = jj + 1;
        end
        jj=1;
        ii = ii + 1;
    end

    y = output;
end