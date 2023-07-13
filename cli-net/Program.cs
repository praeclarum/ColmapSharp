using ColmapSharp;
using Foundation;

using var w = new StreamWriter("../alog.txt");
Console.SetOut(w);

Console.WriteLine($"Hello ColmapSharp! {DateTime.Now}");

// Colmap.RunAutomaticReconstruction("", "");
