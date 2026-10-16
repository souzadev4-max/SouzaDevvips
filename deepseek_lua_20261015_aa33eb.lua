-- ============================================================
-- VETERANO TEAM | SINTONIA RP V2 + COLETOR DE ARMAS
-- Versao SEM LOGIN
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local TC = Color3.fromRGB(170,70,255)
local TCD = Color3.fromRGB(90,40,140)
local BG = Color3.fromRGB(14,8,24)
local BG2 = Color3.fromRGB(22,14,34)
local BG3 = Color3.fromRGB(32,20,50)
local LINE = Color3.fromRGB(70,45,110)
local DIM = Color3.fromRGB(170,140,210)
local WH = Color3.fromRGB(240,230,255)
local YEL = Color3.fromRGB(255,200,50)
local STAFF_RED = Color3.fromRGB(255,20,40)

local C = (getgenv and getgenv()) or _G
cloneref = cloneref or function(v) return v end
gethui = gethui or get_hidden_gui
protect_gui = protect_gui or protectgui or (syn and syn.protect_gui)

local parentGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SINTONIA_VTMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
if protect_gui then pcall(protect_gui, screenGui) end
screenGui.Parent = parentGui

local P = 1500
local z = Enum.KeyCode.K
local F = "125299131646017"

local o = {
    connections = {}, placeMatched = tostring(game.PlaceId)==F, destroyed=false,
    itemTeleportRunId=0, farmPartesRunId=0, farmPartesColetadas=0,
    garbageFarmRunId=0, garbageFarmStatus="Parado", durabilidadeRunId=0,
    relationships={}, relationshipConnections={}, staffCount=0, staffNames={},
    pescaRunId=0, pescaStatus="Parado", pescaColetados=0,
    coletaRunId = 0,
    coletaHudRunId = 0,
}

local T = {
    monitorarStaff = false, sorte2xEnabled = false,
    espEnabled=false, box=false, name=false, distance=false, heldItem=false,
    skeleton=false, highlight=false, tracer=false, arrow=false, box3d=false, teamTag=false,
    maxDistance=P, bundles={}, spoofWalkEnabled=false, spoofJumpEnabled=false,
    spoofWalkSpeed=40, spoofJumpPower=90,
    walkSpeedKeybind=Enum.KeyCode.V, menuKeybind=z,
    noclipEnabled=false, noclipKeybind=Enum.KeyCode.N,
    flyEnabled=false, flyKeybind=Enum.KeyCode.F, flySpeed=60,
    aimbotEnabled=false, aimbotMode="Legit", aimbotFov=120, aimbotDistance=500,
    aimbotVisibleOnly=false, aimbotFovVisible=false,
    aimbotHitChance=100, aimbotBodyPart="Cabeca", aimbotSmoothness=0.15,
    aimbotTargetMode="Closest", aimbotWallCheck=true, aimbotTeamCheck=true,
    aimbotKeybind=Enum.KeyCode.E, friendCheck=true, adminCheck=true,
    armaTracer=false, armaTracerCor="Ciano",
    perfectLockpick=false,
    itemTeleportSpeed=65,
    autoFarmLixeiroEnabled=false, autoFarmLixeiroQuantidade=20,
    farmPartesEnabled=false,
    durabilidadeHudEnabled=false,
    autoCintoEnabled=false,
    noclipCarEnabled=false, vFlyEnabled=false,
    vFlyHorizontalSpeed=60, vFlyVerticalSpeed=30,
    boostFactor=1, alwaysDay=false, fullbright=false,
    noLag=false,
    autoFarmPescaEnabled=false,
    autoColetaEnabled=false, autoColetaCooldown=0.35,
    coletaHudEnabled=false, coletaYOffset=3, coletaReachDistance=4,
    coletorArmasAtivo=false,
    coletorArmasReturnPos=CFrame.new(-227, 38, 144),
}

if C.__VETERANO_SINTONIA_CLEANUP then pcall(C.__VETERANO_SINTONIA_CLEANUP) end
if C.__VETERANO_MOBILIDADE_CLEANUP then pcall(C.__VETERANO_MOBILIDADE_CLEANUP); C.__VETERANO_MOBILIDADE_CLEANUP = nil end

local function handleReady(conn) table.insert(o.connections, conn); return conn end
local GuiService = game:GetService("GuiService")

local function handleM(frame)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800,600)
    local sg = frame:FindFirstAncestorWhichIsA("ScreenGui")
    local inset = GuiService:GetGuiInset()
    if sg and sg.IgnoreGuiInset then return inset, vp end
    return Vector2.zero, Vector2.new(vp.X, vp.Y-inset.Y)
end

local function updateInstancePropertiesPosition(frame, handlePart, onEnd)
    handlePart = handlePart or frame
    local kind, startPos, origin
    handleReady(handlePart.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        kind, startPos, origin = t, input.Position, frame.AbsolutePosition
        handleReady(input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                kind = nil
                if onEnd then onEnd(frame.Position) end
            end
        end))
    end))
    handleReady(UserInputService.InputChanged:Connect(function(input)
        if not kind then return end
        local t = input.UserInputType
        if not ((kind == Enum.UserInputType.MouseButton1 and t == Enum.UserInputType.MouseMovement) or
                (kind == Enum.UserInputType.Touch and t == Enum.UserInputType.Touch)) then return end
        local inset, vp = handleM(frame)
        local size = frame.AbsoluteSize
        local x = (origin.X + (input.Position.X - startPos.X)) + inset.X
        local y = (origin.Y + (input.Position.Y - startPos.Y)) + inset.Y
        frame.Position = UDim2.fromOffset(
            math.clamp(x, inset.X+8, math.max(inset.X+8, (vp.X-size.X)-8)),
            math.clamp(y, inset.Y+8, math.max(inset.Y+8, (vp.Y-size.Y)-8))
        )
    end))
end

