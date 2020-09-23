# Reversible Data Hiding in Encrypted Images Based on Pixel Prediction and Bit-plane Compression

This code is the implementation of the paper "Reversible Data Hiding in Encrypted Images Based on Multi-MSB Prediction and Huffman Coding".

[Paper Link](https://ieeexplore.ieee.org/abstract/document/9178468)

## Abstract

Reversible data hiding in encrypted images (RDHEI) receives growing attention because it protects the content of the original image while the embedded data can be accurately extracted and the original image can be reconstructed losslessly. To make full use of the correlation of the adjacent pixels, this paper proposes an RDHEI scheme based on pixel prediction and bit-plane compression. Firstly, the original image are divided into the blocks of equal size and the prediction error of the original image is calculated. Then, the 8 bit-planes of prediction error are executed rearrangement and bit-stream compression, respectively. Finally, the image after vacating room is encrypted by a stream cipher and the additional data is embedded in the vacated room by multi-LSBs (Least Significant Bits) substitution. Experimental results show that the embedding capacity of the proposed method outperforms the state-of-the-art methods.

## How to cite our paper

    @article{yin2020reversible,
      title={Reversible Data Hiding in Encrypted Images Based on Pixel Prediction and Bit-plane Compression},
      author={Yin, Zhaoxia and Peng, Yinyin and Xiang, Youzhi},
      journal={IEEE Transactions on Dependable and Secure Computing},
      year={2020},
      publisher={IEEE}
    }
