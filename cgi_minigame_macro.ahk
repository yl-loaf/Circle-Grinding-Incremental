#Requires AutoHotkey v2.0
; coded by ylche
; #skibidi toilet
; #SIX SEVEN AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
; coded at 3 am


; Init
GreenClickerActive := false
BoundarySet := false
BoundaryTopLeftX := 0
BoundaryTopLeftY := 0
BoundaryBottomRightX := A_ScreenWidth
BoundaryBottomRightY := A_ScreenHeight
ClickOffset := 30 ; Pixels to offset diagonally bottom-right
SelectedGreenColor := 0x003B00  ; Default color

CheckForUpdates()
tooltip("Macro starting...", 100, 100)
Sleep Random(1000, 3000)
tooltip("loading ui...")
Sleep Random(500, 1000)
tooltip("")
global GreenClickerActive, SelectedGreenColor
ShowColorSelectionUI()


; Color Selection UI
ShowColorSelectionUI() {
    global SelectedGreenColor
    
    ; Create the GUI window
    colorGui := Gui()
    colorGui.Title := "Green Clicker - Color Selection"
    colorGui.Opt("+AlwaysOnTop +ToolWindow")

    
    ; Add instructions
    colorGui.Add("Text", "w300", "Please select the green color to click:")
    colorGui.Add("Text", "w300", "• Enter RGB hex (e.g., 003B00)")
    colorGui.Add("Text", "w300", "• Or press F8 to pick from screen")
    colorGui.Add("Text", "w300", "• Or click Skip to use default (003B00)")
    colorGui.Add("Text", "w300", "• F9 = Set top-left corner of your click area")
    colorGui.Add("Text", "w300", "• F10 = Set bottom-right corner of your click area")  
    colorGui.Add("Text", "w300", "• Press F6 to start clicking!")     
    
    ; Add input field
    colorGui.Add("Text",, "RGB Hex Color:")
    colorEdit := colorGui.Add("Edit", "w100 vColorInput", "003B00")
    
    ; Add buttons in a row
    buttonsRow := colorGui.Add("Text", "w300")
    pickBtn := colorGui.Add("Button", "xm w80", "&Pick Color (F8)")
    okBtn := colorGui.Add("Button", "x+10 w80", "&OK")
    skipBtn := colorGui.Add("Button", "x+10 w80", "&Skip")
    
    ; Button events
    pickBtn.OnEvent("Click", (*) => PickColorFromScreen(colorGui, colorEdit))
    okBtn.OnEvent("Click", (*) => ValidateAndClose(colorGui, colorEdit.Value))
    skipBtn.OnEvent("Click", (*) => SkipColorSelection(colorGui))
    
    ; Also allow F8 key to pick color and Enter to submit
    colorGui.OnEvent("Escape", (*) => SkipColorSelection(colorGui))
    colorEdit.OnEvent("Change", (*) => colorEdit.Value := RegExReplace(colorEdit.Value, "[^0-9A-Fa-f]", ""))
    
    ; Show the GUI
    colorGui.Show()
    
    ; Wait for user input
    WinWaitClose(colorGui)
}

PickColorFromScreen(gui, editControl) {
    gui.Hide()
    ToolTip("Click on the green color you want to detect...")
    KeyWait("LButton", "D")
    MouseGetPos(&mouseX, &mouseY)
    pixelColor := PixelGetColor(mouseX, mouseY)
    
    ; Convert BGR to RGB for display
    rgbColor := SubStr(pixelColor, 3)  ; Remove 0x prefix
    rgbColor := SubStr(rgbColor, 5, 2) . SubStr(rgbColor, 3, 2) . SubStr(rgbColor, 1, 2)
    
    editControl.Value := rgbColor
    ToolTip()
    gui.Show()
}

ValidateAndClose(gui, colorInput) {
    colorInput := RegExReplace(colorInput, "[^0-9A-Fa-f]", "")  ; Remove non-hex characters
    
    if (StrLen(colorInput) != 6) {
        MsgBox("Please enter a valid 6-digit hex color (e.g., 003B00)", "Invalid Color", 0x30)
        return
    }
    
    ; Convert RGB to BGR for the script
    bgrColor := "0x" . SubStr(colorInput, 5, 2) . SubStr(colorInput, 3, 2) . SubStr(colorInput, 1, 2)
    global SelectedGreenColor := bgrColor
    
    gui.Destroy()
}

SkipColorSelection(gui) {
    global SelectedGreenColor := 0x003B00  ; Use default color
    gui.Destroy()
}

; F6 hotkey to toggle green clicker within boundary
F6:: {
    global GreenClickerActive, SelectedGreenColor
    GreenClickerActive := !GreenClickerActive
    
    if GreenClickerActive {
        ToolTip("Green Clicker ACTIVE - Color: " . Format("0x{:06X}", SelectedGreenColor) . " - Press F6 to stop", 10, 10)
        SetTimer(ClickGreenPixels, 5)
    } else {
        ToolTip()
        SetTimer(ClickGreenPixels, 0)
    }
}

; F9: Set top-left boundary corner
F9:: {
    global BoundaryTopLeftX, BoundaryTopLeftY, BoundarySet
    MouseGetPos(&BoundaryTopLeftX, &BoundaryTopLeftY)
    BoundarySet := true
    ToolTip("Top-Left Boundary Set: " BoundaryTopLeftX ", " BoundaryTopLeftY, 10, 30)
    SetTimer(() => ToolTip(), 2000)
}

