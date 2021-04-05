
function y = pool_block(input)
%     num = 0;
%     for i = 1:24
%         for j = 1:24
%             input(i,j) = num;
%             num = num + 1;
%         end
%     end

    ii = 1;
    jj = 1;
    for i = 1:2:24
        for j = 1:2:24
            %disp(i)
            %disp(j)
            max_value1 = max(input(i,j),input(i+1,j));
            max_value2 = max(input(i,j+1),input(i+1,j+1));
            final_max = max(max_value1,max_value2);
            output(ii,jj) = final_max;
            jj = jj + 1;
        end
        jj=1;
        ii = ii + 1;
    end

    y = output;
end


