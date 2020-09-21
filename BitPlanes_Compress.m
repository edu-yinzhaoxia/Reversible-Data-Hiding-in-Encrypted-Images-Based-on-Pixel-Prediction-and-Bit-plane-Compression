function [CBS,type] = BitPlanes_Compress(Plane,Block_size,L_fix,L)
% 函数说明：压缩位平面矩阵Plane
% 输入：Plane（位平面矩阵）,Block_size（分块大小）,L_fix（定长编码参数）,L（相同比特流长度参数）
% 输出：CBS（位平面压缩比特流）,type（位平面重排列方式）

%% 将位平面重排列并进行压缩（共有4种重排列方式）
BS_comp = cell(0); %用来记录压缩的位平面比特流
for t=0:3  %0→00,1→01,2→10,3→11
    %----------------根据BMPR算法重排列位平面----------------%
    [origin_bits] = BitPlanes_Rearrange(Plane,Block_size,t);
    %----------------压缩重排列位平面的比特流----------------%
    [compress_bits] = BitStream_Compress(origin_bits,L_fix,L);
    BS_comp{t+1} = compress_bits; %记录压缩的比特流
end
%% 判断哪种重排列方式的压缩比特流最短
len = Inf; %表示无穷大
for t=0:3  %0→00,1→01,2→10,3→11
    bit_stream = BS_comp{t+1};
    num = length(bit_stream);
    if num < len
        CBS = bit_stream; %记录最短的压缩比特流
        type = t; %记录位平面重排列方式
        len = num;    
    end 
end