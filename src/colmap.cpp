#include <stdint.h>
#include <cstdio>
using namespace std;

#include "base/reconstruction.h"
#include "controllers/automatic_reconstruction.h"
using namespace colmap;

extern "C" {

int32_t colmapAutomaticReconstruction(const char *image_path, const char *workspace_path, int32_t quality, const char *camera_model, bool dense)
{
    AutomaticReconstructionController::Options reconstruction_options;
    reconstruction_options.image_path = image_path;
    reconstruction_options.workspace_path = workspace_path;
    reconstruction_options.quality = (AutomaticReconstructionController::Quality)quality;
    reconstruction_options.use_gpu = false;
    reconstruction_options.dense = dense;
    reconstruction_options.camera_model = camera_model;
    ReconstructionManager reconstruction_manager;

    AutomaticReconstructionController controller(reconstruction_options,
                                                 &reconstruction_manager);
    controller.Start();
    controller.Wait();

    return reconstruction_manager.Size() == 1 ? 0 : 1;
}

}
