--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Converted to Obsidian Library (LinoriaLib) by request
-- Original features preserved exactly
-- MODIFICATIONS: Ajout onglet Misc avec Bunny Hop + Anti-Aim complet

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "MilkaPrivate",
	Footer = "Made by Milka",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

--// TABS
local Tabs = {
	Combat = Window:AddTab("Combat", "crosshair"),
	Skins = Window:AddTab("Skins", "swords"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Misc = Window:AddTab("Misc", "gear"), -- NOUVEL ONGLET
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

--// Services & Globals
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local CharactersFolder = workspace:WaitForChild("Characters", 10)

--// ==========================================
--// SHARED LOGIC (TEAM CHECK)
--// ==========================================
local function getTFolder() return CharactersFolder:FindFirstChild("Terrorists") end
local function getCTFolder() return CharactersFolder:FindFirstChild("Counter-Terrorists") end

local function isAlive()
    local t, ct = getTFolder(), getCTFolder()
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end

local function getEnemyFolder()
    if not isAlive() then return nil end
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(player.Name) then return ct end
    if ct and ct:FindFirstChild(player.Name) then return t end
    return nil
end

--// ==========================================
--// AIMBOT & FOV LOGIC
--// ==========================================
local AimbotEnabled = false
local ShowFOV = false
local FOV_Radius = 100
local Smoothing = 3
local AimKey = Enum.UserInputType.MouseButton2
local isAiming = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
FOVCircle.Radius = FOV_Radius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Thickness = 1

local function getClosestEnemyToMouse()
    local closestEnemy = nil
    local shortestDistance = FOV_Radius
    local enemyFolder = getEnemyFolder()
    
    if not enemyFolder or not AimbotEnabled then return nil end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local head = enemy:FindFirstChild("Head")
        
        if hum and hum.Health > 0 and head then
            local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = head
                end
            end
        end
    end
    return closestEnemy
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimKey then isAiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimKey then isAiming = false end
end)

RunService.RenderStepped:Connect(function()
    if ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = FOV_Radius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if not isAiming or not isAlive() or not AimbotEnabled then return end
    
    local targetHead = getClosestEnemyToMouse()
    if targetHead then
        local headPos = camera:WorldToViewportPoint(targetHead.Position)
        local mousePos = UserInputService:GetMouseLocation()
        
        local moveX = (headPos.X - mousePos.X) / Smoothing
        local moveY = (headPos.Y - mousePos.Y) / Smoothing
        
        if mousemoverel then
            mousemoverel(moveX, moveY)
        end
    end
end)

--// COMBAT TAB
local CombatGroup = Tabs.Combat:AddLeftGroupbox("Aimbot Settings", "target")

CombatGroup:AddToggle("AimbotToggle", {
    Text = "Enable Aimbot (Hold Right Click)",
    Default = false,
    Tooltip = "Aims at enemies when holding right click",
    Callback = function(Value) AimbotEnabled = Value end
})

CombatGroup:AddToggle("FOVToggle", {
    Text = "Show FOV Circle",
    Default = false,
    Tooltip = "Shows the aimbot field of view circle",
    Callback = function(Value) ShowFOV = Value end
})

CombatGroup:AddSlider("FOVSlider", {
    Text = "FOV Radius",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Suffix = "px",
    Tooltip = "Radius of the aimbot FOV circle",
    Callback = function(Value) FOV_Radius = Value end
})

CombatGroup:AddSlider("AimbotSmoothing", {
    Text = "Aimbot Smoothing",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = " (Lower is faster)",
    Tooltip = "Lower = faster aiming, Higher = smoother",
    Callback = function(Value) Smoothing = Value end
})

--// TRIGGERBOT
local TriggerBotEnabled = false
local TriggerBotDelay = 0

local TriggerGroup = Tabs.Combat:AddLeftGroupbox("TriggerBot Settings", "target")

TriggerGroup:AddToggle("TriggerBotToggle", {
    Text = "Enable TriggerBot",
    Default = false,
    Tooltip = "Automatically shoots when crosshair is on enemy",
    Callback = function(Value) TriggerBotEnabled = Value end
})

TriggerGroup:AddSlider("TriggerBotDelay", {
    Text = "Shot Delay",
    Default = 0,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Suffix = "ms",
    Tooltip = "Delay before shooting in milliseconds",
    Callback = function(Value) TriggerBotDelay = Value end
})

task.spawn(function()
    while task.wait(0.01) do
        if TriggerBotEnabled and isAlive() then
            local viewportSize = camera.ViewportSize
            local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local ignoreList = {camera}
            if player.Character then table.insert(ignoreList, player.Character) end
            raycastParams.FilterDescendantsInstances = ignoreList
            
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if result and result.Instance then
                local hitPart = result.Instance
                local model = hitPart:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") then
                    local enemyFolder = getEnemyFolder()
                    if enemyFolder and model.Parent == enemyFolder then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if TriggerBotDelay > 0 then task.wait(TriggerBotDelay / 1000) end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end)

--// HITBOX
local HitboxEnabled = false
local HitboxSize = 3
local originalHeadSizes = {}

local HitboxGroup = Tabs.Combat:AddLeftGroupbox("Simple Hitbox (Max 3)", "target")

HitboxGroup:AddToggle("HitboxToggle", {
    Text = "Enable Hitbox",
    Default = false,
    Tooltip = "Enlarges enemy head hitbox",
    Callback = function(Value) HitboxEnabled = Value end
})

HitboxGroup:AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = 3,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Suffix = " Studs",
    Tooltip = "Size of the enlarged hitbox",
    Callback = function(Value) HitboxSize = Value end
})

