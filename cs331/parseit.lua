
local parseit = {}


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
--
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end

-- matchCat
--
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
    local good, ast, newast

    ast = { STMT_LIST }
    while true do
        if lexstr ~= "input"
          and lexstr ~= "print"
          and lexstr ~= "func"
          and lexstr ~= "call"
          and lexstr ~= "if"
          and lexstr ~= "while"
          and lexcat ~= lexit.ID then
            return true, ast
        end

        good, newast = parse_statement()
        if not good then
            return false, nil
        end

        table.insert(ast, newast)
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
        else
            ast1 = {FUNC_STMT, savelex}
            
            good, ast2 = parse_stmt_list()
            if not good then
                return false, nil
            end

            table.insert(ast1, ast2)
        end

        if not matchString("end")
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

        if not matchString("else") then
            return false, nil
        end

        good, ast1 = parse_stmt_list()
        if not good then
            return false, nil
        end

        table.insert(ast2, ast1)

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
    
    elseif matchCat(lexit.ID) then
        
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end

        ast2 = {ASSN_STMT}
    end
end



return parseit