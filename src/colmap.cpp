#include <stdint.h>
#include <cstdio>
#include <exception>
using namespace std;

#include "base/reconstruction.h"
#include "controllers/automatic_reconstruction.h"
using namespace colmap;

namespace colmap {
    extern void (*colmapPrintHeading1Callback)(const std::string& heading);
    extern void (*colmapPrintHeading2Callback)(const std::string& heading);
}

static int32_t progressCurrent = 0;
static int32_t progressTotal = 0;
static void (*progressAutomaticReconstruction)(int32_t, int32_t) = nullptr;

static void PrintHeading1(const std::string& heading) {
    // fprintf(stderr, "H1 %s\n", heading.c_str());
    if (progressAutomaticReconstruction != nullptr) {
        progressCurrent++;
        progressTotal = max(progressCurrent + 1, progressTotal);
        progressAutomaticReconstruction(progressCurrent, progressTotal);
    }
}
static void PrintHeading2(const std::string& heading) {
    // fprintf(stderr, "H2 %s\n", heading.c_str());
}


extern "C" {

int32_t colmapAutomaticReconstruction(const char *image_path, const char *workspace_path, int32_t quality, const char *camera_model, bool dense, void (*progress)(int32_t, int32_t))
{
    try {
        progressAutomaticReconstruction = progress;
        colmap::colmapPrintHeading1Callback = PrintHeading1;
        colmap::colmapPrintHeading2Callback = PrintHeading2;
        progressCurrent = 0;
        progressTotal = 10;
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

        auto result = reconstruction_manager.Size() == 1 ? 0 : 2;

        progress(progressTotal, progressTotal);
        progressAutomaticReconstruction = nullptr;

        return result;
    }
    catch (runtime_error &ex) {
        fprintf(stderr, "Runtime error: %s\n", ex.what());
        return 1;
    }
}

}
