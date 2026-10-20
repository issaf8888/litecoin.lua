--[[
    ===================================================================
    ⚡ LITECOIN THEMED ROBLOX LOADER & GAME SELECTOR
    ===================================================================
    Features:
      • Animated GIF Loading Screen am Start (smooth Spritesheet)
      • Litecoin-Style Gradient Line (Grau -> Blau -> Grau) oben am Menü
      • Logo zentriert oben
      • Titel "CHOOSE GAME MA DRILLA"
      • Button "RIVALS" & Button "SOON"
      • Glatte Tween-Animationen & Hover-Effekte
      • Vollständig draggable (verschiebbar)
      • Kompatibel mit Executor (getcustomasset / CoreGui) & Roblox Studio (PlayerGui)
    ===================================================================
--]]

-- [[ KONFIGURATION ]] --
local Config = {
    -- Trage hier deinen GitHub Benutzernamen und dein Repo ein:
    -- Beispiel: "https://raw.githubusercontent.com/MaxMustermann/MeinLoader/main"
    GitHubUser = "issaf8888",
    GitHubRepo = "litecoin.lua",
    GitHubBranch = "main",

    -- Lokale Dateinamen (werden automatisch von GitHub geladen):
    SpritesheetFile = "spritesheet.png",
    LogoFile = "logo.png",

    -- Zeit wie lange der Loading Screen das GIF abspielt (in Sekunden)
    LoadingDuration = 2.8,

    -- Spritesheet Eigenschaften (für das 40-Frame GIF):
    TotalFrames = 40,
    Columns = 6,
    Rows = 7,
    FrameWidth = 150,
    FrameHeight = 100,
    FrameTime = 0.06, -- 60ms pro Frame

    -- Menü Farben (Litecoin Theme):
    Theme = {
        Background = Color3.fromRGB(18, 19, 28),
        CardBackground = Color3.fromRGB(25, 27, 39),
        ButtonBackground = Color3.fromRGB(32, 35, 52),
        ButtonHover = Color3.fromRGB(45, 50, 75),
        
        -- Litecoin Blau & Grau:
        LitecoinBlue = Color3.fromRGB(52, 120, 215),
        LitecoinDarkBlue = Color3.fromRGB(34, 65, 120),
        GreyMuted = Color3.fromRGB(105, 110, 125),
        GreyLight = Color3.fromRGB(214, 216, 225),
        
        TextPrimary = Color3.fromRGB(245, 247, 252),
        TextSecondary = Color3.fromRGB(145, 150, 168),
        
        Border = Color3.fromRGB(48, 52, 74),
        BorderActive = Color3.fromRGB(60, 130, 230),
    }
}

-- [[ SERVICES ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ ASSET HELPER MIT GITHUB AUTO-DOWNLOAD ]] --
local function getAsset(fileName)
    local customAssetFunc = (getcustomasset or (syn and syn.getcustomasset))
    
    -- 1. Automatischer Download von GitHub, falls die Datei noch nicht lokal existiert
    if writefile and isfile then
        if not isfile(fileName) then
            pcall(function()
                local rawUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", 
                    Config.GitHubUser, 
                    Config.GitHubRepo, 
                    Config.GitHubBranch, 
                    fileName
                )
                local data = game:HttpGet(rawUrl)
                if data and #data > 0 then
                    writefile(fileName, data)
                end
            end)
        end
    end

    -- 2. Lokales Laden über Executor Asset Funktion
    if customAssetFunc and isfile and isfile(fileName) then
        local success, result = pcall(function()
            return customAssetFunc(fileName)
        end)
        if success and result then
            return result
        end
    end

    return fileName
end

local SpritesheetImage = getAsset(Config.SpritesheetFile)
local LogoImage = getAsset(Config.LogoFile)

-- [[ SCREEN GUI CONTAINER ]] --
-- Wählt CoreGui / gethui() für Executoren oder PlayerGui für Studio
local parentContainer = nil
if gethui then
    parentContainer = gethui()
elseif game:GetService("CoreGui") and pcall(function() return game:GetService("CoreGui").Name end) then
    parentContainer = game:GetService("CoreGui")
elseif LocalPlayer then
    parentContainer = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end

