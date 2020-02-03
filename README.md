# White Matter Injury detection in pre-term infant brain MRI

Injury to the white matter regions in infant brains may serve as early predictors of developmental deficits. This project detects WMI from T1 MR images of pre-term infants, which is specially challenging due to lack of brain atlas, small size of the brain, short scan duration and their constant movement during scanning. This creates very low-resolution and extremely noisy MR images, making this project challenging. I developed the first fully automated WMI detection method that does not require brain atlas and heuristically approximates tissue segmentation, greatly reducing computation.

Please cite the below [paper](https://doi.org/10.1007/s11517-018-1829-9) if you use the code in its original or modified form:

*S. Mukherjee, I. Cheng, S. Miller, T. Guo, V. Chau, and A. Basu, “A fast segmentation-free fully automated approach to white matter injury detection in preterm infants,” Medical & Biological Engineering & Computing, vol. 57, no. 1, pp. 71–87, Jul. 2018.*

# Guidelines

1. [final_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/final_journal.m) is the per-slice WMI detection code. This is referred to as "coarse detection" in the [paper](https://doi.org/10.1007/s11517-018-1829-9).
2. [combine_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/combine_journal.m) combines detection results from adjacent slices by calling [final_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/final_journal.m) on each slice, followed by a call to [Evaluate.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/Evaluate.m), and finally integrating the results.  This is referred to as "fine detection" in the [paper](https://doi.org/10.1007/s11517-018-1829-9).
3. Please refer to [final_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/final_journal.m) and [combine_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/combine_journal.m) to understand how to provide input slice and ground truth images and how to name them.
4. [final_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/final_journal.m) calls [anisodiff2D.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/anisodiff2D.m) to denoise the input image. You can comment out this call or tune the parameters passed to [anisodiff2D.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/anisodiff2D.m) from [final_journal.m](https://github.com/subhayanmukherjee/fastwmi/blob/master/final_journal.m) depending on how noisy your input images actually are.
