-- Create a frame for the addon
local LootAddonFrame = CreateFrame("Frame", "LootAddonFrame", UIParent)
LootAddonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
LootAddonFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
LootAddonFrame:RegisterEvent("CHALLENGE_MODE_START")
LootAddonFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
LootAddonFrame:RegisterEvent("CHAT_MSG_LOOT")
LootAddonFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-- Table to store loot information for each player
local lootHistory = {}

-- Flag to indicate if the player is in a Mythic Plus dungeon
--local inMythicPlusDungeon = false

-- Flag to track whether the addon has been loaded before
local addonLoaded = false

-- Event handler for PLAYER_ENTERING_WORLD
function LootAddonFrame:PLAYER_ENTERING_WORLD(...)
    if not addonLoaded then
        print("MythicPlusLoot loaded.")
        addonLoaded = true
    end
end

-- Event handler for GROUP_ROSTER_UPDATE
function LootAddonFrame:GROUP_ROSTER_UPDATE(...)
    -- Code for GROUP_ROSTER_UPDATE event
end

-- Event handler for CHALLENGE_MODE_START
function LootAddonFrame:CHALLENGE_MODE_START(...)
    -- Code for CHALLENGE_MODE_START event
    inMythicPlusDungeon = true    

    -- Clear loot history when starting a new Mythic Plus dungeon
    lootHistory = {}
	
	-- Clear loot frame when starting a new Mythic Plus dungeon
	self:UpdateLootWindow()
	
	-- Hide loot frame, otherwise it will show when calling updatelootwindow
	if LootAddonFrame.LootWindow then
		LootAddonFrame.LootWindow:Hide()
	end
	
	print("New M+ registered - Previous loot cleared.")
end

-- Event handler for CHALLENGE_MODE_COMPLETED
function LootAddonFrame:CHALLENGE_MODE_COMPLETED(...)
    -- Code for CHALLENGE_MODE_COMPLETED event
    if inMythicPlusDungeon then
        self:OpenLootWindow()
		
		-- Set a timer to reset inMythicPlusDungeon to false after 2 minute
        C_Timer.After(120, function()
            inMythicPlusDungeon = false
            --print("M+ concluded.")
        end)
    end
end

-- Function to open the loot window for all group members
function LootAddonFrame:OpenLootWindow()
    if not LootAddonFrame.LootWindow then
        -- Create the loot window and set it up
        LootAddonFrame.LootWindow = CreateFrame("Frame", "LootAddonFrame_LootWindow", UIParent, "UIPanelDialogTemplate")
        LootAddonFrame.LootWindow:SetSize(275, 325)
        LootAddonFrame.LootWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10)
        LootAddonFrame.LootWindow.title = LootAddonFrame.LootWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        LootAddonFrame.LootWindow.title:SetPoint("TOP", LootAddonFrame.LootWindow, "TOP", 0, -10)
        LootAddonFrame.LootWindow.title:SetText("MythicPlusLoot")

        -- Make the loot window draggable
        LootAddonFrame.LootWindow:SetMovable(true)
        LootAddonFrame.LootWindow:EnableMouse(true)
        LootAddonFrame.LootWindow:RegisterForDrag("LeftButton")

        -- Set script for dragging
        LootAddonFrame.LootWindow:SetScript("OnDragStart", LootAddonFrame.LootWindow.StartMoving)
        LootAddonFrame.LootWindow:SetScript("OnDragStop", LootAddonFrame.LootWindow.StopMovingOrSizing)
    else
        -- Update the loot window with the latest loot information for all group members
        self:UpdateLootWindow()
        LootAddonFrame.LootWindow:Show()
    end
end

