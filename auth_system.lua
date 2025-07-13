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
    -- Create tabs window following the exact pattern
    local AuthWindow = ReGui:TabsWindow({
        Title = "Indictus Authentication",
        Size = UDim2.fromOffset(500, 350)
    })

    local authenticated = false
    local Console = nil
    local consoleContent = "<font color='#00BFFF'>●</font> [INFO] Authentication system initialized.\n<font color='#00BFFF'>●</font> [INFO] Please enter your access key in the Authentication tab."
    
    -- Create Authentication tab
    local AuthTab = AuthWindow:CreateTab({Name="Authentication"})
    
    AuthTab:Label({
        Text = "Welcome to Indictus Authentication System",
        TextWrapped = true
    })
    
    AuthTab:Separator()
    
    AuthTab:Label({
        Text = "Please enter your access key below:",
        TextWrapped = true
    })

    local keyInput = ""
    AuthTab:InputText({
        Label = "Access Key",
        Value = "",
        Callback = function(self, Value)
            keyInput = Value
        end
    })

    AuthTab:Separator()
    
    -- Create Console tab
    local ConsoleTab = AuthWindow:CreateTab({Name="Console"})
    
    Console = ConsoleTab:Console({
        LineNumbers = true,
        ReadOnly = true,
        AutoScroll = true,
        MaxLines = 100,
        RichText = true,
        Value = consoleContent
    })
    
    -- Helper function to add colored console messages
    local function addConsoleMessage(messageType, message)
        local coloredMessage = ""
        
        if messageType == "INFO" then
            coloredMessage = "<font color='#00BFFF'>●</font> [INFO] " .. message
        elseif messageType == "SUCCESS" then
            coloredMessage = "<font color='#00FF00'>●</font> [SUCCESS] " .. message
        elseif messageType == "ERROR" then
            coloredMessage = "<font color='#FF0000'>●</font> [ERROR] " .. message
        elseif messageType == "WARNING" then
            coloredMessage = "<font color='#FFA500'>●</font> [WARNING] " .. message
        else
            coloredMessage = message
        end
        
        consoleContent = consoleContent .. "\n" .. coloredMessage
        Console:SetValue(consoleContent)
    end

    AuthTab:Button({
        Text = "Authenticate",
        Callback = function()
            addConsoleMessage("INFO", "Attempting authentication...")
            
            if keyInput == "" then
                addConsoleMessage("ERROR", "Access key cannot be empty!")
                return
            end
            
            if authenticatePlayer(keyInput) then
                addConsoleMessage("SUCCESS", "Authentication successful!")
                addConsoleMessage("INFO", "Loading main application...")
                authenticated = true
                
                -- Small delay to show success message
                wait(1)
                
                ReGui:SetFocusedWindow(nil)
                local window = game:GetService("CoreGui").ReGui.Windows.TabsWindow
                if window then
                    window:Destroy()
                end
            else
                addConsoleMessage("ERROR", "Authentication failed! Invalid key.")
                addConsoleMessage("INFO", "Please check your key and try again.")
            end
        end
    })

    AuthTab:Button({
        Text = "Cancel",
        Callback = function()
            addConsoleMessage("INFO", "Authentication cancelled by user.")
            addConsoleMessage("INFO", "Exiting application...")
            
            -- Small delay to show cancellation message
            wait(1)
            
            ReGui:SetFocusedWindow(nil)
            local window = game:GetService("CoreGui").ReGui.Windows.TabsWindow
            if window then
                window:Destroy()
            end
            error("Authentication cancelled.")
        end
    })
    
    -- Add some helpful information in the Auth tab
    AuthTab:Separator()
    
    AuthTab:Label({
        Text = "💡 Need a key? Join our Discord server!",
        TextWrapped = true
    })
    
    AuthTab:Button({
        Text = "Copy Discord Invite",
        Callback = function()
            addConsoleMessage("INFO", "Discord invite copied to clipboard!")
            if setclipboard then
                setclipboard("https://discord.gg/wgSjANmXPZ")
            end
        end
    })

    -- Wait for authentication to complete
    repeat
        wait(0.1)
    until authenticated

    -- Small delay to ensure window is fully destroyed
    wait(0.2)
    return authenticated
end

return showAuthSystem()
