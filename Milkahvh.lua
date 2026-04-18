local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/twistedk1d/BloxStrike/refs/heads/main/Source/UI/source.lua"))()

--// Window creation
local Window = Rayfield:CreateWindow({
    Name = "MilkaPrivate",
    Icon = 0,
    LoadingTitle = "loading MilkaPrivate",
    LoadingSubtitle = "Made by Milka",
    ShowText = "Menu",
    Theme = "Dark",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MilkaPrivate",
        FileName = "MilkaPrivate"
    }
})

--// Services & Globals
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local CharactersFolder = Workspace:WaitForChild("Characters", 10)

--// ==========================================
--// TABS
--// ==========================================
local Tab_Combat  = Window:CreateTab("Combat", "crosshair")
local Tab_Skins   = Window:CreateTab("Skins", "swords")
local Tab_Visuals = Window:CreateTab("Visuals", "eye")
local Tab_Misc    = Window:CreateTab("Misc", "settings")

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

local function isEnemy(target)
    if not target or not isAlive() then return false end
    local enemyFolder = getEnemyFolder()
    return enemyFolder and target.Parent == enemyFolder
end

--// ==========================================
--// MATERIAL LIMITS FOR WALLBANG
--// ==========================================
local MaterialLimits = {
    [Enum.Material.Asphalt] = 0.25, [Enum.Material.Basalt] = 0.25, [Enum.Material.Brick] = 0.25,
    [Enum.Material.Cobblestone] = 0.25, [Enum.Material.Concrete] = 0.25, [Enum.Material.CrackedLava] = 0.25,
    [Enum.Material.DiamondPlate] = 0.25, [Enum.Material.Foil] = 0.25, [Enum.Material.Glacier] = 0.25,
    [Enum.Material.Granite] = 0.25, [Enum.Material.Grass] = 0.25, [Enum.Material.Ground] = 0.25,
    [Enum.Material.Ice] = 0.25, [Enum.Material.LeafyGrass] = 0.25, [Enum.Material.Limestone] = 0.25,
    [Enum.Material.Marble] = 0.25, [Enum.Material.Metal] = 0.25, [Enum.Material.Mud] = 0.25,
    [Enum.Material.Pavement] = 0.25, [Enum.Material.Rock] = 0.25, [Enum.Material.Salt] = 0.25,
    [Enum.Material.Sand] = 0.25, [Enum.Material.Sandstone] = 0.25, [Enum.Material.Slate] = 0.25,
    [Enum.Material.Snow] = 0.25, [Enum.Material.ForceField] = 0.25, [Enum.Material.Neon] = 0.25,
    [Enum.Material.CorrodedMetal] = 0.25, [Enum.Material.Pebble] = 0.25, [Enum.Material.CeramicTiles] = 0.25,
    [Enum.Material.Plaster] = 0.25, [Enum.Material.Plastic] = 7, [Enum.Material.SmoothPlastic] = 7,
    [Enum.Material.Wood] = 7, [Enum.Material.WoodPlanks] = 7, [Enum.Material.Cardboard] = 7,
    [Enum.Material.Glass] = 100, [Enum.Material.Fabric] = 100
}

local MaterialVariantLimits = { ["IndoorWall"] = 0.25, ["Sandy Brick"] = 0.25 }

--// ==========================================
--// CONFIGURATION
--// ==========================================
_G.Config = {
    -- Silent Aim / Rage
    SilentAim = false,
    TargetMode = "Near Crosshair",
    AimHitboxes = {"Head", "HumanoidRootPart", "UpperTorso"},
    FovRadius = 100,
    ShowFov = false,
    FovColor = Color3.fromRGB(255, 255, 255),
    AllDirections = false,
    
    -- Wallbang
    WallBang = false,
    ShowWallbangIndicator = false,
    WallDepth = 1.0,
    AutoWallDepth = false,
    
    -- Auto Fire / Triggerbot
    AutoFire = false,
    MinHitChance = 50,
    TriggerbotRadius = 10,
    LegitAutoWallbang = false,
    LegitAutoScope = false,
    LegitAutoStop = false,
    
    -- Dégâts
    MinDamage = 10,
    MinDamageOverride = 50,
    MinDamageOverrideActive = false,
    
    -- Anti-Aim
    AntiAim = false,
    AntiAimPitchMode = "Down",
    AntiAimBackwards = false,
    FollowBackwardsAA = false,
    
    -- Third Person
    ThirdPerson = false,
    ThirdPersonDist = 10,
    
    -- No Recoil / No Spread
    NoRecoilVisual = false,
    NoRecoilReal = false,
    NoSpread = false,
    EnableFov = false,
    CustomFov = 90,
    CustomFovValue = 100,
    
    -- Visuals
    Esp = false,
    EspBoxes = true,
    EspNames = true,
    EspHealthBar = true,
    EspDistance = true,
    EspTracers = false,
    EspHeadDot = false,
    EspWeapon = false,
    EspOffscreenArrows = false,
    EspChams = false,
    EspSoulParticles = false,
    EspChinaHat = false,
    EspSelfChinaHat = false,
    EspChinaHatRainbow = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    DistColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    WeaponColor = Color3.fromRGB(255, 255, 255),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TeammateColor = Color3.fromRGB(0, 255, 0),
    ChamHiddenColor = Color3.fromRGB(255, 0, 0),
    
    -- World
    WorldSkyboxEnabled = false,
    WorldSkybox = "Standard",
    WorldTimeEnabled = false,
    WorldClockTime = 12,
    WorldBrightEnabled = false,
    WorldBrightness = 2,
    WorldAmbient = Color3.fromRGB(127, 127, 127),
    WorldOutdoorAmbient = Color3.fromRGB(127, 127, 127),
    
    -- Effects
    ShowHitmark = false,
    PlayHitSound = false,
    ShowHitLogs = false,
    ShowTracers = false,
    BulletTracerColor = Color3.fromRGB(0, 100, 255),
    TracerDuration = 2,
    ShowImpacts = false,
    ImpactColor = Color3.fromRGB(255, 0, 0),
    ImpactTransparency = 0.5,
    KillEffect = false,
    KillEffectMode = "Rocket",
    KillEffectDuration = 3,
    CustomParticles = false,
    ParticleColor = Color3.fromRGB(170, 0, 255),
    
    -- Removals
    NoFlash = false,
    NoSmoke = false,
    NoFallDamage = false,
    
    -- Movement
    Bhop = false,
    BhopSpeed = 18,
    AutoStop = false,
    AutoPeek = false,
    FakeDuck = false,
    
    -- Scope
    NoScopeOverlay = false,
    CustomScopeFov = false,
    ScopeFovValue = 40,
    RemoveScope = false,
    AutoScope = false,
    
    -- Grenades
    MolotovZoneESP = false,
    SmokeZoneESP = false,
    GrenadeESP = false,
    GrenadeTracers = false,
    GrenadeZoneColor = Color3.fromRGB(255, 0, 0),
    SmokeColor = Color3.fromRGB(255, 0, 0),
    ColoredSmoke = false,
    
    -- Backtrack
    Backtrack = false,
    BacktrackTime = 0.33,
    BacktrackChams = false,
    BacktrackChamsColor = Color3.fromRGB(80, 0, 255),
    BacktrackChamsStyle = "Glow",
    
    -- Misc
    Multipoint = false,
    Weather = "None"
}

