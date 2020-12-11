# Reversible Data Hiding in Encrypted Images Based on Pixel Prediction and Bit-plane Compression

This code is the implementation of the paper "Reversible Data Hiding in Encrypted Images Based on Multi-MSB Prediction and Huffman Coding".

[Paper Link](https://ieeexplore.ieee.org/abstract/document/9178468)

## Abstract

Reversible data hiding in encrypted images (RDHEI) receives growing attention because it protects the content of the original image while the embedded data can be accurately extracted and the original image can be reconstructed losslessly. To make full use of the correlation of the adjacent pixels, this paper proposes an RDHEI scheme based on pixel prediction and bit-plane compression. Firstly, the original image are divided into the blocks of equal size and the prediction error of the original image is calculated. Then, the 8 bit-planes of prediction error are executed rearrangement and bit-stream compression, respectively. Finally, the image after vacating room is encrypted by a stream cipher and the additional data is embedded in the vacated room by multi-LSBs (Least Significant Bits) substitution. Experimental results show that the embedding capacity of the proposed method outperforms the state-of-the-art methods.

## 摘要
密文域可逆信息隐藏（RDHEI）受到越来越多的关注，因为它可以保护原始图像的内容，同时可以准确地提取嵌入的数据，并且可以无损地重建原始图像。 为了充分利用相邻像素的相关性，本文提出了一种基于像素预测和位平面压缩的RDHEI方案。 首先，将原始图像分成相等大小的块，并计算原始图像的预测误差。 然后，分别执行8个预测误差的位平面的重排和位流压缩。 最后，通过流密码对腾出空间后的图像进行加密，并通过多LSB（最低有效位）替换将附加数据嵌入到腾出的空间中。 实验结果表明，该方法的嵌入能力优于现有方法。

## How to cite our paper

    @article{yin2020reversible,
      title={Reversible Data Hiding in Encrypted Images Based on Pixel Prediction and Bit-plane Compression},
      author={Yin, Zhaoxia and Peng, Yinyin and Xiang, Youzhi},
      journal={IEEE Transactions on Dependable and Secure Computing},
      year={2020},
      publisher={IEEE}
    }
