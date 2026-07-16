# Slay the Spire 2 Linux Auto-Splitter Setup (Flatpak Steam)

By default, Flatpak Steam isolates its games inside secure sandboxes. If you run LiveSplit separately on Linux, it is "blind" to Slay the Spire 2's active memory and cannot read the game logs.

This guide teaches you how to run LiveSplit **inside** the game's secure sandbox using native Proton features. This method requires **zero** security overrides or filesystem holes on your Linux host.

*Note: The `LiveSplit.SlayTheSpire2.asl` script included in this repository already contains all the necessary hardcoded Linux path translations and C# compiler fixes required to run flawlessly under Wine/Proton.*

---

## Step 1: Move LiveSplit into the Game's Sandbox

Steam already has full permission to read and write inside its own sandbox. By moving LiveSplit inside the game's virtual C: drive, Steam can launch it natively.

1. Open your Linux file manager.
2. Place your entire `LiveSplit` folder inside the game's virtual Windows C: drive folder (press Ctrl + H in your file manager to show hidden files):
   ~/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/compatdata/2868840/pfx/drive_c/
3. Download the corrected `LiveSplit.SlayTheSpire2.asl` script from this repository and save it directly inside that newly placed `LiveSplit` folder.

---

## Step 2: Configure Steam to Inject LiveSplit

Instead of launching LiveSplit manually, we use Proton's developer tools to force Steam to launch LiveSplit inside the exact same process space as the game.

1. Open Steam.
2. Right-click Slay the Spire 2 -> Properties...
3. Under the General tab, scroll down to the Launch Options text box.
4. Paste this exact line (make sure to replace YOUR_USERNAME with your actual Linux/Fedora username):

PROTON_REMOTE_DEBUG_CMD="/home/YOUR_USERNAME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/compatdata/2868840/pfx/drive_c/LiveSplit/LiveSplit.exe" %command%

---

## Step 3: Configure Your LiveSplit Layout

Because LiveSplit is now running inside the sandbox, its "My Computer" interface sees the virtual C: drive.

1. Launch Slay the Spire 2 from Steam.
   (Note: Slay the Spire 2 will start, and a second later, LiveSplit will automatically pop up on your screen on its own!)
2. Right-click LiveSplit -> Edit Layout...
3. Double-click the Scriptable Auto Splitter component. Click Browse... and navigate to:
   My Computer -> Local Disk (C:) -> LiveSplit -> LiveSplit.SlayTheSpire2.asl
4. Click OK to save the script settings.
5. **Add the Splits Display UI:** In the Layout Editor, click the "+" button -> List -> Splits. (If you omit this, the timer will tick but you won't visually see your individual segment rows update).
6. Click OK to save your Layout.
7. Right-click LiveSplit -> Compare Against -> Ensure Game Time is checked. (This is mandatory; if set to Real Time, the timer will ignore the script and sit frozen at 0.00).

---

## Step 4: Configure Your Splits Count (Prevent Timer Freezing)

The auto-splitter script doesn't know what Act you are currently playing; it blindly sends a "move down one row" signal to LiveSplit every time a boss (like the Kaiser Crab) is defeated. If LiveSplit receives a split signal while it is on its final configured row, it assumes your run is completed and permanently pauses the timer.

1. Right-click LiveSplit -> Edit Splits...
2. Click Insert Below until you have a segment row created for every single boss you plan to encounter during a successful run (e.g., "Act 1 Boss", "Act 2 Boss", "Act 3 Boss").
3. Ensure the total number of rows exactly matches or exceeds the number of bosses you will fight, or the timer will freeze mid-run.
4. Click OK to save your split file.

---

### How to Test
Start a New Run in Slay the Spire 2 and hit Embark. The second you load onto Floor 1, the timer will automatically spring to life!
