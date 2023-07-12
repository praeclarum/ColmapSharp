#include <stdint.h>
#include <cstdio>
using namespace std;

#include "base/reconstruction.h"
#include "controllers/automatic_reconstruction.h"
using namespace colmap;

extern "C" {

int32_t colmapAutomaticReconstruction(const char *image_path, const char *workspace_path)
{
    AutomaticReconstructionController::Options reconstruction_options;
    reconstruction_options.image_path = "/Users/fak/work/colmap1in";
    reconstruction_options.workspace_path = "/Users/fak/work/colmap1_2";
    reconstruction_options.use_gpu = false;
    ReconstructionManager reconstruction_manager;

    AutomaticReconstructionController controller(reconstruction_options,
                                                 &reconstruction_manager);
    controller.Start();
    controller.Wait();

    return 0;
}

}
