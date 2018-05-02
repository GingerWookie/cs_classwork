
local parseit = {}

lexit = require "lexit"
-- Variables

local iter
local state
local lexer_out_str
local lexer_out_cat

local lexstr = ""
local lexcat = 0


-- Symbolic Constants for AST

local STMT_LIST   = 1
local INPUT_STMT  = 2
local PRINT_STMT  = 3
local FUNC_STMT   = 4
local CALL_FUNC   = 5
local IF_STMT     = 6
local WHILE_STMT  = 7
local ASSN_STMT   = 8
local CR_OUT      = 9
local STRLIT_OUT  = 10
local BIN_OP      = 11
local UN_OP       = 12
local NUMLIT_VAL  = 13
local BOOLLIT_VAL = 14
local SIMPLE_VAR  = 15
local ARRAY_VAR   = 16

-- Utility Functions

-- advance
-- Next Lexeme
local function advance()
    lexer_out_str, lexer_out_cat = iter(state, lexer_out_str)
    
    if lexer_out_str ~= nil then
        lexstr, lexcat = lexer_out_str, lexer_out_cat
    else
        lexstr, lexcat = "", 0
    end

    if lexcat == lexit.ID 
        or lexcat == lexit.NUMLIT 
        or lexstr == "]"
        or lexstr == ")"
        or lexstr == "true"
        or lexstr == "false" then

        lexit.preferOp()
    end
end        

-- inti
-- Sets input
-- MUST BE CALLED BEFORE PARSEING FUNCTIONS
local function init(prog)
    iter, state, lexer_out_str = lexit.lex(prog)
    advance()
end

-- atEnd
-- True if at end of input
local function atEnd()
    return lexcat == 0
end

-- matchString
-- checks string advances if true
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end

-- matchCat
-- checks category advances if true
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end

-- Primary Parse Function

-- parse
-- Given a program
-- Returns bool, bool, AST
function parseit.parse(prog)
    init(prog)
    local good, ast = parse_program()
    local done = atEnd()

    return good, done, ast
end

-- Parsing Functions

-- parse_program
-- Parsing function for nonterminal "program".
function parse_program()
    local good, ast

    good, ast = parse_stmt_list()
    return good, ast
end


-- parse_stmt_list
-- Parsing function for nonterminal "stmt_list".
function parse_stmt_list()
    local good, ast1, ast2

    ast1 = { STMT_LIST }
    while true do
        if lexstr ~= "input"
          and lexstr ~= "print"
          and lexstr ~= "func"
          and lexstr ~= "call"
          and lexstr ~= "if"
          and lexstr ~= "while"
          and lexcat ~= lexit.ID then
            return true, ast1
        end

        good, ast2 = parse_statement()
        if not good then
            return false, nil
        end

        table.insert(ast1, ast2)
    end
end


-- parse_statement
-- Parsing function for nonterminal "statement"
function parse_statement()
    local good, ast1, ast2, savelex
  
    savelex = lexstr
  
    if matchString("input") then
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end

        return true, { INPUT_STMT, ast1 }

    elseif matchString("print") then
        good, ast1 = parse_print_arg()
        if not good then
            return false, nil
        end

        ast2 = { PRINT_STMT, ast1 }

        while true do
            if not matchString(";") then
                break
            end

            good, ast1 = parse_print_arg()
            if not good then
                return false, nil
            end

            table.insert(ast2, ast1)
        end

        return true, ast2

    elseif matchString("func") then
        
        savelex = lexstr
        if not matchCat(lexit.ID) then
            return false, nil
        end
        ast1 = {FUNC_STMT, savelex}
        
        good, ast2 = parse_stmt_list()
        if not good then
            return false, nil
        end

        table.insert(ast1, ast2)
        

        if not matchString("end") then
            return false, nil
        end

        return true, ast1

    elseif matchString("call") then
        
        savelex = lexstr
        if not matchCat(lexit.ID) then
            return false, nil
        else
            return true, {CALL_FUNC, savelex}
        end

    elseif matchString("if") then

        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end

        ast2 = {IF_STMT, ast1}

        good, ast1 = parse_stmt_list()
        if not good then
            return false, nil
        end

        table.insert(ast2, ast1)

        while true do
            if not matchString("elseif") then
                break
            end

            good, ast1 = parse_expr()
            if not good then
                return false, nil
            end

            table.insert(ast2, ast1)

            good, ast1 = parse_stmt_list()
            if not good then
                return false, nil
            end

            table.insert(ast2, ast1)
        end

        if matchString("else") then
            good, ast1 = parse_stmt_list()
            if not good then
                return false, nil
            end
            table.insert(ast2, ast1)
        end



        if not matchString("end") then
            return false, nil
        end

        return true, ast2

    elseif matchString("while") then
        
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end

        ast2 = {WHILE_STMT, ast1}

        good, ast1 = parse_stmt_list()
        if not good then
            return false, nil
        end

        table.insert(ast2, ast1)

        if not matchString("end") then
            return false, nil
        end

        return true, ast2
    
    elseif lexcat == lexit.ID then
        
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end

        ast2 = {ASSN_STMT, ast1}
        if not matchString("=") then
            return false, nil
        end
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end
        table.insert(ast2, ast1)

        return true, ast2
    end
