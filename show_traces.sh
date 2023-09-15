#! /bin/bash

cd /sst-elements/src/sst/elements/balar/tests/vectorAdd

echo "VectorAdd CUDA Program:"
cat vecAdd.cu
echo ""
echo "----------------------------------------------------------"
echo ""

echo "VectorAdd CUDA API traces:"
cat cuda_calls.trace
echo ""
echo "----------------------------------------------------------"
echo ""

echo "Array A data (A[i] = 3):"
xxd -g 4 --len 32 cuMemcpyH2D-0-524288.data
echo ""
echo "----------------------------------------------------------"
echo ""

echo "Array B data (B[i] = 4):"
xxd -g 4 --len 32 cuMemcpyH2D-1-524288.data
echo ""
echo "----------------------------------------------------------"
echo ""

echo "Array C data (C[i] = A[i] + B[i]):"
xxd -g 4 --len 32 cuMemcpyD2H-0-524288.data
echo ""
echo "----------------------------------------------------------"
echo ""

cd /