task.spawn(function()
    while task.wait(0.5) do
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local head = enemy:FindFirstChild("Head")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    if not originalHeadSizes[head] then
                        originalHeadSizes[head] = head.Size
                    end
                    
                    if HitboxEnabled then
                        head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        head.CanCollide = false
                        head.Transparency = 0.5
                    else
                        if originalHeadSizes[head] and head.Size ~= originalHeadSizes[head] then
                            head.Size = originalHeadSizes[head]
                            head.Transparency = 0
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// MISC TAB - ANTI-AIM COMPLET + BHOP
--// ==========================================

--// ANTI-AIM COMPLET (tous les modes du premier script)
local AAEnabled = false
local AAMode = "Jitter"
local AAPitch = "None"
local AASpeed = 15
local JitterRange = 45
local Character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local aaTime = 0

local function UpdateAntiAim(dt)
    if not AAEnabled then return end
    if not Character or not Character.Parent then return end

    aaTime = aaTime + dt

    local yaw = 0
    local pitch = 0

    -- Calcul du pitch
    if AAPitch == "Down" then 
        pitch = math.rad(-90)
    elseif AAPitch == "Flip" then 
        pitch = math.rad(-180)
    elseif AAPitch == "Up" then 
        pitch = math.rad(90)
    end

    -- Calcul du yaw selon le mode
    if AAMode == "Jitter" then 
        yaw = math.rad(math.random(-math.floor(JitterRange), math.floor(JitterRange)))
    elseif AAMode == "Sway" then 
        yaw = math.sin(aaTime * (AASpeed / 5)) * math.rad(JitterRange)
    elseif AAMode == "Inverter" then 
        yaw = (math.floor(aaTime * 2) % 2 == 0) and 0 or math.rad(180)
    elseif AAMode == "Spin180" then 
        yaw = math.rad((aaTime * AASpeed * 10) % 360)
    elseif AAMode == "Spin360" then
        yaw = math.rad((aaTime * AASpeed * 20) % 360)
    end

    -- Application de la rotation
    if yaw ~= 0 or pitch ~= 0 then
        local currentCF = HumanoidRootPart.CFrame
        HumanoidRootPart.CFrame = currentCF * CFrame.Angles(pitch, yaw, 0)
    end
end

-- Connexion Anti-Aim
local aaConnection = RunService.Heartbeat:Connect(UpdateAntiAim)

-- Gestion du changement de personnage pour Anti-Aim
player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

--// GROUPE ANTI-AIM DANS MISC
local AAGroup = Tabs.Misc:AddLeftGroupbox("Anti-Aim Settings", "crosshair")

AAGroup:AddToggle("AAToggle", {
    Text = "Enable Anti-Aim",
    Default = false,
    Tooltip = "Modifies your character rotation to avoid headshots",
    Callback = function(Value) AAEnabled = Value end
})

AAGroup:AddDropdown("AAModeSelect", {
    Text = "Mode",
    Values = {"None", "Jitter", "Sway", "Inverter", "Spin180", "Spin360"},
    Default = "Jitter",
    Tooltip = "Select anti-aim mode",
    Callback = function(Value) AAMode = Value end
})

AAGroup:AddDropdown("AAPitchSelect", {
    Text = "Pitch",
    Values = {"None", "Up", "Down", "Flip"},
    Default = "None",
    Tooltip = "Select pitch angle",
    Callback = function(Value) AAPitch = Value end
})

AAGroup:AddSlider("AASpeedSlider", {
    Text = "Speed",
    Default = 15,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Suffix = "x",
    Tooltip = "Speed of the anti-aim movement",
    Callback = function(Value) AASpeed = Value end
})

AAGroup:AddSlider("JitterRangeSlider", {
    Text = "Jitter Range (degrees)",
    Default = 45,
    Min = 10,
    Max = 180,
    Rounding = 0,
    Suffix = "°",
    Tooltip = "Range of jitter movement",
    Callback = function(Value) JitterRange = Value end
})

--// BHOP (déjà existant mais déplacé dans Misc)
local BhopEnabled = false

local BhopGroup = Tabs.Misc:AddLeftGroupbox("Movement Settings", "activity")

BhopGroup:AddToggle("BhopToggle", {
    Text = "Enable Bunny Hop (Hold Space)",
    Default = false,
    Tooltip = "Auto jumps while holding space",
    Callback = function(Value) BhopEnabled = Value end
})

RunService.RenderStepped:Connect(function()
    if BhopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and isAlive() then
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)

--// ==========================================
--// SKINS TAB LOGIC (PRESERVED EXACTLY)
--// ==========================================
local scriptRunning = false
local selectedKnife = "Butterfly Knife"
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0

local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK  = "AttackKnifeAction"

pcall(function() RS.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

local knives = {
    ["Karambit"]        = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["Butterfly Knife"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["M9 Bayonet"]      = {Offset = CFrame.new(0, -1.5, 1)},
    ["Flip Knife"]      = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Gut Knife"]       = {Offset = CFrame.new(0, -1.5, 0.5)},
    ["Stiletto Knife"]  = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Skeleton Knife"]  = {Offset = CFrame.new(0, -1.5, 1.25)},
}

local vm, animator
local equipAnim, idleAnim, inspectAnim, HeavySwingAnim, Swing1Anim, Swing2Anim

local function getKnifeInCamera() return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife") end

local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide, part.Anchored, part.CastShadow, part.CanTouch, part.CanQuery = false, false, false, false, false
end

local function disableCollisions(model)
    for _, part in model:GetDescendants() do cleanPart(part) end
end

local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Texture") then part.Transparency = 1 end
    end
end

local function playSound(folder, name)
    local weaponSounds = RS.Sounds:FindFirstChild(selectedKnife)
    if not weaponSounds then return end
    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end

local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end
    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm
    local motor = Instance.new("Motor6D")
    motor.Part0, motor.Part1, motor.C0, motor.Parent = targetArm, assetMesh, offset, targetArm
end

local function handleAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin or not spawned or not animator or not isAlive() then return Enum.ContextActionResult.Pass end

    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or inspecting or swinging then return Enum.ContextActionResult.Pass end
        inspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() inspecting = false end)
    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then return Enum.ContextActionResult.Pass end
        lastAttackTime = currentTime
        if inspecting then inspecting = false; if inspectAnim then inspectAnim:Stop() end end
        swinging = true
        if idleAnim then idleAnim:Stop() end
        local anims = {HeavySwingAnim, Swing1Anim, Swing2Anim}
        local chosenAnim = anims[math.random(1, #anims)]
        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"
        chosenAnim:Play()
        local s = playSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() swinging = false end)
    end
    return Enum.ContextActionResult.Pass
end

local function removeViewmodel()
    spawned = false
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy() vm = nil end
    animator, inspecting, swinging = nil, false, false
end

local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    local myModel = isAlive()
    if not myModel then return end
    spawned = true

    local knifeTemplate = RS.Assets.Weapons:WaitForChild(selectedKnife)
    local knifeOffset = knives[selectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = selectedKnife, camera

    disableCollisions(vm)
    hideOriginalKnife(knife)

    if myModel.Parent.Name == "Terrorists" then
        local tGloves = RS.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = RS.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = RS.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end

    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = RS.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")

    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))

    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = camera.CFrame * knifeOffset
    }):Play()

    equipAnim:Play()
    playSound("Equip", "1")

    CAS:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
