-- Dylan Tucker
-- CS331
-- Using starting given by Dr. Chappell

local interpit = {}


-- ***** Variables *****


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


-- ***** Utility Functions *****


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    assert(type(s) == "string")

    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return numToInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    assert(type(n) == "number")

    return ""..n
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end


-- astToStr
-- Given an AST, produce a string holding the AST in (roughly) Lua form,
-- with numbers replaced by names of symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
--
-- THIS FUNCTION IS INTENDED FOR USE IN DEBUGGING ONLY!
-- IT SHOULD NOT BE CALLED IN THE FINAL VERSION OF THE CODE.
function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "INPUT_STMT", "PRINT_STMT", "FUNC_STMT",
        "CALL_FUNC", "IF_STMT", "WHILE_STMT", "ASSN_STMT", "CR_OUT",
        "STRLIT_OUT", "BIN_OP", "UN_OP", "NUMLIT_VAL", "BOOLLIT_VAL",
        "SIMPLE_VAR", "ARRAY_VAR"
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end


-- ***** Primary Function for Client Code *****


function interpit.interp(ast, state, incall, outcall)


    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end


    function interp_stmt(ast)
        local name, body, str, indx, val

        if ast[1] == INPUT_STMT then
            name, str, indx = process_lvalue(ast[2])
            body = strToNum(incall())
            set_lvalue(name, str, indx, body)
        elseif ast[1] == PRINT_STMT then
            for i = 2, #ast do
                if ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == STRLIT_OUT then
                    str = ast[i][2]
                    outcall(str:sub(2,str:len()-1))  
                else
                    val = eval_expr(ast[i])
                    str = numToStr(val)
                    outcall(str)
                end
            end
        elseif ast[1] == FUNC_STMT then
            name = ast[2]
            body = ast[3]
            state.f[name] = body
        elseif ast[1] == CALL_FUNC then
            name = ast[2]
            body = state.f[name]
            if body == nil then
                body = { STMT_LIST }  
            end
            interp_stmt_list(body)
        elseif ast[1] == IF_STMT then
            val = eval_expr(ast[2])
            if val ~= 0 then
                body = ast[3]
            end
            -- local i = 4
            -- while val == 0 do
                
            --     if ast[i][1] == STMT_LIST then
            --         break
            --     end
            --     val = eval_expr(ast[i])
            --     if val ~= 0 then
            --         body = ast[i+1]
            --         break
            --     end
            --     i = i + 2
            -- end
            -- if val == 0 and ast[i][1] == STMT_LIST then
            --     body = ast[i]
            -- end
            if val ~= 0 then
            interp_stmt_list(body)
            end
        elseif ast[1] == WHILE_STMT then
            val = eval_expr(ast[2])
            body = ast[3]
            while val ~= 0 do 
                val = eval_expr(ast[2])
                body = ast[3]
                interp_stmt_list(body)
            end
        else
            assert(ast[1] == ASSN_STMT)
            name, str, indx = process_lvalue(ast[2])
            val = eval_expr(ast[3])
            if val == nil then
                val = 0
            end
            set_lvalue(name, str, indx, val)
        end
    end

    function eval_expr(ast)
        local name, typ, indx, val
        if ast[1] == NUMLIT_VAL then
            val = strToNum(ast[2]) 
            return val
        elseif ast[1] == SIMPLE_VAR then
            name, typ, indx = process_lvalue(ast)
            val = get_lvalue(name, typ, indx)
            if val == nil then
                val = 0
            end
            return val
        elseif ast[1] == ARRAY_VAR then
            name, typ, indx = process_lvalue(ast)
            val = get_lvalue(name, typ, indx)
            if val == nil then
                val = 0
            end
            return val 
        elseif ast[1] == BOOLLIT_VAL then
            if ast[2] == "true" then
                val = 1
            else 
                val = 0
            end

            return val
        elseif ast[1] == CALL_FUNC then
            interp_stmt(ast)
            return 
        else 
            assert(type(ast[1]) == "table")
            if ast[1][1] == UN_OP then
                if ast[1][2] == "-" then
                    val = -eval_expr(ast[2])
                    return val
                elseif ast[1][2] == "+"  then
                    val = eval_expr(ast[2])
                    return val
                elseif ast[1][2] == "!" then
                    val = not eval_expr(ast[2])
                    return boolToInt(val)
                end
            elseif ast[1][1] == BIN_OP then
                if ast[1][2] == "&&" then
                    val = eval_expr(ast[2]) and eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  "||" then
                    val = eval_expr(ast[2]) or eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  "!=" then
                    val = eval_expr(ast[2]) ~= eval_expr(ast[3])
                    return boolToInt(val)                
                elseif ast[1][2] ==  "==" then
                    val = eval_expr(ast[2]) == eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  "<" then
                    val = eval_expr(ast[2]) < eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  "<=" then
                    val = eval_expr(ast[2]) <= eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  ">" then
                    val = eval_expr(ast[2]) > eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  ">=" then
                    val = eval_expr(ast[2]) >= eval_expr(ast[3])
                    return boolToInt(val)
                elseif ast[1][2] ==  "+" then
                    val = eval_expr(ast[2]) + eval_expr(ast[3])
                    return numToInt(val)               
                elseif ast[1][2] ==  "-" then
                    val = eval_expr(ast[2]) - eval_expr(ast[3])
                    return numToInt(val)
                elseif ast[1][2] ==  "*" then
                    val = eval_expr(ast[2]) * eval_expr(ast[3])
                    return numToInt(val)
                elseif ast[1][2] ==  "/" then
                    if eval_expr(ast[3]) == 0 then
                        return 0
                    end
                    val = eval_expr(ast[2]) / eval_expr(ast[3])
                    return numToInt(val)
                elseif ast[1][2] ==  "%" then
                    if eval_expr(ast[3]) == 0 then
                        return 0
                    end
                    val = eval_expr(ast[2]) % eval_expr(ast[3])
                    return numToInt(val)
                end
            end
        end
    end

    function process_lvalue(ast)
        local name, typ, indx
        if ast[1] == SIMPLE_VAR then
            name = ast[2]
            typ = ast[1]
            indx = 0
            return name, typ, indx
        else
            assert(ast[1] == ARRAY_VAR)
            name = ast[2]
            typ = ast[1]
            indx = eval_expr(ast[3])
            return name, typ, indx
        end
    end

    function get_lvalue(name, typ, indx)
        if typ == SIMPLE_VAR then
            return state.v[name]
        else 
            if (state.a[name][indx]==nil) then
                return state.a[name][indx]
            end
            return 0
        end
    end

    function set_lvalue(name, typ, indx, val)
        if typ == SIMPLE_VAR then
            state.v[name] = val
        else
            state.a[name] = {}
            state.a[name][indx] = val
        end
    end

    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit