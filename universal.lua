
-- megurgur hub

-- [?] Yield until game is loaded.
if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

-- [?] Acquire Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerService = game:GetService("Players")
-- [?] Acquire LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
-- [?] Declare VisualsTable
local VisualsTable = {
    ["Nametag"] = {
        ["Players"] = {},
        ["NPCs"] = {},
        ["Mobs"] = {}
    }
}
-- [?] Redefine (require) function.
local require; require = function(path)
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Megurgur/Megur-Hub/main/" .. path .. ".lua"))()
end
-- [?] Acquire Iris module
local Iris = require("Iris/Iris").Init()
-- [?] Kill previous Iris windows
function KillPreviousIrisWindows()
    getgenv().IrisDisableFunctions = getgenv().IrisDisableFunctions or {}

    for _, IrisDisabledFunction in getgenv().IrisDisableFunctions do
        IrisDisabledFunction()
    end

    table.insert(getgenv().IrisDisableFunctions, function()
        Iris:Shutdown() 
    end)
end
KillPreviousIrisWindows()
-- [?] Setup new Iris windows
local ShowGui = Iris.State(true)

local CombatStates = {}
local VisualStates = {
    PlayerESP = {
        Enabled = Iris.State(false),
        Color = Iris.State(Color3.new(1,1,0)),
        Size = Iris.State(18),
        Distance = Iris.State(10000)
    },
    MobESP = {
        Enabled = Iris.State(false),
        Color = Iris.State(Color3.new(0.5,0.5,0.25)),
        Size = Iris.State(18),
        Distance = Iris.State(10000)
    },
    NPCESP = {
        Enabled = Iris.State(false),
        Color = Iris.State(Color3.new(1,1,1)),
        Size = Iris.State(18),
        Distance = Iris.State(10000)
    },
}
local MovementStates = {
    SpeedHack = {
        Enabled = Iris.State(false),
        WalkSpeed = Iris.State(50),
        Keybind = Iris.State("")
    },
    InfiniteJump = {
        Enabled = Iris.State(false),
        JumpPower = Iris.State(50),
        Keybind = Iris.State("")
    },
    FlyHack = {
        Enabled = Iris.State(false),
        FlySpeed = Iris.State(50),
        Keybind = Iris.State(""),
        Noclip = {
            Enabled = Iris.State(false)
        }
    },
}
local PlayerStates = {
    AutoLockpick = {
        Enabled = Iris.State(false)
    },
    AutoLoot = {
        Enabled = Iris.State(false)
    }
}
local WorldStates = {}
local GuiStates = {
    HideGui = Iris.State(""),
    ChatLogger = {
        Enabled = Iris.State(false),
        Keybind = Iris.State("")
    }
}
local MiscStates = {}

local ChatMessageLogs = {}
local chattedConnections = {}

function connectChatted(player)
    if chattedConnections[player] then
        chattedConnections[player]:Disconnect()
    end
    chattedConnections[player] = player.Chatted:Connect(function(msg)
        table.insert(ChatMessageLogs, string.format("[%s]: %s", player.Name, msg))
    end)
end

for _, player in PlayerService:GetPlayers() do
    connectChatted(player)
end

PlayerService.PlayerAdded:Connect(connectChatted)
PlayerService.PlayerRemoving:Connect(function(player)
    if chattedConnections[player] then
        chattedConnections[player]:Disconnect()
    end
end)

local rejoinPrompt = false

