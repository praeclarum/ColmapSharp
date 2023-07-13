using System.Text.Json;
using System.Text.Json.Serialization;
using ColmapSharp;

#if __MACOS__
using var output = new StreamWriter("../aout.txt");
using var error = new StreamWriter("../aerr.txt");
Console.SetOut(output);
Console.SetError(error);
#endif

Console.WriteLine($"COLMAP");

try {
    if (args.Length != 2) {
        Console.WriteLine("Usage: colmap <imagesDirectory> <workDirectory>");
        return;
    }
    var imagesDirectory = args[0];
    var workDirectory = args[1];
    var rec = Colmap.RunAutomaticReconstruction(imagesDirectory, workDirectory);
    Console.WriteLine(JsonSerializer.Serialize(rec));
}
catch (Exception e) {
    Console.WriteLine(e);
}