-- BYPASS ANTI-CHEAT
(function()
    local RS = game:GetService("ReplicatedStorage")
    local isEValid = function(k) return (getgenv and getgenv()[k]) or (_G and _G[k]) end
    local g = isEValid("filtergc")
    local m = isEValid("hookfunction")
    local E = isEValid("newcclosure")
    local M = debug or {}
    local A, F = M.getconstants, M.getprotos
    local u2, q2 = M.getupvalues, M.setupvalue
    if not (g and m and E and A and F and u2 and q2) then
        o.acStatus = "Executor sem filtergc/hookfunction/debug.* - AC intacto."
        return
    end
    local P2 = {}
    local function secondaryZ(C, isEValid2, g2)
        g2 = g2 or 0
        if g2 > 8 then return false end
        local m2, E2 = pcall(A, C)
        if m2 and type(E2)=="table" then
            for _, v in next, E2 do
                if type(v)=="string" and isEValid2(v) then return true end
            end
        end
        local M2, H2 = pcall(F, C)
        if M2 and type(H2)=="table" then
            for _, p in next, H2 do
                if secondaryZ(p, isEValid2, g2+1) then return true end
            end
        end
        return false
    end
    local function alternateZ(C)
        return secondaryZ(C, function(s) return string.find(s, "__ACK__", 1, true) ~= nil end)
    end
    local f2 = {"Hitbox Expander", "ESP Detectado"}
    local function isYValid(C)
        local isEValid2, g2 = false, true
        secondaryZ(C, function(s)
            if #s < 4 or not string.find(s, " ", 1, true) then return false end
            isEValid2 = true
            for _, bad in ipairs(f2) do
                if string.find(s, bad, 1, true) then return false end
            end
            g2 = false
            return true
        end)
        return isEValid2 and g2
    end
    local V = {"CFrame TP: ","Tween TP: ","TP Absurdo","Velocity","VFly","WalkFling IY","Noclip","WalkSpeed: ","JumpPower: ","Fly mal feito"}
    local handleM2 = {FireServer = function() end}
    local updateInstancePropertiesPosition2 = {
        WaitForChild = function() return handleM2 end,
        FindFirstChild = function() return handleM2 end,
    }
    local O = {"CFrame TP: ","TP Absurdo","VFly"}
    local function handleY(C)
        local ok, consts = pcall(A, C)
        if not ok or type(consts)~="table" then return false end
        for _, v in next, consts do
            if type(v)=="string" then
                for _, reason in ipairs(O) do
                    if v == reason then return true end
                end
            end
        end
        return false
    end
    local function handleG()
        local ok, res = pcall(g, "function", {Constants={"VFly"}, IgnoreExecutor=true})
        if not ok or type(res)~="table" then return nil end
        return res
    end
    local function handler(fn)
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return true end
        for _, v in next, ups do
            if v == RS then return true end
        end
        return false
    end
    local function secondaryHandleG(fn)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return false end
        for _, v in next, ups do
            if v == root then return true end
        end
        return false
    end
    local function isValid(fn)
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return false end
        for k, v in next, ups do
            if v == RS then
                return (pcall(q2, fn, k, updateInstancePropertiesPosition2)) and true or false
            end
        end
        return true
    end
    local getconnectionsFn = isEValid("getconnections")
    local function handleM3(fn, depth)
        depth = depth or 0
        if depth > 6 then return nil end
        local ok, consts = pcall(A, fn)
        if ok and type(consts)=="table" then
            for _, v in next, consts do
                if type(v)=="string" then
                    for _, reason in ipairs(V) do
                        if v == reason then return reason end
                    end
                end
            end
        end
        local ok2, protos = pcall(F, fn)
        if ok2 and type(protos)=="table" then
            for _, p in next, protos do
                local r = handleM3(p, depth+1)
                if r then return r end
            end
        end
        return nil
    end
    local function alternateHandleG()
        local out = {}
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            out[#out+1] = hum:GetPropertyChangedSignal("WalkSpeed")
            out[#out+1] = hum:GetPropertyChangedSignal("JumpPower")
            out[#out+1] = hum.StateChanged
        end
        if char then
            out[#out+1] = char.DescendantAdded
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then out[#out+1] = p:GetPropertyChangedSignal("CanCollide") end
            end
        end
        out[#out+1] = RunService.Heartbeat
        return out
    end
    local function handleAcReaplicar()
        if not getconnectionsFn then return nil end
        local seen, reasons = {}, {}
        for _, sig in ipairs(alternateHandleG()) do
            local ok, conns = pcall(getconnectionsFn, sig)
            if ok and type(conns)=="table" then
                for _, c in ipairs(conns) do
                    local fn = c.Function
                    if type(fn)=="function" and c.Connected then
                        local r = handleM3(fn)
                        if r and not seen[r] then seen[r]=true; reasons[#reasons+1]=r end
                    end
                end
            end
        end
        local fns = handleG()
        if fns == nil then return nil end
        local hasApproved, hasUnapproved = false, false
        for _, fn in next, fns do
            if secondaryHandleG(fn) then
                if handler(fn) then hasApproved = true else hasUnapproved = true end
            end
        end
        if (hasApproved or not hasUnapproved) and not seen["CFrame TP: "] then
            seen["CFrame TP: "] = true
            reasons[#reasons+1] = "CFrame TP: "
        end
        return reasons
    end
    local function secondaryHandleY()
        if not RS:FindFirstChild("SignalSendACK") then return 0 end
        local ok, fns = pcall(g, "function", {Constants={"SignalSendACK","FireServer"}, IgnoreExecutor=true})
        if not ok or type(fns)~="table" then return 0 end
        local hit, total = 0, 0
        for _, fn in next, fns do
            if not P2[fn] then
                if handleY(fn) then
                    if isValid(fn) then P2[fn] = true; hit = hit+1 end
                else
                    P2[fn] = true
                    if not alternateZ(fn) and not isYValid(fn) then
                        if pcall(m, fn, E(function() end)) then hit = hit+1 end
                    end
                end
                total = total + 1
                if total >= 200 then total = 0; task.wait() end
            end
        end
        return hit
    end
    local b2 = false
    local function acReaplicar(tag)
        if b2 or o.destroyed then return end
        b2 = true
        o.acSilenciados = 0
        o.acMotivosVivos = nil
        o.acStatus = "Aplicando ("..tag..")..."
        task.spawn(function()
            local silenced, reasons = 0, nil
            for _ = 1, 120, 1 do
                if o.destroyed then break end
                silenced = silenced + secondaryHandleY()
                reasons = handleAcReaplicar()
                if reasons == nil then break end
                if #reasons == 0 then break end
                task.wait(0.5)
            end
            b2 = false
            o.acSilenciados = silenced
            o.acMotivosVivos = reasons
            if reasons == nil then
                o.acStatus = silenced.." silenciado(s) ("..tag..")"
            elseif #reasons > 0 then
                o.acStatus = "AC parcial: "..silenced.." OK, vivos: "..table.concat(reasons, ", ")
            elseif silenced > 0 then
                o.acStatus = silenced.." denunciante(s) silenciado(s)"
            else
                o.acStatus = "Nenhum denunciante encontrado"
            end
        end)
    end
    o.acReaplicar = acReaplicar
    acReaplicar("carga")
    handleReady(LocalPlayer.CharacterAdded:Connect(function()
        acReaplicar("respawn")
    end))
end)()

-- MUNDO
do
    local function capture()
        local L = game:GetService("Lighting")
        return {
            Brightness = L.Brightness, ClockTime = L.ClockTime,
            GeographicLatitude = L.GeographicLatitude, FogEnd = L.FogEnd,
            FogStart = L.FogStart, GlobalShadows = L.GlobalShadows,
            Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient,
            ExposureCompensation = L.ExposureCompensation,
            EnvironmentDiffuseScale = L.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = L.EnvironmentSpecularScale,
        }
    end
    local function restore()
        local L = game:GetService("Lighting")
        if not o.worldOriginal then return end
        for k, v in pairs(o.worldOriginal) do pcall(function() L[k] = v end) end
        for _, atm in ipairs(L:GetChildren()) do
            if atm:IsA("Atmosphere") and o.worldAtmOriginal then
                pcall(function() atm.Density = o.worldAtmOriginal end)
            end
        end
    end
    local function applyWorld()
        local L = game:GetService("Lighting")
        local active = T.alwaysDay or T.fullbright or T.noLag
        if active and not o.worldOriginal then
            o.worldOriginal = capture()
            local atm = L:FindFirstChildOfClass("Atmosphere")
            o.worldAtmOriginal = atm and atm.Density or 0.3
        elseif not active and o.worldOriginal then
            restore(); o.worldOriginal = nil; return
        end
        if not active then return end
        if T.alwaysDay then
            pcall(function() L.ClockTime = 12 end)
            pcall(function() L.GeographicLatitude = 0 end)
        elseif o.worldOriginal then
            pcall(function() L.ClockTime = o.worldOriginal.ClockTime end)
            pcall(function() L.GeographicLatitude = o.worldOriginal.GeographicLatitude end)
        end
        if T.fullbright then
            pcall(function()
                L.Brightness = 3; L.ExposureCompensation = 0
                L.EnvironmentDiffuseScale = 1; L.EnvironmentSpecularScale = 1
                L.Ambient = Color3.new(1,1,1); L.OutdoorAmbient = Color3.new(1,1,1)
                L.GlobalShadows = false; L.FogStart = 0; L.FogEnd = 1e9
            end)
            for _, atm in ipairs(L:GetChildren()) do
                if atm:IsA("Atmosphere") then pcall(function() atm.Density = 0 end) end
            end
        elseif T.noLag then
            pcall(function()
                L.GlobalShadows = false; L.FogStart = 0; L.FogEnd = 1e6
            end)
            for _, atm in ipairs(L:GetChildren()) do
                if atm:IsA("Atmosphere") then pcall(function() atm.Density = 0 end) end
            end
            for _, v in ipairs(L:GetDescendants()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                    pcall(function() v.Enabled = false end)
                end
            end
        elseif o.worldOriginal then
            pcall(function()
                L.Brightness = o.worldOriginal.Brightness
                L.ExposureCompensation = o.worldOriginal.ExposureCompensation
                L.Ambient = o.worldOriginal.Ambient
                L.OutdoorAmbient = o.worldOriginal.OutdoorAmbient
                L.GlobalShadows = o.worldOriginal.GlobalShadows
                L.FogStart = o.worldOriginal.FogStart
                L.FogEnd = o.worldOriginal.FogEnd
            end)
        end
    end
    o.applyWorld = applyWorld
    local acc = 0
    handleReady(RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < 0.2 then return end
        acc = 0
        if T.alwaysDay or T.fullbright or T.noLag then pcall(applyWorld) end
    end))
end

-- AUTO CINTO
do
    local acc = 0
    local function autoCinto()
        local st = LocalPlayer:FindFirstChild("Status")
        local cinto = st and st:FindFirstChild("Cinto")
        if not cinto or cinto.Value then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if not seat or seat.Name ~= "DriveSeat" then return end
        cinto.Value = true
        pcall(function() LocalPlayer.PlayerGui.OrpheusCarInterface.Velocimetro.Icons.Cinto.Visible = true end)
        pcall(function()
            local sound = seat:FindFirstChild("ColocaCinto")
            if sound then sound:Play() end
        end)
    end
    handleReady(RunService.Heartbeat:Connect(function(dt)
        if not T.autoCintoEnabled then return end
        acc = acc + dt
        if acc < 0.3 then return end
        acc = 0
        pcall(autoCinto)
    end))
end

-- HELPERS
local function isCValid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function isUpdatePlayerGetMagnitudeCValid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local U = Vector3.zero
task.spawn(function()
    while not o.destroyed do
        local hum = isCValid()
        if hum then U = hum.MoveDirection end
        task.wait(0.05)
    end
end)

local L = 28
local function isUpdateInstancePropertiesEValid()
    local reasons = o.acMotivosVivos
    return (o.acSilenciados or 0) > 0 and (reasons ~= nil and #reasons == 0)
end

local function updateInstanceProperties(hum)
    if not hum then return end
    if T.spoofWalkEnabled then
        local ws = math.min(T.spoofWalkSpeed, L)
        if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
    end
    if T.spoofJumpEnabled then
        if hum.JumpPower ~= 50 then hum.JumpPower = 50 end
        if not hum.UseJumpPower then hum.UseJumpPower = true end
    end
end

local b = {
    [Enum.HumanoidStateType.Seated]=true,
    [Enum.HumanoidStateType.Dead]=true,
    [Enum.HumanoidStateType.Climbing]=true,
}
local y = 0.5
local x = 18
local c = 34
local l = 36
local Z = 0.08
local D = 16

local function handleG(arr, now)
    local sum = 0
    for i = #arr, 1, -1 do
        if now - arr[i].t > y then table.remove(arr, i)
        else sum = sum + arr[i].passo end
    end
    return sum
end
local function handleInstanceProperties(arr, now, from, to)
    if not to then return end
    local d = (to-from).Magnitude
    if d > 0 then table.insert(arr, {t=now, passo=d}) end
end
local j = {root=nil, posicao=nil, ultimaAmostra=0, historico={}}
local function updateG(root, now)
    local st = j
    if st.root ~= root or now - st.ultimaAmostra > y then
        st.root = root; st.posicao = root.Position; st.ultimaAmostra = now
        table.clear(st.historico)
        return 0
    end
    handleInstanceProperties(st.historico, now, st.posicao, root.Position)
    st.posicao = root.Position
    st.ultimaAmostra = now
    return handleG(st.historico, now)
end
local function isGhValid(root, dt)
    local hum = isCValid()
    if root.Anchored or not hum or hum.Health <= 0 or dt >= Z then return true end
    local st = hum:GetState()
    return root.AssemblyLinearVelocity.Magnitude < 12 and (st ~= Enum.HumanoidStateType.Freefall and st ~= Enum.HumanoidStateType.Jumping)
end
local function handleQ(root, dt, targetVel, isFly)
    local step = math.clamp(dt or 0.016666, 0.004166, y)
    local moved = updateG(root, os.clock())
    local stable = not isFly or isGhValid(root, step)
    local slow = isFly and (stable and moved > x)
    local cap = isFly and (stable and x or c) or x
    if slow then cap = c end
    local slack = math.max(0, cap-moved)
    local vel = math.min(math.max(targetVel or 0, 0), slack/step)
    local phys = math.max(0, slack-vel*step)
    if slow then phys = 0 end
    return step, vel, phys, moved, stable
end

local w, a, i, d = 4, 8, 105, 65
local G, t, K = 0.05, 0.6, 14
local Cz, Yz, gz = 20, 14, 0.55
local mz = Vector3.zero
local Ez, Mz, Hz, Az = 0, 0, 4, 0

local function Fz(dt)
    if not T.spoofWalkEnabled then Az = 0; return end
    if T.flyEnabled or T.autoFarmPescaEnabled or T.farmPartesEnabled then Az = 0; return end
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return end
    local hum = isCValid()
    if not hum then return end
    if hum.Sit or b[hum:GetState()] then Az = 0; return end
    if U.Magnitude <= 0 then
        Az = 0
        if os.clock() < Ez and mz.Magnitude > 0 then
            local ws = math.max(hum.WalkSpeed, 1)
            local frac = math.clamp(Yz/ws, 0, 1)
            pcall(hum.Move, hum, mz*frac, false)
        end
        return
    end
    mz = U.Unit
    Ez = os.clock() + gz
    local vel = root.AssemblyLinearVelocity
    local horiz = Vector3.new(vel.X, 0, vel.Z).Magnitude
    if (dt or 0) >= G or root.Anchored or horiz < 12 then
        Mz = os.clock() + t
    end
    local unblocked = isUpdateInstancePropertiesEValid()
    local speed = math.min(T.spoofWalkSpeed, unblocked and T.spoofWalkSpeed or (os.clock() < Mz and d or i))
    local diff = speed - L
    if diff <= 0 then Az = 0; return end
    local jitter = 0.9 + math.random()*0.1
    local want = (diff*dt)*jitter + Az
    local step = math.min(want, diff*dt, unblocked and a or w)
    Az = math.clamp(want-step, 0, Hz)
    local dir = U.Unit
    root.CFrame = root.CFrame + dir*step
    local v = root.AssemblyLinearVelocity
    if Vector3.new(v.X, 0, v.Z).Magnitude < K then
        root.AssemblyLinearVelocity = Vector3.new(dir.X*Cz, v.Y, dir.Z*Cz)
    end
end

local function uz()
    if not T.spoofJumpEnabled then return end
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return end
    local diff = T.spoofJumpPower - 50
    if diff > 0 then root.Velocity = root.Velocity + Vector3.new(0, diff, 0) end
end

-- NOCLIP / FLY
local Oz = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg","HumanoidRootPart"}
local Xz = {Head=true, Torso=true, ["Left Arm"]=false, ["Right Arm"]=false, ["Left Leg"]=false, ["Right Leg"]=false, HumanoidRootPart=false}
local Bz = nil

local function sz(force)
    local char = LocalPlayer.Character
    if not char then return end
    for _, name in ipairs(Oz) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            local col = not force and Xz[name] or false
            if p.CanCollide ~= col then p.CanCollide = col end
        end
    end
end

local function Nz()
    local char = LocalPlayer.Character
    if not char then return end
    local rag = char:FindFirstChild("IsRagdoll")
    local rc = char:FindFirstChild("RagdollClient")
    if T.noclipEnabled then
        if rc then rc.Disabled = true end
        if rag and not rag.Value then rag.Value = true end
        sz(true)
    else
        Bz = nil; sz(false)
        if rag and rag.Value then rag.Value = false end
        if rc then rc.Disabled = false end
    end
end

local Sz = 50
local function ez()
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return end
    if not Bz then Bz = root.Position.Y; return end
    local vel = root.AssemblyLinearVelocity
    local onGround = root.Position.Y <= Bz+0.5
    local hum = isCValid()
    local jump = (hum and hum.Jump) or UserInputService:IsKeyDown(Enum.KeyCode.Space)
    if onGround and jump then
        root.AssemblyLinearVelocity = Vector3.new(vel.X, Sz, vel.Z); return
    end
    if vel.Y < 0 and root.Position.Y <= Bz then
        root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
    end
end

local Uz, Lz, kz = 60, 30, 14
local nz = Uz
local bz = Vector3.zero
local yz = false

local function xz(dt)
    local root = isUpdatePlayerGetMagnitudeCValid()
    local hum = isCValid()
    if not root or not hum then return end
    if not T.flyEnabled then
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        if hum:GetState() == Enum.HumanoidStateType.Swimming then
            local target = hum.FloorMaterial == Enum.Material.Air and Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.Running
            pcall(hum.ChangeState, hum, target)
        end
        if T.autoFarmPescaEnabled or T.farmPartesEnabled then yz = false; return end
        if isUpdateInstancePropertiesEValid() then
            yz = false; root.AssemblyLinearVelocity = Vector3.zero; return
        end
        local _, vel, phys, _, stable = handleQ(root, dt, kz, true)
        if yz and (stable and bz.Magnitude > 0) then
            root.AssemblyLinearVelocity = bz*vel; return
        end
        yz = false; root.AssemblyLinearVelocity = Vector3.zero; return
    end
    if hum.Health <= 0 then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    local vert = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vert = 1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vert = -1 end
    local dir = hum.MoveDirection + Vector3.new(0, vert, 0)
    if dir.Magnitude <= 0 then
        if isUpdateInstancePropertiesEValid() then root.AssemblyLinearVelocity = Vector3.zero; return end
        local _, vel, _, _, stable = handleQ(root, dt, kz, true)
        if stable and bz.Magnitude > 0 then root.AssemblyLinearVelocity = bz*vel
        else root.AssemblyLinearVelocity = Vector3.zero end
        return
    end
    dir = dir.Unit
    bz = dir; yz = true
    if isUpdateInstancePropertiesEValid() then
        root.AssemblyLinearVelocity = dir * T.flySpeed; return
    end
    local cap = hum.MoveDirection.Magnitude > 0 and Uz or nz
    local goal = math.min(T.flySpeed, cap)
    local vel = math.min(goal, Lz)
    local _, step, _, _, stable = handleQ(root, dt, vel, true)
    local wanted = math.min(goal, stable and l or Uz)
    local want2 = math.max(0, wanted-step)
    if want2 > 0 then root.CFrame = root.CFrame + dir*want2*(dt or 0.016) end
    root.AssemblyLinearVelocity = dir*step
end

-- VEICULO
local function Dz(hum)
    if type(getconnections) ~= "function" then return nil end
    if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" then return nil end
    for _, conn in ipairs(getconnections(RunService.Stepped)) do
        local fn = conn.Function
        if type(fn)=="function" then
            local hit, carState
            for i = 1, 8, 1 do
                local ok, up = pcall(debug.getupvalue, fn, i)
                if not ok then break end
                if up == hum then hit = true end
                if type(up)=="table" and (up.RemapMultiplier ~= nil and type(up.BuildHPCache)=="function") then
                    carState = up
                end
            end
            if hit and carState then return carState end
        end
    end
    return nil
end

local function rz()
    local hum = isCValid()
    local seat = hum and hum.SeatPart
    if not seat or seat.Name ~= "DriveSeat" then return nil end
    local carros = workspace:FindFirstChild("CarrosSpawnados")
    if not carros then return nil end
    local p = seat
    while p and p.Parent ~= carros do p = p.Parent end
    return p
end

do
    local carCfg = {
        carro=nil, originais={}, raiz=nil, assento=nil,
        relativoAssento=nil, altura=nil, piso=nil, raycast=nil,
        velocidade=0, frente=nil, personagemAtivo=false,
        altitude=nil, vFlyAtivo=false, vFlyReduzidoAte=0,
    }
    local function findSeat(car)
        local seat = car:FindFirstChild("DriveSeat", true) or car:FindFirstChildWhichIsA("VehicleSeat", true)
        return (seat and seat.AssemblyRootPart) or car.PrimaryPart or seat, seat
    end
    local function restaurarNoclipCar()
        for part, v in pairs(carCfg.originais) do
            if part.Parent then pcall(function() part.CanCollide = v end) end
        end
        table.clear(carCfg.originais)
        if carCfg.personagemAtivo and not T.noclipEnabled then pcall(sz, false) end
        carCfg.carro, carCfg.raiz, carCfg.assento = nil, nil, nil
        carCfg.relativoAssento, carCfg.altura, carCfg.piso, carCfg.raycast = nil, nil, nil, nil
        carCfg.velocidade, carCfg.frente, carCfg.personagemAtivo = 0, nil, false
        carCfg.altitude, carCfg.vFlyAtivo, carCfg.vFlyReduzidoAte = nil, false, 0
    end
    local function prepararNoclipCar(car)
        local raiz, seat = findSeat(car)
        if not raiz or not seat then return end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {car, LocalPlayer.Character}
        local hit = workspace:Raycast(raiz.Position + Vector3.new(0, 20, 0), Vector3.new(0, -120, 0), rp)
        carCfg.raiz = raiz; carCfg.assento = seat
        carCfg.relativoAssento = ((raiz.CFrame - raiz.Position)):ToObjectSpace(seat.CFrame - seat.Position)
        carCfg.raycast = rp
        carCfg.piso = hit and hit.Position.Y or (raiz.Position.Y - 3)
        carCfg.altura = hit and math.max(1, raiz.Position.Y - hit.Position.Y) or 3
        local fwd = Vector3.new(seat.CFrame.LookVector.X, 0, seat.CFrame.LookVector.Z)
        carCfg.frente = fwd.Magnitude > 0 and fwd.Unit or Vector3.new(0, 0, -1)
        carCfg.altitude = raiz.Position.Y
        carCfg.velocidade = fwd.Magnitude > 0 and raiz.AssemblyLinearVelocity:Dot(fwd.Unit) or 0
    end
    local function max(a, b, d)
        if a < b then return math.min(a+d, b) end
        return math.max(a-d, b)
    end
    local function tickCar(dt)
        local raiz, seat = carCfg.raiz, carCfg.assento
        local rp, altura, piso = carCfg.raycast, carCfg.altura, carCfg.piso
        local rel = carCfg.relativoAssento
        if not raiz or not raiz.Parent or not seat or not seat.Parent or not rp or not altura or not piso or not rel then return end
        local step = math.min(dt or 0.016666, 0.1)
        local flying = T.vFlyEnabled
        local unstable = false
        if flying and not carCfg.vFlyAtivo then
            carCfg.altitude = raiz.Position.Y
            carCfg.vFlyReduzidoAte = os.clock() + 0.6
            carCfg.velocidade = math.clamp(carCfg.velocidade, -24, 36)
        elseif not flying and carCfg.vFlyAtivo then
            local hit = workspace:Raycast(raiz.Position + Vector3.new(0, 20, 0), Vector3.new(0, -520, 0), rp)
            if hit then piso = hit.Position.Y; carCfg.piso = piso end
        end
        carCfg.vFlyAtivo = flying
        local vertAdj = 0
        if flying then
            if step >= 0.05 or raiz.Anchored or raiz.AssemblyLinearVelocity.Magnitude < 12 then
                carCfg.vFlyReduzidoAte = os.clock() + 0.6
            end
        else
            local scanStart = Vector3.new(raiz.Position.X, piso+20, raiz.Position.Z)
            local hit = workspace:Raycast(scanStart, Vector3.new(0, -60, 0), rp)
            if hit and hit.Position.Y - piso <= 4 then piso = hit.Position.Y; carCfg.piso = piso end
            vertAdj = (piso + altura) - raiz.Position.Y
            unstable = math.abs(vertAdj) > 1
            if unstable then vertAdj = math.clamp(vertAdj, -20*step, 20*step) end
        end
        local fwd = carCfg.frente or Vector3.new(0, 0, -1)
        local verticalVel = 0
        if fwd.Magnitude > 0.001 then
            fwd = fwd.Unit
            local throttle = seat.ThrottleFloat
            local steer = seat.SteerFloat
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then throttle = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then throttle = -1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then steer = -1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then steer = 1 end
            local unblocked = isUpdateInstancePropertiesEValid()
            local boost = math.clamp(T.boostFactor, 1, 999)
            local vMax
            if flying then vMax = T.vFlyHorizontalSpeed * boost
            else vMax = unstable and 260 or (unblocked and 999 or 180) * boost end
            local vMin = flying and (vMax*0.65) or (unstable and 120 or (150*boost))
            local target = throttle > 0.05 and vMax or (throttle < -0.05 and -vMin or 0)
            local accel = (math.abs(throttle) > 0.05 and 130 or 200) * step
            carCfg.velocidade = max(carCfg.velocidade, target, accel)
            if math.abs(steer) > 0.05 and math.abs(carCfg.velocidade) > 0.5 then
                local sign = carCfg.velocidade >= 0 and 1 or -1
                local ang = ((-steer*sign) * math.rad(85)) * step
                fwd = CFrame.Angles(0, ang, 0):VectorToWorldSpace(fwd)
            end
            carCfg.frente = fwd.Unit
            if flying then
                local vInput = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vInput = 1
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vInput = -1 end
                local vCap = T.vFlyVerticalSpeed * boost
                if vInput ~= 0 then
                    verticalVel = vInput * vCap
                    carCfg.altitude = raiz.Position.Y + verticalVel * step
                else
                    local diff = (carCfg.altitude or raiz.Position.Y) - raiz.Position.Y
                    verticalVel = math.clamp(diff*10, -vCap, vCap)
                end
            end
            local look = CFrame.lookAt(Vector3.zero, fwd.Unit, Vector3.yAxis)
            local rot = look * rel:Inverse()
            if flying then
                raiz.CFrame = CFrame.new(raiz.Position + Vector3.new(0, vertAdj, 0)) * rot
            elseif math.abs(vertAdj) > 0.01 then
                raiz.CFrame = raiz.CFrame + Vector3.new(0, vertAdj, 0)
            end
            if fwd.Magnitude > 0.001 then
                raiz.AssemblyLinearVelocity = fwd.Unit*carCfg.velocidade + Vector3.new(0, verticalVel, 0)
            else
                raiz.AssemblyLinearVelocity = Vector3.new(0, verticalVel, 0)
            end
            raiz.AssemblyAngularVelocity = Vector3.zero
        end
    end
    local function aplicarNoclipCar()
        if not T.noclipCarEnabled and not T.vFlyEnabled then
            restaurarNoclipCar(); return
        end
        local car = rz()
        if car ~= carCfg.carro then
            restaurarNoclipCar()
            carCfg.carro = car
            if car then prepararNoclipCar(car) end
        end
        if not car then return end
        sz(true); carCfg.personagemAtivo = true
        for _, p in ipairs(car:GetDescendants()) do
            if p:IsA("BasePart") then
                if carCfg.originais[p] == nil then carCfg.originais[p] = p.CanCollide end
                if p.CanCollide then p.CanCollide = false end
            end
        end
    end
    o.aplicarNoclipCar = aplicarNoclipCar
    o.restaurarNoclipCar = restaurarNoclipCar
    handleReady(RunService.Stepped:Connect(function() if not o.destroyed then pcall(aplicarNoclipCar) end end))
    handleReady(RunService.Heartbeat:Connect(function(dt)
        if not o.destroyed and (T.noclipCarEnabled or T.vFlyEnabled) then pcall(tickCar, dt) end
    end))
end

local function hz(hum)
    local st = Dz(hum)
    if not st then return false end
    st.RemapMultiplier = math.clamp(T.boostFactor, 1, 999)
    pcall(function() st:BuildHPCache() end)
    pcall(function()
        if st.SpeedLimit ~= nil then st.SpeedLimit = 999 end
        if st.MaxSpeed ~= nil then st.MaxSpeed = 999 end
        if st.TopSpeed ~= nil then st.TopSpeed = 999 end
        if st.SpeedCap ~= nil then st.SpeedCap = 999 end
    end)
    return true
end

-- LOOP PRINCIPAL
o.state = T
C.__VETERANO_SINTONIA_RUNTIME = o

local function Wz(dt)
    if o.destroyed then return end
    local hum = isCValid()
    if hum then updateInstanceProperties(hum) end
    pcall(Fz, dt)
    if T.noclipEnabled then
        pcall(Nz)
        if not T.flyEnabled then pcall(ez) end
    end
    if T.flyEnabled or yz then pcall(xz, dt) end
end
handleReady(RunService.Heartbeat:Connect(Wz))
handleReady(RunService.Stepped:Connect(function()
    if not o.destroyed and T.noclipEnabled then pcall(sz, true) end
end))

task.spawn(function()
    local lastCar
    while not o.destroyed do
        local car = rz()
        if car then o.lastDrivenCar = car end
        if car and car ~= lastCar then
            local hum = isCValid()
            if hum then hz(hum) end
            lastCar = car
        elseif not car then
            lastCar = nil
        end
        task.wait(0.5)
    end
end)

local function vz(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        updateInstanceProperties(hum)
        hum.Jumping:Connect(uz)
    end
end
handleReady(LocalPlayer.CharacterAdded:Connect(vz))
if LocalPlayer.Character then vz(LocalPlayer.Character) end

-- STAFF DETECTION
local Jz = {}
do
    local CollectionService = game:GetService("CollectionService")
    local rankMin = 254
    local friendCol = Color3.fromRGB(60,210,255)
    local normCol = Color3.fromRGB(170,70,255)
    local staffKeywords = {"admin","staff","moder","owner","founder","creator","developer","dono","fundador","gerente","supervis","diretor","gestor"}
    local function hasKeyword(s)
        s = string.lower(tostring(s or ""))
        for _, k in ipairs(staffKeywords) do
            if string.find(s, k, 1, true) then return true end
        end
        return false
    end
    local function isTruthy(v)
        local t = typeof(v)
        if t == "boolean" then return v end
        if t == "number" then return v > 0 end
        if t == "string" then
            local s = string.lower(v)
            return s ~= "" and s ~= "false" and s ~= "0" and s ~= "none" and s ~= "guest" and s ~= "member"
        end
        return v ~= nil
    end
    local function isConfiguredStaff(plr)
        local list = C.VETERANO_SINTONIA_STAFF_USER_IDS
        if type(list) ~= "table" then return false end
        return list[plr.UserId] == true or list[tostring(plr.UserId)] == true or table.find(list, plr.UserId) ~= nil
    end
    local function isAdminRaw(plr)
        if isConfiguredStaff(plr) then return true, "configured" end
        if game.CreatorType == Enum.CreatorType.User and plr.UserId == game.CreatorId then
            return true, "creator"
        end
        local ok, attrs = pcall(function() return plr:GetAttributes() end)
        if ok then
            for k, v in pairs(attrs) do
                if hasKeyword(k) and isTruthy(v) then return true, "attribute:"..k end
            end
        end
        local ok2, tags = pcall(CollectionService.GetTags, CollectionService, plr)
        if ok2 then
            for _, tag in ipairs(tags) do
                if hasKeyword(tag) then return true, "tag:"..tag end
            end
        end
        return false, nil
    end
    local function getRel(plr)
        local r = o.relationships[plr]
        if r then return r end
        r = {ready=false, checking=false, friend=false, admin=false, rank=0, role="", source=nil}
        o.relationships[plr] = r
        return r
    end
    local function checkReady(plr)
        if plr == LocalPlayer or plr.Parent ~= Players then return end
        local rel = getRel(plr)
        if rel.checking then return end
        rel.checking = true
        task.spawn(function()
            local friend = false
            local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
            if ok then friend = res == true end
            local admin, src = isAdminRaw(plr)
            local rank, role = 0, ""
            if game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 then
                local ok2, r = pcall(function() return plr:GetRankInGroup(game.CreatorId) end)
                if ok2 and type(r) == "number" then rank = r end
                local ok3, ro = pcall(function() return plr:GetRoleInGroup(game.CreatorId) end)
                if ok3 and type(ro) == "string" then role = ro end
                if rank >= rankMin then admin, src = true, "group-rank:"..rank
                elseif hasKeyword(role) then admin, src = true, "group-role:"..role end
            end
            if plr.Parent == Players and o.relationships[plr] == rel then
                rel.friend = friend; rel.admin = admin
                rel.rank = rank; rel.role = role; rel.source = src
                rel.ready = true; rel.checking = false
            end
        end)
    end
    local function getRelSafe(plr)
        local r = getRel(plr)
        if not r.ready and not r.checking then checkReady(plr) end
        return r
    end
    function Jz.Protected(plr)
        local r = getRelSafe(plr)
        if (T.friendCheck or T.adminCheck) and not r.ready then return true end
        if T.adminCheck and r.admin then return true end
        if T.friendCheck and r.friend then return true end
        return false
    end
    Jz.Admin = function(plr)
        local r = getRelSafe(plr)
        return r.ready and r.admin
    end
    Jz.Appearance = function(plr)
        local r = getRelSafe(plr)
        if r.ready and (T.adminCheck and r.admin) then return STAFF_RED, " [STAFF]" end
        if r.ready and (T.friendCheck and r.friend) then return friendCol, " [AMIGO]" end
        return normCol, ""
    end
    local function onAdded(plr)
        if plr == LocalPlayer then return end
        checkReady(plr)
        local conn = plr.AttributeChanged:Connect(function(name)
            if hasKeyword(name) then
                local r = o.relationships[plr]
                if r then r.ready = false end
                checkReady(plr)
            end
        end)
        o.relationshipConnections[plr] = conn
        handleReady(conn)
    end
    for _, plr in ipairs(Players:GetPlayers()) do onAdded(plr) end
    handleReady(Players.PlayerAdded:Connect(onAdded))
    handleReady(Players.PlayerRemoving:Connect(function(plr)
        o.relationships[plr] = nil
        o.relationshipConnections[plr] = nil
    end))
end

task.spawn(function()
    while not o.destroyed do
        if T.monitorarStaff then
            local count, nomes = 0, {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and Jz.Admin(plr) then
                    count = count + 1
                    table.insert(nomes, plr.Name)
                end
            end
            o.staffCount = count
            o.staffNames = nomes
        end
        task.wait(1)
    end
end)

-- ESP
local wz = {medido=false, drawing=false, texto=false}
function wz.set(obj, prop, val) return pcall(function() obj[prop]=val end) end
function wz.medir()
    if wz.medido then return wz end
    if Drawing == nil or type(Drawing.new) ~= "function" then return wz end
    local ok, sq = pcall(Drawing.new, "Square")
    if not ok then return wz end
    wz.drawing = true
    wz.filled = wz.set(sq, "Filled", false)
    wz.thickness = wz.set(sq, "Thickness", 1)
    pcall(function() sq:Remove() end)
    local ok2, txt = pcall(Drawing.new, "Text")
    if ok2 then
        wz.texto = true
        wz.center = wz.set(txt, "Center", true)
        wz.outline = wz.set(txt, "Outline", true)
        wz.outlineColor = wz.set(txt, "OutlineColor", Color3.new())
        wz.font = wz.set(txt, "Font", 2)
        pcall(function() txt.Text = "MMM" end)
        local ok3, tb = pcall(function() return txt.TextBounds end)
        wz.textBounds = ok3 and (typeof(tb)=="Vector2" and tb.X > 0)
        pcall(function() txt:Remove() end)
    end
    local ok4, tr = pcall(Drawing.new, "Triangle")
    wz.triangle = ok4 == true
    if ok4 then pcall(function() tr:Remove() end) end
    wz.medido = true
    return wz
end
function wz.ok() return (wz.medir()).drawing end

local function az(kind)
    if not wz.ok() then return nil end
    if kind == "Triangle" and not wz.triangle then return nil end
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if not ok then return nil end
    wz.set(obj, "Visible", false)
    wz.set(obj, "Color", Color3.fromRGB(170,70,255))
    wz.set(obj, "Transparency", 1)
    wz.set(obj, "Thickness", 1)
    return obj
end

local function iz(col)
    if not wz.ok() or not wz.texto then return nil end
    local ok, obj = pcall(function() return Drawing.new("Text") end)
    if not ok then return nil end
    wz.set(obj, "Visible", false)
    wz.set(obj, "Color", col or Color3.fromRGB(170,70,255))
    wz.set(obj, "Transparency", 1)
    wz.set(obj, "Size", 13)
    if wz.center then wz.set(obj, "Center", true) end
    if wz.outline then wz.set(obj, "Outline", true) end
    if wz.outlineColor then wz.set(obj, "OutlineColor", Color3.new(0,0,0)) end
    if wz.font then wz.set(obj, "Font", 2) end
    return obj
end

local function larguraText(obj)
    if not obj then return 0 end
    if wz.textBounds then
        local ok, tb = pcall(function() return obj.TextBounds end)
        if ok and tb then return tb.X end
    end
    local ok, txt = pcall(function() return obj.Text end)
    if not ok or type(txt) ~= "string" then return 0 end
    local ok2, sz = pcall(function() return obj.Size end)
    return (#txt * (ok2 and sz or 13)) * 0.52
end

local dz = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local Gz = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}
local tz = #dz
local Kz = {{1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},{5,6},{5,7},{6,8},{7,8}}
local CF, YF, gF, mF = 300, 0.016666, 0.033333, 0.05
local EF, MF = 4, 5
local HF = function(prev, now, interval) if prev <= 0 or now-prev > interval then return now+interval end return prev+interval end

local function AF(plr)
    local b2 = {
        player=plr, box=az("Square"),
        name=iz(Color3.fromRGB(170,70,255)),
        distance=iz(Color3.fromRGB(190,200,225)),
        item=iz(Color3.fromRGB(190,200,225)),
        team=iz(Color3.fromRGB(170,70,255)),
        lines={}, tracer=nil, arrow=nil, box3dLines={}, highlight=nil,
        character=nil, humanoid=nil, root=nil,
        bodyParts={}, skeletonPairs={},
        relationshipColor=nil, relationshipLabel="",
        nextVisualUpdate=0, nextSkeletonUpdate=0,
    }
    if b2.box and wz.filled then b2.box.Filled = false end
    for _ = 1, tz do table.insert(b2.lines, az("Line")) end
    T.bundles[plr] = b2
    return b2
end

local function FF(b2)
    if b2.box then b2.box.Visible = false end
    if b2.name then b2.name.Visible = false end
    if b2.distance then b2.distance.Visible = false end
    if b2.item then b2.item.Visible = false end
    if b2.team then b2.team.Visible = false end
    if b2.tracer then b2.tracer.Visible = false end
    if b2.arrow then b2.arrow.Visible = false end
    for _, l in ipairs(b2.lines) do l.Visible = false end
    for _, l in ipairs(b2.box3dLines) do l.Visible = false end
end

local function uF(b2)
    FF(b2)
    if b2.highlight then b2.highlight.Enabled = false end
end

local function qF(b2)
    if not b2 then return end
    local function h(obj) if obj then pcall(function() obj:Remove() end) end end
    h(b2.box); h(b2.name); h(b2.distance); h(b2.item); h(b2.team)
    h(b2.tracer); h(b2.arrow)
    for _, l in ipairs(b2.lines) do h(l) end
    for _, l in ipairs(b2.box3dLines) do h(l) end
    if b2.highlight then pcall(function() b2.highlight:Destroy() end); b2.highlight = nil end
end

local function PF()
    for _, b2 in pairs(T.bundles) do uF(b2) end
end

local function zF(cam, pos)
    local s, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), onScreen, s.Z
end

local function oF(b2)
    if b2.tracer then return b2.tracer end
    b2.tracer = az("Line")
    if b2.tracer then
        if wz.thickness then b2.tracer.Thickness = 1.5 end
        b2.tracer.Color = b2.relationshipColor or Color3.fromRGB(170,70,255)
    end
    return b2.tracer
end

local function TF(b2)
    if b2.arrow then return b2.arrow end
    b2.arrow = az("Triangle")
    if b2.arrow then
        if wz.filled then b2.arrow.Filled = true end
        if wz.thickness then b2.arrow.Thickness = 1 end
        b2.arrow.Color = b2.relationshipColor or Color3.fromRGB(170,70,255)
    end
    return b2.arrow
end

local function fF(b2)
    if #b2.box3dLines > 0 then return b2.box3dLines end
    for _ = 1, #Kz do
        local l = az("Line")
        if l then
            if wz.thickness then l.Thickness = 1 end
            l.Color = b2.relationshipColor or Color3.fromRGB(170,70,255)
            table.insert(b2.box3dLines, l)
        end
    end
    return b2.box3dLines
end

local function RF(b2, char)
    local hl = b2.highlight
    if not hl or not hl.Parent then
        local ok, newHl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VeteranoESP_"..tostring(b2.player.UserId)
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 0.78; h.OutlineTransparency = 0
            h.Parent = workspace.CurrentCamera or workspace
            return h
        end)
        if not ok then return nil end
        hl = newHl; b2.highlight = hl
    elseif hl.Parent ~= (workspace.CurrentCamera or workspace) then
        hl.Parent = workspace.CurrentCamera or workspace
    end
    local col = b2.relationshipColor or Color3.fromRGB(170,70,255)
    hl.Adornee = char; hl.FillColor = col; hl.OutlineColor = col
    return hl
end

local function QF(b2, cam, screenPos, z)
    local arrow = TF(b2)
    if not arrow then return end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X*0.5, vp.Y*0.5)
    local dir = screenPos - center
    if z <= 0 then dir = -dir end
    if dir.Magnitude < 0.001 then dir = Vector2.new(0, -1) end
    local unit = dir.Unit
    local radius = math.max(40, math.min(vp.X, vp.Y)*0.42)
    local tip = center + unit*radius
    local back = tip - unit*14
    local perp = Vector2.new(-unit.Y, unit.X)*8
    arrow.PointA = tip; arrow.PointB = back + perp; arrow.PointC = back - perp
    arrow.Visible = true
end

local function VF(b2, char, hum, root)
    if b2.character == char and b2.humanoid == hum and b2.root == root then return end
    b2.character, b2.humanoid, b2.root = char, hum, root
    table.clear(b2.bodyParts); table.clear(b2.skeletonPairs)
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then table.insert(b2.bodyParts, p) end
    end
    local pairsList = (hum.RigType == Enum.HumanoidRigType.R15) and dz or Gz
    for _, pr in ipairs(pairsList) do
        table.insert(b2.skeletonPairs, {char:FindFirstChild(pr[1]), char:FindFirstChild(pr[2])})
    end
end

local function pF(plr)
    local t = plr.Team
    local name = t and t.Name or nil
    if Jz.Admin(plr) and name ~= "STAFF" then
        return name and ("STAFF | "..name) or "STAFF"
    end
    return name
end

local function IF(plr)
    local t = plr.Team
    local ok, col = pcall(function() return t.TeamColor.Color end)
    return (ok and col) or Color3.fromRGB(170,70,255)
end

local function OF(plr, b2)
    local col, suffix = Jz.Appearance(plr)
    b2.relationshipLabel = suffix
    if b2.relationshipColor == col then return end
    b2.relationshipColor = col
    if b2.box then b2.box.Color = col end
    if b2.name then b2.name.Color = col end
    if b2.distance then b2.distance.Color = col end
    if b2.item then b2.item.Color = col end
    if b2.tracer then b2.tracer.Color = col end
    if b2.arrow then b2.arrow.Color = col end
    if b2.highlight then
        b2.highlight.FillColor = col
        b2.highlight.OutlineColor = col
    end
    for _, l in ipairs(b2.lines) do if l then l.Color = col end end
    for _, l in ipairs(b2.box3dLines) do if l then l.Color = col end end
end

local function XF(plr, b2, cam, myPos, now)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or hum.Health <= 0 or not root then
        b2.character = nil
        b2.nextVisualUpdate = now + mF
        uF(b2); return
    end
    VF(b2, char, hum, root)
    local dist = (root.Position - myPos).Magnitude
    if dist > T.maxDistance then
        b2.nextVisualUpdate = now + mF
        uF(b2); return
    end
    OF(plr, b2)
    if T.highlight then
        local hl = RF(b2, char)
        if hl then hl.Enabled = true end
    elseif b2.highlight then b2.highlight.Enabled = false end
    local screenPos, onScreen, z = zF(cam, root.Position)
    if not onScreen or z <= 0 then
        b2.nextVisualUpdate = now + mF
        FF(b2)
        if T.arrow then QF(b2, cam, screenPos, z) end
        return
    end
    local close = dist <= CF
    local interval = close and YF or gF
    b2.nextVisualUpdate = HF(b2.nextVisualUpdate, now, interval)
    if b2.arrow then b2.arrow.Visible = false end
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyOnScreen = false
    local screenCorners, zCorners = {}, {}
    if T.box or T.name or T.distance or T.box3d or T.teamTag then
        local bbMin, bbMax
        for _, p in ipairs(b2.bodyParts) do
            if p.Parent == char then
                local half = p.Size*0.5
                local a, b2v = p.Position-half, p.Position+half
                if bbMin then
                    bbMin = Vector3.new(math.min(bbMin.X,a.X), math.min(bbMin.Y,a.Y), math.min(bbMin.Z,a.Z))
                    bbMax = Vector3.new(math.max(bbMax.X,b2v.X), math.max(bbMax.Y,b2v.Y), math.max(bbMax.Z,b2v.Z))
                else
                    bbMin, bbMax = a, b2v
                end
            end
        end
        if bbMin then
            local idx = 0
            for xi = 0, 1 do for yi = 0, 1 do for zi = 0, 1 do
                idx = idx + 1
                local corner = Vector3.new(xi==0 and bbMin.X or bbMax.X, yi==0 and bbMin.Y or bbMax.Y, zi==0 and bbMin.Z or bbMax.Z)
                local sp, onS, zc = zF(cam, corner)
                screenCorners[idx] = sp; zCorners[idx] = zc
                if zc > 0.5 then
                    anyOnScreen = true
                    minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
                end
            end end end
        end
        if anyOnScreen then
            local vp = cam.ViewportSize
            minX = math.clamp(minX, -32, vp.X+32); maxX = math.clamp(maxX, -32, vp.X+32)
            minY = math.clamp(minY, -32, vp.Y+32); maxY = math.clamp(maxY, -32, vp.Y+32)
            if maxX-minX < 1 or maxY-minY < 1 then anyOnScreen = false end
        end
    end
    if T.box and b2.box then
        if anyOnScreen then
            b2.box.Position = Vector2.new(minX, minY)
            b2.box.Size = Vector2.new(maxX-minX, maxY-minY)
            b2.box.Visible = true
        else b2.box.Visible = false end
    elseif b2.box then b2.box.Visible = false end
    if T.name and b2.name then
        if anyOnScreen then
            b2.name.Text = plr.Name..b2.relationshipLabel
            b2.name.Position = Vector2.new((minX+maxX)/2, minY-18)
            b2.name.Visible = true
        else b2.name.Visible = false end
    elseif b2.name then b2.name.Visible = false end
    if T.teamTag and b2.team then
        local teamName = anyOnScreen and pF(plr) or nil
        if teamName then
            b2.team.Text = teamName
            if Jz.Admin(plr) and plr.Team and plr.Team.Name == "STAFF" then
                b2.team.Color = YEL
            else b2.team.Color = IF(plr) end
            b2.team.Position = Vector2.new((minX+maxX)/2, (T.name and (b2.name and b2.name.Visible)) and (minY-32) or (minY-18))
            b2.team.Visible = true
        else b2.team.Visible = false end
    elseif b2.team then b2.team.Visible = false end
    if T.distance and b2.distance then
        if anyOnScreen then
            b2.distance.Text = string.format("%dm", math.floor(dist))
            if wz.center then b2.distance.Center = true end
            b2.distance.Position = Vector2.new((minX+maxX)/2, maxY+3)
            b2.distance.Visible = true
        else b2.distance.Visible = false end
    elseif b2.distance then b2.distance.Visible = false end
    if T.heldItem and b2.item then
        local c2 = b2.character or plr.Character
        local tool = anyOnScreen and (c2 and c2:FindFirstChildOfClass("Tool"))
        if tool then
            b2.item.Text = tool.Name
            local cx = (minX+maxX)/2
            if T.distance and (b2.distance and b2.distance.Visible) then
                local dw = larguraText(b2.distance); local iw = larguraText(b2.item)
                local startX = cx - ((dw+MF)+iw)/2
                if wz.center then b2.distance.Center = false end
                b2.distance.Position = Vector2.new(startX, maxY+3)
                if wz.center then b2.item.Center = false end
                b2.item.Position = Vector2.new((startX+dw)+MF, maxY+3)
            else
                if wz.center then b2.item.Center = true end
                b2.item.Position = Vector2.new(cx, maxY+3)
            end
            b2.item.Visible = true
        else b2.item.Visible = false end
    elseif b2.item then b2.item.Visible = false end
    if T.tracer then
        local tr = oF(b2)
        if tr then
            local vp = cam.ViewportSize
            tr.From = Vector2.new(vp.X*0.5, vp.Y-4)
            tr.To = anyOnScreen and Vector2.new((minX+maxX)*0.5, (minY+maxY)*0.5) or screenPos
            tr.Visible = true
        end
    elseif b2.tracer then b2.tracer.Visible = false end
    if T.box3d then
        local lines = fF(b2)
        for i, pr in ipairs(Kz) do
            local l = lines[i]
            local p1, p2 = screenCorners[pr[1]], screenCorners[pr[2]]
            local z1, z2 = zCorners[pr[1]], zCorners[pr[2]]
            if l and p1 and p2 and z1 and z2 and z1 > 0.5 and z2 > 0.5 then
                l.From = p1; l.To = p2; l.Visible = true
            elseif l then l.Visible = false end
        end
    else
        for _, l in ipairs(b2.box3dLines) do l.Visible = false end
    end
    if not T.skeleton then
        for _, l in ipairs(b2.lines) do l.Visible = false end
    elseif now >= b2.nextSkeletonUpdate then
        local interval = close and YF or gF
        b2.nextSkeletonUpdate = HF(b2.nextSkeletonUpdate, now, interval)
        for i, l in ipairs(b2.lines) do
            local pr = b2.skeletonPairs[i]
            if pr and l then
                local p1, p2 = pr[1], pr[2]
                if p1 and p2 and p1.Parent == char and p2.Parent == char then
                    local s1, on1, z1 = zF(cam, p1.Position)
                    local s2, on2, z2 = zF(cam, p2.Position)
                    if on1 and on2 and z1 > 0.5 and z2 > 0.5 then
                        l.From = s1; l.To = s2; l.Visible = true
                    else l.Visible = false end
                else l.Visible = false end
            elseif l then l.Visible = false end
        end
    end
end

handleReady(Players.PlayerRemoving:Connect(function(plr)
    local b2 = T.bundles[plr]
    if b2 then qF(b2); T.bundles[plr] = nil end
end))

local BF = false
handleReady(RunService.RenderStepped:Connect(function()
    if not T.espEnabled then
        if BF then PF() end
        BF = false; return
    end
    BF = true
    local cam = workspace.CurrentCamera
    if not cam then PF(); return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = root and root.Position or cam.CFrame.Position
    local list = Players:GetPlayers()
    local now = os.clock()
    local budget = EF
    for _, plr in ipairs(list) do
        if plr ~= LocalPlayer then
            local b2 = T.bundles[plr]
            if not b2 and budget > 0 then
                local ok, res = pcall(AF, plr)
                if ok then b2 = res elseif not o.espErro then o.espErro = tostring(res) end
                budget = budget - 1
            end
            if b2 and now >= b2.nextVisualUpdate then
                local ok, err = pcall(XF, plr, b2, cam, myPos, now)
                if not ok and not o.espErro then o.espErro = tostring(err) end
            end
        end
    end
end))

-- AIMBOT
local SF = {
    Cabeca = {"Head"},
    Tronco = {"Torso","UpperTorso","LowerTorso","HumanoidRootPart"},
}
local function eF(char)
    local list = SF[T.aimbotBodyPart] or SF.Cabeca
    for _, n in ipairs(list) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return char:FindFirstChild("Head")
end
local function temLinhaDeVisao(cam, target, char)
    local from = cam.CFrame.Position
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {LocalPlayer.Character, char, cam}
    local hit = workspace:Raycast(from, target.Position-from, rp)
    return hit == nil
end
local function getClosestTarget(cam, maxFov, maxDist)
    local myPos = cam.CFrame.Position
    local center = cam.ViewportSize/2
    local best, bestD = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not Jz.Protected(plr) then
            local char = plr.Character
            local part = char and eF(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 and (part.Position-myPos).Magnitude <= maxDist then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y)-center).Magnitude
                    if d <= maxFov and d < bestD then
                        if not T.aimbotWallCheck or temLinhaDeVisao(cam, part, char) then
                            best, bestD = part, d
                        end
                    end
                end
            end
        end
    end
    return best
end
local aimbotConnection = nil
local function aimbotLoop()
    if aimbotConnection then return end
    aimbotConnection = RunService.RenderStepped:Connect(function(dt)
        if not T.aimbotEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if T.aimbotMode == "Legit" then
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
        end
        local target = getClosestTarget(cam, T.aimbotFov, T.aimbotDistance)
        if not target then return end
        local myPos = cam.CFrame.Position
        local targetPos = target.Position
        if T.aimbotMode == "Rage" then
            cam.CFrame = CFrame.new(myPos, targetPos)
        else
            local currentLook = cam.CFrame.LookVector
            local desiredLook = (targetPos-myPos).Unit
            local smooth = math.clamp(T.aimbotSmoothness, 0.01, 1)
            local newLook = currentLook:Lerp(desiredLook, smooth*3)
            cam.CFrame = CFrame.new(myPos, myPos+newLook)
        end
    end)
end
local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- PERFECT LOCKPICK
local function bF()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local lp = pg:FindFirstChild("Lockpick")
    if not lp then return nil end
    local inner = lp:FindFirstChild("Lockpick") or lp
    if not inner or not inner.Visible then return nil end
    local bloco = inner:FindFirstChild("Bloco")
    local obj = inner:FindFirstChild("Objetivo")
    local btn = inner:FindFirstChild("Btn")
    if bloco and obj and btn and bloco.Visible and obj.Visible then
        return bloco, obj, btn
    end
    return nil
end
local function yF(bloco, obj)
    local bp, bs = bloco.AbsolutePosition, bloco.AbsoluteSize
    local op, os = obj.AbsolutePosition, obj.AbsoluteSize
    if bp.X+bs.X < op.X or bp.X > op.X+os.X then return false end
    local cy = bp.Y+bs.Y/2
    local m = os.Y*0.25
    return cy >= op.Y+m and cy <= op.Y+os.Y-m
end
local function xF(btn)
    if not btn then return end
    if type(getconnections) == "function" then
        local ok, conns = pcall(getconnections, btn.MouseButton1Click)
        if ok and type(conns) == "table" and #conns > 0 then
            for _, c2 in ipairs(conns) do
                if type(c2.Function) == "function" then
                    pcall(task.spawn, c2.Function)
                end
            end
            return
        end
    end
    if type(firesignal) == "function" then
        pcall(firesignal, btn.MouseButton1Click)
        return
    end
end
local cF, lF = 0.35, 0
handleReady(RunService.RenderStepped:Connect(function()
    if not T.perfectLockpick then return end
    local bloco, obj, btn = bF()
    if not bloco then return end
    if os.clock() - lF < cF then return end
    if not yF(bloco, obj) then
        pcall(function()
            obj.Position = UDim2.new(0.5, 0, bloco.Position.Y.Scale, bloco.Position.Y.Offset)
        end)
        return
    end
    lF = os.clock()
    xF(btn)
end))

-- COLETAR ITENS
local ZF, DF, rF, hF, jF, WF = 20, 14, 1.5, D, 18, 65
local function aF(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end
    return nil
end
local function dF(item)
    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt or not prompt.Enabled then return false end
    if type(fireproximityprompt) == "function" then return pcall(fireproximityprompt, prompt, 0) end
    return pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(0.15, prompt.HoldDuration+0.1))
        prompt:InputHoldEnd()
    end)
end

local function GF(target, checkDone)
    o.itemTeleportRunId = o.itemTeleportRunId + 1
    local runId = o.itemTeleportRunId
    local canTp = isUpdateInstancePropertiesEValid()
    local hadNoclip = T.noclipEnabled
    if not hadNoclip then T.noclipEnabled = true; pcall(Nz) end
    local reached = false
    local lastDir = Vector3.zero
    local function destinoExato()
        local yy = target.parte.Position.Y + (target.parte.Size.Y * 0.5) + 3
        return Vector3.new(target.parte.Position.X, yy, target.parte.Position.Z)
    end
    if canTp then
        local deadline = os.clock()+8
        while os.clock() < deadline do
            if o.destroyed or runId ~= o.itemTeleportRunId then break end
            if not target.item.Parent or not target.parte.Parent then reached = true; break end
            local root = isUpdatePlayerGetMagnitudeCValid()
            if not root then break end
            local dest = destinoExato()
            if (dest-root.Position).Magnitude <= 1 then reached = true; break end
            root.CFrame = CFrame.new(dest)
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.05)
        end
    end
    local root = isUpdatePlayerGetMagnitudeCValid()
    local dist0 = root and (target.parte.Position-root.Position).Magnitude or 0
    local dest = destinoExato()
    local maxY = math.max(root and root.Position.Y or dest.Y, dest.Y) + jF
    local spd = math.min(T.itemTeleportSpeed, l)
    local deadline = (os.clock()+20) + (dist0/math.max(spd,1))*2
    while not canTp and os.clock() < deadline do
        local dt = RunService.RenderStepped:Wait()
        if o.destroyed or runId ~= o.itemTeleportRunId then break end
        local item, part = target.item, target.parte
        if not item.Parent or not part.Parent then reached = true; break end
        local root2 = isUpdatePlayerGetMagnitudeCValid()
        if not root2 then break end
        dest = destinoExato()
        local flat = Vector3.new(dest.X-root2.Position.X, 0, dest.Z-root2.Position.Z)
        local waypoint = dest
        if flat.Magnitude > 4 then
            waypoint = root2.Position.Y < maxY-1
                and Vector3.new(root2.Position.X, maxY, root2.Position.Z)
                or Vector3.new(dest.X, maxY, dest.Z)
        end
        local delta = waypoint-root2.Position
        local mag = delta.Magnitude
        if (dest-root2.Position).Magnitude <= 2 then reached = true; break end
        local _, vel, phys, _, stable = handleQ(root2, dt, ZF, true)
        local spd2 = math.min(T.itemTeleportSpeed, stable and l or WF)
        local moveStep = math.min(mag, math.max(0, spd2-vel)*dt, phys)
        local dir = delta.Unit
        lastDir = dir
        if moveStep > 0 then root2.CFrame = root2.CFrame + dir*moveStep end
        root2.AssemblyLinearVelocity = dir*vel
        local hum = isCValid()
        if hum then pcall(hum.ChangeState, hum, Enum.HumanoidStateType.Freefall) end
    end
    local root3 = isUpdatePlayerGetMagnitudeCValid()
    local hum3 = isCValid()
    local flatDir = Vector3.new(lastDir.X, 0, lastDir.Z)
    if not canTp and root3 and hum3 then
        if flatDir.Magnitude <= 0 then
            local lv = root3.CFrame.LookVector
            flatDir = Vector3.new(lv.X, 0, lv.Z)
        end
        flatDir = flatDir.Magnitude > 0 and flatDir.Unit or Vector3.new(0,0,-1)
        local deadline2 = os.clock()+rF
        while os.clock() < deadline2 and (not o.destroyed and runId == o.itemTeleportRunId) do
            local dt = RunService.RenderStepped:Wait()
            local _, vel, _, moved, _ = handleQ(root3, dt, DF, true)
            if moved <= hF then break end
            local frac = math.clamp(vel/math.max(hum3.WalkSpeed,1), 0, 1)
            pcall(hum3.Move, hum3, flatDir*frac, false)
            root3.AssemblyLinearVelocity = flatDir*vel
        end
    end
    if root3 then root3.AssemblyLinearVelocity = Vector3.zero end
    if reached and runId == o.itemTeleportRunId then
        local rootF = isUpdatePlayerGetMagnitudeCValid()
        if rootF and target.parte and target.parte.Parent then
            local topoY = target.parte.Position.Y + (target.parte.Size.Y * 0.5) + 3
            rootF.CFrame = CFrame.new(target.parte.Position.X, topoY, target.parte.Position.Z)
            rootF.AssemblyLinearVelocity = Vector3.zero
            rootF.AssemblyAngularVelocity = Vector3.zero
        end
    end
    if reached and runId == o.itemTeleportRunId then
        local doneCheck = checkDone or function() return not target.item.Parent end
        for _ = 1, 5, 1 do
            if doneCheck() then break end
            dF(target.item)
            task.wait(0.15)
        end
    end
    if not hadNoclip and runId == o.itemTeleportRunId then
        T.noclipEnabled = false; pcall(Nz)
    end
    return reached
end

o.coletarItem = GF

o.listDrops = function()
    local out = {}
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return out end
    local pastas = {"DropadosInv","Drops","ItensDropados","ItensNoChao","ItemsDrop","DropsInv"}
    local vistos = {}
    local found = false
    for _, nome in ipairs(pastas) do
        local folder = workspace:FindFirstChild(nome)
        if folder then
            found = true
            for _, obj in ipairs(folder:GetChildren()) do
                if not vistos[obj] then
                    vistos[obj] = true
                    local part = aF(obj)
                    if part then
                        table.insert(out, {
                            item = obj, parte = part, nome = obj.Name,
                            distancia = (root.Position - part.Position).Magnitude,
                        })
                    end
                end
            end
        end
    end
    if not found then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not vistos[obj] and obj:IsA("BasePart") then
                local isChar = LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)
                if not isChar then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        vistos[obj] = true
                        table.insert(out, {
                            item = obj, parte = obj, nome = obj.Name,
                            distancia = (root.Position - obj.Position).Magnitude,
                        })
                    end
                end
            end
        end
    end
    table.sort(out, function(a,b) return a.distancia < b.distancia end)
    return out
end

do
    local coleta = {runId = 0}
    local function startAutoColeta()
        if T.autoColetaEnabled then return end
        T.autoColetaEnabled = true
        coleta.runId = coleta.runId + 1
        local myId = coleta.runId
        task.spawn(function()
            while T.autoColetaEnabled and not o.destroyed and myId == coleta.runId do
                local drops = o.listDrops and o.listDrops() or {}
                local alvo = drops[1]
                if alvo and alvo.item.Parent then pcall(GF, alvo) end
                task.wait(math.max(0.1, T.autoColetaCooldown * 0.5))
            end
        end)
    end
    local function stopAutoColeta()
        T.autoColetaEnabled = false
        coleta.runId = coleta.runId + 1
    end
    o.startAutoColeta = startAutoColeta
    o.stopAutoColeta = stopAutoColeta
end

-- COLETOR DE ARMAS ESPECÍFICAS
local ARMAS_PERMITIDAS = {
    "AK47", "FAL", "Fuzil", "Glock", "Oitão", "Submetralhadora", "USPs", "Uzi",
    "Barret", "FuzilHollow", "FuzilPhantom", "FuzilTrovão", "G3", "PtDragon", "PtNeon", "PtNK",
    "ArmaPDSecreta", "FuzilNinja", "FuzilPascoa", "Natalina", "PtNinja", "PtPascoa"
}

local function armaPermitida(nome)
    for _, arma in ipairs(ARMAS_PERMITIDAS) do
        if nome == arma then return true end
    end
    return false
end

local function encontrarArmas()
    local armasEncontradas = {}
    local pastas = {"FarmPartesDeArma", "Armas", "ArmasDropadas", "DropadosInv", "Drops", "ItensDropados"}
    for _, pastaNome in ipairs(pastas) do
        local pasta = workspace:FindFirstChild(pastaNome)
        if pasta then
            for _, item in ipairs(pasta:GetChildren()) do
                if armaPermitida(item.Name) then table.insert(armasEncontradas, item) end
            end
        end
    end
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and armaPermitida(item.Name) then
            local isOwned = false
            if LocalPlayer.Character and item:IsDescendantOf(LocalPlayer.Character) then isOwned = true end
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack and item:IsDescendantOf(backpack) then isOwned = true end
            if not isOwned then table.insert(armasEncontradas, item) end
        end
    end
    return armasEncontradas
end

local function teleportarParaArma(arma)
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return false end
    local parte = arma
    if arma:IsA("Model") then
        parte = arma.PrimaryPart or arma:FindFirstChildWhichIsA("BasePart")
    end
    if not parte then return false end
    root.CFrame = CFrame.new(parte.Position + Vector3.new(0, 3, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.5)
    return true
end

local function pegarArma(arma)
    local prompt = arma:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then prompt = arma:FindFirstChildWhichIsA("ProximityPrompt", true) end
    if prompt and prompt.Enabled then
        if type(fireproximityprompt) == "function" then
            pcall(fireproximityprompt, prompt, 0)
        else
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(math.max(0.15, prompt.HoldDuration+0.1))
                prompt:InputHoldEnd()
            end)
        end
        return true
    end
    if arma:IsA("Tool") then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                arma.Parent = LocalPlayer.Backpack
                return true
            end
        end
    end
    return false
end

local function voltarParaPosicao()
    task.wait(1)
    local character = LocalPlayer.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = T.coletorArmasReturnPos
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            return true
        end
    end
    return false
end

local function coletarArmasEspecificas()
    T.coletorArmasAtivo = true
    local armas = encontrarArmas()
    local coletadas = 0
    if #armas == 0 then T.coletorArmasAtivo = false; return 0 end
    local hadNoclip = T.noclipEnabled
    if not hadNoclip then T.noclipEnabled = true; pcall(Nz) end
    for _, arma in ipairs(armas) do
        if o.destroyed then break end
        if arma and arma.Parent then
            if teleportarParaArma(arma) then
                if pegarArma(arma) then
                    coletadas = coletadas + 1
                    task.wait(0.5)
                end
            end
        end
    end
    if not hadNoclip then T.noclipEnabled = false; pcall(Nz) end
    voltarParaPosicao()
    T.coletorArmasAtivo = false
    return coletadas
end

o.coletarArmasEspecificas = coletarArmasEspecificas

-- AUTO FARM PARTES DE ARMA
do
    local function tF()
        local folder = workspace:FindFirstChild("FarmPartesDeArma")
        folder = folder and folder:FindFirstChild("Locais")
        if not folder then return nil end
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("BasePart") and obj:FindFirstChild("GUI") then return obj end
        end
        local root = isUpdatePlayerGetMagnitudeCValid()
        if not root then return nil end
        local best, bestD
        for _, obj in ipairs(folder:GetChildren()) do
            local prompt = obj:IsA("BasePart") and obj:FindFirstChild("Interagir")
            if prompt and prompt.Enabled then
                local d = (root.Position-obj.Position).Magnitude
                if not bestD or d < bestD then best, bestD = obj, d end
            end
        end
        return best
    end

    local function KF()
        o.farmPartesRunId = o.farmPartesRunId + 1
        T.farmPartesEnabled = false
    end

    local Cf = 15
    local function Yf()
        if T.flyEnabled then T.flyEnabled = false; pcall(xz) end
        o.farmPartesRunId = o.farmPartesRunId + 1
        local runId = o.farmPartesRunId
        local count = 0
        local hadNoclip = T.noclipEnabled
        if not hadNoclip then T.noclipEnabled = true; pcall(Nz) end
        while T.farmPartesEnabled and (not o.destroyed and runId == o.farmPartesRunId) do
            local alvo = tF()
            if not alvo then
                task.wait(1)
            else
                local target = alvo
                local reached = GF({item=target, parte=target}, function() return tF() ~= target end)
                if runId ~= o.farmPartesRunId then break end
                local moved = reached and tF() ~= target
                if moved then count = count+1 end
                local wait = moved and Cf or 1
                local deadline = os.clock()+wait
                while os.clock() < deadline do
                    if not T.farmPartesEnabled or o.destroyed or runId ~= o.farmPartesRunId then break end
                    task.wait(0.2)
                end
            end
        end
        if runId == o.farmPartesRunId then
            T.farmPartesEnabled = false
            o.farmPartesColetadas = count
        end
        if not hadNoclip and (not T.farmPartesEnabled or runId == o.farmPartesRunId) then
            T.noclipEnabled = false
            pcall(Nz)
        end
        return count
    end

    o.iniciarFarmPartes = Yf
    o.pararFarmPartes = KF
end

-- WEAPONS + TRACER COR
do
    local tracerColors = {
        {"Ciano", Color3.fromRGB(0,255,255)},
        {"Verde", Color3.fromRGB(60,255,90)},
        {"Rosa", Color3.fromRGB(255,60,190)},
        {"Roxo", Color3.fromRGB(160,70,255)},
        {"Vermelho", Color3.fromRGB(255,45,45)},
        {"Azul", Color3.fromRGB(70,130,255)},
        {"Laranja", Color3.fromRGB(255,145,30)},
        {"Branco", Color3.fromRGB(240,240,240)},
        {"Amarelo", Color3.fromRGB(255,230,60)},
        {"VerdeLimao", Color3.fromRGB(180,255,0)},
        {"Magenta", Color3.fromRGB(255,0,200)},
        {"Turquesa", Color3.fromRGB(0,200,180)},
        {"Arco-iris", nil},
    }
    local corBalaOriginal = nil

    local function getCorBala()
        local C = LocalPlayer:FindFirstChild("OrpheusGunCFG")
        local Y = C and C:FindFirstChild("CorBala")
        if Y and corBalaOriginal == nil then corBalaOriginal = Y.Color end
        return Y
    end

    local function aplicarCorBala()
        local cor = getCorBala()
        if not cor then return end
        if not T.armaTracer then
            if corBalaOriginal then pcall(function() cor.Color = corBalaOriginal end) end
            return
        end
        if T.armaTracerCor == "Arco-iris" then
            cor.Color = Color3.fromHSV((os.clock()*0.25) % 1, 1, 1)
            return
        end
        for _, g in ipairs(tracerColors) do
            if g[1] == T.armaTracerCor and g[2] then
                cor.Color = g[2]
                return
            end
        end
    end

    o.restaurarArmas = function()
        pcall(aplicarCorBala)
        local cor = getCorBala()
        if cor and corBalaOriginal then pcall(function() cor.Color = corBalaOriginal end) end
    end

    handleReady(RunService.RenderStepped:Connect(function()
        if o.destroyed then return end
        if not T.armaTracer then return end
        pcall(aplicarCorBala)
    end))
end

-- GACHA 2%
do
    local RS = game:GetService("ReplicatedStorage")
    local CHANCE_MINIMA = 0.02
    local MULTIPLICADOR = 3
    local ARMAS_RARAS = {
        Natalina=true, PtNinja=true, PtPaschoa=true,
        FuzilPaschoa=true, FuzilNinja=true, ArmaPDSecreta=true,
        Barret=true, FuzilTrovao=true, FuzilPhantom=true,
    }
    local hooked = false
    local originalData = {}
    local function snapshot(t, seen)
        seen = seen or {}
        if seen[t] then return seen[t] end
        local copy = {}
        seen[t] = copy
        for k, v in pairs(t) do
            if type(v)=="table" then copy[k] = snapshot(v, seen)
            else copy[k] = v end
        end
        return copy
    end
    local function ehRara(nome)
        if not nome then return false end
        nome = tostring(nome)
        if ARMAS_RARAS[nome] then return true end
        local low = string.lower(nome)
        if string.find(low, "ninja") or string.find(low, "paschoa") or string.find(low, "secreta")
            or string.find(low, "trovao") or string.find(low, "phantom") or string.find(low, "barret")
            or string.find(low, "natalina") then return true end
        return false
    end
    local function reescreverChances(tbl, depth)
        depth = depth or 0
        if depth > 12 then return end
        for k, v in pairs(tbl) do
            if type(v)=="table" then
                local nome = v.Nome or v.nome or v.Name or v.name or k
                local eraRara = ehRara(nome)
                for _, field in ipairs({"Chance","chance","Weight","weight","Probabilidade",
                                         "probabilidade","Rate","rate","DropChance","dropChance"}) do
                    if type(v[field])=="number" and v[field] > 0 then
                        if eraRara then v[field] = CHANCE_MINIMA
                        else
                            if v[field] < CHANCE_MINIMA then v[field] = CHANCE_MINIMA
                            else v[field] = v[field] * MULTIPLICADOR end
                        end
                    end
                end
                reescreverChances(v, depth+1)
            end
        end
    end
    local function aplicarGacha()
        if hooked then return end
        hooked = true
        local function scanMods(container, depth)
            if depth > 6 then return end
            for _, mod in ipairs(container:GetChildren()) do
                if mod:IsA("ModuleScript") then
                    local n = string.lower(mod.Name)
                    if string.find(n, "gacha") or string.find(n, "roleta")
                        or string.find(n, "sorteio") or string.find(n, "spin")
                        or string.find(n, "crate") or string.find(n, "caixa")
                        or string.find(n, "loot") or string.find(n, "premi")
                        or string.find(n, "reward") or string.find(n, "raridade") then
                        local ok, data = pcall(require, mod)
                        if ok and type(data)=="table" then
                            if not originalData[mod] then originalData[mod] = snapshot(data) end
                            pcall(reescreverChances, data, 0)
                        end
                    end
                end
                scanMods(mod, depth+1)
            end
        end
        scanMods(RS, 0)
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then scanMods(ps, 0) end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then scanMods(pg, 0) end
    end
    local function restaurarGacha()
        for mod, snap in pairs(originalData) do
            pcall(function()
                local ok, data = pcall(require, mod)
                if ok and type(data)=="table" then
                    for k, v in pairs(snap) do
                        if type(v)=="table" then data[k] = snapshot(v)
                        else data[k] = v end
                    end
                end
            end)
        end
        originalData = {}
        hooked = false
    end
    o.aplicarGacha = aplicarGacha
    o.restaurarGacha = restaurarGacha
    task.spawn(function()
        task.wait(2)
        pcall(aplicarGacha)
    end)
    local ultimoEstado = false
    handleReady(RunService.Heartbeat:Connect(function()
        if o.destroyed then return end
        if T.sorte2xEnabled and not ultimoEstado then pcall(aplicarGacha)
        elseif not T.sorte2xEnabled and ultimoEstado then pcall(restaurarGacha) end
        ultimoEstado = T.sorte2xEnabled
    end))
end

-- AUTO FARM PESCA
do
    local PESCA_TP = Vector3.new(-1165, -33, -5055)
    local function getCharacter()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        return character, humanoid, root
    end
    local function isRun(runId)
        return T.autoFarmPescaEnabled and (not o.destroyed and o.pescaRunId == runId)
    end
    local function firePrompt(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return false end
        return pcall(function()
            prompt:InputHoldBegin()
            task.wait(math.max(prompt.HoldDuration, 0.1))
            prompt:InputHoldEnd()
        end)
    end
    local function destroyWorldParts()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "Terrain" then
                local isOwnCharacter = LocalPlayer.Character and v:IsDescendantOf(LocalPlayer.Character)
                local hasPrompt = v:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
                if not isOwnCharacter and not hasPrompt then pcall(function() v:Destroy() end) end
            end
        end
    end
    local function farmLoop(session)
        if T.autoFarmPescaEnabled and session == o.pescaRunId then destroyWorldParts() end
        while isRun(session) do
            local farmChar, hum, root = getCharacter()
            if root then
                root.CFrame = CFrame.new(PESCA_TP)
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptParent = prompt.Parent
                        if promptParent and promptParent:IsA("BasePart") then
                            local promptDistance = (promptParent.Position - root.Position).Magnitude
                            if promptDistance <= (prompt.MaxActivationDistance + 10) then firePrompt(prompt) end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end
    local function setFarmEnabled(enabled)
        T.autoFarmPescaEnabled = enabled
        o.pescaRunId = o.pescaRunId + 1
        local session = o.pescaRunId
        if enabled then task.spawn(function() pcall(farmLoop, session) end) end
    end
    o.startPesca = setFarmEnabled
end

-- DURABILIDADE HUD
do
    local MAX = 1500
    local green = Color3.fromRGB(70,190,120)
    local yellow = Color3.fromRGB(232,190,70)
    local red = Color3.fromRGB(232,92,84)
    local bg = Color3.fromRGB(22,14,34)
    local border = Color3.fromRGB(70,45,110)
    local track = Color3.fromRGB(40,26,60)
    local textCol = Color3.fromRGB(240,230,255)
    local muted = Color3.fromRGB(170,140,210)
    local fontName = "rbxasset://fonts/families/Nunito.json"
    local boldFont = Font.new(fontName, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    local regFont = Font.new(fontName, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    local W, Hh = 208, 64
    local O = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local S = {
        gui=nil, frame=nil, fill=nil, percentLabel=nil, valueLabel=nil,
        carLabel=nil, uiScale=nil, vidaConn=nil, car=nil,
        maxVida=MAX, savedPosition=nil, painel=nil,
    }
    o.durHUD = S
    local function mk(kind, props, parent)
        local obj = Instance.new(kind)
        for k, v in pairs(props) do obj[k] = v end
        obj.Parent = parent
        return obj
    end
    local function getParent() return LocalPlayer:WaitForChild("PlayerGui") end
    local function colorFor(pct)
        if pct <= 20 then return red end
        if pct <= 50 then return yellow end
        return green
    end
    local function vpSize()
        local cam = workspace.CurrentCamera
        return cam and cam.ViewportSize or Vector2.new(800,600)
    end
    local function updateScale()
        if not S.uiScale then return end
        local vp = vpSize()
        S.uiScale.Scale = math.clamp(vp.X/1280, 0.85, 1.1)
    end
    local function defaultPos()
        local vp = vpSize()
        local yy = math.max(40, (vp.Y-Hh)-150)
        return UDim2.fromOffset(14, yy)
    end
    local function setVal(v)
        if not S.frame then return end
        if v > S.maxVida then S.maxVida = v end
        local pct = math.clamp((v/S.maxVida)*100, 0, 100)
        local col = colorFor(pct)
        S.percentLabel.Text = string.format("%d%%", math.floor(pct+0.5))
        S.percentLabel.TextColor3 = col
        S.valueLabel.Text = string.format("%d / %d", math.floor(v+0.5), math.floor(S.maxVida+0.5))
        TweenService:Create(S.fill, O, {Size=UDim2.new(pct/100,0,1,0), BackgroundColor3=col}):Play()
    end
    local function create()
        if S.gui and S.gui.Parent then return end
        local gui = mk("ScreenGui", {
            Name="VeteranoDurabilidade", ResetOnSpawn=false,
            IgnoreGuiInset=true, DisplayOrder=9999,
            ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        }, getParent())
        local frame = mk("Frame", {
            Name="HUD", Active=true, AnchorPoint=Vector2.new(0,0),
            Position=S.savedPosition or defaultPos(),
            Size=UDim2.fromOffset(W, Hh),
            BackgroundColor3=bg, BackgroundTransparency=0.08,
            BorderSizePixel=0, Visible=false,
        }, gui)
        S.uiScale = mk("UIScale", {Scale=1}, frame)
        mk("UICorner", {CornerRadius=UDim.new(0,10)}, frame)
        mk("UIStroke", {Color=border, Transparency=0.2, Thickness=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, frame)
        mk("UIPadding", {
            PaddingTop=UDim.new(0,9), PaddingBottom=UDim.new(0,9),
            PaddingLeft=UDim.new(0,11), PaddingRight=UDim.new(0,11),
        }, frame)
        S.carLabel = mk("TextLabel", {
            Name="Carro", Position=UDim2.fromOffset(0,0),
            Size=UDim2.new(1,-46,0,15), BackgroundTransparency=1,
            Text="Veiculo", TextColor3=textCol, TextSize=14,
            FontFace=boldFont, TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd,
        }, frame)
        S.percentLabel = mk("TextLabel", {
            Name="Percent", AnchorPoint=Vector2.new(1,0),
            Position=UDim2.new(1,0,0,0), Size=UDim2.fromOffset(46,15),
            BackgroundTransparency=1, Text="--%", TextColor3=green,
            TextSize=15, FontFace=boldFont,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, frame)
        local bar = mk("Frame", {
            Name="Barra", Position=UDim2.fromOffset(0,24),
            Size=UDim2.new(1,0,0,9), BackgroundColor3=track,
            BorderSizePixel=0, ClipsDescendants=true,
        }, frame)
        mk("UICorner", {CornerRadius=UDim.new(1,0)}, bar)
        S.fill = mk("Frame", {Name="Fill", Size=UDim2.new(1,0,1,0), BackgroundColor3=green, BorderSizePixel=0}, bar)
        mk("UICorner", {CornerRadius=UDim.new(1,0)}, S.fill)
        S.valueLabel = mk("TextLabel", {
            Name="Valor", Position=UDim2.fromOffset(0,37),
            Size=UDim2.new(1,0,0,12), BackgroundTransparency=1,
            Text="-- / --", TextColor3=muted, TextSize=12,
            FontFace=regFont, TextXAlignment=Enum.TextXAlignment.Left,
        }, frame)
        S.gui = gui; S.frame = frame
        updateScale()
        handleReady((workspace:GetPropertyChangedSignal("CurrentCamera")):Connect(function()
            updateScale()
            local cam = workspace.CurrentCamera
            if cam then handleReady((cam:GetPropertyChangedSignal("ViewportSize")):Connect(updateScale)) end
        end))
        local cam = workspace.CurrentCamera
        if cam then handleReady((cam:GetPropertyChangedSignal("ViewportSize")):Connect(updateScale)) end
        updateInstancePropertiesPosition(frame, nil, function(pos) S.savedPosition = pos end)
    end
    local function vidaDoCarro(car)
        local body = car:FindFirstChild("Body")
        local paint = body and body:FindFirstChild("Pintura")
        local life = paint and paint:FindFirstChild("LifeController")
        return life and life:FindFirstChild("Vida")
    end
    o.vidaDoCarro = vidaDoCarro
    local function getMeuCarro()
        local hum = isCValid()
        local seat = hum and hum.SeatPart
        if not seat then return nil end
        local carros = workspace:FindFirstChild("CarrosSpawnados")
        if not carros then return nil end
        local p = seat
        while p and p.Parent do
            if p.Parent == carros then return p end
            p = p.Parent
        end
        return nil
    end
    local function desconectar()
        if S.vidaConn then S.vidaConn:Disconnect(); S.vidaConn = nil end
        S.car = nil
        if S.painel then S.painel:SetVisible(false) end
    end
    local function conectar(car)
        local vida = vidaDoCarro(car)
        if not vida then return end
        if S.vidaConn then S.vidaConn:Disconnect() end
        S.car = car
        S.maxVida = math.max(MAX, vida.Value)
        if S.carLabel then S.carLabel.Text = car.Name end
        if S.painel then S.painel:SetVisible(true) end
        setVal(vida.Value)
        S.vidaConn = vida:GetPropertyChangedSignal("Value"):Connect(function() setVal(vida.Value) end)
    end
    function o.ativarDurabilidade()
        create()
        o.durabilidadeRunId = o.durabilidadeRunId + 1
        local runId = o.durabilidadeRunId
        task.spawn(function()
            while T.durabilidadeHudEnabled and (not o.destroyed and o.durabilidadeRunId == runId) do
                local car = getMeuCarro()
                if car ~= S.car then
                    if car and vidaDoCarro(car) then pcall(conectar, car)
                    else pcall(desconectar) end
                elseif car and not S.vidaConn then pcall(conectar, car) end
                task.wait(0.3)
            end
        end)
    end
    function o.desativarDurabilidade()
        o.durabilidadeRunId = o.durabilidadeRunId + 1
        pcall(desconectar)
        if S.painel then S.painel:SetVisible(false) end
    end
    function o.destruirDurabilidade()
        pcall(desconectar)
        if S.gui then pcall(function() S.gui:Destroy() end) end
        S.gui, S.frame, S.fill, S.painel = nil, nil, nil, nil
    end
end

-- AUTO FARM LIXEIRO
do
    local P2 = 10
    local function getTeam() return LocalPlayer.Team and LocalPlayer.Team.Name or nil end
    local function getLevel()
        local ns = LocalPlayer:FindFirstChild("NewStats")
        local lv = ns and ns:FindFirstChild("Level")
        return lv and tonumber(lv.Value) or 0
    end
    local function getEmpregos()
        local ok, mod = pcall(function() return require((game:GetService("ReplicatedStorage")).Mercadinho.PrefModule) end)
        if not ok or type(mod) ~= "table" or type(mod.Empregos) ~= "table" then return {} end
        local list = {}
        for name, data in pairs(mod.Empregos) do
            table.insert(list, {nome=name, level=tonumber(data.Level) or 0, salario=tonumber(data.Salario) or 0})
        end
        table.sort(list, function(a, b2)
            if a.level == b2.level then return a.nome < b2.nome end
            return a.level < b2.level
        end)
        return list
    end
    local function getLixoCount()
        local inv = LocalPlayer:FindFirstChild("Inv")
        local count = 0
        if inv then
            for _, v in ipairs(inv:GetChildren()) do
                if v.Name == "Saco de Lixo" then count = count+1 end
            end
        end
        return count
    end
    local function getMoneySafe()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        local d = ls and ls:FindFirstChild("Dinheiro")
        return d and tonumber(d.Value) or nil
    end
    local function getLixeiroEmp()
        for _, e in ipairs(getEmpregos()) do
            if string.lower(e.nome) == "lixeiro" then return e end
        end
        return {nome="Lixeiro", level=1, salario=0}
    end
    local function setFarmStatus(msg) o.garbageFarmStatus = tostring(msg or "") end
    local function isRun(runId) return T.autoFarmLixeiroEnabled and (not o.destroyed and o.garbageFarmRunId == runId) end
    local function wait2(t, runId)
        local deadline = os.clock()+math.max(0, t or 0)
        repeat
            if not isRun(runId) then return false end
            task.wait(math.min(0.1, math.max(0.01, deadline-os.clock())))
        until os.clock() >= deadline
        return isRun(runId)
    end
    local function handleIsValid()
        local char = LocalPlayer.Character
        return char, char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
    end
    local function sendJobSelect(remote, emp)
        remote:FireServer(emp.nome, emp.level, true)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local lx = pg and pg:FindFirstChild("LixeiroUI")
        local frame = lx and lx:FindFirstChild("LixeiroFrame")
        if frame and frame.Visible then frame.Visible = false end
    end
    local function trySelectLixeiro(runId)
        if getTeam() == "Lixeiro" then return true end
        local merc = (game:GetService("ReplicatedStorage")):FindFirstChild("Mercadinho")
        local remote = merc and merc:FindFirstChild("PrefRemote")
        if not remote or not remote:IsA("RemoteEvent") then
            setFarmStatus("PrefRemote nao encontrado")
            return false
        end
        local emp = getLixeiroEmp()
        if getLevel() < emp.level then return false end
        setFarmStatus("Selecionando lixeiro...")
        remote:FireServer(emp.nome, emp.level)
        wait2(0.25, runId)
        if not isRun(runId) then return false end
        sendJobSelect(remote, emp)
        local deadline = os.clock()+P2
        repeat
            if not isRun(runId) then return false end
            if getTeam() == "Lixeiro" then
                wait2(1.2, runId)
                return true
            end
            task.wait(0.15)
        until os.clock() >= deadline
        return false
    end
    local function isLixoPart(part, prompt)
        return part and part.Parent and part:IsA("BasePart") and part.Name == "Lixo"
            and part.Transparency < 0.95
            and (prompt and prompt.Parent == part and prompt:IsA("ProximityPrompt") and prompt.Enabled)
    end
    local function scanLixos()
        local char, hum, root = handleIsValid()
        local folder = workspace:FindFirstChild("Lixeiro")
        local list = {}
        if not root or not folder then return list end
        for _, part in ipairs(folder:GetChildren()) do
            local prompt = part:FindFirstChild("PegarLixo")
            if isLixoPart(part, prompt) then
                table.insert(list, {parte=part, prompt=prompt, posicao=part.Position, distancia=(part.Position-root.Position).Magnitude})
            end
        end
        table.sort(list, function(a, b3) return a.distancia < b3.distancia end)
        return list
    end
    local function inRange(root, part, prompt)
        if not root or not part or not part.Parent then return false end
        local maxD = prompt and math.max(2.5, prompt.MaxActivationDistance-0.65) or 4.25
        return (root.Position-part.Position).Magnitude <= maxD
    end
    local function walkTo(part, prompt, runId)
        local char, hum, root = handleIsValid()
        if not char or not hum or not root or hum.Health <= 0 then return false end
        if inRange(root, part, prompt) then return true end
        for attempt = 1, 4, 1 do
            if not isRun(runId) or not part.Parent then return false end
            char, hum, root = handleIsValid()
            if not char or not hum or not root or hum.Health <= 0 then return false end
            if inRange(root, part, prompt) then return true end
            local maxD = prompt and math.max(2.5, prompt.MaxActivationDistance-0.8) or 4
            local flat = Vector3.new(root.Position.X-part.Position.X, 0, root.Position.Z-part.Position.Z)
            local dir = flat.Magnitude > 0.1 and flat.Unit or Vector3.new(0,0,1)
            local radius = math.max(part.Size.X, part.Size.Z)*0.5
            local safe = math.clamp(radius+1.25, 1.25, math.max(1.25, maxD-0.35))
            local goal = part.Position + dir*safe
            local path = PathfindingService:CreatePath({
                AgentRadius=2, AgentHeight=5, AgentCanJump=true,
                AgentCanClimb=true, WaypointSpacing=5,
            })
            local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
            local waypoints = ok and (path.Status == Enum.PathStatus.Success and path:GetWaypoints())
                or {{Position=goal, Action=Enum.PathWaypointAction.Walk}}
            local idx = 0
            local blocked = false
            local blockConn = path.Blocked:Connect(function(wp) if wp <= idx+1 then blocked = true end end)
            for i, wp in ipairs(waypoints) do
                idx = i
                if not isRun(runId) or blocked then break end
                char, hum, root = handleIsValid()
                if not char or not hum or not root or hum.Health <= 0 then break end
                if inRange(root, part, prompt) then blockConn:Disconnect(); return true end
                if wp.Action == Enum.PathWaypointAction.Jump then
                    hum.Jump = true
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
                hum:MoveTo(wp.Position)
                local last = root.Position
                local lastMove = os.clock()
                local lastJump = 0
                local deadline = os.clock()+8
                repeat
                    RunService.Heartbeat:Wait()
                    if not isRun(runId) then blockConn:Disconnect(); return false end
                    char, hum, root = handleIsValid()
                    if not char or not hum or not root then break end
                    if inRange(root, part, prompt) then blockConn:Disconnect(); return true end
                    local now = os.clock()
                    if (root.Position-last).Magnitude >= 0.8 then
                        last = root.Position
                        lastMove = now
                    elseif now-lastMove >= 1.25 and now-lastJump >= 1 then
                        lastJump = now
                        hum.Jump = true
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                        hum:MoveTo(wp.Position)
                    end
                    if now-lastMove >= 3 then blocked = true end
                until blocked or os.clock() >= deadline or (root.Position-wp.Position).Magnitude <= 3
            end
            blockConn:Disconnect()
            char, hum, root = handleIsValid()
            if root and inRange(root, part, prompt) then return true end
            wait2(0.2, runId)
        end
        return false
    end
    local function firePrompt(prompt, force)
        if not prompt or not prompt.Parent or not prompt.Enabled then return false end
        if not force and type(fireproximityprompt) == "function" then
            return pcall(fireproximityprompt, prompt, 0)
        end
        return pcall(function()
            prompt:InputHoldBegin()
            task.wait(math.max(0.15, prompt.HoldDuration+0.1))
            prompt:InputHoldEnd()
        end)
    end
    local function collectOne(part, prompt, runId)
        local before = getLixoCount()
        for attempt = 1, 3, 1 do
            if not isRun(runId) or not isLixoPart(part, prompt) then
                return not part.Parent or part.Transparency >= 0.95
            end
            local _, _, root = handleIsValid()
            if not inRange(root, part, prompt) then return false end
            firePrompt(prompt, attempt > 1)
            local deadline = os.clock()+2.75
            repeat
                if not isRun(runId) then return false end
                if not part.Parent or part.Transparency >= 0.95 or getLixoCount() > before then return true end
                task.wait(0.1)
            until os.clock() >= deadline
        end
        return false
    end
    local function findDelivery()
        local folder = workspace:FindFirstChild("EntregaLixo")
        local lixeira = folder and folder:FindFirstChild("Lixeira")
        local prompt = lixeira and lixeira:FindFirstChild("EntregarLixo")
        if lixeira and lixeira:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt") then
            return lixeira, prompt
        end
        return nil, nil
    end
    local function deliverLixos(count, runId)
        local part, prompt = findDelivery()
        if not part or not prompt then return false end
        setFarmStatus(string.format("%d/%d coletados; indo entregar...", count, count))
        if not walkTo(part, prompt, runId) then
            if not isRun(runId) then return false end
            return false
        end
        local beforeCount = getLixoCount()
        local beforeMoney = getMoneySafe()
        for attempt = 1, 3, 1 do
            if not isRun(runId) then return false end
            firePrompt(prompt, attempt > 1)
            local deadline = os.clock()+4
            repeat
                if not isRun(runId) then return false end
                local nowCount = getLixoCount()
                local nowMoney = getMoneySafe()
                if (beforeCount > 0 and nowCount < beforeCount) or (beforeMoney and nowMoney and nowMoney > beforeMoney) then
                    return true
                end
                task.wait(0.15)
            until os.clock() >= deadline
        end
        return false
    end
    local function farmLoop(runId)
        while isRun(runId) do
            if not trySelectLixeiro(runId) then
                wait2(2, runId)
            else
                local goal = math.clamp(math.floor(tonumber(T.autoFarmLixeiroQuantidade) or 20), 1, 20)
                local collected = 0
                while isRun(runId) and (getTeam() == "Lixeiro" and collected < goal) do
                    local list = scanLixos()
                    if #list == 0 then
                        setFarmStatus(string.format("Coletados %d/%d; aguardando...", collected, goal))
                        wait2(1.25, runId)
                    else
                        local target = list[1]
                        if walkTo(target.parte, target.prompt, runId) then
                            if collectOne(target.parte, target.prompt, runId) then
                                collected = collected + 1
                                wait2(0.45, runId)
                            else
                                if not isRun(runId) then break end
                                wait2(0.35, runId)
                            end
                        else
                            if not isRun(runId) then break end
                            wait2(0.4, runId)
                        end
                    end
                end
                if not isRun(runId) then break end
                if getTeam() ~= "Lixeiro" then
                    setFarmStatus("Emprego alterado; retomando...")
                elseif collected >= goal then
                    while isRun(runId) and not deliverLixos(collected, runId) do
                        wait2(1, runId)
                    end
                    if isRun(runId) then wait2(1.25, runId) end
                end
            end
        end
    end
    local function startLixeiro(enable)
        T.autoFarmLixeiroEnabled = enable == true
        o.garbageFarmRunId = o.garbageFarmRunId + 1
        local runId = o.garbageFarmRunId
        if T.autoFarmLixeiroEnabled then
            setFarmStatus("Verificando emprego...")
            task.spawn(function()
                local ok, err = pcall(farmLoop, runId)
                if not ok and isRun(runId) then
                    setFarmStatus("Erro: "..tostring(err))
                    T.autoFarmLixeiroEnabled = false
                    o.garbageFarmRunId = o.garbageFarmRunId + 1
                end
            end)
        else
            setFarmStatus("Auto Farm parado.")
            local char, hum, root = handleIsValid()
            if hum and root then hum:MoveTo(root.Position) end
        end
    end
    o.startLixeiro = startLixeiro
end

-- ACOES RAPIDAS
local function curar()
    local hum = isCValid()
    if hum then hum.Health = hum.MaxHealth end
end
local function destravar()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if string.find(n,"door") or string.find(n,"porta") or string.find(n,"gate") then
                obj.CanCollide = false
            end
        end
    end
end
local function encherMunicao()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    for _, cont in ipairs({char, bp}) do
        if cont then
            for _, tool in ipairs(cont:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, v in ipairs(tool:GetDescendants()) do
                        if v:IsA("NumberValue") and (v.Name == "Ammo" or v.Name == "Mag") then v.Value = 999 end
                    end
                end
            end
        end
    end
end

-- HUD ITENS NO CHAO
do
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "VeteranoColetaHUD"
    hudGui.ResetOnSpawn = false
    hudGui.IgnoreGuiInset = true
    hudGui.DisplayOrder = 9997
    if protect_gui then pcall(protect_gui, hudGui) end
    hudGui.Parent = parentGui
    o.coletaHudGui = hudGui

    local frame = Instance.new("Frame")
    frame.Name = "ColetaHUD"
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -20, 0, 100)
    frame.Size = UDim2.fromOffset(280, 320)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Visible = false
    frame.ZIndex = 5
    frame.Parent = hudGui
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 12); fc.Parent = frame
    local fs = Instance.new("UIStroke"); fs.Color = LINE; fs.Thickness = 1; fs.Parent = frame

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.ZIndex = 6
    header.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(14, 0)
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "Itens no chao"
    title.TextColor3 = WH
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = header

    local countLbl = Instance.new("TextLabel")
    countLbl.AnchorPoint = Vector2.new(1, 0.5)
    countLbl.Position = UDim2.new(1, -14, 0.5, 0)
    countLbl.Size = UDim2.fromOffset(80, 20)
    countLbl.BackgroundTransparency = 1
    countLbl.Font = Enum.Font.Gotham
    countLbl.Text = "0"
    countLbl.TextColor3 = DIM
    countLbl.TextSize = 11
    countLbl.TextXAlignment = Enum.TextXAlignment.Right
    countLbl.ZIndex = 6
    countLbl.Parent = header

    local drag = {dragging=false, startPos=nil, startMouse=nil, touchInput=nil}
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag.dragging = true
            drag.startPos = frame.Position
            drag.startMouse = input.Position
        elseif input.UserInputType == Enum.UserInputType.Touch then
            drag.dragging = true
            drag.startPos = frame.Position
            drag.startMouse = input.Position
            drag.touchInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag.dragging = false; drag.touchInput = nil
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not drag.dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - drag.startMouse
            frame.Position = UDim2.new(drag.startPos.X.Scale, drag.startPos.X.Offset + delta.X, drag.startPos.Y.Scale, drag.startPos.Y.Offset + delta.Y)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            if drag.touchInput and input ~= drag.touchInput then return end
            local delta = input.Position - drag.startMouse
            frame.Position = UDim2.new(drag.startPos.X.Scale, drag.startPos.X.Offset + delta.X, drag.startPos.Y.Scale, drag.startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag.dragging = false; drag.touchInput = nil
        end
    end)

    local div = Instance.new("Frame")
    div.Position = UDim2.new(0, 12, 0, 30)
    div.Size = UDim2.new(1, -24, 0, 1)
    div.BackgroundColor3 = LINE
    div.BorderSizePixel = 0
    div.ZIndex = 6
    div.Parent = frame

    local list = Instance.new("ScrollingFrame")
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.Position = UDim2.fromOffset(10, 38)
    list.Size = UDim2.new(1, -20, 1, -48)
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = TC
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.ZIndex = 5
    list.Parent = frame
    local ll = Instance.new("UIListLayout")
    ll.Padding = UDim.new(0, 5)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Parent = list

    local emptyMsg = Instance.new("TextLabel")
    emptyMsg.Name = "EmptyMsg"
    emptyMsg.BackgroundTransparency = 1
    emptyMsg.Size = UDim2.new(1, 0, 0, 30)
    emptyMsg.Font = Enum.Font.Gotham
    emptyMsg.Text = "Nenhum item dropado"
    emptyMsg.TextColor3 = DIM
    emptyMsg.TextSize = 12
    emptyMsg.ZIndex = 5
    emptyMsg.Visible = true
    emptyMsg.Parent = list

    local function buildRow(idx, entry)
        local row = Instance.new("Frame")
        row.Name = "Row_" .. idx
        row.BackgroundColor3 = BG3
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, -4, 0, 34)
        row.LayoutOrder = idx
        row.ZIndex = 5
        row.Parent = list
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = row

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(9, 0)
        label.Size = UDim2.new(1, -62, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = string.format("%s  -  %dm", entry.nome, math.floor(entry.distancia + 0.5))
        label.TextColor3 = WH
        label.TextSize = 11
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 6
        label.Parent = row

        local tp = Instance.new("TextButton")
        tp.Name = "TP"
        tp.AnchorPoint = Vector2.new(1, 0.5)
        tp.Position = UDim2.new(1, -5, 0.5, 0)
        tp.Size = UDim2.fromOffset(42, 24)
        tp.BackgroundColor3 = TC
        tp.BorderSizePixel = 0
        tp.Font = Enum.Font.GothamBold
        tp.Text = "TP"
        tp.TextColor3 = BG
        tp.TextSize = 11
        tp.AutoButtonColor = false
        tp.ZIndex = 6
        tp.Parent = row
        local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 5); tc.Parent = tp

        row:SetAttribute("ItemIdx", idx)
        tp.MouseButton1Click:Connect(function()
            local curIdx = row:GetAttribute("ItemIdx")
            local drops = o.listDrops and o.listDrops() or {}
            local cur = drops[curIdx]
            if cur and cur.item and cur.item.Parent then
                task.spawn(function() pcall(o.coletarItem, cur) end)
            end
        end)
    end

    local function refresh()
        local drops = o.listDrops and o.listDrops() or {}
        local maxShow = math.min(#drops, 20)
        for _, ch in ipairs(list:GetChildren()) do
            if ch:IsA("GuiObject") and ch.Name ~= "EmptyMsg" then ch:Destroy() end
        end
        if maxShow == 0 then
            emptyMsg.Visible = true
            countLbl.Text = "0"
            return
        end
        emptyMsg.Visible = false
        for i = 1, maxShow do buildRow(i, drops[i]) end
        countLbl.Text = tostring(#drops)
    end

    function o.setColetaHudVisible(v)
        frame.Visible = v == true
        if frame.Visible then pcall(refresh) end
    end

    task.spawn(function()
        while not o.destroyed do
            if frame.Visible then pcall(refresh) end
            task.wait(0.6)
        end
    end)
end

-- STAFF MONITOR HUD
do
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "VeteranoStaffHUD"
    hudGui.ResetOnSpawn = false
    hudGui.IgnoreGuiInset = true
    hudGui.DisplayOrder = 9998
    if protect_gui then pcall(protect_gui, hudGui) end
    hudGui.Parent = parentGui

    local hudLbl = Instance.new("TextLabel")
    hudLbl.Size = UDim2.new(0, 320, 0, 30)
    hudLbl.Position = UDim2.new(0.5, -160, 1, -60)
    hudLbl.BackgroundTransparency = 1
    hudLbl.Text = "0 staff no servidor"
    hudLbl.TextColor3 = Color3.fromRGB(100,255,100)
    hudLbl.Font = Enum.Font.GothamBlack
    hudLbl.TextSize = 18
    hudLbl.TextStrokeTransparency = 0
    hudLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    hudLbl.TextXAlignment = Enum.TextXAlignment.Center
    hudLbl.Visible = false
    hudLbl.Parent = hudGui

    task.spawn(function()
        while not o.destroyed do
            if T.monitorarStaff then
                hudLbl.Visible = true
                local c2 = o.staffCount or 0
                if c2 == 0 then
                    hudLbl.Text = "0 staff no servidor"
                    hudLbl.TextColor3 = Color3.fromRGB(100,255,100)
                elseif c2 == 1 then
                    hudLbl.Text = "1 staff no servidor"
                    hudLbl.TextColor3 = Color3.fromRGB(255,200,50)
                else
                    hudLbl.Text = c2.." staff no servidor"
                    hudLbl.TextColor3 = Color3.fromRGB(255,60,60)
                end
            else
                hudLbl.Visible = false
            end
            task.wait(1)
        end
    end)
end

-- UI PRINCIPAL
local W = isMobile and 440 or 640
local H = isMobile and 500 or 580

local container = Instance.new("Frame")
container.Size = UDim2.new(0, W, 0, H)
container.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
container.BackgroundColor3 = BG
container.BorderSizePixel = 0
container.Parent = screenGui
container.ClipsDescendants = true
local cCorner = Instance.new("UICorner"); cCorner.CornerRadius = UDim.new(0,14); cCorner.Parent = container
local cStroke = Instance.new("UIStroke"); cStroke.Color = TC; cStroke.Thickness = 2; cStroke.Parent = container

local camMenu = workspace.CurrentCamera
local vpMenu = camMenu and camMenu.ViewportSize or Vector2.new(1280,720)
local menuScale = 1
if isMobile or vpMenu.X < 700 then
    local maxW, maxH = vpMenu.X*0.96, vpMenu.Y*0.92
    menuScale = math.min(maxW/W, maxH/H, 1)
    if menuScale < 0.40 then menuScale = 0.40 end
end
local uiscaleMenu = Instance.new("UIScale")
uiscaleMenu.Scale = menuScale
uiscaleMenu.Parent = container

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, isMobile and 64 or 52)
topBar.BackgroundColor3 = BG3
topBar.BorderSizePixel = 0
topBar.Parent = container
local topCorner = Instance.new("UICorner"); topCorner.CornerRadius = UDim.new(0,14); topCorner.Parent = topBar
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 1)
topLine.Position = UDim2.new(0, 0, 1, -1)
topLine.BackgroundColor3 = TC
topLine.BorderSizePixel = 0
topLine.Parent = topBar

local badge = Instance.new("Frame")
badge.Size = UDim2.new(0, isMobile and 40 or 34, 0, isMobile and 40 or 34)
badge.Position = UDim2.new(0, 10, 0.5, isMobile and -20 or -17)
badge.BackgroundColor3 = TC
badge.BorderSizePixel = 0
badge.Parent = topBar
local badgeCorner = Instance.new("UICorner"); badgeCorner.CornerRadius = UDim.new(0,8); badgeCorner.Parent = badge
local badgeTxt = Instance.new("TextLabel")
badgeTxt.Size = UDim2.new(1, 0, 1, 0)
badgeTxt.BackgroundTransparency = 1
badgeTxt.Text = "VT"
badgeTxt.TextColor3 = BG
badgeTxt.Font = Enum.Font.GothamBlack
badgeTxt.TextSize = isMobile and 15 or 13
badgeTxt.Parent = badge

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 300, 0, 28)
titleLbl.Position = UDim2.new(0, isMobile and 60 or 52, 0, isMobile and 8 or 6)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "VETERANO TEAM | SINTONIA RP V2"
titleLbl.TextColor3 = WH
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = isMobile and 12 or 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(0, 300, 0, 14)
subLbl.Position = UDim2.new(0, isMobile and 60 or 52, 0, isMobile and 34 or 32)
subLbl.BackgroundTransparency = 1
subLbl.Text = "@VETERANO.DEV"
subLbl.TextColor3 = TC
subLbl.Font = Enum.Font.GothamMedium
subLbl.TextSize = 10
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.Parent = topBar

local function mkTopBtn(xOff, col, txt)
    local b2 = Instance.new("TextButton")
    b2.Size = UDim2.new(0, isMobile and 40 or 32, 0, isMobile and 40 or 32)
    b2.Position = UDim2.new(1, xOff, 0.5, isMobile and -20 or -16)
    b2.BackgroundColor3 = col
    b2.Text = txt
    b2.TextColor3 = WH
    b2.TextSize = isMobile and 18 or 15
    b2.Font = Enum.Font.GothamBold
    b2.BorderSizePixel = 0
    b2.Parent = topBar
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,8); bc.Parent = b2
    return b2
end

local closeBtn = mkTopBtn(isMobile and -52 or -42, Color3.fromRGB(130,25,10), "X")
local minBtn = mkTopBtn(isMobile and -102 or -82, BG2, "-")

local TAB_NAMES = {"PLAYER","ESP","AIMBOT","WEAPONS","MISC","VEICULO","GARAGEM","CONFIG"}
local activeTab = "PLAYER"
local tabButtons, tabStrokes = {}, {}

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(1, -16, 0, isMobile and 44 or 36)
tabBar.Position = UDim2.new(0, 8, 0, isMobile and 72 or 56)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.ScrollBarThickness = 0
tabBar.CanvasSize = UDim2.new(0,0,0,0)
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
tabBar.ScrollingDirection = Enum.ScrollingDirection.X
tabBar.Parent = container

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, isMobile and 4 or 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

for _, name in ipairs(TAB_NAMES) do
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, isMobile and 88 or 96, 0, isMobile and 38 or 32)
    tb.BackgroundColor3 = BG3
    tb.Text = name
    tb.TextColor3 = DIM
    tb.Font = Enum.Font.GothamSemibold
    tb.TextSize = isMobile and 10 or 11
    tb.BorderSizePixel = 0
    tb.Parent = tabBar
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0,8); tbc.Parent = tb
    local ts = Instance.new("UIStroke"); ts.Color = LINE; ts.Thickness = 1; ts.Parent = tb
    tabButtons[name] = tb
    tabStrokes[name] = ts
end

local PY = isMobile and 120 or 98
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Size = UDim2.new(0, isMobile and 210 or 300, 0, H-PY-10)
leftPanel.Position = UDim2.new(0, 8, 0, PY)
leftPanel.BackgroundColor3 = BG2
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 4
leftPanel.ScrollBarImageColor3 = TC
leftPanel.CanvasSize = UDim2.new(0,0,0,0)
leftPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
leftPanel.Parent = container
local lpCorner = Instance.new("UICorner"); lpCorner.CornerRadius = UDim.new(0,10); lpCorner.Parent = leftPanel
local lpStr = Instance.new("UIStroke"); lpStr.Color = LINE; lpStr.Thickness = 1; lpStr.Parent = leftPanel

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0, isMobile and 205 or 320, 0, H-PY-10)
rightPanel.Position = UDim2.new(0, isMobile and 226 or 316, 0, PY)
rightPanel.BackgroundColor3 = BG2
rightPanel.BorderSizePixel = 0
rightPanel.Parent = container
rightPanel.ClipsDescendants = true
local rpCorner = Instance.new("UICorner"); rpCorner.CornerRadius = UDim.new(0,10); rpCorner.Parent = rightPanel
local rpStr = Instance.new("UIStroke"); rpStr.Color = LINE; rpStr.Thickness = 1; rpStr.Parent = rightPanel

local rTitle = Instance.new("TextLabel")
rTitle.Size = UDim2.new(1, -20, 0, 28)
rTitle.Position = UDim2.new(0, 12, 0, 8)
rTitle.BackgroundTransparency = 1
rTitle.TextColor3 = TC
rTitle.Font = Enum.Font.GothamBold
rTitle.TextSize = isMobile and 12 or 13
rTitle.TextXAlignment = Enum.TextXAlignment.Left
rTitle.Parent = rightPanel

local rDiv = Instance.new("Frame")
rDiv.Size = UDim2.new(1, -24, 0, 1)
rDiv.Position = UDim2.new(0, 12, 0, 38)
rDiv.BackgroundColor3 = LINE
rDiv.BorderSizePixel = 0
rDiv.Parent = rightPanel

local rText = Instance.new("ScrollingFrame")
rText.Size = UDim2.new(1, -24, 1, -52)
rText.Position = UDim2.new(0, 12, 0, 46)
rText.BackgroundTransparency = 1
rText.BorderSizePixel = 0
rText.ScrollBarThickness = 2
rText.ScrollBarImageColor3 = TC
rText.CanvasSize = UDim2.new(0,0,0,0)
rText.AutomaticCanvasSize = Enum.AutomaticSize.Y
rText.Parent = rightPanel

local rTextLbl = Instance.new("TextLabel")
rTextLbl.Size = UDim2.new(1, 0, 0, 0)
rTextLbl.AutomaticSize = Enum.AutomaticSize.Y
rTextLbl.BackgroundTransparency = 1
rTextLbl.TextColor3 = DIM
rTextLbl.Font = Enum.Font.Gotham
rTextLbl.TextSize = isMobile and 10 or 11
rTextLbl.TextWrapped = true
rTextLbl.TextXAlignment = Enum.TextXAlignment.Left
rTextLbl.TextYAlignment = Enum.TextYAlignment.Top
rTextLbl.Parent = rText

local function limparPainel()
    for _, c2 in ipairs(leftPanel:GetChildren()) do
        if not c2:IsA("UIListLayout") and not c2:IsA("UIPadding") then c2:Destroy() end
    end
end

local function criarLayout()
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, isMobile and 4 or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = leftPanel
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, isMobile and 4 or 8)
    p.PaddingRight = UDim.new(0, isMobile and 4 or 8)
    p.PaddingTop = UDim.new(0, isMobile and 4 or 8)
    p.Parent = leftPanel
end

local function criarToggle(texto, getter, setter)
    local on = getter()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, isMobile and 50 or 44)
    frame.BackgroundColor3 = on and Color3.fromRGB(70,30,110) or BG3
    frame.BorderSizePixel = 0
    frame.Parent = leftPanel
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0,10); fc.Parent = frame
    local fs = Instance.new("UIStroke"); fs.Color = on and TC or LINE; fs.Thickness = 1; fs.Parent = frame
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 10, 0.5, -3)
    dot.BackgroundColor3 = on and TC or DIM
    dot.BorderSizePixel = 0
    dot.Parent = frame
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, isMobile and 130 or 210, 1, 0)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = on and WH or DIM
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = isMobile and 11 or 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    local tBg = Instance.new("Frame")
    tBg.Size = UDim2.new(0, isMobile and 42 or 38, 0, isMobile and 24 or 20)
    tBg.Position = UDim2.new(1, isMobile and -50 or -46, 0.5, isMobile and -12 or -10)
    tBg.BackgroundColor3 = on and TC or LINE
    tBg.BorderSizePixel = 0
    tBg.Parent = frame
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(1,0); tbc.Parent = tBg
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, isMobile and 20 or 16, 0, isMobile and 20 or 16)
    knob.Position = on and UDim2.new(1, isMobile and -22 or -19, 0.5, isMobile and -10 or -8) or UDim2.new(0, 3, 0.5, isMobile and -10 or -8)
    knob.BackgroundColor3 = WH
    knob.BorderSizePixel = 0
    knob.Parent = tBg
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    local deb = false
    local function doToggle()
        if deb then return end
        deb = true
        setter(not getter())
        local now = getter()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3=now and Color3.fromRGB(70,30,110) or BG3}):Play()
        TweenService:Create(fs, TweenInfo.new(0.15), {Color=now and TC or LINE}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.15), {TextColor3=now and WH or DIM}):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {BackgroundColor3=now and TC or DIM}):Play()
        TweenService:Create(tBg, TweenInfo.new(0.15), {BackgroundColor3=now and TC or LINE}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position=now and UDim2.new(1, isMobile and -22 or -19, 0.5, isMobile and -10 or -8) or UDim2.new(0, 3, 0.5, isMobile and -10 or -8)}):Play()
        task.delay(0.3, function() deb = false end)
    end
    btn.MouseButton1Click:Connect(doToggle)
    btn.TouchTap:Connect(doToggle)
