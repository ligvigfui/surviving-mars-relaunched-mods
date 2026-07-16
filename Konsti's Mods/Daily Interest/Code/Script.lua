local max_limit = 80000000000
local min_limit = -80000000000
local interest_rate = 0.01

local function UpdateInterestRate()
    local options = CurrentModOptions
    if not options then return end
    
    interest_rate = options.Interestrate / 100
end


PlaceObj('NotificationPreset', {
    Expiration = 60000,
    FxAction = "UINotificationFunding",
    GameTime = false,
    Image = "UI/IconsRemaster/Notifications/funding.png",
    NotificationTemplate = "NotificationImportant",
    Title = T(799081322513, "FundingLost"),
    group = "Default",
    id = "FundingLost",
})

local function CheckLimit(UIColony)
    local current_funding = UIColony.funds.funding
    
    if current_funding > max_limit then
        UIColony.funds:ChangeFunding(max_limit - current_funding)
    elseif current_funding < min_limit then
        UIColony.funds:ChangeFunding(min_limit - current_funding)
    end
end

local function addInterest(UIColony)
    local current_funding = UIColony.funds.funding
    local actual_interest = math.floor(current_funding * interest_rate)
    local display_interest = math.floor(actual_interest / 1000000)

    if actual_interest == 0 then return end
    
    UIColony.funds:ChangeFunding(actual_interest)

    CreateGameTimeThread(function()
        if actual_interest > 0 then
            AddOnScreenNotification("FundingReceived", nil, {
                title = T(302535920011336, "Daily Interest"),
                override_text = T{302535920011384, "You've received: <amount> M", amount = display_interest},
                expiration = 720000
            })
        elseif actual_interest < 0 then
            AddOnScreenNotification("FundingLost", nil, {
                title = T(812499102341, "Debt Overdraft"), 
                override_text = T{812499102342, "Interest charged: <amount> M", amount = math.abs(display_interest) },
                expiration = 720000
            })
        end
    end)
end

function OnMsg.NewDay()
    if not UIColony or not UIColony.funds then return end
    addInterest(UIColony)
    CheckLimit(UIColony)
end

local function StartupCode()
    UpdateInterestRate()
    if not UIColony or not UIColony.funds then return end
    CheckLimit(UIColony)
end

function OnMsg.ApplyModOptions(id)
    UpdateInterestRate()
end

OnMsg.CityStart = StartupCode
OnMsg.LoadGame = StartupCode