local rules = {}

rules.active_rules = {}
rules.current_hand = 1

rules.rule_types = {
    suit = {
        name = "Disallow Suit",
        description = "Hands cannot contain specified suit",
        icon = "S",
        color = {1, 0.3, 0.3}
    },
    rank = {
        name = "Disallow Rank", 
        description = "Hands cannot contain specified rank",
        icon = "R",
        color = {0.3, 0.5, 1}
    },
    mix = {
        name = "Disallow Mix",
        description = "Hands cannot contain both specified suits",
        icon = "M",
        color = {1, 0.3, 1}
    },
    gold = {
        name = "Gold Rule",
        description = "Specified rank overrides all other rules",
        icon = "G",
        color = {1, 0.8, 0.2}
    }
}

function rules.load()
    rules.active_rules = {}
    rules.current_hand = 1
end

function rules.reset()
    rules.active_rules = {}
    rules.current_hand = 1
end

function rules.reset_hand()
    rules.current_hand = rules.current_hand + 1
    
    for i = #rules.active_rules, 1, -1 do
        local rule = rules.active_rules[i]
        if rule.type == "gold" and rule.applied_hand and rules.current_hand > rule.applied_hand + 1 then
            table.remove(rules.active_rules, i)
        end
    end
end

function rules.apply_rule(rule_type, value)
    if not rules.rule_types[rule_type] then
        return false, "Invalid rule type"
    end
    
    for _, rule in ipairs(rules.active_rules) do
        local same_rule = false
        
        if rule.type == rule_type then
            if rule_type == "mix" then
                if type(rule.value) == "table" and type(value) == "table" and
                   #rule.value == #value and #value == 2 then
                    same_rule = (rule.value[1] == value[1] and rule.value[2] == value[2]) or
                               (rule.value[1] == value[2] and rule.value[2] == value[1])
                end
            else
                same_rule = (rule.value == value)
            end
        end
        
        if same_rule then
            return false, "Rule already applied"
        end
    end
    
    local new_rule = {
        type = rule_type,
        value = value,
        description = rules.get_rule_description(rule_type, value),
        color = rules.rule_types[rule_type].color,
        icon = rules.rule_types[rule_type].icon
    }
    
    if rule_type == "gold" then
        new_rule.applied_hand = rules.current_hand
    end
    
    table.insert(rules.active_rules, new_rule)
    return true, new_rule.description
end

function rules.get_rule_description(rule_type, value)
    local rule_def = rules.rule_types[rule_type]
    if not rule_def then
        return "Unknown rule"
    end
    
    if rule_type == "suit" then
        if value == "hearts" then
            return "Hearts not allowed"
        elseif value == "diamonds" then
            return "Diamonds not allowed"
        elseif value == "clubs" then
            return "Clubs not allowed"
        elseif value == "spades" then
            return "Spades not allowed"
        else
            return value:gsub("^%l", string.upper) .. " not allowed"
        end
    elseif rule_type == "rank" then
        return value .. " cards not allowed"
    elseif rule_type == "mix" then
        -- For mix rules, value is an array of suits
        if type(value) == "table" and #value == 2 then
            local suit1 = value[1]:gsub("^%l", string.upper)
            local suit2 = value[2]:gsub("^%l", string.upper)
            return "Cannot mix " .. suit1 .. " and " .. suit2
        else
            return "Invalid mix rule"
        end
    elseif rule_type == "gold" then
        return value .. " cards override all rules"
    end
    
    return rule_def.description
end

function rules.validate_hand(hand)
    local violations = {}
    
    for _, rule in ipairs(rules.active_rules) do
        if rule.type == "suit" then
            for _, card in ipairs(hand) do
                if card.suit == rule.value then
                    table.insert(violations, {
                        rule = rule,
                        card = card,
                        description = card.rank .. " of " .. card.suit .. " violates rule"
                    })
                end
            end
        elseif rule.type == "rank" then
            for _, card in ipairs(hand) do
                if card.rank == rule.value then
                    table.insert(violations, {
                        rule = rule,
                        card = card,
                        description = card.rank .. " of " .. card.suit .. " violates rule"
                    })
                end
            end
        elseif rule.type == "mix" then
            if type(rule.value) == "table" and #rule.value == 2 then
                local has_suit1, has_suit2 = false, false
                
                for _, card in ipairs(hand) do
                    if card.suit == rule.value[1] then has_suit1 = true
                    elseif card.suit == rule.value[2] then has_suit2 = true end
                end
                
                if has_suit1 and has_suit2 then
                    table.insert(violations, {
                        rule = rule,
                        card = nil,
                        description = "Hand mixes " .. rule.value[1] .. " and " .. rule.value[2]
                    })
                end
            end
        elseif rule.type == "gold" then
            local has_gold_rank = false
            for _, card in ipairs(hand) do
                if card.rank == rule.value then
                    has_gold_rank = true
                    break
                end
            end
            
            if has_gold_rank then
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

function rules.has_gold_protection(hand)
    for _, rule in ipairs(rules.active_rules) do
        if rule.type == "gold" then
            for _, card in ipairs(hand) do
                if card.rank == rule.value then
                    return true
                end
            end
        end
    end
    return false
end

function rules.has_violations_without_gold(hand)
    local violations = {}
    
    for _, rule in ipairs(rules.active_rules) do
        if rule.type == "suit" then
            for _, card in ipairs(hand) do
                if card.suit == rule.value then
                    table.insert(violations, {rule = rule, card = card})
                end
            end
        elseif rule.type == "rank" then
            for _, card in ipairs(hand) do
                if card.rank == rule.value then
                    table.insert(violations, {rule = rule, card = card})
                end
            end
        elseif rule.type == "mix" then
            if type(rule.value) == "table" and #rule.value == 2 then
                local has_suit1, has_suit2 = false, false
                
                for _, card in ipairs(hand) do
                    if card.suit == rule.value[1] then has_suit1 = true
                    elseif card.suit == rule.value[2] then has_suit2 = true end
                end
                
                if has_suit1 and has_suit2 then
                    table.insert(violations, {rule = rule, card = nil})
                end
            end
        end
    end
    
    return #violations > 0
end

return rules