end

local function criarBotao(texto, cb)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, isMobile and 50 or 44)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = leftPanel
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0,10); fc.Parent = frame
    local fs = Instance.new("UIStroke"); fs.Color = LINE; fs.Thickness = 1; fs.Parent = frame
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = DIM
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = isMobile and 11 or 12
    lbl.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(50,30,80)}):Play()
        TweenService:Create(fs, TweenInfo.new(0.12), {Color=TC}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.12), {TextColor3=WH}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.12), {BackgroundColor3=BG3}):Play()
        TweenService:Create(fs, TweenInfo.new(0.12), {Color=LINE}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.12), {TextColor3=DIM}):Play()
    end)
    local deb = false
    local function acao()
        if deb then return end
        deb = true
        pcall(cb)
        task.delay(0.5, function() deb = false end)
    end
    btn.MouseButton1Click:Connect(acao)
    btn.TouchTap:Connect(acao)
end

local function criarSlider(texto, min, max, getter, setter, step)
    step = step or 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, isMobile and 76 or 70)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = leftPanel
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0,10); fc.Parent = frame
    local fs = Instance.new("UIStroke"); fs.Color = LINE; fs.Thickness = 1; fs.Parent = frame
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = WH
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = isMobile and 11 or 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 62, 0, 24)
    inputBox.Position = UDim2.new(1, -72, 0, 3)
    inputBox.BackgroundColor3 = BG2
    inputBox.Text = tostring(getter())
    inputBox.TextColor3 = WH
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextSize = isMobile and 11 or 12
    inputBox.ClearTextOnFocus = false
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    inputBox.BorderSizePixel = 0
    inputBox.Parent = frame
    local ibc = Instance.new("UICorner"); ibc.CornerRadius = UDim.new(0,6); ibc.Parent = inputBox
    local ibs = Instance.new("UIStroke"); ibs.Color = LINE; ibs.Thickness = 1; ibs.Parent = inputBox
    local hintLbl = Instance.new("TextLabel")
    hintLbl.Size = UDim2.new(1, -20, 0, 14)
    hintLbl.Position = UDim2.new(0, 10, 0, 30)
    hintLbl.BackgroundTransparency = 1
    hintLbl.Text = string.format("min %s | max %s | passo %s", tostring(min), tostring(max), tostring(step))
    hintLbl.TextColor3 = DIM
    hintLbl.Font = Enum.Font.Gotham
    hintLbl.TextSize = isMobile and 9 or 10
    hintLbl.TextXAlignment = Enum.TextXAlignment.Left
    hintLbl.Parent = frame
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -10)
    track.BackgroundColor3 = BG2
    track.BorderSizePixel = 0
    track.Parent = frame
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((getter()-min)/(max-min),0,1), 0, 1, 0)
    fill.BackgroundColor3 = TC
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fcc = Instance.new("UICorner"); fcc.CornerRadius = UDim.new(1,0); fcc.Parent = fill
    local function aplicarValor(raw, mostrarErro)
        if raw == "" or raw == "-" then return end
        local num = tonumber(raw)
        if not num then
            if mostrarErro then
                inputBox.Text = tostring(getter())
                inputBox.TextColor3 = Color3.fromRGB(255,100,125)
                task.delay(0.8, function() inputBox.TextColor3 = WH end)
            end
            return
        end
        local v = math.floor(num/step+0.5)*step
        v = math.clamp(v, min, max)
        setter(v)
        inputBox.Text = tostring(v)
        fill.Size = UDim2.new((v-min)/(max-min), 0, 1, 0)
    end
    inputBox.FocusLost:Connect(function(enterPressed)
        aplicarValor(inputBox.Text, true)
    end)