Iris:Connect(function()
    Iris.Window({"Chat Logger [Megurgur Hub]", false, false, false, true, false, false, false, false, true}, {size = Iris.State(Vector2.new(400,400)), position = Iris.State(Vector2.new(0,0)), isOpened = GuiStates.ChatLogger.Enabled})
        local clearChatLogs = Iris.Button({"Clear Chat Logs"})
        if clearChatLogs.clicked() then
            ChatMessageLogs = {}
        end
        for _, ChatMessageLog in ChatMessageLogs do
            Iris.Text({ChatMessageLog, true})
        end
    Iris.End()

    Iris.Window({"Control Panel [Megurgur Hub]", false, false, false, true, false, false, false, false, true}, {size = Iris.State(Vector2.new(350,500)), position = Iris.State(Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2 - 175, workspace.CurrentCamera.ViewportSize.Y / 2 - 250)), isOpened = ShowGui})
        Iris.CollapsingHeader({ "Combat" })
        Iris.End()
        Iris.CollapsingHeader({ "Visual" })
            -- // PLAYER ESP
            Iris.Tree({"Player ESP"})
                Iris.Checkbox({ "Enabled" }, { isChecked = VisualStates.PlayerESP.Enabled })
                Iris.InputColor3({ "Color" }, { color = VisualStates.PlayerESP.Color })
                Iris.SliderNum({ "Size", 1, 2, 80 }, { number = VisualStates.PlayerESP.Size })
                Iris.SliderNum({ "Distance", 5, 0, 10000 }, { number = VisualStates.PlayerESP.Distance })
            Iris.End()
        Iris.End()
        Iris.CollapsingHeader({ "Movement" })
            Iris.Tree({"Speed Hack"})
                Iris.Checkbox({ "Enabled" }, { isChecked = MovementStates.SpeedHack.Enabled })
                Iris.SliderNum({ "WalkSpeed", 1, 0, 300 }, { number = MovementStates.SpeedHack.WalkSpeed })
                Iris.InputKeyCode({ "Keybind" }, { key = MovementStates.SpeedHack.Keybind })
            Iris.End()
            Iris.Tree({"Infinite Jump"})
                Iris.Checkbox({ "Enabled" }, { isChecked = MovementStates.InfiniteJump.Enabled })
                Iris.SliderNum({ "JumpPower", 1, 0, 300 }, { number = MovementStates.InfiniteJump.JumpPower })
                Iris.InputKeyCode({ "Keybind" }, { key = MovementStates.InfiniteJump.Keybind })
            Iris.End()
            Iris.Tree({"Fly Hack"})
                Iris.Checkbox({ "Enabled" }, { isChecked = MovementStates.FlyHack.Enabled })
                Iris.SliderNum({ "FlySpeed", 1, 0, 300 }, { number = MovementStates.FlyHack.FlySpeed })
                Iris.InputKeyCode({ "Keybind" }, { key = MovementStates.FlyHack.Keybind })
                Iris.Tree({"Noclip"})
                    Iris.Checkbox({ "Enabled" }, { isChecked = MovementStates.FlyHack.Noclip.Enabled })
                Iris.End()
            Iris.End()
        Iris.End()
        Iris.CollapsingHeader({ "Player" })
        Iris.End()
        Iris.CollapsingHeader({ "World" })
        Iris.End()
        Iris.CollapsingHeader({ "Gui" })
            Iris.InputKeyCode({ "Hide Gui" }, { key = GuiStates.HideGui })
            Iris.Tree({"Chat Logger"})
                Iris.Checkbox({ "Enabled" }, { isChecked = GuiStates.ChatLogger.Enabled })
                Iris.InputKeyCode({ "Keybind" }, { key = GuiStates.ChatLogger.Keybind })
            Iris.End()
        Iris.End()
        Iris.CollapsingHeader({ "Misc" })
            local rejoinServer = Iris.Button({rejoinPrompt and "Are you sure? (Yes)" or "Rejoin Server"})
            if rejoinServer.clicked() then
                if rejoinPrompt then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
                end
                rejoinPrompt = true
                task.delay(1, function()
                    rejoinPrompt = false
                end)
            end
        Iris.End()
    Iris.End()
end)
-- [?] Setup Visual Functions
function PlayerESP(Player)
    if VisualsTable.Nametag.Players[Player] then return end

    local Object = Drawing.new("Text")
    Object.Color = Color3.new(1, 1, 1)
    Object.Position = Vector2.new()
    Object.Size = 21
    Object.Outline = true
    Object.Center = true
    Object.Visible = false
    local Health = Drawing.new("Text")
    Health.Color = Color3.new(1, 1, 1)
    Health.Position = Vector2.new()
    Health.Size = 21
    Health.Outline = true
    Health.Center = true
    Health.Visible = false
    local Tool = Drawing.new("Text")
    Tool.Color = Color3.new(1, 1, 1)
    Tool.Position = Vector2.new()
    Tool.Size = 21
    Tool.Outline = true
    Tool.Center = true
    Tool.Visible = false

    VisualsTable.Nametag.Players[Player] = {
        Object = Object,
        Health = Health,
        Tool = Tool,
        Target = false
    }