-- Alten ScreenGui ggf. entfernen falls schon vorhanden
if parentContainer and parentContainer:FindFirstChild("LitecoinLoaderUI") then
    parentContainer:FindFirstChild("LitecoinLoaderUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LitecoinLoaderUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentContainer

-- ===================================================================
-- 1. LOADING SCREEN (NUR DAS GIF)
-- ===================================================================
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.Position = UDim2.new(0, 0, 0, 0)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
LoadingScreen.BackgroundTransparency = 0
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 50
LoadingScreen.Parent = ScreenGui

-- Container für das zentrierte GIF
local GifContainer = Instance.new("Frame")
GifContainer.Name = "GifContainer"
GifContainer.AnchorPoint = Vector2.new(0.5, 0.5)
GifContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
GifContainer.Size = UDim2.new(0, 360, 0, 240)
GifContainer.BackgroundTransparency = 1
GifContainer.Parent = LoadingScreen

local GifLabel = Instance.new("ImageLabel")
GifLabel.Name = "GifDisplay"
GifLabel.Size = UDim2.new(1, 0, 1, 0)
GifLabel.BackgroundTransparency = 1
GifLabel.Image = SpritesheetImage
GifLabel.ScaleType = Enum.ScaleType.Fit
GifLabel.ImageRectSize = Vector2.new(Config.FrameWidth, Config.FrameHeight)
GifLabel.ImageRectOffset = Vector2.new(0, 0)
GifLabel.Parent = GifContainer

local GifCorner = Instance.new("UICorner")
GifCorner.CornerRadius = UDim.new(0, 12)
GifCorner.Parent = GifContainer

-- Animierter Glow-Effekt um das GIF
local GifGlow = Instance.new("UIStroke")
GifGlow.Thickness = 2
GifGlow.Color = Config.Theme.LitecoinBlue
GifGlow.Transparency = 0.5
GifGlow.Parent = GifContainer

-- Spritesheet Animation Loop
local isPlayingGif = true
task.spawn(function()
    local currentFrame = 0
    while isPlayingGif and ScreenGui.Parent do
        local col = currentFrame % Config.Columns
        local row = math.floor(currentFrame / Config.Columns)
        
        GifLabel.ImageRectOffset = Vector2.new(
            col * Config.FrameWidth,
            row * Config.FrameHeight
        )
        
        currentFrame = (currentFrame + 1) % Config.TotalFrames
        task.wait(Config.FrameTime)
    end
end)

-- ===================================================================
-- 2. HAUPTMENÜ (LOADER)
-- ===================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 480, 0, 340)
MainFrame.BackgroundColor3 = Config.Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Config.Theme.Border
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- -------------------------------------------------------------------
-- OBERER COLOR-FADE STRICH: Grau -> Litecoin Blau -> Grau
-- -------------------------------------------------------------------
local TopGlowBar = Instance.new("Frame")
TopGlowBar.Name = "TopGlowBar"
TopGlowBar.Size = UDim2.new(1, 0, 0, 3)
TopGlowBar.Position = UDim2.new(0, 0, 0, 0)
TopGlowBar.BorderSizePixel = 0
TopGlowBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopGlowBar.ZIndex = 5
TopGlowBar.Parent = MainFrame

local TopGradient = Instance.new("UIGradient")
TopGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Config.Theme.GreyMuted),
    ColorSequenceKeypoint.new(0.50, Config.Theme.LitecoinBlue),
    ColorSequenceKeypoint.new(1.00, Config.Theme.GreyMuted)
})
TopGradient.Parent = TopGlowBar

-- Schließen-Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -36, 0, 10)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Config.Theme.TextSecondary
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 10
CloseButton.Parent = MainFrame

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Config.Theme.TextSecondary}):Play()
end)
CloseButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- -------------------------------------------------------------------
-- LOGO (OBEN IN DER MITTE)
-- -------------------------------------------------------------------
local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.AnchorPoint = Vector2.new(0.5, 0)
LogoContainer.Position = UDim2.new(0.5, 0, 0, 24)
LogoContainer.Size = UDim2.new(0, 240, 0, 60)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = MainFrame

