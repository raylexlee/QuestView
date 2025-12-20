# QuestView (Vanilla WoW 1.12.1 Addon)

QuestView is a lightweight addon for the Vanilla 1.12.1 client that lets you view quest text in a scrollable, copy‑friendly window. Perfect for accessibility workflows like sending quest text to a text‑to‑speech (TTS) webapp.

## ✨ Features
- `/qv [quest title]` opens the quest description + objectives in a custom frame.
- Scrollable window for long quests.
- **Select All** button highlights the entire quest text automatically.
- Auto‑highlight on open: just press `Ctrl‑C` to copy and paste into your TTS tool.
- Close button to dismiss the frame.

## 📂 Installation
1. Download or clone this repository.
2. Place the `QuestView` folder into your WoW `Interface/AddOns` directory.
3. Ensure the folder contains:
   - `QuestView.toc`
   - `QuestView.lua`

Example path:
World of Warcraft/Interface/AddOns/QuestView/

## 📝 Usage
In game, type:
/qv [quest title]

Code
Example:
/qv Smart Drinks

A window will appear with the quest text. Click **Select All** or use the auto‑highlight, then press `Ctrl‑C` to copy. Paste into your favorite TTS webapp to have the quest read aloud.

## ⚙️ TOC File
```toc
## Interface: 11200
## Title: QuestView
## Notes: View quest text in a custom frame via /qv [quest title]
## Author: Raylex & Copilot
QuestView.lua
📜 License
MIT License — free to use, modify, and share.
