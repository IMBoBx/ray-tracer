#!/bin/bash
set -e

WIDTHS=(400 400 400 400 720 720 720 720 1080 1080 1080 1080)
SPPS=(  64 128 256 500  64 128 256 500   64  128  256  500)

RESULTS="cpu_results.csv"
echo "width,spp,time_s" > "$RESULTS"

for i in "${!WIDTHS[@]}"; do
    W=${WIDTHS[$i]}
    S=${SPPS[$i]}
    echo "Running: width=$W spp=$S"

    sed -i "s/cam\.image_width\s*=\s*[0-9]*/cam.image_width       = $W/" main.cpp
    sed -i "s/cam\.samples_per_pixel\s*=\s*[0-9]*/cam.samples_per_pixel = $S/" main.cpp

    g++ -O2 -o raytracer_cpu *.cpp

    TIME=$(./raytracer_cpu 2>&1 >/dev/null | grep "Render time" | awk '{print $3}')
    echo "$W,$S,$TIME" >> "$RESULTS"
    echo "  -> ${TIME}s"
done

echo "Done. Results written to $RESULTS"