--// ==========================================
--// UTILITY FUNCTIONS
--// ==========================================
local function SafeNum(val, default)
    if type(val) == "number" and val == val then return val end
    return default
end

local function playHitSound()
    if not _G.Config.PlayHitSound then return end
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://1255040462"
    s.Volume = 1
    s.PlayOnRemove = true
    s.Parent = Workspace
    s:Destroy()
end

local function SpawnHitmarker(position)
    if not _G.Config.ShowHitmark then return end
    local hitpart = Instance.new("Part", Workspace)
    hitpart.Transparency = 1
    hitpart.CanCollide = false
    hitpart.CanQuery = false
    hitpart.Size = Vector3.new(0.01, 0.01, 0.01)
    hitpart.Anchored = true
    hitpart.Position = position
    hitpart.Name = "MilkaHitmarker"
    
    local hit = Instance.new("BillboardGui")
    hit.Name = "hit"
    hit.AlwaysOnTop = true
    hit.Parent = hitpart
    hit.Size = UDim2.new(0, 50, 0, 50)
    hit.Adornee = hitpart
    
    local hit_img = Instance.new("ImageLabel")
    hit_img.Name = "hit_img"
    hit_img.Image = "http://www.roblox.com/asset/?id=10922361372"
    hit_img.BackgroundTransparency = 1
    hit_img.Size = UDim2.new(0, 23, 0, 23)
    hit_img.Visible = true
    hit_img.ImageColor3 = Color3.new(1, 1, 1)
    hit_img.Rotation = 45
    hit_img.AnchorPoint = Vector2.new(0.5, 0.5)
    hit_img.Position = UDim2.new(0.5, 0, 0.5, 0)
    hit_img.Parent = hit
    
    task.spawn(function()
        local duration = 0.5
        task.wait(duration)
        if hit_img then hit_img:Destroy() end
        if hit then hit:Destroy() end
        if hitpart then hitpart:Destroy() end
    end)
end

--// ==========================================
--// PENETRATION STATS (WALLBANG)
--// ==========================================
local function GetPenetrationStats(origin, direction, maxPen, ignoreList, targetRoot)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.CollisionGroup = "Bullet"
    local filter = ignoreList or {player.Character, camera}
    params.FilterDescendantsInstances = filter
    
    local currentOrigin = origin
    local currentDir = direction 
    local accMat = {} 
    local accVar = {} 
    local stats = {
        TotalThickness = 0,
        MaterialStats = {},
        Success = false,
        FailReason = "Max Steps",
        EndPos = Vector3.zero
    }
    
    local backParams = RaycastParams.new()
    backParams.FilterType = Enum.RaycastFilterType.Include
    backParams.CollisionGroup = "Bullet"

    for i = 1, 100 do
        if not currentOrigin or not currentDir then break end
        local result = Workspace:Raycast(currentOrigin, currentDir * 1000, params)
        if not result then 
            if not targetRoot then
                stats.Success = true
                stats.EndPos = currentOrigin + (currentDir * 1000)
            else
                stats.FailReason = "Void (Missed)"
            end
            break 
        end
        if not result.Instance or not result.Instance.Parent then
             stats.FailReason = "Destroyed Instance"
             break
        end
        if targetRoot and result.Instance:IsDescendantOf(targetRoot) then
            stats.Success = true
            stats.EndPos = result.Position
            stats.FailReason = "Hit"
            return stats
        end
        table.insert(filter, result.Instance)
        params.FilterDescendantsInstances = filter
        local enterPos = result.Position
        local fakeEnd = enterPos + (currentDir * 1000)
        
        backParams.FilterDescendantsInstances = {result.Instance}
        local backRes = Workspace:Raycast(fakeEnd, enterPos - fakeEnd, backParams)
        local thickness = 0.5 
        local limit = 0.25
        local matName = result.Instance.Material.Name
        if not backRes then
             thickness = 5
             stats.FailReason = "Infinite/Block"
        else
             thickness = (enterPos - backRes.Position).Magnitude
             local variant = backRes.Instance.MaterialVariant
             if variant ~= "" and MaterialVariantLimits[variant] then
                 matName = variant
                 limit = MaterialVariantLimits[variant]
                 accVar[variant] = (accVar[variant] or 0) + thickness
                 if accVar[variant] > limit + maxPen then
                     stats.FailReason = string.format("Var: %s (%.1f > %.1f)", variant, accVar[variant], limit + maxPen)
                     stats.MaterialStats = {Type = "Variant", Name = variant, Thickness = accVar[variant], Limit = limit + maxPen}
                     return stats 
                 end
             else
                 local mat = backRes.Material
                 matName = mat.Name
                 limit = MaterialLimits[mat] or 0.25
                 accMat[mat] = (accMat[mat] or 0) + thickness
                 if accMat[mat] > limit + maxPen then
                      stats.FailReason = string.format("%s (%.1f / %.1f)", matName, accMat[mat], limit + maxPen)
                      stats.MaterialStats = {Type = "Material", Name = matName, Thickness = accMat[mat], Limit = limit + maxPen}
                      return stats 
                 end
             end
             currentOrigin = backRes.Position 
        end
        stats.TotalThickness = stats.TotalThickness + thickness
    end
    return stats
end

local function IsHitPossible(targetInstance, origin, maxPen, explicitPos)
    if not targetInstance then return false end
    local targetRoot
    local targetPart
    if targetInstance:IsA("Model") then
        targetRoot = targetInstance
        targetPart = targetRoot:FindFirstChild("Head") or targetRoot:FindFirstChild("HumanoidRootPart")
    elseif targetInstance:IsA("BasePart") then
         targetRoot = targetInstance.Parent
         targetPart = targetInstance 
    end
    if not targetPart or not targetRoot then return false end
    local targetPos = explicitPos or targetPart.Position
    local dir = (targetPos - origin).Unit
    local stats = GetPenetrationStats(origin, dir, maxPen, {player.Character, camera}, targetRoot)
    
    local minDmgToCheck = _G.Config.MinDamage or 0
    if _G.Config.MinDamageOverrideActive and _G.Config.MinDamageOverride then
        minDmgToCheck = _G.Config.MinDamageOverride
    end
    
    if stats.Success and (minDmgToCheck > 0) then
        local baseDmg = 30
        local factor = 1 - (stats.TotalThickness / maxPen)
        if factor < 0 then factor = 0 end
        local estDmg = baseDmg * factor
        if estDmg < minDmgToCheck then
             stats.Success = false
             stats.FailReason = string.format("Min Dmg (%.0f < %d)", estDmg, minDmgToCheck)
        end
    end
    return stats.Success, stats.FailReason, stats.TotalThickness