end

RunService.RenderStepped:Connect(function()
    if not scriptRunning or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knives[selectedKnife].Offset
    if not (equipAnim and equipAnim.IsPlaying) and not inspecting and not swinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if scriptRunning and living and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife or not living) and spawned then
            removeViewmodel()
        end
    end
end)

--// SKIN CHANGER (PRESERVED EXACTLY)
local SkinChangerEnabled = false
local SelectedSkins = {}
local DropdownObjects = {}
local SkinOptions = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"

local CT_ONLY = {["USP-S"]=true, ["Five-SeveN"]=true, ["MP9"]=true, ["FAMAS"]=true, ["M4A1-S"]=true, ["M4A4"]=true, ["AUG"]=true}
local SHARED = {["P250"]=true, ["Desert Eagle"]=true, ["Dual Berettas"]=true, ["Negev"]=true, ["P90"]=true, ["Nova"]=true, ["XM1014"]=true, ["AWP"]=true, ["SSG 08"]=true}

local KNIVES = {["Karambit"]=true, ["Butterfly Knife"]=true, ["M9 Bayonet"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["T Knife"]=true, ["CT Knife"]=true, ["Stiletto Knife"]=true, ["Skeleton Knife"]=true}
local GLOVES = {["Sports Gloves"]=true}
local SkinsFolder = RS:WaitForChild("Assets"):WaitForChild("Skins")
local IgnoreFolders = {["HE Grenade"]=true, ["Incendiary Grenade"]=true, ["Molotov"]=true, ["Smoke Grenade"]=true, ["Flashbang"]=true, ["Decoy Grenade"]=true, ["C4"]=true, ["CT Glove"]=true, ["T Glove"]=true}

local function getNonStockSkins(folder)
    local skins = {}
    for _, skin in folder:GetChildren() do
        if skin.Name ~= "Stock" then
            table.insert(skins, skin.Name)
        end
    end
    return skins
end

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not isAlive() then return end
    local skinName = SelectedSkins[model.Name]
    if not skinName then return end

    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then return end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild(WEAR)
        if not sourceFolder then return end

        for _, obj in camera:GetChildren() do
            local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
            if left or right then
                local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild(WEAR)
                if gloveSource then
                    for _, side in {"Left Arm", "Right Arm"} do
                        local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                        if arm and src then
                            local gloveMesh = arm:FindFirstChild("Glove")
                            if gloveMesh then
                                local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = src:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                            end
                        end
                    end
                end
            end
        end

        if not GLOVES[model.Name] then
            local weaponFolder = model:FindFirstChild("Weapon")
            if weaponFolder then
                for _, part in weaponFolder:GetDescendants() do
                    if part:IsA("BasePart") then
                        local newSkin = sourceFolder:FindFirstChild(part.Name)
                        if newSkin then
                            local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                            if existing then existing:Destroy() end
                            local clone = newSkin:Clone()
                            clone.Name, clone.Parent = "SurfaceAppearance", part
                        end
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end

--// SKINS TAB UI
local SkinsGroup = Tabs.Skins:AddLeftGroupbox("Skin Changer", "palette")

SkinsGroup:AddToggle("SkinChangerToggle", {
    Text = "Enable Skin Changer",
    Default = false,
    Tooltip = "Enables custom weapon skins",
    Callback = function(Value)
        SkinChangerEnabled = Value
        if not Value then for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil) end end
    end
})

