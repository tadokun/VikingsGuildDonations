local frame = CreateFrame('Frame', 'EventFrame', UIParent)

frame:RegisterEvent("GUILDBANKFRAME_OPENED");
frame:RegisterEvent("PLAYER_MONEY");
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
lastGetMoneyEvent = GetMoney()

local function eventHandler(self, event, arg1, ...)
    
    if event == "ADDON_LOADED" and arg1 == "GuildDonations" then
       if MoneySinceLastVisited == nil then
            MoneySinceLastVisited = 0; -- This is the first time this addon is loaded; initialize the count to 0.
            moneySave = MoneySinceLastVisited
        end
    end

    if event == "GUILDBANKFRAME_OPENED" then
        print("Guild Bank Opened");
        print(string.format("%s %s %s", "You have looted: ", GetCoinTextureString(MoneySinceLastVisited), " since last visit"))
        
        -- Main frame
        GuildDonation = CreateFrame("Frame", "GuildDonationFrame", UIParent, "BasicFrameTemplateWithInset");
        GuildDonation:SetSize(300, 200);
        GuildDonation:SetPoint("CENTER");
        GuildDonation:SetMovable(true);
        GuildDonation:EnableMouse(true);
        GuildDonation:SetFrameStrata("HIGH")
        GuildDonation:RegisterForDrag("LeftButton");
        GuildDonation:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        GuildDonation:SetScript("OnMouseUp", GuildDonation.StopMovingOrSizing)

        -- Title bar
        GuildDonation.title = GuildDonation:CreateFontString(nil, "OVERLAY");
        GuildDonation.title:SetFontObject("GameFontHighlight");
        GuildDonation.title:SetPoint("LEFT", GuildDonation.TitleBg, 5, 0);
        GuildDonation.title:SetText("Viking Guild Donations");
        -- 2, 94, 20
        -- Gold box 
        
        -- Calculate amounts
        donationAmount = calculateDonationAmount(MoneySinceLastVisited)
        calculationAmount = donationAmount
        copperAmount = calculationAmount % 100
        calculationAmount = (calculationAmount - copperAmount) / 100
        silverAmount  = calculationAmount % 100
        goldAmount = (calculationAmount - silverAmount) / 100

        goldDonationAmount = goldAmount
        GuildDonation.gold = CreateFrame("EditBox", "GuildDonationEditBoxGold", GuildDonation, "InputBoxTemplate")
        GuildDonation.gold:SetFrameStrata("DIALOG")
        GuildDonation.gold:SetSize(30,20)    
        GuildDonation.gold:SetAutoFocus(false)
        GuildDonation.gold:SetText(goldAmount) 
        GuildDonation.gold:SetPoint("TOPLEFT", 30, -90)
        GuildDonation.gold:SetScript("OnTextChanged", function(self, userInput)
            b = tonumber(GuildDonation.gold:GetText()) ~= nil
                if (b == true) then 
                    goldDonationAmount = GuildDonation.gold:GetText() * 10000
                    print(GetCoinTextureString(goldDonationAmount))                   
                end     
        end)            

        silverDonationAmount = silverAmount
        GuildDonation.silver = CreateFrame("EditBox", "GuildDonationEditBoxSilver", GuildDonation, "InputBoxTemplate")
        GuildDonation.silver:SetFrameStrata("DIALOG")
        GuildDonation.silver:SetSize(30,20)
        GuildDonation.silver:SetAutoFocus(false)
        GuildDonation.silver:SetText(silverAmount) 
        GuildDonation.silver:SetPoint("TOPLEFT", 90, -90)
        GuildDonation.silver:SetScript("OnTextChanged", function(self, userInput)
            b = tonumber(GuildDonation.silver:GetText()) ~= nil
                if (b == true) then 
                    silverDonationAmount = GuildDonation.silver:GetText() * 100
                    print(GetCoinTextureString(silverDonationAmount))                   
                end     
        end)            

        copperDonationAmount = copperAmount
        GuildDonation.copper = CreateFrame("EditBox", "GuildDonationEditBoxSilver", GuildDonation, "InputBoxTemplate")
        GuildDonation.copper:SetFrameStrata("DIALOG")
        GuildDonation.copper:SetSize(30,20)
        GuildDonation.copper:SetAutoFocus(false)
        GuildDonation.copper:SetText(copperAmount) 
        GuildDonation.copper:SetPoint("TOPLEFT", 150, -90)
        GuildDonation.copper:SetScript("OnTextChanged", function(self, userInput)
            b = tonumber(GuildDonation.copper:GetText()) ~= nil
                if (b == true) then 
                    copperDonationAmount = GuildDonation.copper:GetText()
                    print(GetCoinTextureString(copperDonationAmount))                   
                end     
        end)            


        -- Donate button        
        formattedAmount = GetCoinTextureString(donationAmount)
        GuildDonation.donateBtn = CreateFrame("Button", nil, GuildDonation, "GameMenuButtonTemplate");
        GuildDonation.donateBtn:SetPoint("CENTER", GuildDonation, "BOTTOM", 0, 40);
        GuildDonation.donateBtn:SetSize(150, 50);
        GuildDonation.donateBtn:SetText("Donate");
        GuildDonation.donateBtn:SetNormalFontObject("GameFontNormal");
        GuildDonation.donateBtn:SetHighlightFontObject("GameFontHighlight");        
        GuildDonation.donateBtn:SetScript("OnClick", function(self, arg1)
            print(MoneySinceLastVisited)
            donationAmount = goldDonationAmount + silverDonationAmount + copperDonationAmount
            print (donationAmount)
            DepositGuildBankMoney(donationAmount)
            MoneySinceLastVisited = 1            
            print(string.format("%s, %s, %s", "Donated ", formattedAmount, "to guildbank"))
            GuildDonation:Hide()
        end)
        GuildDonation:Show()
    end

    function calculateDonationAmount(MoneySinceLastVisited)
        if (MoneySinceLastVisited == nil) then return 1 end 
        amountToDonate =  math.floor(MoneySinceLastVisited * 0.1)
        if (amountToDonate < 1) then return 1 
            else 
                return amountToDonate
            end
    end

    if event == "PLAYER_MONEY" then
        print(MoneySinceLastVisited)

        if lastGetMoneyEvent < GetMoney() and lastGetMoneyEvent > 0 then
         goldDiff = GetMoney() - lastGetMoneyEvent
         MoneySinceLastVisited = MoneySinceLastVisited + goldDiff
         print("Money since last donation")
         print(GetCoinTextureString(MoneySinceLastVisited))
         print("10% of money since last donation")
         print(GetCoinTextureString(calculateDonationAmount(MoneySinceLastVisited)))
         print("Money looted:")
         print(GetCoinTextureString(GetMoney() - lastGetMoneyEvent))
        end 
        print("Current amount of money:")    
        print(GetCoinTextureString(GetMoney()))
        lastGetMoneyEvent = GetMoney()
        
    end
end

frame:SetScript("OnEvent", eventHandler);