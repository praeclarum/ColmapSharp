#include <cstdio>
using namespace std;

#include "base/reconstruction.h"
#include "controllers/automatic_reconstruction.h"
using namespace colmap;

int main(int argc, char** argv) {
    printf("COLMAP!\n");
    AutomaticReconstructionController::Options reconstruction_options;
    ReconstructionManager reconstruction_manager;

    AutomaticReconstructionController controller(reconstruction_options,
                                                 &reconstruction_manager);
    controller.Start();
    controller.Wait();
    return 0;
}
