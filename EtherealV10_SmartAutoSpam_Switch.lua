 Players = game:GetService("Players")
 LocalPlayer = Players.LocalPlayer

 TargetGameId = 4777817887

if game.GameId ~= TargetGameId then
    LocalPlayer:Kick("You have been kicked because this game is not Blade Ball.")
    return
end

do
    local clipUrl = "https://raw.githubusercontent.com/foreverspacexc-blip/Roblox/refs/heads/main/Ethereal_ClipPlayer.lua"
    local ok, source = pcall(function() return game:HttpGet(clipUrl) end)
    if ok and type(source) == "string" and type(loadstring) == "function" then
        local clipChunk = loadstring(source)
        if type(clipChunk) == "function" then
            pcall(clipChunk)
        end
    end
end

 Players = game:GetService("Players")
 player = Players.LocalPlayer
 playerGui = player:WaitForChild("PlayerGui")

 env = (type(getgenv) == "function" and getgenv()) or shared
env.IntroDone = false

while not env.IntroDone do
    task.wait(0.1)
end

local CONFIG = {
    Version = 'v0.1.5',
    UI_URL = 'https://github.com/Ehe241/Abc/raw/refs/heads/main/Ethereal-UI-White-Pro.lua',
}

--// [ ENVIRONMENT ] ---------------------------------------------------------
if typeof(getgenv) ~= 'function' then
    getgenv = function()
        return _G
    end
end

local ENV = getgenv()

if type(ENV.Ethereal_Version) == 'string' and ENV.Ethereal_Version ~= '' then
    CONFIG.Version = ENV.Ethereal_Version
end
ENV.Product_Version = CONFIG.Version

--// [ UI ] ------------------------------------------------------------------
-- The interface is pulled from its URL at run time:
--     loadstring(game:HttpGet(URL))()
-- The hosted file declares Library / Window / Notify as locals and does not
-- expose them, so a return statement is appended in the same chunk if missing.
local Got_UI, UI_Source = pcall(function()
    return game:HttpGet(CONFIG.UI_URL)
end)
if not Got_UI or type(UI_Source) ~= 'string' or UI_Source == '' then
    error('[Ethereal] could not download the UI from ' .. CONFIG.UI_URL .. ' — ' .. tostring(UI_Source), 0)
end
if not string.find(UI_Source, 'return%s+Library%s*,%s*Window') then
    UI_Source = UI_Source .. '\nreturn Library, Window, Notify\n'
end

local Chunk, Compile_Error = loadstring(UI_Source)
if not Chunk then
    error('[Ethereal] UI failed to compile: ' .. tostring(Compile_Error), 0)
end

local Library, Window, Notify = Chunk()