SkinsGroup:AddButton({
    Text = "Randomize All Skins",
    Tooltip = "Randomizes all weapon skins",
    Func = function()
        for weaponName, optionsList in pairs(SkinOptions) do
            if #optionsList > 0 then
                local randomSkin = optionsList[math.random(1, #optionsList)]
                if DropdownObjects[weaponName] then
                    for _, dropdown in ipairs(DropdownObjects[weaponName]) do 
                        dropdown:SetValue(randomSkin)
                    end
                end
            end
        end
    end
})

local SkinsRightGroup = Tabs.Skins:AddRightGroupbox("Weapon Skins", "palette")

--// Custom Knife Settings
local KnifeGroup = Tabs.Skins:AddRightGroupbox("Custom Knife", "swords")

KnifeGroup:AddToggle("KnifeToggle", {
    Text = "Enable Custom Knife",
    Default = false,
    Tooltip = "Enables custom knife viewmodel",
    Callback = function(Value)
        scriptRunning = Value
        if not Value then removeViewmodel() end
    end
})

KnifeGroup:AddDropdown("KnifeDropdown", {
    Text = "Selected Custom Knife",
    Values = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife", "Stiletto Knife", "Skeleton Knife"},
    Default = "Butterfly Knife",
    Tooltip = "Choose your custom knife model",
    Callback = function(Value)
        selectedKnife = Value
        if spawned then removeViewmodel() end
    end
})

local function CreateSkinDropdown(weaponName, group)
    local folder = SkinsFolder:FindFirstChild(weaponName)
    if not folder then return end
    
    local options = getNonStockSkins(folder)
    SkinOptions[weaponName] = options
    
    if #options > 0 then
        if not SelectedSkins[weaponName] then SelectedSkins[weaponName] = options[1] end
    else
        SelectedSkins[weaponName] = nil
    end

    local dp = group:AddDropdown("Skin_" .. weaponName:gsub("%W", ""), {
        Name = weaponName,
        Text = weaponName,
        Values = options,
        Default = SelectedSkins[weaponName] or (options[1] or ""),
        Tooltip = "Select skin for " .. weaponName,
        Callback = function(opt)
            SelectedSkins[weaponName] = opt
            if DropdownObjects[weaponName] then
                for _, other in DropdownObjects[weaponName] do
                    if other.Value ~= opt then other:SetValue(opt) end
                end
            end
            for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil); applyWeaponSkin(obj) end
        end
    })
    DropdownObjects[weaponName] = DropdownObjects[weaponName] or {}
    table.insert(DropdownObjects[weaponName], dp)
end

-- Create skin dropdowns in the right group
SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("Knives Skins")
for name in pairs(KNIVES) do CreateSkinDropdown(name, SkinsRightGroup) end

SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("Gloves")
for name in pairs(GLOVES) do CreateSkinDropdown(name, SkinsRightGroup) end

SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("CT Weapons")
for name in pairs(CT_ONLY) do CreateSkinDropdown(name, SkinsRightGroup) end

SkinsRightGroup:AddDivider()
SkinsRightGroup:AddLabel("T Weapons")
for name in pairs(SHARED) do CreateSkinDropdown(name, SkinsRightGroup) end

for _, folder in SkinsFolder:GetChildren() do
    local n = folder.Name
    if not IgnoreFolders[n] and not KNIVES[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then 
        CreateSkinDropdown(n, SkinsRightGroup) 
    end
end

camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled or not isAlive() then return end
    task.wait(COOLDOWN)
    applyWeaponSkin(obj)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled and isAlive() then
            for _, obj in camera:GetChildren() do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then 
                    applyWeaponSkin(obj) 
                end
            end
        end
    end
end)

--// ==========================================
--// VISUALS TAB LOGIC (ESP & WORLD)
--// ==========================================
local EspEnabled, EspBox, EspName, EspHealth, EspDistance = false, true, true, true, true
local espCache = {}

local function createESP()
    local esp = {
        boxOutline = Drawing.new("Square"), box = Drawing.new("Square"),
        name = Drawing.new("Text"), distance = Drawing.new("Text"),
        healthOutline = Drawing.new("Line"), healthBar = Drawing.new("Line")
    }
    esp.boxOutline.Thickness = 3; esp.boxOutline.Filled = false; esp.boxOutline.Color = Color3.new(0, 0, 0)
    esp.box.Thickness = 1; esp.box.Filled = false; esp.box.Color = Color3.fromRGB(255, 50, 50)
    esp.name.Center = true; esp.name.Outline = true; esp.name.Color = Color3.new(1, 1, 1); esp.name.Size = 16
    esp.distance.Center = true; esp.distance.Outline = true; esp.distance.Color = Color3.new(0.8, 0.8, 0.8); esp.distance.Size = 13
    esp.healthOutline.Thickness = 3; esp.healthOutline.Color = Color3.new(0, 0, 0)
    esp.healthBar.Thickness = 1; esp.healthBar.Color = Color3.new(0, 1, 0)
    return esp
end

RunService.RenderStepped:Connect(function()
    if not EspEnabled or not isAlive() then
        for _, e in pairs(espCache) do for _, d in pairs(e) do d.Visible = false end end
        return
    end
    
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end

    local currentAlive = {}
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum, root, head = enemy:FindFirstChildOfClass("Humanoid"), enemy:FindFirstChild("HumanoidRootPart"), enemy:FindFirstChild("Head")

        if hum and hum.Health > 0 and root and head then
            currentAlive[enemy] = true
            if not espCache[enemy] then espCache[enemy] = createESP() end
            
            local esp = espCache[enemy]
            local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local boxH, boxW = math.abs(headPos.Y - legPos.Y), math.abs(headPos.Y - legPos.Y) / 2
                local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)

                if EspBox then
                    esp.boxOutline.Size = Vector2.new(boxW, boxH); esp.boxOutline.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y); esp.boxOutline.Visible = true
                    esp.box.Size = Vector2.new(boxW, boxH); esp.box.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y); esp.box.Visible = true
                else esp.boxOutline.Visible, esp.box.Visible = false, false end
                
                if EspHealth then
                    local hpPct, barX = hum.Health / hum.MaxHealth, rootPos.X - boxW / 2 - 6
                    esp.healthOutline.From = Vector2.new(barX, headPos.Y - 1); esp.healthOutline.To = Vector2.new(barX, headPos.Y + boxH + 1); esp.healthOutline.Visible = true
                    esp.healthBar.From = Vector2.new(barX, headPos.Y + boxH); esp.healthBar.To = Vector2.new(barX, headPos.Y + boxH - (boxH * hpPct)); esp.healthBar.Color = Color3.new(1 - hpPct, hpPct, 0); esp.healthBar.Visible = true
                else esp.healthOutline.Visible, esp.healthBar.Visible = false, false end
                
                if EspName then esp.name.Text = enemy.Name; esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 20); esp.name.Visible = true 
                else esp.name.Visible = false end

                if EspDistance then esp.distance.Text = "[" .. dist .. "m]"; esp.distance.Position = Vector2.new(rootPos.X, headPos.Y + boxH + 2); esp.distance.Visible = true
                else esp.distance.Visible = false end
            else for _, d in pairs(esp) do d.Visible = false end end
        end
    end
    for cEnemy, e in pairs(espCache) do
        if not currentAlive[cEnemy] then for _, d in pairs(e) do d:Remove() end; espCache[cEnemy] = nil end
    end
