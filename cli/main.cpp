#include <cstdio>
using namespace std;

#include "base/reconstruction.h"
#include "controllers/automatic_reconstruction.h"
using namespace colmap;

extern "C" {
    int32_t colmapAutomaticReconstruction(const char *image_path, const char *workspace_path, int32_t quality, const char *camera_model, bool dense, void (*progress)(int32_t, int32_t));
}

int main(int argc, char** argv) {
    printf("COLMAP!\n");
    return colmapAutomaticReconstruction(
        "/Users/fak/work/colmap1in",
        "/Users/fak/work/colmap1_2");
}