end

local function criarSep(txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, isMobile and 22 or 20)
    l.BackgroundTransparency = 1
    l.Text = "-- "..txt.." --"
    l.TextColor3 = TC
    l.Font = Enum.Font.GothamBold
    l.TextSize = isMobile and 9 or 10
    l.Parent = leftPanel
end

local function criarDropdown(texto, options, default, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, isMobile and 50 or 44)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = leftPanel
    frame.ClipsDescendants = false
    frame.ZIndex = 5
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0,10); fc.Parent = frame
    local fs = Instance.new("UIStroke"); fs.Color = LINE; fs.Thickness = 1; fs.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, isMobile and 90 or 140, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextColor3 = WH
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = isMobile and 11 or 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    lbl.ZIndex = 6

    local cur = Instance.new("TextLabel")
    cur.Size = UDim2.new(0, isMobile and 90 or 130, 1, 0)
    cur.Position = UDim2.new(1, isMobile and -100 or -140, 0, 0)
    cur.BackgroundTransparency = 1
    cur.Text = tostring(default)
    cur.TextColor3 = TC
    cur.Font = Enum.Font.GothamBold
    cur.TextSize = isMobile and 10 or 11
    cur.TextXAlignment = Enum.TextXAlignment.Right
    cur.Parent = frame
    cur.ZIndex = 6

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.ZIndex = 7

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 4)
    list.BackgroundColor3 = BG2
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 50
    list.Parent = frame
    local lc = Instance.new("UICorner"); lc.CornerRadius = UDim.new(0,8); lc.Parent = list
    local ls = Instance.new("UIStroke"); ls.Color = TC; ls.Thickness = 1; ls.Transparency = 0.4; ls.Parent = list
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,2); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = list
    local lpad = Instance.new("UIPadding")
    lpad.PaddingTop = UDim.new(0, 4)
    lpad.PaddingBottom = UDim.new(0, 4)
    lpad.PaddingLeft = UDim.new(0, 4)
    lpad.PaddingRight = UDim.new(0, 4)
    lpad.Parent = list

    local open = false
    local rowH = 28
    for i, opt in ipairs(options) do
        local o = Instance.new("TextButton")
        o.Size = UDim2.new(1, 0, 0, rowH)
        o.BackgroundColor3 = BG3
        o.Text = opt
        o.TextColor3 = WH
        o.Font = Enum.Font.GothamSemibold
        o.TextSize = 11
        o.BorderSizePixel = 0
        o.LayoutOrder = i
        o.ZIndex = 51
        o.AutoButtonColor = false
        o.Parent = list
        local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0,6); oc.Parent = o
        o.MouseEnter:Connect(function()
            TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(60,35,100)}):Play()
        end)
        o.MouseLeave:Connect(function()
            TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3=BG3}):Play()
        end)
        local function sel()
            cur.Text = tostring(opt)
            cur.TextColor3 = TC
            open = false
            TweenService:Create(list, TweenInfo.new(0.15), {Size=UDim2.new(1,0,0,0)}):Play()
            task.delay(0.16, function() list.Visible = false end)
            if onChange then pcall(onChange, opt) end
        end
        o.MouseButton1Click:Connect(sel)
        o.TouchTap:Connect(sel)
    end

    local function toggleList()
        open = not open
        if open then
            local total = (#options * (rowH + 2)) + 8
            list.Visible = true
            TweenService:Create(list, TweenInfo.new(0.15), {Size=UDim2.new(1,0,0,total)}):Play()
        else
            TweenService:Create(list, TweenInfo.new(0.15), {Size=UDim2.new(1,0,0,0)}):Play()
            task.delay(0.16, function() list.Visible = false end)
        end
    end
    btn.MouseButton1Click:Connect(toggleList)
    btn.TouchTap:Connect(toggleList)

    return {
        Get = function() return cur.Text end,
        Set = function(_, v) cur.Text = tostring(v) end,
    }
end

local updateContent = function()
    task.spawn(function()
        limparPainel()
        criarLayout()

        if activeTab == "PLAYER" then
            rTitle.Text = "PLAYER"
            criarToggle("WalkSpeed", function() return T.spoofWalkEnabled end, function(v)
                T.spoofWalkEnabled = v
                if not v then
                    local hum = isCValid()
                    if hum then hum.WalkSpeed = 16 end
                end
            end)
            criarSlider("Velocidade", 16, 250, function() return T.spoofWalkSpeed end, function(v) T.spoofWalkSpeed = v end, 1)
            criarToggle("JumpPower", function() return T.spoofJumpEnabled end, function(v)
                T.spoofJumpEnabled = v
                if not v then
                    local hum = isCValid()
                    if hum then hum.JumpPower = 50 end
                end
            end)
            criarSlider("Forca Jump", 50, 150, function() return T.spoofJumpPower end, function(v) T.spoofJumpPower = v end, 1)
            criarSep("MOVIMENTO")
            criarToggle("Noclip", function() return T.noclipEnabled end, function(v)
                T.noclipEnabled = v; pcall(Nz)
            end)
            criarToggle("Fly", function() return T.flyEnabled end, function(v)
                T.flyEnabled = v; pcall(xz)
            end)
            criarSlider("Vel. Fly", 16, 250, function() return T.flySpeed end, function(v) T.flySpeed = v end, 1)
            criarSep("MUNDO")
            criarToggle("Sempre Dia", function() return T.alwaysDay end, function(v)
                T.alwaysDay = v; pcall(o.applyWorld)
            end)
            criarToggle("Fullbright", function() return T.fullbright end, function(v)
                T.fullbright = v; pcall(o.applyWorld)
            end)
            criarToggle("No Lag", function() return T.noLag end, function(v)
                T.noLag = v; pcall(o.applyWorld)
            end)
            rTextLbl.Text = "PLAYER - Jogador\n\nWalkSpeed:\n  Aumenta a velocidade.\n  Limite = 28.\n\nJumpPower:\n  Forca do pulo.\n\nNoclip:\n  Atravessa paredes.\n\nFly:\n  Voa com WASD.\n  Space = subir\n  Ctrl = descer\n\nSempre Dia / Fullbright / No Lag."

        elseif activeTab == "ESP" then
            rTitle.Text = "ESP"
            criarToggle("Ativar ESP", function() return T.espEnabled end, function(v)
                T.espEnabled = v
                if not v then pcall(PF) end
            end)
            criarSep("VISUAL")
            criarToggle("Caixa 2D", function() return T.box end, function(v) T.box = v end)
            criarToggle("Caixa 3D", function() return T.box3d end, function(v) T.box3d = v end)
            criarToggle("Nome", function() return T.name end, function(v) T.name = v end)
            criarToggle("Distancia", function() return T.distance end, function(v) T.distance = v end)
            criarToggle("Item na mao", function() return T.heldItem end, function(v) T.heldItem = v end)
            criarToggle("Esqueleto", function() return T.skeleton end, function(v) T.skeleton = v end)
            criarToggle("Highlight", function() return T.highlight end, function(v) T.highlight = v end)
            criarToggle("Tracer", function() return T.tracer end, function(v) T.tracer = v end)
            criarToggle("Seta fora da tela", function() return T.arrow end, function(v) T.arrow = v end)
            criarToggle("Times", function() return T.teamTag end, function(v) T.teamTag = v end)
            criarSlider("Distancia maxima", 100, 5000, function() return T.maxDistance end, function(v) T.maxDistance = v end, 50)
            rTextLbl.Text = "ESP - Ver Jogadores\n\nStaff = VERMELHO\nAmigos = AZUL\nNormais = ROXO"

        elseif activeTab == "AIMBOT" then
            rTitle.Text = "AIMBOT"
            criarToggle("Ativar Aimbot", function() return T.aimbotEnabled end, function(v)
                T.aimbotEnabled = v
                if v then aimbotLoop() else stopAimbot() end
            end)
            criarSep("MODO")
            criarDropdown("Modo", {"Legit", "Rage"}, T.aimbotMode, function(v) T.aimbotMode = v end)
            criarSep("MIRA")
            criarSlider("FOV", 10, 600, function() return T.aimbotFov end, function(v) T.aimbotFov = v end, 5)
            criarSlider("Distancia", 50, 1000, function() return T.aimbotDistance end, function(v) T.aimbotDistance = v end, 10)
            criarSlider("Suavidade", 1, 100, function() return math.floor(T.aimbotSmoothness*100) end, function(v) T.aimbotSmoothness = v/100 end, 1)
            criarDropdown("Parte corpo", {"Cabeca", "Torso"}, T.aimbotBodyPart, function(v) T.aimbotBodyPart = v end)
            criarSep("FILTROS")
            criarToggle("Wall Check", function() return T.aimbotWallCheck end, function(v) T.aimbotWallCheck = v end)
            criarToggle("Friend Check", function() return T.friendCheck end, function(v) T.friendCheck = v end)
            criarToggle("Staff Check", function() return T.adminCheck end, function(v) T.adminCheck = v end)
            rTextLbl.Text = "AIMBOT - Mira\n\nLegit: so mira com arma\nRage: mira sempre"

        elseif activeTab == "WEAPONS" then
            rTitle.Text = "WEAPONS"
            criarSep("TRACER")
            criarToggle("Tracer Neon", function() return T.armaTracer end, function(v) T.armaTracer = v end)
            local coresTracer = {
                {"Ciano", Color3.fromRGB(0,255,255)},
                {"Verde", Color3.fromRGB(60,255,90)},
                {"Rosa", Color3.fromRGB(255,60,190)},
                {"Roxo", Color3.fromRGB(160,70,255)},
                {"Vermelho", Color3.fromRGB(255,45,45)},
                {"Azul", Color3.fromRGB(70,130,255)},
                {"Laranja", Color3.fromRGB(255,145,30)},
                {"Branco", Color3.fromRGB(240,240,240)},
                {"Amarelo", Color3.fromRGB(255,230,60)},
                {"Arco-iris", nil},
            }
            local corGrid = Instance.new("Frame")
            corGrid.Size = UDim2.new(1, 0, 0, isMobile and 130 or 120)
            corGrid.BackgroundColor3 = BG3
            corGrid.BorderSizePixel = 0
            corGrid.Parent = leftPanel
            local cgC = Instance.new("UICorner"); cgC.CornerRadius = UDim.new(0,10); cgC.Parent = corGrid
            local cgS = Instance.new("UIStroke"); cgS.Color = LINE; cgS.Thickness = 1; cgS.Parent = corGrid
            local cgGrid = Instance.new("UIGridLayout")
            cgGrid.CellSize = UDim2.new(0, isMobile and 50 or 55, 0, isMobile and 26 or 24)
            cgGrid.CellPadding = UDim2.new(0, 4, 0, 4)
            cgGrid.SortOrder = Enum.SortOrder.LayoutOrder
            cgGrid.Parent = corGrid
            local cgPad = Instance.new("UIPadding")
            cgPad.PaddingTop = UDim.new(0,6)
            cgPad.PaddingLeft = UDim.new(0,6)
            cgPad.PaddingRight = UDim.new(0,6)
            cgPad.Parent = corGrid
            for _, corData in ipairs(coresTracer) do
                local nome = corData[1]
                local corRGB = corData[2]
                local btn = Instance.new("TextButton")
                btn.BackgroundColor3 = corRGB or Color3.fromRGB(200,200,200)
                btn.Text = nome
                btn.TextColor3 = (corRGB and (corRGB.R+corRGB.G+corRGB.B > 400) and Color3.fromRGB(0,0,0)) or Color3.fromRGB(255,255,255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = isMobile and 8 or 9
                btn.BorderSizePixel = 0
                btn.Parent = corGrid
                local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
                local bs = Instance.new("UIStroke"); bs.Color = LINE; bs.Thickness = 1; bs.Parent = btn
                local function aplicar()
                    T.armaTracerCor = nome
                    T.armaTracer = true
                    for _, other in ipairs(corGrid:GetChildren()) do
                        if other:IsA("TextButton") then
                            local s = other:FindFirstChildOfClass("UIStroke")
                            if s then s.Color = LINE; s.Thickness = 1 end
                        end
                    end
                    bs.Color = TC; bs.Thickness = 2
                end
                btn.MouseButton1Click:Connect(aplicar)
                btn.TouchTap:Connect(aplicar)
            end

            criarSep("COLETAR ITENS")
            criarToggle("Coleta Auto", function() return T.autoColetaEnabled end, function(v)
                if v then
                    if o.startAutoColeta then o.startAutoColeta() end
                else
                    if o.stopAutoColeta then o.stopAutoColeta() end
                end
            end)
            criarSlider("Velocidade TP", 20, 160, function() return T.itemTeleportSpeed end, function(v) T.itemTeleportSpeed = v end, 5)
            criarSlider("Cooldown (ms)", 10, 200, function() return math.floor(T.autoColetaCooldown * 100) end, function(v) T.autoColetaCooldown = v / 100 end, 5)
            criarToggle("HUD de itens", function() return T.coletaHudEnabled end, function(v)
                T.coletaHudEnabled = v
                if o.setColetaHudVisible then o.setColetaHudVisible(v) end
            end)

            criarSep("COLETOR DE ARMAS")
            criarToggle("Coletor Automatico", function() return T.coletorArmasAtivo end, function(v)
                T.coletorArmasAtivo = v
                if v then
                    task.spawn(function()
                        if o.coletarArmasEspecificas then o.coletarArmasEspecificas() end
                        T.coletorArmasAtivo = false
                    end)
                end
            end)
            criarBotao("Coletar Armas Agora", function()
                task.spawn(function()
                    if o.coletarArmasEspecificas then o.coletarArmasEspecificas() end
                end)
            end)
            criarBotao("Mostrar Lista", function()
                local lista = "Armas Permitidas:\n\nFacil:\n"
                for _, arma in ipairs({"AK47", "FAL", "Fuzil", "Glock", "Oitão", "Submetralhadora", "USPs", "Uzi"}) do
                    lista = lista .. "• " .. arma .. "\n"
                end
                lista = lista .. "\nMedia:\n"
                for _, arma in ipairs({"Barret", "FuzilHollow", "FuzilPhantom", "FuzilTrovão", "G3", "PtDragon", "PtNeon", "PtNK"}) do
                    lista = lista .. "• " .. arma .. "\n"
                end
                lista = lista .. "\nLimited:\n"
                for _, arma in ipairs({"ArmaPDSecreta", "FuzilNinja", "FuzilPascoa", "Natalina", "PtNinja", "PtPascoa"}) do
                    lista = lista .. "• " .. arma .. "\n"
                end
                rTextLbl.Text = lista
            end)
            criarBotao("Voltar Posicao", function() voltarParaPosicao() end)
            rTextLbl.Text = "WEAPONS\n\nTracer: cor da bala\nColeta Auto: TP pro item\nColetor Armas: pega especificas\nVoltar: (-227, 38, 144)"

        elseif activeTab == "MISC" then
            rTitle.Text = "MISC"
            criarToggle("Perfect Lockpick", function() return T.perfectLockpick end, function(v) T.perfectLockpick = v end)
            criarToggle("2x Sorte (Gacha)", function() return T.sorte2xEnabled end, function(v)
                T.sorte2xEnabled = v
                if v then
                    if o.aplicarGacha then pcall(o.aplicarGacha) end
                else
                    if o.restaurarGacha then pcall(o.restaurarGacha) end
                end
            end)
            criarSep("AUTO FARM")
            criarToggle("Farm Partes Arma", function() return T.farmPartesEnabled end, function(v)
                if v and T.flyEnabled then T.flyEnabled = false; pcall(xz) end
                T.farmPartesEnabled = v
                if not v then
                    if o.pararFarmPartes then o.pararFarmPartes() end
                    return
                end
                task.spawn(function()
                    if o.iniciarFarmPartes then o.iniciarFarmPartes() end
                end)
            end)
            criarToggle("Farm Lixeiro", function() return T.autoFarmLixeiroEnabled end, function(v)
                if o.startLixeiro then o.startLixeiro(v) end
            end)
            criarSlider("Lixos/entrega", 1, 20, function() return T.autoFarmLixeiroQuantidade end, function(v) T.autoFarmLixeiroQuantidade = v end, 1)
            criarToggle("Farm Pesca", function() return T.autoFarmPescaEnabled end, function(v)
                if o.startPesca then o.startPesca(v) end
            end)
            criarSep("ACOES")
            criarBotao("Curar", curar)
            criarBotao("Destravar Portas", destravar)
            criarBotao("Encher Municao", encherMunicao)
            rTextLbl.Text = "MISC\n\nPerfect Lockpick\nGacha 2x\nFarm Partes/Lixeiro/Pesca\nAcoes rapidas"

        elseif activeTab == "VEICULO" then
            rTitle.Text = "VEICULO"
            criarToggle("Durabilidade HUD", function() return T.durabilidadeHudEnabled end, function(v)
                T.durabilidadeHudEnabled = v
                if v then pcall(o.ativarDurabilidade) else pcall(o.desativarDurabilidade) end
            end)
            criarToggle("Cinto Auto", function() return T.autoCintoEnabled end, function(v) T.autoCintoEnabled = v end)
            criarSep("MOVIMENTO")
            criarToggle("Noclip Car", function() return T.noclipCarEnabled end, function(v)
                T.noclipCarEnabled = v; pcall(o.aplicarNoclipCar)
            end)
            criarToggle("VFly", function() return T.vFlyEnabled end, function(v)
                T.vFlyEnabled = v; pcall(o.aplicarNoclipCar)
            end)
            criarSlider("VFly Horiz", 20, 500, function() return T.vFlyHorizontalSpeed end, function(v) T.vFlyHorizontalSpeed = v end, 5)
            criarSlider("VFly Vert", 10, 300, function() return T.vFlyVerticalSpeed end, function(v) T.vFlyVerticalSpeed = v end, 5)
            criarSlider("Boost (%)", 100, 99900, function() return math.floor(T.boostFactor*100) end, function(v)
                T.boostFactor = v/100
                pcall(function()
                    local hum = isCValid()
                    if hum then hz(hum) end
                end)
            end, 100)
            rTextLbl.Text = "VEICULO\n\nDurabilidade HUD\nCinto Auto\nNoclip Car\nVFly (Space/Ctrl)\nBoost motor"

        elseif activeTab == "GARAGEM" then
            rTitle.Text = "GARAGEM"
            criarSep("EM BREVE")
            local infoLbl = Instance.new("TextLabel")
            infoLbl.Size = UDim2.new(1, 0, 0, isMobile and 200 or 180)
            infoLbl.BackgroundColor3 = BG3
            infoLbl.Text = "Em breve:\n  ESP Car\n  Spawn de veiculos\n  Controle remoto"
            infoLbl.TextColor3 = DIM
            infoLbl.Font = Enum.Font.Gotham
            infoLbl.TextSize = isMobile and 10 or 11
            infoLbl.TextWrapped = true
            infoLbl.TextYAlignment = Enum.TextYAlignment.Top
            infoLbl.Parent = leftPanel
            local infoCorner = Instance.new("UICorner"); infoCorner.CornerRadius = UDim.new(0,8); infoCorner.Parent = infoLbl
            local infoPad = Instance.new("UIPadding")
            infoPad.PaddingTop = UDim.new(0,6); infoPad.PaddingLeft = UDim.new(0,8)
            infoPad.PaddingRight = UDim.new(0,8); infoPad.PaddingBottom = UDim.new(0,6)
            infoPad.Parent = infoLbl
            local infoStroke = Instance.new("UIStroke"); infoStroke.Color = TC; infoStroke.Thickness = 1; infoStroke.Transparency = 0.5; infoStroke.Parent = infoLbl
            rTextLbl.Text = "GARAGEM\n\nEm breve"

        elseif activeTab == "CONFIG" then
            rTitle.Text = "CONFIG"
            criarSep("SOBRE")
            local infoLbl = Instance.new("TextLabel")
            infoLbl.Size = UDim2.new(1, 0, 0, isMobile and 150 or 130)
            infoLbl.BackgroundColor3 = BG3
            infoLbl.Text = "VETERANO TEAM\n\nDiscord: @veterano.dev\nTikTok: @veterano.dev\nYouTube: @veterano_dev"
            infoLbl.TextColor3 = DIM
            infoLbl.Font = Enum.Font.Gotham
            infoLbl.TextSize = isMobile and 9 or 10
            infoLbl.TextWrapped = true
            infoLbl.TextYAlignment = Enum.TextYAlignment.Top
            infoLbl.Parent = leftPanel
            local infoCorner = Instance.new("UICorner"); infoCorner.CornerRadius = UDim.new(0,8); infoCorner.Parent = infoLbl
            local infoPad = Instance.new("UIPadding")
            infoPad.PaddingTop = UDim.new(0,8); infoPad.PaddingLeft = UDim.new(0,10)
            infoPad.PaddingRight = UDim.new(0,10); infoPad.PaddingBottom = UDim.new(0,8)
            infoPad.Parent = infoLbl
            local infoStroke = Instance.new("UIStroke"); infoStroke.Color = TC; infoStroke.Thickness = 1; infoStroke.Transparency = 0.5; infoStroke.Parent = infoLbl

            criarSep("MONITORAR STAFF")
            criarToggle("Monitor Staff", function() return T.monitorarStaff end, function(v) T.monitorarStaff = v end)

            criarSep("GERENCIAR")
            criarBotao("Resetar Menu", function()
                for k, v in pairs(T) do
                    if type(v) == "boolean" then T[k] = false end
                end
                T.boostFactor = 1
                T.spoofWalkSpeed = 40
                T.spoofJumpPower = 90
                T.flySpeed = 60
                T.maxDistance = P
                T.vFlyHorizontalSpeed = 60
                T.vFlyVerticalSpeed = 30
                T.itemTeleportSpeed = 65
                T.autoColetaCooldown = 0.35
                T.aimbotMode = "Legit"
                T.aimbotBodyPart = "Cabeca"
                T.armaTracerCor = "Ciano"
                pcall(o.applyWorld); pcall(Nz); pcall(xz)
                stopAimbot()
                if o.restaurarArmas then pcall(o.restaurarArmas) end
                if o.desativarDurabilidade then pcall(o.desativarDurabilidade) end
                if o.restaurarNoclipCar then pcall(o.restaurarNoclipCar) end
                if o.restaurarGacha then pcall(o.restaurarGacha) end
                if o.stopAutoColeta then pcall(o.stopAutoColeta) end
                if o.setColetaHudVisible then pcall(o.setColetaHudVisible, false) end
                if o.pararFarmPartes then pcall(o.pararFarmPartes) end
                updateContent()
            end)
            criarBotao("Rejoin Servidor", function()
                pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            end)
            criarBotao("Rejoin Place", function()
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
            end)
            criarBotao("Fechar Menu", function() screenGui.Enabled = false end)

            criarSep("INFO")
            local infoLbl2 = Instance.new("TextLabel")
            infoLbl2.Size = UDim2.new(1, 0, 0, isMobile and 70 or 60)
            infoLbl2.BackgroundColor3 = BG3
            infoLbl2.Text = "Build: vt-team-v5\nTecla menu: K\nFly: F | Noclip: N"
            infoLbl2.TextColor3 = DIM
            infoLbl2.Font = Enum.Font.Gotham
            infoLbl2.TextSize = isMobile and 9 or 10
            infoLbl2.TextWrapped = true
            infoLbl2.TextYAlignment = Enum.TextYAlignment.Top
            infoLbl2.Parent = leftPanel
            local ic2 = Instance.new("UICorner"); ic2.CornerRadius = UDim.new(0,8); ic2.Parent = infoLbl2
            local ip2 = Instance.new("UIPadding")
            ip2.PaddingTop = UDim.new(0,6); ip2.PaddingLeft = UDim.new(0,8)
            ip2.PaddingRight = UDim.new(0,8); ip2.PaddingBottom = UDim.new(0,6)
            ip2.Parent = infoLbl2
            local is2 = Instance.new("UIStroke"); is2.Color = TC; is2.Thickness = 1; is2.Transparency = 0.5; is2.Parent = infoLbl2

            rTextLbl.Text = "CONFIG\n\nMonitor Staff\nReset\nRejoin\nAtalhos: K/F/N"
        end
    end)
end

local function setActiveTab(name)
    activeTab = name
    for n, b2 in pairs(tabButtons) do
        TweenService:Create(b2, TweenInfo.new(0.15), {BackgroundColor3=BG3, TextColor3=DIM}):Play()
        TweenService:Create(tabStrokes[n], TweenInfo.new(0.15), {Color=LINE}):Play()
    end
    local btn = tabButtons[name]
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=TCD, TextColor3=WH}):Play()
    TweenService:Create(tabStrokes[name], TweenInfo.new(0.15), {Color=TC}):Play()
    updateContent()
