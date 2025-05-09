## Loadstring for NDS Script
```lua
getgenv().ndsSettings = {
    ["PredictEnabled"] = true, 
    ["ChatMessage"] = false,
    ["NoStorms"] = true,
    ["NotifyTime"] = 15
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/rocky-rickaby10/Scripts/refs/heads/main/ndsscript.lua"))()
```
