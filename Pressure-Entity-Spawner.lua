--[[
 ██████╗ ██╗   ██╗███████╗███████╗████████╗██╗  ██╗   ██╗
██╔════╝ ██║   ██║██╔════╝██╔════╝╚══██╔══╝██║  ╚██╗ ██╔╝
██║  ███╗██║   ██║█████╗  ███████╗   ██║   ██║   ╚████╔╝
██║   ██║██║   ██║██╔══╝  ╚════██║   ██║   ██║    ╚██╔╝
╚██████╔╝╚██████╔╝███████╗███████║   ██║   ███████╗██║
 ╚═════╝  ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝

███████╗███╗   ██╗████████╗██╗████████╗██╗   ██╗
██╔════╝████╗  ██║╚══██╔══╝██║╚══██╔══╝╚██╗ ██╔╝
█████╗  ██╔██╗ ██║   ██║   ██║   ██║    ╚████╔╝
██╔══╝  ██║╚██╗██║   ██║   ██║   ██║     ╚██╔╝
███████╗██║ ╚████║   ██║   ██║   ██║      ██║
╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝   ╚═╝      ╚═╝

███████╗██████╗  █████╗ ██╗    ██╗███╗   ██╗███████╗██████╗ 
██╔════╝██╔══██╗██╔══██╗██║    ██║████╗  ██║██╔════╝██╔══██╗
███████╗██████╔╝███████║██║ █╗ ██║██╔██╗ ██║█████╗  ██████╔╝
╚════██║██╔═══╝ ██╔══██║██║███╗██║██║╚██╗██║██╔══╝  ██╔══██╗
███████║██║     ██║  ██║╚███╔███╔╝██║ ╚████║███████╗██║  ██║
╚══════╝╚═╝     ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝

                    GUESTLY — 2026
                 ALL RIGHTS RESERVED
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local TweenService = game:GetService("TweenService")  
local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local SerializationService = game:GetService("SerializationService")  
  
local Workspace = workspace  
local Gameplay = Workspace:WaitForChild("GameplayFolder")  
local Rooms = Gameplay:WaitForChild("Rooms")  
local Camera = Workspace.CurrentCamera  
local SoundService = game:GetService("SoundService")  
  
local Player = Players.LocalPlayer  
local PlayerGui = Player:WaitForChild("PlayerGui")  
local FlickerEnabled = false  
local entityReady = false
local hitboxActive = false
local buildFullPath
local DeafGui
local DeafImage
local DeafConnection
local rootPart = nil  
local entityModel = nil  
local entityFinished = false  
  
local Remotes = ReplicatedStorage:WaitForChild("Events")  
local URSpecialEffects = Remotes:WaitForChild("URSpecialEffects")  
  
local EntityConfig = {  
AssetId = "rbxassetid://71148476112454",  
EntityName = "Unknown Entity",  
MoveSpeed = 40,  
HitboxRadius = 50,  
ShakeRadius = 100,  
DamageAmount = 10,        -- Lượng máu mất khi tóm (không chết ngay)  
InstantKill = true,  
ConstantBloodSucking = false, -- Thêm vào bảng EntityConfig  
DelayEachDamage = 0.5,          -- Thêm vào bảng EntityConfig  
  
DelayWhenSpawned = false,      -- Bật/tắt việc chờ đợi khi spawn    
Delay = 1,                     -- Số giây chờ trước khi bắt đầu di chuyển    
Rebounding = false,     
MinRebounds = 1,            -- Số lần rebound tối thiểu    
MaxRebounds = 1,    
Reversed = false, -- Thêm dòng này vào bảng EntityConfig    
DelayEachRebound = 1,    
WallPenetrating = false, -- Thêm dòng này vào bảng EntityConfig    
IgnoreHiding = false, -- Thêm dòng này: false = không tấn công khi trốn tủ, true = tấn công xuyên tủ    
RoomLimits = false,    
RoomLimitValue = 5,    
EntityLifeTime = "Forever", -- hoặc 15, 7.5,...    
    
YOffset = Vector3.new(0, 4, 0),    
DespawnYOffset = Vector3.new(0, 30, 0),    
Tolerance = 0.1,    
FlickerSpeed = 75,    
MaxDarkness = 0.2,    
ShakeIntensity = 2.5,    
ShakeSpeedMultiplier = 1.5,    
LightFlickerTime = 0,          -- Thời gian chớp đèn liên tục khi mới spawn    
LightFlickersUntilDespawn = false,    
    
-- Cấu hình bật/tắt hiệu ứng True/False    
EnableFlicker = true,    
EnableShake = true,    
EnableBlackout = true,    
EnableBreakLights = true,  -- True: Phá vỡ đèn khi qua phòng | False: Bỏ qua    

DeafModeFrameTransparency = 0.6,
DeafModeFrameColor = Color3.new(1,1,1),
DeafModeFrameId = "rbxassetid://135625259700248",
DeafModeFrameDistance = 400,
DependsOnSpeed = true,
    
LightBreakingRange = 35,    
DarkenPercent = 0.11,    
AutoScanInterval = 0.1,    
LightSoundId = "rbxassetid://13303926122",
LightSoundVolume = 2,
LightSoundDistance = 150,
ParticleTexture = "rbxassetid://257173628",    
ParticleDuration = 0.3,    
    
GithubSound = "",              -- Link raw mp3 github    
PlayGitSoundWhenSpawned = false, -- Bật/tắt sound arrival    
SoundVolume = 1,               -- Âm lượng    
SoundPlaybackSpeed = 1,        -- Tốc độ phát    
    
-- Cấu hình giao diện UI Màn hình chết (AfterDeath)    
DeathImage = "rbxassetid://0",    
DeathName = "Unknown Entity",    
DeathNotes = "\"Paste your text here\"",    
DeathImageColor = Color3.fromRGB(255, 255, 255), -- Mặc định là trắng (giữ nguyên màu ảnh)    
    
-- Các điểm kích hoạt hàm mở rộng (Callbacks)    
OnSpawn = function() end,    
OnMoveStart = function() end,    
OnRoomEnter = function(roomName) end,    
OnDamagePlayer = function() end,    
OnKillPlayer = function() end,    
OnDespawning = function() end,    
OnDespawned = function() end,  
  
}  

local function FireCallback(callback, ...)
	if typeof(callback) ~= "function" then
		return
	end

	local args = table.pack(...)

	task.spawn(function()
		local ok, err = pcall(function()
			callback(table.unpack(args, 1, args.n))
		end)

		if not ok then
			warn("[Entity Callback Error]", err)
		end
	end)
end
  
local BREAK_SOUND_ID = "rbxassetid://13303926122"  
local currentRebounds = 0  
local isFinalRebound = false
local totalRebounds = 0
local isReboundingPaused = false  
local canRebound = false  
local reboundLock = false  
local BlacklistedExitNodes = {}  
  
-- =====================================================================  
-- CAMERA SHAKE SYSTEM (SCREEN SHAKE)  
-- =====================================================================  
local function CreateDeafModeFrame()

	local FrameTransparency = EntityConfig.DeafModeFrameTransparency
local FrameColor = EntityConfig.DeafModeFrameColor
local FrameId = EntityConfig.DeafModeFrameId
local FrameDistance = EntityConfig.DeafModeFrameDistance
local FrameSpeed = EntityConfig.DependsOnSpeed

	if FrameTransparency == nil
	or FrameColor == nil
	or FrameId == nil
	or FrameDistance == nil
	or FrameSpeed == nil then
	return
end

	local data = Player:FindFirstChild("Data")
	if not data then
		return
	end

	local settings = data:FindFirstChild("GameSettings")
	if not settings then
		return
	end

	local deaf = settings:FindFirstChild("DeafMode")
	if not deaf
	or not deaf:IsA("IntValue")
	or deaf.Value ~= 1 then
		return
	end

	if DeafGui then
		DeafGui:Destroy()
	end

	DeafGui = Instance.new("ScreenGui")
	DeafGui.Name = "EntityDeafMode"
	DeafGui.IgnoreGuiInset = true
	DeafGui.ResetOnSpawn = false
	DeafGui.DisplayOrder = 999999
	DeafGui.Parent = PlayerGui

	DeafImage = Instance.new("ImageLabel")
	DeafImage.BackgroundTransparency = 1
	DeafImage.Size = UDim2.fromScale(1,1)
	DeafImage.Position = UDim2.fromScale(0,0)
	DeafImage.ScaleType = Enum.ScaleType.Stretch
	DeafImage.Image = FrameId
	DeafImage.ImageColor3 = FrameColor
	DeafImage.ImageTransparency = 1
	DeafImage.Parent = DeafGui

	if DeafConnection then
		DeafConnection:Disconnect()
	end

	DeafConnection = RunService.RenderStepped:Connect(function(dt)

	if entityFinished then
		return
	end

	if not entityReady then
		return
	end

	if not rootPart then
		return
	end

	if not rootPart.Parent then
		return
	end

	if deaf.Value ~= 1 then
		DeafImage.ImageTransparency = 1
		return
	end

	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return
	end
	
	local dist = (hrp.Position - rootPart.Position).Magnitude

	local MaxDistance = EntityConfig.DeafModeFrameDistance or 400

if dist > MaxDistance then
	local tweenSpeed = 8

if EntityConfig.DependsOnSpeed then
	local speed = EntityConfig.MoveSpeed or 40
	tweenSpeed = math.max(speed / 5, 1)
end

DeafImage.ImageTransparency +=
	(1 - DeafImage.ImageTransparency)
	* math.clamp(dt * tweenSpeed, 0, 1)
	
	return
end

local alpha = 1 - (dist / MaxDistance)
local target = 1 - alpha * (1 - FrameTransparency)

local tweenSpeed = 8

if EntityConfig.DependsOnSpeed then
	local speed = EntityConfig.MoveSpeed or 40
	tweenSpeed = math.max(speed / 5, 1)
end

local finalPass = (not EntityConfig.Rebounding) or isFinalRebound

if finalPass then
	-- Chỉ cho giảm transparency, ko tăng lại
	if DeafImage.ImageTransparency > target then
		DeafImage.ImageTransparency +=
			(target - DeafImage.ImageTransparency)
			* math.clamp(dt * tweenSpeed, 0, 1)
	end
else
	-- Rebound bình thường thì tăng/giảm như cũ
	DeafImage.ImageTransparency +=
		(target - DeafImage.ImageTransparency)
		* math.clamp(dt * tweenSpeed, 0, 1)
end

end)

end

local function DestroyDeafModeFrame()
	if DeafConnection then
		DeafConnection:Disconnect()
		DeafConnection = nil
	end

	if DeafGui then
		DeafGui:Destroy()
		DeafGui = nil
	end

	DeafImage = nil
end

local function getOrCreateBlackoutGui()  
local gui = PlayerGui:FindFirstChild("PressureBlackoutGui")  
if not gui then  
gui = Instance.new("ScreenGui")  
gui.Name = "PressureBlackoutGui"  
gui.IgnoreGuiInset = true  
gui.ResetOnSpawn = false  
gui.Parent = PlayerGui  
  
local frame = Instance.new("Frame")      
    frame.Name = "BlackFrame"      
    frame.Size = UDim2.new(1, 0, 1, 0)      
    frame.BackgroundColor3 = Color3.new(0, 0, 0)      
    frame.BorderSizePixel = 0      
    frame.BackgroundTransparency = 1      
    frame.Parent = gui      
end      
return gui:FindFirstChild("BlackFrame")  
  
end  
  
local function initializeBypassedShaker()  
local playerCamera = workspace.CurrentCamera  
if not playerCamera then return nil end  
  
local currentCFrame = playerCamera.CFrame      
  
local function cameraCallback(shakeCFrame)      
    playerCamera.CFrame = currentCFrame * shakeCFrame      
end      
  
local renderPriority = Enum.RenderPriority.Camera.Value + 1      
      
local shakerInstance = {      
    ["_running"] = false,      
    ["_renderName"] = "BypassedCameraShaker",      
    ["_renderPriority"] = renderPriority,      
    ["_camShakeInstances"] = {},      
    ["_removeInstances"] = {},      
    ["_callback"] = cameraCallback      
}      
  
RunService:BindToRenderStep(shakerInstance._renderName, shakerInstance._renderPriority, function(deltaTime)      
    currentCFrame = playerCamera.CFrame      
          
    local posAccumulator = Vector3.new()      
    local rotAccumulator = Vector3.new()      
    
    local instances = shakerInstance._camShakeInstances      
          
    for i = 1, #instances do      
        local inst = instances[i]      
        if inst.currentFadeTime <= 0 and not inst.sustain then      
            shakerInstance._removeInstances[#shakerInstance._removeInstances + 1] = i      
        else      
            local deltaTick = inst.tick      
            local fadeTime = inst.currentFadeTime      
            local noiseVal = Vector3.new(math.noise(deltaTick, 0) * 0.5, math.noise(0, deltaTick) * 0.5, math.noise(deltaTick, deltaTick) * 0.5)      
                  
            if inst.fadeInDuration > 0 and inst.sustain then      
                if fadeTime < 1 then      
                    fadeTime = fadeTime + deltaTime / inst.fadeInDuration      
                end      
            end      
            if not inst.sustain then      
                fadeTime = fadeTime - deltaTime / inst.fadeOutDuration      
            end      
           
            if inst.sustain then      
                inst.tick = deltaTick + deltaTime * inst.Roughness * inst.roughMod      
            else      
                inst.tick = deltaTick + deltaTime * inst.Roughness * inst.roughMod * fadeTime      
            end      
            inst.currentFadeTime = math.clamp(fadeTime, 0, 1)      
                  
            local shakeVector = noiseVal * inst.Magnitude * inst.magnMod * fadeTime      
            posAccumulator = posAccumulator + shakeVector * inst.PositionInfluence      
            rotAccumulator = rotAccumulator + shakeVector * inst.RotationInfluence      
        end      
    end      
          
    for i = #shakerInstance._removeInstances, 1, -1 do      
        table.remove(instances, shakerInstance._removeInstances[i])      
        shakerInstance._removeInstances[i] = nil      
    end      
          
    local finalCFrame = CFrame.new(posAccumulator) * CFrame.Angles(0, math.rad(rotAccumulator.Y), 0) * CFrame.Angles(math.rad(rotAccumulator.X), 0, math.rad(rotAccumulator.Z))      
    shakerInstance._callback(finalCFrame)      
end)      
  
shakerInstance._running = true      
return shakerInstance  
  
end  
  
local function GitAud(soundgit, filename)  
local url = soundgit  
local FileName = filename  
-- Lưu ý: writefile yêu cầu môi trường exploit hỗ trợ (như Synapse/Script-Ware/...)  
if writefile then  
writefile(FileName..".mp3", game:HttpGet(url))  
return (getcustomasset or getsynasset)(FileName..".mp3")  
end  
return nil  
end  
  
local function playCustomGitSound()  
-- KIỂM TRA ĐIỀU KIỆN: Chỉ tiếp tục nếu PlayGitSoundWhenSpawned là true  
if not EntityConfig.PlayGitSoundWhenSpawned then return end  
  
-- Kiểm tra link hợp lệ    
if EntityConfig.GithubSound == "" then     
    warn("[EntitySystem] GithubSound chưa được thiết lập!")    
    return     
end    
    
task.spawn(function()    
    local asset = GitAud(EntityConfig.GithubSound, "EntityArrivalSound")    
    if asset then    
        local sound = Instance.new("Sound")    
        sound.SoundId = asset    
        sound.Parent = Workspace    
        sound.Name = "ArrivalSound"    
        sound.Volume = EntityConfig.SoundVolume    
        sound.PlaybackSpeed = EntityConfig.SoundPlaybackSpeed    
        sound:Play()    
            
        -- Tự xóa sau khi phát xong để dọn dẹp bộ nhớ    
        sound.Ended:Connect(function()    
            sound:Destroy()    
        end)    
    end    
end)  
  
end  
  
local activeShaker = initializeBypassedShaker()  
  
local function getObjects(src)  
	if typeof(src) == "Instance" then  
		return {src:Clone()}  
	end  
  
	if typeof(src) ~= "string" then  
		error("AssetId phải là String hoặc Instance.")  
	end  
  
	local lower = src:lower()  
  
	if lower:match("^rbxassetid://") then  
		local ok, objs = pcall(game.GetObjects, game, src)  
		if ok and objs and #objs > 0 then  
			return objs  
		end  
  
		error("Không load được asset Roblox.")  
	end  
  
	if lower:match("^https?://") then  
		local ok, data = pcall(game.HttpGet, game, src)  
  
		if not ok then  
			error(tostring(data))  
		end  
  
		local ok2, objs = pcall(function()  
			return SerializationService:DeserializeInstancesAsync(buffer.fromstring(data))  
		end)  
  
		if ok2 and objs and #objs > 0 then  
			return objs  
		end  
  
		error("File không phải .rbxm hoặc .rbxmx hợp lệ.")  
	end  
  
	error("AssetId không được hỗ trợ.")  
end  
  
-- =====================================================================  
-- LOAD & ENTITY SETUP  
-- =====================================================================  
  
local function loadEntityModel()  
if typeof(EntityConfig.AssetId) == "Instance" then  
	local obj = EntityConfig.AssetId:Clone()  
  
	obj.Name = EntityConfig.EntityName  
  
	if obj:IsA("BasePart") then  
		local mdl = Instance.new("Model")  
		obj.Parent = mdl  
		mdl.PrimaryPart = obj  
		mdl.Name = EntityConfig.EntityName  
		mdl.Parent = workspace  
		return mdl  
	end  
  
	if obj:IsA("Model") then  
		if not obj.PrimaryPart then  
			local part = obj:FindFirstChildWhichIsA("BasePart", true)  
  
			if part then  
				obj.PrimaryPart = part  
			else  
				local root = Instance.new("Part")  
				root.Name = "EntityRoot"  
				root.Size = Vector3.new(1,1,1)  
				root.Transparency = 1  
				root.Anchored = true  
				root.CanCollide = false  
				root.CanTouch = false  
				root.CanQuery = false  
				root.Parent = obj  
  
				obj.PrimaryPart = root  
			end  
		end  
  
		obj.Parent = workspace  
		return obj  
	end  
  
	error("AssetId Instance phải là Model hoặc BasePart.")  
end  
  
local success, objects = pcall(function()  
	return getObjects(EntityConfig.AssetId)  
end)  
  
if not success then    
	error("Không load được asset: " .. tostring(objects))    
end    
  
if #objects == 0 then    
	error("Asset không trả về object nào")    
end    
  
local obj = objects[1]    
  
if obj:IsA("BasePart") then    
	local model = Instance.new("Model")    
	model.Name = EntityConfig.EntityName    
  
	obj.Parent = model    
	model.PrimaryPart = obj    
	model.Parent = workspace    
  
	return model    
end    
  
if obj:IsA("Model") then    
	obj.Name = EntityConfig.EntityName    
	obj.Parent = workspace    
  
if not obj.PrimaryPart then    
local firstPart = obj:FindFirstChildWhichIsA("BasePart", true)    
  
if firstPart then    
	obj.PrimaryPart = firstPart    
else    
	local root = Instance.new("Part")    
	root.Name = "EntityRoot"    
	root.Size = Vector3.new(1, 1, 1)    
	root.Transparency = 1    
	root.CanCollide = false    
	root.CanTouch = false    
	root.CanQuery = false    
	root.Anchored = true    
	root.Parent = obj    
  
	obj.PrimaryPart = root    
end  
  
end  
  
return obj    
end    
  
error("[EntitySystem] Asset phải là Model hoặc BasePart!")  
  
end  
 
local LifeTimeTask = nil  
local LifeTimeExpired = false  
local proximityConnection = nil  
local flickerConnection = nil  
local hitboxConnection = nil  
  
-- Forward declaration  
local despawnEntity  
  
-- =====================================================================  
-- KILL / JUMPSCARE EXECUTION (FIXED: CHỈ DÙNG DAMAGEAMOUNT & CHỐNG SPAM)  
-- =====================================================================  
local isJumpscareRunning = false  
  
local function executeJumpscare()  
-- Quản lý trạng thái khóa cho Jumpscare đơn lần  
if not EntityConfig.ConstantBloodSucking then  
if isJumpscareRunning then return end  
isJumpscareRunning = true  
end  
  
local damageRemote = ReplicatedStorage:FindFirstChild("LocalDamage", true) or ReplicatedStorage:FindFirstChild("ChangeHealth", true)    
    
if damageRemote and damageRemote:IsA("RemoteEvent") then    
    -- 1. Lấy máu hiện tại    
    local mainGui = PlayerGui:WaitForChild("Main", 5)    
    local healthLabel = mainGui and mainGui:WaitForChild("Health", 5) and mainGui.Health:WaitForChild("TextLabel", 5)    
    local healthText = (healthLabel and healthLabel:IsA("TextLabel")) and healthLabel.Text or "100"    
    local cleanText = string.gsub(healthText, "[^%d]", "")    
    local currentHealth = tonumber(cleanText) or 100    
        
    -- 2. Tính toán sát thương    
    local finalDamage = (EntityConfig.InstantKill) and currentHealth or EntityConfig.DamageAmount    
        
    -- 3. Gây sát thương nhẹ (nếu chưa chết)    
    FireCallback(EntityConfig.OnDamagePlayer)
        
    -- 4. Kiểm tra kết quả    
    if (currentHealth - finalDamage) <= 0 then    
        -- MỚI: Thực thi OnKillPlayer và đợi nó hoàn thành trước khi đi tiếp    
        local success, err = pcall(function()    
            FireCallback(EntityConfig.OnKillPlayer)
        end)    
        if not success then     
            warn("[EntitySystem] Lỗi trong hàm OnKillPlayer: " .. tostring(err))     
        end    
        
        if EntityConfig.InstantKill or (currentHealth - finalDamage) <= 0 then
	DestroyDeafModeFrame()
end
            
        -- Sau khi OnKillPlayer đã chạy xong, mới thực hiện lệnh giết người    
        damageRemote:FireServer(finalDamage, "SittingItOut", 1, nil)    
        damageRemote:FireServer("Damage", finalDamage)    
            
        -- Xử lý UI Death    
        pcall(function()    
            task.spawn(function()    
            while true do    
            task.wait(0.5)    
                local playerGui = game.Players.LocalPlayer.PlayerGui    
local entityPage = playerGui.Main.AfterDeath.Document.EntityPage    
local imgLabel = entityPage.DeathFrame.Entities.Button.ImageLabel    
    
-- Kiểm tra nếu không có ảnh    
if EntityConfig.DeathImage == "" or EntityConfig.DeathImage == "rbxassetid://0" then    
    imgLabel.BackgroundTransparency = 1    
else    
    imgLabel.Image = EntityConfig.DeathImage    
        
    -- CẬP NHẬT MÀU MỚI TẠI ĐÂY    
    imgLabel.ImageColor3 = EntityConfig.DeathImageColor    
end    
    
entityPage.DeathFrame.EntityName.Text = EntityConfig.DeathName    
playerGui.Main.AfterDeath.Document.ScorePage.OverseerNotes.Text = EntityConfig.DeathNotes    
                end    
            end)    
        end)    
            
        -- Hủy model thực thể    
        if entityModel then entityModel:Destroy() end    
    else    
        -- Sát thương thường    
        damageRemote:FireServer(finalDamage, "SittingItOut", 1, nil)    
        damageRemote:FireServer("Damage", finalDamage)    
            
        if not EntityConfig.ConstantBloodSucking then    
            task.wait(2)    
            isJumpscareRunning = false    
        end    
    end    
else    
    warn("[ENTITY ERROR] Không tìm thấy RemoteEvent sát thương")    
    if not EntityConfig.ConstantBloodSucking then    
        isJumpscareRunning = false    
    end    
end  
  
end  
  
-- =====================================================================  
-- PROXIMITY SYSTEM (CỰC LY RUNG & CHỚP ĐÈN DƯỚI 30 STUDS)  
-- =====================================================================  
local isShaking = false  
local isBlackoutActive = false  
  
local function mapValue(val, inMin, inMax, outMin, outMax)  
local clamped = math.clamp(val, inMin, inMax)  
return outMin + (clamped - inMin) / (inMax - inMin) * (outMax - outMin)  
end  
  
proximityConnection = RunService.RenderStepped:Connect(function()  
if not entityReady then return end  
  
if entityFinished then  
if proximityConnection then  
proximityConnection:Disconnect()  
proximityConnection = nil  
end  
return  
end  
  
if not rootPart or not rootPart.Parent then    
    if despawnEntity then    
        despawnEntity()    
    end    
    return    
end    
    
local character = Player.Character    
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")    
    
if rootPart and humanoidRootPart then    
    local distance = (humanoidRootPart.Position - rootPart.Position).Magnitude    
        
    if distance <= EntityConfig.ShakeRadius then    
        local blackFrame = getOrCreateBlackoutGui()    
            
        local dynamicMagnitude = mapValue(distance, 0, EntityConfig.ShakeRadius, 3.5, 0.1)    
        local dynamicRoughness = mapValue(distance, 0, EntityConfig.ShakeRadius, 25, 5)    
  
        if EntityConfig.EnableShake then    
            if not isShaking and activeShaker then    
                isShaking = true    
                activeShaker._camShakeInstances = {}    
                    
                local newInstance = {      
                    ["Magnitude"] = dynamicMagnitude,      
                    ["Roughness"] = dynamicRoughness,      
                    ["PositionInfluence"] = Vector3.new(0.25, 0.25, 0.25),      
                    ["RotationInfluence"] = Vector3.new(1.25, 0, 4),      
                    ["roughMod"] = EntityConfig.ShakeSpeedMultiplier,      
                    ["magnMod"] = EntityConfig.ShakeIntensity,      
                    ["fadeOutDuration"] = 0.5,      
                    ["fadeInDuration"] = 0.1,      
                    ["sustain"] = true,      
                    ["currentFadeTime"] = 1,      
                    ["tick"] = Random.new():NextNumber(-100, 100)      
                }      
                table.insert(activeShaker._camShakeInstances, newInstance)    
            else    
                if activeShaker then    
                    for _, inst in ipairs(activeShaker._camShakeInstances) do    
                        inst.Magnitude = dynamicMagnitude    
                        inst.Roughness = dynamicRoughness    
                    end    
                end    
            end    
        end    
  
        if EntityConfig.EnableBlackout then    
            if not isBlackoutActive then    
                isBlackoutActive = true    
                if blackFrame and not flickerConnection then    
                    flickerConnection = RunService.RenderStepped:Connect(function()      
                        local wave = math.sin(os.clock() * EntityConfig.FlickerSpeed)      
                        local weight = (wave + 1) / 2      
                        blackFrame.BackgroundTransparency = 1 - (weight * EntityConfig.MaxDarkness)      
                    end)      
                end    
            end    
        else    
            if isBlackoutActive then    
                isBlackoutActive = false    
                if flickerConnection then    
                    flickerConnection:Disconnect()    
                    flickerConnection = nil    
                end    
                if blackFrame then    
                    blackFrame.BackgroundTransparency = 1    
                end    
            end    
        end    
    else    
        if isShaking or isBlackoutActive then    
            isShaking = false    
            isBlackoutActive = false    
            if activeShaker then    
                activeShaker._camShakeInstances = {}     
            end    
                
            if flickerConnection then    
                flickerConnection:Disconnect()    
                flickerConnection = nil    
            end    
                
            local blackFrame = PlayerGui:FindFirstChild("PressureBlackoutGui") and PlayerGui.PressureBlackoutGui:FindFirstChild("BlackFrame")    
            if blackFrame then    
                blackFrame.BackgroundTransparency = 1    
            end    
        end    
    end    
end  
  
end)  
  
local HitboxDisabled = false  
  
local function updateHitboxState()  
    local char = Player.Character  
    local hrp = char and char:FindFirstChild("HumanoidRootPart")  
    local hum = char and char:FindFirstChildOfClass("Humanoid")  
  
    HitboxDisabled = hrp and hum and hrp.Anchored and hum.WalkSpeed == 0 or false  
end  
  
RunService.Heartbeat:Connect(updateHitboxState)  
  
-- =====================================================================  
-- HITBOX SYSTEM (FIXED: HỖ TRỢ XUYÊN TƯỜNG)  
-- =====================================================================  
local isSuckingBlood = false  
  
hitboxConnection = RunService.Heartbeat:Connect(function()
if not entityReady or not hitboxActive then return end
  
if isReboundingPaused or entityFinished or not rootPart or not rootPart.Parent then return end  
  
local character = Player.Character    
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")    
    
if humanoidRootPart then    
    local direction = humanoidRootPart.Position - rootPart.Position    
    local distance = direction.Magnitude    
        
    if distance <= EntityConfig.HitboxRadius then    
        -- 1. KIỂM TRA TỦ (Logic mới: IgnoreHiding = true thì Tôn trọng tủ/An toàn)    
        if HitboxDisabled and EntityConfig.IgnoreHiding then  
    return  
end  
            
        -- 2. Kiểm tra xuyên tường (WallPenetrating) hoặc Raycast    
        local canHit = false    
        if EntityConfig.WallPenetrating then    
            canHit = true    
        else    
            local params = RaycastParams.new()    
            params.FilterType = Enum.RaycastFilterType.Exclude    
            params.FilterDescendantsInstances = {entityModel, character}    
            params.IgnoreWater = true    
                
            local raycastResult = Workspace:Raycast(rootPart.Position, direction, params)    
            if not raycastResult then canHit = true end    
        end    
            
        -- 3. Thực thi   
        if canHit then     
            if EntityConfig.ConstantBloodSucking then    
                if not isSuckingBlood then    
                    isSuckingBlood = true    
                    task.spawn(function()    
                        while true do    
                            local char = Player.Character    
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")    
                                
                            -- Điều kiện dừng hút máu    
                            if not hrp or (hrp.Position - rootPart.Position).Magnitude > EntityConfig.HitboxRadius then    
                                break    
                            end    
                                
                            -- Kiểm tra lại tủ trong lúc hút máu (Tôn trọng tủ nếu IgnoreHiding là true)    
                            local stillSafe = HitboxDisabled and EntityConfig.IgnoreHiding  
if stillSafe then  
    break  
end  
  
                            executeJumpscare()    
                            task.wait(EntityConfig.DelayEachDamage)    
                        end    
                        isSuckingBlood = false    
                    end)    
                end    
            else    
                executeJumpscare()    
            end   
        end    
    end    
end  
  
end)  
  
local function getSignalConnections(signal)  
if getconnections then return getconnections(signal) end  
if get_signal_cons then return get_signal_cons(signal) end  
  
for _, funcName in ipairs({"GetConnections", "getconnections"}) do      
    local success, result = pcall(function() return signal[funcName](signal) end)      
    if success then return result end      
end      
return nil  
  
end  
  
local function fireFlickerEvent(connections, lightParts)  
for _, lightPart in ipairs(lightParts) do  
local randomDuration = math.random(2, 12)  
for _, connection in ipairs(connections) do  
if connection.Function then  
task.spawn(connection.Function, "NeonFlicker", lightPart, randomDuration)  
end  
end  
end  
end  
  
local function triggerDoubleFlicker()  
-- Kiểm tra nếu không bật hiệu ứng flicker thì thoát  
if not EntityConfig.EnableFlicker then return end  
  
local connections = getSignalConnections(URSpecialEffects.OnClientEvent)    
if not connections or #connections == 0 then return end    
  
-- Hàm cục bộ quét tất cả các đèn hợp lệ trong Workspace    
local function getValidLights()    
    local lights = {}    
    for _, descendant in ipairs(Workspace:GetDescendants()) do      
        if descendant.Name == "Lights" and descendant:IsA("Instance") then      
            for _, lightPart in ipairs(descendant:GetChildren()) do      
                local name = lightPart.Name      
                if name ~= "OceanNeon"  
and name ~= "Delete"  
and name ~= "RidgeNeon"  
and not lightPart:GetAttribute("TricksterSign")  
and not lightPart:GetAttribute("Broken")  
and not (lightPart.Parent and lightPart.Parent:GetAttribute("Broken")) then  
	table.insert(lights, lightPart)  
end  
            end      
        end      
    end    
    return lights    
end    
  
-- Chạy hiệu ứng trong thread riêng    
task.spawn(function()    
    local startTime = os.clock()    
        
    while not entityFinished do    
        -- Kiểm tra điều kiện thoát dựa trên cấu hình thời gian    
        if not EntityConfig.LightFlickersUntilDespawn then    
            if (os.clock() - startTime) >= EntityConfig.LightFlickerTime then    
                break    
            end    
        end    
            
        -- Lấy danh sách đèn mới nhất (bao gồm đèn ở phòng mới spawn)    
        local currentLights = getValidLights()    
            
        -- Kích hoạt hiệu ứng chớp đèn    
        if #currentLights > 0 then    
            fireFlickerEvent(connections, currentLights)    
        end    
            
        task.wait(0.2)     
    end    
end)  
  
end  
  
-- =====================================================================  
-- MOVEMENT & NODE LOGIC (DI CHUYỂN QUA CÁC NODE)  
-- =====================================================================  
despawnEntity = function()  
if entityFinished then return end  
entityFinished = true  
  
LifeTimeExpired = true    
    
-- 1. Reset tất cả các biến trạng thái về mặc định    
-- Điều này cực kỳ quan trọng nếu thực thể được spawn lại    
isReboundingPaused = false    
canRebound = false    
reboundLock = false    
isSuckingBlood = false     
isJumpscareRunning = false -- Reset để không chặn Jumpscare của thực thể mới    
ReboundStopExit = nil
hitboxActive = false
    
-- 2. Dọn sạch các Render/Heartbeat Connections    
if flickerConnection then     
    flickerConnection:Disconnect()     
    flickerConnection = nil     
end    
if DeafConnection then
    DeafConnection:Disconnect()
    DeafConnection = nil
end
if hitboxConnection then     
    hitboxConnection:Disconnect()     
    hitboxConnection = nil     
end    
if proximityConnection then     
    proximityConnection:Disconnect()     
    proximityConnection = nil     
end    
if roomAddedConnection then    
roomAddedConnection:Disconnect()    
roomAddedConnection = nil  
  
end  
if roomRemovedConnection then  
roomRemovedConnection:Disconnect()  
roomRemovedConnection = nil  
end  
  
-- 3. Xử lý Shake System    
if activeShaker then    
    activeShaker._camShakeInstances = {}    
end    
  
-- 4. Dọn sạch UI hiệu ứng    
local blackoutGui = PlayerGui:FindFirstChild("PressureBlackoutGui")    
if blackoutGui then    
    local blackFrame = blackoutGui:FindFirstChild("BlackFrame")    
    if blackFrame then    
        blackFrame.BackgroundTransparency = 1    
    end    
end    
  
local tween = TweenService:Create(    
rootPart,    
TweenInfo.new(5, Enum.EasingStyle.Linear),    
{    
    CFrame = rootPart.CFrame - EntityConfig.DespawnYOffset    
}  
  
)  
  
-- Fade out tất cả Sound trong entity khi bắt đầu despawn  
for _, obj in ipairs(entityModel:GetDescendants()) do  
if obj:IsA("Sound") then  
TweenService:Create(  
obj,  
TweenInfo.new(5, Enum.EasingStyle.Linear),  
{  
Volume = 0  
}  
):Play()  
end  
end  
  
tween:Play()  
tween.Completed:Wait()  
  
if entityModel then  
if DeafConnection then
	DeafConnection:Disconnect()
	DeafConnection = nil
end

if DeafImage then

	local tween = TweenService:Create(
		DeafImage,
		TweenInfo.new(3,Enum.EasingStyle.Linear),
		{
			ImageTransparency = 1
		}
	)

	tween:Play()

	task.delay(3,function()

		if DeafGui then
			DeafGui:Destroy()
			DeafGui = nil
			DeafImage = nil
		end

	end)

end

entityModel:Destroy()  
end  
  
FireCallback(EntityConfig.OnDespawned)
  
end  
  
local function extractPathNodes(nodesFolder)  
local entrance = nodesFolder:FindFirstChild("Entrance")  
if not entrance then return {} end  
  
local path = {}      
local current = entrance      
  
while current do      
    table.insert(path, current)      
    local connections = current:FindFirstChild("Connections")      
    local nextValue = connections and connections:FindFirstChild("Next")  
  
if nextValue and nextValue:IsA("ObjectValue") then  
local nextNode = nextValue.Value  
  
while nextNode and nextNode.Name == "Exit" do    
    -- Nếu node này từng bị blacklist thì skip luôn    
    if BlacklistedExitNodes[nextNode] then    
        local exitConnections = nextNode:FindFirstChild("Connections")    
        local exitNext = exitConnections and exitConnections:FindFirstChild("Next")    
        nextNode = exitNext and exitNext.Value or nil    
        continue    
    end    
  
    local exitConnections = nextNode:FindFirstChild("Connections")
local isRealExit = false

local value = nextNode:FindFirstChild("Value")
if value and value:IsA("ObjectValue") then
	local target = value.Value

	if target
	and target.Parent
	and target.Parent.Name == "Exits" then
		isRealExit = true
	end
end

if not isRealExit then
	local previous = exitConnections and exitConnections:FindFirstChild("Previous")

	if previous
	and previous:IsA("ObjectValue")
	and previous.Value
	and previous.Value.Name == "Entrance" then
		isRealExit = true
	end
end

if isRealExit then
	break
end

BlacklistedExitNodes[nextNode] = true

local exitNext = exitConnections and exitConnections:FindFirstChild("Next")
nextNode = exitNext and exitNext.Value or nil
end    
  
current = nextNode  
  
else  
current = nil  
end  
end  
  
for _, ex in ipairs(nodesFolder:GetChildren()) do    
if ex.Name == "Exit"    
and not BlacklistedExitNodes[ex]    
and not table.find(path, ex) then    
  
    local v = ex:FindFirstChild("Value")    
  
    if v and tonumber(v.Value) ~= nil then    
        table.insert(path, ex)    
    end    
end  
  
end  
  
return path  
  
end  
  
local function cacheRoomNodes(room)  
cachedRoom = room  
cachedRoomNodes = {}  
  
if not room then    
    return    
end    
  
local nodesFolder = room:FindFirstChild("EntityNodes", true)    
if not nodesFolder then    
    return    
end    
  
local path = extractPathNodes(nodesFolder)    
  
if EntityConfig.Reversed then    
    for i = #path, 1, -1 do    
        table.insert(cachedRoomNodes, path[i])    
    end    
else    
    for _, node in ipairs(path) do    
        table.insert(cachedRoomNodes, node)    
    end    
end  
  
end  
  
-- Biến này để chặn hitbox khi đang delay  
  
local logs = {}  
  
local function log(...)  
local t = {}  
for i = 1, select("#", ...) do  
t[#t + 1] = tostring(select(i, ...))  
end  
table.insert(logs, table.concat(t, " "))  
end  
  
local function copyLogs()  
local text = table.concat(logs, "\n")  
print(text)  
if setclipboard then  
setclipboard(text)  
end  
end  
  
local currentPath = {}  
local currentNode = nil  
local SpawnRoom = nil  
local ReboundStopExit = nil
local SpawnRoomName = nil  
local cachedRoomNodes = {}  
local cachedRoom = nil  
local currentIndex = 1  
local currentDirection = 1  
local roomAddedConnection  
local roomRemovedConnection  

local function getPreviousConnectedNode(targetNode)
	for _, room in ipairs(Rooms:GetChildren()) do
		local nodesFolder = room:FindFirstChild("EntityNodes", true)

		if nodesFolder then
			for _, node in ipairs(nodesFolder:GetDescendants()) do
				local connections = node:FindFirstChild("Connections")
				local nextValue = connections and connections:FindFirstChild("Next")

				if nextValue and nextValue.Value == targetNode then
					return node
				end
			end
		end
	end
end
  
local function traverseNodes(nodesFolder)  
currentPath = (typeof(nodesFolder) == "table") and nodesFolder or extractPathNodes(nodesFolder)  
  
if #currentPath == 0 then    
    return    
end    
    
local lastRoom = nil    
    
log("PATH SIZE:", #currentPath)    
  
-- 1. Tính toán số vòng rebound ngẫu nhiên    
totalRebounds = EntityConfig.Rebounding and math.random(EntityConfig.MinRebounds or 1, EntityConfig.MaxRebounds or 1) or 0    
if EntityConfig.Rebounding then print("Entity thực hiện: " .. totalRebounds .. " vòng rebound.") end    
    
-- 2. Khởi tạo hướng và index dựa trên chế độ Reversed    
local direction = 1    
local reboundsDone = 0  
  
-- 3. Spawn và Snap an toàn  
if not entityModel:GetAttribute("Spawned") then  
local startCFrame = currentPath[currentIndex].CFrame + EntityConfig.YOffset  
entityModel:PivotTo(startCFrame)  
entityModel:SetAttribute("Spawned", true)  
  
FireCallback(EntityConfig.OnSpawn)
    
task.spawn(playCustomGitSound)    
if EntityConfig.EnableFlicker then triggerDoubleFlicker() end    
    
-- Xử lý delay gameplay (Chỉ delay đúng số giây người dùng muốn)    
if EntityConfig.DelayWhenSpawned and EntityConfig.Delay > 0 then     
    task.wait(EntityConfig.Delay)     
end    
    
-- Ổn định vật lý (0.3 giây này là cố định, không liên quan tới Delay cài đặt)    
task.wait(0.3)     
canRebound = true  
  
end  
  
-- Bây giờ, dù có Delay hay không, sau khi xong các lệnh trên,  
-- code mới chạy đến đây. OnMoveStart sẽ không bị "lố" thời gian.  
FireCallback(EntityConfig.OnMoveStart)

hitboxActive = true 
  
while true do    
    if entityFinished then return end    
        
    log(    
    "Current:", currentIndex,    
    "Next:", currentIndex + direction,    
    "Direction:", direction,    
    "Rebounds:", reboundsDone,    
    "/",    
    totalRebounds    
)    
  
    local nextIndex = currentIndex + direction    
  
          -- 4. Logic chạm biên (Rebound)    
    if (nextIndex < 1 or nextIndex > #currentPath) then    
        if not EntityConfig.Rebounding then break end    
  
        -- Nếu đã đủ số vòng, thoát luôn    
        if reboundsDone >= totalRebounds then    
log("BREAK BECAUSE REBOUND LIMIT")    
log("Done:", reboundsDone, "Need:", totalRebounds)    
break  
  
end  
  
-- Chỉ tăng rebound khi chạm biên và chưa bị khóa    
        if canRebound and not reboundLock then
    reboundLock = true
    reboundsDone += 1

    if reboundsDone >= totalRebounds then
        isFinalRebound = true
        ReboundStopExit = nil
    end
    
    if isFinalRebound then
    local newPath = buildFullPath()

    if #newPath > 0 then
        currentPath = newPath

        for i, node in ipairs(currentPath) do
            if node == currentNode then
                currentIndex = i
                break
            end
        end
    end
end

            print(">>> Rebound thành công lần thứ:", reboundsDone, "/", totalRebounds)    
                
            -- Tạm dừng di chuyển trong thời gian delay rebound    
            isReboundingPaused = true    
            task.spawn(function()    
                task.wait(EntityConfig.DelayEachRebound or 1)    
                isReboundingPaused = false    
                reboundLock = false    
            end)    
        end    
            
        -- Đảo chiều & reset chỉ số index ngay lập tức    
        direction *= -1    
        nextIndex = currentIndex + direction    
    end            
  
    currentIndex = nextIndex    
    currentNode = currentPath[currentIndex]
local targetNode = currentPath[currentIndex]

if targetNode and targetNode.Name == "Entrance" then
	local exitNode = getPreviousConnectedNode(targetNode)

	if exitNode then
		targetNode = exitNode
		currentIndex = #currentPath
	end
end
  
    if targetNode then    
        local targetPos = targetNode.Position + EntityConfig.YOffset    
            
        -- Di chuyển tới node    
        while (rootPart.Position - targetPos).Magnitude > EntityConfig.Tolerance do    
            if entityFinished then return end    
            -- Nếu đang trong thời gian delay rebound, đứng yên    
            if isReboundingPaused then task.wait() continue end    
  
            local dt = task.wait()    
            local offset = targetPos - rootPart.Position    
            local moveDir = offset.Unit    
  
            -- Giới hạn khoảng cách di chuyển (chống bay)    
            local moveStep = math.min(EntityConfig.MoveSpeed * dt, offset.Magnitude)    
            entityModel:PivotTo(entityModel:GetPivot() + (moveDir * moveStep))    
        end    
            
        if targetNode.Name == "Exit" then
	for _, node in ipairs(currentPath) do
		if node.Name == "Exit" and node ~= targetNode then
			local isRealExit = false

			local value = node:FindFirstChild("Value")
			if value and value:IsA("ObjectValue") then
				local target = value.Value

				if target
				and target.Parent
				and target.Parent.Name == "Exits" then
					isRealExit = true
				end
			end

			if not isRealExit then
				local connections = node:FindFirstChild("Connections")
				local previous = connections and connections:FindFirstChild("Previous")

				if previous
				and previous:IsA("ObjectValue")
				and previous.Value
				and previous.Value.Name == "Entrance" then
					isRealExit = true
				end
			end

			if not isRealExit then
				BlacklistedExitNodes[node] = true
			end
		end
	end
end
  
local room = targetNode:FindFirstAncestorWhichIsA("Model")  
  
if room and room ~= lastRoom then  
lastRoom = room  
  
cacheRoomNodes(room)    
  
FireCallback(EntityConfig.OnRoomEnter, room.Name)
  
end  
end  
end  
  
log("WHILE ENDED")  
  
FireCallback(EntityConfig.OnDespawning)
despawnEntity()  
end  
  
-- =====================================================================  
-- ROOM MANAGEMENT & EXECUTION  
-- =====================================================================  
local function getOrderedRooms()  
local allRooms = Rooms:GetChildren()  
local startRoom = Rooms:FindFirstChild("Start") or allRooms[1]  
  
local startIndex = 1      
for i, room in ipairs(allRooms) do      
    if room == startRoom then      
        startIndex = i      
        break      
    end      
end      
  
local orderedList = {}      
if startIndex > 1 and allRooms[startIndex - 1]:IsA("Model") then      
    table.insert(orderedList, allRooms[startIndex - 1])      
end      
  
for i = startIndex, #allRooms do      
    if allRooms[i]:IsA("Model") then      
        table.insert(orderedList, allRooms[i])      
    end      
end      
    
if EntityConfig.Reversed then    
    local reversedList = {}    
    for i = #orderedList, 1, -1 do    
        table.insert(reversedList, orderedList[i])    
    end    
    return reversedList    
end    
  
return orderedList  
  
end  

local function getReboundStopExit()
	if not EntityConfig.Rebounding then
		return nil
	end

	if EntityConfig.Reversed then
		return nil
	end
	
	if isFinalRebound then
	return nil
end

	local roomsList = getOrderedRooms()

	if #roomsList < 2 then
		return nil
	end

	local stopRoom

	if EntityConfig.Reversed then
		stopRoom = roomsList[2]
	else
		stopRoom = roomsList[#roomsList - 1]
	end

	if not stopRoom then
		return nil
	end

	local nodesFolder = stopRoom:FindFirstChild("EntityNodes", true)

	if not nodesFolder then
		return nil
	end

	local path = extractPathNodes(nodesFolder)

	if EntityConfig.Reversed then
		for _, node in ipairs(path) do
			if node.Name == "Exit" then
				return node
			end
		end
	else
		for i = #path, 1, -1 do
			if path[i].Name == "Exit" then
				return path[i]
			end
		end
	end
end
  
buildFullPath = function()  
local roomsList = getOrderedRooms()  
  
if EntityConfig.RoomLimits and SpawnRoom then  
local startIndex  
  
for i, room in ipairs(roomsList) do    
	if room == SpawnRoom or room.Name == SpawnRoomName then    
		startIndex = i    
		break    
	end    
end    
  
if startIndex then    
	local limited = {}    
  
	if EntityConfig.Reversed then    
		local finish = math.max(1, startIndex - EntityConfig.RoomLimitValue)    
  
		for i = startIndex, finish, -1 do    
			table.insert(limited, roomsList[i])    
		end    
	else    
		local finish = math.min(#roomsList, startIndex + EntityConfig.RoomLimitValue)    
  
		for i = startIndex, finish do    
			table.insert(limited, roomsList[i])    
		end    
	end    
  
	roomsList = limited    
end  
  
end  
  
if EntityConfig.RoomLimits then    
local limitedRooms = {}    
  
for i = 1, math.min(#roomsList, EntityConfig.RoomLimitValue + 1) do    
	table.insert(limitedRooms, roomsList[i])    
end    
  
roomsList = limitedRooms  
  
end  
  
local fullPath = {}    
  
for _, room in ipairs(roomsList) do    
    local nodesFolder = room:FindFirstChild("EntityNodes", true)    
    if nodesFolder then    
        local roomPath = extractPathNodes(nodesFolder)    
  
        if EntityConfig.Reversed then    
            for i = #roomPath, 1, -1 do    
                table.insert(fullPath, roomPath[i])    
            end    
        else    
            for _, node in ipairs(roomPath) do    
                table.insert(fullPath, node)    
            end    
        end    
    end    
end    

if EntityConfig.Rebounding
and not EntityConfig.Reversed
and ReboundStopExit
and ReboundStopExit.Parent
and not isFinalRebound then
	local stopIndex

	for i, node in ipairs(fullPath) do
		if node == ReboundStopExit then
			stopIndex = i
			break
		end
	end

	if stopIndex then
		if EntityConfig.Reversed then
			for i = stopIndex - 1, 1, -1 do
				table.remove(fullPath, i)
			end
		else
			for i = #fullPath, stopIndex + 1, -1 do
				table.remove(fullPath, i)
			end
		end
	end
end
  
return fullPath  
  
end  
  
local function findClosestNode(path)  
if not rootPart then  
return 1  
end  
  
local closestIndex = 1    
local closestDistance = math.huge    
  
for i, node in ipairs(path) do    
    if node and node.Parent then    
        local dist = (rootPart.Position - node.Position).Magnitude    
  
        if dist < closestDistance then    
            closestDistance = dist    
            closestIndex = i    
        end    
    end    
end    
  
return closestIndex  
  
end  
  
local function refreshCurrentPath()  
if entityFinished then  
return  
end  

if EntityConfig.Rebounding then
    ReboundStopExit = getReboundStopExit()
end
  
local newPath = buildFullPath()    
  
if #newPath == 0 then    
    return    
end    
  
local foundIndex    
  
if currentNode and currentNode.Parent then    
    for i, node in ipairs(newPath) do    
        if node == currentNode then    
            foundIndex = i    
            break    
        end    
    end    
end    
  
if not foundIndex then    
if EntityConfig.RoomLimits then    
	foundIndex = math.clamp(currentIndex, 1, #newPath)    
else    
	foundIndex = findClosestNode(newPath)    
end  
  
end  
  
currentPath = newPath    
currentIndex = foundIndex    
currentNode = currentPath[currentIndex]  
  
end  
  
local function runEntityBehavior()  
-- Ngắt kết nối cũ nếu có để tránh chạy trùng lặp (Memory leak)  
if roomAddedConnection then  
roomAddedConnection:Disconnect()  
roomAddedConnection = nil  
end  
  
roomAddedConnection = Rooms.ChildAdded:Connect(function(room)  
  
if EntityConfig.RoomLimits then  
return  
end  
  
if room:IsA("Model") then    
        task.wait(0.5)    
        refreshCurrentPath()    
  
        -- TÍNH NĂNG MỚI: Tự động kích hoạt flicker cho phòng mới nếu cấu hình cho phép    
        if EntityConfig.EnableFlicker and EntityConfig.LightFlickersUntilDespawn then    
            local connections = getSignalConnections(URSpecialEffects.OnClientEvent)    
            if connections and #connections > 0 then    
                local roomLights = {}    
                -- Chỉ quét đèn trong phạm vi của phòng vừa spawn    
                for _, d in ipairs(room:GetDescendants()) do    
                    if d.Name == "Lights" and d:IsA("Folder") or d:IsA("Model") then    
                        for _, lp in ipairs(d:GetChildren()) do    
                            if lp:IsA("BasePart")  
and not lp:GetAttribute("Broken")  
and not (lp.Parent and lp.Parent:GetAttribute("Broken")) then  
	table.insert(roomLights, lp)  
end  
                        end    
                    end    
                end    
                    
                if #roomLights > 0 then    
                    fireFlickerEvent(connections, roomLights)    
                end    
            end    
        end    
    end    
end)    
    
if roomRemovedConnection then    
    roomRemovedConnection:Disconnect()    
    roomRemovedConnection = nil    
end    
  
roomRemovedConnection = Rooms.ChildRemoved:Connect(function(room)    
    if room == cachedRoom then    
        currentPath = cachedRoomNodes    
        currentIndex = 1    
        currentNode = currentPath[1]    
    else    
        task.wait(0.2)    
        refreshCurrentPath()    
    end    
end)    
    
local orderedRooms = getOrderedRooms()  
  
if EntityConfig.Reversed then  
SpawnRoom = orderedRooms[#orderedRooms]  
else  
SpawnRoom = orderedRooms[1]  
end  
  
if SpawnRoom then  
SpawnRoomName = SpawnRoom.Name  
end  
  
if type(EntityConfig.EntityLifeTime) == "number" then  
LifeTimeTask = task.delay(EntityConfig.EntityLifeTime, function()  
if entityFinished or LifeTimeExpired then  
return  
end  
  
LifeTimeExpired = true    
  
	if movementConnection then    
		movementConnection:Disconnect()    
		movementConnection = nil    
	end    
  
	if hitboxConnection then    
		hitboxConnection:Disconnect()    
		hitboxConnection = nil    
	end    
  
	if roomAddedConnection then    
		roomAddedConnection:Disconnect()    
		roomAddedConnection = nil    
	end    
  
	if roomRemovedConnection then    
		roomRemovedConnection:Disconnect()    
		roomRemovedConnection = nil    
	end    
  
	if currentTween then    
		currentTween:Cancel()    
		currentTween = nil    
	end    
  
	entityFinished = true    
  
	despawnEntity()    
end)  
  
end  
  
ReboundStopExit = getReboundStopExit()

traverseNodes(buildFullPath())
  
end  
  
-- =====================================================================  
-- LIGHT BREAKING SYSTEM (FULL INTEGRATION)  
-- =====================================================================  
local LightCache = {}  
local SignCache = {}  
  
local function playBreakSound(part)  
if not part then return end  
local sound = Instance.new("Sound")  
sound.SoundId = EntityConfig.LightSoundId
sound.Volume = EntityConfig.LightSoundVolume
sound.RollOffMaxDistance = EntityConfig.LightSoundDistance
sound.Parent = part  
sound:Play()  
sound.Ended:Connect(function() sound:Destroy() end)  
end  
  
local function createPressureSparkEffect(part)  
if not part then return end  
  
-- Core Spark    
local core = Instance.new("ParticleEmitter")    
core.Name = "SparkCore"    
core.Texture = EntityConfig.ParticleTexture    
core.Rate = 55    
core.Speed = NumberRange.new(0)    
core.Lifetime = NumberRange.new(10)    
core.Size = NumberSequence.new(1.5)    
core.RotSpeed = NumberRange.new(1500, 2500)    
core.Rotation = NumberRange.new(0, 360)    
core.Transparency = NumberSequence.new(0)    
core.LightEmission = 1    
core.LightInfluence = 0    
core.SpreadAngle = Vector2.new(360, 360)    
core.Parent = part    
  
-- Ring Spark    
local ring = Instance.new("ParticleEmitter")    
ring.Name = "SparkRing"    
ring.Texture = EntityConfig.ParticleTexture    
ring.Rate = 55    
ring.Speed = NumberRange.new(5, 10)    
ring.Lifetime = NumberRange.new(0.3)    
ring.Size = NumberSequence.new(1.2)    
ring.RotSpeed = NumberRange.new(3000, 4500)    
ring.Rotation = NumberRange.new(0, 360)    
ring.Transparency = NumberSequence.new(0)    
ring.LightEmission = 1    
ring.LightInfluence = 0    
ring.EmissionDirection = Enum.NormalId.Top    
ring.SpreadAngle = Vector2.new(360, 0)    
ring.Parent = part    
  
task.delay(EntityConfig.ParticleDuration, function()    
    if core then core:Destroy() end    
    if ring then ring:Destroy() end    
end)  
  
end  
  
local function checkAndCache(obj)  
if obj:IsA("BasePart") and obj.Name == "Sign" then  
table.insert(SignCache, obj)  
return  
end  
  
if obj:IsA("BasePart") then    
local path = obj:GetFullName()    
  
if path:find("%.Lights%.Neon")    
or path:find("%.Lights%.SmallNeon")    
or path:find("%.Lights%.Nec") then    
  
    table.insert(LightCache,{    
        NeonPart = obj,    
        RootModel = obj.Parent,    
        Broken = false    
    })    
end  
  
end  
end  
  
-- Khởi tạo Cache ban đầu  
for _, obj in ipairs(Workspace:GetDescendants()) do checkAndCache(obj) end  
Workspace.DescendantAdded:Connect(checkAndCache)  
  
-- Hàm quét và phá đèn dựa trên Entity Position  
local function scanAndExplodeFast()  
if not rootPart or not rootPart.Parent then return end  
local entityPosition = rootPart.Position  
  
-- Xử lý Sign    
for _, obj in ipairs(SignCache) do    
    if obj and obj.Parent then    
        if (obj.Position - entityPosition).Magnitude <= EntityConfig.LightBreakingRange then    
            for _, gui in ipairs(obj:GetChildren()) do    
                if gui:IsA("SurfaceGui") then    
                    for _, label in ipairs(gui:GetDescendants()) do    
                        if label:IsA("TextLabel") and not label:GetAttribute("Darkened") then    
                            label:SetAttribute("Darkened", true)    
                            local oc = label.TextColor3    
                            label.TextColor3 = Color3.new(oc.R * EntityConfig.DarkenPercent, oc.G * EntityConfig.DarkenPercent, oc.B * EntityConfig.DarkenPercent)    
                        end    
                    end    
                end    
            end    
        end    
    end    
end    
  
-- Xử lý Đèn    
for _, data in ipairs(LightCache) do    
    local neonPart = data.NeonPart    
    if neonPart and neonPart.Parent and not data.Broken then    
        if (neonPart.Position - entityPosition).Magnitude <= EntityConfig.LightBreakingRange then    
            data.Broken = true    
            neonPart:SetAttribute("Broken", true)  
  
local rootModel = data.RootModel

if rootModel then
    rootModel:SetAttribute("Broken", true)
end
  
if rootModel then  
playBreakSound(neonPart)  
createPressureSparkEffect(neonPart)  
  
for _, descendant in ipairs(rootModel:GetDescendants()) do    
    if descendant:IsA("BasePart") then    
        descendant.Material = Enum.Material.Glass    
    elseif descendant:IsA("Light") then    
        task.spawn(function()    
            local endTime = os.clock() + 0.2    
            while os.clock() < endTime do    
                descendant.Enabled = not descendant.Enabled    
                task.wait(math.random(1,6)/100)    
            end    
            descendant.Enabled = false    
        end)    
    end    
end  
  
end  
end  
end  
end  
end  
  
-- Vòng lặp chạy song song theo thực thể  
task.spawn(function()  
while not entityFinished do  
if EntityConfig.EnableBreakLights then  
scanAndExplodeFast()  
end  
task.wait(EntityConfig.AutoScanInterval)  
end  
end)  
  
return function(customConfig)  
	if customConfig then  
		for k, v in pairs(customConfig) do  
			if EntityConfig[k] ~= nil then  
				EntityConfig[k] = v  
			end  
		end  
		
		EntityConfig.LightBreakingRange =
    customConfig.LightBreakingRange
    or customConfig.LightBreakRange
    or EntityConfig.LightBreakingRange

EntityConfig.DarkenPercent =
    customConfig.DarkenPercent
    or customConfig.LightDarkenPercent
    or EntityConfig.DarkenPercent

EntityConfig.AutoScanInterval =
    customConfig.AutoScanInterval
    or customConfig.LightAutoScanInterval
    or EntityConfig.AutoScanInterval

EntityConfig.ParticleTexture =
    customConfig.ParticleTexture
    or customConfig.LightParticleTexture
    or EntityConfig.ParticleTexture

EntityConfig.ParticleDuration =
    customConfig.ParticleDuration
    or customConfig.LightParticleDuration
    or EntityConfig.ParticleDuration
    
    EntityConfig.LightSoundId =
    customConfig.LightSoundId
    or customConfig.BreakSoundId
    or EntityConfig.LightSoundId

EntityConfig.LightSoundVolume =
    customConfig.LightSoundVolume
    or EntityConfig.SoundVolume
    or EntityConfig.LightSoundVolume

EntityConfig.LightSoundDistance =
    customConfig.LightSoundDistance
    or customConfig.SoundDistance
    or EntityConfig.LightSoundDistance
	end  
  
	entityModel = loadEntityModel()

if not entityModel then
	error("entityModel nil")
end
  
	while not entityModel.PrimaryPart do  
		local part = entityModel:FindFirstChildWhichIsA("BasePart", true)  
  
		if part then  
			entityModel.PrimaryPart = part  
		else  
			local root = Instance.new("Part")  
			root.Name = "EntityRoot"  
			root.Size = Vector3.new(1, 1, 1)  
			root.Transparency = 1  
			root.Anchored = true  
			root.CanCollide = false  
			root.CanTouch = false  
			root.CanQuery = false  
			root.Parent = entityModel  
  
			entityModel.PrimaryPart = root  
		end  
	end  
  
	rootPart = entityModel.PrimaryPart  
  
	if not rootPart then  
		error("Không thể gán PrimaryPart cho entity.")  
	end  
	  
	repeat  
        task.wait()  
    until rootPart and rootPart.Parent  
      
    entityReady = true  
  
	task.spawn(runEntityBehavior)  
	task.spawn(CreateDeafModeFrame) 
end