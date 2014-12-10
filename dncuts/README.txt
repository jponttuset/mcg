
This is sandbox code for the "DNCuts" (Downsampled Normalized Cuts) part of Multiscale Combinatorial Grouping, CVPR 2014

Here we demonstrate a technique for taking an affinity matrix from an image (where each pixel in the image is a row/column of the affinity matrix) and efficiently approximating the eigenvectors of the Laplacian of that graph, a la Normalized Cuts.

Run "go.m" to see the technique in progress. This script uses a simple affinity measure, not the kind used in the CVPR 2014 paper, as this code is just meant to demonstrate the effectiveness of the eigenvector computation. The affinity measure can be swapped out for most commonly used affinity measures for segmentation, such as http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html. If everything works correctly, you should see true NCuts eigenvectors for the image, and fast eigenvectors from our method, and the fast eigenvectors should be roughly 20x faster to compute (though the exact speedup is heavily dependent on the connectivity of the affinity matrix and the parameters for DNCuts).

Email questions about this code and technique to Jon Barron (jonbarron@gmail.com), but please direct all questions regarding the rest of the Multiscale Combinatorial Grouping paper to Pablo Abelaez (arbelaez@berkeley.edu).