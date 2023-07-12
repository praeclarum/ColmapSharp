using System.Runtime.InteropServices;

namespace ColmapSharp;

#pragma warning disable CA2101

public static class Colmap
{
    const string Lib = "libcolmap";

    public static void RunAutomaticReconstruction(string imagesDirectory, string workDirectory)
    {
        if (colmapAutomaticReconstruction(imagesDirectory, workDirectory) != 0)
        {
            throw new Exception("Colmap failed");
        }
    }

    [DllImport(Lib, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    static extern int colmapAutomaticReconstruction(string imagesDirectory, string workDirectory);
}
