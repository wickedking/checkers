--used to display and save high scores. 

json = require("json")
-- Function to save a table.&nbsp; Since game settings need to be saved from session to session, we will
-- use the Documents Directory

highScore = {}

function createTable()
	highScore.score1 = 0
	--highScore.score2 = 2
	--highScore.score3 = 0
	--highScore.score4 = 0
	--highScore.score5 = 0
	--highScore.score6 = 0
	--highScore.score7 = 0
	--highScore.score8 = 0
	--highScore.score9 = 0
	--highScore.score10 = 0
end

function saveFile()
	saveTable(highScore, "highScores.json")
end

function loadFile()
	highScore = loadTable("highScores.json")
end


--Code and idea was used from http://omnigeek.robmiracle.com/2012/02/23/need-to-save-your-game-data-in-corona-sdk-check-out-this-little-bit-of-code/
	
function saveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end
	
function loadTable(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         myTable = json.decode(contents);
         io.close( file )
         return myTable 
    end
    return nil	
end

function insertScore(score)
	for i = 1, 10 do
		highScore.score7 = score
		--loop through and assign new location
	end
end