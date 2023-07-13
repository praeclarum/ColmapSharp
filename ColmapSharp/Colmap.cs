using System.Numerics;
using System.Runtime.InteropServices;
using System.Runtime.Serialization;

namespace ColmapSharp;

#pragma warning disable CA2101

public enum Quality { Low, Medium, High, Extreme }

/// <summary>
/// Represents a single image in the sparse reconstruction.
///
/// The reconstructed pose of an image is specified as the projection from world to the camera coordinate system of an image using a quaternion (QW, QX, QY, QZ) and a translation vector (TX, TY, TZ).
/// The quaternion is defined using the Hamilton convention, which is, for example, also used by the Eigen library.
/// The coordinates of the projection/camera center are given by -R^t * T, where R^t is the inverse/transpose of the 3x3 rotation matrix composed from the quaternion and T is the translation vector.
/// The local camera coordinate system of an image is defined in a way that the X axis points to the right, the Y axis to the bottom, and the Z axis to the front as seen from the image.
/// </summary>
public record Image(int Id, double QW, double QX, double QY, double QZ, double TX, double TY, double TZ, int CameraId, string Name) {
    public static Image? ReadLine(string line) {
        var icult = System.Globalization.CultureInfo.InvariantCulture;
        if (string.IsNullOrWhiteSpace(line)) {
            return null;
        }
        var parts = line.Split(' ');
        if (parts.Length < 9) {
            return null;
        }
        if (parts[0][0] == '#') {
            return null;
        }
        return new Image(
            int.Parse(parts[0]),
            double.Parse(parts[1], icult),
            double.Parse(parts[2], icult),
            double.Parse(parts[3], icult),
            double.Parse(parts[4], icult),
            double.Parse(parts[5], icult),
            double.Parse(parts[6], icult),
            double.Parse(parts[7], icult),
            int.Parse(parts[8]),
            string.Join(' ', parts[9..])
        );
    }
    public static Image[] ReadImagesFromFile(string filePath) {
        var lines = File.ReadAllLines(filePath);
        var images = new List<Image>();
        for (int i = 0; i < lines.Length; i++) {
            string? line = lines[i];
            var image = ReadLine(line);
            if (image != null) {
                images.Add(image);
                i++;
            }
        }
        return images.ToArray();
    }
}

public record Camera(int Id, string Model, int Width, int Height, double[] Params) {
}

public record Reconstruction(Image[] Images) {

}

public static class Colmap
{
    const string Lib = "libcolmap";

    public static Reconstruction RunAutomaticReconstruction(string imagesDirectory, string workDirectory, Quality quality = Quality.High, string cameraModel = "SIMPLE_RADIAL", bool dense = false)
    {
        var r = colmapAutomaticReconstruction(imagesDirectory, workDirectory, (int)quality, cameraModel, dense);
        if (r != 0)
        {
            throw new ColmapException(r);
        }
        var imagesPath = Path.Combine(workDirectory, "sparse", "0", "images.txt");
        var images = Image.ReadImagesFromFile(imagesPath);
        return new Reconstruction(images);
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