--// [ MENU ] ---------------------------------------------------------------
local Create_Menu = (function()
--[[
    Ethereal AP — menu
    ─────────────────────────────────────────────────────────────────────────
    Builds the Ethereal window for the auto-parry engine and owns the single
    shared config table the engine reads every frame.

    Every control is bound to one Cfg field, so moving a slider or picking a
    dropdown entry takes effect on the next parry / frame with no restart.
    Ethereal's own config autosave already persists the flag values, and the
    control callbacks fire once on creation with the restored value, which
    keeps Cfg in sync on load.

    Usage (inside the built bundle):
        local App = Create_Menu({ Library = Library, Window = Window })
        -- App.Cfg, App.Log
]]

return function(Env)
    local Library = Env.Library
    local Window = Env.Window

    --// [ CONFIG ] — shared with the engine --------------------------------
    -- Every control below writes exactly one field here; the engine reads Cfg
    -- live on the next frame, so no control needs a restart.
    local Cfg = {
        -- Auto Parry
        AutoParry = true,
        Accuracy = 50,
        CurveMode = 'Camera',
        TargetMode = 'Normal',
        ParryAnimationEnabled = false,

        -- ability detection
        DetectInfinity      = false,
        DetectDeathSlash    = false,
        DetectTimeHole      = false,
        DetectSlashesOfFury = false,
        DetectTornado       = false,
        DetectPhantom       = false,
        DetectGuardianDragon = false,
        AntiRepeatMode      = 'V1',
        FuryMaxParries      = 36,
        FuryParryDelay      = 0.05,
        AutoAbility         = false,

        -- staff detection
        StaffDetection  = false,
        StaffActionMode = 'Notification',
        StaffGroupId    = 12836673,
        StaffMinRank    = 10,
        StaffScanPulse  = 0,

        -- triggerbot / pre-click
        Triggerbot     = false,
        PreClick       = false,
        PreClickRange  = 30,
        PreClickSpeed  = 1,
        AutoPlayEnabled = false,
        OrbitBallEnabled = false,
        OrbitBallSpeed = 2,
        OrbitBallRadius = 8,
        OrbitBallDirection = 'Clockwise',

        -- win options
        CustomWin      = false,
        WinMessage     = 'Ethereal',
        KillMessage    = 'Ethereal',
        CustomWinstreak = false,
        Winstreak      = '1',

        -- avatar options
        Headless  = false,
        Korblox   = false,

        --  player options
        FOVEnabled = false,
        FOV        = 70,

        
        ImmortalEnabled   = false,
        ImmortalV1        = false,
        ImmortalV2        = true,
        ImmortalMode      = 'Auto',
        ImmortalAngle     = 145,
        ImmortalRadius    = 10,
        ImmortalHeightMin = -8,
        ImmortalHeightMax = 35,

        
        SkinChanger = false,
        SkinName    = '',

        
        SlashColor      = false,
        SlashColorMode  = 'Solid',
        SlashColorValue = Color3.fromRGB(255, 0, 0),


        ManualSpam      = false,
        ManualSpamKey   = Enum.KeyCode.V,
        ManualSpamStyle = 'Default',   -- 'Default' | 'Rectangle' | 'Square' | 'Circle'
        SpamSpeedMode   = 'Normal',    -- 'Light'|'Normal'|'Fast'|'Turbo'
        AutoSpam        = false,
        SmartAutoSpam   = false,
        CPS             = 60,
        SpamThreshold   = 1,
        SmartAimDot       = 0.92,  -- min cosine between ball velocity and the direction to us (0.92 ~ 23 deg)
        ParryQueueMax     = 4,     -- max pending Auto Parry entries
        ParryQueueMaxAge  = 1.5,   -- drop a queued parry older than this (s)
        DragonAimDot      = 0.85,  -- min cosine between dragon velocity and the direction to a ball
        SmartClashRange2  = 33,    -- max distance (studs) to every clash player: 2 players (me + 1)
        SmartClashRange3  = 50,    -- 3 players
        SmartClashRange4  = 65,    -- 4+ players
        SmartClashWindow  = 3.0,   -- seconds of target history used to verify the clash order
        SmartCDFailsafe   = 3.0,   -- release the lock if the server never sends 'cooldown done'

        
        DeviceTarget           = 'PC',
        DeviceSpoofPulse       = 0,
        DeviceSpoofRejoinPulse = 0,

        espability = false,
        ESPStyle          = 'Default',  -- 'Default' | 'Name Only' | 'Icon Only'
        ESPAbilityColor   = Color3.fromRGB(255, 255, 255),  -- ability name label
        ESPReadyColor     = Color3.fromRGB(80, 220, 120),   -- ready/cooldown label
        BallStatus        = false,
        AerialBlock       = true,
        Reward_Claim_Daily_Rewards    = false,
        Reward_Claim_Playtime_Rewards = false,
        Reward_Claim_Quest_Rewards    = false,

        -- performance
        AntiLag         = false,
        NoRender        = false,
        SyntraFFlags     = false,
        __AntiLagPulse  = 0,
        __NoRenderPulse = 0,

        -- player movement (from normal.txt)
        SpeedEnabled     = false,
        SpeedValue       = 32,
        JumpEnabled      = false,
        JumpValue        = 100,
        FlyEnabled       = false,
        FlySpeed         = 50,
        AutoJumpEnabled  = false,
        NoclipEnabled    = false,
        FreecamEnabled   = false,
        FreecamSpeed     = 50,
        FreecamLookSpeed = 0.003,
        AntiAFKEnabled   = false,
        AntiAFKInterval  = 28,

        -- manual spam floating switch builder (injected by engine)
        __BuildFloatingSwitch = nil,
    }
    

    --// [ NOTIFICATIONS ] --------------------------------------------------
    -- Engine events are routed here. Identical text is rate limited so a
    -- failing network path on every frame cannot flood the screen.
    local Recent = {}
    local Recent_Count = 0
     function Log(Kind, Title, Message, Duration)
        local Key = tostring(Kind) .. '|' .. tostring(Title) .. '|' .. tostring(Message)
        local Now = os.clock()
        if Recent[Key] and (Now - Recent[Key]) < 4 then
            return
        end
        if Recent[Key] == nil then
            Recent_Count = Recent_Count + 1
        end
        Recent[Key] = Now
        if Recent_Count > 200 then
            Recent = {}
            Recent_Count = 0
            Recent[Key] = Now
            Recent_Count = 1
        end

        pcall(function()
            Library.Notify({
                Title = tostring(Title or 'Ethereal'),
                Description = tostring(Message or ''),
                Kind = Kind or 'Info',
                Duration = Duration or 5,
            })
        end)
    end

    --// [ MAIN SECTION ] ---------------------------------------------------
    -- The menu is four top-level tabs: Main, Player, Visual and Misc.
    -- Ethereal's tab bar is flat (one horizontal, left-aligned strip) and tabs
    -- have no left/right placement, so the "tabs" inside each section are
    -- rendered as titled column sections instead: Auto Parry on the left,
    -- AutoSpam and Detection on the right.
    local Main = Window:Create_Tab('Main', '')

    --// [ MAIN > QUICK START ] ---------------------------------------------
    Main.Create_Paragraph({
        title = '⚡ Quick Start',
        content = '1. Turn on <b>Auto Parry</b> to start.\n2. Use <b>Manual Spam</b> (key V) for extra hits.\n3. Want Ethereal to run automatically? Go to <b>Settings → Auto Execute</b>.\n4. Advanced options (Detection, Timing) are in the <b>Pro</b> tab.',
        badge = 'Info',
    })

    Main.Create_Divider({})

    --// [ MAIN > AUTO PARRY ] ----------------------------------------------
    Main.Create_Title({ name = 'Auto Parry' })

    Main.Create_Toggle({
        name = 'Auto Parry',
        info = 'Arm or idle the auto-parry engine.',
        flag = 'Ethereal_AP_Enabled',
        enabled = Cfg.AutoParry,
        callback = function(Value)
            Cfg.AutoParry = Value
        end,
    })

    Main.Create_Toggle({
        name = 'Parry Animation',
        info = 'Play parry animation when parrying',
        flag = 'Ethereal_Parry_Animation',
        enabled = Cfg.ParryAnimationEnabled,
        callback = function(Value)
            Cfg.ParryAnimationEnabled = Value
        end,
    })

    Main.Create_Divider({})

    Main.Create_Slider({
        name = 'Accuracy',
        info = 'Reaction window used to time the parry.',
        flag = 'Ethereal_AP_Accuracy',
        min = 1,
        max = 100,
        step = 1,
        default = Cfg.Accuracy,
        suffix = '%',
        callback = function(Value)
            Cfg.Accuracy = Value
        end,
    })

    
    Main.Create_Dropdown({
        name = 'Curve Mode',
        flag = 'Ethereal_AP_Curve_Mode',
        options = {
            'Camera',
            'Left',
            'Right',
            'Up',
            'Down',
            'Straight',
            'Random',
            'Super Curve Random',
            'Normal',
        },
        default = Cfg.CurveMode,
        callback = function(Value)
            Cfg.CurveMode = Value
        end,
    })

    Main.Create_Dropdown({
        name = 'Target Mode',
        flag = 'Ethereal_AP_Target_Mode',
        options = {
            'Normal',
            'Nearest',
            'Farest',
            'Random',
            'Mouse',
            'Double Click',
        },
        default = Cfg.TargetMode,
        callback = function(Value)
            Cfg.TargetMode = Value
        end,
    })

    Main.Create_Divider({})

    Main.Create_Title({ name = 'Auto Ability' })
    

    Main.Create_Toggle({
        name = 'Auto Ability',
        info = 'Use your equipped ability instead of a wasted parry.',
        flag = 'Ethereal_Auto_Ability',
        enabled = Cfg.AutoAbility,
        callback = function(Value) Cfg.AutoAbility = Value end,
    })

    -- Triggerbot + Pre-Click moved to Pro tab

    --// [ MAIN > AUTOSPAM ] (right column) ---------------------------------
    --// SPAM — right column
    Main.Create_Title({ name = 'Spam', section = 'right' })

    Main.Create_Toggle({
        name = 'Manual Spam',
        info = 'Floating toggle — fires remote independently of range/conditions.',
        flag = 'Ethereal_Manual_Spam',
        enabled = Cfg.ManualSpam,
        section = 'right',
        callback = function(Value)
            Cfg.ManualSpam = Value
            local CG = game:GetService('CoreGui')
            local sg = CG:FindFirstChild('StellarFloatingToggle')
            if sg then
                sg.Enabled = Value
            elseif Value and typeof(Cfg.__BuildFloatingSwitch) == 'function' then
                Cfg.__BuildFloatingSwitch()
            end
        end,
    })

    Main.Create_Button({
        name = 'Manual Spam Keybind',
        info = 'Open keybind setting window to change the spam key.',
        flag = 'Ethereal_Spam_Keybind_Open',
        section = 'right',
        callback = function()
            -- Signal the engine to open the keybind popup.
            -- The popup is built inside BuildFloatingSwitch, so we store
            -- a reference to it in Cfg for the GUI to call.
            if typeof(Cfg.__OpenKeybindPopup) == 'function' then
                Cfg.__OpenKeybindPopup()
            else
                Log('Info', 'Keybind', 'Enable Manual Spam first to use this.')
            end
        end,
    })

    
    Main.Create_Dropdown({
        name = 'Spam Speed',
        flag = 'Ethereal_Spam_Speed_Mode',
        section = 'right',
        options = { 'Light', 'Normal', 'Fast', 'Turbo' },
        default = Cfg.SpamSpeedMode or 'Normal',
        callback = function(Value)
            Cfg.SpamSpeedMode = Value
            local map = { Light = 60, Normal = 100, Fast = 250, Turbo = 430 }
            Cfg.CPS = map[Value] or 60
        end,
    })

    Main.Create_Toggle({
        name = 'Auto Spam',
        info = 'Spam while near an opponent and actively parrying.',
        flag = 'Ethereal_Auto_Spam',
        enabled = Cfg.AutoSpam,
        section = 'right',
        callback = function(Value) Cfg.AutoSpam = Value end,
    })

    Main.Create_Toggle({
        name = 'Smart Auto Spam',
        info = 'Ordered-clash spam: one parry per server cooldown, only while the ball is heading straight at you.',
        flag = 'Ethereal_Spam_Protection',
        enabled = Cfg.SmartAutoSpam,
        section = 'right',
        callback = function(Value)
            Cfg.SmartAutoSpam = Value
        end,
    })

    Main.Create_Slider({
        name = 'CPS',
        flag = 'Ethereal_Spam_CPS',
        min = 1,
        max = 200,
        step = 1,
        default = Cfg.CPS,
        section = 'right',
        callback = function(Value)
            Cfg.CPS = Value
            -- Snap SpamSpeedMode label to closest preset
            if Value <= 60 then Cfg.SpamSpeedMode = 'Light'
            elseif Value <= 100 then Cfg.SpamSpeedMode = 'Normal'
            elseif Value <= 250 then Cfg.SpamSpeedMode = 'Fast'
            else Cfg.SpamSpeedMode = 'Turbo' end
        end,
    })

    Main.Create_Slider({
        name = 'Spam Threshold',
        flag = 'Ethereal_Spam_Threshold',
        min = 0.5,
        max = 5,
        step = 0.1,
        default = Cfg.SpamThreshold,
        section = 'right',
        callback = function(Value) Cfg.SpamThreshold = Value end,
    })

    -- Detection + Staff Detection moved to Pro tab

    --// [ PLAYER SECTION ] -------------------------------------------------
    -- The local avatar and its camera live here: Immortality V1/V2 + Field of
    -- View on the left, Headless/Korblox on the right. Sword cosmetics moved
    -- to their own Visual tab.
    local Player = Window:Create_Tab('Player', '')

    --// [ PLAYER > IMMORTALITY ] ------------------------------------------
    Player.Create_Title({ name = 'Immortality' })
    Player.Create_Paragraph({
        title = 'V1 + V2 desync',
        content = '<b>Risky</b>: not a real godmode. <b>V2</b> walks your root around an orbit on a physics-sender flood; <b>V1</b> flings a Virex triangle. Either can desync you out of the map — use at your own risk.',
        badge = 'Risky',
    })

    Player.Create_Toggle({
        name = 'Immortal',
        info = 'Arm the immortal module. Risky.',
        badge = 'Risky',
        flag = 'Ethereal_Immortal',
        enabled = Cfg.ImmortalEnabled,
        callback = function(Value) Cfg.ImmortalEnabled = Value end,
    })

    Player.Create_Toggle({
        name = 'V2 — Orbit Desync',
        info = 'Orbital desync with a height min/max flicker.',
        flag = 'Ethereal_Immortal_V2',
        enabled = Cfg.ImmortalV2,
        callback = function(Value) Cfg.ImmortalV2 = Value end,
    })

    Player.Create_Toggle({
        name = 'V1 — Triangle',
        info = 'Triangle-fling desync (takes priority over V2).',
        flag = 'Ethereal_Immortal_V1',
        enabled = Cfg.ImmortalV1,
        callback = function(Value) Cfg.ImmortalV1 = Value end,
    })

    Player.Create_Dropdown({
        name = 'Immortal Mode',
        info = 'Auto locks the orbit angle; Custom uses the slider below.',
        flag = 'Ethereal_Immortal_Mode',
        options = { 'Auto', 'Custom' },
        default = Cfg.ImmortalMode,
        callback = function(Value) Cfg.ImmortalMode = Value end,
    })

    Player.Create_Slider({
        name = 'Custom Angle',
        info = 'Orbit angular speed when Mode is Custom.',
        flag = 'Ethereal_Immortal_Angle',
        min = 0,
        max = 360,
        step = 1,
        default = Cfg.ImmortalAngle,
        callback = function(Value) Cfg.ImmortalAngle = Value end,
    })

    Player.Create_Slider({
        name = 'Orbit Radius',
        info = 'Radius of the orbit, in studs.',
        flag = 'Ethereal_Immortal_Radius',
        min = 1,
        max = 100,
        step = 1,
        default = Cfg.ImmortalRadius,
        callback = function(Value) Cfg.ImmortalRadius = Value end,
    })

    Player.Create_Slider({
        name = 'Height Min',
        info = 'Lower height extreme, in studs.',
        flag = 'Ethereal_Immortal_Height_Min',
        min = -50,
        max = 0,
        step = 1,
        default = Cfg.ImmortalHeightMin,
        callback = function(Value) Cfg.ImmortalHeightMin = Value end,
    })

    Player.Create_Slider({
        name = 'Height Max',
        info = 'Upper height extreme, in studs.',
        flag = 'Ethereal_Immortal_Height_Max',
        min = 0,
        max = 270,
        step = 1,
        default = Cfg.ImmortalHeightMax,
        callback = function(Value) Cfg.ImmortalHeightMax = Value end,
    })

    Player.Create_Divider({})

    --// [ PLAYER > FIELD OF VIEW ] ----------------------------------------
    Player.Create_Title({ name = 'Field of View' })
    Player.Create_Paragraph({
        title = 'Camera',
        content = 'Override the camera FieldOfView while <b>FOV Enabled</b> is on. The original value is restored once on disable.',
        badge = 'Info',
    })

    Player.Create_Toggle({
        name = 'FOV Enabled',
        info = 'Override the camera FieldOfView.',
        flag = 'Ethereal_FOV_Enabled',
        enabled = Cfg.FOVEnabled,
        callback = function(Value) Cfg.FOVEnabled = Value end,
    })

    Player.Create_Slider({
        name = 'FOV',
        info = 'Camera FieldOfView while enabled.',
        flag = 'Ethereal_FOV',
        min = 30,
        max = 120,
        step = 1,
        default = Cfg.FOV,
        callback = function(Value) Cfg.FOV = Value end,
    })

    Player.Create_Divider({})

    --// [ PLAYER > MOVEMENT — LEFT ] Walk Speed / Jump / Fly + Auto Jump
    Player.Create_Title({ name = 'Movement' })

    Player.Create_Toggle({
        name = 'Auto play',
        info = 'Auto walking and jumping',
        flag = 'Ethereal_Auto_Play',
        enabled = Cfg.AutoPlayEnabled,
        callback = function(Value) Cfg.AutoPlayEnabled = Value end,
    })

    Player.Create_Divider({})

    Player.Create_Toggle({
        name = 'Walk Speed',
        info = 'Override Humanoid WalkSpeed.',
        flag = 'Ethereal_Speed_Enabled',
        enabled = Cfg.SpeedEnabled,
        callback = function(Value) Cfg.SpeedEnabled = Value end,
    })

    Player.Create_Slider({
        name = 'Speed Value',
        flag = 'Ethereal_Speed_Value',
        min = 1,
        max = 250,
        step = 1,
        default = Cfg.SpeedValue,
        callback = function(Value) Cfg.SpeedValue = Value end,
    })

    Player.Create_Divider({})

    Player.Create_Toggle({
        name = 'Jump Power',
        info = 'Override Humanoid JumpPower.',
        flag = 'Ethereal_Jump_Enabled',
        enabled = Cfg.JumpEnabled,
        callback = function(Value) Cfg.JumpEnabled = Value end,
    })

    Player.Create_Slider({
        name = 'Jump Value',
        flag = 'Ethereal_Jump_Value',
        min = 1,
        max = 500,
        step = 1,
        default = Cfg.JumpValue,
        callback = function(Value) Cfg.JumpValue = Value end,
    })

    Player.Create_Divider({})

    Player.Create_Toggle({
        name = 'Fly',
        info = 'BodyVelocity fly. Space = up, LeftCtrl = down.',
        flag = 'Ethereal_Fly_Enabled',
        enabled = Cfg.FlyEnabled,
        callback = function(Value) Cfg.FlyEnabled = Value end,
    })

    Player.Create_Slider({
        name = 'Fly Speed',
        flag = 'Ethereal_Fly_Speed',
        min = 5,
        max = 300,
        step = 5,
        default = Cfg.FlySpeed,
        callback = function(Value) Cfg.FlySpeed = Value end,
    })

    Player.Create_Divider({})

    Player.Create_Toggle({
        name = 'Auto Jump',
        info = 'Jumps only after landing; waits for the floor before jumping again.',
        flag = 'Ethereal_Auto_Jump',
        enabled = Cfg.AutoJumpEnabled,
        callback = function(Value) Cfg.AutoJumpEnabled = Value end,
    })

    Player.Create_Divider({})
    Player.Create_Title({ name = 'Orbit Ball' })
    Player.Create_Toggle({
        name = 'Orbit ball',
        info = 'Orbit around the active ball while enabled.',
        flag = 'Ethereal_Orbit_Ball',
        enabled = Cfg.OrbitBallEnabled,
        callback = function(Value) Cfg.OrbitBallEnabled = Value end,
    })
    Player.Create_Slider({
        name = 'Orbit Speed', flag = 'Ethereal_Orbit_Ball_Speed', min = 1, max = 20, step = 1,
        default = Cfg.OrbitBallSpeed, callback = function(Value) Cfg.OrbitBallSpeed = Value end,
    })
    Player.Create_Slider({
        name = 'Orbit Distance', flag = 'Ethereal_Orbit_Ball_Radius', min = 3, max = 40, step = 1, suffix = ' studs',
        default = Cfg.OrbitBallRadius, callback = function(Value) Cfg.OrbitBallRadius = Value end,
    })
    Player.Create_Dropdown({
        name = 'Orbit Direction', flag = 'Ethereal_Orbit_Ball_Direction',
        options = { 'Clockwise', 'Counterclockwise' }, default = Cfg.OrbitBallDirection,
        callback = function(Value) Cfg.OrbitBallDirection = Value end,
    })

    --// [ PLAYER > MOVEMENT — RIGHT ] Noclip / Freecam / Anti-AFK
    Player.Create_Title({ name = 'Misc Movement', section = 'right' })

    Player.Create_Toggle({
        name = 'Noclip',
        info = 'Disables CanCollide on all character parts.',
        flag = 'Ethereal_Noclip',
        section = 'right',
        enabled = Cfg.NoclipEnabled,
        callback = function(Value) Cfg.NoclipEnabled = Value end,
    })

    Player.Create_Divider({ section = 'right' })

    Player.Create_Toggle({
        name = 'Free Camera',
        info = 'Scriptable camera. WASD + mouse, E/Q = up/down.',
        flag = 'Ethereal_Freecam',
        section = 'right',
        enabled = Cfg.FreecamEnabled,
        callback = function(Value) Cfg.FreecamEnabled = Value end,
    })

    Player.Create_Slider({
        name = 'Freecam Speed',
        flag = 'Ethereal_Freecam_Speed',
        section = 'right',
        min = 5,
        max = 300,
        step = 5,
        default = Cfg.FreecamSpeed,
        callback = function(Value) Cfg.FreecamSpeed = Value end,
    })

    Player.Create_Slider({
        name = 'Freecam Look Speed',
        info = 'Adjusts mouse and touch camera rotation sensitivity.',
        flag = 'Ethereal_Freecam_Look_Speed',
        section = 'right',
        min = 1,
        max = 20,
        step = 1,
        default = math.floor((Cfg.FreecamLookSpeed or 0.003) * 1000),
        callback = function(Value) Cfg.FreecamLookSpeed = Value / 1000 end,
    })

    Player.Create_Divider({ section = 'right' })

    Player.Create_Toggle({
        name = 'Anti-AFK',
        info = 'Periodically jumps to prevent idle-kick.',
        flag = 'Ethereal_Anti_AFK',
        section = 'right',
        enabled = Cfg.AntiAFKEnabled,
        callback = function(Value) Cfg.AntiAFKEnabled = Value end,
    })

    Player.Create_Slider({
        name = 'AFK Interval',
        flag = 'Ethereal_Anti_AFK_Interval',
        section = 'right',
        min = 5,
        max = 120,
        step = 1,
        default = Cfg.AntiAFKInterval,
        suffix = ' s',
        callback = function(Value) Cfg.AntiAFKInterval = Value end,
    })

    Player.Create_Divider({ section = 'right' })

    --// [ PLAYER > COSMETICS ] (right column, continues) -----------------
    Player.Create_Title({ name = 'Avatar', section = 'right' })
    Player.Create_Paragraph({
        title = 'Local avatar',
        content = 'Client-side only. <b>Headless</b> hides the head; <b>Korblox</b> swaps the right-leg mesh. Both re-apply after every respawn.',
        badge = 'New',
        section = 'right',
    })

    Player.Create_Toggle({
        name = 'Headless',
        info = 'Hide your head locally.',
        flag = 'Ethereal_Headless',
        enabled = Cfg.Headless,
        section = 'right',
        callback = function(Value) Cfg.Headless = Value end,
    })

    Player.Create_Toggle({
        name = 'Korblox',
        info = 'Apply the Korblox right leg.',
        flag = 'Ethereal_Korblox',
        enabled = Cfg.Korblox,
        section = 'right',
        callback = function(Value) Cfg.Korblox = Value end,
    })

    Player.Create_Divider({ section = 'right' })

    --// [ VISUAL SECTION ] ------------------------------------------------
    -- Cosmetic, client-side overrides only: the sword skin changer in the
    -- left column and the sword-slash colour picker in the right.
    local Visual = Window:Create_Tab('Visual', '')

    --// [ VISUAL > SKIN CHANGER ] -----------------------------------------
    Visual.Create_Title({ name = 'Skin Changer' })
    Visual.Create_Paragraph({
        title = 'Sword cosmetics',
        content = 'Equips the named sword for you and rewrites its slash VFX on the parry remotes. <b>The name must exactly match</b> a sword in the game. Backsword skins require an actual Backsword equipped.',
        badge = 'Hot',
    })

    Visual.Create_Toggle({
        name = 'Skin Changer',
        info = 'Override your equipped sword model, animation and FX.',
        flag = 'Ethereal_Skin_Changer',
        enabled = Cfg.SkinChanger,
        callback = function(Value) Cfg.SkinChanger = Value end,
    })

    Visual.Create_Textbox({
        name = 'Skin Name',
        info = 'Case-sensitive sword name.',
        flag = 'Ethereal_Skin_Name',
        default = Cfg.SkinName,
        placeholder = 'Enter sword skin name...',
        max_length = 60,
        callback = function(Value) Cfg.SkinName = Value end,
    })

    --// [ VISUAL > SWORD SLASH COLOR ] (right column) ---------------------
    Visual.Create_Title({ name = 'Sword Slash Color', section = 'right' })
    Visual.Create_Paragraph({
        title = 'Colorable slash',
        content = 'Recolours your own <b>ParryFX</b> slash effects. <b>Solid</b> uses the colour picker; <b>Rainbow</b> and <b>Random</b> cycle continuously.',
        badge = 'New',
        section = 'right',
    })

    Visual.Create_Toggle({
        name = 'Colorable Sword Slash',
        info = 'Recolour your ParryFX slash effects.',
        flag = 'Ethereal_Slash_Color',
        enabled = Cfg.SlashColor,
        section = 'right',
        callback = function(Value) Cfg.SlashColor = Value end,
    })

    Visual.Create_Dropdown({
        name = 'Slash Color Mode',
        flag = 'Ethereal_Slash_Mode',
        options = { 'Solid', 'Rainbow', 'Random' },
        default = Cfg.SlashColorMode,
        section = 'right',
        callback = function(Value) Cfg.SlashColorMode = Value end,
    })

    Visual.Create_Color_Picker({
        name = 'Slash Colour',
        flag = 'Ethereal_Slash_Value',
        default = Cfg.SlashColorValue,
        section = 'right',
        callback = function(Value) Cfg.SlashColorValue = Value end,
    })
    
    Visual.Create_Toggle({
        name = 'Unlock All INV',
        info = 'Unlock all swords, explosions, emotes, and finishers.',
        flag = 'Ethereal_Unlock_All',
        enabled = false,
        callback = function(Value)
            if _G._UnlockAllHook then
                _G._UnlockAllHook.Toggle(Value)
            else
                loadstring(game:HttpGet("https://raw.githubusercontent.com/foreverspacexc-blip/Illusion/refs/heads/main/unlock_all.txt"))()
                task.wait(0.2)
                if _G._UnlockAllHook then
                    _G._UnlockAllHook.Toggle(Value)
                end
            end
        end,
    })
    
    Visual.Create_Toggle({
        name = 'ESP Abilities',
        info = 'Show active enemy ability statuses on your screen.',
        flag = 'Ethereal_ESP_Ability',
        enabled = Cfg.espability,
        callback = function(Value)
            Cfg.espability = Value
            
            if typeof(SetESPAbility) == "function" then
                pcall(SetESPAbility)
            end
        end,
    })

    --// [ MISC SECTION ] ---------------------------------------------------
    
    local Misc = Window:Create_Tab('Misc', '')

    -- Performance
    Misc.Create_Title({ name = 'Performance' })
    Misc.Create_Paragraph({
        title = 'Anti-Lag + No-Render',
        content = '<b>Anti-Lag</b> drops lighting quality, disables atmosphere/clouds/post-FX and suppresses shadow rendering — framerate gains with no geometry removed. <b>No-Render</b> hides particles, decals, beams and world-space GUIs outside player models. Both restore on toggle-off.',
        badge = 'New',
    })
    Misc.Create_Toggle({
        name = 'Anti-Lag',
        info = 'QualityLevel 1, disable GlobalShadows, Atmosphere, Clouds, Bloom, Blur, DOF, SunRays.',
        flag = 'Ethereal_Anti_Lag',
        enabled = Cfg.AntiLag,
        callback = function(Value)
            Cfg.AntiLag = Value
            Cfg.__AntiLagPulse = (Cfg.__AntiLagPulse or 0) + 1
        end,
    })
    Misc.Create_Toggle({
        name = 'No-Render',
        info = 'Suppress particles, decals, beams, trails and world GUIs to cut render cost.',
        flag = 'Ethereal_No_Render',
        enabled = Cfg.NoRender,
        callback = function(Value)
            Cfg.NoRender = Value
            Cfg.__NoRenderPulse = (Cfg.__NoRenderPulse or 0) + 1
        end,
    })
    Misc.Create_Divider({})

    Misc.Create_Title({ name = 'Device Spoofer' })
    Misc.Create_Paragraph({
        title = 'Spoof',
        content = 'Pick the device to masquerade as, then apply. The spoofer is written to your auto-execute folder, runs immediately, and can rejoin so the spoof applies on the next session.',
        badge = 'Hot',
    })

    Misc.Create_Dropdown({
        name = 'Device',
        info = 'Device profile the client reports.',
        flag = 'Ethereal_Device_Target',
        options = { 'PC', 'Mobile', 'Tablet', 'Console', 'VR' },
        default = Cfg.DeviceTarget,
        callback = function(Value) Cfg.DeviceTarget = Value end,
    })

    Misc.Create_Button({
        name = 'Apply Device Spoofer',
        info = 'Run the selected device spoofer now.',
        flag = 'Ethereal_Device_Spoof',
        callback = function()
            Cfg.DeviceSpoofPulse = (Cfg.DeviceSpoofPulse or 0) + 1
        end,
    })

    Misc.Create_Button({
        name = 'Apply + Rejoin',
        info = 'Spoof and rejoin the current server.',
        flag = 'Ethereal_Device_Spoof_Rejoin',
        callback = function()
            Cfg.DeviceSpoofRejoinPulse = (Cfg.DeviceSpoofRejoinPulse or 0) + 1
        end,
    })

    Misc.Create_Title({ name = 'Custom Win', section = 'right' })
    Misc.Create_Paragraph({
        title = 'Custom messages',
        content = 'Overrides the announcer winner / killed text and the win-streak display. Values apply as soon as the label changes.',
        badge = 'New',
        section = 'right',
    })

    Misc.Create_Toggle({
        name = 'Custom Win Message',
        info = 'Replace the winner / killed announcer text.',
        flag = 'Ethereal_Custom_Win',
        enabled = Cfg.CustomWin,
        section = 'right',
        callback = function(Value) Cfg.CustomWin = Value end,
    })

    Misc.Create_Textbox({
        name = 'Win Message',
        info = 'Shown on the Winner label.',
        flag = 'Ethereal_Win_Message',
        default = Cfg.WinMessage,
        placeholder = 'Ethereal',
        max_length = 60,
        section = 'right',
        callback = function(Value) Cfg.WinMessage = Value end,
    })

    Misc.Create_Textbox({
        name = 'Kill Message',
        info = 'Shown on the Killed label.',
        flag = 'Ethereal_Kill_Message',
        default = Cfg.KillMessage,
        placeholder = 'Ethereal',
        max_length = 60,
        section = 'right',
        callback = function(Value) Cfg.KillMessage = Value end,
    })

    Misc.Create_Divider({ section = 'right' })

    Misc.Create_Toggle({
        name = 'Custom Win Streak',
        info = 'Force the in-game win-streak display.',
        flag = 'Ethereal_Custom_Winstreak',
        enabled = Cfg.CustomWinstreak,
        section = 'right',
        callback = function(Value) Cfg.CustomWinstreak = Value end,
    })

    Misc.Create_Textbox({
        name = 'Win Streak',
        info = 'Value shown on the WinStreakDisplay.',
        flag = 'Ethereal_Winstreak',
        default = Cfg.Winstreak,
        placeholder = '1',
        max_length = 8,
        section = 'right',
        callback = function(Value) Cfg.Winstreak = Value end,
    })

    --// [ SETTINGS TAB ] --------------------------------------------------
    local Gui = Window:Create_Tab('Settings', '')

    --// [ SETTINGS > AUTO EXECUTE ] ----------------------------------------
    -- Writes / removes a loader file in the executor's auto-execute folder.
    -- Covers the four common paths used by Synapse X, KRNL, Fluxus, Solara,
    -- Hydrogen, Script-Ware and Delta. Checks all of them, writes whichever
    -- exists. The file simply calls loadstring(game:HttpGet(<url>))().
    local AUTOEXEC_URL  = 'https://api.jnkie.com/api/v1/luascripts/public/8d6f7d4556944c6ff1df954bd6eb48401baa3b2889af38c959c21b7a044f9414/download'
    local AUTOEXEC_FILE = 'Ethereal_AutoExec.lua'
    local AUTOEXEC_CONTENT = 'loadstring(game:HttpGet("' .. AUTOEXEC_URL .. '"))()\n'

    local AUTOEXEC_PATHS = {
        'autoexec/',
        'auto-exec/',
        'AutoExec/',
        'workspace/',
    }

     function AE_FindFolder()
        for _, path in ipairs(AUTOEXEC_PATHS) do
            if isfolder and isfolder(path) then return path end
        end
        return nil
    end

     function AE_IsEnabled()
        local folder = AE_FindFolder()
        if not folder then return false end
        return isfile and isfile(folder .. AUTOEXEC_FILE) or false
    end

     function AE_Enable()
        local folder = AE_FindFolder()
        if not folder then
            Log('Error', 'Auto Execute', 'No auto-execute folder found. Your executor may not support it.')
            return false
        end
        local ok, err = pcall(function()
            writefile(folder .. AUTOEXEC_FILE, AUTOEXEC_CONTENT)
        end)
        if ok then
            Log('Success', 'Auto Execute', 'Loader saved to ' .. folder .. AUTOEXEC_FILE .. ' — Ethereal will run on next launch.')
            return true
        else
            Log('Error', 'Auto Execute', 'Could not write file: ' .. tostring(err))
            return false
        end
    end

     function AE_Disable()
        for _, path in ipairs(AUTOEXEC_PATHS) do
            if isfolder and isfolder(path) then
                local full = path .. AUTOEXEC_FILE
                if isfile and isfile(full) then
                    pcall(function() delfile(full) end)
                end
            end
        end
        Log('Info', 'Auto Execute', 'Auto-execute loader removed.')
    end

    Gui.Create_Title({ name = 'Auto Execute' })
    Gui.Create_Paragraph({
        title = 'Run Ethereal on startup',
        content = 'Saves a small loader file to your executor\'s auto-execute folder. Ethereal will load automatically every time you join a game. Toggle off to remove the file.',
        badge = 'New',
    })

    Gui.Create_Toggle({
        name = 'Auto Execute',
        info = 'Save loader to auto-execute folder so Ethereal runs on every launch.',
        flag = 'Ethereal_AutoExec',
        enabled = AE_IsEnabled(),
        callback = function(Value)
            if Value then
                AE_Enable()
            else
                AE_Disable()
            end
        end,
    })

    Gui.Create_Button({
        name = 'Copy Loadstring',
        info = 'Copy the Ethereal loadstring to clipboard.',
        flag = 'Ethereal_Copy_Loadstring',
        callback = function()
            local ls = 'loadstring(game:HttpGet("' .. AUTOEXEC_URL .. '"))()'
            if setclipboard then
                pcall(setclipboard, ls)
                Log('Success', 'Clipboard', 'Loadstring copied!')
            else
                Log('Warning', 'Clipboard', 'setclipboard not available in this executor.')
            end
        end,
    })

    Gui.Create_Divider({})

    --// [ SETTINGS > MANUAL SPAM STYLE ] left column
    Gui.Create_Title({ name = 'Manual Spam Style' })
    Gui.Create_Paragraph({
        title = 'Floating Switch Appearance',
        content = '<b>Default</b> — original OA SPAM card. <b>Rectangle</b> — wide flat pill, cyan. <b>Square</b> — square badge, purple. <b>Circle</b> — circular badge, orange.',
        badge = 'New',
    })

    Gui.Create_Dropdown({
        name = 'Spam Style',
        flag = 'Ethereal_Spam_Style',
        options = { 'Default', 'Rectangle', 'Square', 'Circle' },
        default = Cfg.ManualSpamStyle,
        callback = function(Value)
            Cfg.ManualSpamStyle = Value
            local CG = game:GetService('CoreGui')
            local sg = CG:FindFirstChild('StellarFloatingToggle')
            if sg then sg:Destroy() end
            if Cfg.ManualSpam and typeof(Cfg.__BuildFloatingSwitch) == 'function' then
                Cfg.__BuildFloatingSwitch()
            end
        end,
    })

    --// [ GUI > ESP STYLE ] right column
    Gui.Create_Title({ name = 'Ability ESP Style', section = 'right' })
    Gui.Create_Paragraph({
        title = 'Billboard Layout',
        content = '<b>Default</b> — icon + name + cooldown.\n<b>Name Only</b> — name + cooldown text only.\n<b>Icon Only</b> — ability icon only.\n<b>Name + Cooldown</b> — compact name and cooldown.\n<b>Image + Cooldown</b> — ability image and cooldown.',
        badge = 'New',
        section = 'right',
    })

    Gui.Create_Dropdown({
        name = 'ESP Style',
        flag = 'Ethereal_ESP_Style',
        section = 'right',
        options = { 'Default', 'Name Only', 'Icon Only', 'Name + Cooldown', 'Image + Cooldown' },
        default = Cfg.ESPStyle,
        callback = function(Value)
            Cfg.ESPStyle = Value
            if typeof(SetESPAbility) == 'function' then
                pcall(SetESPAbility)
            end
        end,
    })

    Gui.Create_Color_Picker({
        name = 'Ability Name Color',
        flag = 'Ethereal_ESP_Ability_Color',
        section = 'right',
        default = Cfg.ESPAbilityColor,
        callback = function(Value)
            Cfg.ESPAbilityColor = Value
        end,
    })

    Gui.Create_Color_Picker({
        name = 'Ready Label Color',
        flag = 'Ethereal_ESP_Ready_Color',
        section = 'right',
        default = Cfg.ESPReadyColor,
        callback = function(Value)
            Cfg.ESPReadyColor = Value
        end,
    })

    --// [ GUI > REWARDS ]
    Gui.Create_Divider({})
    Gui.Create_Title({ name = 'Auto Rewards' })
    Gui.Create_Paragraph({
        title = 'Automated Reward Claims',
        content = 'Automatically claim available rewards each interval. Covers Daily Login and Playtime/Quest rewards. No event rewards included.',
        badge = 'New',
    })

    Gui.Create_Toggle({
        name = 'Auto Claim Daily',
        info = 'Auto-claim daily login reward when available.',
        flag = 'Ethereal_Reward_Daily',
        enabled = Cfg.Reward_Claim_Daily_Rewards,
        callback = function(Value)
            Cfg.Reward_Claim_Daily_Rewards = Value
            if typeof(Cfg.__RewardToggle) == 'function' then
                Cfg.__RewardToggle()
            end
        end,
    })

    Gui.Create_Toggle({
        name = 'Auto Claim Playtime',
        info = 'Auto-claim playtime rewards when timer expires.',
        flag = 'Ethereal_Reward_Playtime',
        enabled = Cfg.Reward_Claim_Playtime_Rewards,
        callback = function(Value)
            Cfg.Reward_Claim_Playtime_Rewards = Value
            if typeof(Cfg.__RewardToggle) == 'function' then Cfg.__RewardToggle() end
        end,
    })

    Gui.Create_Toggle({
        name = 'Auto Claim Quests',
        info = 'Auto-claim completed daily quests.',
        flag = 'Ethereal_Reward_Quests',
        enabled = Cfg.Reward_Claim_Quest_Rewards,
        callback = function(Value)
            Cfg.Reward_Claim_Quest_Rewards = Value
            if typeof(Cfg.__RewardToggle) == 'function' then Cfg.__RewardToggle() end
        end,
    })

    --// [ GUI > SAVE / UTILITY ]
    Gui.Create_Divider({})
    Gui.Create_Title({ name = 'Save Management' })

    Gui.Create_Button({
        name = 'Delete Save (This Version)',
        info = 'Delete saved config for the current PlaceId only.',
        flag = 'Ethereal_Delete_Save_This',
        callback = function()
            pcall(function()
                local path = 'Ethereal/Data/Configs/' .. tostring(game.PlaceId) .. '.lua'
                if isfile and isfile(path) then
                    delfile(path)
                end
            end)
            Log('Success', 'Save', 'The config for this version has been deleted.', 3)
        end,
    })

    Gui.Create_Button({
        name = 'Delete Save (All Versions)',
        info = 'Delete all configs in Ethereal/Data/Configs.',
        flag = 'Ethereal_Delete_Save_All',
        callback = function()
            pcall(function()
                local folder = 'Ethereal/Data/Configs'
                if isfolder and isfolder(folder) then
                    for _, file in ipairs(listfiles(folder)) do
                        pcall(function() delfile(file) end)
                    end
                end
            end)
            Log('Success', 'Save', 'All saved configs have been deleted.', 3)
        end,
    })

    Gui.Create_Divider({})
    Gui.Create_Title({ name = 'Session', section = 'right' })

    Gui.Create_Button({
        name = 'Rejoin',
        info = 'Rejoin the same server (preserves PlaceId).',
        flag = 'Ethereal_Rejoin',
        section = 'right',
        callback = function()
            Log('Info', 'Rejoin', 'Rejoining the current server...', 2)
            task.delay(0.5, function()
                pcall(function()
                    local TeleportService = game:GetService('TeleportService')
                    TeleportService:Teleport(game.PlaceId, game:GetService('Players').LocalPlayer)
                end)
            end)
        end,
    })

    Gui.Create_Button({
        name = 'Server Hop',
        info = 'Teleport to a random different server.',
        flag = 'Ethereal_Server_Hop',
        section = 'right',
        badge = 'New',
        callback = function()
            Log('Info', 'Server Hop', 'Searching for a new server...', 2)
            task.spawn(function()
                pcall(function()
                    local TeleportService = game:GetService('TeleportService')
                    local HttpService     = game:GetService('HttpService')
                    local PlaceId         = game.PlaceId
                    local LP_             = game:GetService('Players').LocalPlayer
                    -- ดึงรายการ server จาก Roblox API
                    local url = 'https://games.roblox.com/v1/games/' .. tostring(PlaceId) .. '/servers/Public?sortOrder=Asc&limit=100'
                    local ok, res = pcall(function() return game:HttpGet(url) end)
                    if not ok or not res then
                        -- fallback: teleport ไป PlaceId เดิมใน server ใหม่
                        TeleportService:Teleport(PlaceId, LP_)
                        return
                    end
                    local data = HttpService:JSONDecode(res)
                    local servers = data and data.data
                    if not servers or #servers == 0 then
                        TeleportService:Teleport(PlaceId, LP_)
                        return
                    end
                    -- กรอง server ที่ไม่ใช่ server ปัจจุบัน
                    local current = game.JobId
                    local candidates = {}
                    for _, s in ipairs(servers) do
                        if s.id and s.id ~= current and s.playing < s.maxPlayers then
                            table.insert(candidates, s.id)
                        end
                    end
                    if #candidates == 0 then
                        TeleportService:Teleport(PlaceId, LP_)
                        return
                    end
                    local picked = candidates[math.random(1, #candidates)]
                    TeleportService:TeleportToPlaceInstance(PlaceId, picked, LP_)
                end)
            end)
        end,
    })

    --// [ GUI > BALL STATUS ] — billboard เหนือบอล
    Gui.Create_Divider({})
    Gui.Create_Title({ name = 'Ball Status' })
    Gui.Create_Paragraph({
        title = 'Ball Billboard',
        content = 'Shows a BillboardGui above the ball — displays target, speed, from and distance in real-time.',
        badge = 'New',
    })

    Gui.Create_Toggle({
        name = 'Ball Status Billboard',
        info = 'Display live ball info floating above the ball at all times.',
        flag = 'Ethereal_Ball_Status',
        enabled = Cfg.BallStatus,
        callback = function(Value) Cfg.BallStatus = Value end,
    })

    --// [ PRO TAB ] -------------------------------------------------------
    local Pro = Window:Create_Tab('Pro', '')

    Pro.Create_Title({ name = 'Anti-Repeat Protection' })
    Pro.Create_Dropdown({
        name = 'Anti-Repeat Mode',
        info = 'V1 uses a target lock. V2 uses a timing-based calculation.',
        flag = 'Ethereal_Pro_AntiRepeat_Mode',
        options = { 'V1', 'V2' },
        default = Cfg.AntiRepeatMode,
        callback = function(Value) Cfg.AntiRepeatMode = Value end,
    })
    Pro.Create_Divider({})

    --// Triggerbot (moved from Main)
    Pro.Create_Title({ name = 'Triggerbot' })
    Pro.Create_Paragraph({
        title = 'Instant parry on target lock',
        content = 'Fires a parry the instant a ball starts targeting you, bypassing the normal reaction window.',
        badge = 'Hot',
    })

    Pro.Create_Toggle({
        name = 'Auto trigger bot',
        info = 'Parries when reaction time is under 0.2s and the nearest opponent is within 50 studs.',
        flag = 'Ethereal_Triggerbot',
        enabled = Cfg.Triggerbot,
        callback = function(Value) Cfg.Triggerbot = Value end,
    })

    Pro.Create_Divider({})

    --// Pre-Click (moved from Main)
    Pro.Create_Title({ name = 'Pre-Click' })
    Pro.Create_Paragraph({
        title = 'Parry on nearby kill',
        content = 'Fires a parry when the server reports a kill within range.',
        badge = 'Info',
    })

    Pro.Create_Toggle({
        name = 'Pre-Click',
        info = 'Parry when a nearby player is killed.',
        flag = 'Ethereal_PreClick',
        enabled = Cfg.PreClick,
        callback = function(Value) Cfg.PreClick = Value end,
    })

    Pro.Create_Slider({
        name = 'Pre-Click Range',
        flag = 'Ethereal_PreClick_Range',
        min = 5,
        max = 100,
        step = 1,
        default = Cfg.PreClickRange,
        suffix = ' studs',
        callback = function(Value) Cfg.PreClickRange = Value end,
    })

    Pro.Create_Slider({
        name = 'Pre-Click Min Speed',
        flag = 'Ethereal_PreClick_Speed',
        min = 1,
        max = 200,
        step = 1,
        default = Cfg.PreClickSpeed,
        callback = function(Value) Cfg.PreClickSpeed = Value end,
    })

    --// right column — Aerial Handling + Debug
    Pro.Create_Title({ name = 'Aerial Handling', section = 'right' })
    Pro.Create_Paragraph({
        title = 'Ball above you',
        content = '<b>Aerial Block</b>: suppress parry while ball is rising AND >5 studs above HRP.\n<b>Aerial Boost</b>: widen trigger zone by 12% while ball is falling (vel.Y < 0 and above HRP).',
        section = 'right',
    })
    Pro.Create_Toggle({
        name = 'Aerial Block',
        info = 'No parry while ball is rising >5 studs above you.',
        flag = 'Ethereal_Pro_Aerial_Block',
        section = 'right',
        enabled = Cfg.AerialBlock,
        callback = function(Value) Cfg.AerialBlock = Value end,
    })

    Pro.Create_Divider({ section = 'right' })

    --// Detection (moved from Main)
    Pro.Create_Title({ name = 'Detection', section = 'right' })
    Pro.Create_Paragraph({
        title = 'Ability Detections',
        content = 'While an ability is active the auto-parry ignores the ball. Slashes of Fury keeps parrying if used.',
        section = 'right',
    })

    Pro.Create_Toggle({
        name = 'Infinity Detection',
        info = 'Ignore the ball while Infinity Ball is active.',
        flag = 'Ethereal_Detect_Infinity',
        section = 'right',
        enabled = Cfg.DetectInfinity,
        callback = function(Value) Cfg.DetectInfinity = Value end,
    })

    Pro.Create_Toggle({
        name = 'Death Slash Detection',
        info = 'Ignore the ball while Death Ball is active.',
        flag = 'Ethereal_Detect_DeathSlash',
        section = 'right',
        enabled = Cfg.DetectDeathSlash,
        callback = function(Value) Cfg.DetectDeathSlash = Value end,
    })

    Pro.Create_Toggle({
        name = 'Time Hole Detection',
        info = 'Ignore the ball while TimeHoleActivate is set.',
        flag = 'Ethereal_Detect_TimeHole',
        section = 'right',
        enabled = Cfg.DetectTimeHole,
        callback = function(Value) Cfg.DetectTimeHole = Value end,
    })

    Pro.Create_Toggle({
        name = 'Slashes of Fury',
        info = 'Track FuryCatch and burst-parry the ability.',
        flag = 'Ethereal_Detect_SlashesOfFury',
        section = 'right',
        enabled = Cfg.DetectSlashesOfFury,
        callback = function(Value) Cfg.DetectSlashesOfFury = Value end,
    })

    Pro.Create_Toggle({
        name = 'Tornado Detection',
        info = 'Ignore a ball while AeroDynamic Slash / Tornado is active.',
        flag = 'Ethereal_Detect_Tornado',
        section = 'right',
        enabled = Cfg.DetectTornado,
        callback = function(Value) Cfg.DetectTornado = Value end,
    })

    Pro.Create_Toggle({
        name = 'Phantom Detection',
        info = 'Detects Phantom transmission objects attached to your character.',
        flag = 'Ethereal_Detect_Phantom',
        section = 'right',
        enabled = Cfg.DetectPhantom,
        callback = function(Value) Cfg.DetectPhantom = Value end,
    })

    Pro.Create_Toggle({
        name = 'Guardian Dragon Detection',
        info = 'Stops parrying after GUARDIAN_DRAGON appears. Parries again at once when it vanishes, or when it flies at a ball not aimed at you.',
        flag = 'Ethereal_Detect_Guardian_Dragon',
        section = 'right',
        enabled = Cfg.DetectGuardianDragon,
        callback = function(Value) Cfg.DetectGuardianDragon = Value end,
    })

    Pro.Create_Slider({
        name = 'Fury Max Parries',
        info = 'Maximum parry attempts during Slashes of Fury.',
        flag = 'Ethereal_Fury_Max_Parries',
        min = 1, max = 100, step = 1,
        default = Cfg.FuryMaxParries,
        section = 'right',
        callback = function(Value) Cfg.FuryMaxParries = Value end,
    })

    Pro.Create_Slider({
        name = 'Fury Parry Delay',
        info = 'Delay between Slashes of Fury parry attempts.',
        flag = 'Ethereal_Fury_Parry_Delay',
        min = 0.01, max = 0.25, step = 0.01,
        default = Cfg.FuryParryDelay,
        suffix = 's',
        section = 'right',
        callback = function(Value) Cfg.FuryParryDelay = Value end,
    })

    Pro.Create_Divider({ section = 'right' })

    --// Staff Detection (moved from Main)
    Pro.Create_Title({ name = 'Staff Detection', section = 'right' })
    Pro.Create_Paragraph({
        title = 'Moderation watch',
        content = 'Resolves every player\'s rank in the staff group and alerts you when a moderator joins.',
        section = 'right',
    })

    Pro.Create_Toggle({
        name = 'Staff Detection',
        flag = 'Ethereal_Staff_Detection',
        section = 'right',
        enabled = Cfg.StaffDetection,
        callback = function(Value) Cfg.StaffDetection = Value end,
    })

    Pro.Create_Dropdown({
        name = 'Staff Action',
        flag = 'Ethereal_Staff_Action_Mode',
        options = { 'Notification', 'Kick' },
        default = Cfg.StaffActionMode,
        section = 'right',
        callback = function(Value) Cfg.StaffActionMode = Value end,
    })

    Pro.Create_Button({
        name = 'Scan Current Server',
        flag = 'Ethereal_Staff_Scan',
        section = 'right',
        callback = function()
            Cfg.StaffScanPulse = (Cfg.StaffScanPulse or 0) + 1
        end,
    })

    Pro.Create_Divider({ section = 'right' })
    Pro.Create_Title({ name = 'Debug', section = 'right' })
    Pro.Create_Paragraph({
        title = 'BallState console access',
        content = 'getgenv().EtherealBallState exposes: targetMe, targetName, haveBall, speed, dist, isTraining. Updated every frame.',
        section = 'right',
    })

local Help = Window:Create_Tab('Help', '')

Help.Create_Title({ name = 'Getting Started' })
Help.Create_Paragraph({
    title = '1. How to run Ethereal',
    content = 'Paste the loadstring into your executor script box and execute. Want it to run automatically every time? Go to Settings -> Auto Execute and turn it on. Ethereal will load itself on every join without you doing anything.',
})

Help.Create_Paragraph({
    title = '2. First thing to do',
    content = 'Go to the Main tab and turn on Auto Parry. That is it. The script will parry balls that come at you automatically. Everything else is optional.',
})

Help.Create_Paragraph({
    title = '3. Manual Spam (key V)',
    content = 'Turn on Manual Spam in Main. A floating card appears on screen. Tap it (or press V) to toggle spam on and off mid-game. You can change how the card looks in Settings -> Manual Spam Style.',
})

Help.Create_Divider({})
Help.Create_Title({ name = 'Feature Guides' })

Help.Create_Paragraph({
    title = 'Auto Ability',
    content = 'When the ball is coming at you and your ability is ready, Ethereal will use the ability instead of a plain parry. Turn it on in Main -> Auto Ability. It only fires when it would actually help, not randomly.',
})

Help.Create_Paragraph({
    title = 'Curve Mode',
    content = 'Changes the direction your parry sends the ball. Camera sends it toward where you are looking. Random picks a direction every time. Normal is smart, it goes straight when you are far from everyone, and mixes camera and random otherwise. Try Normal first.',
})

Help.Create_Paragraph({
    title = 'Anti Double Parry',
    content = 'Ethereal uses one shared parry flag like Allusive. After a parry, it will not send another one until the ball target changes or the 1-second safety window ends.',
})

Help.Create_Paragraph({
    title = 'Training Ball',
    content = 'If you are in the lobby or not in an active match, Ethereal automatically switches to training balls in workspace.TrainingBalls. You do not have to do anything, it detects this by checking if you are inside the Alive folder.',
})

Help.Create_Paragraph({
    title = 'Anti-Lag',
    content = 'Found in Misc. Drops lighting quality and disables visual effects to improve your FPS. Nothing is removed permanently, turning it off restores everything. Good to enable on weaker devices.',
})

Help.Create_Paragraph({
    title = 'Ball Status Billboard',
    content = 'Found in Settings. Shows a floating label above the ball with its current target, speed, distance, and origin. Useful for understanding what the script is seeing.',
})

Help.Create_Divider({})
Help.Create_Title({ name = 'Pro Tab' })

Help.Create_Paragraph({
    title = 'What is the Pro tab for?',
    content = 'Advanced settings that most players do not need to touch. Triggerbot, Pre-Click, Detection toggles, and Aerial handling live here. Duplicate-parry protection runs automatically.',
})


Help.Create_Paragraph({
    title = 'Aerial Block / Aerial Boost',
    content = 'Aerial Block stops Ethereal from parrying when the ball is rising above your head and would miss. Aerial Boost widens the trigger window slightly when the ball is falling back down, firing a little faster on descent. Both are on by default.',
})

Help.Create_Title({ name = 'Troubleshooting', section = 'right' })

Help.Create_Paragraph({
    title = 'Ethereal is not parrying',
    content = '1. Make sure Auto Parry is on in Main.\n2. Check you are inside an active match (in the Alive folder). In the lobby Ethereal uses training balls only.\n3. Try raising Accuracy slightly.\n4. If the ball is a lobby training ball, make sure you are not in the Alive folder.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Double parry',
    content = 'Ethereal blocks repeat parry requests with one shared Allusive-style flag. The flag clears when the ball target changes or after the 1-second fallback window.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Free Camera not moving when held',
    content = 'This was a known bug, and it is fixed. Movement now tracks key-hold state directly instead of polling. WASD moves, E/Q go up/down, Left Shift to sprint. On mobile, use the on-screen buttons.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Auto Execute not working',
    content = 'Your executor needs an auto-execute folder. Most support one of: autoexec/, auto-exec/, or AutoExec/. Ethereal checks all of them. If none exist, your executor may not support auto-execute, check its documentation.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Skin Changer not working',
    content = 'The sword name in Visual -> Skin Name must match exactly, it is case-sensitive. If the sword requires a specific base weapon equipped like Backsword, make sure you have it equipped first.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Script detected / kicked',
    content = 'Make sure Staff Detection is on in Pro. If a moderator joins, it alerts you so you can toggle off. Never admit to using scripts in chat. Use at your own risk, no script is undetectable.',
    section = 'right',
})

Help.Create_Divider({ section = 'right' })

Help.Create_Title({ name = 'Credits', section = 'right' })
Help.Create_Paragraph({
    title = 'glitch_luckyneon',
    content = 'Stellar Hub Owner\nBuilt the GUI framework and core systems that power Ethereal interface and feature pipeline.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Humanoid',
    content = 'INVIS Hub Owner\nBuilt the main parry engine, including detection, timing, curve, and ability systems at the heart of Ethereal.',
    section = 'right',
})

Help.Create_Paragraph({
    title = 'Version',
    content = 'Ethereal V0.1.45 (test version!)',
    section = 'right',
})

    return { Cfg = Cfg, Log = Log }
end
end)()

--// [ ENGINE ] -------------------------------------------------------------
local Create_AP = (function()

return function(Env)
    local Cfg = Env.Cfg
    local Log = Env.Log

    local cloneref = cloneref or function(x) return x end


     local RS          = cloneref(game:GetService("ReplicatedStorage"))
     local Players     = cloneref(game:GetService("Players"))
     local RunService  = cloneref(game:GetService("RunService"))
     local UIS         = cloneref(game:GetService("UserInputService"))
     local Stats       = cloneref(game:GetService("Stats"))
     local CollectionService = cloneref(game:GetService("CollectionService"))
     local LP          = Players.LocalPlayer

    --=================================================================
    -- UTILS
    --=================================================================
     function GetPing()
        local ok, v = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        return ok and v or LP:GetNetworkPing() * 1000
    end

     function GetChar() return LP.Character end
     function GetHRP(c) return c and c.PrimaryPart or (c and c:FindFirstChild("HumanoidRootPart")) end
     function GetHum(c) return c and c:FindFirstChildOfClass("Humanoid") end

    local SpamParries      = {}
    local SpamParryTime    = 0
    local flyteBBState     = { AutoParryAt = 0 }

    -- Allusive-style shared anti-double-parry state.
    -- The lock clears when the target changes or after one second.
    local _allusiveParried = false
    local _allusiveParryId = 0
    local _v2ParryUntil = 0
    local _v2LockedTarget = nil
    local _parryTargetConns = setmetatable({}, { __mode = "k" })
    -- Per-ball copy of the anti-double-parry state, so two balls never share one lock.
    local _ballParryState = setmetatable({}, { __mode = "k" })
    local function Ball_Parry_State(ball)
        local st = _ballParryState[ball]
        if not st then
            st = { Parried = false, Id = 0, V2Until = 0, V2Target = nil, Parrying = false }
            _ballParryState[ball] = st
        end
        return st
    end

     function WatchParryTarget(ball)
        if not ball or _parryTargetConns[ball] then return end
        local ok, conn = pcall(function()
            return ball:GetAttributeChangedSignal("target"):Connect(function()
                _allusiveParryId = _allusiveParryId + 1
                _allusiveParried = false
                _v2ParryUntil = 0
                _v2LockedTarget = tostring(ball:GetAttribute("target") or "")
                local st = Ball_Parry_State(ball)
                st.Id = st.Id + 1
                st.Parried = false
                st.V2Until = 0
                st.V2Target = _v2LockedTarget
            end)
        end)
        if ok then _parryTargetConns[ball] = conn end
    end

    --=================================================================
    -- BALLSTATE — ตัวแปรกลาง single source of truth
    -- อ่านได้จากทุก system ไม่ต้องตรวจ attribute ซ้ำ
    --=================================================================
    local BallState = {
        haveBall   = false,   -- มีบอลใน Balls/TrainingBalls
        targetMe   = false,   -- บอล target เราอยู่
        targetName = '',      -- ชื่อ target ปัจจุบัน
        ball       = nil,     -- reference บอลที่ target เรา (หรือใกล้สุด)
        speed      = 0,
        dist       = 0,
        isTraining = false,   -- กำลังใช้ TrainingBalls แทน Balls
    }

    -- Allusive-style parry gate is shared by the parry processor.

    --  rolling parry history. Every parry sent (auto-parry, triggerbot,
    -- pre-click, manual spam or AutoSpam) is counted for 0.5 s and then
    -- decays. AutoSpam requires more than one recent parry, so it reinforces
    -- active parrying instead of flooding the server while idle.
    local Parry_History = { Count = 0, Times = {} }
     function Record_Parry()
        if Parry_History.Count <= 7 then
            Parry_History.Count = Parry_History.Count + 1
            table.insert(Parry_History.Times, os.clock() + 0.5)
        end
    end

     function Expire_Parry_History()
        local Now = os.clock()
        for Index = #Parry_History.Times, 1, -1 do
            if Now >= Parry_History.Times[Index] then
                table.remove(Parry_History.Times, Index)
                if Parry_History.Count > 0 then
                    Parry_History.Count = Parry_History.Count - 1
                end
            end
        end
    end

    --=================================================================
    -- BYPASS — Byte createParrySender + Oxy PRY fallback
    --=================================================================
     local sendParry       = nil
     local _reverted       = {}
     local _tokenize       = nil
     local _firstSignal    = nil
     local _bypassReady    = false

    -- Method A: Byte direct capture (hookfunction)
    pcall(function()
        local parryFunction = require(RS.Controllers["SwordsController \12"].PRY)
        local encoder = debug.getupvalue(parryFunction, 4)
        local hash    = debug.getupvalue(parryFunction, 8)
        local playerData = require(RS.Packages.Replion).Client:WaitReplion("Data")
        local serverInfo  = require(RS.ServerInfo)
        local universeIds = require(RS.Shared.UniverseIds)
        local durations = {1.5, 1.25, 1, 0.75, 0.625}
        local signal = require(RS.Packages.Signal).new()
        signal:Connect(parryFunction)

        local capturedRemote, capturedKey, capturedTimeKey = nil, nil, nil
        local timeHash = {}

        local noobParry = not serverInfo.isDungeonsMatchServer()
            and game.PlaceId ~= universeIds.RankedMatches.PlaceId
            and game.PlaceId ~= universeIds.RankedMatchesNoAbility.PlaceId
            and not serverInfo.isMedalServer()
            and not serverInfo.isClanWarServer()
            and not serverInfo.isTournamentMatchServer()
            and require(RS.Common.Utils).FFlag.GetInstantFFlag("NoobParryEnabled", true)

         function capture(event, eventHash, eventKey, proof, duration, direction, targets, aim, flag)
            if eventHash == hash and type(eventKey) == "string" and type(proof) == "string"
                and type(duration) == "number" and typeof(direction) == "CFrame"
                and type(targets) == "table" and type(aim) == "table" and type(flag) == "boolean" then
                capturedRemote, capturedKey = event, eventKey
                _bypassReady = true
            end
        end

        local fireServer
        fireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(event, ...)
            if not capturedRemote and not checkcaller() then
                capture(event, ...)
            end
            return fireServer(event, ...)
        end))

        sendParry = function(direction, targets, aim)
            local kills = playerData:Get("TotalStats.Kills") or 0
            local duration = durations[(playerData:Get("timesParried") or 0) + 1] or 0.5
            if noobParry then
                duration = kills < 20 and duration * kills / 20 or duration
            end
            if not capturedKey then
                signal:Fire(duration, direction, targets, aim, false)
                return true
            end
            capturedTimeKey = capturedTimeKey or encoder(capturedKey, "TIME")
            local stamp = tostring(math.floor(workspace:GetServerTimeNow() * 100))
            table.clear(timeHash)
            for i = 1, #stamp do
                timeHash[i] = string.char(bit32.bxor(
                    (string.byte(stamp, i) + i) % 256,
                    string.byte(capturedTimeKey, (i - 1) % #capturedTimeKey + 1)
                ))
            end
            fireServer(capturedRemote, hash, capturedKey, table.concat(timeHash), duration, direction, targets, aim, false)
            return true
        end
        Log('Success', 'Bypass', 'Byte capture active — parries are sent directly.')
    end)

    -- Method B: Oxy PRY fallback
    if not sendParry then
        pcall(function()
            for _, fn in pairs(getgc(true)) do
                if type(fn) ~= "function" then continue end
                if not debug.info(fn, "s"):find("PRY", 1, true) then continue end
                for _, v in pairs(debug.getupvalues(fn)) do
                    if type(v) == "function" then
                        local tkFn = v
                        _tokenize = function(uid)
                            local time = tostring(math.floor(workspace:GetServerTimeNow() * 100))
                            local key  = tkFn(uid, "TIME")
                            local out  = table.create(#time)
                            for i = 1, #time do
                                out[i] = string.char(bit32.bxor(
                                    (string.byte(time, i) + i) % 256,
                                    string.byte(key, (i-1) % #key + 1)
                                ))
                            end
                            return table.concat(out)
                        end
                        break
                    end
                end
                if _tokenize then break end
            end

            local eCapture = { captured = {}, hooked = {}, originals = {} }
            eCapture.valid = function(a)
                return #a == 8 and type(a[2]) == "string" and type(a[3]) == "string"
                    and type(a[4]) == "number" and typeof(a[5]) == "CFrame"
                    and type(a[6]) == "table" and type(a[7]) == "table" and type(a[8]) == "boolean"
            end
            eCapture.unhook = function()
                for mt, orig in pairs(eCapture.originals) do
                    pcall(function() setreadonly(mt, false); mt.__index = orig; setreadonly(mt, true) end)
                end
            end
            eCapture.hook = function(remote)
                if next(eCapture.captured) ~= nil then return end
                local mt = getrawmetatable(remote)
                if eCapture.hooked[mt] then return end
                eCapture.hooked[mt] = true
                setreadonly(mt, false)
                local index = mt.__index
                eCapture.originals[mt] = index
                mt.__index = function(self, key)
                    if (key == "FireServer" and self:IsA("RemoteEvent")) or
                       (key == "InvokeServer" and self:IsA("RemoteFunction")) then
                        return function(_, ...)
                            local args = { ... }
                            if eCapture.valid(args) then
                                eCapture.captured[self] = args
                                _reverted = eCapture.captured
                                eCapture.unhook()
                                _bypassReady = true
                            end
                            return index(self, key)(_, unpack(args))
                        end
                    end
                    return index(self, key)
                end
                setreadonly(mt, true)
            end
            for _, v in pairs(RS:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then eCapture.hook(v) end
            end
            task.spawn(function()
                local pkg = RS:FindFirstChild("Packages")
                local ctrl = RS:FindFirstChild("Controllers")
                if not pkg or not ctrl then return end
                local sc = ctrl:FindFirstChild("SwordsController \12")
                if not sc then return end
                pcall(function()
                    local Signal = require(pkg:WaitForChild("Signal", 10))
                    local PRY    = require(sc.PRY)
                    _firstSignal = Signal.new()
                    _firstSignal:Connect(PRY)
                    task.wait(0.5)
                    if next(eCapture.captured) == nil then
                        _firstSignal:Fire(0.5, CFrame.new(), {}, {0, 0}, false)
                    end
                end)
            end)
            Log('Success', 'Bypass', 'Oxy fallback active — PRY signal path captured.')
        end)
    end

    --=================================================================
    -- FORCE TARGET / DOUBLE CLICK 
    --=================================================================
    local ForceTargetPlayer = nil
    local LastClickTime     = 0

     function GetMousePlayerTarget()
        local alive = workspace:FindFirstChild("Alive")
        local char = GetChar()
        if not alive then return nil end

        local mouse = LP:GetMouse()
        local hit = mouse and mouse.Target
        if not hit then return nil end

        local model = hit:FindFirstAncestorOfClass("Model")
        while model and model.Parent ~= alive do
            model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model") or nil
        end

        if model and model ~= char and model:IsDescendantOf(alive) then
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                return model
            end
        end
        return nil
    end

     function ComputeForceTarget()
        local alive = workspace:FindFirstChild("Alive")
        local char  = GetChar()
        local hrp   = GetHRP(char)
        if not alive or not hrp then return nil end

        -- Double Click: aim at double-clicked player
        if Cfg.TargetMode == "Double Click" and ForceTargetPlayer then
            local tc = alive:FindFirstChild(ForceTargetPlayer)
            if tc and tc ~= char then return tc end
        end

        -- Nearest: closest enemy
        if Cfg.TargetMode == "Nearest" then
            local best, bestD = nil, math.huge
            for _, c2 in ipairs(alive:GetChildren()) do
                if c2 ~= char and c2:IsA('Model') then
                    local root = c2:FindFirstChild('HumanoidRootPart') or c2.PrimaryPart
                    local humanoid = c2:FindFirstChildOfClass('Humanoid')
                    if root and (not humanoid or humanoid.Health > 0) then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d < bestD then bestD = d; best = c2 end
                    end
                end
            end
            return best
        end

        -- Farest: furthest enemy — aim curve at the player farthest away
        if Cfg.TargetMode == "Farest" then
            local best, worstD = nil, -1
            for _, c2 in ipairs(alive:GetChildren()) do
                if c2 ~= char and c2:IsA('Model') then
                    local root = c2:FindFirstChild('HumanoidRootPart') or c2.PrimaryPart
                    local humanoid = c2:FindFirstChildOfClass('Humanoid')
                    if root and (not humanoid or humanoid.Health > 0) then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d > worstD then worstD = d; best = c2 end
                    end
                end
            end
            return best
        end

        -- Mouse: resolve the actual Alive player under the cursor.
        if Cfg.TargetMode == "Mouse" then
            return GetMousePlayerTarget()
        end

        return nil
    end

    -- Target cache: Nearest/Farest refresh rapidly; Random rerolls every 0.5s.
    local _forceTargetCache = nil
    local _forceTargetCacheMode = nil
    local _forceTargetRandomNext = 0
    local _forceTargetRandomLast = nil

     function ForceTarget()
        local mode = Cfg.TargetMode
        if mode == "Nearest" or mode == "Farest" or mode == "Random" then
            return _forceTargetCache
        end
        return ComputeForceTarget()
    end

    task.spawn(function()
        while true do
            local now = os.clock()
            local mode = Cfg.TargetMode

            if mode == "Nearest" or mode == "Farest" then
                _forceTargetCache = ComputeForceTarget()
                _forceTargetCacheMode = mode
                task.wait(0.05)
            elseif mode == "Random" then
                if _forceTargetCacheMode ~= "Random" or now >= _forceTargetRandomNext then
                    local alive = workspace:FindFirstChild("Alive")
                    local char = GetChar()
                    local candidates = {}

                    if alive then
                        for _, candidate in ipairs(alive:GetChildren()) do
                            if candidate:IsA("Model") and candidate ~= char then
                                local root = candidate:FindFirstChild("HumanoidRootPart") or candidate.PrimaryPart
                                local humanoid = candidate:FindFirstChildOfClass("Humanoid")
                                if root and (not humanoid or humanoid.Health > 0) then
                                    table.insert(candidates, candidate)
                                end
                            end
                        end
                    end

                    local picked = nil
                    if #candidates == 1 then
                        picked = candidates[1]
                    elseif #candidates > 1 then
                        local choices = {}
                        for _, candidate in ipairs(candidates) do
                            if candidate ~= _forceTargetRandomLast then
                                table.insert(choices, candidate)
                            end
                        end
                        if #choices == 0 then choices = candidates end
                        picked = choices[math.random(1, #choices)]
                    end

                    _forceTargetCache = picked
                    _forceTargetRandomLast = picked
                    _forceTargetCacheMode = "Random"
                    _forceTargetRandomNext = now + 0.5
                end
                task.wait(0.05)
            else
                _forceTargetCache = nil
                _forceTargetCacheMode = mode
                _forceTargetRandomNext = 0
                task.wait(0.15)
            end
        end
    end)

    -- Curve direction calculation
     function CalcCurveDir(ball, target)
        local camera = workspace.CurrentCamera
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local currentMode = Cfg.CurveMode or "Camera"
        local lookV = camera.CFrame.LookVector
        local upV = camera.CFrame.UpVector
        local rightV = camera.CFrame.RightVector
        
        if currentMode == "Camera" then
            return lookV
        elseif currentMode == "Left" then
            return (-rightV * 150000 + (lookV * 0.001)).Unit
        elseif currentMode == "Right" then
            return (rightV * 150000 + (lookV * 0.001)).Unit
        elseif currentMode == "Up" then
            return (upV * 85000 + (lookV * 0.001)).Unit
        elseif currentMode == "Down" then
            return (-upV * 85000 + (lookV * 0.001)).Unit
        elseif currentMode == "Straight" then
            if hrp then
                return (hrp.CFrame.LookVector * 250000).Unit
            end
            return lookV
        elseif currentMode == "Random" then
            local randomSpread = Vector3.new(math.random(-50000, 50000), math.random(-25000, 75000), math.random(-50000, 50000)).Unit
            return (lookV + (randomSpread * 350000)).Unit
        elseif currentMode == "Super Curve Random" then
            local choices = {-rightV * 450000, rightV * 450000, upV * 250000, -upV * 250000}
            local picked = choices[math.random(1, #choices)]
            return (picked + (lookV * 0.001)).Unit

        elseif currentMode == "Normal" then
            --[[
                Normal mode — adaptive logic:

                CONDITION A (long range + fast):
                  คนที่ใกล้สุดอยู่ใน Alive ห่าง > 60 studs จากเรา
                  AND ball speed > 400
                  → 80% Straight
                  → 20% สุ่มระหว่าง: backward, sky, backward+sky
                
                CONDITION B (ไม่ครบ condition A):
                  → 40% Camera
                  → 60% Random
            ]]
             function GetNearestAliveDistFromUs()
                local aliveF = workspace:FindFirstChild("Alive")
                if not aliveF or not hrp then return math.huge end
                local best = math.huge
                for _, c2 in ipairs(aliveF:GetChildren()) do
                    if c2 ~= char and c2.PrimaryPart then
                        local d = (hrp.Position - c2.PrimaryPart.Position).Magnitude
                        if d < best then best = d end
                    end
                end
                return best
            end

            local nearestDist = GetNearestAliveDistFromUs()
            local ballSpeed   = 0
            if ball then
                local z = ball:FindFirstChildOfClass("LinearVelocity") or ball:FindFirstChild("zoomies")
                if z then
                    ballSpeed = (z.VectorVelocity or z.Velocity or Vector3.zero).Magnitude
                end
            end

            local conditionA = (nearestDist > 60) and (ballSpeed > 400)

            if conditionA then
                -- 80% Straight, 20% สุ่ม
                local r = math.random(1, 100)
                if r <= 80 then
                    -- Straight: ตรงไปข้างหน้าตาม HRP
                    if hrp then
                        return (hrp.CFrame.LookVector * 250000).Unit
                    end
                    return lookV
                else
                    -- 20% สุ่มระหว่าง 3 แบบ
                    local pick = math.random(1, 3)
                    if pick == 1 then
                        -- Backward
                        if hrp then
                            return (-hrp.CFrame.LookVector * 250000).Unit
                        end
                        return (-lookV * 250000).Unit
                    elseif pick == 2 then
                        -- Sky (up)
                        return (upV * 200000 + lookV * 0.001).Unit
                    else
                        -- Backward + Sky
                        if hrp then
                            return ((-hrp.CFrame.LookVector * 150000) + (upV * 150000)).Unit
                        end
                        return ((-lookV * 150000) + (upV * 150000)).Unit
                    end
                end
            else
                -- Condition B: 40% Camera, 60% Random
                local r = math.random(1, 100)
                if r <= 40 then
                    return lookV  -- Camera
                else
                    local randomSpread = Vector3.new(
                        math.random(-50000, 50000),
                        math.random(-25000, 75000),
                        math.random(-50000, 50000)
                    ).Unit
                    return (lookV + (randomSpread * 350000)).Unit
                end
            end
        end
        
        xpcall(function()
            if ball and target and target.PrimaryPart then
                return ((target.PrimaryPart.Position - ball.Position).Unit * 500000).Unit
            end
        end, function(err)
            Log('Error', 'Trajectory', 'Curve calculation failed: ' .. tostring(err))
        end)
        
        return lookV
    end

    -- Build snap map
     function BuildSnap()
        local cam   = workspace.CurrentCamera
        local snap  = {}
        local alive = workspace:FindFirstChild("Alive")
        if alive and cam then
            for _, c2 in ipairs(alive:GetChildren()) do
                local p2 = c2.PrimaryPart or c2:FindFirstChild("HumanoidRootPart")
                if p2 then
                    local sp = cam:WorldToScreenPoint(p2.Position)
                    if sp.Z > 0 then snap[c2.Name] = sp end
                end
            end
        end
        return snap
    end

    --=================================================================
    -- PARRY ANIMATION
    --=================================================================
    local CachedParryTracks = {}
    local LastParryAnimTime = 0

     function PlayParryAnimation()
        if not Cfg.ParryAnimationEnabled then return end

        local now = os.clock()
        if now - LastParryAnimTime < 0.12 then return end
        LastParryAnimTime = now

        pcall(function()
            local player = LP or Players.LocalPlayer
            local char = player and player.Character
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 1))
            if not animator then return end

            local currentSword = char:GetAttribute("CurrentlyEquippedSword") or "Default"
            local track = CachedParryTracks[currentSword]

            if not track or not track.Animation or not track.Parent then
                local sharedFolder = RS:FindFirstChild("Shared")
                local swordAPI = sharedFolder and sharedFolder:FindFirstChild("SwordAPI")
                local collection = swordAPI and swordAPI:FindFirstChild("Collection")
                local defaultFolder = collection and collection:FindFirstChild("Default")
                local parryAnimation = defaultFolder and defaultFolder:FindFirstChild("GrabParry")

                if currentSword ~= "Default" then
                    pcall(function()
                        local replicatedInstances = sharedFolder and sharedFolder:FindFirstChild("ReplicatedInstances")
                        local swordModule = replicatedInstances and replicatedInstances:FindFirstChild("Swords")
                        if swordModule then
                            local swordData = require(swordModule)
                            local swordInfo = swordData and swordData:GetSword(currentSword)
                            local animationType = swordInfo and swordInfo.AnimationType
                            local animationFolder = animationType and collection and collection:FindFirstChild(animationType)
                            if animationFolder then
                                parryAnimation = animationFolder:FindFirstChild("GrabParry")
                                    or animationFolder:FindFirstChild("Grab")
                                    or parryAnimation
                            end
                        end
                    end)
                end

                if parryAnimation and parryAnimation:IsA("Animation") then
                    track = animator:LoadAnimation(parryAnimation)
                    track.Priority = Enum.AnimationPriority.Action
                    CachedParryTracks[currentSword] = track
                end
            end

            if track then
                track:Stop(0.02)
                track:Play(0.05, 0.65, 1.35)
            end
        end)
    end

    --=================================================================
    -- FIRE PARRY
    --=================================================================
     function FireParry(ball, isSpam, targetOverride)
        local cam = workspace.CurrentCamera
        if not cam then 
            Log('Error', 'Camera', 'CurrentCamera was not found.')
            return 
        end
        local target = targetOverride or ForceTarget()
        local char = GetChar()
        local hrp = GetHRP(char)
        local alive = workspace:FindFirstChild("Alive")
        
        local curveDirectionVector = CalcCurveDir(ball, target)
        local finalCF = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + curveDirectionVector)

        local snap = BuildSnap()
       

    -- ── ปรับตัวอักษรตัวเล็ก-ใหญ่ให้ตรงกับอันเก่า ──
    gamePositionsSnapshot = {}
    if cam and alive then
        local mode = Cfg.TargetMode
        local isNormalOrMouse = (mode == "Normal" or mode == "Mouse")

        if mode == "Mouse" and targetOverride and targetOverride:IsA("Model") and targetOverride.PrimaryPart then
            screenPos, onScreen = cam:WorldToScreenPoint(targetOverride.PrimaryPart.Position)
            gamePositionsSnapshot[targetOverride.Name] = screenPos
        elseif isNormalOrMouse then
            -- Normal mode and regular Mouse parries keep the complete player snapshot.
            for _, character in ipairs(alive:GetChildren()) do
                if character:IsA("Model") and character.PrimaryPart then
                    screenPos, onScreen = cam:WorldToScreenPoint(character.PrimaryPart.Position)
                    gamePositionsSnapshot[character.Name] = screenPos
                end
            end
        else
            -- โหมดอื่นๆ: ใส่ข้อมูลเฉพาะคนที่เรา target เท่านั้น
            local targetChar = ForceTarget()
            if targetChar and targetChar:IsA("Model") and targetChar.PrimaryPart then
                screenPos, onScreen = cam:WorldToScreenPoint(targetChar.PrimaryPart.Position)
                gamePositionsSnapshot[targetChar.Name] = screenPos
            end
        end
    end

        -- Determine aim point: Mouse mode = actual mouse screen pos; everything else = viewport center
        local aimPoint
        if Cfg.TargetMode == "Mouse" then
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            aimPoint = {mouse.X, mouse.Y}
        else
            aimPoint = {cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2}
        end

        local packetSent = false

        if sendParry and not packetSent then
            local success, err = pcall(function()
                sendParry(finalCF, gamePositionsSnapshot, aimPoint)
            end)
            if success then
                packetSent = true
            else
                Log('Error', 'Network', 'sendParry path failed: ' .. tostring(err))
            end
        end

        if _reverted and next(_reverted) ~= nil and not packetSent then
            local successCount = 0
            for remote, args in pairs(_reverted) do
                if type(args) ~= "table" then continue end
                local success, err = pcall(function()
                    local pa = {}
                    pa[1] = args[1]
                    pa[2] = args[2]
                    pa[3] = _tokenize and _tokenize(args[2]) or args[3]
                    pa[4] = isSpam and 0 or 0.5
                    pa[5] = finalCF
                    pa[6] = gamePositionsSnapshot
                    pa[7] = aimPoint
                    pa[8] = false
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(pa))
                    else
                        remote:InvokeServer(unpack(pa))
                    end
                end)
                if success then
                    successCount = successCount + 1
                else
                    Log('Error', 'Network', 'Remote path failed: ' .. tostring(err))
                end
            end
            if successCount > 0 then
                packetSent = true
            end
        end

        if _firstSignal and not packetSent then
            local success, err = pcall(function()
                _firstSignal:Fire(0.5, finalCF, gamePositionsSnapshot, aimPoint, false)
            end)
            if success then
                packetSent = true
            else
                Log('Error', 'Network', 'Signal path failed: ' .. tostring(err))
            end
        end

        if not packetSent then
            pcall(function()
                if mouse1press then mouse1press(); task.wait(0.03); mouse1release() end
                if mouse1click then mouse1click() end
            end)
        end

        Record_Parry()
        PlayParryAnimation()
    end

    ---------------------------------------------------------------------------------------------------------------------------

     function GetPing()
        local ok, v = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        return ok and v or LP:GetNetworkPing() * 1000
    end

     function GetChar() return LP.Character end
     function GetHRP(c) return c and c.PrimaryPart or (c and c:FindFirstChild("HumanoidRootPart")) end
     function GetHum(c) return c and c:FindFirstChildOfClass("Humanoid") end

     Real_Ball_Position, Tracked_Ball = nil, nil

    pcall(function()
        local net = RS.Packages._Index["sleitnick_net@0.1.0"].net
        for _, child in net:GetChildren() do
            if child:IsA("UnreliableRemoteEvent") and child.Name ~= "URE/ReplicateBallPosition" then
                child.OnClientEvent:Connect(function(arg, arg2)
                    if not arg or not arg.Parent then
                        if arg == Tracked_Ball then Tracked_Ball = nil; Real_Ball_Position = nil end
                        return
                    end
                    Tracked_Ball = arg; Real_Ball_Position = arg2
                end)
                break
            end
        end
    end)

    -- ถ้าเราอยู่ใน Alive ใช้ workspace.Balls
    -- ถ้าไม่อยู่ใน Alive ใช้ workspace.TrainingBalls แทน
     function _GetBallFolder()
        local char  = LP.Character
        local alive = workspace:FindFirstChild("Alive")
        local inAlive = alive and char and char:IsDescendantOf(alive)
        if inAlive then
            return workspace:FindFirstChild("Balls"), false
        end
        local tb = workspace:FindFirstChild("TrainingBalls")
        if tb then return tb, true end
        return workspace:FindFirstChild("Balls"), false
    end

    -- GetBalls step cache: sort + GetChildren only run every 2 PreSimulation steps.
    -- BallState fast-path (position, speed, dist) still updates every step.
     local _ballsCache     = {}
     local _ballsCacheStep = 0
     local _ballsStep      = 0
    RunService.Stepped:Connect(function() _ballsStep = _ballsStep + 1 end)

     function GetBalls()
        local status, err = pcall(function()
            local myChar = LP.Character
            local myHRP  = myChar and (myChar.PrimaryPart or myChar:FindFirstChild("HumanoidRootPart"))
            local myPos  = myHRP and myHRP.Position
            local myName = LP.Name

            -- Rebuild list + sort every 2 steps (reduces GetChildren + sort cost by 50%)
            if _ballsStep ~= _ballsCacheStep and (_ballsStep - _ballsCacheStep) >= 2 then
                _ballsCacheStep = _ballsStep
                local out = {}
                local targetFolder, isTraining = _GetBallFolder()
                BallState.isTraining = isTraining or false
                if targetFolder then
                    for _, v in ipairs(targetFolder:GetChildren()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                            table.insert(out, v)
                        end
                    end
                    if myPos and #out > 1 then
                        table.sort(out, function(a, b)
                            local aT = a:GetAttribute("target") == myName
                            local bT = b:GetAttribute("target") == myName
                            if aT ~= bT then return aT end
                            return (myPos - a.Position).Magnitude < (myPos - b.Position).Magnitude
                        end)
                    end
                end
                _ballsCache = out
            end

            local out = _ballsCache

            -- BallState fast-path: update per-frame values without re-sorting
            BallState.haveBall = #out > 0
            if #out > 0 then
                local targeting = nil
                for _, b in ipairs(out) do
                    if b:GetAttribute("target") == myName then targeting = b; break end
                end
                local refBall = targeting or out[1]
                BallState.ball       = refBall
                BallState.targetMe   = (refBall:GetAttribute("target") == myName)
                BallState.targetName = tostring(refBall:GetAttribute("target") or '')
                if myPos then
                    BallState.dist = (myPos - refBall.Position).Magnitude
                end
                local z = refBall:FindFirstChildOfClass("LinearVelocity") or refBall:FindFirstChild("zoomies")
                local zv = z and (z.VectorVelocity or z.Velocity)
                BallState.speed = (zv and typeof(zv) == 'Vector3') and zv.Magnitude or 0
            else
                BallState.ball = nil; BallState.targetMe = false; BallState.targetName = ''
                BallState.dist = 0;   BallState.speed = 0
            end
            return out
        end)
        if not status then return {} end
        return err
    end

     function GetBall()
        local status, err = pcall(function()
            -- BallState.ball is updated every GetBalls() call.
            -- Only return it if still in the workspace hierarchy.
            local cached = BallState.ball
            if cached and cached.Parent then return cached end

            -- Fallback: scan folder directly (covers edge case where GetBalls
            -- hasn't run yet this frame, e.g. called from VisualCD handler)
            local targetFolder = _GetBallFolder()
            if not targetFolder then return nil end
            local myName = LP.Name
            -- prefer ball targeting us
            for _, b in ipairs(targetFolder:GetChildren()) do
                if b:IsA("BasePart") and b:GetAttribute("target") == myName then
                    return b
                end
            end
            -- any ball
            for _, b in ipairs(targetFolder:GetChildren()) do
                if b:IsA("BasePart") then return b end
            end
            return nil
        end)
        if not status then return nil end
        return err
    end

      function GetBallPos(ball)
        local status, err = pcall(function()
            if not ball or not ball.Parent then return Vector3.zero end
            if ball == Tracked_Ball and Real_Ball_Position then 
                return Real_Ball_Position 
            end
            return ball.Position
        end)
        if not status then return Vector3.zero end
        return err
    end

      function GetBallVel(ball)
        local status, err = pcall(function()
            if not ball or not ball.Parent then return Vector3.zero end
            local zoomiesInstance = ball:FindFirstChildOfClass("LinearVelocity") or ball:FindFirstChild("zoomies")
            if zoomiesInstance then
                return zoomiesInstance.VectorVelocity or zoomiesInstance.Velocity or Vector3.zero
            end
            return ball.AssemblyLinearVelocity or Vector3.zero
        end)
        if not status then return Vector3.zero end
        return err
    end

    

    local Detection = {
        Infinity      = false,
        DeathSlash    = false,
        TimeHole      = false,
        SlashesOfFury = false,
        Phantom       = false,
        GuardianDragon = false,
        TornadoTime   = 0,
    }

     local Avatar_State = {
        Headless = false, HeadlessConn = nil,
        Korblox  = false, KorbloxConn  = nil,
    }

     local Win_State    = { Enabled = false, Connections = {} }
     local Streak_State = {
        Enabled = false, Updating = false, Value = nil,
        Conn = nil, EnabledConn = nil, CharConn = nil,
        OriginalText = nil, OriginalIcon = nil, OriginalEnabled = nil,
    }
    local Spam_State = {
        Accumulator = 0,         -- CPS accumulator (plain Auto Spam only)
        Engaged = false,         -- Smart Auto Spam conditions hold -> Auto Parry must stay off
    }
    local SpamParryPauseUntil = 0
    local function MarkSpamParryPause(Delta)
        SpamParryPauseUntil = math.max(SpamParryPauseUntil, os.clock() + math.max(tonumber(Delta) or 0, 1 / 60))
    end
     local Trigger_State  = { Parrying = false }
     local Device_State   = { Spoof = 0, Rejoin = 0 }
     local FOV_State      = { Enabled = false }

    --// [ ABILITY DETECTION ] ---------------------------------------------
     local function Watch_Ability_Active(Character)
        if not Character then return end
        pcall(function()
            Character:GetAttributeChangedSignal("AbilityActive"):Connect(function()
                local Active = Character:GetAttribute("AbilityActive")
                Detection.SlashesOfFury = (LP:GetAttribute("CurrentlyEquippedAbility") == "Slashes of Fury") and Active == true
            end)
        end)
        pcall(function()
            Character:GetAttributeChangedSignal("FuryCatch"):Connect(function()
                if Character:GetAttribute("FuryCatch") == nil then return end
                if not (Cfg.DetectSlashesOfFury and Detection.SlashesOfFury) then return end
                task.spawn(function()
                    local Count = 0
                    while Detection.SlashesOfFury and Cfg.DetectSlashesOfFury
                        and Count < math.clamp(math.floor(Cfg.FuryMaxParries or 36), 1, 100) do
                        Count = Count + 1
                        local Ball = GetBall()
                        if Ball then pcall(FireParry, Ball, true) end
                        task.wait(math.clamp(Cfg.FuryParryDelay or 0.05, 0.01, 0.25))
                    end
                end)
            end)
        end)
    end

    -- Assigned after the cooldown/queue code below; the dragon watcher calls it when the dragon vanishes.
    local Release_Parry_Cooldown = function() end

     local function Setup_Detections()
        pcall(function()
            RS.Remotes.DeathBall.OnClientEvent:Connect(function(_, Active)
                Detection.DeathSlash = Active or false
            end)
        end)
        pcall(function()
            RS.Remotes.InfinityBall.OnClientEvent:Connect(function(_, Active)
                Detection.Infinity = Active or false
            end)
        end)
        pcall(function()
            LP:GetAttributeChangedSignal("TimeHoleActivate"):Connect(function()
                Detection.TimeHole = LP:GetAttribute("TimeHoleActivate") ~= nil
            end)
        end)
        task.spawn(function()
            local Character = GetChar()
            if Character then Watch_Ability_Active(Character) end
            LP.CharacterAdded:Connect(function(NewCharacter)
                Detection.SlashesOfFury = false
                Detection.Phantom = false
                local RuntimeNow = workspace:FindFirstChild("Runtime")
                Detection.GuardianDragon = RuntimeNow ~= nil
                    and RuntimeNow:FindFirstChild("GUARDIAN_DRAGON") ~= nil
                task.wait(0.1)
                Watch_Ability_Active(NewCharacter)
            end)
        end)

        local Runtime = workspace:FindFirstChild("Runtime") or workspace:WaitForChild("Runtime", 10)
        if Runtime then
            local function WatchGuardianDragon(Object)
                if not Object or Object.Name ~= "GUARDIAN_DRAGON" then return end
                Detection.GuardianDragon = false
                local maxBallSpeed = 0
                for _, activeBall in ipairs(GetBalls()) do
                    if activeBall and activeBall.Parent then
                        local ballSpeed = GetBallVel(activeBall).Magnitude
                        if ballSpeed > maxBallSpeed then maxBallSpeed = ballSpeed end
                    end
                end
                local detectDelay = maxBallSpeed < 136 and 0.67 or 0.37
                task.delay(detectDelay, function()
                    if Object.Parent == Runtime then
                        Detection.GuardianDragon = true
                    end
                end)
                Object.AncestryChanged:Connect(function(_, Parent)
                    if Parent == nil then
                        Detection.GuardianDragon = Runtime:FindFirstChild("GUARDIAN_DRAGON") ~= nil
                        if not Detection.GuardianDragon and Cfg.DetectGuardianDragon then
                            Release_Parry_Cooldown()
                        end
                    end
                end)
            end

            -- Per-frame watcher: tracks the dragon's position/velocity (for the multi-ball
            -- heading check) and catches "existed last frame, gone this frame" even when
            -- AncestryChanged does not report it.
            local function Dragon_Position(Object)
                if Object:IsA("BasePart") then return Object.Position end
                if Object:IsA("Model") then
                    local Ok, Pivot = pcall(Object.GetPivot, Object)
                    if Ok and Pivot then return Pivot.Position end
                end
                local Part = Object:FindFirstChildWhichIsA("BasePart", true)
                return Part and Part.Position
            end
            local DragonWasPresent = Runtime:FindFirstChild("GUARDIAN_DRAGON") ~= nil
            local DragonLastPos, DragonLastTime = nil, 0
            RunService.Heartbeat:Connect(function()
                local Dragon = Runtime:FindFirstChild("GUARDIAN_DRAGON")
                local Now = os.clock()
                if Dragon then
                    local Pos = Dragon_Position(Dragon)
                    if Pos then
                        if DragonLastPos and Now > DragonLastTime then
                            local Instant = (Pos - DragonLastPos) / (Now - DragonLastTime)
                            Detection.DragonVel = Detection.DragonVel and Detection.DragonVel:Lerp(Instant, 0.5) or Instant
                        end
                        DragonLastPos, DragonLastTime = Pos, Now
                        Detection.DragonPos = Pos
                    end
                else
                    Detection.DragonPos, Detection.DragonVel = nil, nil
                    DragonLastPos = nil
                    if DragonWasPresent then
                        Detection.GuardianDragon = false
                        if Cfg.DetectGuardianDragon then Release_Parry_Cooldown() end
                    end
                end
                DragonWasPresent = Dragon ~= nil
            end)

            local ExistingGuardian = Runtime:FindFirstChild("GUARDIAN_DRAGON")
            if ExistingGuardian then WatchGuardianDragon(ExistingGuardian) end
            Runtime.ChildAdded:Connect(WatchGuardianDragon)

            local function CheckPhantomObject(Object)
                if not Object or (Object.Name ~= "maxTransmission" and Object.Name ~= "transmissionpart") then return end
                local Weld = Object:FindFirstChildWhichIsA("WeldConstraint")
                if not Weld then return end
                local Root = GetHRP(GetChar())
                if Root and Weld.Part1 == Root then
                    Detection.Phantom = true
                    Object.AncestryChanged:Connect(function(_, Parent)
                        if Parent == nil then Detection.Phantom = false end
                    end)
                end
            end
            for _, Object in ipairs(Runtime:GetChildren()) do CheckPhantomObject(Object) end
            Runtime.ChildAdded:Connect(CheckPhantomObject)
        end
    end

     local function Has_Singularity_Cape()
        local Character = GetChar()
        if not Character or not Character.PrimaryPart then return false end
        return Character.PrimaryPart:FindFirstChild("SingularityCape") ~= nil
    end

     local function Is_Tornado(Ball)
        if not Ball or not Ball.Parent then return false end
        if Ball:FindFirstChild("AeroDynamicSlashVFX") then
            pcall(function() Ball.AeroDynamicSlashVFX:Destroy() end)
            Detection.TornadoTime = os.clock()
        end
        local Runtime = workspace:FindFirstChild("Runtime")
        if Runtime and Runtime:FindFirstChild("Tornado") then
            local Time = Runtime.Tornado:GetAttribute("TornadoTime") or 1
            if (os.clock() - Detection.TornadoTime) < (Time + 0.314159) then
                return true
            end
        end
        return false
    end

    -- Which ball is the dragon flying at? Highest alignment between the dragon's
    -- velocity and the direction to each ball (must reach SmartDragonAimDot).
     local function Dragon_Target_Ball(Balls)
        local Pos, Vel = Detection.DragonPos, Detection.DragonVel
        if not Pos or not Vel or Vel.Magnitude < 1 then return nil end
        local Dir = Vel.Unit
        local Best, BestDot = nil, tonumber(Cfg.DragonAimDot) or 0.85
        for _, Ball in ipairs(Balls) do
            if Ball and Ball.Parent then
                local Offset = GetBallPos(Ball) - Pos
                local Magnitude = Offset.Magnitude
                if Magnitude > 1e-3 then
                    local Dot = Dir:Dot(Offset / Magnitude)
                    if Dot >= BestDot then Best, BestDot = Ball, Dot end
                end
            end
        end
        return Best
    end

    -- Dragon blocks parries, except with 2+ balls when it is flying at a ball that is NOT aimed at us.
     local function Dragon_Blocks(Ball)
        if not (Cfg.DetectGuardianDragon and Detection.GuardianDragon) then return false end
        local Balls = GetBalls()
        if #Balls >= 2 then
            local Target = Dragon_Target_Ball(Balls)
            if Target and Target:GetAttribute("target") ~= LP.Name then return false end
        end
        return true
    end

     local function Detection_Blocked(Ball)
        if Cfg.DetectInfinity and Detection.Infinity then return true end
        if Cfg.DetectDeathSlash and Detection.DeathSlash then return true end
        if Cfg.DetectTimeHole and Detection.TimeHole then return true end
        if Cfg.DetectTornado and Is_Tornado(Ball) then return true end
         if Cfg.DetectPhantom and Detection.Phantom then return true end
        if Dragon_Blocks(Ball) then return true end
        if Cfg.DetectSlashesOfFury and Detection.SlashesOfFury then return true end
        return false
    end

    --// [ AUTO ABILITY ] —  try_auto_ability ----------------------
    local _abilityReadySince = nil
    local _abilityConsumed = false
     local function Try_Auto_Ability()
        if not Cfg.AutoAbility then
            _abilityReadySince = nil
            _abilityConsumed = false
            return false
        end
        local Success, Result = pcall(function()
            local PlayerGui = LP:FindFirstChild("PlayerGui")
            local Hotbar = PlayerGui and PlayerGui:FindFirstChild("Hotbar")
            local Ability = Hotbar and Hotbar:FindFirstChild("Ability")
            local Gradient = Ability and Ability:FindFirstChild("UIGradient")
            local IsReady = Gradient ~= nil and Gradient.Offset.Y == 0.5
            if not IsReady then
                _abilityReadySince = nil
                _abilityConsumed = false
                return false
            end

            local Now = os.clock()
            if not _abilityReadySince then
                _abilityReadySince = Now
                return false
            end
            if (Now - _abilityReadySince) < 0.5 or _abilityConsumed then
                return false
            end

            local Character = GetChar()
            local Abilities = Character and Character:FindFirstChild("Abilities")
            if not Abilities then return false end

            local Names = {
                "Raging Deflection", "Rapture", "Calming Deflection",
                "Aerodynamic Slash", "Fracture", "Death Slash",
            }
            for _, Name in ipairs(Names) do
                local Entry = Abilities:FindFirstChild(Name)
                if Entry and Entry.Enabled then
                    RS.Remotes.AbilityButtonPress:Fire()
                    _abilityConsumed = true
                    if Name == "Death Slash" then
                        task.delay(2.432, function()
                            pcall(function()
                                RS:WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)
                            end)
                        end)
                    end
                    return true
                end
            end
            return false
        end)
        return Success and Result == true
    end

    --// [ HEADLESS / KORBLOX / FOV ] —  avatar + player_mods ------
     local function Apply_Headless(Character)
        if not Character then return end
        local Head = Character:FindFirstChild("Head")
        if not Head then return end
        Head.Transparency = 1
        local Face = Head:FindFirstChildOfClass("Decal")
        if Face then Face:Destroy() end
    end

     local function Remove_Headless(Character)
        if not Character then return end
        local Head = Character:FindFirstChild("Head")
        if Head then Head.Transparency = 0 end
    end

     local function Apply_Korblox(Character)
        if not Character then return end
        local Leg = Character:FindFirstChild("RightLeg") or Character:FindFirstChild("Right Leg")
        if not Leg then return end
        for _, Child in ipairs(Leg:GetChildren()) do
            if Child:IsA("SpecialMesh") or Child:IsA("Mesh") then Child:Destroy() end
        end
        local Mesh = Instance.new("SpecialMesh")
        Mesh.MeshId = "rbxassetid://101851696"
        Mesh.TextureId = "rbxassetid://115727863"
        Mesh.Scale = Vector3.new(1, 1, 1)
        Mesh.Parent = Leg
    end

     local function Remove_Korblox(Character)
        if not Character then return end
        local Leg = Character:FindFirstChild("RightLeg") or Character:FindFirstChild("Right Leg")
        if not Leg then return end
        for _, Child in ipairs(Leg:GetChildren()) do
            if Child:IsA("SpecialMesh") and Child.MeshId == "rbxassetid://101851696" then
                Child:Destroy()
            end
        end
    end

     local function Sync_Avatar()
        if Avatar_State.Headless ~= Cfg.Headless then
            Avatar_State.Headless = Cfg.Headless
            if Cfg.Headless then
                if Avatar_State.HeadlessConn then Avatar_State.HeadlessConn:Disconnect() end
                Apply_Headless(GetChar())
                Avatar_State.HeadlessConn = LP.CharacterAdded:Connect(function(Character)
                    task.wait(0.1)
                    if Cfg.Headless then Apply_Headless(Character) end
                end)
            else
                if Avatar_State.HeadlessConn then
                    Avatar_State.HeadlessConn:Disconnect()
                    Avatar_State.HeadlessConn = nil
                end
                Remove_Headless(GetChar())
            end
        end
        if Avatar_State.Korblox ~= Cfg.Korblox then
            Avatar_State.Korblox = Cfg.Korblox
            if Cfg.Korblox then
                if Avatar_State.KorbloxConn then Avatar_State.KorbloxConn:Disconnect() end
                Apply_Korblox(GetChar())
                Avatar_State.KorbloxConn = LP.CharacterAdded:Connect(function(Character)
                    task.wait(0.1)
                    if Cfg.Korblox then Apply_Korblox(Character) end
                end)
            else
                if Avatar_State.KorbloxConn then
                    Avatar_State.KorbloxConn:Disconnect()
                    Avatar_State.KorbloxConn = nil
                end
                Remove_Korblox(GetChar())
            end
        end
    end

     local function Apply_FOV()
        local Camera = workspace.CurrentCamera
        if not Camera then return end
        if Cfg.FOVEnabled then
            Camera.FieldOfView = Cfg.FOV or 70
        elseif FOV_State.Enabled then
            Camera.FieldOfView = 70
        end
        FOV_State.Enabled = Cfg.FOVEnabled
    end

    --// [ CUSTOM WIN MESSAGE ] —  custom_win ----------------------
     local function Custom_Win_Watch(Label, Getter)
        if not Label then return end
        local Conn = Label:GetPropertyChangedSignal("Text"):Connect(function()
            if not Cfg.CustomWin then return end
            local Value = Getter()
            if Value ~= nil and Value ~= "" and Label.Text ~= Value then
                Label.Text = Value
            end
        end)
        table.insert(Win_State.Connections, Conn)
        local Value = Getter()
        if Value ~= nil and Value ~= "" and Label.Text ~= Value then
            Label.Text = Value
        end
    end

     local function Sync_Custom_Win()
        if Win_State.Enabled == Cfg.CustomWin then return end
        Win_State.Enabled = Cfg.CustomWin
        if Cfg.CustomWin then
            task.spawn(function()
                local PlayerGui = LP:WaitForChild("PlayerGui", 10)
                local Announcer = PlayerGui and PlayerGui:WaitForChild("announcer", 10)
                if not Announcer then return end
                Custom_Win_Watch(Announcer:WaitForChild("Killed", 10), function() return Cfg.KillMessage end)
                Custom_Win_Watch(Announcer:FindFirstChild("Winner"), function() return Cfg.WinMessage end)
                table.insert(Win_State.Connections, Announcer.ChildAdded:Connect(function(Child)
                    if not Cfg.CustomWin then return end
                    if Child.Name == "Killed" then
                        Custom_Win_Watch(Child, function() return Cfg.KillMessage end)
                    elseif Child.Name == "Winner" then
                        Custom_Win_Watch(Child, function() return Cfg.WinMessage end)
                    end
                end))
            end)
        else
            for _, Conn in ipairs(Win_State.Connections) do
                pcall(function() Conn:Disconnect() end)
            end
            table.clear(Win_State.Connections)
        end
    end

    --// [ CUSTOM WINSTREAK ] —  winstreak -------------------------
     local function Winstreak_Update()
        if not Cfg.CustomWinstreak then return end
        Streak_State.Value = tostring(Cfg.Winstreak or "1")
        local Character = GetChar()
        if not Character then return end
        local Display = Character:FindFirstChild("WinStreakDisplay") or Character:WaitForChild("WinStreakDisplay", 5)
        if not Display then return end
        local Main = Display:FindFirstChild("Main")
        if not Main then return end
        local Icon, Value = Main:FindFirstChild("Icon"), Main:FindFirstChild("Value")
        if not Icon or not Value then return end

        if Streak_State.OriginalEnabled == nil then Streak_State.OriginalEnabled = Display.Enabled end
        if not Streak_State.OriginalText or Streak_State.OriginalText == "" then Streak_State.OriginalText = Value.Text end
        if not Streak_State.OriginalIcon or Streak_State.OriginalIcon == "" then Streak_State.OriginalIcon = Icon.Image end

        local Streak = Streak_State.Value
        local Number = tonumber(Streak)
        Icon.Image = (Number and Number >= 10) and "rbxassetid://75598166115655" or "rbxassetid://89658127170771"
        Value.Text = string.format("<b><stroke color='rgb(0, 0, 0)' thickness='2'>%s</stroke></b>", Streak)
        Display.Enabled = true

        if Streak_State.Conn then Streak_State.Conn:Disconnect() end
        if Streak_State.EnabledConn then Streak_State.EnabledConn:Disconnect() end

        Streak_State.Conn = Value:GetPropertyChangedSignal("Text"):Connect(function()
            if not Cfg.CustomWinstreak or Streak_State.Updating then return end
            Streak_State.OriginalText = Value.Text
            Streak_State.Updating = true
            local NewStreak = tostring(Cfg.Winstreak or "1")
            local NewNumber = tonumber(NewStreak)
            Icon.Image = (NewNumber and NewNumber >= 10) and "rbxassetid://75598166115655" or "rbxassetid://89658127170771"
            Value.Text = string.format("<b><stroke color='rgb(0, 0, 0)' thickness='2'>%s</stroke></b>", NewStreak)
            Streak_State.Updating = false
        end)

        Streak_State.EnabledConn = Display:GetPropertyChangedSignal("Enabled"):Connect(function()
            if not Cfg.CustomWinstreak or Streak_State.Updating then return end
            Streak_State.OriginalEnabled = Display.Enabled
            Streak_State.Updating = true
            Display.Enabled = true
            Streak_State.Updating = false
        end)
    end

     local function Sync_Winstreak()
        if Streak_State.Enabled ~= Cfg.CustomWinstreak then
            Streak_State.Enabled = Cfg.CustomWinstreak
            if Cfg.CustomWinstreak then
                if not Streak_State.CharConn then
                    Streak_State.CharConn = LP.CharacterAdded:Connect(function()
                        Streak_State.OriginalText = nil
                        Streak_State.OriginalIcon = nil
                        Streak_State.OriginalEnabled = nil
                        task.wait(1.5)
                        pcall(Winstreak_Update)
                    end)
                end
                pcall(Winstreak_Update)
            else
                if Streak_State.CharConn then Streak_State.CharConn:Disconnect() Streak_State.CharConn = nil end
                if Streak_State.Conn then Streak_State.Conn:Disconnect() Streak_State.Conn = nil end
                if Streak_State.EnabledConn then Streak_State.EnabledConn:Disconnect() Streak_State.EnabledConn = nil end
                local Character = GetChar()
                if Character then
                    local Display = Character:FindFirstChild("WinStreakDisplay")
                    if Display then
                        local Main = Display:FindFirstChild("Main")
                        if Main then
                            local Icon, Value = Main:FindFirstChild("Icon"), Main:FindFirstChild("Value")
                            if Icon and Streak_State.OriginalIcon and Streak_State.OriginalIcon ~= "" then Icon.Image = Streak_State.OriginalIcon end
                            if Value and Streak_State.OriginalText and Streak_State.OriginalText ~= "" then Value.Text = Streak_State.OriginalText end
                        end
                        if Streak_State.OriginalEnabled ~= nil then Display.Enabled = Streak_State.OriginalEnabled end
                    end
                end
                Streak_State.OriginalText, Streak_State.OriginalIcon, Streak_State.OriginalEnabled = nil, nil, nil
            end
        end
        if Streak_State.Enabled and tostring(Cfg.Winstreak) ~= Streak_State.Value then
            pcall(Winstreak_Update)
        end
    end

    --// [ MANUAL SPAM / AUTOSPAM ] —  spam engine ----------------------
     local function Get_Nearest_OpponentDistance(Character)
        local CharacterRoot = Character and (Character:FindFirstChild('HumanoidRootPart') or Character.PrimaryPart)
        if not CharacterRoot then return math.huge end
        local Alive = workspace:FindFirstChild("Alive")
        if not Alive then return math.huge end
        local Best = math.huge
        for _, Other in ipairs(Alive:GetChildren()) do
            if Other ~= Character and Other:IsA('Model') then
                local OtherRoot = Other:FindFirstChild('HumanoidRootPart') or Other.PrimaryPart
                local OtherHumanoid = Other:FindFirstChildOfClass('Humanoid')
                if OtherRoot and (not OtherHumanoid or OtherHumanoid.Health > 0) then
                    local Distance = (CharacterRoot.Position - OtherRoot.Position).Magnitude
                    if Distance < Best then Best = Distance end
                end
            end
        end
        return Best
    end

     --// SMART AUTO SPAM ------------------------------------------------
     -- Conditions, cheapest first (all must hold, evaluated every Heartbeat and
     -- instantly when the server reports 'cooldown done'):
     --   1. range gate            : ball inside the spam range
     --   2. ordered clash         : Me > P2 > Me   /   Me > P2 > P3 > Me  (from target log)
     --   3. clash distance        : every lap player within 33 / 50 / 65 studs (2 / 3 / 4+ players)
     --   4. ball heading at me    : velocity direction, NOT ball:GetAttribute("target")
     -- While 1-4 hold the spam is "engaged" and Auto Parry is switched off.
     --   5. server cooldown state : no cooldown running, no parry awaiting its cooldown
     -- Then ONE FireParry, and nothing more until VisualCD reports cooldown done.

     -- VisualCD (block, active, duration) from the server:
     --   block == true, active == true            -> cooldown started
     --   block == true, active == nil, duration == nil -> cooldown done
     --   any other shape is ignored.
     local CD = {
        Active = false,       -- server says a cooldown is running
        ActiveSince = 0,
        Locked = false,       -- we fired and are waiting for that cooldown to finish
        SawStart = false,     -- the cooldown start for our shot has arrived
        Deadline = 0,         -- failsafe so a dropped event can never freeze us
    }

    -- Shared by Smart Auto Spam and the Auto Parry queue: one parry per server cooldown.
    local function CD_Ready(Now)
        local Failsafe = tonumber(Cfg.SmartCDFailsafe) or 3
        if CD.Active and Now - CD.ActiveSince > Failsafe then CD.Active = false end
        if CD.Locked and Now >= CD.Deadline then      -- the cooldown events never came; unfreeze
            CD.Locked = false
            CD.Active = false
        end
        return not CD.Locked and not CD.Active
    end

    local function CD_MarkFired(Now, Ping)
        CD.Locked = true
        CD.SawStart = false
        CD.Deadline = Now + math.clamp(0.25 + (Ping / 1000) * 2, 0.25, 0.8)   -- no cooldown start by then = parry never registered
    end

    -- Target log: ball:GetAttribute("target") holds one name, so changes are logged
    -- with timestamps and the clash order is read from that log.
     local Clash_Track = setmetatable({}, { __mode = 'k' })

     local function Clash_Watch(Ball)
        local Track = Clash_Track[Ball]
        if Track then return Track end
        Track = { History = {}, Last = nil }
        Clash_Track[Ball] = Track
        local function Push()
            local Raw = Ball:GetAttribute("target")
            local Name = (typeof(Raw) == "Instance" and Raw.Name) or (Raw ~= nil and tostring(Raw)) or nil
            if not Name or Name == "" or Name == Track.Last then return end   -- empty target (e.g. training ball) is never logged
            Track.Last = Name
            local History = Track.History
            History[#History + 1] = { Name = Name, Time = os.clock() }
            if #History > 24 then table.remove(History, 1) end
        end
        Push()
        pcall(function() Ball:GetAttributeChangedSignal("target"):Connect(Push) end)
        return Track
    end

    local function Is_Living_Player(Alive, Name)
        local Model = Alive and Alive:FindFirstChild(Name)
        local Hum = Model and Model:FindFirstChildOfClass('Humanoid')
        return Model ~= nil and (not Hum or Hum.Health > 0)
    end

    -- returns the lap's player names (everyone except us) when the log shows a closed lap Me > P2 [> P3 ...] > Me, the lap order
    -- matches the previous lap (when there is one), and whatever came after the
    -- last "Me" is still an in-order prefix of that lap (ball mid-lap).
     local function Clash_Get_Lap(Ball)
        local Log = Clash_Watch(Ball).History
        local Alive = workspace:FindFirstChild("Alive")
        if not Alive then return nil end
        local Me, Now = LP.Name, os.clock()
        local Window = tonumber(Cfg.SmartClashWindow) or 3
        local Count = #Log
        if Count < 3 or Now - Log[Count].Time > Window then return nil end

        local J, I, H
        for Index = Count, 1, -1 do
            if Log[Index].Name == Me then
                if not J then J = Index elseif not I then I = Index else H = Index; break end
            end
        end
        if not I or Now - Log[I].Time > Window then return nil end

        local Lap, Seen = {}, {}
        for Index = I + 1, J - 1 do
            local Name = Log[Index].Name
            if Seen[Name] or not Is_Living_Player(Alive, Name) then return nil end
            Seen[Name] = true
            Lap[#Lap + 1] = Name
        end
        if #Lap == 0 then return nil end

        if H and Now - Log[H].Time <= Window * 2 then          -- previous lap must be the same order
            if (I - H - 1) ~= #Lap then return nil end
            for Offset = 1, #Lap do
                if Log[H + Offset].Name ~= Lap[Offset] then return nil end
            end
        end

        local Tail = Count - J                                  -- entries after the latest "Me"
        if Tail > #Lap then return nil end
        for Offset = 1, Tail do
            if Log[J + Offset].Name ~= Lap[Offset] then return nil end
        end
        return Lap
    end

    -- Ball velocity points at us and at nobody else more directly.
     local function Ball_Heading_At_Me(Ball, Character, Root)
        local BallPos = GetBallPos(Ball)
        local Vel = GetBallVel(Ball)
        local Speed = Vel.Magnitude
        if Speed < 1 then return false end
        local Dir = Vel / Speed
        local function Align(Position)
            local Offset = Position - BallPos
            local Magnitude = Offset.Magnitude
            if Magnitude < 1e-3 then return 1 end
            return Dir:Dot(Offset / Magnitude)
        end
        local MyAlign = Align(Root.Position)
        if MyAlign < (tonumber(Cfg.SmartAimDot) or 0.92) then return false end
        local Alive = workspace:FindFirstChild("Alive")
        if Alive then
            for _, Other in ipairs(Alive:GetChildren()) do
                if Other ~= Character and Other:IsA('Model') then
                    local OtherRoot = Other:FindFirstChild('HumanoidRootPart') or Other.PrimaryPart
                    local OtherHum = Other:FindFirstChildOfClass('Humanoid')
                    if OtherRoot and (not OtherHum or OtherHum.Health > 0) and Align(OtherRoot.Position) > MyAlign then
                        return false
                    end
                end
            end
        end
        return true
    end

     -- Clash radius by headcount (me + players in the lap): 2 -> 33, 3 -> 50, 4+ -> 65 studs.
     local function Clash_Radius(Participants)
        if Participants <= 2 then return tonumber(Cfg.SmartClashRange2) or 33 end
        if Participants == 3 then return tonumber(Cfg.SmartClashRange3) or 50 end
        return tonumber(Cfg.SmartClashRange4) or 65
    end

     local function Smart_Try(Ball, Delta)
        Spam_State.Engaged = false      -- true only while every clash condition below holds
        if not Cfg.SmartAutoSpam or not Ball or not Ball.Parent then return end

        local Character = GetChar()
        local Root = GetHRP(Character)
        if not Root then return end
        local Now = os.clock()
        local Ping = GetPing() or 30

        -- range gate (same speed/ping range as Auto Spam)
        local Speed = GetBallVel(Ball).Magnitude
        local Range = math.clamp((Speed / 5) + (Ping / 5000), 26, 70) * (tonumber(Cfg.SpamThreshold) or 1)
        if (Root.Position - GetBallPos(Ball)).Magnitude > Range * 1.5 then return end

        -- Training balls have no opponents and an empty target: skip the clash checks.
        if not BallState.isTraining then
            -- ordered clash: Me > P2 > Me  /  Me > P2 > P3 > Me
            local Lap = Clash_Get_Lap(Ball)
            if not Lap then return end

            -- every player in the clash must be within the radius for this headcount
            local Radius = Clash_Radius(#Lap + 1)
            local Alive = workspace:FindFirstChild("Alive")
            for _, Name in ipairs(Lap) do
                local Model = Alive and Alive:FindFirstChild(Name)
                local OtherRoot = Model and (Model:FindFirstChild('HumanoidRootPart') or Model.PrimaryPart)
                if not OtherRoot or (OtherRoot.Position - Root.Position).Magnitude > Radius then return end
            end
        end

        -- ball really flying at me
        if not Ball_Heading_At_Me(Ball, Character, Root) then return end

        Spam_State.Engaged = true       -- Auto Parry stays off while this is true

        -- server cooldown gate
        if not CD_Ready(Now) then return end

        -- one parry, then wait for the server's 'cooldown done'
        CD_MarkFired(Now, Ping)
        MarkSpamParryPause(Delta)
        pcall(FireParry, Ball, true)
    end

    --// AUTO PARRY QUEUE --------------------------------------------------
    -- The Auto Parry loop only ADDS entries (one per ball, any time, also while
    -- waiting). This processor is the only thing that fires them: if the server
    -- cooldown is clear the head entry fires at once, otherwise it waits and fires
    -- the moment VisualCD reports 'cooldown done'. One parry per cooldown.
    local Parry_Queue = {}
    local Parry_Queued = setmetatable({}, { __mode = 'k' })   -- ball -> true while queued

    local function Parry_Queue_Clear()
        if #Parry_Queue == 0 then return end
        table.clear(Parry_Queue)
        table.clear(Parry_Queued)
    end

    local function Parry_Queue_Add(Ball, IsSpam, TryAbility)
        if not Ball or Parry_Queued[Ball] or #Parry_Queue >= (tonumber(Cfg.ParryQueueMax) or 4) then return false end
        Parry_Queued[Ball] = true
        Parry_Queue[#Parry_Queue + 1] = { Ball = Ball, IsSpam = IsSpam, TryAbility = TryAbility, Time = os.clock() }
        return true
    end

    local function Parry_Queue_Process()
        local MaxAge = tonumber(Cfg.ParryQueueMaxAge) or 1.5
        while #Parry_Queue > 0 do
            local Now = os.clock()
            local Item = Parry_Queue[1]
            local Ball = Item.Ball
            -- drop entries whose ball is gone, too old, or no longer aimed at us
            local Stale = not Ball.Parent or (Now - Item.Time) > MaxAge
                or (not BallState.isTraining and (Ball:GetAttribute("target") ~= LP.Name or Dragon_Blocks(Ball)))
            if Stale then
                table.remove(Parry_Queue, 1)
                Parry_Queued[Ball] = nil
            else
                if Now < SpamParryPauseUntil or not CD_Ready(Now) then return end
                table.remove(Parry_Queue, 1)
                Parry_Queued[Ball] = nil
                local UsedAbility = Item.TryAbility and Try_Auto_Ability()
                if not UsedAbility then
                    CD_MarkFired(Now, GetPing() or 30)
                    pcall(FireParry, Ball, Item.IsSpam)
                end
                return                       -- one parry per cooldown
            end
        end
    end

    local function Smart_OnVisualCD(Block, Active, Duration)
        if Block ~= true then return end     -- anything that is not a block message is ignored
        local Now = os.clock()
        if Active == true then
            CD.Active, CD.ActiveSince = true, Now
            if CD.Locked then
                CD.SawStart = true
                CD.Deadline = Now + (tonumber(Cfg.SmartCDFailsafe) or 3)
            end
        elseif Active == nil and Duration == nil then
            CD.Active = false
            if CD.Locked and CD.SawStart then CD.Locked = false end   -- a 'done' from before our shot is ignored
            if not CD.Locked then
                pcall(Parry_Queue_Process)                             -- waiting parry fires immediately
                if Cfg.SmartAutoSpam then
                    local Ball = GetBall()
                    if Ball then pcall(Smart_Try, Ball, 0) end
                end
            end
        end                                  -- any other argument shape is ignored
    end

    -- Dragon gone: clear every parry lock so Auto Parry can hit again immediately.
    Release_Parry_Cooldown = function()
        CD.Active, CD.Locked, CD.SawStart = false, false, false
        for _, Ball in ipairs(GetBalls()) do
            local st = Ball_Parry_State(Ball)
            st.Id = st.Id + 1
            st.Parried, st.Parrying, st.V2Until = false, false, 0
        end
        _allusiveParried = false
        _v2ParryUntil = 0
        local fst = getgenv().FlyteBB_State
        if fst then fst.ParryCooldownUntil = nil; fst.ExtraParryCooldownUntil = nil end
        pcall(Parry_Queue_Process)
    end

    if shared._SmartCDConn then pcall(function() shared._SmartCDConn:Disconnect() end); shared._SmartCDConn = nil end
    task.spawn(function()
        local Remotes = RS:WaitForChild("Remotes", 30)
        local Event = Remotes and Remotes:WaitForChild("VisualCD", 30)
        if Event then
            shared._SmartCDConn = Event.OnClientEvent:Connect(function(...)
                xpcall(Smart_OnVisualCD, function(Err) warn("VisualCD handler failure: " .. tostring(Err)) end, ...)
            end)
        end
    end)

     local function Spam_Tick(Delta, Ball)
        Expire_Parry_History()
        if Ball and Ball.Parent then Clash_Watch(Ball) end   -- keep the target log running while spam is off

        -- Smart Auto Spam owns spamming when enabled (Auto Spam does not need to be on).
        if Cfg.SmartAutoSpam then
            Spam_State.Accumulator = 0
            Smart_Try(Ball, Delta)
            return
        end
        Spam_State.Engaged = false

        if not Cfg.AutoSpam then
            Spam_State.Accumulator = 0
            return
        end

        local Character = GetChar()
        local Root = GetHRP(Character)
        if not Root or not Ball or not Ball.Parent then
            Spam_State.Accumulator = 0
            return
        end

        local Speed = GetBallVel(Ball).Magnitude
        local Ping = GetPing() or 30
        local Base = math.clamp((Speed / 5) + (Ping / 5000), 26, 70)
        local Range = Base * (tonumber(Cfg.SpamThreshold) or 1)
        local BallDistance = (Root.Position - GetBallPos(Ball)).Magnitude
        local OpponentDistance = Get_Nearest_OpponentDistance(Character)
        if not (BallDistance <= Range * 1.5 and OpponentDistance <= Range and Parry_History.Count > 1) then
            Spam_State.Accumulator = 0
            return
        end

        local CPS = tonumber(Cfg.CPS) or 60
        if CPS <= 0 then return end

        Spam_State.Accumulator = Spam_State.Accumulator + (Delta or 0)
        local Shots = math.floor(Spam_State.Accumulator * CPS)
        if Shots <= 0 then return end

        Spam_State.Accumulator = Spam_State.Accumulator - (Shots / CPS)
        if Spam_State.Accumulator < 0 then Spam_State.Accumulator = 0 end
        if Shots > 10 then Shots = 10 end

        MarkSpamParryPause(Delta)
        for _ = 1, Shots do
            FireParry(Ball, true)
        end
    end

    --// [ PRE-CLICK ] —  kill_pre_click ---------------------------
     local function Get_Alive_Position(Name)
        if type(Name) ~= "string" or Name == "" then return nil end
        local Alive = workspace:FindFirstChild("Alive")
        local Model = Alive and Alive:FindFirstChild(Name)
        if not Model then Model = workspace:FindFirstChild(Name) end
        if Model and Model:IsA("Model") then
            local Root = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart or Model:FindFirstChildWhichIsA("BasePart")
            if Root then return Root.Position end
        end
        return nil
    end

     local function Get_Fastest_Ball_Speed()
        local Fastest = 0
        for _, Ball in ipairs(GetBalls()) do
            local Speed = GetBallVel(Ball).Magnitude
            if Speed > Fastest then Fastest = Speed end
        end
        return Fastest
    end

     local _preClickLastFire = 0
     local function On_Killed_Event(...)
        if not Cfg.AutoParry or not Cfg.PreClick then return end
        local Character = GetChar()
        local Root = GetHRP(Character)
        if not Root then return end
        local Humanoid = GetHum(Character)
        if not Humanoid or Humanoid.Health <= 0 then return end

        local MinSpeed = tonumber(Cfg.PreClickSpeed) or 1
        if MinSpeed > 1 and Get_Fastest_Ball_Speed() < MinSpeed then return end

        local Range = tonumber(Cfg.PreClickRange) or 30
        local Found = false

        local Args = table.pack(...)
        for Index = 1, Args.n do
            local Value = Args[Index]
            local Name
            if type(Value) == "string" then
                Name = Value
            elseif type(Value) == "table" then
                Name = Value.Name or Value.DisplayName or Value.Victim or Value.Player
            end
            local Position = Get_Alive_Position(Name)
            if Position and (Root.Position - Position).Magnitude <= Range then
                Found = true
                break
            end
        end

        if not Found then
            local Alive = workspace:FindFirstChild("Alive")
            if Alive then
                for _, Model in ipairs(Alive:GetChildren()) do
                    if Model ~= Character and Model:IsA("Model") then
                        local OtherRoot = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart
                        if OtherRoot and (Root.Position - OtherRoot.Position).Magnitude <= Range then
                            Found = true
                            break
                        end
                    end
                end
            end
        end

        if Found then
            local now = os.clock()
            if now - (_preClickLastFire or 0) >= 0.15 then
                _preClickLastFire = now
                local Ball = GetBall()
                if Ball and Ball.Parent then
                    pcall(function() FireParry(Ball, true) end)
                end
            end
        end
    end

    local _preClickConnected = false
    local function ConnectPreClickEvent()
        if _preClickConnected then return end
        local remotes = RS:FindFirstChild('Remotes')
        local killedRemote = remotes and remotes:FindFirstChild('Killed')
        if killedRemote and killedRemote:IsA('RemoteEvent') then
            _preClickConnected = true
            killedRemote.OnClientEvent:Connect(On_Killed_Event)
        end
    end
    pcall(ConnectPreClickEvent)
    task.spawn(function()
        for _ = 1, 30 do
            if _preClickConnected then break end
            task.wait(1)
            pcall(ConnectPreClickEvent)
        end
    end)

    --// [ DEVICE SPOOFER ] —  DEVICE_SPOOFER_SOURCE (profile-aware) ------
    --  shipped a single hard-coded "PC" target. The Misc dropdown picks a
    -- profile and the placeholders below are substituted into the source
    -- before it is run or written to the auto-exec folder.
     local DEVICE_PROFILES = {
        ['PC']      = { Label = 'PC',      Platform = 'Windows', Touch = false, Keyboard = true,  Mouse = true,  Gamepad = false, VR = false, Preferred = 'KeyboardAndMouse' },
        ['Mobile']  = { Label = 'Mobile',  Platform = 'Android', Touch = true,  Keyboard = false, Mouse = false, Gamepad = false, VR = false, Preferred = 'Touch' },
        ['Tablet']  = { Label = 'Tablet',  Platform = 'IOS',     Touch = true,  Keyboard = false, Mouse = false, Gamepad = false, VR = false, Preferred = 'Touch' },
        ['Console'] = { Label = 'Console', Platform = 'XboxOne', Touch = false, Keyboard = false, Mouse = false, Gamepad = true,  VR = false, Preferred = 'Gamepad' },
        ['VR']      = { Label = 'VR',      Platform = 'Windows', Touch = false, Keyboard = false, Mouse = false, Gamepad = false, VR = true,  Preferred = 'Gamepad' },
    }

     local DEVICE_SPOOFER_TEMPLATE = [==[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TARGET_DEVICE = "__DEVICE_LABEL__"
local TARGET_PLATFORM = __TARGET_PLATFORM__
task.spawn(function()
	local cgm = ReplicatedStorage:WaitForChild("ClientGameModules", 30)
	if not cgm then return end
	local mod = cgm:WaitForChild("DeviceListener", 30)
	if not mod then return end
	local ok, DL = pcall(require, mod)
	if not ok or not DL then return end
	if DL.RegisterDeviceChanged then
		local OriginalRegister = DL.RegisterDeviceChanged
		DL.RegisterDeviceChanged = function(self, deviceTable, ...)
			if type(deviceTable) == "table" then
				for k, v in pairs(deviceTable) do
					if type(v) == "string" then
						local l = v:lower()
						if l == "mobile" or l == "phone" or l == "tablet" or l == "android" or l == "ios"
							or l == "windows" or l == "pc" or l == "mac" or l == "osx" then
							deviceTable[k] = TARGET_DEVICE
						end
					elseif typeof(v) == "EnumItem" then
						if v == Enum.Platform.Android or v == Enum.Platform.IOS
							or v == Enum.Platform.Windows or v == Enum.Platform.OSX then
							deviceTable[k] = TARGET_PLATFORM
						end
					end
				end
			elseif type(deviceTable) == "string" then
				local l = deviceTable:lower()
				if l == "mobile" or l == "phone" or l == "tablet" or l == "android" or l == "ios"
					or l == "windows" or l == "pc" or l == "mac" or l == "osx" then
					deviceTable = TARGET_DEVICE
				end
			end
			return OriginalRegister(self, deviceTable, ...)
		end
	end
	pcall(function() DL.Device = TARGET_DEVICE end)
	pcall(function()
		if type(DL.Device) == "table" then
			for k, v in pairs(DL.Device) do
				if type(v) == "string" then
					local l = v:lower()
					if l == "mobile" or l == "phone" or l == "android" or l == "ios"
						or l == "windows" or l == "pc" or l == "mac" or l == "osx" then
						DL.Device[k] = TARGET_DEVICE
					end
				end
			end
		end
	end)
	task.wait(1)
	pcall(function() DL:RegisterDeviceChanged(DL.Device) end)
	task.wait(2)
	pcall(function() DL:RegisterDeviceChanged(DL.Device) end)
	task.wait(3)
	pcall(function() DL:RegisterDeviceChanged(DL.Device) end)
end)
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
	if self == UserInputService then
		if key == "GetPlatform" then
			return function() return TARGET_PLATFORM end
		end
		if key == "TouchEnabled" or key == "TouchScreenEnabled" or key == "AccelerometerEnabled" or key == "GyroscopeEnabled" then
			return __TOUCH__
		end
		if key == "GamepadEnabled" then
			return __GAMEPAD__
		end
		if key == "VREnabled" then
			return __VR__
		end
		if key == "KeyboardEnabled" then
			return __KEYBOARD__
		end
		if key == "MouseEnabled" then
			return __MOUSE__
		end
		if key == "PreferredInput" then
			return __PREFERRED__
		end
	end
	return oldIndex(self, key)
end)
setreadonly(mt, true)
]==]

     local function Build_Device_Spoofer_Source(Target)
        local Profile = DEVICE_PROFILES[Target] or DEVICE_PROFILES['PC']
        local Source = DEVICE_SPOOFER_TEMPLATE
        Source = Source:gsub('__DEVICE_LABEL__', Profile.Label)
        Source = Source:gsub('__TARGET_PLATFORM__', 'Enum.Platform.' .. Profile.Platform)
        Source = Source:gsub('__TOUCH__', tostring(Profile.Touch))
        Source = Source:gsub('__KEYBOARD__', tostring(Profile.Keyboard))
        Source = Source:gsub('__MOUSE__', tostring(Profile.Mouse))
        Source = Source:gsub('__GAMEPAD__', tostring(Profile.Gamepad))
        Source = Source:gsub('__VR__', tostring(Profile.VR))
        Source = Source:gsub('__PREFERRED__', 'Enum.PreferredInput.' .. Profile.Preferred)
        return Source
    end

     local function Recognize_Autoexec_Folder()
        local Folders = {
            "autoexec", "AutoExec", "autoexec/scripts",
            "workspace/autoexec", "scripts/autoexec",
        }
        for _, Candidate in ipairs(Folders) do
            if isfolder and isfolder(Candidate) then
                return Candidate
            end
        end
        return nil
    end

     local function Apply_Device_Spoofer(Rejoin)
        local Target = Cfg.DeviceTarget or 'PC'
        local Source = Build_Device_Spoofer_Source(Target)
        local Success = pcall(function()
            local Chunk = loadstring(Source)
            if Chunk then Chunk() end
        end)
        pcall(function()
            if writefile then
                pcall(writefile, "ds_rejoin.flag", "1")
                local Folder = Recognize_Autoexec_Folder()
                if Folder then
                    pcall(writefile, Folder .. "/device_spoofer.lua", Source)
                end
            end
        end)
        if Rejoin then
            task.spawn(function()
                task.wait(0.5)
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
                end)
            end)
        end
        Log(Success and 'Success' or 'Warning', 'Device Spoofer',
            Success and (' device spoofer applied (' .. Target .. ').')
                or (' device spoofer loaded with warnings (' .. Target .. ').'))
    end

    --// [ IMMORTALITY DESYNC ] — V1 (Virex Triangle) + V2 (Orbit Desync) --
    -- Port of immortal.txt. A transparent, anchored EH_CamAnchor holds the
    -- camera while the module walks/carries the HumanoidRootPart and floods
    -- the physics sender rate, so the server keeps the last-seen pose. V1
    -- flings a rotating triangle, V2 orbits between Height Min and Height
    -- Max. Each root change is restored one render frame later. This is a
    -- desync, not a real godmode: it can strand you out of the map.
     local Immortal_State = {
        Anchor = nil,
    }

     local function Immortal_Anchor()
        local Anchor = Immortal_State.Anchor
        if Anchor and Anchor.Parent then return Anchor end
        Anchor = workspace:FindFirstChild("EH_CamAnchor")
        if not Anchor then
            Anchor = Instance.new("Part")
            Anchor.Size = Vector3.new(0.1, 0.1, 0.1)
            Anchor.Transparency = 1
            Anchor.CanCollide = false
            Anchor.Anchored = true
            Anchor.Name = "EH_CamAnchor"
            Anchor.Parent = workspace
        end
        Immortal_State.Anchor = Anchor
        return Anchor
    end

     local function Immortal_Tick()
        local Character = LP.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
        local Cam = workspace.CurrentCamera
        if not HRP or not Hum or Hum.Health <= 0 or not Cam then return end

        local Anchor = Immortal_Anchor()
        local V1 = Cfg.ImmortalEnabled and Cfg.ImmortalV1
        local V2 = Cfg.ImmortalEnabled and Cfg.ImmortalV2

        if not (V1 or V2) then
            if Cam.CameraSubject == Anchor then Cam.CameraSubject = Hum end
            return
        end

        Anchor.CFrame = Anchor.CFrame:Lerp(CFrame.new(HRP.Position), 0.3)
        if Cam.CameraSubject ~= Anchor then Cam.CameraSubject = Anchor end
        if type(setfflag) == "function" then
            pcall(setfflag, "S2PhysicsSenderRate", "15")
        end

        if V1 then
            local T = tick()
            local Spot = math.floor(T * 95) % 3
            local Reach = 14
            if type(setfflag) == "function" then
                pcall(setfflag, "S2PhysicsSenderRate", "1333335")
            end
            HRP.CFrame = HRP.CFrame + Vector3.new(0, 0.01, 0)
            local Look = HRP.CFrame.LookVector
            local Right = HRP.CFrame.RightVector
            local Triangle, Velocity = Vector3.zero, Vector3.zero
            if Spot == 0 then
                Triangle = (-Right * Reach) + (Look * (Reach * 0.5)); Velocity = -Right * 350
            elseif Spot == 1 then
                Triangle = (Right * Reach) + (Look * (Reach * 0.5)); Velocity = Right * 350
            else
                Triangle = -Look * Reach; Velocity = -Look * 350
            end
            local OldCF = HRP.CFrame
            local OldVel = HRP.AssemblyLinearVelocity
            HRP.CFrame = OldCF * CFrame.new(Triangle)
            HRP.AssemblyLinearVelocity = Velocity
            task.spawn(function()
                RunService.RenderStepped:Wait()
                if HRP and HRP.Parent then
                    HRP.CFrame = OldCF
                    HRP.AssemblyLinearVelocity = OldVel
                end
            end)
        elseif V2 then
            local Angle = (Cfg.ImmortalMode == "Auto") and 145 or (tonumber(Cfg.ImmortalAngle) or 145)
            local T = tick()
            if type(setfflag) == "function" then
                pcall(setfflag, "S2PhysicsSenderRate", "1333335")
            end
            HRP.CFrame = HRP.CFrame + Vector3.new(0, 0.01, 0)
            local Round = T * math.pi * 2 * Angle / 5
            local HeightMin = tonumber(Cfg.ImmortalHeightMin) or -8
            local HeightMax = tonumber(Cfg.ImmortalHeightMax) or 35
            local Y = (math.floor(T * 135) % 2 == 0) and HeightMin or HeightMax
            local Radius = tonumber(Cfg.ImmortalRadius) or 10
            local Offset = Vector3.new(math.cos(Round) * Radius, Y, math.sin(Round) * Radius)
            local OldCF = HRP.CFrame
            local OldVel = HRP.AssemblyLinearVelocity
            HRP.CFrame = OldCF + Offset
            HRP.AssemblyLinearVelocity = Vector3.new(
                math.sin(Round) * 250,
                (Y == HeightMax) and 280 or -280,
                math.cos(Round) * 250
            )
            task.spawn(function()
                RunService.RenderStepped:Wait()
                if HRP and HRP.Parent then
                    HRP.CFrame = OldCF
                    HRP.AssemblyLinearVelocity = OldVel
                end
            end)
        end
    end
    
 Players = game:GetService("Players")
 ReplicatedStorage = game:GetService("ReplicatedStorage")
 LocalPlayer = Players.LocalPlayer

 ESP_Storage = {}
 ESP_RespawnConns = {}
 ESP_Active_Task = nil
 ESP_Running = false

 DataAbilities = ReplicatedStorage:WaitForChild("Misc"):WaitForChild("DataAbilities")

 function RemovePlayerESP(plr)
    if ESP_Storage[plr] then
        pcall(function() ESP_Storage[plr]:Destroy() end)
        ESP_Storage[plr] = nil
    end
end

 function DetachRespawnHook(plr)
    if ESP_RespawnConns[plr] then
        pcall(function() ESP_RespawnConns[plr]:Disconnect() end)
        ESP_RespawnConns[plr] = nil
    end
end

 function AttachPlayerESP(plr)
    if plr == LocalPlayer then return end
    RemovePlayerESP(plr)

    local char = plr.Character
    if not char then
        local ok, result = pcall(function()
            return plr.CharacterAdded:Wait()
        end)
        if not ok or not ESP_Running then return end
        char = result
    end
    if not ESP_Running then return end

    local head = char:WaitForChild("Head", 5)
    if not head or not ESP_Running then return end

    local sGui = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local espStyle = Cfg.ESPStyle or 'Default'
    -- Default: icon + name + cooldown; compact modes show only the selected elements.
    local nameCooldownMode = (espStyle == 'Name Only' or espStyle == 'Name + Cooldown')
    local imageCooldownMode = (espStyle == 'Image + Cooldown')
    local iconOnlyMode = (espStyle == 'Icon Only')

    local BGui = Instance.new("BillboardGui")
    BGui.Name           = "Plr_Ability_ESP"
    BGui.AlwaysOnTop    = true
    BGui.StudsOffset    = Vector3.new(0, 3.0, 0)
    BGui.Size = iconOnlyMode and UDim2.new(0, 28, 0, 28)
             or nameCooldownMode and UDim2.new(0, 110, 0, 36)
             or imageCooldownMode and UDim2.new(0, 64, 0, 42)
             or UDim2.new(0, 140, 0, 52)
    BGui.Adornee        = head
    BGui.Parent         = sGui
    ESP_Storage[plr]    = BGui

    local iconOX = (espStyle == 'Default') and 5 or 2
    local textOX = (espStyle == 'Default') and 36 or 2

    local Icon = Instance.new("ImageLabel")
    Icon.BackgroundTransparency = 1
    Icon.Image   = "rbxassetid://9094483852"
    Icon.Visible = (espStyle == 'Default' or iconOnlyMode or imageCooldownMode)
    Icon.Size     = imageCooldownMode and UDim2.fromOffset(24, 24) or UDim2.fromOffset(26, 26)
    Icon.Position = imageCooldownMode and UDim2.fromOffset(2, 3) or UDim2.fromOffset(iconOX, 7)
    Icon.Parent   = BGui

    -- Row 1: ability name
    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.TextColor3         = Cfg.ESPAbilityColor or Color3.fromRGB(255, 255, 255)
    StatusLbl.Font               = Enum.Font.GothamBold
    StatusLbl.TextXAlignment     = Enum.TextXAlignment.Left
    StatusLbl.TextStrokeTransparency = 0
    StatusLbl.Text               = "NONE"
    StatusLbl.TextSize           = 10
    StatusLbl.Size               = UDim2.fromOffset(nameCooldownMode and 106 or 95, 13)
    StatusLbl.Position           = UDim2.fromOffset(textOX, 2)
    StatusLbl.Visible            = (espStyle ~= 'Icon Only' and not imageCooldownMode)
    StatusLbl.Parent             = BGui

    -- Row 2: cooldown / READY
    local ReadyLbl = Instance.new("TextLabel")
    ReadyLbl.BackgroundTransparency  = 1
    ReadyLbl.TextColor3              = Cfg.ESPReadyColor or Color3.fromRGB(80, 220, 120)
    ReadyLbl.Font                    = Enum.Font.GothamBlack
    ReadyLbl.TextXAlignment          = Enum.TextXAlignment.Left
    ReadyLbl.TextStrokeTransparency  = 0
    ReadyLbl.Text                    = "READY"
    ReadyLbl.TextSize                = 9
    ReadyLbl.Size                    = UDim2.fromOffset(imageCooldownMode and 60 or (nameCooldownMode and 106 or 95), 12)
    ReadyLbl.Position                = imageCooldownMode and UDim2.fromOffset(2, 27) or UDim2.fromOffset(textOX, 15)
    ReadyLbl.Visible                 = (espStyle ~= 'Icon Only')
    ReadyLbl.Parent                  = BGui

    -- Row 3: active timer (Allusive-style — shows while AbilityActive=true)
    local ActiveLbl = Instance.new("TextLabel")
    ActiveLbl.BackgroundTransparency = 1
    ActiveLbl.TextColor3             = Color3.fromRGB(100, 200, 255)
    ActiveLbl.Font                   = Enum.Font.Gotham
    ActiveLbl.TextXAlignment         = Enum.TextXAlignment.Left
    ActiveLbl.TextStrokeTransparency = 0
    ActiveLbl.Text                   = ""
    ActiveLbl.TextSize               = 9
    ActiveLbl.Size                   = UDim2.fromOffset(nameCooldownMode and 106 or 95, 11)
    ActiveLbl.Position               = UDim2.fromOffset(textOX, 28)
    ActiveLbl.Visible                = false
    ActiveLbl.Parent                 = BGui

    -- Allusive-style per-player state (tracked by AttributeChanged events)
    local espState = {
        cdStart    = nil,   -- os.clock() when cd began
        cdLen      = nil,   -- cooldown duration in seconds
        activeStart = nil,  -- os.clock() when ability activated
        activeDur   = nil,  -- ability active duration in seconds
        charConns   = {},
    }

    local function hookChar(c)
        for _, cn in ipairs(espState.charConns) do pcall(function() cn:Disconnect() end) end
        table.clear(espState.charConns)
        espState.cdStart = nil; espState.cdLen = nil
        espState.activeStart = nil; espState.activeDur = nil

        if not c then return end

        -- AbilityActive + AbilityDuration: track active timer (Allusive)
        table.insert(espState.charConns, c.AttributeChanged:Connect(function(attr)
            if attr == "AbilityActive" then
                local active = c:GetAttribute("AbilityActive")
                local dur    = c:GetAttribute("AbilityDuration") or 0
                if active == true and dur > 0 then
                    espState.activeStart = os.clock()
                    espState.activeDur   = dur
                else
                    espState.activeStart = nil
                    espState.activeDur   = nil
                end
            elseif attr == "AbilityDuration" then
                local active = c:GetAttribute("AbilityActive")
                local dur    = c:GetAttribute("AbilityDuration") or 0
                if active == true and dur > 0 then
                    espState.activeStart = os.clock()
                    espState.activeDur   = dur
                end
            elseif attr == "CooldownActive" then
                -- When CooldownActive turns true, start tracking cd length from CooldownExpiration
                local cdActive = c:GetAttribute("CooldownActive")
                if cdActive == true then
                    espState.cdStart = os.clock()
                    local expiry = plr:GetAttribute("CooldownExpiration")
                    if expiry then
                        espState.cdLen = math.max(0, expiry - workspace:GetServerTimeNow())
                    else
                        espState.cdLen = nil
                    end
                else
                    espState.cdStart = nil
                    espState.cdLen   = nil
                end
            end
        end))
    end

    -- Hook initial character and respawns
    hookChar(char)
    table.insert(espState.charConns, plr.CharacterAdded:Connect(function(c)
        task.wait(0.1)
        hookChar(c)
    end))
    table.insert(espState.charConns, plr.CharacterRemoving:Connect(function()
        espState.cdStart = nil; espState.cdLen = nil
        espState.activeStart = nil; espState.activeDur = nil
    end))

    task.spawn(function()
        while BGui and BGui.Parent and ESP_Running do
            pcall(function()
                local liveChar = plr.Character
                if not liveChar then return end

                local liveHead = liveChar:FindFirstChild("Head")
                if liveHead and BGui.Adornee ~= liveHead then
                    BGui.Adornee = liveHead
                end

                if espStyle == 'Icon Only' then return end

                -- Ability name + icon
                local rawAbility = liveChar:GetAttribute("CurrentlyEquippedAbility")
                    or plr:GetAttribute("EquippedAbility")
                    or plr:GetAttribute("Ability")
                    or "None"
                StatusLbl.Text      = string.upper(tostring(rawAbility))
                StatusLbl.TextColor3 = Cfg.ESPAbilityColor or Color3.fromRGB(255, 255, 255)

                local abilityFolder = DataAbilities and DataAbilities:FindFirstChild(tostring(rawAbility))
                if abilityFolder then
                    local assetIcon = abilityFolder:GetAttribute("Icon") or abilityFolder:GetAttribute("Icon1")
                    Icon.Image = (assetIcon and assetIcon ~= "") and assetIcon or "rbxassetid://9094483852"
                else
                    Icon.Image = "rbxassetid://9094483852"
                end

                -- Cooldown row (Allusive: cdStart + cdLen)
                local now = os.clock()
                local cdActive = liveChar:GetAttribute("CooldownActive") == true
                local cdExpiry = plr:GetAttribute("CooldownExpiration")
                local cdDiff   = cdExpiry and (cdExpiry - workspace:GetServerTimeNow()) or 0

                -- prefer server CooldownExpiration if available, fall back to local cdStart
                local cdRemain = 0
                if cdDiff > 0 then
                    cdRemain = cdDiff
                elseif espState.cdStart and espState.cdLen then
                    cdRemain = math.max(0, espState.cdLen - (now - espState.cdStart))
                    if cdRemain <= 0 then
                        espState.cdStart = nil; espState.cdLen = nil
                    end
                end

                local abActive = liveChar:GetAttribute("AbilityActive") == true
                local isReady  = not abActive and cdRemain <= 0 and not cdActive

                if isReady then
                    ReadyLbl.Text      = "READY"
                    ReadyLbl.TextColor3 = Cfg.ESPReadyColor or Color3.fromRGB(80, 220, 120)
                    ReadyLbl.Visible   = true
                elseif cdRemain > 0 then
                    ReadyLbl.Text      = string.format("cd  %.1fs", cdRemain)
                    ReadyLbl.TextColor3 = Color3.fromRGB(220, 100, 80)
                    ReadyLbl.Visible   = true
                else
                    ReadyLbl.Text      = "USED"
                    ReadyLbl.TextColor3 = Color3.fromRGB(180, 80, 80)
                    ReadyLbl.Visible   = true
                end

                -- Active timer row (Allusive-style)
                if imageCooldownMode then
                    ActiveLbl.Visible = false
                elseif espState.activeStart and espState.activeDur then
                    local remaining = math.max(0, espState.activeDur - (now - espState.activeStart))
                    if remaining > 0 then
                        ActiveLbl.Text    = string.format("active  %.1fs", remaining)
                        ActiveLbl.Visible = true
                    else
                        espState.activeStart = nil; espState.activeDur = nil
                        ActiveLbl.Visible = false
                    end
                else
                    ActiveLbl.Visible = false
                end
            end)
            task.wait(0.1)  -- 10 Hz — smoother timer display
        end
        -- cleanup
        for _, cn in ipairs(espState.charConns) do pcall(function() cn:Disconnect() end) end
        pcall(function() if BGui and BGui.Parent then BGui:Destroy() end end)
        if ESP_Storage[plr] == BGui then ESP_Storage[plr] = nil end
    end)
end

local function HookPlayerRespawn(plr)
    DetachRespawnHook(plr)
    ESP_RespawnConns[plr] = plr.CharacterAdded:Connect(function()
        if not ESP_Running then return end
        task.delay(0.3, function()
            if ESP_Running then
                task.spawn(AttachPlayerESP, plr)
            end
        end)
    end)
end

function SetESPAbility()
    ESP_Running = false

    if ESP_Active_Task then
        pcall(function() task.cancel(ESP_Active_Task) end)
        ESP_Active_Task = nil
    end

    for plr, _ in pairs(ESP_RespawnConns) do DetachRespawnHook(plr) end
    table.clear(ESP_RespawnConns)

    for plr, _ in pairs(ESP_Storage) do RemovePlayerESP(plr) end
    table.clear(ESP_Storage)

    if not Cfg.espability then return end

    ESP_Running = true

    ESP_Active_Task = task.spawn(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                HookPlayerRespawn(p)
                task.spawn(AttachPlayerESP, p)
            end
        end

        local connAdded = Players.PlayerAdded:Connect(function(p)
            if not ESP_Running or p == LocalPlayer then return end
            HookPlayerRespawn(p)
            task.spawn(AttachPlayerESP, p)
        end)

        local connRemoving = Players.PlayerRemoving:Connect(function(p)
            DetachRespawnHook(p)
            RemovePlayerESP(p)
        end)

        while ESP_Running do
            task.wait(0.5)
        end

        pcall(function() connAdded:Disconnect() end)
        pcall(function() connRemoving:Disconnect() end)

        for plr, _ in pairs(ESP_RespawnConns) do DetachRespawnHook(plr) end
        table.clear(ESP_RespawnConns)
        for plr, _ in pairs(ESP_Storage) do RemovePlayerESP(plr) end
        table.clear(ESP_Storage)
    end)
end

    --// [ SKIN CHANGER ] —  sword model / animation / FX override --
    -- Resolves the real Swords module + SwordsController, equips the named
    -- sword for the local player and rewrites the sword/slash arguments of
    -- the parry/sound/visual remotes so the chosen skin and its slash VFX are
    -- what everyone sees. Every executor-dependent step is pcall-guarded.
    local Skin_State = {
        Initialized = false,
        Enabled = false,
        Renderer = nil,
        Controller = nil,
        SwordModel = "",
        SwordAnimations = "",
        SwordFX = "",
        SlashName = "SlashEffect",
        Installed = {},
        HookedFuncs = {},
    }

    local function Skin_Refresh_Slash()
        local FXName = (Skin_State.SwordFX ~= "" and Skin_State.SwordFX) or Skin_State.SwordModel
        if FXName ~= "" and Skin_State.Renderer then
            local OK, Slash = pcall(function() return Skin_State.Renderer:GetSword(FXName) end)
            Skin_State.SlashName = (OK and Slash and Slash.SlashName) or "SlashEffect"
        else
            Skin_State.SlashName = "SlashEffect"
        end
    end

    local function Skin_Set_Sword()
        if Skin_State.SwordModel == "" or not LP.Character then return end
        local Renderer = Skin_State.Renderer
        pcall(function()
            if Renderer and type(rawget(Renderer, "EquipSwordTo")) == "function" then
                local Func = rawget(Renderer, "EquipSwordTo")
                if type(getupvalues) == "function" and type(setupvalue) == "function" then
                    local Ups = getupvalues(Func)
                    for i = 1, #Ups do
                        if type(Ups[i]) == "boolean" then
                            setupvalue(Func, i, false)
                            break
                        end
                    end
                end
            end
        end)
        pcall(function()
            if Renderer and type(Renderer.EquipSwordTo) == "function" then
                Renderer:EquipSwordTo(LP.Character, Skin_State.SwordModel)
            end
        end)
        task.spawn(function()
            local Attempts = 0
            while not Skin_State.Controller and Attempts < 20 do
                task.wait(0.5)
                Attempts = Attempts + 1
            end
            local Controller = Skin_State.Controller
            if not Controller then return end
            pcall(function()
                if type(Controller.SetSword) == "function" then
                    Controller:SetSword(Skin_State.SwordAnimations ~= "" and Skin_State.SwordAnimations or Skin_State.SwordModel)
                end
            end)
            pcall(function()
                local TargetSword = Skin_State.SwordFX ~= "" and Skin_State.SwordFX or Skin_State.SwordModel
                if RS.Remotes:FindFirstChild("FireSwordInfo") then
                    RS.Remotes.FireSwordInfo:FireServer(TargetSword)
                end
                if Controller.currentSword ~= nil then Controller.currentSword = TargetSword end
                if Controller.SwordFX ~= nil then Controller.SwordFX = TargetSword end
            end)
        end)
    end

    local function Skin_Hook_Remotes()
        if type(getconnections) ~= "function" then return end
        for _, RemoteName in ipairs({ "ParrySuccessAll", "ParryAttempt", "ParrySuccess", "PlaySound", "PlayVisuals" }) do
            local Remote = RS.Remotes:FindFirstChild(RemoteName)
            if Remote and Remote:IsA("RemoteEvent") then
                local Installed = Skin_State.Installed[RemoteName]
                if Installed then
                    for i = #Installed, 1, -1 do
                        if not Installed[i].Orig.Connected then
                            pcall(function() Installed[i].Wrap:Disconnect() end)
                            Skin_State.HookedFuncs[Installed[i].OrigFn] = nil
                            Skin_State.HookedFuncs[Installed[i].WrapFn] = nil
                            table.remove(Installed, i)
                        end
                    end
                end
                local OK, Conns = pcall(getconnections, Remote.OnClientEvent)
                if OK and type(Conns) == "table" then
                    for _, Connection in ipairs(Conns) do
                        local Func = Connection.Function
                        if Func and not Skin_State.HookedFuncs[Func] then
                            Skin_State.HookedFuncs[Func] = true
                            pcall(function() Connection:Disable() end)
                            local TargetFunc = Func
                            local OurFunc = function(...)
                                local Args = { ... }
                                local IsLocal = false
                                for _, Arg in ipairs(Args) do
                                    if tostring(Arg) == LP.Name or (typeof(Arg) == "Instance" and (Arg == LP.Character or Arg == LP)) then
                                        IsLocal = true
                                        break
                                    end
                                end
                                if IsLocal and Skin_State.Enabled then
                                    local FXSword = (Skin_State.SwordFX ~= "" and Skin_State.SwordFX) or Skin_State.SwordModel
                                    Skin_Refresh_Slash()
                                    local SwordFound, SlashFound = false, false
                                    for i, Arg in ipairs(Args) do
                                        if type(Arg) == "string" then
                                            if FXSword ~= "" and not SlashFound and (Arg:match("Slash") or Arg == "Default" or Arg:match("Effect")) then
                                                Args[i] = Skin_State.SlashName
                                                SlashFound = true
                                            elseif FXSword ~= "" and not SwordFound then
                                                local IsSword = false
                                                pcall(function()
                                                    if RS.Shared.ReplicatedInstances.Swords:FindFirstChild(Arg) then IsSword = true end
                                                end)
                                                if IsSword or Arg == LP:GetAttribute("CurrentlyEquippedSword") then
                                                    Args[i] = FXSword
                                                    SwordFound = true
                                                end
                                            end
                                        end
                                    end
                                    if FXSword ~= "" and not SlashFound and type(Args[1]) == "string" then
                                        Args[1] = Skin_State.SlashName
                                    end
                                    if FXSword ~= "" and not SwordFound and type(Args[3]) == "string" then
                                        Args[3] = FXSword
                                    end
                                end
                                if setthreadidentity then pcall(setthreadidentity, 2) end
                                pcall(TargetFunc, unpack(Args))
                            end
                            Skin_State.HookedFuncs[OurFunc] = true
                            local Entry = { Orig = Connection, OrigFn = Func, WrapFn = OurFunc }
                            Entry.Wrap = Remote.OnClientEvent:Connect(OurFunc)
                            Skin_State.Installed[RemoteName] = Skin_State.Installed[RemoteName] or {}
                            table.insert(Skin_State.Installed[RemoteName], Entry)
                        end
                    end
                end
            end
        end
    end

    local function Skin_Initialize()
        if Skin_State.Initialized then return end
        Skin_State.Initialized = true
        task.spawn(function()
            local OK, Renderer = pcall(function()
                return require(RS:WaitForChild("Shared", 9e9):WaitForChild("ReplicatedInstances", 9e9):WaitForChild("Swords", 9e9))
            end)
            if not OK then
                Skin_State.Initialized = false
                return
            end
            Skin_State.Renderer = Renderer
            task.spawn(function()
                while task.wait(0.25) and not Skin_State.Controller do
                    if type(getconnections) ~= "function" then return end
                    local OK2, Conns = pcall(getconnections, RS.Remotes.FireSwordInfo.OnClientEvent)
                    if OK2 and Conns then
                        for _, Connection in ipairs(Conns) do
                            if Connection.Function and type(islclosure) == "function" and islclosure(Connection.Function) then
                                local OK3, Ups = pcall(getupvalues, Connection.Function)
                                if OK3 and #Ups == 1 and type(Ups[1]) == "table" then
                                    Skin_State.Controller = Ups[1]
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            task.spawn(function()
                while task.wait(1) do
                    if Skin_State.Enabled then
                        Skin_Hook_Remotes()
                        local Character = LP.Character
                        if Character and Skin_State.SwordModel ~= "" then
                            if LP:GetAttribute("CurrentlyEquippedSword") ~= Skin_State.SwordModel
                                or not Character:FindFirstChild(Skin_State.SwordModel) then
                                Skin_Set_Sword()
                            end
                            for _, Child in ipairs(Character:GetChildren()) do
                                if Child:IsA("Model") and Child.Name ~= Skin_State.SwordModel then
                                    pcall(function() Child:Destroy() end)
                                end
                                task.wait()
                            end
                        end
                    end
                end
            end)
        end)
    end

    local function Sync_Skin_Changer()
        if Skin_State.Enabled ~= Cfg.SkinChanger then
            Skin_State.Enabled = Cfg.SkinChanger
            if Cfg.SkinChanger then
                Skin_Initialize()
                task.spawn(function()
                    task.wait(0.5)
                    Skin_Refresh_Slash()
                    Skin_Set_Sword()
                end)
            end
        end
        local Name = tostring(Cfg.SkinName or "")
        if Name ~= "" and Name ~= Skin_State.SwordModel then
            Skin_State.SwordModel = Name
            Skin_State.SwordAnimations = Name
            Skin_State.SwordFX = Name
            Skin_Refresh_Slash()
            if Skin_State.Enabled then Skin_Set_Sword() end
        end
    end

    --// [ SWORD SLASH COLOR ] —  colorable ParryFX -----------------
    local Slash_Config = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Mode = "Solid",
    }
    local Slash_State = {
        Connections = {},
        Reassert = setmetatable({}, { __mode = "k" }),
        RainbowLoop = nil,
    }
    local KNOWN_EFFECT_PATHS = {
        "Impact/Glow2Sided",
        "Impact/flare2",
        "Impact/circles",
        "Impact/fast-burst",
        "Impact/impact",
        "Star",
        "Slash/Effect",
        "Slash/Effect3",
    }

    local function Slash_Get_Color()
        local Color = Slash_Config.Color
        if Slash_Config.Mode == "Rainbow" then
            Color = Color3.fromHSV((os.clock() % 3) / 3, 1, 1)
        elseif Slash_Config.Mode == "Random" then
            Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        end
        return Color
    end

    local function Slash_Apply_Color(Instance_, Color)
        pcall(function()
            if Instance_:IsA("BasePart") then
                Instance_.Color = Color
            elseif Instance_:IsA("Highlight") then
                Instance_.FillColor = Color
                Instance_.OutlineColor = Color
            elseif Instance_:IsA("ParticleEmitter") or Instance_:IsA("Beam") or Instance_:IsA("Trail") then
                Instance_.Color = ColorSequence.new(Color)
            end
        end)
    end

    local function Slash_Color_Object(Part)
        if not Slash_Config.Enabled or not Part or not Part:IsDescendantOf(workspace) then return end
        local Character = LP.Character
        if not Character or not Part:IsDescendantOf(Character) then return end
        local Color = Slash_Get_Color()
        Slash_Apply_Color(Part, Color)
        for _, Path in ipairs(KNOWN_EFFECT_PATHS) do
            local Current = Part
            for Segment in Path:gmatch("[^/]+") do
                Current = Current and Current:FindFirstChild(Segment)
            end
            if Current then Slash_Apply_Color(Current, Color) end
        end
        for _, Descendant in ipairs(Part:GetDescendants()) do
            Slash_Apply_Color(Descendant, Color)
        end
        if Slash_State.Reassert[Part] then return end
        Slash_State.Reassert[Part] = true
        local Start = os.clock()
        local Acc = 0
        local Conn
        Conn = RunService.Heartbeat:Connect(function(Delta)
            if not Part.Parent or (os.clock() - Start) > 0.4 then
                Slash_State.Reassert[Part] = nil
                Conn:Disconnect()
                return
            end
            Acc = Acc + Delta
            if Acc < 0.05 then return end
            Acc = 0
            Slash_Apply_Color(Part, Slash_Get_Color())
        end)
    end

    local function Slash_Start()
        if Slash_Config.Enabled then return end
        Slash_Config.Enabled = true
        for _, Conn in ipairs(Slash_State.Connections) do pcall(function() Conn:Disconnect() end) end
        table.clear(Slash_State.Connections)
        for _, Inst in ipairs(CollectionService:GetTagged("ParryFX")) do
            Slash_Color_Object(Inst)
        end
        table.insert(Slash_State.Connections, CollectionService:GetInstanceAddedSignal("ParryFX"):Connect(Slash_Color_Object))
    end

    local function Slash_Stop()
        Slash_Config.Enabled = false
        for _, Conn in ipairs(Slash_State.Connections) do pcall(function() Conn:Disconnect() end) end
        table.clear(Slash_State.Connections)
        table.clear(Slash_State.Reassert)
        if Slash_State.RainbowLoop then
            Slash_State.RainbowLoop:Disconnect()
            Slash_State.RainbowLoop = nil
        end
    end

    local function Slash_Reapply_All()
        if not Slash_Config.Enabled then return end
        for _, Inst in ipairs(CollectionService:GetTagged("ParryFX")) do
            Slash_Color_Object(Inst)
        end
    end

    local function Sync_Slash_Color()
        Slash_Config.Color = Cfg.SlashColorValue or Slash_Config.Color
        Slash_Config.Mode = Cfg.SlashColorMode or Slash_Config.Mode
        if Cfg.SlashColor then
            Slash_Start()
            local Wants_Loop = (Slash_Config.Mode == "Rainbow" or Slash_Config.Mode == "Random")
            if Wants_Loop and not Slash_State.RainbowLoop then
                Slash_State.RainbowLoop = RunService.RenderStepped:Connect(Slash_Reapply_All)
            elseif not Wants_Loop and Slash_State.RainbowLoop then
                Slash_State.RainbowLoop:Disconnect()
                Slash_State.RainbowLoop = nil
            end
        else
            Slash_Stop()
        end
    end

    --// [ STAFF DETECTION ] --------------------------
    -- Resolves each player's rank in the game's staff group and alerts (or
    -- disconnects) when someone at or above StaffMinRank is in the session.
    -- Ranks are cached per UserId so each visitor costs at most one group
    -- lookup, and the module runs even when Auto Parry is off.
    local DEFAULT_STAFF_GROUP = 12836673
    local DEFAULT_STAFF_RANK  = 10

    local Staff_State = {
        Enabled    = false,
        Scan_Pulse = tonumber(Cfg.StaffScanPulse) or 0,
        Detected   = {},   -- [UserId] = { Name, DisplayName, Rank, Time }
        Rank_Cache = {},   -- [UserId] = rank
    }
    local Staff_Connection = nil

    local function Staff_Group_Id()
        return tonumber(Cfg.StaffGroupId) or DEFAULT_STAFF_GROUP
    end

    local function Staff_Min_Rank()
        return tonumber(Cfg.StaffMinRank) or DEFAULT_STAFF_RANK
    end

    local function Staff_Get_Rank(Player)
        if not Player or not Player:IsA("Player") then return 0 end
        local Cached = Staff_State.Rank_Cache[Player.UserId]
        if Cached ~= nil then return Cached end

        local Ok, Rank = pcall(function()
            return Player:GetRankInGroup(Staff_Group_Id())
        end)
        if Ok and type(Rank) == "number" then
            Staff_State.Rank_Cache[Player.UserId] = Rank
            return Rank
        end
        return 0
    end

    local function Staff_Process_Player(Player)
        if not Player or Player == LP then return end
        local UserId = Player.UserId
        if Staff_State.Detected[UserId] then return end

        task.spawn(function()
            local Rank = Staff_Get_Rank(Player)
            if Rank < Staff_Min_Rank() then return end
            -- Another scan may have reported this player while the group
            -- lookup above was in flight.
            if Staff_State.Detected[UserId] then return end

            Staff_State.Detected[UserId] = {
                Name        = Player.Name,
                DisplayName = Player.DisplayName,
                Rank        = Rank,
                Time        = os.time(),
            }

            if Cfg.StaffActionMode == 'Kick' then
                Log('Error', 'Staff Detection',
                    'Staff member detected: ' .. Player.Name .. ' (Rank ' .. tostring(Rank) .. '). Disconnecting.', 8)
                task.wait(0.2)
                LP:Kick('\n[Ethereal]\nStaff member detected in session: ' .. Player.Name ..
                    '.\nDisconnected to protect account integrity.')
            else
                Log('Warning', 'STAFF DETECTED',
                    'Moderator in server: ' .. Player.Name .. ' (Rank ' .. tostring(Rank) .. '+)', 6)
            end
        end)
    end

    local function Staff_Scan_Count()
        local Count = 0
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LP and Staff_Get_Rank(Player) >= Staff_Min_Rank() then
                Count = Count + 1
            end
        end
        return Count
    end

    local function Staff_Start()
        if Staff_Connection then return end
        -- Connect first so a player joining mid-scan is not missed.
        Staff_Connection = Players.PlayerAdded:Connect(function(Player)
            if Staff_State.Enabled then
                Staff_Process_Player(Player)
            end
        end)
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LP then
                Staff_Process_Player(Player)
            end
        end
    end

    local function Staff_Stop()
        if Staff_Connection then
            Staff_Connection:Disconnect()
            Staff_Connection = nil
        end
        table.clear(Staff_State.Detected)
    end

    local function Sync_Staff()
        local Enabled = Cfg.StaffDetection and true or false
        if Enabled ~= Staff_State.Enabled then
            Staff_State.Enabled = Enabled
            if Enabled then
                Staff_Start()
                Log('Success', 'Staff Detection', 'Staff Detection System Activated', 3)
            else
                Staff_Stop()
                Log('Info', 'Staff Detection', 'Staff Detection System Deactivated', 3)
            end
        end

        local Pulse = tonumber(Cfg.StaffScanPulse) or 0
        if Pulse ~= Staff_State.Scan_Pulse then
            Staff_State.Scan_Pulse = Pulse
            -- The roster audit may hit the group API; keep it off the
            -- heartbeat thread in case the lookup yields.
            task.spawn(function()
                Log('Info', 'Server Audit Complete',
                    'Active Staff Members Identified: ' .. tostring(Staff_Scan_Count()), 3)
            end)
        end
    end

    --// [ FEATURE TICK ] --------------------------------------------------
    local function Feature_Tick()
        xpcall(function()
            Expire_Parry_History()
            Apply_FOV()
            Sync_Avatar()
            Sync_Custom_Win()
            Sync_Winstreak()
            Immortal_Tick()
            Sync_Skin_Changer()
            Sync_Slash_Color()
            Sync_Staff()
            if Cfg.DeviceSpoofPulse and Cfg.DeviceSpoofPulse ~= Device_State.Spoof then
                Device_State.Spoof = Cfg.DeviceSpoofPulse
                Apply_Device_Spoofer(false)
            end
            if Cfg.DeviceSpoofRejoinPulse and Cfg.DeviceSpoofRejoinPulse ~= Device_State.Rejoin then
                Device_State.Rejoin = Cfg.DeviceSpoofRejoinPulse
                Apply_Device_Spoofer(true)
            end
        end, function(Error)
            Log('Error', 'Features', tostring(Error))
        end)
    end

    Setup_Detections()
    RunService.Heartbeat:Connect(Feature_Tick)
    task.spawn(Feature_Tick)

    local _rusoCurveState = {
        lerp_radians = 0,
        last_warping = os.clock(),
        curving = os.clock(),
    }

    local function IsCurvedAdvanced(ball)
        local ok, result = pcall(function()
            if not ball or not ball.Parent then return false end
            local char = LP.Character
            local hrp = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
            if not hrp then return false end
            local zoomies = ball:FindFirstChild("zoomies")
            if not zoomies then return false end
            local velocity = zoomies.VectorVelocity
            if typeof(velocity) ~= "Vector3" then return false end
            local speed = velocity.Magnitude
            if speed < 1 then return false end

            local ballDir = velocity.Unit
            local myPos = hrp.Position
            local ballPos = ball.Position
            local toPlayer = (myPos - ballPos).Unit
            local dot = toPlayer:Dot(ballDir)
            local pingSeconds = (GetPing() or 0) / 1000
            local distance = (myPos - ballPos).Magnitude
            local reachTime = distance / speed - pingSeconds
            local dotThreshold = math.clamp(0.55 - (pingSeconds * 0.75), -1, 0.45)
            local speedThreshold = math.min(speed / 100, 45)
            local distanceThreshold = 15 - math.min(distance / 1000, 15) + speedThreshold

            local radians = math.asin(math.clamp(dot, -1, 1))
            local now = os.clock()
            _rusoCurveState.lerp_radians =
                _rusoCurveState.lerp_radians
                + (radians - _rusoCurveState.lerp_radians) * 0.85

            if _rusoCurveState.lerp_radians < 0.016 then
                _rusoCurveState.last_warping = now
            end
            if distance < (distanceThreshold * 0.85) then return false end
            if (now - _rusoCurveState.last_warping) < (reachTime / 1.4) then return true end
            if (now - _rusoCurveState.curving) < (reachTime / 1.1) then return true end
            return dot < dotThreshold
        end)
        return ok and result == true
    end

    -- Detect a sharp change from moving away/sideways to moving toward us.
    -- This supplements the generic curve detector for back-curve turns.
    local _backCurveHistory = setmetatable({}, { __mode = "k" })
    local function IsBackCurve(ball, velocity, myPos, now)
        if not ball or not ball.Parent or velocity.Magnitude < 1 then return false end

        local toPlayerVector = myPos - ball.Position
        if toPlayerVector.Magnitude < 0.001 then return false end

        local direction = velocity.Unit
        local towardDot = direction:Dot(toPlayerVector.Unit)
        local previous = _backCurveHistory[ball]
        local detected = false

        if previous and (now - previous.time) <= 0.45 then
            local directionChange = previous.direction:Dot(direction)
            detected = previous.towardDot < 0.35
                and towardDot > 0.58
                and directionChange < 0.94
        end

        _backCurveHistory[ball] = {
            direction = direction,
            towardDot = towardDot,
            time = now,
        }

        return detected
    end

    if shared._VisualCDConn then
        shared._VisualCDConn:Disconnect()
        shared._VisualCDConn = nil
    end

    local LastSingularityActiveTime = 0
    local LastFrameTarget = {}
    local _parryConn = nil

    local function StartParryLoop()
        if _parryConn then _parryConn:Disconnect(); _parryConn = nil end

        local loopFn = function(Delta)
            xpcall(function()
                local char = GetChar()
                local hrp  = GetHRP(char)
                local hum  = GetHum(char)
                if not hrp or not hum or hum.Health <= 0 then return end

                -- Training mode: ถ้าไม่อยู่ใน Alive อนุญาต Training ball แต่ lock
                -- triggerbot/detection ไว้ (ไม่มีคู่ต่อสู้ใน training)
                local alive    = workspace:FindFirstChild("Alive")
                local inAlive  = alive and char:IsDescendantOf(alive)

                local balls = GetBalls()   -- อัพเดท BallState ด้วย
                if #balls == 0 then
                    Spam_State.Accumulator = 0
                    Spam_State.Engaged = false
                    return
                end

                local myPos = hrp.Position
                local now   = os.clock()

                -- Spam engine (อยู่ก่อน AutoParry gate เสมอ)
                Spam_Tick(Delta, balls[1])

                if Spam_State.Engaged then Parry_Queue_Clear(); return end   -- Smart Auto Spam owns the ball: Auto Parry off
                if not Cfg.AutoParry then Parry_Queue_Clear(); return end
                if os.clock() < SpamParryPauseUntil then return end

                -- Every ball is evaluated on its own; a parry decision only adds it to the queue.
                local function EvaluateBall(ball)
                    local st = Ball_Parry_State(ball)
                    WatchParryTarget(ball)
                    if st.Parried then return end

                    local target        = tostring(ball:GetAttribute("target") or '')
                    local isTargetingMe = (target == LP.Name)

                    local ballPos = GetBallPos(ball)
                    local vel     = GetBallVel(ball)
                    local speed   = vel.Magnitude
                    local dist    = (myPos - ballPos).Magnitude
                    local ping    = GetPing()

                    -- Training mode: target attribute may be empty (no opponents),
                    -- so treat a close ball as targeting us.
                    if BallState.isTraining and not isTargetingMe then
                        isTargetingMe = (dist < 60)
                    end

                    if Cfg.AntiRepeatMode == 'V2' then
                        local pingSeconds = (ping or 0) / 1000
                        local estimatedReach = speed > 0 and (dist / speed) - pingSeconds or 0
                        local targetKey = tostring(ball:GetAttribute("target") or "")
                        if targetKey ~= st.V2Target then
                            st.V2Target = targetKey
                            st.V2Until = 0
                        end
                        if now < st.V2Until then return end
                        if st.Parried then st.Parried = false end
                        BallState.estimatedReach = estimatedReach
                    end

                    -- Triggerbot: only fire when reaction time is below 0.2s
                    -- and the nearest opponent is within 50 studs.
                    local nearestOpponentDistance = Get_Nearest_OpponentDistance(char)
                    local reactionTime = speed > 0 and (dist / speed) - ((ping or 0) / 1000) or math.huge
                    if inAlive and Cfg.Triggerbot and isTargetingMe
                        and reactionTime < 0.2 and nearestOpponentDistance < 50
                        and not Has_Singularity_Cape() and not st.Parrying
                        and not st.Parried then
                        st.Parried = true
                        st.Id = st.Id + 1
                        local parryId = st.Id
                        st.Parrying = true
                        Parry_Queue_Add(ball, true, false)
                        ball:GetAttributeChangedSignal("target"):Once(function()
                            st.Parrying = false
                            st.Parried = false
                        end)
                        local triggerLock = 1
                        if Cfg.AntiRepeatMode == 'V2' then
                            local estimatedReach = speed > 0 and (dist / speed) - ((ping or 0) / 1000) or 0
                            triggerLock = math.clamp(math.max(estimatedReach, 0.08), 0.08, 1)
                            st.V2Target = tostring(ball:GetAttribute("target") or "")
                            st.V2Until = now + triggerLock
                        end
                        task.delay(triggerLock, function()
                            st.Parrying = false
                            if st.Id == parryId then
                                st.Parried = false
                            end
                        end)
                        return
                    end

                    -- Detection gate (เฉพาะ Alive)
                    if inAlive and Detection_Blocked(ball) then return end

                    -- Singularity cape
                    local isSingularActiveNow = (char:GetAttribute("IS_EVENT_SINGULARITY") == true)
                    if isSingularActiveNow then LastSingularityActiveTime = now end
                    if (now - LastSingularityActiveTime) <= 0.1 then
                        if dist <= 12 and speed <= 8 then return end
                    end

                    local curvedVirex = IsCurvedAdvanced(ball)
                    local backCurve = IsBackCurve(ball, vel, myPos, now)

                    local pingScaled = ping / 10
                    local pingThreshold = math.clamp(pingScaled / 10, 5, 17)
                    local cappedSpeedDiff = math.min(math.max(speed - 9.5, 0), 650)
                    local divisorMultiplier = 0.7 + ((math.clamp(Cfg.Accuracy or 50, 1, 100) - 1) * (0.9 / 99))
                    local speedDivisor = (2.4 + cappedSpeedDiff * 0.002) * divisorMultiplier
                    local zone = pingThreshold + math.max(speed / speedDivisor, 9.5)

                    -- Aerial handling
                    local ballY   = ballPos.Y
                    local velY    = vel.Y
                    local aboveUs = (ballY - myPos.Y) > 5

                    -- Aerial Block: ball is rising AND above us → don't parry (would whiff)
                    if Cfg.AerialBlock and aboveUs and velY > 0 then
                        return
                    end
                    local backCurveLead = math.clamp(speed * 0.16, 7, 20)
                    local trigger = (dist <= zone and not curvedVirex)
                        or (backCurve and dist <= (zone + backCurveLead))

                    -- Tornado delay parry
                    local tornado      = workspace:FindFirstChild("Runtime") and workspace.Runtime:FindFirstChild("Tornado")
                    local tornadoTime  = tornado and (tornado:GetAttribute("TornadoTime") or 1)
                    local isAerodynamic = ball:GetAttribute("AerodynamicTime") or 0

                    if isTargetingMe and inAlive then
                        if LastFrameTarget[ball] == LP.Name and tornado
                            and (now - isAerodynamic) < (tornadoTime + 0.314159) then
                            trigger = false
                            if not st.Parried then
                                st.Parried = true
                                st.Id = st.Id + 1
                                local parryId = st.Id
                                task.delay(0.12, function()
                                    xpcall(function()
                                        if ball and ball.Parent
                                            and tostring(ball:GetAttribute("target") or "") == LP.Name then
                                            FireParry(ball, false)
                                        end
                                        task.delay(0.88, function()
                                            if st.Id == parryId then
                                                st.Parried = false
                                            end
                                        end)
                                    end, function()
                                        if st.Id == parryId then
                                            st.Parried = false
                                        end
                                    end)
                                end)
                            end
                        end
                    end

                    LastFrameTarget[ball] = target

                    -- Allusive-style shared anti-double-parry gate.
                    if trigger and isTargetingMe and not st.Parried then
                        local fst = getgenv().FlyteBB_State
                        if fst then
                            if fst.ParryCooldownUntil and now < fst.ParryCooldownUntil then return end
                            if fst.ExtraParryCooldownUntil and now < fst.ExtraParryCooldownUntil then return end
                            fst.ExtraParryCooldownUntil = nil
                        end

                        -- Set before firing so overlapping callbacks cannot double-fire.
                        st.Parried = true
                        st.Id = st.Id + 1
                        local parryId = st.Id
                        if fst then fst.AutoParryAt = now end

                        Parry_Queue_Add(ball, false, true)   -- the queue processor fires it (ability attempt included)

                        local lockDuration = 1
                        if Cfg.AntiRepeatMode == 'V2' then
                            local pingSeconds = (ping or 0) / 1000
                            local estimatedReach = speed > 0 and (dist / speed) - pingSeconds or 0
                            lockDuration = math.clamp(math.max(estimatedReach, 0.08), 0.08, 1)
                            st.V2Target = tostring(ball:GetAttribute("target") or "")
                            st.V2Until = now + lockDuration
                        end
                        task.delay(lockDuration, function()
                            if st.Id == parryId then
                                st.Parried = false
                            end
                        end)
                    end

                end

                for Index = 1, math.min(#balls, 4) do
                    local ball = balls[Index]
                    if ball and ball.Parent then pcall(EvaluateBall, ball) end
                end
                Parry_Queue_Process()
            end, function(e) end)
        end

        _parryConn = RunService.Heartbeat:Connect(loopFn)
    end

    StartParryLoop()
    
    

    if not sendParry and not _firstSignal and not (_reverted and next(_reverted) ~= nil) then
        Log('Warning', 'Bypass', 'No bypass detected — using the input fallback.')
    end

    --=================================================================
    -- MANUAL SPAM — direct-fire, no range/condition gate
    -- Uses RunService.Heartbeat accumulator driven by CPS (same field
    -- the auto-spam uses) so both modes share one config slider.
    -- Independent of the auto-spam condition checks — fires as long as
    -- the floating toggle is ON, nothing else required.
    --=================================================================
    local ManualSpam_State = {
        Active      = false,  -- controlled only by floating toggle (open/close)
        Accumulator = 0,
        -- rolling FPS estimate from Heartbeat deltas, no yielding
        FPS_Acc     = 0,
        FPS_Frames  = 0,
        FPS_Est     = 60,
        FPS_Clock   = 0,
    }

    local function ManualSpam_Tick(Delta)
        -- pure open/close gate — no range, no conditions, nothing else
        if not ManualSpam_State.Active then
            ManualSpam_State.Accumulator = 0
            return
        end

        -- rolling FPS estimate: average delta over 0.5s windows, no yield
        ManualSpam_State.FPS_Acc    = ManualSpam_State.FPS_Acc + Delta
        ManualSpam_State.FPS_Frames = ManualSpam_State.FPS_Frames + 1
        local now = os.clock()
        if (now - ManualSpam_State.FPS_Clock) >= 0.5 then
            if ManualSpam_State.FPS_Acc > 0 then
                ManualSpam_State.FPS_Est = ManualSpam_State.FPS_Frames / ManualSpam_State.FPS_Acc
            end
            ManualSpam_State.FPS_Acc    = 0
            ManualSpam_State.FPS_Frames = 0
            ManualSpam_State.FPS_Clock  = now
        end

        local CPS = tonumber(Cfg.CPS) or 60
        if CPS <= 0 then return end

        -- burst cap scales with FPS so one slow frame doesn't dump 20 remotes at once
        -- and fast ball speed earns +1–2 extra shots
        local ball = GetBall()
        local ballSpeed = ball and GetBallVel(ball).Magnitude or 0
        local fpsCap    = math.clamp(ManualSpam_State.FPS_Est / 10, 1, 8)
        local speedBonus = math.clamp(ballSpeed / 90, 8, 15)
        local burstCap  = math.max(1, math.floor(fpsCap + speedBonus))

        ManualSpam_State.Accumulator = ManualSpam_State.Accumulator + Delta
        local Shots = math.floor(ManualSpam_State.Accumulator * CPS)
        if Shots <= 0 then return end
        ManualSpam_State.Accumulator = ManualSpam_State.Accumulator - (Shots / CPS)
        if ManualSpam_State.Accumulator < 0 then ManualSpam_State.Accumulator = 0 end
        if Shots > burstCap then Shots = burstCap end
        MarkSpamParryPause(Delta)

        for _ = 1, Shots do
            pcall(FireParry, ball, true)
            Record_Parry()
        end
    end

    -- build the floating switch GUI and wire V-key to toggle
    local function BuildFloatingSwitch()
        local TweenService     = game:GetService('TweenService')
        local UserInputService = game:GetService('UserInputService')
        local CoreGui          = game:GetService('CoreGui')

        if CoreGui:FindFirstChild('StellarFloatingToggle') then
            CoreGui.StellarFloatingToggle:Destroy()
        end

        local Style = Cfg.ManualSpamStyle or 'Default'
        -- Default    = rectangle card, full label (original look)
        -- Rectangle  = wider flat pill, label centred, cyan accent
        -- Square     = square badge, label hidden, corner radius small
        -- Circle     = circular badge, label hidden, full radius

        local FloatCfg = {
            Title         = 'SPAM',
            Keybind       = Cfg.ManualSpamKey or Enum.KeyCode.V,
            StartPosition = UDim2.new(1, -190, 1, -168),
            ColorOff      = Color3.fromRGB(40, 40, 46),
            ColorOn       = Color3.fromRGB(48, 224, 158),
            KnobColor     = Color3.fromRGB(248, 248, 252),
        }

        if Style == 'Rectangle' then
            FloatCfg.ColorOn = Color3.fromRGB(80, 200, 255)
        elseif Style == 'Square' then
            FloatCfg.ColorOn = Color3.fromRGB(220, 90, 255)
            FloatCfg.Title   = ''
        elseif Style == 'Circle' then
            FloatCfg.ColorOn = Color3.fromRGB(255, 160, 60)
            FloatCfg.Title   = ''
        end

        local IsOn = false

        local screenGui = Instance.new('ScreenGui')
        screenGui.Name = 'StellarFloatingToggle'
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Enabled = Cfg.ManualSpam
        screenGui.Parent = CoreGui

        -- Style sizing:
        -- Default    168x114  card r16  — original rectangle card, track + status row
        -- Rectangle  180x60   card r10  — wide flat pill, only track
        -- Square     80x80    card r12  — square badge, only track + colour dot
        -- Circle     80x80    card r40  — full circle, only colour indicator
        local rootW  = (Style == 'Circle' or Style == 'Square') and 80
                    or (Style == 'Rectangle') and 180
                    or 168
        local rootH  = (Style == 'Circle' or Style == 'Square') and 80
                    or (Style == 'Rectangle') and 60
                    or 114
        local cardW  = rootW - 18
        local cardH  = rootH - 18
        local radius = (Style == 'Circle') and 40
                    or (Style == 'Square')  and 12
                    or (Style == 'Rectangle') and 10
                    or 16

        local root = Instance.new('CanvasGroup')
        root.Name = 'Root'
        root.Size = UDim2.fromOffset(rootW, rootH)
        root.Position = FloatCfg.StartPosition
        root.BackgroundTransparency = 1
        root.GroupTransparency = 1
        root.Parent = screenGui

        local rootScale = Instance.new('UIScale')
        rootScale.Scale = 0.75
        rootScale.Parent = root

        local shadow = Instance.new('Frame')
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
        shadow.Size = UDim2.fromOffset(cardW + 4, cardH + 4)
        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadow.BackgroundTransparency = 0.5
        shadow.BorderSizePixel = 0
        shadow.ZIndex = 0
        shadow.Parent = root
        Instance.new('UICorner', shadow).CornerRadius = UDim.new(0, radius + 2)

        local card = Instance.new('Frame')
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.new(0.5, 0, 0.5, 0)
        card.Size = UDim2.fromOffset(cardW, cardH)
        card.BackgroundColor3 = (Style == 'New2') and Color3.fromRGB(18, 18, 22) or Color3.fromRGB(24, 24, 29)
        card.BackgroundTransparency = 0.05
        card.BorderSizePixel = 0
        card.ZIndex = 1
        card.Parent = root
        Instance.new('UICorner', card).CornerRadius = UDim.new(0, radius)
        local cardStroke = Instance.new('UIStroke')
        cardStroke.Color = (Style ~= 'Classic') and FloatCfg.ColorOn or Color3.fromRGB(255, 255, 255)
        cardStroke.Transparency = (Style ~= 'Classic') and 0.6 or 0.91
        cardStroke.Thickness = 1
        cardStroke.Parent = card
        local cg = Instance.new('UIGradient')
        cg.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 40)), ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20)) })
        cg.Rotation = 60
        cg.Parent = card

        local title = Instance.new('TextLabel')
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -16, 0, 16)
        title.Position = UDim2.new(0, 8, 0, (Style == 'New2') and 4 or 8)
        title.Font = Enum.Font.GothamBold
        title.Text = FloatCfg.Title
        title.TextSize = (Style == 'New2') and 10 or 12
        title.TextColor3 = (Style == 'Classic') and Color3.fromRGB(195, 195, 205) or FloatCfg.ColorOn
        title.TextTransparency = (Style == 'New2') and 0.3 or 0.1
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.TextScaled = true
        title.ZIndex = 2
        title.Parent = card
        local tc2 = Instance.new('UITextSizeConstraint', title)
        tc2.MaxTextSize = (Style == 'New2') and 10 or 12; tc2.MinTextSize = 8

        -- Track/knob layout per style
        local trackY  = (Style == 'Circle' or Style == 'Square') and (cardH // 2 + 2)
                     or (Style == 'Rectangle') and (cardH // 2 + 2)
                     or 46
        local trackW  = (Style == 'Circle' or Style == 'Square') and 44
                     or (Style == 'Rectangle') and 60
                     or 72
        local trackH  = (Style == 'Circle' or Style == 'Square') and 24
                     or (Style == 'Rectangle') and 26
                     or 34
        local knobSz  = (Style == 'Circle' or Style == 'Square') and 18
                     or (Style == 'Rectangle') and 20
                     or 28
        local statusY = 70  -- only used by Default; hidden otherwise

        local glowOuter = Instance.new('Frame')
        glowOuter.AnchorPoint = Vector2.new(0.5, 0.5)
        glowOuter.Position = UDim2.new(0.5, 0, 0, trackY)
        glowOuter.Size = UDim2.fromOffset(trackW + 32, trackH + 30)
        glowOuter.BackgroundColor3 = FloatCfg.ColorOn
        glowOuter.BackgroundTransparency = 1
        glowOuter.BorderSizePixel = 0
        glowOuter.ZIndex = 1
        glowOuter.Parent = card
        Instance.new('UICorner', glowOuter).CornerRadius = UDim.new(1, 0)

        local glowInner = Instance.new('Frame')
        glowInner.AnchorPoint = Vector2.new(0.5, 0.5)
        glowInner.Position = UDim2.new(0.5, 0, 0, trackY)
        glowInner.Size = UDim2.fromOffset(trackW + 12, trackH + 14)
        glowInner.BackgroundColor3 = FloatCfg.ColorOn
        glowInner.BackgroundTransparency = 1
        glowInner.BorderSizePixel = 0
        glowInner.ZIndex = 1
        glowInner.Parent = card
        Instance.new('UICorner', glowInner).CornerRadius = UDim.new(1, 0)

        local track = Instance.new('Frame')
        track.Name = 'Track'
        track.Active = true
        track.AnchorPoint = Vector2.new(0.5, 0.5)
        track.Position = UDim2.new(0.5, 0, 0, trackY)
        track.Size = UDim2.fromOffset(trackW, trackH)
        track.BackgroundColor3 = FloatCfg.ColorOff
        track.BorderSizePixel = 0
        track.ZIndex = 2
        track.Parent = card
        Instance.new('UICorner', track).CornerRadius = UDim.new(1, 0)
        local trkStroke = Instance.new('UIStroke')
        trkStroke.Color = Color3.fromRGB(64, 64, 72)
        trkStroke.Thickness = 1.5
        trkStroke.Transparency = 0.2
        trkStroke.Parent = track
        local trkGrad = Instance.new('UIGradient')
        trkGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        trkGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(0.5, 0.94), NumberSequenceKeypoint.new(1, 1) })
        trkGrad.Rotation = 90
        trkGrad.Parent = track

        local knob = Instance.new('Frame')
        knob.Name = 'Knob'
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.Position = UDim2.new(0, 3, 0.5, 0)
        knob.Size = UDim2.fromOffset(knobSz, knobSz)
        knob.BackgroundColor3 = FloatCfg.KnobColor
        knob.BorderSizePixel = 0
        knob.ZIndex = 3
        knob.Parent = track
        Instance.new('UICorner', knob).CornerRadius = UDim.new(1, 0)
        local knobStroke = Instance.new('UIStroke')
        knobStroke.Color = Color3.fromRGB(224, 224, 230)
        knobStroke.Thickness = 1
        knobStroke.Transparency = 0.5
        knobStroke.Parent = knob

        local statusRow = Instance.new('Frame')
        statusRow.AnchorPoint = Vector2.new(0.5, 0)
        statusRow.Position = UDim2.new(0.5, 0, 0, statusY)
        statusRow.Size = UDim2.new(1, -16, 0, 20)
        statusRow.Visible = (Style == 'Default')
        statusRow.BackgroundTransparency = 1
        statusRow.ZIndex = 2
        statusRow.Parent = card
        local sLayout = Instance.new('UIListLayout', statusRow)
        sLayout.FillDirection = Enum.FillDirection.Horizontal
        sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        sLayout.Padding = UDim.new(0, 6)
        sLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local dot = Instance.new('Frame')
        dot.Size = UDim2.fromOffset(8, 8)
        dot.BackgroundColor3 = FloatCfg.ColorOff
        dot.BorderSizePixel = 0
        dot.LayoutOrder = 1
        dot.ZIndex = 2
        dot.Parent = statusRow
        Instance.new('UICorner', dot).CornerRadius = UDim.new(1, 0)

        local statusText = Instance.new('TextLabel')
        statusText.BackgroundTransparency = 1
        statusText.Size = UDim2.fromOffset(28, 16)
        statusText.Font = Enum.Font.GothamBold
        statusText.Text = 'OFF'
        statusText.TextSize = 12
        statusText.TextColor3 = Color3.fromRGB(150, 150, 160)
        statusText.TextXAlignment = Enum.TextXAlignment.Left
        statusText.LayoutOrder = 2
        statusText.ZIndex = 2
        statusText.Parent = statusRow

        local keyTag = Instance.new('TextLabel')
        keyTag.AutomaticSize = Enum.AutomaticSize.X
        keyTag.Size = UDim2.fromOffset(0, 18)
        keyTag.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        keyTag.Font = Enum.Font.GothamBold
        keyTag.Text = FloatCfg.Keybind.Name
        keyTag.TextSize = 11
        keyTag.TextColor3 = Color3.fromRGB(205, 205, 215)
        keyTag.LayoutOrder = 3
        keyTag.ZIndex = 2
        keyTag.Parent = statusRow
        Instance.new('UICorner', keyTag).CornerRadius = UDim.new(0, 5)
        local ktStroke = Instance.new('UIStroke', keyTag)
        ktStroke.Color = Color3.fromRGB(68, 68, 76); ktStroke.Thickness = 1
        local ktPad = Instance.new('UIPadding', keyTag)
        ktPad.PaddingLeft = UDim.new(0, 7); ktPad.PaddingRight = UDim.new(0, 7)

        -- Keybind change button — small pill below the track (Default style only)
        local keybindBtn = nil
        if Style == 'Default' then
            keybindBtn = Instance.new('TextButton')
            keybindBtn.Size               = UDim2.new(1, -16, 0, 14)
            keybindBtn.Position           = UDim2.new(0, 8, 0, statusY + 20)
            keybindBtn.BackgroundColor3   = Color3.fromRGB(28, 28, 34)
            keybindBtn.BackgroundTransparency = 0.3
            keybindBtn.TextColor3         = Color3.fromRGB(160, 160, 175)
            keybindBtn.Font               = Enum.Font.Gotham
            keybindBtn.TextSize           = 9
            keybindBtn.Text               = '⌨ Change Key'
            keybindBtn.BorderSizePixel    = 0
            keybindBtn.ZIndex             = 3
            keybindBtn.Parent             = card
            Instance.new('UICorner', keybindBtn).CornerRadius = UDim.new(0, 4)
        end

        -- ================================================================
        -- KEYBIND POPUP
        -- Draggable frame, style matches the main floating switch.
        -- Flow: open → press ~ to enter listen mode → press any key → Enter to save
        -- ================================================================
        local _kbPopup     = nil   -- current popup ScreenGui
        local _kbListening = false
        local _kbPending   = nil   -- KeyCode waiting for confirm
        local _kbCapConn   = nil   -- key capture connection (declared here so all closures share it)

        local function DestroyKeybindPopup()
            if _kbCapConn then _kbCapConn:Disconnect(); _kbCapConn = nil end
            if _kbPopup then
                _kbPopup:Destroy()
                _kbPopup     = nil
                _kbListening = false
                _kbPending   = nil
            end
        end

        local function OpenKeybindPopup()
            DestroyKeybindPopup()

            local sg = Instance.new('ScreenGui')
            sg.Name           = 'EtherealKeybindPopup'
            sg.ResetOnSpawn   = false
            sg.IgnoreGuiInset = true
            sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sg.Parent         = CoreGui
            _kbPopup          = sg

            -- Backdrop (semi-transparent overlay so user focuses the popup)
            local overlay = Instance.new('Frame')
            overlay.Size                 = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
            overlay.BackgroundTransparency = 0.55
            overlay.BorderSizePixel      = 0
            overlay.ZIndex               = 10
            overlay.Parent               = sg

            -- Main frame
            local frame = Instance.new('Frame')
            frame.Size               = UDim2.fromOffset(260, 158)
            frame.Position           = UDim2.new(0.5, -130, 0.5, -79)
            frame.BackgroundColor3   = Color3.fromRGB(18, 18, 24)
            frame.BackgroundTransparency = 0.05
            frame.BorderSizePixel    = 0
            frame.ZIndex             = 11
            frame.Active             = true
            frame.Parent             = sg
            Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 14)
            local fStroke = Instance.new('UIStroke', frame)
            fStroke.Color       = Color3.fromRGB(255, 255, 255)
            fStroke.Transparency = 0.88
            fStroke.Thickness    = 1

            -- Title row
            local titleLbl = Instance.new('TextLabel')
            titleLbl.Size                = UDim2.new(1, -44, 0, 28)
            titleLbl.Position            = UDim2.new(0, 14, 0, 10)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font                = Enum.Font.GothamBold
            titleLbl.Text                = 'Keybind Setting'
            titleLbl.TextSize            = 13
            titleLbl.TextColor3          = Color3.fromRGB(220, 220, 230)
            titleLbl.TextXAlignment      = Enum.TextXAlignment.Left
            titleLbl.ZIndex              = 12
            titleLbl.Parent              = frame

            -- Close button (top-right ×)
            local closeBtn = Instance.new('TextButton')
            closeBtn.Size              = UDim2.fromOffset(26, 26)
            closeBtn.Position          = UDim2.new(1, -34, 0, 7)
            closeBtn.BackgroundColor3  = Color3.fromRGB(48, 48, 56)
            closeBtn.BackgroundTransparency = 0.3
            closeBtn.Font              = Enum.Font.GothamBold
            closeBtn.Text              = '×'
            closeBtn.TextSize          = 16
            closeBtn.TextColor3        = Color3.fromRGB(200, 200, 210)
            closeBtn.BorderSizePixel   = 0
            closeBtn.ZIndex            = 12
            closeBtn.Parent            = frame
            Instance.new('UICorner', closeBtn).CornerRadius = UDim.new(0, 7)
            closeBtn.MouseButton1Click:Connect(DestroyKeybindPopup)

            -- Divider line
            local divLine = Instance.new('Frame')
            divLine.Size             = UDim2.new(1, -28, 0, 1)
            divLine.Position         = UDim2.new(0, 14, 0, 40)
            divLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            divLine.BackgroundTransparency = 0.9
            divLine.BorderSizePixel  = 0
            divLine.ZIndex           = 12
            divLine.Parent           = frame

            -- Current key display
            local curKeyLbl = Instance.new('TextLabel')
            curKeyLbl.Size                = UDim2.new(1, -28, 0, 20)
            curKeyLbl.Position            = UDim2.new(0, 14, 0, 48)
            curKeyLbl.BackgroundTransparency = 1
            curKeyLbl.Font                = Enum.Font.Gotham
            curKeyLbl.TextSize            = 11
            curKeyLbl.TextColor3          = Color3.fromRGB(140, 140, 155)
            curKeyLbl.TextXAlignment      = Enum.TextXAlignment.Left
            curKeyLbl.ZIndex              = 12
            curKeyLbl.Parent              = frame
            curKeyLbl.Text                = 'Current key:  ' .. FloatCfg.Keybind.Name

            -- ~ button + pending key display row
            local listenRow = Instance.new('Frame')
            listenRow.Size               = UDim2.new(1, -28, 0, 32)
            listenRow.Position           = UDim2.new(0, 14, 0, 72)
            listenRow.BackgroundTransparency = 1
            listenRow.ZIndex             = 12
            listenRow.Parent             = frame

            local tildeBtn = Instance.new('TextButton')
            tildeBtn.Size             = UDim2.fromOffset(32, 32)
            tildeBtn.Position         = UDim2.fromOffset(0, 0)
            tildeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            tildeBtn.Font             = Enum.Font.GothamBold
            tildeBtn.Text             = '~'
            tildeBtn.TextSize         = 15
            tildeBtn.TextColor3       = Color3.fromRGB(180, 180, 200)
            tildeBtn.BorderSizePixel  = 0
            tildeBtn.ZIndex           = 13
            tildeBtn.Parent           = listenRow
            Instance.new('UICorner', tildeBtn).CornerRadius = UDim.new(0, 8)
            local tildeStroke = Instance.new('UIStroke', tildeBtn)
            tildeStroke.Color = Color3.fromRGB(100, 100, 120); tildeStroke.Thickness = 1

            local pendingLbl = Instance.new('TextLabel')
            pendingLbl.Size               = UDim2.new(1, -44, 1, 0)
            pendingLbl.Position           = UDim2.fromOffset(44, 0)
            pendingLbl.BackgroundTransparency = 1
            pendingLbl.Font               = Enum.Font.GothamBold
            pendingLbl.TextSize           = 11
            pendingLbl.TextColor3         = Color3.fromRGB(160, 160, 180)
            pendingLbl.TextXAlignment     = Enum.TextXAlignment.Left
            pendingLbl.ZIndex             = 12
            pendingLbl.Parent             = listenRow
            pendingLbl.Text               = 'Click "~" then press any key'

            -- Help line
            local helpLbl = Instance.new('TextLabel')
            helpLbl.Size               = UDim2.new(1, -28, 0, 14)
            helpLbl.Position           = UDim2.new(0, 14, 0, 110)
            helpLbl.BackgroundTransparency = 1
            helpLbl.Font               = Enum.Font.Gotham
            helpLbl.TextSize           = 9
            helpLbl.TextColor3         = Color3.fromRGB(100, 100, 115)
            helpLbl.TextXAlignment     = Enum.TextXAlignment.Left
            helpLbl.ZIndex             = 12
            helpLbl.Parent             = frame
            helpLbl.Text               = "Don't forget to click \"Enter\" to save"

            -- Enter button
            local enterBtn = Instance.new('TextButton')
            enterBtn.Size             = UDim2.fromOffset(72, 26)
            enterBtn.Position         = UDim2.new(1, -86, 1, -34)
            enterBtn.BackgroundColor3 = Color3.fromRGB(48, 224, 158)
            enterBtn.Font             = Enum.Font.GothamBold
            enterBtn.Text             = 'Enter'
            enterBtn.TextSize         = 12
            enterBtn.TextColor3       = Color3.fromRGB(14, 14, 18)
            enterBtn.BorderSizePixel  = 0
            enterBtn.ZIndex           = 12
            enterBtn.Parent           = frame
            Instance.new('UICorner', enterBtn).CornerRadius = UDim.new(0, 8)
            -- disabled look until a key is pending
            enterBtn.BackgroundTransparency = 0.5

            -- ── DRAG ──────────────────────────────────────────────────
            local kbDragging, kbDragStart, kbFrameStart = false, Vector2.zero, Vector2.zero
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    kbDragging   = true
                    kbDragStart  = Vector2.new(input.Position.X, input.Position.Y)
                    kbFrameStart = frame.AbsolutePosition
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if kbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = Vector2.new(input.Position.X, input.Position.Y) - kbDragStart
                    local cam   = workspace.CurrentCamera
                    local vp    = cam and cam.ViewportSize or Vector2.new(1920,1080)
                    local sz    = frame.AbsoluteSize
                    local nx    = math.clamp(kbFrameStart.X + delta.X, 0, vp.X - sz.X)
                    local ny    = math.clamp(kbFrameStart.Y + delta.Y, 0, vp.Y - sz.Y)
                    frame.Position = UDim2.fromOffset(nx, ny)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    kbDragging = false
                end
            end)

            -- ── ~ BUTTON — enter listen mode ──────────────────────────
            tildeBtn.MouseButton1Click:Connect(function()
                _kbListening = true
                _kbPending   = nil
                TweenService:Create(tildeBtn, TweenInfo.new(0.1),
                    { BackgroundColor3 = Color3.fromRGB(48, 224, 158) }):Play()
                TweenService:Create(tildeBtn, TweenInfo.new(0.08),
                    { TextColor3 = Color3.fromRGB(14, 14, 18) }):Play()
                pendingLbl.Text      = 'Listening… press any key'
                pendingLbl.TextColor3 = Color3.fromRGB(48, 224, 158)
                enterBtn.BackgroundTransparency = 0.5
            end)

            -- ── KEY CAPTURE ───────────────────────────────────────────
            _kbCapConn = UserInputService.InputBegan:Connect(function(input, gp)
                if not _kbListening then return end
                if gp then return end
                local kc = input.KeyCode
                -- skip mouse buttons, unknown, and modifier-only keys
                if kc == Enum.KeyCode.Unknown then return end
                if kc == Enum.KeyCode.LeftShift or kc == Enum.KeyCode.RightShift   then return end
                if kc == Enum.KeyCode.LeftControl or kc == Enum.KeyCode.RightControl then return end
                if kc == Enum.KeyCode.LeftAlt or kc == Enum.KeyCode.RightAlt       then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

                _kbListening  = false
                _kbPending    = kc
                pendingLbl.Text      = 'New key:  ' .. kc.Name
                pendingLbl.TextColor3 = Color3.fromRGB(220, 220, 100)
                TweenService:Create(tildeBtn, TweenInfo.new(0.15),
                    { BackgroundColor3 = Color3.fromRGB(40, 40, 50) }):Play()
                TweenService:Create(tildeBtn, TweenInfo.new(0.15),
                    { TextColor3 = Color3.fromRGB(180, 180, 200) }):Play()
                -- enable Enter button
                TweenService:Create(enterBtn, TweenInfo.new(0.1),
                    { BackgroundTransparency = 0 }):Play()
            end)

            -- ── ENTER — save ──────────────────────────────────────────
            enterBtn.MouseButton1Click:Connect(function()
                if not _kbPending then return end

                -- save to Cfg, update keyTag, then rebuild so InputBegan uses new key
                Cfg.ManualSpamKey = _kbPending
                FloatCfg.Keybind  = _kbPending
                if keyTag then keyTag.Text = _kbPending.Name end

                DestroyKeybindPopup()  -- also disconnects _kbCapConn

                local CG = game:GetService('CoreGui')
                local sg2 = CG:FindFirstChild('StellarFloatingToggle')
                if sg2 then sg2:Destroy() end
                if Cfg.ManualSpam and typeof(Cfg.__BuildFloatingSwitch) == 'function' then
                    Cfg.__BuildFloatingSwitch()
                end
            end)
        end

        -- Expose for Main tab button
        Cfg.__OpenKeybindPopup = OpenKeybindPopup

        -- Wire the keybind button (Default style) and long-press on other styles
        if keybindBtn then
            keybindBtn.MouseButton1Click:Connect(OpenKeybindPopup)
        end

        -- Long-press on the card background (non-Default styles) opens keybind popup
        if Style ~= 'Default' then
            local _longPressConn, _longPressTask
            card.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    _longPressTask = task.delay(0.6, OpenKeybindPopup)
                end
            end)
            card.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    if _longPressTask then
                        task.cancel(_longPressTask)
                        _longPressTask = nil
                    end
                end
            end)
        end

        local knobTravel = trackW - knobSz - 3
        local function applyVisualState(on, animated)
            local q  = TweenInfo.new(animated and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local qk = TweenInfo.new(animated and 0.28 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            local kp = on and UDim2.new(0, knobTravel, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            TweenService:Create(track, q, { BackgroundColor3 = on and FloatCfg.ColorOn or FloatCfg.ColorOff }):Play()
            TweenService:Create(trkStroke, q, { Color = on and FloatCfg.ColorOn or Color3.fromRGB(64, 64, 72) }):Play()
            TweenService:Create(knob, qk, { Position = kp }):Play()
            TweenService:Create(dot, q, { BackgroundColor3 = on and FloatCfg.ColorOn or Color3.fromRGB(90, 90, 98) }):Play()
            TweenService:Create(statusText, q, { TextColor3 = on and FloatCfg.ColorOn or Color3.fromRGB(150, 150, 160) }):Play()
            TweenService:Create(glowOuter, q, { BackgroundTransparency = on and 0.82 or 1 }):Play()
            TweenService:Create(glowInner, q, { BackgroundTransparency = on and 0.7 or 1 }):Play()
            statusText.Text = on and 'ON' or 'OFF'
        end

        local function toggleState()
            IsOn = not IsOn
            ManualSpam_State.Active = IsOn
            ManualSpam_State.Accumulator = 0
            applyVisualState(IsOn, true)
        end

        applyVisualState(false, false)

        -- drag logic
        local dragging, moved = false, false
        local dragStart, startPos = Vector2.zero, Vector2.zero
        local DRAG_TOL = 4

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; moved = false
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
                startPos = root.AbsolutePosition
                TweenService:Create(track, TweenInfo.new(0.12), { Size = UDim2.fromOffset(76, 36) }):Play()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pt = Vector2.new(input.Position.X, input.Position.Y)
                local delta = pt - dragStart
                if delta.Magnitude > DRAG_TOL then moved = true end
                local cam = workspace.CurrentCamera
                local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
                local sz = root.AbsoluteSize
                local x = math.clamp(startPos.X + delta.X, 0, math.max(vp.X - sz.X, 0))
                local y = math.clamp(startPos.Y + delta.Y, 0, math.max(vp.Y - sz.Y, 0))
                root.Position = UDim2.fromOffset(x, y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    TweenService:Create(track, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(72, 34) }):Play()
                    if not moved then toggleState() end
                end
            end
        end)
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == FloatCfg.Keybind then
                toggleState()
                local resting = keyTag.BackgroundColor3
                TweenService:Create(keyTag, TweenInfo.new(0.06), { BackgroundColor3 = FloatCfg.ColorOn }):Play()
                task.delay(0.15, function()
                    TweenService:Create(keyTag, TweenInfo.new(0.25), { BackgroundColor3 = resting }):Play()
                end)
            end
        end)

        TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
        TweenService:Create(rootScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end

    -- expose builder to menu
    Cfg.__BuildFloatingSwitch = BuildFloatingSwitch
    if Cfg.ManualSpam then BuildFloatingSwitch() end

    -- hook ManualSpam_Tick into the existing heartbeat
    local _manualSpamConn = RunService.Heartbeat:Connect(function(Delta)
        ManualSpam_Tick(Delta)
    end)

    --=================================================================
    -- PLAYER MOVEMENT SYSTEMS (merged from normal.txt)
    --=================================================================
     local UIS_Mov = cloneref(game:GetService('UserInputService'))

     local function GetMovChar() return LP.Character end
     local function GetMovHRP(c) return c and (c.PrimaryPart or c:FindFirstChild('HumanoidRootPart')) end
     local function GetMovHum(c) return c and c:FindFirstChildOfClass('Humanoid') end

    -- 1. WALKSPEED
    task.spawn(function()
        while true do
            task.wait(0.2)
            if Cfg.SpeedEnabled then
                local hum = GetMovHum(GetMovChar())
                if hum and hum.WalkSpeed ~= Cfg.SpeedValue then
                    pcall(function() hum.WalkSpeed = Cfg.SpeedValue end)
                end
            end
        end
    end)

    -- 2. JUMP POWER
    task.spawn(function()
        while true do
            task.wait(0.2)
            if Cfg.JumpEnabled then
                local hum = GetMovHum(GetMovChar())
                if hum then
                    pcall(function()
                        hum.UseJumpPower = true
                        if hum.JumpPower ~= Cfg.JumpValue then
                            hum.JumpPower = Cfg.JumpValue
                        end
                    end)
                end
            end
        end
    end)

    -- 3. FLY SYSTEM
    local _flyConn_Mov, _flyBV_Mov, _flyGyro_Mov = nil, nil, nil

     local function StopFly_Mov()
        if _flyConn_Mov then _flyConn_Mov:Disconnect(); _flyConn_Mov = nil end
        pcall(function() if _flyBV_Mov   then _flyBV_Mov:Destroy()   end end); _flyBV_Mov   = nil
        pcall(function() if _flyGyro_Mov then _flyGyro_Mov:Destroy() end end); _flyGyro_Mov = nil
        local hum = GetMovHum(GetMovChar())
        if hum then pcall(function() hum.PlatformStand = false end) end
    end

     local function StartFly_Mov()
        local char = GetMovChar()
        local hrp  = GetMovHRP(char)
        local hum  = GetMovHum(char)
        if not hrp or not hum then return end
        StopFly_Mov()
        pcall(function() hum.PlatformStand = true end)

        _flyBV_Mov = Instance.new('BodyVelocity')
        _flyBV_Mov.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        _flyBV_Mov.Velocity  = Vector3.zero
        _flyBV_Mov.Parent    = hrp

        _flyGyro_Mov = Instance.new('BodyGyro')
        _flyGyro_Mov.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        _flyGyro_Mov.P         = 9e4
        _flyGyro_Mov.Parent    = hrp

        _flyConn_Mov = RunService.RenderStepped:Connect(function()
            if not Cfg.FlyEnabled or not hrp or not _flyBV_Mov or not _flyGyro_Mov then
                StopFly_Mov(); return
            end
            pcall(function() hum.PlatformStand = true end)
            local cam = workspace.CurrentCamera
            if not cam then return end
            _flyGyro_Mov.CFrame = cam.CFrame

            local mv = hum.MoveDirection
            if mv.Magnitude == 0 then
                if UIS_Mov:IsKeyDown(Enum.KeyCode.W) then mv = mv + Vector3.new(0,0,-1) end
                if UIS_Mov:IsKeyDown(Enum.KeyCode.S) then mv = mv + Vector3.new(0,0, 1) end
                if UIS_Mov:IsKeyDown(Enum.KeyCode.A) then mv = mv + Vector3.new(-1,0,0) end
                if UIS_Mov:IsKeyDown(Enum.KeyCode.D) then mv = mv + Vector3.new( 1,0,0) end
            end
            local sp  = Cfg.FlySpeed or 50
            local dir = cam.CFrame:VectorToWorldSpace(mv)
            local vy  = 0
            if UIS_Mov:IsKeyDown(Enum.KeyCode.Space)      then vy =  sp end
            if UIS_Mov:IsKeyDown(Enum.KeyCode.LeftControl) then vy = -sp end
            _flyBV_Mov.Velocity = (dir * sp) + Vector3.new(0, vy, 0)
        end)
    end

     local _flyWasEnabled = false
    RunService.Heartbeat:Connect(function()
        xpcall(function()
            if Cfg.FlyEnabled ~= _flyWasEnabled then
                _flyWasEnabled = Cfg.FlyEnabled
                if Cfg.FlyEnabled then StartFly_Mov() else StopFly_Mov() end
            end
        end, function() end)
    end)

    LP.CharacterAdded:Connect(function()
        task.wait(0.8)
        if Cfg.FlyEnabled then StartFly_Mov() end
    end)

    -- 4. AUTO JUMP / AUTO PLAY — random world-space movement, independent of camera.
    local _autoJumpArmed = true
    local _autoJumpSawAir = false
    task.spawn(function()
        while true do
            task.wait(0.08)
            local enabled = Cfg.AutoJumpEnabled or Cfg.AutoPlayEnabled
            if not enabled then
                _autoJumpArmed = true
                _autoJumpSawAir = false
                continue
            end
            local char = GetMovChar()
            local hum = GetMovHum(char)
            if not hum or hum.Health <= 0 then continue end
            local state = hum:GetState()
            local grounded = hum.FloorMaterial ~= Enum.Material.Air
                and state ~= Enum.HumanoidStateType.Freefall
                and state ~= Enum.HumanoidStateType.Jumping
            if not grounded then
                _autoJumpSawAir = true
                _autoJumpArmed = false
            elseif _autoJumpArmed or _autoJumpSawAir then
                _autoJumpArmed = false
                _autoJumpSawAir = false
                hum.Jump = true
            end
        end
    end)

    local _autoPlayDirection = Vector3.zero
    local _autoPlayMoveUntil = 0
    local _autoPlayNextTurn = 0
    local _autoPlayTargetYaw = nil
    local _autoPlayTargetPitch = nil

    task.spawn(function()
        while true do
            task.wait(0.1)
            if not Cfg.AutoPlayEnabled then
                _autoPlayDirection = Vector3.zero
                _autoPlayTargetYaw = nil
                _autoPlayTargetPitch = nil
                continue
            end

            local now = os.clock()
            if now >= _autoPlayMoveUntil then
                if math.random() < 0.12 then
                    _autoPlayDirection = Vector3.zero
                else
                    local angle = math.random() * math.pi * 2
                    _autoPlayDirection = Vector3.new(math.cos(angle), 0, math.sin(angle))
                end
                _autoPlayMoveUntil = now + (math.random(6, 16) / 10)
            end

            if now >= _autoPlayNextTurn then
                local camera = workspace.CurrentCamera
                if camera then
                    local look = camera.CFrame.LookVector
                    local yaw = math.atan2(-look.X, -look.Z)
                    local pitch = math.asin(math.clamp(look.Y, -1, 1))
                    _autoPlayTargetYaw = yaw + math.rad(math.random(-150, 150))
                    _autoPlayTargetPitch = math.clamp(
                        pitch + math.rad(math.random(-12, 12)),
                        math.rad(-65),
                        math.rad(65)
                    )
                end
                _autoPlayNextTurn = now + (math.random(10, 28) / 10)
            end
        end
    end)

    local _autoPlayMoveConn = RunService.Heartbeat:Connect(function()
        if not Cfg.AutoPlayEnabled then return end
        local hum = GetMovHum(GetMovChar())
        if not hum or hum.Health <= 0 then return end
        hum:Move(_autoPlayDirection, false)
    end)

    pcall(function()
        RunService:UnbindFromRenderStep("EtherealAutoPlayRandomCamera")
        RunService:BindToRenderStep(
            "EtherealAutoPlayRandomCamera",
            Enum.RenderPriority.Camera.Value + 1,
            function(dt)
                if not Cfg.AutoPlayEnabled then return end
                local camera = workspace.CurrentCamera
                if not camera or _autoPlayTargetYaw == nil or _autoPlayTargetPitch == nil then return end

                local look = camera.CFrame.LookVector
                local currentYaw = math.atan2(-look.X, -look.Z)
                local currentPitch = math.asin(math.clamp(look.Y, -1, 1))
                local yawDelta = math.atan2(
                    math.sin(_autoPlayTargetYaw - currentYaw),
                    math.cos(_autoPlayTargetYaw - currentYaw)
                )
                local alpha = 1 - math.exp(-math.max(dt, 0) * 2.2)
                local yaw = currentYaw + yawDelta * alpha
                local pitch = currentPitch + (_autoPlayTargetPitch - currentPitch) * alpha
                local horizontal = math.cos(pitch)
                local newLook = Vector3.new(
                    -math.sin(yaw) * horizontal,
                    math.sin(pitch),
                    -math.cos(yaw) * horizontal
                )
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + newLook)
            end
        )
    end)

    -- 5. ORBIT BALL — connect only while enabled to avoid idle Heartbeat work.
    local _orbitAngle = 0
    local _orbitWasEnabled = false
    local _orbitConn = nil
    local function OrbitBallStep(dt)
        local char = GetMovChar()
        local root = GetMovHRP(char)
        local hum = GetMovHum(char)
        local ball = GetBall()
        if not root or not hum or hum.Health <= 0 or not ball or not ball.Parent then return end
        if not _orbitWasEnabled then
            local offset = root.Position - ball.Position
            _orbitAngle = math.atan2(offset.Z, offset.X)
            _orbitWasEnabled = true
        end
        local direction = Cfg.OrbitBallDirection == 'Counterclockwise' and -1 or 1
        _orbitAngle += (tonumber(Cfg.OrbitBallSpeed) or 2) * dt * direction
        local radius = math.clamp(tonumber(Cfg.OrbitBallRadius) or 8, 3, 40)
        local center = ball.Position
        local targetPosition = center + Vector3.new(math.cos(_orbitAngle) * radius, 0, math.sin(_orbitAngle) * radius)
        local lookAt = Vector3.new(center.X, root.Position.Y, center.Z)
        pcall(function() root.CFrame = CFrame.lookAt(targetPosition, lookAt) end)
    end

    task.spawn(function()
        while true do
            if Cfg.OrbitBallEnabled then
                if not _orbitConn then
                    _orbitWasEnabled = false
                    _orbitConn = RunService.Heartbeat:Connect(OrbitBallStep)
                end
            elseif _orbitConn then
                _orbitConn:Disconnect()
                _orbitConn = nil
                _orbitWasEnabled = false
            end
            task.wait(0.1)
        end
    end)

    -- 6. ANTI-AFK
    task.spawn(function()
        while true do
            task.wait(Cfg.AntiAFKInterval or 28)
            if Cfg.AntiAFKEnabled then
                local hum = GetMovHum(GetMovChar())
                if hum then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
            end
        end
    end)

    -- 6. NOCLIP
    RunService.Stepped:Connect(function()
        xpcall(function()
            if not Cfg.NoclipEnabled then return end
            local char = GetMovChar()
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA('BasePart') then
                    part.CanCollide = false
                end
            end
        end, function() end)
    end)

    -- 7. FREE CAMERA
     local _freecamPos   = Vector3.zero
     local _freecamYaw   = 0
     local _freecamPitch = 0
     local _freecamGui   = nil
     local _ctrlMod      = nil
    pcall(function()
        _ctrlMod = require(LP.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild('ControlModule'))
    end)

    -- Key-state table: track held keys via InputBegan/Ended instead of
    -- polling IsKeyDown every frame. IsKeyDown can miss held state on some
    -- executors because the game sinks the input before UIS sees it.
     local _fcKeys = {}   -- [KeyCode] = true while held

    -- Mobile button direction: set to a Vector3 while thumb held, nil when released
     local _fcMobileDir = nil

    local _fcInputConn1, _fcInputConn2  -- InputBegan / InputEnded connections
    local _fcPreviousMouseBehavior = nil
    local _fcTouchConn, _fcMouseConn    -- look connections

     local function FC_StartInput()
        if _fcInputConn1 then return end   -- already connected

        _fcInputConn1 = UIS_Mov.InputBegan:Connect(function(input, processed)
            if processed then return end
            _fcKeys[input.KeyCode] = true
        end)

        _fcInputConn2 = UIS_Mov.InputEnded:Connect(function(input)
            _fcKeys[input.KeyCode] = nil
        end)

        _fcTouchConn = UIS_Mov.TouchMoved:Connect(function(touch, processed)
            if not processed and Cfg.FreecamEnabled then
                _freecamYaw   = _freecamYaw   - touch.Delta.X * (Cfg.FreecamLookSpeed or 0.003) * (5 / 3)
                _freecamPitch = math.clamp(
                    _freecamPitch - touch.Delta.Y * (Cfg.FreecamLookSpeed or 0.003) * (5 / 3),
                    -math.rad(89), math.rad(89)
                )
            end
        end)

        _fcMouseConn = UIS_Mov.InputChanged:Connect(function(input)
            if not Cfg.FreecamEnabled then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                -- PC: look freely (no RMB hold required — camera is Scriptable)
                _freecamYaw   = _freecamYaw   - input.Delta.X * (Cfg.FreecamLookSpeed or 0.003)
                _freecamPitch = math.clamp(
                    _freecamPitch - input.Delta.Y * (Cfg.FreecamLookSpeed or 0.003),
                    -math.rad(89), math.rad(89)
                )
            end
        end)
    end

     local function FC_StopInput()
        if _fcInputConn1 then _fcInputConn1:Disconnect(); _fcInputConn1 = nil end
        if _fcInputConn2 then _fcInputConn2:Disconnect(); _fcInputConn2 = nil end
        if _fcTouchConn  then _fcTouchConn:Disconnect();  _fcTouchConn  = nil end
        if _fcMouseConn  then _fcMouseConn:Disconnect();  _fcMouseConn  = nil end
        table.clear(_fcKeys)
        _fcMobileDir = nil
    end

    local function RemoveFreecamUI()
        if _freecamGui then _freecamGui:Destroy(); _freecamGui = nil end
    end

    local function CreateFreecamUI()
        if _freecamGui then return end
        local pGui = LP:FindFirstChild('PlayerGui')
        if not pGui then return end
        _freecamGui = Instance.new('ScreenGui')
        _freecamGui.Name        = 'EtherealFreecamUI'
        _freecamGui.ResetOnSpawn = false
        _freecamGui.Parent      = pGui

        -- Each button holds a direction vector while pressed — read per-frame in RenderStepped
        local function mkBtn(text, pos, dir)
            local b = Instance.new('TextButton')
            b.Size                = UDim2.fromOffset(56, 56)
            b.Position            = pos
            b.BackgroundColor3    = Color3.fromRGB(30, 30, 45)
            b.BackgroundTransparency = 0.35
            b.TextColor3          = Color3.fromRGB(255, 255, 255)
            b.TextSize            = 20
            b.Font                = Enum.Font.GothamBold
            b.Text                = text
            b.Parent              = _freecamGui
            Instance.new('UICorner', b).CornerRadius = UDim.new(0, 10)

            -- hold = set direction, release/leave = clear
            b.MouseButton1Down:Connect(function() _fcMobileDir = dir end)
            b.MouseButton1Up:Connect(function()
                if _fcMobileDir == dir then _fcMobileDir = nil end
            end)
            b.MouseLeave:Connect(function()
                if _fcMobileDir == dir then _fcMobileDir = nil end
            end)
        end

        local ox, oy = 20, -170
        mkBtn('▲', UDim2.new(0, ox+60,  1, oy+0),   Vector3.new( 0, 0,-1))
        mkBtn('▼', UDim2.new(0, ox+60,  1, oy+64),  Vector3.new( 0, 0, 1))
        mkBtn('◄', UDim2.new(0, ox+0,   1, oy+64),  Vector3.new(-1, 0, 0))
        mkBtn('►', UDim2.new(0, ox+128, 1, oy+64),  Vector3.new( 1, 0, 0))
        mkBtn('↑', UDim2.new(0, ox+128, 1, oy+0),   Vector3.new( 0, 1, 0))
        mkBtn('↓', UDim2.new(0, ox+0,   1, oy+0),   Vector3.new( 0,-1, 0))
    end

    RunService.RenderStepped:Connect(function(dt)
        xpcall(function()
            local cam = workspace.CurrentCamera
            if Cfg.FreecamEnabled then
                if cam.CameraType ~= Enum.CameraType.Scriptable then
                    -- first activation: snapshot current camera state
                    _freecamPos   = cam.CFrame.Position
                    _freecamYaw, _freecamPitch, _ = cam.CFrame:ToOrientation()
                    cam.CameraType = Enum.CameraType.Scriptable
                    pcall(function()
                        _fcPreviousMouseBehavior = UIS_Mov.MouseBehavior
                        if not UIS_Mov.TouchEnabled then UIS_Mov.MouseBehavior = Enum.MouseBehavior.LockCenter end
                    end)
                    if _ctrlMod then pcall(function() _ctrlMod:Disable() end) end
                    if UIS_Mov.TouchEnabled then CreateFreecamUI() end
                    FC_StartInput()
                end

                -- Build move direction from held-key table (always works on hold)
                local md = _fcMobileDir or Vector3.zero
                if not _fcMobileDir then
                    if _fcKeys[Enum.KeyCode.W] then md = md + Vector3.new( 0, 0,-1) end
                    if _fcKeys[Enum.KeyCode.S] then md = md + Vector3.new( 0, 0, 1) end
                    if _fcKeys[Enum.KeyCode.A] then md = md + Vector3.new(-1, 0, 0) end
                    if _fcKeys[Enum.KeyCode.D] then md = md + Vector3.new( 1, 0, 0) end
                    if _fcKeys[Enum.KeyCode.E] then md = md + Vector3.new( 0, 1, 0) end
                    if _fcKeys[Enum.KeyCode.Q] then md = md + Vector3.new( 0,-1, 0) end
                    if _fcKeys[Enum.KeyCode.Space]       then md = md + Vector3.new(0, 1, 0) end
                    if _fcKeys[Enum.KeyCode.LeftControl] then md = md + Vector3.new(0,-1, 0) end
                end

                local spd = Cfg.FreecamSpeed or 50
                if _fcKeys[Enum.KeyCode.LeftShift] then spd = spd * 3 end

                local rot = CFrame.Angles(0, _freecamYaw, 0) * CFrame.Angles(_freecamPitch, 0, 0)
                if md.Magnitude > 0 then
                    _freecamPos = _freecamPos + rot:VectorToWorldSpace(md.Unit) * spd * dt
                end
                cam.CFrame = CFrame.new(_freecamPos) * rot
            else
                if cam.CameraType == Enum.CameraType.Scriptable then
                    cam.CameraType = Enum.CameraType.Custom
                    local char = GetMovChar()
                    if char and char:FindFirstChild('Humanoid') then
                        cam.CameraSubject = char.Humanoid
                    end
                    if _ctrlMod then pcall(function() _ctrlMod:Enable() end) end
                    FC_StopInput()
                    pcall(function() UIS_Mov.MouseBehavior = _fcPreviousMouseBehavior or Enum.MouseBehavior.Default end)
                    _fcPreviousMouseBehavior = nil
                    RemoveFreecamUI()
                end
            end
        end, function() end)
    end)

    --=================================================================
    -- BALL STATUS BILLBOARD
    -- แสดง BillboardGui เหนือบอล — target, speed, from, dist
    --=================================================================
    local BallStatusBUI = nil
    local BallStatusLbl = nil

    local function RemoveBallStatusBUI()
        if BallStatusBUI then
            pcall(function() BallStatusBUI:Destroy() end)
            BallStatusBUI = nil
            BallStatusLbl = nil
        end
    end

    local function EnsureBallStatusBUI(ball)
        if BallStatusBUI and BallStatusBUI.Parent and BallStatusBUI.Adornee == ball then return end
        RemoveBallStatusBUI()
        if not ball or not ball.Parent then return end

        local sGui = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
        local bg = Instance.new("BillboardGui")
        bg.Name = "EtherealBallStatus"
        bg.AlwaysOnTop = true
        bg.Size = UDim2.new(0, 160, 0, 54)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.Adornee = ball
        bg.ResetOnSpawn = false
        bg.Parent = sGui

        local back = Instance.new("Frame")
        back.Size = UDim2.new(1, 0, 1, 0)
        back.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        back.BackgroundTransparency = 0.3
        back.BorderSizePixel = 0
        back.Parent = bg
        Instance.new("UICorner", back).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 220, 160)
        stroke.Transparency = 0.5
        stroke.Thickness = 1
        stroke.Parent = back

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, -6)
        lbl.Position = UDim2.new(0, 4, 0, 3)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextStrokeTransparency = 0.6
        lbl.RichText = true
        lbl.Text = '—'
        lbl.Parent = back

        BallStatusBUI = bg
        BallStatusLbl = lbl
    end

    local _ballStatusClock = 0
    RunService.Heartbeat:Connect(function()
        xpcall(function()
            if not Cfg.BallStatus then
                if BallStatusBUI then RemoveBallStatusBUI() end
                return
            end
            local now = os.clock()
            if (now - _ballStatusClock) < 0.08 then return end
            _ballStatusClock = now

            local ball = (BallState and BallState.ball and BallState.ball.Parent and BallState.ball)
                      or (GetBall and GetBall())
            if not ball or not ball.Parent then
                RemoveBallStatusBUI(); return
            end

            EnsureBallStatusBUI(ball)
            if not BallStatusLbl then return end

            local target = tostring(ball:GetAttribute("target") or "—")
            local from   = tostring(ball:GetAttribute("from")   or "—")

            -- compute speed directly from ball (BallState may not be updated if AutoParry is off)
            local z   = ball:FindFirstChildOfClass("LinearVelocity") or ball:FindFirstChild("zoomies")
            local zv  = z and (z.VectorVelocity or z.Velocity)
            local spd = (zv and typeof(zv) == 'Vector3') and math.floor(zv.Magnitude + 0.5) or 0

            local char  = LP.Character
            local hrp   = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
            local dist  = hrp and math.floor((hrp.Position - ball.Position).Magnitude + 0.5) or 0

            local isMe  = (target == LP.Name)
            local arrow = isMe and "▶" or "·"
            local tHex  = isMe and "#50DC9C" or "#FF6060"

            -- plain text fallback: build without nested font tags to avoid render issues
            BallStatusLbl.Text = string.format(
                '<font color="%s">%s %s</font>\n<font color="#AAAACC">spd </font>%d  <font color="#AAAACC">dist </font>%d\n<font color="#888899">from </font>%s',
                tHex, arrow, target, spd, dist, from
            )
        end, function() end)
    end)

    --=================================================================
    -- AUTO REWARD SYSTEM (ported from flyte.txt — non-event rewards)
    -- Covers: Daily Login, Playtime Rewards, Daily Quests
    -- Does NOT include: Battlepass spins, wheel spins, event rewards
    -- Each item runs every `Interval` seconds when its flag is true.
    --=================================================================
    local RS_Rewards   = game:GetService('ReplicatedStorage')
    local Reward_Lines = {}  -- [button] = {ID, Check} — pending claim checks
    local Reward_Items = {}  -- registered runners

    local function RewardFindUI(...)
        local node = LP:FindFirstChild('PlayerGui')
        for _, name in ipairs({...}) do
            if not node then return nil end
            node = node:FindFirstChild(name)
        end
        return node
    end

     local function RewardFire(id, button, controller, checkFn, nameFn, event)
        if not button or not button.Visible or Reward_Lines[button] then return false end
        local evName = event or 'Activated'
        if not getconnections then return false end
        for _, conn in pairs(getconnections(button[evName])) do
            if conn.Enabled and conn.Function and
               pcall(function() return getfenv(conn.Function).script == controller end) then
                Reward_Lines[button] = { ID = id, Check = checkFn, Names = nameFn }
                pcall(function() conn:Fire() end)
                return true
            end
        end
        return false
    end

     local function RewardRegister(id, name, fn, interval)
        Reward_Items[#Reward_Items+1] = {
            ID = id, Name = name, Run = fn,
            Interval = interval or 5, Next = 0
        }
    end

    -- 1. DAILY LOGIN
    RewardRegister('Claim_Daily_Rewards', 'Auto Claim Daily', function()
        pcall(function()
            local ctrl = RS_Rewards:FindFirstChild('Controllers')
            if not ctrl then return end

            local Data = shared.EtherealData or (getgenv().FlyteBB_State and getgenv().FlyteBB_State.Data)
            if not Data then return end

            local value = Data:Get('CurrentDailyLoginType')
            local info  = value and Data:Get({'DailyLoginData', value})
            if not info or type(info.NextClaim) ~= 'number' then return end
            if workspace:GetServerTimeNow() < info.NextClaim then return end

            local head = RewardFindUI('DailyLogin_' .. value .. '_Rewards')
            if not head then return end

            if value == 'D30' then
                local day = head.Page.Rewards:FindFirstChild('Day' .. (info.DaysClaimedStreak or 0) + 1, true)
                if day then head = day end
            elseif value == 'Longterm' then
                head = head.Frame and head.Frame:FindFirstChild('Claim')
            end

            local snap = info.NextClaim
            RewardFire('Claim_Daily_Rewards', head,
                ctrl:FindFirstChild('UI') and ctrl.UI:FindFirstChild('DailyLoginController'),
                function()
                    local d = Data:Get({'DailyLoginData', value, 'NextClaim'})
                    return d ~= snap
                end)
        end)
    end, 5)

    -- 2. PLAYTIME REWARDS + DAILY QUESTS
    RewardRegister('Claim_Playtime_Rewards', 'Auto Claim Playtime', function()
        pcall(function()
            local ctrl = RS_Rewards:FindFirstChild('Controllers')
            if not ctrl then return end

            local Data = shared.EtherealData or (getgenv().FlyteBB_State and getgenv().FlyteBB_State.Data)
            if not Data then return end

            -- Playtime rewards
            local ok, PlaytimeInfo = pcall(function()
                return require(RS_Rewards.Common.PlaytimeRewardsInfo).Rewards
            end)
            if ok and PlaytimeInfo then
                local pData = Data:Get('PlaytimeRewardsData')
                if pData then
                    for idx, reward in pairs(PlaytimeInfo) do
                        if not pData.ClaimedRewards[tostring(idx)] then
                            if workspace:GetServerTimeNow() >= (pData.TimerStart + reward.Duration) then
                                local btn = RewardFindUI('PlaytimeRewards','PlaytimeRewards','Page','List','RewardsList',tostring(idx),'ClaimButton')
                                RewardFire('Claim_Playtime_Rewards', btn,
                                    ctrl.UI and ctrl.UI:FindFirstChild('PlaytimeRewardsController'),
                                    function()
                                        return Data:Get({'PlaytimeRewardsData','ClaimedRewards',tostring(idx)}) == true
                                    end)
                                break
                            end
                        end
                    end
                end
            end

            -- Daily Quests
            local ok2, QuestData = pcall(function()
                return require(RS_Rewards.Shared.Quests)
            end)
            if ok2 and QuestData then
                for _, questId in pairs(Data:Get('CurrentQuests') or {}) do
                    local q = QuestData[questId]
                    if q and (Data:Get({'QuestStats', q.stat}) or 0) >= q.goal then
                        if not table.find(Data:Get('QuestsAwarded') or {}, questId) then
                            local btn = RewardFindUI('NewDailyQuests','Holder','Quests',questId,'Intermediate')
                            RewardFire('Claim_Playtime_Rewards', btn,
                                ctrl.UI and ctrl.UI:FindFirstChild('QuestsController'),
                                function()
                                    return table.find(Data:Get('QuestsAwarded') or {}, questId) ~= nil
                                end)
                        end
                    end
                end
            end
        end)
    end, 5)

    -- Reward step loop
    -- Uses a sentinel token (unique table) to detect restarts.
    -- Prevents double-spawn on rapid toggle on/off.
    local Reward_Token = nil

    local function Reward_Toggle()
        -- check if any reward flag is on
        local anyOn = false
        for _, item in pairs(Reward_Items) do
            if Cfg['Reward_' .. item.ID] then anyOn = true; break end
        end

        if not anyOn then
            Reward_Token = nil   -- signal running loop to stop
            return
        end

        if Reward_Token then return end   -- already running

        local token = {}       -- unique sentinel
        Reward_Token = token

        task.spawn(function()
            while Reward_Token == token do
                -- expire pending claim checks
                for btn, entry in pairs(Reward_Lines) do
                    local ok, done = pcall(entry.Check)
                    if (ok and done) or not btn.Parent then
                        Reward_Lines[btn] = nil
                    end
                end
                -- run scheduled items
                local now = os.clock()
                for _, item in pairs(Reward_Items) do
                    if Cfg['Reward_' .. item.ID] and now >= item.Next then
                        item.Next = now + item.Interval
                        task.spawn(item.Run)
                    end
                end
                task.wait(1)
            end
        end)
    end

    -- Expose so GUI callbacks can call it
    Cfg.__RewardToggle = Reward_Toggle

    -- Export BallState for console debugging
    getgenv().EtherealBallState = BallState

    -- Keep Anti-Lag internals in their own function scope. The engine chunk is
    -- already large; isolating these locals avoids Luau's 200-register limit.
    local AntiLag = (function()
        local Cache = {}
        local Connections = {}
        local Active = false

        local function Save(obj, prop, newVal)
            if not Cache[obj] then Cache[obj] = {} end
            if Cache[obj][prop] == nil then
                Cache[obj][prop] = obj[prop]
            end
            pcall(function() obj[prop] = newVal end)
        end

        local function Restore()
            for _, conn in ipairs(Connections) do
                pcall(function() conn:Disconnect() end)
            end
            table.clear(Connections)
            for obj, props in pairs(Cache) do
                pcall(function()
                    for prop, val in pairs(props) do
                        obj[prop] = val
                    end
                end)
            end
            table.clear(Cache)
            Active = false
        end

        local FX_CLASSES = {
            BloomEffect = true, BlurEffect = true,
            DepthOfFieldEffect = true, SunRaysEffect = true,
        }

        local function HandleDescendant(inst)
            if not Active then return end
            local className = inst.ClassName
            if className == 'Atmosphere' then
                Save(inst, 'Density', 0)
                Save(inst, 'Haze', 0)
                Save(inst, 'Glare', 0)
            elseif className == 'Clouds' then
                Save(inst, 'Enabled', false)
            elseif FX_CLASSES[className] then
                if not (Cache[inst] and Cache[inst].Enabled ~= nil) then
                    Save(inst, 'Enabled', false)
                    table.insert(Connections, inst:GetPropertyChangedSignal('Enabled'):Connect(function()
                        if Active and inst.Enabled then
                            pcall(function() inst.Enabled = false end)
                        end
                    end))
                end
            end
        end

        local function ScanContainer(container)
            if not container then return end
            for _, desc in ipairs(container:GetDescendants()) do
                HandleDescendant(desc)
            end
            table.insert(Connections, container.DescendantAdded:Connect(HandleDescendant))
        end

        local function Apply()
            if not Active then return end
            local lighting = game:GetService('Lighting')
            local terrain = workspace.Terrain
            local rendering = settings().Rendering
            Save(rendering, 'QualityLevel', Enum.QualityLevel.Level01)
            Save(lighting, 'GlobalShadows', false)
            Save(lighting, 'EnvironmentDiffuseScale', 0)
            Save(lighting, 'EnvironmentSpecularScale', 0)
            Save(terrain, 'WaterWaveSize', 0)
            Save(terrain, 'WaterWaveSpeed', 0)
            Save(terrain, 'WaterReflectance', 0)
            ScanContainer(lighting)
            ScanContainer(terrain)
            ScanContainer(workspace.CurrentCamera)
        end

        local function Enable()
            Restore()
            Active = true
            Apply()
            table.insert(Connections, workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
                if Active then ScanContainer(workspace.CurrentCamera) end
            end))
            table.insert(Connections, LP.CharacterAdded:Connect(function()
                if not Active then return end
                task.delay(0.3, function()
                    if Active then
                        table.clear(Cache)
                        Apply()
                    end
                end)
            end))
            task.spawn(function()
                while Active do
                    task.wait(10)
                    if Active then Apply() end
                end
            end)
            Log('Success', 'Anti-Lag', 'Enabled — QualityLevel 1, shadows + post-FX disabled.')
        end

        return { Enable = Enable, Restore = Restore }
    end)()

    --=================================================================
    -- NO-RENDER — disable particles, decals, beams, trails, world GUIs
    -- outside player characters. Full restore on disable.
    --=================================================================
     local NoRender_Cache = {}   -- [inst] = { [prop] = originalValue }
     local NoRender_Conn  = nil
     local NoRender_Active = false

     local function NR_Save(inst, prop, newVal)
        if not NoRender_Cache[inst] then NoRender_Cache[inst] = {} end
        if NoRender_Cache[inst][prop] == nil then
            NoRender_Cache[inst][prop] = inst[prop]
        end
        pcall(function() inst[prop] = newVal end)
        if inst:IsA('ParticleEmitter') then pcall(function() inst:Clear() end) end
    end

     local function NR_Restore()
        if NoRender_Conn then pcall(function() NoRender_Conn:Disconnect() end); NoRender_Conn = nil end
        for inst, props in pairs(NoRender_Cache) do
            pcall(function()
                for prop, val in pairs(props) do inst[prop] = val end
            end)
        end
        table.clear(NoRender_Cache)
        NoRender_Active = false
    end

     local function NR_IsPlayerModel(inst)
        local par = inst.Parent
        while par and par ~= workspace do
            if par:IsA('Model') then
                local plr = game:GetService('Players'):GetPlayerFromCharacter(par)
                if plr then return true end
            end
            par = par.Parent
        end
        return false
    end

     local function NR_Process(inst)
        if not NoRender_Active then return end
        if NR_IsPlayerModel(inst) then return end
        if inst:IsA('ParticleEmitter') or inst:IsA('Beam') or inst:IsA('Trail') then
            NR_Save(inst, 'Enabled', false)
            NR_Save(inst, 'Transparency', NumberSequence.new(1))
        elseif inst:IsA('Decal') or inst:IsA('Texture') then
            NR_Save(inst, 'Transparency', 1)
        elseif (inst:IsA('SurfaceGui') or inst:IsA('BillboardGui')) and not NR_IsPlayerModel(inst) then
            NR_Save(inst, 'Enabled', false)
        end
    end

     local function NoRender_Enable()
        NR_Restore()
        NoRender_Active = true
        for _, desc in ipairs(workspace:GetDescendants()) do
            NR_Process(desc)
        end
        NoRender_Conn = workspace.DescendantAdded:Connect(NR_Process)
        Log('Success', 'No-Render', 'Enabled — particles, decals, world GUIs suppressed.')
    end

    --=================================================================
    -- ANTI-LAG / NO-RENDER pulse watcher (runs in Feature_Tick)
    --=================================================================
     local _antiLagPulse  = 0
     local _noRenderPulse = 0


    -- extend Feature_Tick by patching the heartbeat connection after the fact
    RunService.Heartbeat:Connect(function()
        xpcall(function()
             alp = tonumber(Cfg.__AntiLagPulse) or 0
            if alp ~= _antiLagPulse then
                _antiLagPulse = alp
                if Cfg.AntiLag then
                    AntiLag.Enable()
                else
                    AntiLag.Restore()
                    Log('Info', 'Anti-Lag', 'Disabled — rendering restored.')
                end
            end
             nrp = tonumber(Cfg.__NoRenderPulse) or 0
            if nrp ~= _noRenderPulse then
                _noRenderPulse = nrp
                if Cfg.NoRender then
                    NoRender_Enable()
                else
                    NR_Restore()
                    Log('Info', 'No-Render', 'Disabled — effects restored.')
                end
            end
        end, function() end)
    end)