local LogoImageLabel = Instance.new("ImageLabel")
LogoImageLabel.Name = "Logo"
LogoImageLabel.Size = UDim2.new(1, 0, 1, 0)
LogoImageLabel.BackgroundTransparency = 1
LogoImageLabel.Image = LogoImage
LogoImageLabel.ScaleType = Enum.ScaleType.Fit
LogoImageLabel.Parent = LogoContainer

-- -------------------------------------------------------------------
-- TEXT: "choose game ma drilla"
-- -------------------------------------------------------------------
local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "Subtitle"
SubtitleLabel.AnchorPoint = Vector2.new(0.5, 0)
SubtitleLabel.Position = UDim2.new(0.5, 0, 0, 92)
SubtitleLabel.Size = UDim2.new(1, -40, 0, 24)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "CHOOSE GAME MA DRILLA"
SubtitleLabel.TextColor3 = Config.Theme.TextPrimary
SubtitleLabel.TextSize = 15
SubtitleLabel.Font = Enum.Font.GothamBold
SubtitleLabel.TextTransparency = 0.05
SubtitleLabel.Parent = MainFrame

-- Kleiner dezenter Trennstrich
local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.AnchorPoint = Vector2.new(0.5, 0)
Divider.Position = UDim2.new(0.5, 0, 0, 126)
Divider.Size = UDim2.new(0.8, 0, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local DividerGradient = Instance.new("UIGradient")
DividerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 27, 39)),
    ColorSequenceKeypoint.new(0.50, Config.Theme.Border),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 27, 39))
})
DividerGradient.Parent = Divider

-- -------------------------------------------------------------------
-- BUTTONS CONTAINER
-- -------------------------------------------------------------------
local ButtonsContainer = Instance.new("Frame")
ButtonsContainer.Name = "ButtonsContainer"
ButtonsContainer.AnchorPoint = Vector2.new(0.5, 0)
ButtonsContainer.Position = UDim2.new(0.5, 0, 0, 146)
ButtonsContainer.Size = UDim2.new(1, -60, 0, 150)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.Parent = MainFrame

local ButtonsList = Instance.new("UIListLayout")
ButtonsList.Padding = UDim.new(0, 14)
ButtonsList.FillDirection = Enum.FillDirection.Vertical
ButtonsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonsList.SortOrder = Enum.SortOrder.LayoutOrder
ButtonsList.Parent = ButtonsContainer

-- Funktion zum Erstellen eines stylischen Buttons
local function createButton(name, title, subtitle, isAvailable, onClickCallback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 56)
    btn.BackgroundColor3 = Config.Theme.ButtonBackground
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.ClipsDescendants = true
    btn.Parent = ButtonsContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1.2
    btnStroke.Color = Config.Theme.Border
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = btn

    -- Linker Akzentbalken
    local btnAccent = Instance.new("Frame")
    btnAccent.Name = "Accent"
    btnAccent.Size = UDim2.new(0, 4, 1, 0)
    btnAccent.Position = UDim2.new(0, 0, 0, 0)
    btnAccent.BorderSizePixel = 0
    btnAccent.BackgroundColor3 = isAvailable and Config.Theme.LitecoinBlue or Config.Theme.GreyMuted
    btnAccent.Parent = btn

    -- Haupt-Titel des Buttons
    local btnTitle = Instance.new("TextLabel")
    btnTitle.Name = "Title"
    btnTitle.Position = UDim2.new(0, 20, 0, 10)
    btnTitle.Size = UDim2.new(0.6, 0, 0, 20)
    btnTitle.BackgroundTransparency = 1
    btnTitle.Text = title
    btnTitle.TextColor3 = isAvailable and Config.Theme.TextPrimary or Config.Theme.GreyLight
    btnTitle.TextSize = 16
    btnTitle.Font = Enum.Font.GothamBold
    btnTitle.TextXAlignment = Enum.TextXAlignment.Left
    btnTitle.Parent = btn

    -- Untertitel / Status
    local btnSub = Instance.new("TextLabel")
    btnSub.Name = "Subtitle"
    btnSub.Position = UDim2.new(0, 20, 0, 30)
    btnSub.Size = UDim2.new(0.6, 0, 0, 16)
    btnSub.BackgroundTransparency = 1
    btnSub.Text = subtitle
    btnSub.TextColor3 = Config.Theme.TextSecondary
    btnSub.TextSize = 12
    btnSub.Font = Enum.Font.Gotham
    btnSub.TextXAlignment = Enum.TextXAlignment.Left
    btnSub.Parent = btn

    -- Status Tag (Rechts)
    local tagFrame = Instance.new("Frame")
    tagFrame.Name = "Tag"
    tagFrame.AnchorPoint = Vector2.new(1, 0.5)
    tagFrame.Position = UDim2.new(1, -16, 0.5, 0)
    tagFrame.Size = UDim2.new(0, 72, 0, 26)
    tagFrame.BackgroundColor3 = isAvailable and Color3.fromRGB(24, 48, 86) or Color3.fromRGB(35, 36, 45)
    tagFrame.BorderSizePixel = 0
    tagFrame.Parent = btn

    local tagCorner = Instance.new("UICorner")
    tagCorner.CornerRadius = UDim.new(0, 6)
    tagCorner.Parent = tagFrame

    local tagText = Instance.new("TextLabel")
    tagText.Size = UDim2.new(1, 0, 1, 0)
    tagText.BackgroundTransparency = 1
    tagText.Text = isAvailable and "LAUNCH" or "SOON"
    tagText.TextColor3 = isAvailable and Config.Theme.LitecoinBlue or Config.Theme.GreyMuted
    tagText.TextSize = 11
    tagText.Font = Enum.Font.GothamBold
    tagText.Parent = tagFrame

    -- Hover-Animationen
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Theme.ButtonHover
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {
            Color = isAvailable and Config.Theme.BorderActive or Config.Theme.GreyLight
        }):Play()
        TweenService:Create(btnAccent, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 6, 1, 0)
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Theme.ButtonBackground
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {
            Color = Config.Theme.Border
        }):Play()
        TweenService:Create(btnAccent, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 4, 1, 0)
        }):Play()
    end)

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(0.98, 0, 0, 54)
        }):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 0, 56)
        }):Play()
        if onClickCallback then
            onClickCallback()
        end
    end)

    return btn
end

-- 1. Button: RIVALS
local RivalsButton = createButton(
    "RivalsButton",
    "RIVALS",
    "Ready to execute script",
    true,
    function()
        print("[Litecoin Loader] RIVALS Spiel ausgewählt!")
        -- HIER DEINEN RIVALS CODE / SCRIPT EINFÜGEN:
        -- z.B.: loadstring(game:HttpGet("..."))()
    end
)

-- 2. Button: SOON
local SoonButton = createButton(
    "SoonButton",
    "SOON",
    "In development...",
    false,
    function()
        print("[Litecoin Loader] Slot ist noch in Entwicklung (SOON)!")
    end
)

-- -------------------------------------------------------------------
-- DRAGGABLE FUNKTION (Verschiebbares Fenster)
-- -------------------------------------------------------------------
local function makeDraggable(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(MainFrame)

-- ===================================================================
-- 3. TRANSITION: LOADING SCREEN -> HAUPTMENÜ
-- ===================================================================
task.spawn(function()
    -- Lässt das GIF für die eingestellte Dauer laufen
    task.wait(Config.LoadingDuration)

    -- GIF Animation stoppen
    isPlayingGif = false

    -- Loading Screen sanft ausblenden
    local fadeOutLoading = TweenService:Create(LoadingScreen, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    local fadeOutGif = TweenService:Create(GifLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 1
    })
    local fadeOutGlow = TweenService:Create(GifGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1
    })

    fadeOutLoading:Play()
    fadeOutGif:Play()
    fadeOutGlow:Play()

    fadeOutLoading.Completed:Connect(function()
        LoadingScreen:Destroy()
    end)

    task.wait(0.2)

    -- Hauptmenü mit Pop-in Animation einblenden
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 420, 0, 300)
    MainFrame.BackgroundTransparency = 1
    MainStroke.Transparency = 1

    local fadeInMenu = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 480, 0, 340),
        BackgroundTransparency = 0
    })
    local fadeInStroke = TweenService:Create(MainStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0
    })

    fadeInMenu:Play()
    fadeInStroke:Play()
end)

print("[Litecoin Loader] Erfolgreich geladen!")
