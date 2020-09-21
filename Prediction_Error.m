function [PE_I,num_Of,Overflow] = Prediction_Error(origin_I)
% 函数说明：计算origin_I的预测误差
% 输入：origin_I（原始图像）
% 输出：PE_I（预测误差图像）,num_Of（溢出预测误差个数）,Overflow（溢出信息）

[row,col] = size(origin_I); %计算origin_I的行列值
PE_I = origin_I;  %构建存储origin_I预测值的容器
Overflow = zeros(); %记录溢出信息
num_Of = 0; %计数，记录溢出像素的个数
for i=2:row %第一行第一列作为参考像素
    for j=2:col
        a = origin_I(i-1,j);
        b = origin_I(i-1,j-1);
        c = origin_I(i,j-1);
        if b <= min(a,c)
            pv = max(a,c); %预测值
        elseif b >= max(a,c)
            pv = min(a,c);
        else
            pv = a + c - b;
        end
        pe = origin_I(i,j) - pv; %计算预测误差
        if pe<0 && pe>=-127 %负数的情况将最高位设为1，作为标记
            abs_pe = abs(pe); %预测误差的绝对值
            PE_I(i,j) = mod(abs_pe,128) + 128;
        elseif pe>=0 && pe<=127
            PE_I(i,j) = pe;
        else
            PE_I(i,j) = origin_I(i,j); %溢出点不改变
            num_Of = num_Of+1;
            Overflow(1,num_Of) = i; %记录溢出预测误差的位置
            Overflow(2,num_Of) = j;
        end  
    end
end