end

for name, btn in pairs(tabButtons) do
    local deb = false
    local function sel()
        if deb or activeTab == name then return end
        deb = true
        setActiveTab(name)
        task.delay(0.35, function() deb = false end)
    end
    btn.MouseButton1Click:Connect(sel)
    btn.TouchTap:Connect(sel)
end

local minimized = false
local function ativarMin()
    minimized = not minimized
    if minimized then
        TweenService:Create(container, TweenInfo.new(0.2), {Size=UDim2.new(0, W, 0, isMobile and 70 or 52)}):Play()
        leftPanel.Visible = false
        rightPanel.Visible = false
        tabBar.Visible = false
        topLine.Visible = false
    else
        leftPanel.Visible = true
        rightPanel.Visible = true
        tabBar.Visible = true
        topLine.Visible = true
        TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0, W, 0, H)}):Play()
    end
end
minBtn.MouseButton1Click:Connect(ativarMin)
minBtn.TouchTap:Connect(ativarMin)

local function closeUI() screenGui.Enabled = false end
closeBtn.MouseButton1Click:Connect(closeUI)
closeBtn.TouchTap:Connect(closeUI)

local dragData = {dragging=false, startPos=nil, startMousePos=nil, touchInput=nil}
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.startPos = container.Position
        dragData.startMousePos = input.Position
        dragData.touchInput = nil
    elseif input.UserInputType == Enum.UserInputType.Touch then
        dragData.dragging = true
        dragData.startPos = container.Position
        dragData.startMousePos = input.Position
        dragData.touchInput = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragData.dragging = false
                dragData.touchInput = nil
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragData.dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position-dragData.startMousePos
        container.Position = UDim2.new(dragData.startPos.X.Scale, dragData.startPos.X.Offset+delta.X, dragData.startPos.Y.Scale, dragData.startPos.Y.Offset+delta.Y)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        if dragData.touchInput and input ~= dragData.touchInput then return end
        local delta = input.Position-dragData.startMousePos
        container.Position = UDim2.new(dragData.startPos.X.Scale, dragData.startPos.X.Offset+delta.X, dragData.startPos.Y.Scale, dragData.startPos.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragData.dragging = false
        dragData.touchInput = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == T.menuKeybind then
        screenGui.Enabled = not screenGui.Enabled
    end
    if input.KeyCode == T.flyKeybind then
        T.flyEnabled = not T.flyEnabled
        pcall(xz)
    end
    if input.KeyCode == T.noclipKeybind then
        T.noclipEnabled = not T.noclipEnabled
        pcall(Nz)
    end
end)