end

--// ==========================================
--// MULTIPOINT FUNCTION
--// ==========================================
local function GetScanPoints(part, partName)
    local points = {part.Position}
    if _G.Config.Multipoint then
        local s = 0.6 
        local cf = part.CFrame
        local size = part.Size * 0.5 * s
        if partName == "Head" then
             table.insert(points, cf * Vector3.new(size.X, 0, 0)) 
             table.insert(points, cf * Vector3.new(-size.X, 0, 0))
        elseif partName == "HumanoidRootPart" or partName == "UpperTorso" then
             table.insert(points, cf * Vector3.new(size.X, 0, 0))
             table.insert(points, cf * Vector3.new(-size.X, 0, 0))
        end
    end
    return points
end

--// ==========================================
--// SILENT AIM - GET CLOSEST TARGET
--// ==========================================
local CurrentWeaponData = { CanWallbang = true, Penetration = 2.5 }

local function getClosestTarget()
    if not player.Character then return nil, nil, nil end
    local closestPlayer = nil
    local bestScore = math.huge
    local targetAimPart = nil
    local targetAimPoint = nil
    local mouseLocation = UserInputService:GetMouseLocation()
    local origin = camera.CFrame.Position
    
    if _G.Config.ThirdPerson and player.Character and player.Character:FindFirstChild("Head") then
        origin = player.Character.Head.Position
    end
    
    local hitParams = RaycastParams.new()
    hitParams.FilterDescendantsInstances = {player.Character, camera}
    hitParams.FilterType = Enum.RaycastFilterType.Exclude
    hitParams.CollisionGroup = "Bullet"

    local function checkHitStatus(targetPos, targetHrp)
         local dir = targetPos - origin
         local res = Workspace:Raycast(origin, dir, hitParams)
         if res and res.Instance:IsDescendantOf(targetHrp.Parent) then
             return 2 
         elseif _G.Config.WallBang then
             local weaponPen = CurrentWeaponData.Penetration or 2.5
             if IsHitPossible(targetHrp.Parent, origin, weaponPen, targetPos) then
                 return 1 
             end
         end
         return 0
    end
    
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return nil, nil, nil end
    
    local candidates = {}
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then
            table.insert(candidates, enemy)
        end
    end
    
    if _G.Config.TargetMode == "Highest Damage" then 
        table.sort(candidates, function(a,b) 
            local ha = a:FindFirstChildOfClass("Humanoid")
            local hb = b:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 100) < (hb and hb.Health or 100)
        end)
    elseif _G.Config.TargetMode == "Near Crosshair" then
        table.sort(candidates, function(a,b) 
            local ra = a:FindFirstChild("HumanoidRootPart")
            local rb = b:FindFirstChild("HumanoidRootPart")
            if not ra or not rb then return false end
            local pA = camera:WorldToViewportPoint(ra.Position)
            local pB = camera:WorldToViewportPoint(rb.Position)
            local dA = (Vector2.new(pA.X, pA.Y) - mouseLocation).Magnitude
            local dB = (Vector2.new(pB.X, pB.Y) - mouseLocation).Magnitude
            return dA < dB
        end)
    end
    
    local scanLimit = 6
    if #candidates < scanLimit then scanLimit = #candidates end
    
    for i = 1, scanLimit do
        local enemy = candidates[i]
        if not enemy then continue end
        
        local potentialParts = _G.Config.AimHitboxes or {"Head"}
        
        if _G.Config.Multipoint then
            potentialParts = {
                "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
                "LeftHand", "RightHand", "LeftLowerLeg", "RightLowerLeg"
            }
        end
        
        for _, pName in ipairs(potentialParts) do
            local targetPart = enemy:FindFirstChild(pName)
            if targetPart then
                 local pointsToCheck = GetScanPoints(targetPart, pName)
                 for _, point in ipairs(pointsToCheck) do
                     local screenPoint, onScreen = camera:WorldToViewportPoint(point)
                     local score = math.huge
                     local isValid = false
                     
                     if _G.Config.AllDirections then
                         local hitType = checkHitStatus(point, targetPart)
                         if hitType > 0 then
                             score = (point - origin).Magnitude
                             isValid = true
                         end
                     elseif _G.Config.TargetMode == "Near Crosshair" then
                         if onScreen then
                             local screenDist = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                             if screenDist <= _G.Config.FovRadius then
                                 score = screenDist
                                 if checkHitStatus(point, targetPart) > 0 then isValid = true end
                             end
                         end
                     else 
                         if onScreen then
                             local screenDist = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                             if screenDist <= _G.Config.FovRadius then
                                 score = screenDist 
                                 if checkHitStatus(point, targetPart) > 0 then isValid = true end
                             end
                         end
                     end
                     
                     if isValid and score < bestScore then
                         bestScore = score
                         closestPlayer = enemy
                         targetAimPart = targetPart
                         targetAimPoint = point
                     end
                 end
            end
        end
    end
    
    if targetAimPoint and targetAimPart then
         return closestPlayer, targetAimPart, targetAimPoint
    end
    return nil, nil, nil
end

--// ==========================================
--// TRACER FUNCTIONS
--// ==========================================
local function draw_tracer(origin, target_pos)
    local beam = Instance.new("Beam")
    local att0 = Instance.new("Attachment")
    local att1 = Instance.new("Attachment")
    local part0 = Instance.new("Part", Workspace)
    part0.Size = Vector3.new(0.01, 0.01, 0.01)
    part0.Position = origin
    part0.Anchored = true
    part0.Transparency = 1
    part0.CanCollide = false
    local part1 = Instance.new("Part", Workspace)
    part1.Size = Vector3.new(0.01, 0.01, 0.01)
    part1.Position = target_pos
    part1.Anchored = true
    part1.Transparency = 1
    part1.CanCollide = false
    att0.Parent = part0
    att1.Parent = part1
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Parent = Workspace
    beam.Texture = "http://www.roblox.com/asset/?id=446111271"
    beam.TextureSpeed = 4
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Color = ColorSequence.new(_G.Config.BulletTracerColor)
    beam.Transparency = NumberSequence.new(0)
    task.delay(_G.Config.TracerDuration or 1.5, function()
        beam:Destroy()
        part0:Destroy()
        part1:Destroy()
    end)