end

-- parse_pring_arg
-- non-terminal print arg
function parse_print_arg()
    local good, ast, savelex

    savelex = lexstr

    if matchString("cr") then
        return true, {CR_OUT}
    elseif matchCat(lexit.STRLIT) then
        return true, {STRLIT_OUT, savelex}
    else
        good, ast = parse_expr()
        if not good then
            return false, nil
        end

        return true, ast
    end
end

-- parse_expr
-- non-terminal expr
function parse_expr()
    local good, ast1, ast2, savelex

    good, ast1 = parse_comp_expr()
    if not good then 
        return false, nil
    end

    while true do
        savelex = lexstr
        if not matchString("||") 
            and not matchString("&&") then
            break
        end

        good, ast2 = parse_comp_expr()
        if not good then 
            return false, nil
        end

        ast1 = {{BIN_OP, savelex}, ast1, ast2}
    end
    return true, ast1
end

-- parse_comp_expr
-- non-terminal comp_expr
function parse_comp_expr()
    local good, ast1, ast2, savelex
    savelex = lexstr

    if matchString("!") then
        good, ast1 = parse_comp_expr()
        if not good then
            return false, nil
        end
        ast2 = {{UN_OP, savelex}, ast1}
        return true, ast2
    else
        good, ast1 = parse_arith_expr()
        if not good then
            return false, nil
        end

        while true do
            savelex = lexstr
            
            if not matchString("==")
                and not matchString("!=")
                and not matchString("<")
                and not matchString("<=")
                and not matchString(">")
                and not matchString(">=") then

                break
            end

            good, ast2 = parse_arith_expr()
            if not good then
                return false, nil
            end

            ast1 = {{BIN_OP, savelex}, ast1, ast2}
        end

        return true, ast1
    end
end

-- parse_arith_expr
-- non-terminal arith_expr
function parse_arith_expr()
    local good, ast1, ast2, savelex

    good, ast1 = parse_term()
    if not good then 
        return false, nil
    end

    while true do 
        savelex = lexstr
        if not matchString("+")
            and not matchString("-") then

            break
        end

        good, ast2 = parse_term()
        if not good then
            return false, nil
        end

        ast1 = {{BIN_OP, savelex}, ast1, ast2}
    end

    return true, ast1
end

-- parse_term
-- non-terminal term
function parse_term()
    local good, ast1, ast2, savelex

    good, ast1 = parse_factor()
    if not good then
        return false, nil
    end

    while true do
        savelex = lexstr

        if not matchString("*")
            and not matchString("/")
            and not matchString("%") then

            break
        end

        good, ast2 = parse_factor()
        if not good then
            return false, nil
        end

        ast1 = {{BIN_OP, savelex}, ast1, ast2}
    end

    return true, ast1
end

-- parse_factor
-- non-terminal factor
function parse_factor()
    local good, ast1, ast2, savelex
    savelex = lexstr

    if matchString("(") then
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        return true, ast1
    elseif matchString("+") 
        or matchString("-") then
        good, ast1 = parse_factor()
        if not good then
            return false, nil
        end
        ast2 = {{UN_OP, savelex}, ast1}
        return true, ast2
    elseif matchString("call") then
        savelex = lexstr
        if not matchCat(lexit.ID) then
            return false, nil
        end
        ast1 = {CALL_FUNC, savelex}
        return true, ast1
    elseif matchCat(lexit.NUMLIT) then
        ast1 = {NUMLIT_VAL, savelex}
        return true, ast1
    elseif matchString("true") or matchString("false") then
        ast1 = {BOOLLIT_VAL, savelex}
        return true, ast1
    elseif lexcat == lexit.ID then
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end
        return true, ast1
    end
end

function parse_lvalue()
    local good, ast1, ast2, savelex
    savelex = lexstr
    
    if not matchCat(lexit.ID) then
        return false, nil
    end

    if matchString("[") then
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end
        ast2 = {ARRAY_VAR, savelex, ast1}
        if not matchString("]") then
            return false, nil
        end
        return true, ast2
    else
        ast1 = {SIMPLE_VAR, savelex}
        return true, ast1
    end
end

return parseit