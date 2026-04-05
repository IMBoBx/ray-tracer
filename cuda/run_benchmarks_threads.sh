#!/bin/bash
set -e

THREAD_X=(4 8  16 32  8 4  64)
THREAD_Y=(4 8  16  8 32 64  4)

RESULTS="thread_results.csv"
echo "tx,ty,time_s" > "$RESULTS"

# fix width and spp first
sed -i "s/cam\.image_width\s*=\s*[0-9]*/cam.image_width       = 1080/" main.cu
sed -i "s/cam\.samples_per_pixel\s*=\s*[0-9]*/cam.samples_per_pixel = 500/" main.cu

for i in "${!THREAD_X[@]}"; do
    TX=${THREAD_X[$i]}
    TY=${THREAD_Y[$i]}
    echo "Running: threads=${TX}x${TY}"

    sed -i "s/dim3 threads([0-9]*, [0-9]*, 1)/dim3 threads($TX, $TY, 1)/" Camera.cuh

    nvcc -O2 -o raytracer_cuda *.cu

    TIME=$(./raytracer_cuda 2>&1 >/dev/null | grep "Render time" | awk '{print $3}')
    echo "$TX,$TY,$TIME" >> "$RESULTS"
    echo "  -> ${TIME}s"
done

echo "Done. Results written to $RESULTS"