end

--// ==========================================
--// DRAWING OBJECTS
--// ==========================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Visible = false

local wbBox = Drawing.new("Square")
wbBox.Visible = false
wbBox.Color = Color3.fromRGB(255, 0, 0)
wbBox.Thickness = 2
wbBox.Filled = true
wbBox.Transparency = 0.5
wbBox.Size = Vector2.new(20, 20)

local wbText = Drawing.new("Text")
wbText.Visible = false
wbText.Color = Color3.fromRGB(255, 255, 255)
wbText.Size = 18
wbText.Center = true
wbText.Outline = true

--// ==========================================
--// SILENT AIM HOOK (PREFERED METHOD - NO ERRORS)
--// ==========================================

-- Variables pour le hook
local bulletModule = nil
local originalPerformRaycast = nil
local LocalShots = {}

-- Chercher le module Bullet
local function FindBulletModule()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Components = ReplicatedStorage:FindFirstChild("Components")
    if Components then
        local Weapon = Components:FindFirstChild("Weapon")
        if Weapon then
            local Classes = Weapon:FindFirstChild("Classes")
            if Classes then
                local Bullet = Classes:FindFirstChild("Bullet")
                if Bullet and Bullet:IsA("ModuleScript") then
                    return Bullet
                end
            end
        end
    end
    return nil
end

-- Fonction pour créer un résultat de tir factice (Silent Aim)
local function CreateFakeBulletResult(targetPart, targetPos, startPos)
    local direction = (targetPos - startPos).Unit
    local distance = (targetPos - startPos).Magnitude
    
    return {
        Hits = {{
            Instance = targetPart,
            Position = targetPos,
            Normal = Vector3.new(0, 1, 0),
            Material = targetPart.Material,
            Distance = distance,
            Exit = false
        }},
        Ray = Ray.new(startPos, direction),
        Instance = targetPart,
        Position = targetPos,
        Material = targetPart.Material,
        Normal = Vector3.new(0, 1, 0),
        Distance = distance,
        Direction = direction,
        Origin = startPos
    }
end

-- Hook la fonction _performRaycast
local function SetupSilentAim()
    local Bullet = FindBulletModule()
    if not Bullet then
        task.wait(1)
        SetupSilentAim()
        return
    end
    
    local success, bulletTable = pcall(require, Bullet)
    if not success or not bulletTable then
        task.wait(1)
        SetupSilentAim()
        return
    end
    
    if bulletTable._performRaycast then
        originalPerformRaycast = bulletTable._performRaycast
    elseif bulletTable.performRaycast then
        originalPerformRaycast = bulletTable.performRaycast
        bulletTable.performRaycast = nil
    end
    
    if not originalPerformRaycast then
        task.wait(1)
        SetupSilentAim()
        return
    end
    
    bulletTable._performRaycast = function(self, spreadAmount)
        if _G.Config.NoSpread or _G.Config.SilentAim then
            spreadAmount = 0
        end
        
        local target, targetPart, targetPoint = getClosestTarget()
        local startPos = camera and camera.CFrame.Position
        
        if _G.Config.SilentAim and target and targetPart and startPos then
            local targetPos = targetPoint or targetPart.Position
            
            -- Enregistrer le tir pour les impacts
            table.insert(LocalShots, {
                Position = targetPos,
                Time = tick()
            })
            
            -- Tracer si activé
            if _G.Config.ShowTracers then
                draw_tracer(startPos, targetPos)
            end
            
            -- Hitmarker
            SpawnHitmarker(targetPos)
            
            -- Son de hit
            if _G.Config.PlayHitSound then
                playHitSound()
            end
            
            -- Créer un résultat factice
            return CreateFakeBulletResult(targetPart, targetPos, startPos)
        end
        
        -- Si Silent Aim désactivé ou pas de cible, comportement normal
        if originalPerformRaycast then
            return originalPerformRaycast(self, spreadAmount)
        end
        return nil
    end
    
    print("Silent Aim hooké avec succès!")
end

-- Démarrer le hook
task.spawn(SetupSilentAim)

--// ==========================================
--// ANTI-AIM (CFrame MODIFICATION)
--// ==========================================
local IsGrenadeActive = false
local AATarget = nil

local function UpdateAATarget()
    if not _G.Config.AntiAim then 
        AATarget = nil
        return 
    end
    pcall(function()
        local bestCandidate = nil
        local bestScore = math.huge 
        local origin = camera.CFrame.Position
        local lookVec = camera.CFrame.LookVector
        
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, p in pairs(enemyFolder:GetChildren()) do
                local root = p:FindFirstChild("HumanoidRootPart")
                local hum = p:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local diff = (root.Position - origin)
                    if diff.Magnitude > 0.1 then
                        local dir = diff.Unit
                        local dot = lookVec:Dot(dir)
                        local score = 1 - dot 
                        if score < bestScore then
                            bestScore = score
                            bestCandidate = p
                        end
                    end
                end
            end
        end
        AATarget = bestCandidate
    end)
end

-- Vérifier si une grenade est active
task.spawn(function()
    while task.wait(0.5) do
        local active = false
        if camera then
            for _, child in ipairs(camera:GetChildren()) do
                local name = child.Name:lower()
                if name:find("grenade") or name:find("flash") or name:find("molotov") or name:find("decoy") or name:find("smoke") then
                    active = true
                    break
                end
            end
        end
        IsGrenadeActive = active
    end
end)

-- Hook pour Anti-Aim
local function SetupAntiAim()
    local mt = getrawmetatable(game)
    if not mt then return end
    setreadonly(mt, false)
    local oldIndex = mt.__index
    
    mt.__index = newcclosure(function(self, k)
        if self == camera and k == "CFrame" and _G.Config.AntiAim then
            if not checkcaller() then
                if IsGrenadeActive then
                    return oldIndex(self, k)
                end
                
                local trace = debug.traceback()
                if trace:find("Viewmodel") or trace:find("Bobble") or trace:find("WeaponComponent") or 
                   trace:find("CameraController") or trace:find("Loadout") then
                    return oldIndex(self, k)
                end
                
                if trace:find("ByteNet") or trace:find("Spectate") or trace:find("UpdateCameraCFrame") or trace:find("Replicate") then
                    local realCFrame = oldIndex(self, k)
                    local _, realYaw, _ = realCFrame:ToEulerAnglesYXZ()
                    local pitch = -1.57
                    if _G.Config.AntiAimPitchMode == "Up" then pitch = 1.57 end
                    local yawOffset = 0
                    if _G.Config.AntiAimBackwards then yawOffset = math.pi end
                    
                    local targetYaw = realYaw
                    if _G.Config.FollowBackwardsAA and AATarget and AATarget:FindFirstChild("HumanoidRootPart") then
                        local myChar = player.Character
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            local targetPos = AATarget.HumanoidRootPart.Position
                            local myPos = myChar.HumanoidRootPart.Position
                            local horizontalDiff = Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(myPos.X, 0, myPos.Z)
                            if horizontalDiff.Magnitude > 0.1 then
                                local lookCFrame = CFrame.lookAt(myPos, Vector3.new(targetPos.X, myPos.Y, targetPos.Z))
                                local _, tYaw, _ = lookCFrame:ToEulerAnglesYXZ()
                                targetYaw = tYaw
                                yawOffset = math.pi 
                            end
                        end
                    end
                    
                    return CFrame.new(realCFrame.Position) * CFrame.fromEulerAnglesYXZ(pitch, targetYaw + yawOffset, 0)
                end
            end
        end
        return oldIndex(self, k)
    end)
    setreadonly(mt, true)
    print("Anti-Aim hooké avec succès!")
end

task.spawn(SetupAntiAim)

--// ==========================================
--// THIRD PERSON
--// ==========================================
local function SetupThirdPerson()
    if getrawmetatable and setreadonly then
        local mt = getrawmetatable(game)
        local oldNewIndex = mt.__newindex
        setreadonly(mt, false)
        mt.__newindex = newcclosure(function(self, key, value)
            if self == player then
                if _G.Config.ThirdPerson then
                    if key == "CameraMode" then
                        return oldNewIndex(self, key, Enum.CameraMode.Classic)
                    elseif key == "CameraMaxZoomDistance" then
                        return oldNewIndex(self, key, _G.Config.ThirdPersonDist)
                    elseif key == "CameraMinZoomDistance" then
                        return oldNewIndex(self, key, _G.Config.ThirdPersonDist)
                    end
                end
            end
            return oldNewIndex(self, key, value)
        end)
        setreadonly(mt, true)
    end
end

task.spawn(SetupThirdPerson)

-- Mettre à jour la Third Person quand les paramètres changent
local function UpdateThirdPerson()
    if _G.Config.ThirdPerson then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMaxZoomDistance = _G.Config.ThirdPersonDist
        player.CameraMinZoomDistance = _G.Config.ThirdPersonDist
    else
        player.CameraMode = Enum.CameraMode.LockFirstPerson
        player.CameraMaxZoomDistance = 0.5
        player.CameraMinZoomDistance = 0.5
    end
end

--// ==========================================
--// TRIGGERBOT (AUTO FIRE) AVEC WALLBANG
--// ==========================================
local lastFireTime = 0
local lastScopeTime = 0
local isScoping = false

