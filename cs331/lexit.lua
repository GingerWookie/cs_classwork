-- lexit.lua
-- Dylan Tucker
-- CS 331

local lexer = {}



--Public Constraints--

lexer.KEY = 1
lexer.ID = 2
lexer.NUMLIT = 3
lexer.OP = 4
lexer.PUNCT = 5
lexer.MAL = 6

lexer.catnames = {
	"Keyword",
	"Identifier",
	"NumericLiteral",
	"Operator",
	"Punctuation",
	"Malformed"
}

local function isLetter(c)
	if c:len() ~= 1 then
		return false
	elseif c >= "A" and c <= "Z" then
		return true
	elseif c >= "a" and c <= "z" then
		return true
	else 
		return false
	end
end

local function isDigit(c)
	if c:len() ~= 1 then
		return false
	elseif c >= "0" and c <= "9" then
		return true
	else 
		return false
	end
end

local function isWhitespace(c)
	if c:len() ~= 1 then
		return false
	elseif c == " " 
		or c == "\t" 
		or c == "\n" 
		or c == "\r" 
		or c == "\f" then
		return true
	else
		return false
	end
end

local function isIllegal( c )
	if c:len ~= 1 then
		return false
	elseif isWhitespace(c) then
		return false
	elseif c >= " " and c <= "~" then
		return false
	else 
		return true
	end
end


function lexer.lex(program)

-- Variables --
	local pos
	local state
	local lexstr
	local category
	local handlers

-- States --
	local DONE = 0
	local START = 1
	local LETTER = 2
	local DIGIT = 3


-- Utility Functions --
local function currChar()
	return program:sub(pos, pos)
end

local function nextChar()
	return program:sub(pos+1, pos+1)
end

local function dropOne()
	pos = pos + 1
end

local function addOne()
	lexstr = lexstr .. currChar()
	dropOne()
end

local function skipWhitespace()
	while true do
		while isWhitespace(currChar()) do
			dropOne()
		end

		if currChar() ~= "/" or nextChar() ~= "*" then
			break
		end
		dropOne()
		dropOne()

		while true do
			if currChar() == "*" and nextChar() == "/" then
				dropOne()
				dropOne()
				break
			elseif currChar() == "" then
				return
			end
			dropOne()
		end
	end
end

local function handle_DONE()
	io.write("ERROR: 'DONE' state should not be handled\n")
	assert(0)
end

local function handle_START()
	if isIllegal(ch) then
		addOne()
		state = DONE
		category = lexer.MAL
	elseif isLetter(ch) or ch == "_" then
		addOne()
		state = LETTER
	elseif isDigit(ch) then
		addOne()
		state = DIGIT
	elseif ch = "+" then
		addOne()
		state = PLUS
	elseif ch == "-" then
		addOne()
		state = MINUS
	elseif == "*" or ch == "/" or ch == "=" then
		addOne()
		state = STAR
	elseif == "." then
		addOne()
		state = DOT
	else 
		addOne()
		state = DONE
		category = lexer.PUNCT
	end		
end

local function handle_LETTER()
	if isLetter(ch) or isDigit(ch) or ch == "_" then
		addOne()
	else
		state = DONE
		if lexstr == "begin" or lexstr == "end" or lexstr == "print" then
			category = lexer.KEY
		else
			category = lexer.ID
		end
	end
end

local function handle_DIGIT()
	if isDigit(ch) then
		addOne()
	elseif ch == "." then
		addOne()
		state = DIGDOT
	else 
		state = DONE
		category = lexer.NUMLIT
	end
end

local function handle_DIGDOT()
	if isDigit(ch) then
		addOne()
	else
		state = DONE
		category = lexer.NUMLIT
	end
end

local function handle_PLUS()
	if isDigit(ch) then
		addOne()
		state = DIGIT
	elseif ch == "+" or ch == "=" then
		addOne()
		state = DONE
		category = lexer.OP
	elseif ch == "." then		
		if isDigit(nextChar()) then
			addOne()
			addOne()
			state = DIGDOT
		else
			state = DONE
			category = lexer.OP
		end
		
end		