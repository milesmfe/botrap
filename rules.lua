-- Rules Engine - Game rules and validation system

local rules = {}

-- Active rules for current hand
rules.active_rules = {}
rules.current_hand = 1 -- Track current hand for gold rule expiration

-- Rule definitions with colorful icons
rules.rule_types = {
    suit = {
        name = "Disallow Suit",
        description = "No cards of specified suit allowed",
        icon = "S",
        color = {1, 0.3, 0.3}
    },
    rank = {
        name = "Disallow Rank", 
        description = "No cards of specified rank allowed",
        icon = "R",
        color = {0.3, 0.5, 1}
    },
    mix = {
        name = "Disallow Mix",
        description = "No cards matching both suit and rank",
        icon = "M",
        color = {1, 0.3, 1}
    },
    gold = {
        name = "Gold Rule",
        description = "Special advanced rule",
        icon = "G",
        color = {1, 0.8, 0.2}
    }
}

function rules.load()
    -- Initialize rules system
    rules.active_rules = {}
    rules.current_hand = 1
    print("Rules engine loaded")
end

function rules.reset()
    rules.active_rules = {}
    rules.current_hand = 1
    print("Rules reset for new game")
end

function rules.reset_hand()
    -- Keep rules between hands in same round, but track hand progression
    rules.current_hand = rules.current_hand + 1
    
    -- Remove expired gold rules (they only last one hand)
    for i = #rules.active_rules, 1, -1 do
        local rule = rules.active_rules[i]
        if rule.type == "gold" and rule.applied_hand and rules.current_hand > rule.applied_hand + 1 then
            table.remove(rules.active_rules, i)
            print("Gold rule expired after hand " .. rule.applied_hand)
        end
    end
end

function rules.apply_rule(rule_type, value)
    -- Validate rule application
    if not rules.rule_types[rule_type] then
        return false, "Invalid rule type"
    end
    
    -- Check if rule already exists
    for _, rule in ipairs(rules.active_rules) do
        local same_rule = false
        
        if rule.type == rule_type then
            if rule_type == "mix" then
                -- For mix rules, compare arrays
                if type(rule.value) == "table" and type(value) == "table" and
                   #rule.value == #value and #value == 2 then
                    same_rule = (rule.value[1] == value[1] and rule.value[2] == value[2]) or
                               (rule.value[1] == value[2] and rule.value[2] == value[1])
                end
            else
                -- For other rules, simple comparison
                same_rule = (rule.value == value)
            end
        end
        
        if same_rule then
            return false, "Rule already applied"
        end
    end
    
    -- Apply the rule
    local new_rule = {
        type = rule_type,
        value = value,
        description = rules.get_rule_description(rule_type, value),
        color = rules.rule_types[rule_type].color,
        icon = rules.rule_types[rule_type].icon
    }
    
    -- Track when gold rules are applied for expiration
    if rule_type == "gold" then
        new_rule.applied_hand = rules.current_hand
    end
    
    table.insert(rules.active_rules, new_rule)
    
    print("Applied rule: " .. new_rule.description)
    return true, new_rule.description
end

function rules.get_rule_description(rule_type, value)
    local rule_def = rules.rule_types[rule_type]
    if not rule_def then
        return "Unknown rule"
    end
    
    if rule_type == "suit" then
        return "No " .. value .. " cards allowed"
    elseif rule_type == "rank" then
        return "No " .. value .. " cards allowed"
    elseif rule_type == "mix" then
        -- For mix rules, value is an array of suits
        if type(value) == "table" and #value == 2 then
            return "No hands with both " .. value[1] .. " and " .. value[2] .. " suits"
        else
            return "Invalid mix rule"
        end
    elseif rule_type == "gold" then
        return "Gold rule: " .. value .. " overrides all rules"
    end
    
    return rule_def.description
end

function rules.validate_hand(hand)
    local violations = {}
    
    -- Check each active rule against the hand
    for _, rule in ipairs(rules.active_rules) do
        if rule.type == "suit" then
            -- Check if hand contains any cards of disallowed suit
            for _, card in ipairs(hand) do
                if card.suit == rule.value then
                    table.insert(violations, {
                        rule = rule,
                        card = card,
                        description = "Card " .. card.rank .. " of " .. card.suit .. " violates: " .. rule.description
                    })
                end
            end
        elseif rule.type == "rank" then
            -- Check if hand contains any cards of disallowed rank
            for _, card in ipairs(hand) do
                if card.rank == rule.value then
                    table.insert(violations, {
                        rule = rule,
                        card = card,
                        description = "Card " .. card.rank .. " of " .. card.suit .. " violates: " .. rule.description
                    })
                end
            end
        elseif rule.type == "mix" then
            -- Check if hand contains cards of both disallowed suits
            if type(rule.value) == "table" and #rule.value == 2 then
                local has_suit1 = false
                local has_suit2 = false
                
                for _, card in ipairs(hand) do
                    if card.suit == rule.value[1] then
                        has_suit1 = true
                    elseif card.suit == rule.value[2] then
                        has_suit2 = true
                    end
                end
                
                if has_suit1 and has_suit2 then
                    table.insert(violations, {
                        rule = rule,
                        card = nil, -- This violates the entire hand, not a specific card
                        description = "Hand contains both " .. rule.value[1] .. " and " .. rule.value[2] .. " suits"
                    })
                end
            end
        elseif rule.type == "gold" then
            -- Gold rule overrides other violations for hands containing the gold rank
            local has_gold_rank = false
            for _, card in ipairs(hand) do
                if card.rank == rule.value then
                    has_gold_rank = true
                    break
                end
            end
            
            if has_gold_rank then
                -- Remove all previous violations - gold rule overrides
                violations = {}
                break
            end
        end
    end
    
    return #violations == 0, violations
end

function rules.get_active_rules()
    return rules.active_rules
end

function rules.get_rule_types()
    return rules.rule_types
end

function rules.get_available_suits()
    return {"hearts", "diamonds", "clubs", "spades"}
end

function rules.get_available_ranks()
    return {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
end

-- Helper function to get a random rule for testing
function rules.get_random_suit_rule()
    local suits = rules.get_available_suits()
    return suits[math.random(#suits)]
end

function rules.get_random_rank_rule()
    local ranks = rules.get_available_ranks()
    return ranks[math.random(#ranks)]
end

return rules
