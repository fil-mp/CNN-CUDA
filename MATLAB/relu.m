function y = relu(x)

y=zeros(length(x),1);

for i=1:length(x)
    if x(i)< 0
        %y(i) = x(i)/128;
        y(i) = 0;
    else
        y(i)=x(i);
    end
end
end