-- Function to update the loot window with the latest loot information for all group members
function LootAddonFrame:UpdateLootWindow()
    if not LootAddonFrame.LootWindow then
        return
    end
    
    -- Clear the existing loot window's contents
    LootAddonFrame.LootWindow:Hide()  -- Hide the window to prevent flickering

    -- Iterate over the loot window's dynamic content and hide text (FontString), excluding the header
    for _, child in ipairs({LootAddonFrame.LootWindow:GetRegions()}) do
        if child and child:IsObjectType("FontString") and child ~= LootAddonFrame.LootWindow.title then
            child:Hide()
        end
    end
    
    -- Clear the existing loot window's whisper button while preserving other child frames
    for _, child in ipairs({LootAddonFrame.LootWindow:GetChildren()}) do
        if child and child:IsObjectType("Button") and child:GetText() == "Whisper" then
            child:Hide()
        end
    end
   
    local yOffset = 30  -- Starting y offset

    for playerName, lootList in pairs(lootHistory) do
        local guid = UnitGUID(playerName)

        if guid then
            local _, classFilename, _, _, _, _, _, _, _, _, classID = GetPlayerInfoByGUID(guid)
            local classColor = RAID_CLASS_COLORS[classFilename]
            local coloredPlayerName = classColor and format("|c%s%s|r", classColor.colorStr, playerName) or playerName

            local playerLabel = LootAddonFrame.LootWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            playerLabel:SetPoint("TOPLEFT", 10, -yOffset)
            playerLabel:SetText(coloredPlayerName .. " looted:")

            -- Create a whisper button next to the player's name
            local whisperButton = CreateFrame("Button", nil, LootAddonFrame.LootWindow, "UIPanelButtonTemplate")
            whisperButton:SetPoint("LEFT", playerLabel, "RIGHT", 5, 0)
            whisperButton:SetSize(60, 20)
            whisperButton:SetText("Whisper")
            whisperButton:SetScript("OnClick", function()
                -- Open a whisper window with the player's name
                local playerNameWithRealm = Ambiguate(playerName, "none")

                local playerNameRealm, playerRealm = string.match(playerName, "([^%-]+)%-(.*)")
                if playerRealm and playerRealm ~= GetRealmName() then
                    playerNameWithRealm = playerNameRealm .. "-" .. playerRealm
                end

                local editBox = ChatEdit_ChooseBoxForSend()
                editBox:SetText("/w " .. playerNameWithRealm .. " Hey mate, do you need that? :D")
                ChatEdit_ActivateChat(editBox)

                -- Send the message using ChatEdit_SendText after a short delay
                C_Timer.After(0.1, function()
                    ChatEdit_SendText(editBox)
                end)

                -- Clear the edit box after another short delay
                C_Timer.After(0.2, function()
                    editBox:SetText("")
                    
                    -- Simulate pressing Enter key after clearing the edit box
                    C_Timer.After(0.3, function()
                        editBox:ClearFocus() -- Ensure focus is cleared first
                        editBox:Insert("\n") -- Insert a newline character
                    end)
                end)
                
            end)

            local itemYOffset = 25  -- Separate yOffset for each item

            for _, itemLink in ipairs(lootList) do
                local itemName, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)

                -- Check if the item is a gear, finger, trinket, weapon, or off-hand
                if equipSlot == "INVTYPE_HEAD" or equipSlot == "INVTYPE_NECK" or equipSlot == "INVTYPE_SHOULDER"
                    or equipSlot == "INVTYPE_BODY" or equipSlot == "INVTYPE_CHEST" or equipSlot == "INVTYPE_ROBE"
                    or equipSlot == "INVTYPE_WAIST" or equipSlot == "INVTYPE_LEGS" or equipSlot == "INVTYPE_FEET"
                    or equipSlot == "INVTYPE_WRIST" or equipSlot == "INVTYPE_HAND" or equipSlot == "INVTYPE_FINGER"
                    or equipSlot == "INVTYPE_TRINKET" or equipSlot == "INVTYPE_CLOAK" or equipSlot == "INVTYPE_WEAPON"
                    or equipSlot == "INVTYPE_SHIELD" or equipSlot == "INVTYPE_2HWEAPON" or equipSlot == "INVTYPE_WEAPONMAINHAND"
                    or equipSlot == "INVTYPE_WEAPONOFFHAND" or equipSlot == "INVTYPE_HOLDABLE" or equipSlot == "INVTYPE_RANGED" then

                    local itemLabel = LootAddonFrame.LootWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    itemLabel:SetPoint("TOPLEFT", 20, -yOffset - itemYOffset)
                    itemLabel:SetText("- " .. itemLink)

                    -- Store the item link in a tooltip handler
                    itemLabel.itemLink = itemLink

                    -- Make the item label clickable to show the item tooltip
                    itemLabel:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                        GameTooltip:SetHyperlink(self.itemLink)
                        GameTooltip:Show()
                    end)

                    itemLabel:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)

                    itemYOffset = itemYOffset + 15  -- Incremented for each item
                end
            end

            yOffset = yOffset + itemYOffset + 5  -- Adjusted for each player's total height with some extra space
        end
    end

    -- Show the new loot window
    LootAddonFrame.LootWindow:Show()
end


-- Event handler for CHAT_MSG_LOOT
function LootAddonFrame:CHAT_MSG_LOOT(...)
  	if inMythicPlusDungeon then
        local message, _, _, _, _, _, _, _, _, _, _, guid = ...
        --print("Loot message received:", message)

        local playerName, itemLink = string.match(message, "^([^%s]+) receives loot: (.+)$")

        -- Handle self-loot for testing(uncomment when testing)
        --if not playerName then
            --playerName = UnitName("player")
            --if string.find(message, "You receive loot: ") then
                --itemLink = string.match(message, "You receive loot: (.+)")
           --end
        --end

        if playerName and itemLink then
            local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)

            -- Check if the item is a gear, finger, trinket, weapon, or off-hand
            if equipSlot == "INVTYPE_HEAD" or equipSlot == "INVTYPE_NECK" or equipSlot == "INVTYPE_SHOULDER"
                or equipSlot == "INVTYPE_BODY" or equipSlot == "INVTYPE_CHEST" or equipSlot == "INVTYPE_ROBE"
                or equipSlot == "INVTYPE_WAIST" or equipSlot == "INVTYPE_LEGS" or equipSlot == "INVTYPE_FEET"
                or equipSlot == "INVTYPE_WRIST" or equipSlot == "INVTYPE_HAND" or equipSlot == "INVTYPE_FINGER"
                or equipSlot == "INVTYPE_TRINKET" or equipSlot == "INVTYPE_CLOAK" or equipSlot == "INVTYPE_WEAPON"
                or equipSlot == "INVTYPE_SHIELD" or equipSlot == "INVTYPE_2HWEAPON" or equipSlot == "INVTYPE_WEAPONMAINHAND"
                or equipSlot == "INVTYPE_WEAPONOFFHAND" or equipSlot == "INVTYPE_HOLDABLE" or equipSlot == "INVTYPE_RANGED" then

                -- Store loot information for the player
                lootHistory[playerName] = lootHistory[playerName] or {}
                table.insert(lootHistory[playerName], itemLink)

                -- Update the loot window with the latest loot information for all group members
                self:UpdateLootWindow()
            end
        end

        -- Clear the chat message to prevent it from being printed
        return true
    end
end


-- Slash command to toggle the loot window
SLASH_MYTHICPLUSLOOT1 = "/mythicplusloot"
SlashCmdList["MYTHICPLUSLOOT"] = function()
    if LootAddonFrame.LootWindow and LootAddonFrame.LootWindow:IsShown() then
        LootAddonFrame.LootWindow:Hide()
    else
        LootAddonFrame:OpenLootWindow()
    end
end