local function GetTriggerbotTarget()
    local mouseLoc = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character, camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    
    if res and res.Instance then
        local hitInstance = res.Instance
        local enemyFolder = getEnemyFolder()
        if enemyFolder and hitInstance:IsDescendantOf(enemyFolder) then
            local hum = hitInstance.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return hitInstance.Parent
            end
        end
    end
    
    -- Auto Wallbang pour Triggerbot
    if _G.Config.LegitAutoWallbang then
        enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, enemy in pairs(enemyFolder:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local root = enemy:FindFirstChild("HumanoidRootPart")
                local head = enemy:FindFirstChild("Head")
                
                if hum and hum.Health > 0 and root and head then
                    local bones = {head, root, enemy:FindFirstChild("UpperTorso")}
                    for _, bone in ipairs(bones) do
                        if bone then
                            local sPos, visible = camera:WorldToViewportPoint(bone.Position)
                            if sPos.Z > 0 then
                                local dist = (Vector2.new(sPos.X, sPos.Y) - mouseLoc).Magnitude
                                if dist < (_G.Config.TriggerbotRadius or 10) then
                                    local weaponPen = CurrentWeaponData.Penetration or 2.5
                                    if IsHitPossible(enemy, ray.Origin, weaponPen, bone.Position) then
                                        return enemy
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Auto Fire Loop
task.spawn(function()
    while task.wait(0.01) do
        if _G.Config.AutoFire and isAlive() then
            -- Vérifier si on tient une grenade
            local holdingGrenade = false
            if camera then
                for _, child in ipairs(camera:GetChildren()) do
                    local name = child.Name:lower()
                    if name:find("grenade") or name:find("flash") or name:find("molotov") or name:find("decoy") or name:find("smoke") then
                        holdingGrenade = true
                        break
                    end
                end
            end
            
            if not holdingGrenade then
                local target = GetTriggerbotTarget()
                
                if target then
                    -- Auto Stop
                    if _G.Config.LegitAutoStop and player.Character then
                        local rp = player.Character:FindFirstChild("HumanoidRootPart")
                        if rp then
                            local vel = rp.AssemblyLinearVelocity
                            rp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum:Move(Vector3.new(0,0,0), true) end
                        end
                    end
                    
                    -- Auto Scope
                    if _G.Config.LegitAutoScope then
                        local isScoped = (player:GetAttribute("ScopeIncrement") or 0) > 0
                        if not isScoped and not isScoping then
                            isScoping = true
                            lastScopeTime = tick()
                            if mouse2press then
                                mouse2press()
                            else
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                            end
                            task.delay(0.2, function()
                                if mouse2release then
                                    mouse2release()
                                else
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendMouseButtonEvent(0, 0, 1, false, game, 1)
                                end
                                isScoping = false
                            end)
                        end
                    end
                    
                    -- Tirer
                    local now = tick()
                    if now - lastFireTime > 0.05 then
                        lastFireTime = now
                        if mouse1click then
                            mouse1click()
                        else
                            local vim = game:GetService("VirtualInputManager")
                            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// NO RECOIL / NO SPREAD / CUSTOM FOV
--// ==========================================
local CameraController = nil
local OldWeaponKick = nil
local OldSetRecoil = nil

local function UpdateRecoil()
    if not CameraController then
        pcall(function() 
            CameraController = require(game.ReplicatedStorage.Controllers.CameraController) 
            if CameraController then
                OldWeaponKick = CameraController.weaponKick
                OldSetRecoil = CameraController.setWeaponRecoil
            end
        end)
    end
    if CameraController then
        if _G.Config.NoRecoilVisual then
            CameraController.weaponKick = function() end
        else
            if OldWeaponKick then CameraController.weaponKick = OldWeaponKick end
        end
        if _G.Config.NoRecoilReal then
            CameraController.setWeaponRecoil = function() end
        else
            if OldSetRecoil then CameraController.setWeaponRecoil = OldSetRecoil end
        end
    end
end

--// ==========================================
--// SKYBOX & WEATHER
--// ==========================================
local skyboxtable = {
    ["Standard"] = {
        SkyboxBk = "http://www.roblox.com/asset/?id=91458024",  
        SkyboxDn = "http://www.roblox.com/asset/?id=91457980",
        SkyboxFt = "http://www.roblox.com/asset/?id=91458024",
        SkyboxLf = "http://www.roblox.com/asset/?id=91458024",
        SkyboxRt = "http://www.roblox.com/asset/?id=91458024",
        SkyboxUp = "http://www.roblox.com/asset/?id=91458002"
    },
    ["Minecraft"] = {
        SkyboxBk = "rbxassetid://8735166756",
        SkyboxDn = "http://www.roblox.com/asset/?id=8735166707",
        SkyboxFt = "http://www.roblox.com/asset/?id=8735231668",
        SkyboxLf = "http://www.roblox.com/asset/?id=8735166755",
        SkyboxRt = "http://www.roblox.com/asset/?id=8735166751",
        SkyboxUp = "http://www.roblox.com/asset/?id=8735166729"
    },
    ["Spongebob"] = {
        SkyboxBk = "rbxassetid://277099484",
        SkyboxDn = "rbxassetid://277099500",
        SkyboxFt = "rbxassetid://277099554",
        SkyboxLf = "rbxassetid://277099531",
        SkyboxRt = "rbxassetid://277099589",
        SkyboxUp = "rbxassetid://277101591"
    },
    ["Deep Space"] = {
        SkyboxBk = "rbxassetid://159248188",
        SkyboxDn = "rbxassetid://159248183",
        SkyboxFt = "rbxassetid://159248187",
        SkyboxLf = "rbxassetid://159248173",
        SkyboxRt = "rbxassetid://159248192",
        SkyboxUp = "rbxassetid://159248176"
    },
    ["Clouded Sky"] = {
        SkyboxBk = "rbxassetid://252760981",
        SkyboxDn = "rbxassetid://252763035",
        SkyboxFt = "rbxassetid://252761439",
        SkyboxLf = "rbxassetid://252760980",
        SkyboxRt = "rbxassetid://252760986",
        SkyboxUp = "rbxassetid://252762652"
    }
}

local function UpdateSkybox(name)
    local data = skyboxtable[name]
    if not data then return end
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("Clouds") then
            v:Destroy()
        end
    end
    local sky = Lighting:FindFirstChild("Milka_Sky")
    if not sky then
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        sky = Instance.new("Sky")
        sky.Name = "Milka_Sky"
        sky.Parent = Lighting
    end
    sky.SkyboxBk = data.SkyboxBk
    sky.SkyboxDn = data.SkyboxDn
    sky.SkyboxFt = data.SkyboxFt
    sky.SkyboxLf = data.SkyboxLf
    sky.SkyboxRt = data.SkyboxRt
    sky.SkyboxUp = data.SkyboxUp
end

local WeatherPart = nil
local CurrentWeatherType = "None"

local function UpdateWeather(wType)
    _G.Config.Weather = wType
    CurrentWeatherType = wType
    if WeatherPart then WeatherPart:Destroy() WeatherPart = nil end
    
    if wType == "None" then return end
    
    WeatherPart = Instance.new("Part")
    WeatherPart.Name = "Milka_Weather"
    WeatherPart.Size = Vector3.new(100, 1, 100)
    WeatherPart.Transparency = 1
    WeatherPart.Anchored = true
    WeatherPart.CanCollide = false
    WeatherPart.Parent = camera
    
    local emitter = Instance.new("ParticleEmitter")
    emitter.Parent = WeatherPart
    emitter.EmissionDirection = Enum.NormalId.Bottom
    
    if wType == "Rain" then
        emitter.Texture = "rbxassetid://241868005"
        emitter.Rate = 10000
        emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        emitter.Transparency = NumberSequence.new(0)
        emitter.Size = NumberSequence.new(3, 6)
        emitter.Lifetime = NumberRange.new(2, 2.5)
        emitter.Speed = NumberRange.new(80, 100)
        emitter.Acceleration = Vector3.new(0, -50, 0)
    elseif wType == "Snow" then
        emitter.Texture = "rbxassetid://99851851"
        emitter.Rate = 200
        emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        emitter.Size = NumberSequence.new(0.25, 0.35)
        emitter.Speed = NumberRange.new(30, 30)
        emitter.Lifetime = NumberRange.new(5, 10)
        emitter.Acceleration = Vector3.new(0, 0, 0)
    elseif wType == "Hell Fire" then
        emitter.Texture = "rbxassetid://242205518"
        emitter.Rate = 400
        emitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(150, 0, 0))
        emitter.Size = NumberSequence.new(2, 4)
        emitter.Speed = NumberRange.new(40, 60)
        emitter.Lifetime = NumberRange.new(2, 3)
        emitter.Acceleration = Vector3.new(0, -10, 0)
    end
end

-- Mise à jour du lighting
local DefaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
}

local function UpdateLighting()
    if _G.Config.WorldTimeEnabled then
        Lighting.ClockTime = _G.Config.WorldClockTime
    else
        Lighting.ClockTime = DefaultLighting.ClockTime
    end
    if _G.Config.WorldBrightEnabled then
        Lighting.Brightness = _G.Config.WorldBrightness
    else
        Lighting.Brightness = DefaultLighting.Brightness
    end
    if _G.Config.WorldColorEnabled then
        Lighting.Ambient = _G.Config.WorldAmbient
        Lighting.OutdoorAmbient = _G.Config.WorldOutdoorAmbient
    else
        Lighting.Ambient = DefaultLighting.Ambient
        Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    end
end

--// ==========================================
--// REMOVALS (NO FLASH, NO SMOKE, NO FALL DAMAGE)
--// ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if _G.Config.NoFlash then
            local gui = player.PlayerGui:FindFirstChild("FlashbangEffect")
            if gui then gui:Destroy() end
            local effect = Lighting:FindFirstChild("FlashbangColorCorrection")
            if effect then effect:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.Config.NoSmoke then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if string.match(folder.Name, "Voxel") then
                        folder:ClearAllChildren()
                        folder:Destroy()
                    end
                end
            end
        end
    end
end)

-- No Fall Damage via hook
task.spawn(function()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Remotes = require(ReplicatedStorage.Database.Security.Remotes)
        local FallDamagePacket = Remotes.Character.FallDamage
        if FallDamagePacket and FallDamagePacket.Send then
            local oldSend = FallDamagePacket.Send
            FallDamagePacket.Send = function(...)
                if _G.Config.NoFallDamage then
                    return
                end
                return oldSend(...)
            end
        end
    end)
