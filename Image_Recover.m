function [recover_I] = Image_Recover(stego_I,K_en,K_sh)
% 函数说明：将载密图像stego_I解密恢复
% 输入：stego_I（载密图像）,K_en（图像加密密钥）,K_sh（图像混洗密钥）
% 输出：recover_I（恢复图像）

[row,col] = size(stego_I); %计算stego_I的行列值
%% 根据图像混洗密钥K_sh恢复图像像素的原始位置
rand('seed',K_sh); %设置种子
SH = randperm(row*col); %生成大小为row*col的伪随机序列
[reShuffle_I] = Image_ReShuffle(stego_I,SH);
%% 根据图像加密密钥K_en解密图像re_I
rand('seed',K_en); %设置种子
E = round(rand(row,col)*255); %生成大小为row*col的伪随机数矩阵
decrypt_I = reShuffle_I;
for i=1:row  %根据伪随机数矩阵E对图像vacate_I进行bit级加密
    for j=1:col
        decrypt_I(i,j) = bitxor(reShuffle_I(i,j),E(i,j));
    end
end
%% 统计decrypt_I所有位平面的比特流
Image_Bits = zeros();  %存储图像位平面的比特流
num_TB = 0; %计数,记录遍历的比特流数
for pl=8:-1:1
    [Plane] = BitPlanes_Extract(decrypt_I,pl);
    T_Plane = Plane'; %将矩阵转置,保证最终的比特流是按行遍历的
    PL_bits = reshape(T_Plane,1,row*col); %将Plane转换成一维矩阵,按列遍历
    Image_Bits(num_TB+1:num_TB+row*col) = PL_bits;
    num_TB = num_TB+row*col;
end
t = 0; %计数
%% 提取相关参数（Block_size,L_fix）
bin28_Bs = Image_Bits(t+1:t+4); %提取存储的分块大小信息(4 bits)
[Block_size] = BinaryConversion_2_10(bin28_Bs); %分块大小
t = t+4;
bin28_Lf = Image_Bits(t+1:t+3); %提取存储的参数信息(3 bits)
[L_fix] = BinaryConversion_2_10(bin28_Lf); %参数L_fix
t = t+3;
%% 提取溢出信息
Overflow = zeros(); %记录溢出信息
num = ceil(log2(row)) + ceil(log2(col)); %记录长度信息需要的比特数
bin2_num_Of = Image_Bits(t+1:t+num); %用num比特表示溢出预测误差个数
t = t+num;
[num_Of] = BinaryConversion_2_10(bin2_num_Of); %溢出预测误差的个数
if num_Of>0
    for i=1:num_Of
        bin2_pos = Image_Bits(t+1:t+num);
        t = t+num;
        [pos] = BinaryConversion_2_10(bin2_pos);
        x = ceil(pos/col);
        y = pos - (x-1)*col;
        Overflow(1,i) = x;
        Overflow(2,i) = y;
    end
end
%% 从高到低依次恢复图像的位平面（8→1）
PE_I = decrypt_I;
for pl=8:-1:1
    sign = Image_Bits(t+1);
    t = t+1; %用作压缩标记
    if sign == 1 %表示该位平面可压缩
        %------------------提取位平面的重排列方式（2 bits）-----------------%
        bin2_type = Image_Bits(t+1:t+2); 
        [type] = BinaryConversion_2_10(bin2_type); %位平面重排列方式
        t = t+2;
        %----------------------提取位平面的压缩比特流-----------------------%
        bin2_len = Image_Bits(t+1:t+num); 
        [len_CBS] = BinaryConversion_2_10(bin2_len); %位平面压缩比特流的长度
        t = t+num;
        CBS = Image_Bits(t+1:t+len_CBS); %当前位平面的压缩比特流
        t = t+len_CBS;
        %---------------------解压缩位平面的压缩比特流----------------------% 
        [Plane_bits] = BitStream_DeCompress(CBS,L_fix);
        %-----------------------恢复位平面的原始矩阵------------------------% 
        [Plane_Matrix] = BitPlanes_Recover(Plane_bits,Block_size,type,row,col);
    else %表示该位平面不可压缩，直接提取
        Plane_bits = Image_Bits(t+1:t+row*col); %当前位平面的压缩比特流
        t = t+row*col;
        Plane = reshape(Plane_bits,col,row); %换成矩阵,以列排序
        Plane_Matrix = Plane'; %转置矩阵
    end
    %% ---------------将恢复的位平面矩阵放回解密图像中---------------% 
    [RI] = BitPlanes_Embed(PE_I,Plane_Matrix,pl);
    PE_I = RI;
end
%% 恢复原始图像
recover_I = PE_I;
k = 0; %计数
for i=2:row  %第一行第一列为参考像素值
    for j=2:col
        if k<num_Of   
            if i==Overflow(1,k+1) && j==Overflow(2,k+1) %溢出点不变
                k = k+1;
                recover_I(i,j) = PE_I(i,j);
            else
                %--------------------------计算预测值--------------------------%
                a = recover_I(i-1,j);
                b = recover_I(i-1,j-1);
                c = recover_I(i,j-1);
                if b <= min(a,c)
                    pv = max(a,c); %预测值
                elseif b >= max(a,c)
                    pv = min(a,c);
                else
                    pv = a + c - b;
                end
                %-----------------计算预测误差并恢复原始像素值------------------%
                value = recover_I(i,j);
                if value>128 %最高位为1，表示预测误差是负数
                    pe = value-128;
                    recover_I(i,j) = pv - pe; 
                else
                    pe = value; %预测误差
                    recover_I(i,j) = pv + pe;
                end   
            end  
        else
            %--------------------------计算预测值--------------------------%
            a = recover_I(i-1,j);
            b = recover_I(i-1,j-1);
            c = recover_I(i,j-1);
            if b <= min(a,c)
                pv = max(a,c); %预测值
            elseif b >= max(a,c)
                pv = min(a,c);
            else
                pv = a + c - b;
            end
            %-----------------计算预测误差并恢复原始像素值------------------%
            value = recover_I(i,j);
            if value>128 %最高位为1，表示预测误差是负数
                pe = value-128;
                recover_I(i,j) = pv - pe; 
            else
                pe = value; %预测误差
                recover_I(i,j) = pv + pe;
            end 
        end 
    end
end 