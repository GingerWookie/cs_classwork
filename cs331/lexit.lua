-- lexit.lua
-- Dylan Tucker
-- CS 331

local lexit = {}



--Public Constraints--

lexit.KEY = 1
lexit.ID = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP = 5
lexit.PUNCT = 6
lexit.MAL = 7

lexit.catnames = {
	"Keyword",
	"Identifier",
	"NumericLiteral",
	"StringLiteral",
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
		or c == "\f" 
		or c == "\v" then
		return true
	else
		return false
	end
end

local function isIllegal(c)
	if c:len() ~= 1 then
		return false
	elseif isWhitespace(c) then
		return false
	elseif c >= " " and c <= "~" then
		return false
	else 
		return true
	end
end

local preferOpFlag = false

function lexit.preferOp()
	preferOpFlag = true
end

--THE LEXER

function lexit.lex(program)

-- Variables --
	local pos
	local state
	local ch
	local lexstr
	local category
	local handlers
-- States --
	local DONE = 0
	local START = 1
	local LETTER = 2
	local DIGIT = 3
	local EDIGIT = 4
	local EDIGITPLUS = 5
	local PLUSMINUS = 6
	local SINGLEQUOTES = 7
	local DOUBLEQUOTES = 8
	local OPERA = 9


	-- Utility Functions --


	local function currChar()
		return program:sub(pos, pos)
	end

	local function nextChar()
		return program:sub(pos+1, pos+1)
	end

	local function nextNextChar()
		return program:sub(pos+2, pos+2)
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

			if currChar() ~= "#" then
				break
			end
			dropOne()

			while true do
				if currChar() == "\n" then
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
			category = lexit.MAL
		elseif isLetter(ch) or ch == "_" then
			addOne()
			state = LETTER
		elseif isDigit(ch) then
			addOne()
			state = DIGIT
		elseif ch == "+" or ch == "-" then
			addOne()
			state = PLUSMINUS
		elseif ch == "\'" then
			addOne()
			state = SINGLEQUOTES
		elseif ch == "\"" then
			addOne()
			state = DOUBLEQUOTES
		elseif ch == "=" or ch == "!" or ch == "<" or ch == ">" then
			addOne()
			state = OPERA
		elseif ch == "*" or ch == "/" or ch == "%" or ch == "[" or ch == "]" or ch == ";" then
			addOne()
			state = DONE
			category = lexit.OP
		elseif ch == "&" and nextChar() == "&" then
			addOne()
			addOne()
			state = DONE
			category = lexit.OP
		elseif ch == "|" and nextChar() == "|" then
			addOne()
			addOne()
			state = DONE
			category = lexit.OP
		else 
			addOne()
			state = DONE
			category = lexit.PUNCT
		end		
	end

	local function handle_LETTER()
		if isLetter(ch) or isDigit(ch) or ch == "_" then
			addOne()
		else
			state = DONE
			if lexstr == "call" 
			or lexstr == "cr" 
			or lexstr == "else" 
			or lexstr == "elseif" 
			or lexstr == "end"
			or lexstr == "false"
			or lexstr == "func"
			or lexstr == "if"
			or lexstr == "input"
			or lexstr == "print"
			or lexstr == "true"
			or lexstr == "while" then
				category = lexit.KEY
			else
				category = lexit.ID
			end
		end
	end

	local function handle_DIGIT()
		if isDigit(ch) then
			addOne()
		elseif (ch == "e" or ch == "E") and isDigit(nextChar()) then
			addOne()
			state = EDIGIT
		elseif (ch == "e" or ch == "E") and nextChar() == "+" and isDigit(nextNextChar()) then
			addOne()
			addOne()
			state = EDIGIT
		else
			state = DONE
			category = lexit.NUMLIT
		end
	end

	local function handle_EDIGIT()
		if isDigit(ch) then
			addOne()
		else
			state = DONE
			category = lexit.NUMLIT
		end
	end

	local function handle_EDIGITPLUS()
		if isDigit(nextChar()) then
			addOne()
			addOne()
		else
			state = DONE
			category = lexit.NUMLIT
		end
	end

	local function handle_PLUSMINUS()
		if preferOpFlag then
			state = DONE
			category = lexit.OP
		elseif isDigit(ch) then
			addOne()
			state = DIGIT
		else
			state = DONE
			category = lexit.OP
		end
	end

	local function handle_SINGLEQUOTES()
		if ch == "\n" or ch == "" then
			addOne()
			state = DONE
			category = lexit.MAL
		elseif ch == "\'" then
			addOne()
			state = DONE
			category = lexit.STRLIT
		else
			addOne()
		end
	end

	local function handle_DOUBLEQUOTES()
		if ch == "\n" or ch == "" then
			addOne()
			state = DONE
			category = lexit.MAL
		elseif ch == "\"" then
			addOne()
			state = DONE
			category = lexit.STRLIT
		else
			addOne()
		end
	end

	local function handle_OPERA()
		if ch == "=" then
			addOne()
			state = DONE
			category = lexit.OP
		else
			state = DONE
			category = lexit.OP
		end
	end



	handlers = {
	[DONE] = handle_DONE,
	[START] = handle_START,
	[LETTER] = handle_LETTER,
	[DIGIT] = handle_DIGIT,
	[EDIGIT] = handle_EDIGIT,
	[EDIGITPLUS] = handle_EDIGITPLUS,
	[PLUSMINUS] = handle_PLUSMINUS,
	[SINGLEQUOTES] = handle_SINGLEQUOTES,
	[DOUBLEQUOTES] = handle_DOUBLEQUOTES,
	[OPERA] = handle_OPERA,
	}

	local function getLexeme (dummy1, dummy2)
		if pos > program:len() then
			preferOpFlag = false
			return nil, nil
		end
		lexstr = ""
		state = START
		while state ~= DONE do
			ch = currChar()
			handlers[state]()
		end

		skipWhitespace()
		preferOpFlag = false
		return lexstr, category
	end

	pos = 1
	skipWhitespace()
	return getLexeme, nil, nil
end		



return lexit