end)

--// VISUALS TAB UI
local EspGroup = Tabs.Visuals:AddLeftGroupbox("ESP Master Switch", "eye")

EspGroup:AddToggle("ESPToggle", {
    Text = "Enable Player ESP",
    Default = false,
    Tooltip = "Enables player ESP visuals",
    Callback = function(Value) EspEnabled = Value end
})

local EspSettingsGroup = Tabs.Visuals:AddLeftGroupbox("ESP Settings", "eye")

EspSettingsGroup:AddToggle("EspBoxToggle", {
    Text = "Show Box",
    Default = true,
    Tooltip = "Shows bounding box around enemies",
    Callback = function(Value) EspBox = Value end
})

EspSettingsGroup:AddToggle("EspHealthToggle", {
    Text = "Show Health",
    Default = true,
    Tooltip = "Shows health bar",
    Callback = function(Value) EspHealth = Value end
})

EspSettingsGroup:AddToggle("EspNameToggle", {
    Text = "Show Name",
    Default = true,
    Tooltip = "Shows player name",
    Callback = function(Value) EspName = Value end
})

EspSettingsGroup:AddToggle("EspDistanceToggle", {
    Text = "Show Distance",
    Default = true,
    Tooltip = "Shows distance to enemy",
    Callback = function(Value) EspDistance = Value end
})

