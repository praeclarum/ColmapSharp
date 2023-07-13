using System.Text.Json;
using System.Text.Json.Serialization;
using ColmapSharp;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;

#if __MACOS__
using var output = new StreamWriter("../aout.txt");
using var error = new StreamWriter("../aerr.txt");
Console.SetOut(output);
Console.SetError(error);
#endif

Console.WriteLine($"COLMAP");

[UnmanagedCallersOnly(CallConvs = new[] { typeof(CallConvCdecl) })]
static void Progress(int current, int total) => Console.WriteLine($"Program Progress: {current}/{total}");

try {
    if (args.Length != 2) {
        Console.WriteLine("Usage: colmap <imagesDirectory> <workDirectory>");
        return;
    }
    var imagesDirectory = args[0];
    var workDirectory = args[1];
    unsafe {
        var rec = Colmap.RunAutomaticReconstruction(imagesDirectory, workDirectory, progress: &Progress);
    Console.WriteLine(JsonSerializer.Serialize(rec));
    }
}
catch (Exception e) {
    Console.WriteLine(e);
}
