-- [ ========== EXECUTION  ========== ] --

if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 189707 then return end

ENV = (getgenv and getgenv())
if ENV.VG_LOADED then return end
if ENV then ENV.VG_LOADED = true end

-- [ ========== SERVICES & REFERENCES  ========== ] --

CR = cloneref or function(object) return object end
CORE = CR(game:GetService("CoreGui"))
GUISERVICE = CR(game:GetService("GuiService"))
HTTP = CR(game:GetService("HttpService"))
TS = CR(game:GetService("TweenService"))
RUNSERVICE = CR(game:GetService("RunService"))
PLAYERS = CR(game:GetService("Players"))
WORKSPACE = CR(game:GetService("Workspace"))

LOCAL_PLAYER = PLAYERS.LocalPlayer
UNIBAR = CORE:WaitForChild("TopBarApp"):WaitForChild("TopBarApp"):WaitForChild("UnibarLeftFrame"):WaitForChild("UnibarMenu"):WaitForChild("2"):WaitForChild("Unibar")
ROBLOX = CORE:WaitForChild("TopBarApp"):WaitForChild("TopBarApp"):WaitForChild("MenuIconHolder"):WaitForChild("TriggerPoint"):WaitForChild("IconHitArea")

VG_SG = Instance.new("ScreenGui")
VG_SG.IgnoreGuiInset = true
VG_SG.ResetOnSpawn = false
VG_SG.Parent = CORE

-- [ ========== SETTINGS  ========== ] --

SETTINGS_PATH = "[ND] VANGUARD/options.json"

VG_SETTINGS = {
    AntiFling = false,
    AntiPartFling = false,
    TpTool = false,
    AntiFallDamage = false,
    AntiEarthquake = false,
    AntiVolcano = false,
    AntiAvalanche = false,
    AntiMeteor = false,
    AntiFire = false,
    AntiFloodAndVoid = false,
    PredictingDisasters = false
}

if not isfolder("[ND] VANGUARD") then
    makefolder("[ND] VANGUARD")
end

function RESET_SETTINGS()
    local data = {}
    for key, value in pairs(VG_SETTINGS) do
        data[key] = value
    end
    return data
end

function EDIT_SETTING(data)
    pcall(function()
        writefile(SETTINGS_PATH, HTTP:JSONEncode(data))
    end)
end

function READ_SETTING()
    local success, data = pcall(function()
        if not isfile(SETTINGS_PATH) then return nil end
        return HTTP:JSONDecode(readfile(SETTINGS_PATH))
    end)

    if not success or type(data) ~= "table" then
        data = RESET_SETTINGS()
        EDIT_SETTING(data)
        return data
    end

    local changed = false
    for key, default in pairs(VG_SETTINGS) do
        if data[key] == nil or type(data[key]) ~= type(default) then
            data[key] = default
            changed = true
        end
    end

    if changed then EDIT_SETTING(data) end
    return data
end

function SET_SETTING(key, value)
    local default = VG_SETTINGS[key]
    if default == nil or type(value) ~= type(default) then return end

    local data = READ_SETTING()
    data[key] = value
    EDIT_SETTING(data)
end

function GET_SETTING(key)
    if VG_SETTINGS[key] == nil then return nil end
    return READ_SETTING()[key]
end

-- [ ========== SOUND EFFECTS  ========== ] --

VG_SOUND = Instance.new("Sound")
VG_SOUND.Looped = false
VG_SOUND.Volume = 1
VG_SOUND.Parent = VG_SG

function Sound(id)
    VG_SOUND:Stop()
    VG_SOUND.SoundId = "rbxassetid://" .. tostring(id)
    VG_SOUND:Play()
end

-- [ ========== NOTIFICATIONS  ========== ] --

notifyId = 0
currentNotification = nil

function Notify(title, text, duration)
    if type(title) ~= "string" then
        title = tostring(title or "")
    end

    if type(text) ~= "string" then
        text = tostring(text or "")
    end

    if type(duration) ~= "number" then
        duration = 1
    end

    notifyId += 1
    local thisId = notifyId

    local notifGui = CORE:FindFirstChild("NotifGui")
    if not notifGui then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "NotifGui"
        notifGui.ResetOnSpawn = false
        notifGui.IgnoreGuiInset = true
        notifGui.Parent = CORE
    end

    if currentNotification and currentNotification.Parent then
        currentNotification:Destroy()
        currentNotification = nil
    end

    local frame = Instance.new("ImageButton")
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0.5, 0, 0.2, -10)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = ROBLOX.BackgroundColor3
    frame.BackgroundTransparency = ROBLOX.BackgroundTransparency
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Image = ""
    frame.Parent = notifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 0
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(213, 215, 221)
    textLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.TextWrapped = true
    textLabel.TextSize = 15
    textLabel.Text = ""
    textLabel.TextTransparency = 1
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = frame

    local progressBackground = Instance.new("Frame")
    progressBackground.Name = "ProgressBackground"
    progressBackground.Size = UDim2.new(1, 0, 0, 3)
    progressBackground.Position = UDim2.new(0, 0, 1, 4)
    progressBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressBackground.BackgroundTransparency = 0.9
    progressBackground.BorderSizePixel = 0
    progressBackground.Parent = frame

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBackground

    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBackground

    local progressCorner2 = Instance.new("UICorner")
    progressCorner2.CornerRadius = UDim.new(1, 0)
    progressCorner2.Parent = progressBar

    currentNotification = frame

    frame.Size = UDim2.new(0, 0, 0, 60)
    frame.BackgroundTransparency = 1
    stroke.Transparency = 1

    local tweenGrow = TS:Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0.42, 0, 0, 60),
            BackgroundTransparency = 0.05
        }
    )

    local tweenStroke = TS:Create(
        stroke,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Transparency = 0.2
        }
    )

    local progressTween = TS:Create(
        progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {
            Size = UDim2.new(0, 0, 1, 0)
        }
    )

    tweenGrow:Play()
    task.wait(0.08)

    stroke.Thickness = 1.5
    tweenStroke:Play()

    textLabel.Text = text

    TS:Create(
        textLabel,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            TextTransparency = 0
        }
    ):Play()

    progressTween:Play()

    local removing = false

    local function removeNotification()
        if removing then return end
        removing = true

        if not frame or not frame.Parent then return end

        progressTween:Cancel()

        TS:Create(
            progressBar,
            TweenInfo.new(0.3, Enum.EasingStyle.Linear),
            {
                Size = UDim2.new(0, 0, 1, 0)
            }
        ):Play()

        task.wait(0.3)

        titleLabel.Text = ""
        textLabel.Text = ""
        progressBackground.BackgroundTransparency = 1

        local frameStroke = frame:FindFirstChildOfClass("UIStroke")
        if frameStroke then
            frameStroke:Destroy()
        end

        local tweenShrinkX = TS:Create(
            frame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, frame.Size.Y.Offset)
            }
        )

        tweenShrinkX:Play()

        tweenShrinkX.Completed:Connect(function()
            if not frame.Parent then return end

            local tweenShrinkY = TS:Create(
                frame,
                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {
                    Size = UDim2.new(0, 0, 0, 0)
                }
            )

            tweenShrinkY:Play()

            tweenShrinkY.Completed:Connect(function()
                if frame then
                    frame:Destroy()
                end

                if currentNotification == frame then
                    currentNotification = nil
                end
            end)
        end)
    end

    frame.MouseButton1Click:Connect(function()
        removeNotification()
    end)

    task.delay(duration, function()
        if thisId ~= notifyId then return end
        removeNotification()
    end)
end

-- [ ========== MAIN INTERFACE  ========== ] --

VG_BUTTON = Instance.new("ImageButton")
VG_BUTTON.Name = HTTP:GenerateGUID(false) .. "_" .. math.random(100000, 999999)
VG_BUTTON.Size = ROBLOX.Size
VG_BUTTON.Position = UDim2.new(1, 8, 0, 0)
VG_BUTTON.BackgroundColor3 = ROBLOX.BackgroundColor3
VG_BUTTON.BackgroundTransparency = ROBLOX.BackgroundTransparency
VG_BUTTON.Parent = UNIBAR

VG_ICON = Instance.new("ImageLabel")
VG_ICON.AnchorPoint = Vector2.new(0.5, 0.5)
VG_ICON.Size = UDim2.new(0.5, 0, 0.5, 0)
VG_ICON.Position = UDim2.new(0.5, 0, 0.5, 0)
VG_ICON.BackgroundTransparency = 1
VG_ICON.Image = "rbxassetid://91221760435176"
VG_ICON.Parent = VG_BUTTON
Instance.new("UICorner", VG_BUTTON).CornerRadius = UDim.new(1, 0)

VG_MENU = Instance.new("Frame")
VG_MENU.AnchorPoint = Vector2.new(0.5, 0.5)
VG_MENU.Name = HTTP:GenerateGUID(false) .. "_" .. math.random(100000, 999999)
VG_MENU.Size = UDim2.new(0.620, 0, 0.620, 0)
VG_MENU.Position = UDim2.new(0.5, 0, 0.55, -20)
VG_MENU.SizeConstraint = Enum.SizeConstraint.RelativeXY
VG_MENU.BackgroundColor3 = ROBLOX.BackgroundColor3
VG_MENU.BackgroundTransparency = ROBLOX.BackgroundTransparency
VG_MENU.BorderSizePixel = 0
VG_MENU.Visible = false
VG_MENU.ClipsDescendants = true
VG_MENU.Parent = VG_SG
Instance.new("UICorner", VG_MENU).CornerRadius = UDim.new(0.05, 0)

VG_TOP = Instance.new("Frame")
VG_TOP.Size = UDim2.new(1, 0, 0, 40)
VG_TOP.BackgroundTransparency = 1
VG_TOP.BorderSizePixel = 0
VG_TOP.Parent = VG_MENU

VG_CLOSE = Instance.new("ImageButton")
VG_CLOSE.Size = UDim2.new(0, 20, 0, 20)
VG_CLOSE.Position = UDim2.new(0, 9, 0.5, -12)
VG_CLOSE.BackgroundTransparency = 1
VG_CLOSE.BorderSizePixel = 0
VG_CLOSE.Image = "rbxasset://textures/ui/InspectMenu/x.png"
VG_CLOSE.Parent = VG_TOP

VG_TITLE = Instance.new("TextLabel")
VG_TITLE.AnchorPoint = Vector2.new(0.5, 0.5)
VG_TITLE.Size = UDim2.new(0.6, 0, 1, 0)
VG_TITLE.Position = UDim2.new(0.5, 0, 0.5, 0)
VG_TITLE.BackgroundTransparency = 1
VG_TITLE.BorderSizePixel = 0
VG_TITLE.Text = "NATURAL DISASTER | VANGUARD"
VG_TITLE.TextColor3 = Color3.new(1, 1, 1)
VG_TITLE.TextScaled = true
VG_TITLE.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
VG_TITLE.Parent = VG_TOP

VG_SCROLL = Instance.new("ScrollingFrame")
VG_SCROLL.Size = UDim2.new(1, 0, 1, -53)
VG_SCROLL.Position = UDim2.new(0, 0, 0.2, -2)
VG_SCROLL.BackgroundTransparency = 1
VG_SCROLL.ScrollBarThickness = 0
VG_SCROLL.AutomaticCanvasSize = Enum.AutomaticSize.Y
VG_SCROLL.BorderSizePixel = 0
VG_SCROLL.Parent = VG_MENU

VG_PAD = Instance.new("UIPadding")
VG_PAD.PaddingTop = UDim.new(0, 5)
VG_PAD.PaddingBottom = UDim.new(0, 3)
VG_PAD.Parent = VG_SCROLL

VG_LAY = Instance.new("UIListLayout")
VG_LAY.FillDirection = Enum.FillDirection.Vertical
VG_LAY.SortOrder = Enum.SortOrder.LayoutOrder
VG_LAY.Padding = UDim.new(0, 1)
VG_LAY.Parent = VG_SCROLL

-- [ ========== MENU & OPTIONS  ========== ] --

VG_TWEEN = nil

function OPEN_VG()
    if VG_TWEEN then VG_TWEEN:Cancel(); VG_TWEEN = nil end

    if VG_MENU.Visible then
        VG_ICON.Image = "rbxassetid://91221760435176"
        local tween = TS:Create(VG_MENU, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        VG_TWEEN = tween
        tween:Play()
        tween.Completed:Once(function()
            if VG_TWEEN == tween then
                VG_MENU.Visible = false
                VG_TWEEN = nil
            end
        end)
    else
        VG_ICON.Image = "rbxassetid://120650226928899"
        VG_MENU.Visible = true
        VG_MENU.Size = UDim2.new(0, 0, 0, 0)
        VG_TWEEN = TS:Create(VG_MENU, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.620, 0, 0.620, 0)
        })
        VG_TWEEN:Play()
    end
end

VG_BUTTON.MouseButton1Click:Connect(function()
    if GUISERVICE.MenuIsOpen then return end
    OPEN_VG()
    Sound("14243105702")
end)
VG_CLOSE.MouseButton1Click:Connect(function()
    OPEN_VG()
    Sound("14243105702")
end)

GUISERVICE.MenuOpened:Connect(function()
    if VG_MENU.Visible then OPEN_VG() end
end)

ROBLOX:GetPropertyChangedSignal("Size"):Connect(function()
    VG_BUTTON.Size = ROBLOX.Size
end)

function ADD_SEPARATOR(name)
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 17)
    separator.BackgroundColor3 = Color3.fromRGB(208, 217, 251)
    separator.BackgroundTransparency = 1
    separator.Parent = VG_SCROLL

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -11, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Text = name
    label.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json")
    label.TextColor3 = Color3.fromRGB(213, 215, 221)
    label.TextScaled = true
    label.Parent = separator

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(61, 62, 65)
    stroke.Thickness = 1
    stroke.Parent = separator
end

function ADD_OPTION(icon, name, callback)
    local enabled = false
    local option = Instance.new("ImageButton")
    option.Size = UDim2.new(1, 0, 0, 40)
    option.BackgroundColor3 = Color3.fromRGB(208, 217, 251)
    option.BackgroundTransparency = 1
    option.AutoButtonColor = false
    option.Parent = VG_SCROLL

    local optionIcon = Instance.new("ImageLabel")
    optionIcon.Size = UDim2.new(0, 20, 0, 20)
    optionIcon.Position = UDim2.new(0, 10, 0, 10)
    optionIcon.BackgroundTransparency = 1
    optionIcon.Image = "rbxassetid://" .. tostring(icon)
    optionIcon.Parent = option

    local optionName = Instance.new("TextLabel")
    optionName.Size = UDim2.new(0.5, 0, 0, 30)
    optionName.Position = UDim2.new(0, 42, 0, 5)
    optionName.BackgroundTransparency = 1
    optionName.BorderSizePixel = 0
    optionName.Text = name
    optionName.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json")
    optionName.TextColor3 = Color3.fromRGB(213, 215, 221)
    optionName.TextSize = 17
    optionName.TextXAlignment = Enum.TextXAlignment.Left
    optionName.Parent = option

    local toggle = Instance.new("ImageButton")
    toggle.Size = UDim2.new(0, 47, 0, 22)
    toggle.Position = UDim2.new(1, -53, 0, 9)
    toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    toggle.BackgroundTransparency = 0.7
    toggle.AutoButtonColor = false
    toggle.Parent = option

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 16, 0, 16)
    ball.Position = UDim2.new(0, 3, 0, 3)
    ball.BackgroundColor3 = Color3.new(1, 1, 1)
    ball.Parent = toggle
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(213, 215, 221)
    toggleStroke.Thickness = 0.5
    toggleStroke.Parent = toggle

    local optionStroke = Instance.new("UIStroke")
    optionStroke.Color = Color3.fromRGB(61, 62, 65)
    optionStroke.Thickness = 1
    optionStroke.Parent = option

    local anim = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function ToggleClick(state)
        state = state == true
        if enabled == state then return end
        enabled = state

        TS:Create(ball, anim, {Position = enabled and UDim2.new(0, 28, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
        TS:Create(toggle, anim, {
            BackgroundColor3 = enabled and Color3.fromRGB(51, 95, 254) or Color3.fromRGB(90, 90, 90),
            BackgroundTransparency = enabled and 0 or 0.7
        }):Play()

        if typeof(callback) == "function" then callback(enabled) end
    end

    toggle.MouseButton1Click:Connect(function()
        Sound("14243105581")
        ToggleClick(not enabled)
    end)
    option.MouseEnter:Connect(function()
        option.BackgroundTransparency = 0.88
        Sound("421058925")
    end)
    option.MouseLeave:Connect(function()
        option.BackgroundTransparency = 1
    end)

    return option, ToggleClick
end

-- [ ========== PHYSICS OWNERSHIP  ========== ] --

VG_SETHIDDEN = sethiddenproperty or sethiddenprop
VG_SETSIMRADIUS = setsimulationradius

function VG_OWNER_PARTS()
    pcall(function() settings().Physics.AllowSleep = false end)
    LOCAL_PLAYER.ReplicationFocus = WORKSPACE

    pcall(function() LOCAL_PLAYER.MaximumSimulationRadius = math.huge end)
    if VG_SETHIDDEN then
        pcall(VG_SETHIDDEN, LOCAL_PLAYER, "MaxSimulationRadius", math.huge)
        pcall(VG_SETHIDDEN, LOCAL_PLAYER, "SimulationRadius", math.huge)
    end
    if VG_SETSIMRADIUS then pcall(VG_SETSIMRADIUS, 9e8, 9e9) end

    for _, other in ipairs(PLAYERS:GetPlayers()) do
        if other ~= LOCAL_PLAYER then
            pcall(function() other.MaximumSimulationRadius = 0 end)
            if VG_SETHIDDEN then
                pcall(VG_SETHIDDEN, other, "MaxSimulationRadius", 0)
                pcall(VG_SETHIDDEN, other, "SimulationRadius", 0)
            end
        end
    end
end

-- [ ========== PARTS HANDLER  ========== ] --

VG_VELOCITY_SETS = {}
VG_VELOCITY_CONNECTION = nil

function VG_REGISTER_VELOCITY(key, parts)
    VG_VELOCITY_SETS[key] = parts
    if VG_VELOCITY_CONNECTION then return end

    VG_VELOCITY_CONNECTION = RUNSERVICE.RenderStepped:Connect(function()
        local character = LOCAL_PLAYER.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local hasParts = false
        for _, partSet in pairs(VG_VELOCITY_SETS) do
            if next(partSet) then
                hasParts = true
                break
            end
        end
        if not hasParts then return end

        VG_OWNER_PARTS()
        for _, partSet in pairs(VG_VELOCITY_SETS) do
            for part in pairs(partSet) do
                if part and part.Parent then
                    local direction = part.Position - root.Position
                    if direction.Magnitude > 0 then
                        part.AssemblyLinearVelocity = direction.Unit * 5000
                    end
                else
                    partSet[part] = nil
                end
            end
        end
    end)
end

function VG_UNREGISTER_VELOCITY(key)
    VG_VELOCITY_SETS[key] = nil
    if next(VG_VELOCITY_SETS) == nil and VG_VELOCITY_CONNECTION then
        VG_VELOCITY_CONNECTION:Disconnect()
        VG_VELOCITY_CONNECTION = nil
    end
end

-- [ ========== EXPLOITER PROTECTIONS  ========== ] --

ADD_SEPARATOR("Protection against exploiters")

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_ANTIFLING_CONNECTION = nil

function AntiFling(state)
    if VG_ANTIFLING_CONNECTION then
        VG_ANTIFLING_CONNECTION:Disconnect()
        VG_ANTIFLING_CONNECTION = nil
    end

    local function SetCharacterCollision(character, canCollide)
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then object.CanCollide = canCollide end
        end
    end

    if not state then
        for _, player in ipairs(PLAYERS:GetPlayers()) do
            if player ~= LOCAL_PLAYER and player.Character then
                SetCharacterCollision(player.Character, true)
            end
        end
        return
    end

    VG_ANTIFLING_CONNECTION = RUNSERVICE.Stepped:Connect(function()
        for _, player in ipairs(PLAYERS:GetPlayers()) do
            if player ~= LOCAL_PLAYER and player.Character then
                SetCharacterCollision(player.Character, false)
            end
        end
    end)
end

AntiFlingOption, TOGGLE_AF = ADD_OPTION(109879831384176, "Anti fling", function(state)
    AntiFling(state)
    SET_SETTING("AntiFling", state)
end)
if GET_SETTING("AntiFling") then TOGGLE_AF(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_ANTIPARTFLING_CONNECTION = nil
VG_ANTIPARTFLING_POST = nil
VG_ANTIPARTFLING_PROCESSED = setmetatable({}, {__mode = "k"})

function AntiPF(state)
    if VG_ANTIPARTFLING_CONNECTION then
        VG_ANTIPARTFLING_CONNECTION:Disconnect()
        VG_ANTIPARTFLING_CONNECTION = nil
    end

    if VG_ANTIPARTFLING_POST then
        VG_ANTIPARTFLING_POST:Disconnect()
        VG_ANTIPARTFLING_POST = nil
    end

    if not state then
        table.clear(VG_ANTIPARTFLING_PROCESSED)
        return
    end

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Blacklist

    local function VG_APF_FILTER(root)
        for _, part in ipairs(root:GetConnectedParts(true)) do
            local model = part:FindFirstAncestorOfClass("Model")
            if model and PLAYERS:GetPlayerFromCharacter(model) then
                return true
            end
        end

        local model = root:FindFirstAncestorOfClass("Model")
        return model and PLAYERS:GetPlayerFromCharacter(model) ~= nil
    end

    local function VG_NEUTRALIZER(part)
        local assemblyRoot = part.AssemblyRootPart

        if not assemblyRoot or VG_ANTIPARTFLING_PROCESSED[assemblyRoot] then
            return
        end

        if VG_APF_FILTER(assemblyRoot) then
            return
        end

        VG_ANTIPARTFLING_PROCESSED[assemblyRoot] = true

        local assembly = assemblyRoot:GetConnectedParts(true)

        pcall(function()
            VG_SETHIDDEN(assemblyRoot, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        end)

        for _, connected in ipairs(assembly) do
            connected.CanCollide = false
            connected.CanTouch = false
            connected.CanQuery = false
            connected.Massless = true

            connected.AssemblyLinearVelocity = Vector3.zero
            connected.AssemblyAngularVelocity = Vector3.zero
            connected.Velocity = Vector3.zero
            connected.RotVelocity = Vector3.zero

            pcall(function()
                VG_SETHIDDEN(connected, "NetworkIsSleeping", true)
                VG_SETHIDDEN(connected, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
            end)

            for _, object in ipairs(connected:GetDescendants()) do
                if object:IsA("Constraint")
                or object:IsA("BodyMover")
                or object:IsA("VectorForce")
                or object:IsA("Torque")
                or object:IsA("AngularVelocity")
                or object:IsA("LinearVelocity")
                or object:IsA("AlignPosition")
                or object:IsA("AlignOrientation") then
                    object:Destroy()
                end
            end
        end
    end

    VG_OWNER_PARTS()

    VG_ANTIPARTFLING_CONNECTION = RUNSERVICE.PreSimulation:Connect(function()
        local character = LOCAL_PLAYER.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if not root then
            return
        end

        VG_OWNER_PARTS()

        overlap.FilterDescendantsInstances = {character}

        local nearby = WORKSPACE:GetPartBoundsInRadius(root.Position, 100, overlap)

        for _, part in ipairs(nearby) do
            if not part:IsA("BasePart") or part.Anchored then
                continue
            end

            local model = part:FindFirstAncestorOfClass("Model")

            if model and PLAYERS:GetPlayerFromCharacter(model) then
                continue
            end

            local velocity = part.AssemblyLinearVelocity.Magnitude
                + part.AssemblyAngularVelocity.Magnitude

            if velocity < 5 then
                continue
            end

            local success, owner = pcall(isnetworkowner, part)

            if success and not owner then
                VG_NEUTRALIZER(part)
            end
        end
    end)

    VG_ANTIPARTFLING_POST = RUNSERVICE.PostSimulation:Connect(function()
        local character = LOCAL_PLAYER.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if root and root.AssemblyLinearVelocity.Magnitude > 75 then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

AntiPartFling, TOGGLE_APF = ADD_OPTION(140519548062693, "Anti part fling", function(state)
    AntiPF(state)
    SET_SETTING("AntiPartFling", state)
end)
if GET_SETTING("AntiPartFling") then TOGGLE_APF(true) end

-- [ ========== DISASTER PROTECTION  ========== ] --

ADD_SEPARATOR("Natural disaster protections")

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_TP_RESPAWN = nil
VG_TP_MOUSE = nil
VG_TP_ENABLED = false

function TT(state)
    VG_TP_ENABLED = state
    if VG_TP_RESPAWN then VG_TP_RESPAWN:Disconnect(); VG_TP_RESPAWN = nil end
    if VG_TP_MOUSE then VG_TP_MOUSE:Disconnect(); VG_TP_MOUSE = nil end

    local function DeleteTool()
        local backpack = LOCAL_PLAYER:FindFirstChild("Backpack")
        local character = LOCAL_PLAYER.Character
        if backpack and backpack:FindFirstChild("VG_TpTool") then backpack.VG_TpTool:Destroy() end
        if character and character:FindFirstChild("VG_TpTool") then character.VG_TpTool:Destroy() end
    end

    if not state then
        DeleteTool()
        return
    end

    local function CreateTool()
        if not VG_TP_ENABLED then return end
        DeleteTool()

        local backpack = LOCAL_PLAYER:WaitForChild("Backpack")
        if not VG_TP_ENABLED then return end

        local tool = Instance.new("Tool")
        tool.Name = "VG_TpTool"
        tool.TextureId = "rbxassetid://91197596847718"
        tool.RequiresHandle = false
        tool.Parent = backpack

        tool.Equipped:Connect(function(mouse)
            if VG_TP_MOUSE then VG_TP_MOUSE:Disconnect(); VG_TP_MOUSE = nil end
            VG_TP_MOUSE = mouse.Button1Down:Connect(function()
                if not mouse.Target then return end
                local character = LOCAL_PLAYER.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local position = mouse.Hit.Position
                    task.wait(0.1)
                    if character.Parent then character:MoveTo(position) end
                end
            end)
        end)

        tool.Unequipped:Connect(function()
            if VG_TP_MOUSE then VG_TP_MOUSE:Disconnect(); VG_TP_MOUSE = nil end
        end)
    end

    CreateTool()
    VG_TP_RESPAWN = LOCAL_PLAYER.CharacterAdded:Connect(function()
        task.defer(CreateTool)
    end)
end

TpTool, TOGGLE_TP = ADD_OPTION(91459053655749, "Tp tool", function(state)
    TT(state)
    SET_SETTING("TpTool", state)
end)
if GET_SETTING("TpTool") then TOGGLE_TP(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_AFD_CONNECTION = nil
VG_AFD_CHAR_ADDED = nil

function AFD(state)
    if VG_AFD_CONNECTION then VG_AFD_CONNECTION:Disconnect(); VG_AFD_CONNECTION = nil end
    if VG_AFD_CHAR_ADDED then VG_AFD_CHAR_ADDED:Disconnect(); VG_AFD_CHAR_ADDED = nil end
    if not state then return end

    local function ConnectCharacter(character)
        task.wait(0.5)
        task.spawn(function()
            local root = character:WaitForChild("HumanoidRootPart", 5)
            if not root or not root.Parent then return end

            if VG_AFD_CONNECTION then VG_AFD_CONNECTION:Disconnect() end
            VG_AFD_CONNECTION = RUNSERVICE.Heartbeat:Connect(function()
                if not root.Parent then
                    if VG_AFD_CONNECTION then VG_AFD_CONNECTION:Disconnect(); VG_AFD_CONNECTION = nil end
                    return
                end

                local velocity = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.zero
                RUNSERVICE.RenderStepped:Wait()
                if root.Parent then root.AssemblyLinearVelocity = velocity end
            end)
        end)
    end

    if LOCAL_PLAYER.Character then ConnectCharacter(LOCAL_PLAYER.Character) end
    VG_AFD_CHAR_ADDED = LOCAL_PLAYER.CharacterAdded:Connect(ConnectCharacter)
end

AntiFall, TOGGLE_AFD = ADD_OPTION(133758309580236, "Anti fall damage", function(state)
    AFD(state)
    SET_SETTING("AntiFallDamage", state)
end)
if GET_SETTING("AntiFallDamage") then TOGGLE_AFD(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_AFL_CONNECTION = nil
VG_AFL_PLATFORM = nil

function AntiFlood(state)
    if VG_AFL_CONNECTION then VG_AFL_CONNECTION:Disconnect(); VG_AFL_CONNECTION = nil end
    if VG_AFL_PLATFORM then VG_AFL_PLATFORM:Destroy(); VG_AFL_PLATFORM = nil end
    if not state then return end

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(2048, 4, 2048)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.Parent = WORKSPACE
    VG_AFL_PLATFORM = platform

    VG_AFL_CONNECTION = RUNSERVICE.RenderStepped:Connect(function()
        local character = LOCAL_PLAYER.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local structure = WORKSPACE:FindFirstChild("Structure")
        local flood = structure and structure:FindFirstChild("FloodLevel")
        local water = WORKSPACE:FindFirstChild("WaterLevel")
        local surfaceY = water and (water.Position.Y - 2.5) or 0
        if flood then surfaceY = math.max(surfaceY, flood.Position.Y - 2.5) end

        platform.Position = Vector3.new(root.Position.X, surfaceY, root.Position.Z)
    end)
end

AntiFloodOption, TOGGLE_AFL = ADD_OPTION(99613377341374, "Anti flood & void", function(state)
    AntiFlood(state)
    SET_SETTING("AntiFloodAndVoid", state)
end)
if GET_SETTING("AntiFloodAndVoid") then TOGGLE_AFL(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_AE_CONNECTIONS = {}
VG_AE_ENABLED = false

function AE(state)
    VG_AE_ENABLED = state
    for _, connection in ipairs(VG_AE_CONNECTIONS) do connection:Disconnect() end
    table.clear(VG_AE_CONNECTIONS)
    if not state then return end

    task.spawn(function()
        local island = WORKSPACE:WaitForChild("Island", 10)
        if not island or not VG_AE_ENABLED then return end

        local function WatchPart(part)
            if not part:IsA("BasePart") then return end
            local connection = part.Changed:Connect(function()
                if VG_AE_ENABLED and part.Parent then
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end)
            table.insert(VG_AE_CONNECTIONS, connection)
        end

        for _, part in ipairs(island:GetChildren()) do WatchPart(part) end
    end)
end

AntiEarthquake, TOGGLE_AE = ADD_OPTION(115887082595551, "Anti earthquake", function(state)
    AE(state)
    SET_SETTING("AntiEarthquake", state)
end)
if GET_SETTING("AntiEarthquake") then TOGGLE_AE(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

local function VG_TRACKER(config)
    local tracker = {Parts = {}, Added = nil, Removing = nil}

    function tracker:Stop()
        if self.Added then self.Added:Disconnect(); self.Added = nil end
        if self.Removing then self.Removing:Disconnect(); self.Removing = nil end
        VG_UNREGISTER_VELOCITY(config.Key)
        table.clear(self.Parts)
    end

    function tracker:Start()
        self:Stop()
        local function AddPart(part)
            if part:IsA("BasePart") and config.Match(part) and not part.Anchored then
                if self.Parts[part] then return end
                part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
                part.CanCollide = false
                self.Parts[part] = true
            end
        end
        local function RemovePart(part)
            self.Parts[part] = nil
        end

        for _, part in ipairs(WORKSPACE:GetDescendants()) do AddPart(part) end
        self.Added = WORKSPACE.DescendantAdded:Connect(AddPart)
        self.Removing = WORKSPACE.DescendantRemoving:Connect(RemovePart)
        VG_REGISTER_VELOCITY(config.Key, self.Parts)
    end

    return tracker
end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_AV_TRACKER = VG_TRACKER({Key = "Volcano", Match = function(part)
    return part.Name == "Lava"
end})
function AntiV(state)
    if state then VG_AV_TRACKER:Start() else VG_AV_TRACKER:Stop() end
end

AntiVolcano, TOGGLE_AV = ADD_OPTION(123443727299935, "Anti volcano", function(state)
    AntiV(state)
    SET_SETTING("AntiVolcano", state)
end)
if GET_SETTING("AntiVolcano") then TOGGLE_AV(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_AA_TRACKER = VG_TRACKER({Key = "Avalanche", Match = function(part)
    return part.Name == "AvalanchePart"
end})

function AntiA(state)
    if state then VG_AA_TRACKER:Start() else VG_AA_TRACKER:Stop() end
end

AntiAvalanche, TOGGLE_AA = ADD_OPTION(133870589231513, "Anti avalanche", function(state)
    AntiA(state)
    SET_SETTING("AntiAvalanche", state)
end)
if GET_SETTING("AntiAvalanche") then TOGGLE_AA(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_AM_TRACKER = VG_TRACKER({Key = "Meteor", Match = function(part)
    return part.Name == "MeteorTemplate"
end})

VG_AM_STRUCTURE_ADDED = nil
VG_AM_STRUCTURE_CHILD_ADDED = nil
VG_AM_STRUCTURE_REMOVING = nil
VG_AM_STRUCTURE_CHILD_REMOVING = nil
VG_AM_FOLDER = nil
VG_AM_FOLDER_ADDED = nil
VG_AM_FOLDER_REMOVING = nil
VG_AM_ENABLED = false

function DISABLE_AM()
    for _, connection in pairs({VG_AM_STRUCTURE_ADDED, VG_AM_STRUCTURE_CHILD_ADDED, VG_AM_STRUCTURE_REMOVING, VG_AM_STRUCTURE_CHILD_REMOVING, VG_AM_FOLDER_ADDED, VG_AM_FOLDER_REMOVING}) do
        if connection then connection:Disconnect() end
    end
    VG_AM_STRUCTURE_ADDED = nil
    VG_AM_STRUCTURE_CHILD_ADDED = nil
    VG_AM_STRUCTURE_REMOVING = nil
    VG_AM_STRUCTURE_CHILD_REMOVING = nil
    VG_AM_FOLDER_ADDED = nil
    VG_AM_FOLDER_REMOVING = nil
    VG_AM_FOLDER = nil
end

local function CONNECT_AM1()
    local structure = WORKSPACE:FindFirstChild("Structure")
    local folder = structure and structure:FindFirstChild("MeteorFolder")
    if not folder or folder == VG_AM_FOLDER then return end

    if VG_AM_FOLDER_ADDED then VG_AM_FOLDER_ADDED:Disconnect(); VG_AM_FOLDER_ADDED = nil end
    if VG_AM_FOLDER_REMOVING then VG_AM_FOLDER_REMOVING:Disconnect(); VG_AM_FOLDER_REMOVING = nil end
    VG_AM_FOLDER = folder

    VG_AM_TRACKER:Stop()

    local function AddPart(part)
        if part:IsA("BasePart") and part.Name == "MeteorTemplate" and not part.Anchored then
            if VG_AM_TRACKER.Parts[part] then return end
            part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
            part.CanCollide = false
            VG_AM_TRACKER.Parts[part] = true
        end
    end
    local function RemovePart(part) VG_AM_TRACKER.Parts[part] = nil end
    for _, part in ipairs(folder:GetDescendants()) do AddPart(part) end
    VG_AM_FOLDER_ADDED = folder.DescendantAdded:Connect(AddPart)
    VG_AM_FOLDER_REMOVING = folder.DescendantRemoving:Connect(RemovePart)
    VG_REGISTER_VELOCITY("Meteor", VG_AM_TRACKER.Parts)
end

function CONNECT_AM2(structure)
    if VG_AM_STRUCTURE_CHILD_ADDED then VG_AM_STRUCTURE_CHILD_ADDED:Disconnect() end
    if VG_AM_STRUCTURE_CHILD_REMOVING then VG_AM_STRUCTURE_CHILD_REMOVING:Disconnect() end
    if VG_AM_STRUCTURE_REMOVING then VG_AM_STRUCTURE_REMOVING:Disconnect() end
    VG_AM_STRUCTURE_CHILD_ADDED = structure.ChildAdded:Connect(function(child)
        if child.Name == "MeteorFolder" then CONNECT_AM1() end
    end)
    VG_AM_STRUCTURE_CHILD_REMOVING = structure.ChildRemoved:Connect(function(child)
        if child == VG_AM_FOLDER then
            if VG_AM_FOLDER_ADDED then VG_AM_FOLDER_ADDED:Disconnect(); VG_AM_FOLDER_ADDED = nil end
            if VG_AM_FOLDER_REMOVING then VG_AM_FOLDER_REMOVING:Disconnect(); VG_AM_FOLDER_REMOVING = nil end
            VG_AM_TRACKER:Stop()
            VG_AM_FOLDER = nil
        end
    end)
    VG_AM_STRUCTURE_REMOVING = structure.AncestryChanged:Connect(function(_, parent)
        if not parent and VG_AM_ENABLED then
            VG_AM_TRACKER:Stop()
            VG_AM_FOLDER = nil
        end
    end)
    CONNECT_AM1()
end

function AntiM(state)
    VG_AM_ENABLED = state
    DISABLE_AM()
    VG_AM_TRACKER:Stop()
    if not state then return end

    local structure = WORKSPACE:FindFirstChild("Structure")
    if structure then CONNECT_AM2(structure) end
    VG_AM_STRUCTURE_ADDED = WORKSPACE.ChildAdded:Connect(function(child)
        if child.Name == "Structure" and VG_AM_ENABLED then CONNECT_AM2(child) end
    end)
end

AntiMeteor, TOGGLE_AM = ADD_OPTION(100312783336875, "Anti meteor", function(state)
    AntiM(state)
    SET_SETTING("AntiMeteor", state)
end)
if GET_SETTING("AntiMeteor") then TOGGLE_AM(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_CURRENT_DESASTER = nil
VG_FIRE_ENABLED = false
VG_FIRE_ADDED = nil
VG_FIRE_REMOVING = nil
VG_FIRE_BOXES = {}

function HasFire(part)
    for _, child in ipairs(part:GetDescendants()) do
        if child:IsA("ParticleEmitter") and child.Name == "Fire" and VG_CURRENT_DESASTER == "Fire" then return true end
    end
    return false
end

function RemoveFireBox(part)
    local box = VG_FIRE_BOXES[part]
    if box then box:Destroy(); VG_FIRE_BOXES[part] = nil end
end

function AddFireBox(part)
    if not VG_FIRE_ENABLED or not part:IsA("BasePart") or VG_FIRE_BOXES[part] or not HasFire(part) then return end

    local box = Instance.new("Part")
    box.Size = part.Size + Vector3.new(5, 5, 5)
    box.CFrame = part.CFrame
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Material = Enum.Material.ForceField
    box.Transparency = 0.6
    box.Anchored = false
    box.Massless = true
    box.CanCollide = true
    box.CanTouch = false
    box.Parent = part

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = box
    weld.Parent = box
    VG_FIRE_BOXES[part] = box
end

function AntiFire(state)
    VG_FIRE_ENABLED = state
    if VG_FIRE_ADDED then VG_FIRE_ADDED:Disconnect(); VG_FIRE_ADDED = nil end
    if VG_FIRE_REMOVING then VG_FIRE_REMOVING:Disconnect(); VG_FIRE_REMOVING = nil end
    for part in pairs(VG_FIRE_BOXES) do RemoveFireBox(part) end
    if not state then return end

    for _, instance in ipairs(WORKSPACE:GetDescendants()) do
        if instance:IsA("BasePart") then AddFireBox(instance) end
    end

    VG_FIRE_ADDED = WORKSPACE.DescendantAdded:Connect(function(instance)
        if instance:IsA("BasePart") then
            AddFireBox(instance)
        elseif instance:IsA("ParticleEmitter") and instance.Name == "Fire" then
            local part = instance:FindFirstAncestorWhichIsA("BasePart")
            if part then AddFireBox(part) end
        end
    end)

    VG_FIRE_REMOVING = WORKSPACE.DescendantRemoving:Connect(function(instance)
        if instance:IsA("BasePart") then
            RemoveFireBox(instance)
        elseif instance:IsA("ParticleEmitter") and instance.Name == "Fire" then
            local part = instance:FindFirstAncestorWhichIsA("BasePart")
            if part then
                task.defer(function()
                    if VG_FIRE_ENABLED and (not part:IsDescendantOf(WORKSPACE) or not HasFire(part)) then
                        RemoveFireBox(part)
                    end
                end)
            end
        end
    end)
end

AntiFireOption, TOGGLE_FIRE = ADD_OPTION(123591308547898, "Anti fire", function(state)
    AntiFire(state)
    SET_SETTING("AntiFire", state)
end)
if GET_SETTING("AntiFire") then TOGGLE_FIRE(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

VG_PD_ENABLED = false
VG_PD_CHILD_ADDED = nil
VG_PD_VALUE_CHANGED = nil
VG_PD_CHAR_ADDED = nil

function DISABLE_PD()
    if VG_PD_CHILD_ADDED then VG_PD_CHILD_ADDED:Disconnect(); VG_PD_CHILD_ADDED = nil end
    if VG_PD_VALUE_CHANGED then VG_PD_VALUE_CHANGED:Disconnect(); VG_PD_VALUE_CHANGED = nil end
end

function PD(state)
    VG_PD_ENABLED = state
end

function PD_MONITOR(character)
    DISABLE_PD()

    local function CheckTag(child)
        if child.Name ~= "SurvivalTag" then return end

        if VG_PD_VALUE_CHANGED then
            VG_PD_VALUE_CHANGED:Disconnect()
            VG_PD_VALUE_CHANGED = nil
        end

        local function Update()
            if not child.Parent then return end

            VG_CURRENT_DESASTER = child.Value

            if VG_PD_ENABLED then
                Notify("Next Disaster", tostring(child.Value), 20)
            end
        end

        Update()
        VG_PD_VALUE_CHANGED = child.Changed:Connect(Update)
    end

    for _, child in ipairs(character:GetChildren()) do
        CheckTag(child)
    end

    VG_PD_CHILD_ADDED = character.ChildAdded:Connect(CheckTag)
end

if LOCAL_PLAYER.Character then
    PD_MONITOR(LOCAL_PLAYER.Character)
end

VG_PD_CHAR_ADDED = LOCAL_PLAYER.CharacterAdded:Connect(PD_MONITOR)

PredictingDisasters, TOGGLE_PD = ADD_OPTION(107893299352180, "Predicting disasters", function(state)
    PD(state)
    SET_SETTING("PredictingDisasters", state)
end)
if GET_SETTING("PredictingDisasters") then TOGGLE_PD(true) end

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --

(function(...)
    local a = string
    local b = tonumber

    local c = "446576656C6F7065642062792054696E6E2028405468654E696D61746F725F48442920E280A2203230323620E280A2204F70656E20536F75726365"

    local d = {}

    for i = 1, #c, 2 do
        d[#d + 1] = a.char(b(c:sub(i, i + 1), 16))
    end

    ADD_SEPARATOR(table.concat(d))
end)(...)

-- =÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷=÷= --
