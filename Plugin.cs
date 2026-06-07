using BepInEx;
using BepInEx.Logging;
using HarmonyLib;
using System.Reflection;

[assembly: AssemblyVersion("0.10.13")]
[assembly: AssemblyMetadata("AI_Assisted_Creation", "This assembly was partially created with the assistance of generative AI for packaging, refactoring, and documentation.")]
[assembly: AssemblyMetadata("AI_Model_Vendor", "OpenAI")]

namespace Cinnamon
{
    [BepInPlugin("com.osqat.cinnamon", "Cinnamon", "0.10.13")]
    public class Plugin : BaseUnityPlugin
    {
        internal static ManualLogSource Log;
        internal static string VersionString => Assembly.GetExecutingAssembly().GetName().Version.ToString(3) + " (Thunderstore)";

        void Awake()
        {
            Log = Logger;
            Log.LogInfo($"[Cinnamon] loaded v{VersionString}.");
            new Harmony("com.osqat.cinnamon").PatchAll();
        }
    }
}