RunService = game:GetService("RunService")

AutoTuner = {
    CurrentCap = 120,
    MinCap = 60,
    MaxCap = 240,
    SpikeThreshold = 0.045,
    IsTuning = true
}

function ApplyEngineFlags(targetFps, physicsRate)
    pcall(function()
        if type(setfpscap) == "function" then
            setfpscap(targetFps)
        end
    end)
    pcall(function()
        if type(setfflag) == "function" then
            setfflag("DFIntTaskSchedulerTargetFps", tostring(targetFps))
            setfflag("FFlagDebugDisableMicroProfiler", "True")
            setfflag("FFlagGraphicsQualityAutoAdjust", "False")
            setfflag("DFIntS2PhysicsSenderRate", tostring(physicsRate))
            setfflag("DFIntRakNetResendBufferArrayLength", "128")
            setfflag("DFIntLargePacketQueueSize", "1024")
            setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", "False")
        end
    end)
end

function DetectHardwareBaseline()
    samples = {}
    for i = 1, 30 do
        dt = RunService.RenderStepped:Wait()
        if dt > 0 then
            table.insert(samples, 1 / dt)
        end
    end
    table.sort(samples)
    medianFps = samples[math.floor(#samples / 2)] or 60
    if medianFps >= 135 then
        AutoTuner.CurrentCap = 144
        AutoTuner.MaxCap = 240
    elseif medianFps >= 85 then
        AutoTuner.CurrentCap = 90
        AutoTuner.MaxCap = 120
    else
        AutoTuner.CurrentCap = 60
        AutoTuner.MaxCap = 90
    end
    ApplyEngineFlags(AutoTuner.CurrentCap, 30)
end

task.spawn(function()
    ok, err = pcall(DetectHardwareBaseline)
    if not ok then
        warn("AutoTuner Baseline Error: " .. tostring(err))
    end

    frameHistory = {}
    spikeCount = 0
    stableTicks = 0

    while AutoTuner.IsTuning do
        dt = RunService.Heartbeat:Wait()
        if dt > AutoTuner.SpikeThreshold then
            spikeCount = spikeCount + 1
            stableTicks = 0
        else
            stableTicks = stableTicks + 1
        end

        table.insert(frameHistory, 1 / math.max(dt, 0.001))
        if #frameHistory > 60 then
            table.remove(frameHistory, 1)
        end

        if #frameHistory == 60 then
            sum = 0
            for _, v in ipairs(frameHistory) do
                sum = sum + v
            end
            avgFps = sum / 60

            if spikeCount >= 3 or avgFps < (AutoTuner.CurrentCap * 0.75) then
                newCap = math.max(AutoTuner.MinCap, AutoTuner.CurrentCap - 15)
                if newCap ~= AutoTuner.CurrentCap then
                    AutoTuner.CurrentCap = newCap
                    ApplyEngineFlags(AutoTuner.CurrentCap, 20)
                end
                spikeCount = 0
            elseif stableTicks >= 180 and avgFps >= (AutoTuner.CurrentCap * 0.95) then
                newCap = math.min(AutoTuner.MaxCap, AutoTuner.CurrentCap + 15)
                if newCap ~= AutoTuner.CurrentCap then
                    AutoTuner.CurrentCap = newCap
                    ApplyEngineFlags(AutoTuner.CurrentCap, 30)
                end
                stableTicks = 0
            end
        end
    end
end)

task.spawn(function()
    while (AutoTuner and AutoTuner.IsTuning) and task.wait(12) do
        pcall(gcinfo)
    end
end)

    return {
        Cfg = Cfg,
        Restart = StartParryLoop,
        Ping = GetPing,
        Staff = {
            Scan = Staff_Scan_Count,
            GetRank = Staff_Get_Rank,
            IsStaff = function(Player)
                return Player ~= nil and Staff_State.Detected[Player.UserId] ~= nil
            end,
            Detected = Staff_State.Detected,
        },
        Stop = function()
            if _parryConn then
                _parryConn:Disconnect()
                _parryConn = nil
            end
        end,
    }
end

end)()

--// [ BOOT ] ---------------------------------------------------------------
local App = Create_Menu({ Library = Library, Window = Window })
local Engine = Create_AP({ Cfg = App.Cfg, Log = App.Log })

--// [ VERSION ] ------------------------------------------------------------
local function Set_Version(New_Version)
    New_Version = tostring(New_Version or CONFIG.Version)
    CONFIG.Version = New_Version
    ENV.Product_Version = New_Version

    local Gui = Window and Window.Gui
    local Label = Gui and Gui:FindFirstChild('Version', true)
    if Label and Label:IsA('TextLabel') then
        Label.Text = New_Version
    end
    if ENV.Ethereal then
        ENV.Ethereal.Version = New_Version
    end
    return New_Version
end

--// [ API ] ----------------------------------------------------------------
ENV.Ethereal = {
    Version = CONFIG.Version,
    Set_Version = Set_Version,
    UI_URL = CONFIG.UI_URL,
    Library = Library,
    Window = Window,
    Notify = App.Log,
    Cfg = App.Cfg,
    Engine = Engine,
    Staff = Engine.Staff,
}