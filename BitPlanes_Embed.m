function [RI] = BitPlanes_Embed(I,Plane,pl)
% 函数说明：将位平面矩阵Plane嵌入到图像I中的第pl个位平面
% 输入：I（原始图像矩阵）,Plane（位平面矩阵）,pl（位平面）
% 输出：RI（替换位平面后的图像矩阵）

RI = I;
[row,col] = size(I);   
index = 8 - pl + 1; %像素第pl个位平面的索引
for i=1:row
    for j=1:col
        value = I(i,j); %原始像素值
        [bin2_8] = BinaryConversion_10_2(value); %将像素值value转换成8位二进制数
        bin2_8(index) = Plane(i,j); %替换对应位平面的比特值
        [value] = BinaryConversion_2_10(bin2_8); %将替换位平面的二进制转换成十进制数
        RI(i,j) = value;
    end
end