; F10: Set bottom-right boundary corner
F10:: {
    global BoundaryBottomRightX, BoundaryBottomRightY, BoundarySet
    MouseGetPos(&BoundaryBottomRightX, &BoundaryBottomRightY)
    BoundarySet := true
    ToolTip("Bottom-Right Boundary Set: " BoundaryBottomRightX ", " BoundaryBottomRightY, 10, 50)
    SetTimer(() => ToolTip(), 2000)
}

; F11: Reset boundary to full screen
F11:: {
    global BoundaryTopLeftX, BoundaryTopLeftY, BoundaryBottomRightX, BoundaryBottomRightY, BoundarySet
    BoundaryTopLeftX := 0
    BoundaryTopLeftY := 0
    BoundaryBottomRightX := A_ScreenWidth
    BoundaryBottomRightY := A_ScreenHeight
    BoundarySet := false
    ToolTip("Boundary Reset to Full Screen", 10, 70)
    SetTimer(() => ToolTip(), 2000)
}

; F12: Show current boundary and adjust offset
F12:: {
    global BoundaryTopLeftX, BoundaryTopLeftY, BoundaryBottomRightX, BoundaryBottomRightY, BoundarySet, ClickOffset
    if BoundarySet {
        ToolTip("Boundary: " BoundaryTopLeftX "," BoundaryTopLeftY " to " BoundaryBottomRightX "," BoundaryBottomRightY " | Offset: " ClickOffset "px", 10, 90)
    } else {
        ToolTip("Boundary: Full Screen | Offset: " ClickOffset "px", 10, 90)
    }
    SetTimer(() => ToolTip(), 3000)
}

; Adjust offset (F3: decrease, F4: increase)
F3:: {
    global ClickOffset
    ClickOffset := Max(0, ClickOffset - 5) ; Min 0
    ToolTip("Offset: " ClickOffset "px", 10, 110)
    SetTimer(() => ToolTip(), 1500)
}

F4:: {
    global ClickOffset
    ClickOffset := Min(100, ClickOffset + 5) ; Max 100
    ToolTip("Offset: " ClickOffset "px", 10, 110)
    SetTimer(() => ToolTip(), 1500)
}

CheckForUpdates() {
    ; --- Configure your URLs here ---
    CurrentVersion := "1.2" ; Your script's current version
    VersionFileURL := "https://github.com/yl-loaf/Circle-Grinding-Incremental/blob/main/version.txt"
    NewScriptURL   := "https://github.com/yl-loaf/Circle-Grinding-Incremental/blob/main/cgi_minigame_macro.ahk"
    
    try {
        ; Create an HTTP request object
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", VersionFileURL)
        whr.Send()
        whr.WaitForResponse()
        
        LatestVersion := Trim(whr.ResponseText)
        
        if (CurrentVersion != LatestVersion) {
            result := MsgBox("A new version v" LatestVersion " is available. Would you like to update?", "Update Available", "Yes/No")
            if (result = "Yes")
       {
    if Download(NewScriptURL, A_ScriptDir "\YourMacro_" LatestVersion ".ahk")
    {
        MsgBox("Update downloaded successfully! New file saved as YourMacro_" LatestVersion ".ahk")
    }
    else
    {
        MsgBox("Download failed!")
    }
}
        }
    }
}


ClickGreenPixels() {
    global GreenClickerActive, BoundaryTopLeftX, BoundaryTopLeftY, BoundaryBottomRightX, BoundaryBottomRightY, ClickOffset
    
    if !GreenClickerActive {
        return
    }
    
    greenColor := 0x003B00
    colorVariation := 3 ; smol variation to prevent misclik
    
    ; Search boundary for green 
    if PixelSearch(&foundX, &foundY, BoundaryTopLeftX, BoundaryTopLeftY, BoundaryBottomRightX, BoundaryBottomRightY, greenColor, colorVariation) {
        ; Store current mouse position
        MouseGetPos(&originalX, &originalY)
        
        ; Apply offset 
        targetX := foundX + ClickOffset + Random(-10, 10)
        targetY := foundY + ClickOffset + Random(-10, 10)
        
        ; PrevEnt click outside 
        targetX := Min(targetX, A_ScreenWidth - 1)
        targetY := Min(targetY, A_ScreenHeight - 1)
        
        ; Move to offset pos and click
        MouseMove(targetX, targetY, 0)
        Click("Left")
        Click("Down")
        Sleep 10
        
        ; Debug tooltip (shows original and offset positions)
        ToolTip("Found: " foundX "," foundY "`nClicked: " targetX "," targetY, targetX + 10, targetY + 10)
        SetTimer(() => ToolTip(), 500)
        Sleep 1

    }
}

; Show color at cursor position for debugging (press F8)
F8:: {
    MouseGetPos(&mouseX, &mouseY)
    pixelColor := PixelGetColor(mouseX, mouseY)
    ToolTip("Color at " mouseX "," mouseY ": " pixelColor, mouseX + 10, mouseY + 10)
    SetTimer(() => ToolTip(), 3000)
}

; E stop with Esc
Esc:: {
    global GreenClickerActive
    if GreenClickerActive {
        GreenClickerActive := false
        SetTimer(ClickGreenPixels, 0)
        ToolTip("Clicker stopped", 100, 100)
        Sleep 1000
    }
    ToolTip("Exiting app...", 100, 100)
    Sleep Random(1500, 3000)
    ExitApp
}

Tab:: {
    global AutoClickingTrue
    global nump
    AutoClickingTrue := false
    if AutoClickingTrue {
        AutoClickingTrue := false
        nump := false
    }
    else{
        nump := true
        While nump
        Click("Left")
        Sleep 1
    }
}