end
-- [?] Setup RenderStepped Connection
function WorldToViewportPoint(Vector3)
    local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(Vector3)
    return Vector2.new(vector.x, vector.y), onScreen
end
function getCharacterVariables(character)
    return character:FindFirstChild("Head"), character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Tool"), character:FindFirstChildOfClass("Humanoid")
end

RunService.RenderStepped:Connect(function()
    if (VisualStates.PlayerESP.Enabled:get()) then
        for _, v in PlayerService:GetPlayers() do
            PlayerESP(v)
        end

        for Player, ESPObject in VisualsTable.Nametag.Players do
            local Object = ESPObject.Object
            local _Health = ESPObject.Health
            local _Tool = ESPObject.Tool
            local Character = Player.Character
            if (Character) then
                local Head, RootPart, Tool, Humanoid = getCharacterVariables(Character)
                if (Head and RootPart and Humanoid) then else return end
                local Vector, OnScreen = WorldToViewportPoint((RootPart.CFrame * CFrame.new(0, Head.Size.Y + RootPart.Size.Y, 0)).Position)
                local Health, MaxHealth, HealthPercentage
                local Distance = 0
                Object.Position = Vector
                _Health.Position = Vector2.new(Vector.X, Vector.Y + (VisualStates.PlayerESP.Size:get()))
                _Tool.Position = Vector2.new(Vector.X, Vector.Y + (VisualStates.PlayerESP.Size:get() * 2))
                if (Player == LocalPlayer) then
                    Object.Color = Color3.new(0.7,0.5,1)
                    _Health.Color = Color3.new(0.7,0.5,1)
                else
                    Object.Color = VisualStates.PlayerESP.Color:get()
                    _Health.Color = VisualStates.PlayerESP.Color:get()
                end
                Object.Size = VisualStates.PlayerESP.Size:get()
                _Health.Size = VisualStates.PlayerESP.Size:get()
                _Tool.Size = VisualStates.PlayerESP.Size:get()

                local LocalHumanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local LocalHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                if (LocalHead and LocalHumanoid and workspace.CurrentCamera.CameraSubject == LocalHumanoid) then
                    Distance = tostring(math.floor((LocalHead.Position - Head.Position).Magnitude))
                else
                    Distance = tostring(math.floor((workspace.CurrentCamera.CFrame.Position - Head.Position).Magnitude))
                end
                
                Health = tostring(math.floor(Humanoid.Health))
                MaxHealth = tostring(math.floor(Humanoid.MaxHealth))
                HealthPercentage = tostring(math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)) .. "%"

                if Tool then
                    _Tool.Text = string.format("[%s]", Tool.Name)
                end
                Object.Text = string.format("[%s][%s][@%s]", Distance, Player.DisplayName, Player.Name)
                _Health.Text = string.format("[%s/%s][%s]", Health, MaxHealth, HealthPercentage)
                Object.Center = true
                _Health.Center = true
                _Tool.Center = true
                Object.Visible = (tonumber(Distance) <= VisualStates.PlayerESP.Distance:get()) and OnScreen
                _Health.Visible = (tonumber(Distance) <= VisualStates.PlayerESP.Distance:get()) and OnScreen
                _Tool.Visible = ((tonumber(Distance) <= VisualStates.PlayerESP.Distance:get()) and OnScreen) and Tool ~= nil
            elseif (Player == nil or Character == nil or Player.Parent == nil) then
                if ESPObject.Object ~= nil then
                    ESPObject.Object:Destroy()
                    ESPObject.Health:Destroy()
                    ESPObject.Tool:Destroy()
                end
                VisualsTable.Nametag.Players[Player] = nil
            end
        end
    else
        for idx, val in pairs(VisualsTable.Nametag.Players) do
            if val.Object ~= nil then
                val.Object:Destroy()
                val.Health:Destroy()
                val.Tool:Destroy()
            end
            VisualsTable.Nametag.Players[idx] = nil
        end
    end
end)

local noclipCachedPosition

