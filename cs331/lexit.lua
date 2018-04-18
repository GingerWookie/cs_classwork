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
		