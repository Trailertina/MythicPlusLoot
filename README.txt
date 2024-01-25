This version is in beta!

I've tried to make a simple addon that easily tracks loot in M+ dungeons.
Why? Because I'm too lazy to look though chat, find correct person and manually filter their loot for the item I want to inspect.
This addon only shows gear and weapons in the loot frame.


Future improvements:
- Only show loot equippable by class.


Known bugs/issues:
- Players not looting anything relevant sometimes shows up in loot frame anyway (looting sparks, gold etc.).
- Loot frame position not saved from previous session and resets each time you log-in or use /reload.

Bug fixes as of 25-01-2024:

Header Hiding:
Issue: Loot window's header unintentionally hidden with other dynamic content during FontString element hiding.
Fix: Modified code to exclude loot window's header FontString from being hidden.
Impact: Ensures that only specific FontString elements are hidden, preserving the loot window's appearance and functionality.

Dragging Reset:
Issue: Loot frame previously reset to creation point after dragging when new loot was stored in the frame.
Fix: Implemented code to make the loot frame remember the last place it was dragged to.
Impact: Provides a more user-friendly experience by retaining the last dragged position of the loot frame.

Borders Stuck:
Issue: Loot frame borders were getting stuck in the last place the frame was moved to.
Fix: Resolved the issue causing borders to get stuck after moving the frame.
Impact: Ensures smooth movement of the loot frame without it getting stuck in the last position.

Whisper-Button Functionality:
Issue: Whisper button function lacked consistency.
Fix: Updated the whisper button functionality for improved consistency.
Impact: Provides a more reliable and predictable behavior when interacting with the whisper button.

Loot History Printing:
Issue: Loothistory printed multiple times when new loot was registered, creating a text cluster.
Fix: Adjusted the code to prevent multiple prints of loot history for the same loot.
Impact: Ensures cleaner and more organized loot history display without unnecessary repetitions.

Group Exit Lua Error:
Issue: Opening the loot frame after leaving a group or after group members left caused a Lua error.
Fix: Implemented code to handle group exit scenarios gracefully and prevent Lua errors.
Impact: Eliminates Lua errors during loot frame opening after leaving a group, ensuring a smoother user experience.

Previous Run Loot Display:
Issue: Loot frame displayed loot from the previous run, without resetting.
Fix: Updated the code to reset the loot frame when starting a new Mythic+ run.
Impact: Ensures that the loot frame accurately reflects the loot from the current run and prevents display of outdated information from previous runs.
