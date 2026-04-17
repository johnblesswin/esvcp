# Secret Images

This folder contains sample binary secret images used in the ESVCP paper experiments.

## Contents

- `mnist_0.png` through `mnist_9.png` — MNIST digits (28×28, binarised)
- `pattern_checkerboard.png` — Checkerboard test pattern (64×64)
- `pattern_random.png` — Random binary pattern (256×256)

## Source

MNIST digits are from:
> LeCun, Y., Cortes, C., & Burges, C. J. (1998). The MNIST database of handwritten digits.
> http://yann.lecun.com/exdb/mnist/

These images are used in accordance with the original Creative Commons Attribution-Share Alike 3.0 licence.

## Usage in ESVCP

```matlab
secret_img  = imread('data/secret_images/mnist_7.png');
secret_bits = imbinarize(rgb2gray(secret_img));
secret_bits = secret_bits(:);
```