updateContent()

C.__VETERANO_SINTONIA_WINDOW = screenGui
C.__VETERANO_SINTONIA_BUILD = "vt-team-v5"
C.__VETERANO_SINTONIA_CLEANUP = function()
    o.destroyed = true
    C.__VETERANO_SINTONIA_RUNTIME = nil
    T.autoColetaEnabled = false
    if o.stopAutoColeta then pcall(o.stopAutoColeta) end
    if o.coletaHudGui then pcall(function() o.coletaHudGui:Destroy() end) end
    for _, conn in ipairs(o.connections) do pcall(function() conn:Disconnect() end) end
    o.connections = {}
    for plr in pairs(T.bundles) do qF(T.bundles[plr]); T.bundles[plr] = nil end
    stopAimbot()
    if o.restaurarArmas then pcall(o.restaurarArmas) end
    if o.destruirDurabilidade then pcall(o.destruirDurabilidade) end
    if o.restaurarNoclipCar then pcall(o.restaurarNoclipCar) end
    if o.restaurarGacha then pcall(o.restaurarGacha) end
    pcall(function() screenGui:Destroy() end)
    pcall(function()
        local g = parentGui:FindFirstChild("VeteranoStaffHUD")
        if g then g:Destroy() end
    end)
end

print("[VETERANO TEAM | SINTONIA RP V2] Carregado (v5) SEM LOGIN + Coletor de Armas")
