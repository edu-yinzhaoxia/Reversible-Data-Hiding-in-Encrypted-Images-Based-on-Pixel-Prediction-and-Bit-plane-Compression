function [compress_bits] = BitStream_Compress(origin_bits,L_fix,L)
% 函数说明：压缩比特流
% 输入：origin_bits（原始比特流）,L_fix（定长编码参数）,L（相同比特流长度参数）
% 输出：compress_bits（压缩比特流）

len_bits = length(origin_bits); %统计原始比特流的长度
ori_t = 0; %计数，已遍历原始比特流的数目
compress_bits = zeros(); %用来记录压缩比特流
comp_t = 0;%计数，压缩比特流的长度
while ori_t<len_bits 
    bit = origin_bits(ori_t+1); %相同的比特值
    same_bits = 0; %用来记录相同比特的个数
    comp_L = zeros(); %用来记录一串相同字符的压缩比特流
    %---------------------------统计相同比特的个数--------------------------%
    for i=ori_t+1:len_bits 
        if origin_bits(i) == bit
            same_bits = same_bits+1;
        else
            break;
        end
    end
    %--------------------------相同比特流长度小于4--------------------------%
    if same_bits<L
        comp_L(1) = 0; %前缀标记(1位:0)
        if ori_t+L_fix<=len_bits
            comp_L(2:L_fix+1) = origin_bits(ori_t+1:ori_t+L_fix);
            same_bits = L_fix;
        else
            re = len_bits - ori_t;
            comp_L(2:re+1) = origin_bits(ori_t+1:ori_t+re);
            same_bits = re;
        end
    %------------------------相同比特流长度大于等于4------------------------%
    else %same_bits>=L
        L_pre = floor(log2(same_bits)); %前缀标记位
        for i=1:L_pre-1
            comp_L(i) = 1;
        end
        comp_L(L_pre) = 0; %前缀标记：1…10（L_pre位）
        l = same_bits-2^(L_pre); %剩余比特流
        bin_l = dec2bin(l)-'0'; %转换成二进制
        len_l = length(bin_l);
        comp_L(2*L_pre-len_l+1:2*L_pre) = bin_l; %记录剩余比特流的数目
        comp_L(2*L_pre+1) = bit; %记录压缩比特流的比特值
    end
    %-------------------------记录压缩的相同比特流--------------------------%
    len_L = length(comp_L); %计算相同比特流的压缩长度
    compress_bits(comp_t+1:comp_t+len_L) = comp_L;
    comp_t = comp_t + len_L;
    ori_t = ori_t + same_bits;
end

