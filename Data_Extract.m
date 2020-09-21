function [exD] = Data_Extract(stego_I,K_sh,K_hide,num_emD)
% 函数说明：在载密图像stego_I中提取秘密信息
% 输入：stego_I（载密图像）,K_sh（图像混洗密钥）,K_hide（数据嵌入密钥）,num_emD（嵌入的秘密信息数）
% 输出：exD(提取的秘密信息)

Encrypt_exD = zeros();
[row,col] = size(stego_I);
%% 根据图像混洗密钥K_sh恢复图像像素的原始位置
rand('seed',K_sh); %设置种子
SH = randperm(row*col); %生成大小为row*col的伪随机序列
[re_I] = Image_ReShuffle(stego_I,SH);
%% 在低位位平面中提取秘密信息
num_exD = 0; %计数，提取的秘密信息数
for pl=1:8 
    if num_exD==num_emD %秘密信息已提取完毕
        break;
    end
    index = 8-pl+1; %像素第pl个位平面的索引
    for i=row:-1:1 %从后往前提取
        for j=col:-1:1
            if num_exD==num_emD %秘密信息已提取完毕
                break;
            end
            value = re_I(i,j); %当前像素值
            [bin2_8] = BinaryConversion_10_2(value); %转换成8位二进制
            num_exD = num_exD+1;
            Encrypt_exD(num_exD) = bin2_8(index);
        end
    end
end
%% 根据数据嵌入密钥K_hide解密提取的秘密信息
[exD] = Data_Encrypt(Encrypt_exD,K_hide);
end
