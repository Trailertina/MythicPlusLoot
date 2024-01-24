--For testing purposes, run below command in chat to reset DB
--/run MythicPlusLootDB = nil




local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "MythicPlusLoot" then
        -- Check if the message has been shown using saved variables
        if not MythicPlusLootDB or not MythicPlusLootDB.firstTimeMessageShown then
            -- Create a frame for displaying the message
            local messageFrame = CreateFrame("Frame", "MythicPlusLootMessageFrame", UIParent, "BackdropTemplate")
            messageFrame:SetSize(400, 150)
            messageFrame:SetPoint("CENTER", 0, 150)

            -- Create a backdrop for the frame
            messageFrame:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })

            -- Set the backdrop color
            messageFrame:SetBackdropColor(0, 0, 0, 0.8)

            -- Create a fontString to display the message
            local messageText = messageFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            messageText:SetText("THANK YOU FOR CHOOSING MYTHICPLUSLOOT")
            messageText:SetPoint("CENTER", 0, 50)
			
			-- Create a fontString to display the message
            local messageText = messageFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            messageText:SetText("This addon is a beta version with known bugs/functionality issues\n\nI hope you find it useful anyway!\n\nHappy grinding my friends :D\n\n(Please check the README file for known bugs)")
            messageText:SetPoint("CENTER", 0, -22)

            -- Create a close button
            local closeButton = CreateFrame("Button", nil, messageFrame, "UIPanelCloseButton")
            closeButton:SetPoint("TOPRIGHT", messageFrame, "TOPRIGHT", -5, -5)
            closeButton:SetScript("OnClick", function()
                messageFrame:Hide()
            end)

            -- Update the saved variables to mark that the message has been shown
            MythicPlusLootDB = MythicPlusLootDB or {}
            MythicPlusLootDB.firstTimeMessageShown = true
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)