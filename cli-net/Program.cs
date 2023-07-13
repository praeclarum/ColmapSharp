using ColmapSharp;

using var output = new StreamWriter("../aout.txt");
using var error = new StreamWriter("../aerr.txt");
Console.SetOut(output);
Console.SetError(error);

Console.WriteLine($"Hello ColmapSharp! {DateTime.Now}");

try {
    Colmap.RunAutomaticReconstruction("", "");
}
catch (Exception e) {
    Console.WriteLine(e);
}
