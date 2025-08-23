-- Discord Webhook Meteor Shower Logger
-- Place this script in ServerScriptService

print("Mulai")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuration
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1408441169028972797/_ls8aguNPMDTgrO6yJ6l72p5CXjUD56md_gy6t7xN0Lkf69pqhxaHFTddOtwkX1a3W0Q" -- Replace with your webhook URL
local req = (syn and syn.request) or (http_request) or (request)

-- Wait for the remote to exist
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Info"):WaitForChild("BigNotification")

-- Function to extract code from parentheses
local function extractCode(text)
    local code = string.match(text, "%((.-)%)")
    return code
end

-- Function to check if text contains "end"
local function containsEnd(text)
    return string.find(text:lower(), "end") ~= nil
end

-- Function to get relative timestamp (Discord format)
local function getRelativeTimestamp()
    local unixTimestamp = os.time() -- This already returns Unix timestamp
    return "<t:" .. unixTimestamp .. ":R>"
end

-- Function to get player info by userId
local function getPlayerInfo(userId)
    local success, result = pcall(function()
        return Players:GetNameFromUserIdAsync(userId)
    end)
    
    if success then
        return result
    else
        return "Unknown"
    end
end

-- Function to get display name by userId
local function getDisplayName(userId)
    local success, result = pcall(function()
        return Players:GetDisplayNameFromUserIdAsync(userId)
    end)
    
    if success then
        return result
    else
        return "Unknown"
    end
end

-- Function to find userId by matching username from code
local function findUserIdByUsername(code)
    -- The code should be the username we're looking for
    local targetUsername = code
    
    -- Loop through all players in the server
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == targetUsername:lower() then
            return player.UserId
        end
    end
    
    return nil
end

-- Function to get player level (you may need to modify this based on your game's level system)
local function getPlayerLevel(userId)
    -- This is a placeholder - replace with your actual level retrieval logic
    -- You might need to access leaderstats, DataStore, or other game-specific systems
    local player = Players:GetPlayerByUserId(userId)
    if player then
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local level = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl")
            if level then
                return tostring(level.Value)
            end
        end
    end
    return "?"
end

-- Function to get player info directly from Players service (since they're in server)
local function getPlayerInfoFromServer(userId)
    for _, player in pairs(Players:GetPlayers()) do
        if player.UserId == userId then
            return player.Name, player.DisplayName
        end
    end
    return "Unknown", "Unknown"
end

-- Function to send to Discord webhook
local function sendToDiscord(timestamp, level, displayName, username, code)
    local message = string.format("%s | | %s - | %s | | (%s) | |", 
        timestamp, level, displayName, username)
    
    local data = {
        content = message,
        embeds = {
            {
                title = "🌟 Meteor Shower Code Detected",
                description = "**Code:** `" .. code .. "`",
                color = 3447003, -- Blue color
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                footer = {
                    text = "Meteor Logger"
                }
            }
        }
    }
    
    local requestData = {
        Url = DISCORD_WEBHOOK,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    }
    
    local success, response = pcall(function()
        return req(requestData)
    end)
    
    if success and response.Success then
        print("✅ Successfully sent to Discord")
    else
        warn("❌ Failed to send to Discord: " .. tostring(response and response.StatusMessage or "Request failed"))
    end
end

-- Connect to the remote
remote.OnClientEvent:Connect(function(...)
    local args = {...}
    
    -- Check if first argument exists and is "Meteor Shower"
    if args[1] and tostring(args[1]) == "Meteor Shower" then
        local message = tostring(args[1])
        
        -- Check if the message doesn't contain "end"
        if not containsEnd(message) then
            local code = extractCode(message)
            
            if code then
                print("🌟 METEOR SHOWER CODE DETECTED: " .. code)
                print("📝 Full message: " .. message)
                
                -- Find userId by matching username from code
                local userId = findUserIdByUsername(code)
                
                if userId then
                    -- Get player information directly from server
                    local username, displayName = getPlayerInfoFromServer(userId)
                    local level = getPlayerLevel(userId)
                    local timestamp = getRelativeTimestamp()
                    
                    print("👤 Player Info:")
                    print("   UserID: " .. userId)
                    print("   Username: " .. username)
                    print("   Display Name: " .. displayName)
                    print("   Level: " .. level)
                    
                    -- Send to Discord
                    sendToDiscord(timestamp, level, displayName, username, code)
                    
                else
                    print("⚠️ Could not find player with username: " .. code)
                    print("   Player might not be in the current server")
                    -- Send basic info without player details
                    sendToDiscord(getRelativeTimestamp(), "?", "Unknown", code, code)
                end
                
                print("⏰ Time: " .. os.date("%X"))
                print("----------------------------------------")
                
            else
                print("⚠️ Meteor Shower detected but no code found in parentheses")
                print("📝 Full message: " .. message)
                print("----------------------------------------")
            end
        else
            print("🔚 Meteor Shower event ended")
        end
    end
end)