--// WORLD EFFECTS
local AntiFlashEnabled, AntiSmokeEnabled = false, false

local WorldGroup = Tabs.Visuals:AddRightGroupbox("World and Effects", "sun")

WorldGroup:AddToggle("AntiFlashToggle", {
    Text = "Anti-Flashbang",
    Default = false,
    Tooltip = "Removes flashbang effects",
    Callback = function(Value) AntiFlashEnabled = Value end
})

WorldGroup:AddToggle("AntiSmokeToggle", {
    Text = "Anti-Smoke",
    Default = false,
    Tooltip = "Removes smoke grenade effects",
    Callback = function(Value) AntiSmokeEnabled = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AntiFlashEnabled then
            local gui, effect = player.PlayerGui:FindFirstChild("FlashbangEffect"), game:GetService("Lighting"):FindFirstChild("FlashbangColorCorrection")
            if gui then gui:Destroy() end; if effect then effect:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if AntiSmokeEnabled then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if string.match(folder.Name, "Voxel") then folder:ClearAllChildren(); folder:Destroy() end
                end
            end
        end
    end
end)

--// UI SETTINGS (THEME & CONFIG)
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = false,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { 
    Default = "RightShift", 
    NoUI = true, 
    Text = "Menu keybind" 
})

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

-- Addons for theme and config saving
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("MilkaPrivate")
SaveManager:SetFolder("MilkaPrivate")
SaveManager:SetSubFolder("BloxStrike")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    print("MilkaPrivate unloaded!")
end)
