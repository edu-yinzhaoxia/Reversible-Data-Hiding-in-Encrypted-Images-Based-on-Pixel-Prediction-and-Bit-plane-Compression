function [origin_bits] = BitStream_DeCompress(compress_bits,L_fix)
% 函数说明：解压缩比特流
% 输入：compress_bits（压缩比特流）,L_fix（定长编码参数）
% 输出：origin_bits（原始比特流）

len_bits = length(compress_bits); %统计压缩比特流的长度
comp_t = 0;%计数，已遍历压缩比特流的长度
origin_bits = zeros(); %用来记录原始比特流
ori_t = 0; %计数，原始比特流的数目
while comp_t<len_bits 
    label = compress_bits(comp_t+1); %压缩段的第一个比特值
    %-------------------表示接下来的一段比特流是压缩比特流-------------------%
    if label==1 
        L_pre = 0;  %前缀标记位
        for i=comp_t+1:len_bits
            if compress_bits(i) == 1
                L_pre = L_pre+1;
            else
                L_pre = L_pre+1; %前缀标记以0结束
                break;
            end
        end
        comp_t = comp_t + L_pre; %用于记录相同比特流压缩后的前缀部分
        l_bits = compress_bits(comp_t+1:comp_t+L_pre);%用于记录相同比特流压缩后的中间部分
        comp_t = comp_t + L_pre; 
        [l] = BinaryConversion_2_10(l_bits); %中间部分的值
        L = 2^L_pre + l; %相同比特流的长度
        bit = compress_bits(comp_t+1);  %用于记录相同比特流的比特值
        comp_t = comp_t + 1;
        for i=1:L %记录原始比特流
            ori_t = ori_t+1;
            origin_bits(ori_t) = bit;
        end
    %----------------表示接下来的一段比特流是直接截取的比特流----------------%
    elseif label==0
        if comp_t+L_fix+1<=len_bits
            comp_t = comp_t + 1; %标记位
            origin_bits(ori_t+1:ori_t+L_fix) = compress_bits(comp_t+1:comp_t+L_fix);
            ori_t = ori_t + L_fix;
            comp_t = comp_t + L_fix;
        else
            comp_t = comp_t + 1; %标记位
            re = len_bits - comp_t;
            origin_bits(ori_t+1:ori_t+re) = compress_bits(comp_t+1:comp_t+re);
            ori_t = ori_t + re;
            comp_t = comp_t + re;
        end
    end
end