RunService.Heartbeat:Connect(function(Delta)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    if (Character and Humanoid) then else return end

    if (not MovementStates.FlyHack.Enabled:get() and MovementStates.SpeedHack.Enabled:get()) then
        for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity = Vector3.new(0, v.Velocity.Y, 0)
            end
        end
        Character:TranslateBy(Humanoid.MoveDirection * ((MovementStates.SpeedHack.WalkSpeed:get() - math.clamp(Humanoid.WalkSpeed, 1, 9e9)) / math.clamp(Humanoid.WalkSpeed, 1, 9e9)) * Delta * 10)
    end

    if (MovementStates.FlyHack.Enabled:get()) then
        for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity = Vector3.new(0, 0, 0)
            end
        end
        if MovementStates.FlyHack.Noclip.Enabled:get() then 
            if noclipCachedPosition == nil then
                local Part = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if Part then
                    noclipCachedPosition = Part.CFrame
                end 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.W) and not GameProcessingEvent then
                noclipCachedPosition += (workspace.CurrentCamera.CFrame.lookVector * MovementStates.FlyHack.FlySpeed:get() * Delta)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) and not GameProcessingEvent then
                noclipCachedPosition -= (workspace.CurrentCamera.CFrame.rightVector * MovementStates.FlyHack.FlySpeed:get() * Delta)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) and not GameProcessingEvent then
                noclipCachedPosition -= (workspace.CurrentCamera.CFrame.lookVector * MovementStates.FlyHack.FlySpeed:get() * Delta)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) and not GameProcessingEvent then
                noclipCachedPosition += (workspace.CurrentCamera.CFrame.rightVector * MovementStates.FlyHack.FlySpeed:get() * Delta)
            end
            local Part = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart
            if Part then
                Part.CFrame = noclipCachedPosition
            end 
        else
            noclipCachedPosition = nil
            if UserInputService:IsKeyDown(Enum.KeyCode.W) and not GameProcessingEvent then
                LocalPlayer.Character:TranslateBy(workspace.CurrentCamera.CFrame.lookVector * MovementStates.FlyHack.FlySpeed:get() * Delta)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) and not GameProcessingEvent then
                LocalPlayer.Character:TranslateBy(-1 * (workspace.CurrentCamera.CFrame.rightVector * MovementStates.FlyHack.FlySpeed:get() * Delta))
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) and not GameProcessingEvent then
                LocalPlayer.Character:TranslateBy(-1 * (workspace.CurrentCamera.CFrame.lookVector * MovementStates.FlyHack.FlySpeed:get() * Delta))
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) and not GameProcessingEvent then
                LocalPlayer.Character:TranslateBy(workspace.CurrentCamera.CFrame.rightVector * MovementStates.FlyHack.FlySpeed:get() * Delta)
            end
        end
    elseif (not MovementStates.FlyHack.Enabled:get() and MovementStates.InfiniteJump.Enabled:get()) then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not GameProcessingEvent then
            for _,v in ipairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Velocity = Vector3.new(v.Velocity.X, 0, v.Velocity.Z)
                end
            end
            
            Character:TranslateBy(Vector3.new(0, 0.5, 0) * ((MovementStates.InfiniteJump.JumpPower:get())) * Delta)
        end
    end
end)

function toggleState(state)
    state:set(not state:get())
end


UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if (gameProcessedEvent) then return end

    if (input.KeyCode == MovementStates.FlyHack.Keybind:get()) then
        toggleState(MovementStates.FlyHack.Enabled)
    end
    
    if (input.KeyCode == MovementStates.SpeedHack.Keybind:get()) then
        toggleState(MovementStates.SpeedHack.Enabled)
    end
    
    if (input.KeyCode == MovementStates.InfiniteJump.Keybind:get()) then
        toggleState(MovementStates.InfiniteJump.Enabled)
    end
    if (input.KeyCode == GuiStates.HideGui:get()) then
        toggleState(ShowGui)
    end
    if (input.KeyCode == GuiStates.ChatLogger.Keybind:get()) then
        toggleState(GuiStates.ChatLogger.Enabled)
    end
    
end)

queue_on_teleport("loadstring((game:HttpGet('https://raw.githubusercontent.com/Megurgur/Megur-Hub/main/universal.lua')))()")