end)

--// ==========================================
--// RENDER LOOP (FOV, WALLBANG INDICATOR, UPDATE)
--// ==========================================
RunService.RenderStepped:Connect(function()
    if not camera then camera = Workspace.CurrentCamera end
    if not camera then return end
    
    -- Mettre à jour la cible Anti-Aim
    UpdateAATarget()
    
    -- FOV Circle
    local mouse_pos = UserInputService:GetMouseLocation()
    fovCircle.Position = mouse_pos
    fovCircle.Radius = _G.Config.FovRadius or 100
    fovCircle.Visible = _G.Config.ShowFov and (_G.Config.SilentAim or _G.Config.EnableFov)
    fovCircle.Color = _G.Config.FovColor or Color3.fromRGB(255, 255, 255)
    
    -- Custom FOV
    if _G.Config.EnableFov then
        camera.FieldOfView = _G.Config.CustomFovValue
    end
    
    -- Custom Scope FOV
    local scopeInc = player:GetAttribute("ScopeIncrement") or 0
    local isScopedNow = scopeInc > 0
    if isScopedNow and _G.Config.CustomScopeFov then
        camera.FieldOfView = _G.Config.ScopeFovValue
    end
    
    -- No Scope Overlay
    if isScopedNow and _G.Config.NoScopeOverlay then
        local mainGui = player.PlayerGui:FindFirstChild("MainGui")
        if mainGui then
            local gameplay = mainGui:FindFirstChild("Gameplay")
            if gameplay then
                local scope = gameplay:FindFirstChild("Scope")
                if scope then scope.Visible = false end
            end
        end
    end
    
    -- Remove Scope
    if _G.Config.RemoveScope then
        local mainGui = player.PlayerGui:FindFirstChild("MainGui")
        if mainGui then
            local gameplay = mainGui:FindFirstChild("Gameplay")
            if gameplay then
                local scope = gameplay:FindFirstChild("Scope")
                if scope and scope.Visible then
                    scope.Size = UDim2.new(0, 0, 0, 0)
                end
            end
        end
    end
    
    -- Wallbang Indicator
    if _G.Config.ShowWallbangIndicator then
        local camCFrame = camera.CFrame
        local origin = camCFrame.Position
        local direction = camCFrame.LookVector * 1000
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {player.Character, camera}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(origin, direction, rayParams)
        
        if hit then
            local screenPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            wbBox.Visible = true
            wbBox.Position = screenPos - (wbBox.Size / 2)
            wbText.Visible = true
            wbText.Position = screenPos + Vector2.new(0, 15)
            
            local stats = GetPenetrationStats(origin, direction, 2.5, {player.Character, camera}, nil)
            if stats.Success then
                wbBox.Color = Color3.fromRGB(0, 255, 0)
                wbText.Text = "WALLBANG: YES"
                wbText.Color = Color3.fromRGB(0, 255, 0)
            else
                wbBox.Color = Color3.fromRGB(255, 0, 0)
                wbText.Text = "WALLBANG: NO"
                wbText.Color = Color3.fromRGB(255, 0, 0)
            end
        else
            wbBox.Visible = false
            wbText.Visible = false
        end
    else
        wbBox.Visible = false
        wbText.Visible = false
    end
    
    -- Update lighting toutes les 10 frames environ
    if tick() % 0.5 < 0.05 then
        UpdateLighting()
        if _G.Config.WorldSkyboxEnabled then
            local mySky = Lighting:FindFirstChild("Milka_Sky")
            if not mySky then
                UpdateSkybox(_G.Config.WorldSkybox)
            end
        end
    end
    
    -- Weather position
    if WeatherPart then
        WeatherPart.CFrame = camera.CFrame * CFrame.new(0, 30, 0)
    end
end)

--// ==========================================
--// BHOP (BUNNY HOP)
--// ==========================================
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end
    
    if _G.Config.Bhop then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local groundCheck = Workspace:Raycast(rootPart.Position, Vector3.new(0, -4, 0), rayParams)
            if groundCheck then
                humanoid.Jump = true
            end
        end
        
        -- Bhop Speed
        local moveDirection = Vector3.zero
        local lookVector = camera.CFrame.LookVector
        local rightVector = camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += lookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= lookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= rightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += rightVector end
        
        moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection * _G.Config.BhopSpeed
            local velocity = rootPart.AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(
                velocity.X + (moveDirection.X - velocity.X) * 0.2,
                velocity.Y,
                velocity.Z + (moveDirection.Z - velocity.Z) * 0.2
            )
        end
    end
end)

--// ==========================================
--// AUTO SCOPE
--// ==========================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
        if _G.Config.AutoScope and player.Character then
            local isScoped = (player:GetAttribute("ScopeIncrement") or 0) > 0
            if not isScoped then
                task.spawn(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                    task.wait(math.random(0.15, 0.2))
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait()
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    task.wait(math.random(0.1, 0.15))
                    vim:SendMouseButtonEvent(0, 0, 1, false, game, 1)
                end)
            end
        end
    end
end)

--// ==========================================
--// ESP (VISUALS)
--// ==========================================
local espCache = {}
local espDrawingObjects = {}

local function createESPDrawing()
    return {
        boxOutline = Drawing.new("Square"),
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        healthOutline = Drawing.new("Line"),
        healthBar = Drawing.new("Line"),
        distance = Drawing.new("Text"),
        headDot = Drawing.new("Circle"),
        tracer = Drawing.new("Line")
    }
end

local function setupESPDrawing(obj)
    obj.boxOutline.Thickness = 3
    obj.boxOutline.Filled = false
    obj.boxOutline.Color = Color3.new(0, 0, 0)
    
    obj.box.Thickness = 1
    obj.box.Filled = false
    
    obj.name.Center = true
    obj.name.Outline = true
    obj.name.Size = 14
    
    obj.healthOutline.Thickness = 3
    obj.healthOutline.Color = Color3.new(0, 0, 0)
    
    obj.healthBar.Thickness = 2
    
    obj.distance.Center = true
    obj.distance.Outline = true
    obj.distance.Size = 12
    
    obj.headDot.Radius = 3
    obj.headDot.Filled = true
    
    obj.tracer.Thickness = 1
end

