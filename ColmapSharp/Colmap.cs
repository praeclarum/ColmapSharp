using System.Runtime.InteropServices;

namespace ColmapSharp;

#pragma warning disable CA2101

public enum Quality { Low, Medium, High, Extreme }

public static class Colmap
{
    const string Lib = "libcolmap";

    public static void RunAutomaticReconstruction(string imagesDirectory, string workDirectory, Quality quality = Quality.High, string cameraModel = "SIMPLE_RADIAL", bool dense = false)
    {
        if (colmapAutomaticReconstruction(imagesDirectory, workDirectory, (int)quality, cameraModel, dense) != 0)
        {
            throw new Exception("Colmap failed");
        }
    }

    [DllImport(Lib, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    static extern int colmapAutomaticReconstruction(string imagesDirectory, string workDirectory, int quality, string cameraModel, bool dense);
}
