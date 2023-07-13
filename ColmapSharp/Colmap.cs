using System.Runtime.InteropServices;
using System.Runtime.Serialization;

namespace ColmapSharp;

#pragma warning disable CA2101

public enum Quality { Low, Medium, High, Extreme }

public static class Colmap
{
    const string Lib = "libcolmap";

    public static void RunAutomaticReconstruction(string imagesDirectory, string workDirectory, Quality quality = Quality.High, string cameraModel = "SIMPLE_RADIAL", bool dense = false)
    {
        var r = colmapAutomaticReconstruction(imagesDirectory, workDirectory, (int)quality, cameraModel, dense);
        if (r != 0)
        {
            throw new ColmapException(r);
        }
    }

    [DllImport(Lib, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    static extern int colmapAutomaticReconstruction(string imagesDirectory, string workDirectory, int quality, string cameraModel, bool dense);
}

[Serializable]
public class ColmapException : Exception
{
    public readonly int ExitCode;
    public ColmapException(int exitCode)
        : base($"COLMAP failed with exit code {exitCode}")
    {
        ExitCode = exitCode;
    }
}