RunService.RenderStepped:Connect(function()
    if not _G.Config.Esp or not isAlive() then
        for _, esp in pairs(espCache) do
            for _, d in pairs(esp) do
                if d then d.Visible = false end
            end
        end
        return
    end
    
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end
    
    local currentAlive = {}
    
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local head = enemy:FindFirstChild("Head")
        
        if hum and hum.Health > 0 and root and head then
            currentAlive[enemy] = true
            
            if not espCache[enemy] then
                espCache[enemy] = createESPDrawing()
                setupESPDrawing(espCache[enemy])
            end
            
            local esp = espCache[enemy]
            local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if onScreen then
                local boxH = math.abs(headPos.Y - legPos.Y)
                local boxW = boxH / 2
                local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                
                -- Box
                if _G.Config.EspBoxes then
                    esp.boxOutline.Size = Vector2.new(boxW, boxH)
                    esp.boxOutline.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                    esp.boxOutline.Visible = true
                    
                    esp.box.Size = Vector2.new(boxW, boxH)
                    esp.box.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                    esp.box.Color = _G.Config.BoxColor
                    esp.box.Visible = true
                else
                    esp.boxOutline.Visible = false
                    esp.box.Visible = false
                end
                
                -- Health Bar
                if _G.Config.EspHealthBar then
                    local hpPct = hum.Health / hum.MaxHealth
                    local barX = rootPos.X - boxW / 2 - 6
                    esp.healthOutline.From = Vector2.new(barX, headPos.Y - 1)
                    esp.healthOutline.To = Vector2.new(barX, headPos.Y + boxH + 1)
                    esp.healthOutline.Visible = true
                    
                    esp.healthBar.From = Vector2.new(barX, headPos.Y + boxH)
                    esp.healthBar.To = Vector2.new(barX, headPos.Y + boxH - (boxH * hpPct))
                    esp.healthBar.Color = _G.Config.HealthBarColor
                    esp.healthBar.Visible = true
                else
                    esp.healthOutline.Visible = false
                    esp.healthBar.Visible = false
                end
                
                -- Name
                if _G.Config.EspNames then
                    esp.name.Text = enemy.Name
                    esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                    esp.name.Color = _G.Config.NameColor
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end
                
                -- Distance
                if _G.Config.EspDistance then
                    esp.distance.Text = "[" .. dist .. "m]"
                    esp.distance.Position = Vector2.new(rootPos.X, headPos.Y + boxH + 2)
                    esp.distance.Color = _G.Config.DistColor
                    esp.distance.Visible = true
                else
                    esp.distance.Visible = false
                end
                
                -- Head Dot
                if _G.Config.EspHeadDot then
                    esp.headDot.Position = Vector2.new(rootPos.X, headPos.Y + boxH * 0.15)
                    esp.headDot.Color = _G.Config.HeadDotColor
                    esp.headDot.Visible = true
                else
                    esp.headDot.Visible = false
                end
                
                -- Tracers
                if _G.Config.EspTracers then
                    esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    esp.tracer.Color = _G.Config.TracerColor
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                for _, d in pairs(esp) do
                    if d then d.Visible = false end
                end
            end
        end
    end
    
    -- Cleanup
    for enemy, esp in pairs(espCache) do
        if not currentAlive[enemy] then
            for _, d in pairs(esp) do
                if d then d:Remove() end
            end
            espCache[enemy] = nil
        end
    end
end)

--// ==========================================
--// KILL EFFECTS
--// ==========================================
local function ApplyKillEffect(model)
    local torso = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    if not torso then return end
    
    local mode = _G.Config.KillEffectMode
    
    if mode == "Rocket" then
        local fire = Instance.new("ParticleEmitter", torso)
        fire.Texture = "rbxassetid://242905630"
        fire.Color = ColorSequence.new(Color3.fromRGB(255, 138, 59), Color3.fromRGB(255, 0, 0))
        fire.Size = NumberSequence.new(0.8, 0)
        fire.Rate = 100
        fire.Speed = NumberRange.new(5, 10)
        fire.Lifetime = NumberRange.new(0.5, 1)
        
        local bv = Instance.new("BodyVelocity", torso)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 50, 0)
        
        task.delay(_G.Config.KillEffectDuration or 3, function()
            if model.Parent then model:Destroy() end
        end)
        
    elseif mode == "Lightning" then
        local startPos = torso.Position + Vector3.new(0, 5, 0)
        local endPos = torso.Position
        
        local function CreateBolt(p1, p2)
            local dist = (p1 - p2).Magnitude
            local part = Instance.new("Part", Workspace)
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(100, 200, 255)
            part.Anchored = true
            part.CanCollide = false
            part.Size = Vector3.new(0.2, 0.2, dist)
            part.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist/2)
            Debris:AddItem(part, 0.3)
        end
        
        CreateBolt(startPos, endPos)
        task.delay(_G.Config.KillEffectDuration or 2, function() model:Destroy() end)
        
    elseif mode == "Disintegrate" then
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Neon
                v.Color = Color3.fromRGB(255, 100, 50)
                local dust = Instance.new("ParticleEmitter", v)
                dust.Texture = "rbxassetid://242205574"
                dust.Size = NumberSequence.new(0.3, 0)
                dust.Rate = 100
                dust.Lifetime = NumberRange.new(1, 2)
                task.delay(math.random() * 0.5, function()
                    local tween = TweenService:Create(v, TweenInfo.new(1), {Transparency = 1})
                    tween:Play()
                end)
            end
        end
        task.delay(_G.Config.KillEffectDuration or 2, function() model:Destroy() end)
        
    else -- Default: Ascension
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = true
                v.CanCollide = false
                v.Material = Enum.Material.Ice
                v.Color = Color3.fromRGB(255, 215, 0)
            end
        end
        
        task.spawn(function()
            local t = 0
            local duration = _G.Config.KillEffectDuration or 3
            while t < duration and model.Parent do
                local dt = RunService.Heartbeat:Wait()
                t = t + dt
                for _, v in pairs(model:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Position = v.Position + Vector3.new(0, dt * 5, 0)
                        v.Transparency = 0.3 + (t / duration * 0.7)
                    end
                end
            end
            model:Destroy()
        end)
    end
end

local debrisFolder = Workspace:FindFirstChild("Debris")
if debrisFolder then
    debrisFolder.ChildAdded:Connect(function(child)
        if _G.Config.KillEffect and child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
            task.wait(0.05)
            ApplyKillEffect(child)
        end
    end)
end

--// ==========================================
--// CUSTOM PARTICLES
--// ==========================================
task.spawn(function()
    local debris = Workspace:WaitForChild("Debris")
    debris.ChildAdded:Connect(function(child)
        if not _G.Config.CustomParticles then return end
        task.wait()
        local targetColor = ColorSequence.new(_G.Config.ParticleColor or Color3.fromRGB(170, 0, 255))
        for _, descendant in ipairs(child:GetDescendants()) do
            if descendant:IsA("ParticleEmitter") then
                descendant.Color = targetColor
                descendant.LightEmission = 1
            end
        end
    end)
end)

--// ==========================================
--// SAVE CONFIGURATION
--// ==========================================
Rayfield:LoadConfiguration()
