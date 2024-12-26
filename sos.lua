local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local blackHoleActive = false
local rotationSpeed = 1000
local pullRange = 150

local function findPlayerByName(partialName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(partialName:lower()) then
            return player
        end
    end
    return nil
end

local function setupTargetPlayer(targetPlayer)
    local character = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function ForcePart(v, targetPart)
    if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) then
        local distance = (v.Position - targetPart.Position).Magnitude
        if distance <= pullRange then
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                    x:Destroy()
                end
            end
            if v:FindFirstChild("Attachment") then
                v:FindFirstChild("Attachment"):Destroy()
            end
            if v:FindFirstChild("AlignPosition") then
                v:FindFirstChild("AlignPosition"):Destroy()
            end
            v.CanCollide = false

            local AlignPosition = Instance.new("AlignPosition", v)
            local Attachment = Instance.new("Attachment", v)
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 500
            AlignPosition.Attachment0 = Attachment

            local targetAttachment = Instance.new("Attachment", targetPart)
            AlignPosition.Attachment1 = targetAttachment

            local BodyAngularVelocity = Instance.new("BodyAngularVelocity", v)
            BodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            BodyAngularVelocity.AngularVelocity = Vector3.new(0, rotationSpeed, 0)
        end
    end
end

local function toggleBlackHole(targetName)
    blackHoleActive = not blackHoleActive

    if blackHoleActive then
        local targetPlayer = findPlayerByName(targetName)
        if not targetPlayer then
            return
        end

        local targetPart = setupTargetPlayer(targetPlayer)

        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v, targetPart)
        end

        Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then
                ForcePart(v, targetPart)
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        local command, targetName = message:match("!(%w+)%s*(.*)")
        if command and command:lower() == "sos" then
            if targetName and targetName ~= "" then
                toggleBlackHole(targetName)
            end
        end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        local command, targetName = message:match("!(%w+)%s*(.*)")
        if command and command:lower() == "sos" then
            if targetName and targetName ~= "" then
                toggleBlackHole(targetName)
            end
        end
    end)
end
