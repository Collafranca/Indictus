local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()

local function encodeBase64(data)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function authenticatePlayer(userKey)
    local success, response = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/Collafranca/Indictus/refs/heads/main/Key')
    end)

    if success then
        local cleanResponse = response:gsub("%s+", "")
        local cleanUserKey = userKey:gsub("%s+", "")
        local encodedUserKey = encodeBase64(cleanUserKey)

        return encodedUserKey == cleanResponse
    end

    return false
end

local function showAuthSystem()
    local AuthWindow = ReGui:Window({
        Title = "Authentication",
        Size = UDim2.fromOffset(400, 200)
    })

    AuthWindow:Label({
        Text = "Please enter your access key:",
        TextWrapped = true
    })

    local keyInput = ""
    AuthWindow:InputText({
        Label = "Access Key",
        Value = "",
        Callback = function(self, Value)
            keyInput = Value
        end
    })

    AuthWindow:Separator()

    local authenticated = false

    AuthWindow:Button({
        Text = "Authenticate",
        Callback = function()
            if authenticatePlayer(keyInput) then
                authenticated = true
                ReGui:SetFocusedWindow(nil)
                local window = game:GetService("CoreGui").ReGui.Windows.Window
                if window then
                    window:Destroy()
                end
            else
                error("Authentication failed! Invalid key.")
            end
        end
    })

    AuthWindow:Button({
        Text = "Cancel",
        Callback = function()
            ReGui:SetFocusedWindow(nil)
            local window = game:GetService("CoreGui").ReGui.Windows.Window
            if window then
                window:Destroy()
            end
            error("Authentication cancelled.")
        end
    })

    -- Wait for authentication to complete
    repeat
        wait(0.1)
    until authenticated

    -- Small delay to ensure window is fully destroyed
    wait(0.2)
end

showAuthSystem()
