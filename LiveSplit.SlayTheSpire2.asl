/*
    adapted from Oohbleh's Slay the Spire 1 autosplitter -
    https://github.com/OohBleh/Spire-speedruns-and-other-stuff/blob/main/autosplitters/broken/LiveSplit.SlayTheSpire2.asl
*/

state("SlayTheSpire2") {}

startup
{
    vars.Log = (Action<object>)(output => print("[Slay the Spire 2] " + output));
    vars.TryMatch = (Func<string, string, string>)((value, regex) =>
    {
        var match = System.Text.RegularExpressions.Regex.Match(value, regex);
        if (match.Success)
        {
            return match.Groups[1].Value;
        }
        else
        {
            return null; // Fixed: Changed 'return;' to 'return null;' to satisfy string return type
        }
    });

    dynamic[,] _settings =
    {
        { null, "startSeed",    "Start when generating a new seed", true },
        { null, "resetDeath",   "Reset on deaths/abandons", true },
        { null, "resetClose",   "Reset when game closes", false },
        { null, "bosses",       "Split when defeating a boss", true },
            { "bosses", "VANTOM_BOSS",              "Vantom", true },
            { "bosses", "CEREMONIAL_BEAST_BOSS",    "Ceremonial Beast", true },
            { "bosses", "THE_KIN_BOSS",             "The Kin", true },
            { "bosses", "SOUL_FYSH_BOSS",           "Soul Fysh", true },
            { "bosses", "WATERFALL_GIANT_BOSS",     "Waterfall Giant", true },
            { "bosses", "LAGAVULIN_MATRIARCH_BOSS", "Lagavulin Matriarch", true },
            { "bosses", "THE_INSATIABLE_BOSS",      "The Insatiable", true },
            { "bosses", "KNOWLEDGE_DEMON_BOSS",     "Knowledge Demon", true },
            { "bosses", "KAISER_CRAB_BOSS",         "Kaiser Crab", true },
            { "bosses", "AEONGLASS_BOSS",           "Aeonglass", true },
            { "bosses", "DOORMAKER_BOSS",           "Doormaker (Removed Boss)", true },
            { "bosses", "TEST_SUBJECT_BOSS",        "Test Subject", true },
            { "bosses", "QUEEN_BOSS",               "Queen", true },
    };

    for (int i = 0; i < _settings.GetLength(0); i++)
    {
        var parent = _settings[i, 0];
        var id     = _settings[i, 1];
        var name   = _settings[i, 2];
        var state  = _settings[i, 3];

        settings.Add(id, state, name, parent);
    }
}

init
{
    vars.HasKilledBoss = false;
    var log = @"C:\users\steamuser\AppData\Roaming\SlayTheSpire2\logs\godot.log";
    try
    {
        vars.Reader = new System.IO.StreamReader(new System.IO.FileStream(log, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite));
        vars.Reader.ReadToEnd();
    }
    catch (Exception ex)
    {
        vars.Log("Cannot open Slay the Spire 2 log!");
        vars.Log(ex.Message);
        vars.Reader = null;
    }
    current.Line = "";
    current.LinesInLog = 0;
}

update
{
    if (vars.Reader == null)
    {
        return false;
    }

    current.Line = vars.Reader.ReadLine();

    // Check whether file contents were reset.
    current.LinesInLog = vars.Reader.BaseStream.Length;
    if (old.LinesInLog > current.LinesInLog)
    {
        vars.Reader.BaseStream.Position = 0;
        return false;
    }
}

start
{
    var l = current.Line;

    if (old.Line == l || l == null) return false; // Fixed: Changed 'return;' to 'return false;'

    if (settings["startSeed"])
    {
        return l.Contains("Embarking on a");
    }
    return false;
}

split
{
    var l = current.Line;
    if (old.Line == l || l == null) return false; // Fixed: Changed 'return;' to 'return false;'

    // Split for boss kills.
    string boss = vars.TryMatch(l, "CHARACTER\\..* has won against encounter ENCOUNTER\\.(.*)_BOSS") ?? vars.TryMatch(l, "CHARACTER\\..* fought ENCOUNTER\\.(.*)_BOSS for the first time and WON");
    if (boss != null)
    {
        return settings[boss + "_BOSS"] ?? false;  
    }
    return false;
}

reset
{
    var l = current.Line;

    if (old.Line == l || l == null) return false; // Fixed: Changed 'return;' to 'return false;'

    if (l.Contains("Abandoning an in-progress run (player-initiated)") || l.Contains("has lost to encounter") || l.Contains("Abandoning run from main menu") || l.Contains("for the first time and LOST"))
    {
        vars.HasKilledBoss = false;
        return settings["resetDeath"];
    }
    return false;
}

exit
{
    if (settings["resetClose"])
    {
        if (vars.Reader != null)
        {
            vars.Reader.Close();
        }
    }
}

shutdown
{
    if (vars.Reader != null)
    {
        vars.Reader.Close();
    }
}