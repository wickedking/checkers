-----------------------------------------------------------------------------------------
--
-- main.lua
-- Made by WickedKing1392 and ElementBox
-----------------------------------------------------------------------------------------

--Implement better garbage collection
timer.performWithDelay(1, function() collectgarbage("collect") end)

--The music options. 
options = {loop = -1}

--Global variable used for if sound effects are to be used.
soundEffects = true

--Global table used to switch and hold the different audio files.
sfx = {}
sfx.theme = audio.loadStream("theme.mp3")
sfx.level_one = audio.loadStream("level_one.mp3")
sfx.level_two = audio.loadStream("level_two.mp3")
sfx.level_three = audio.loadStream("level_three.mp3")
sfx.level_four = audio.loadStream("level_four.mp3")

--Global variable for if music is to be used.
music = true

--Global table for the background.
background = {}

clickPieceX = 0
clickPieceY = 0
clickColor = 0.2

--Reference to the current falling piece.
currentPiece = {}
--The reference to the board of the background colors
board = {}
--The reference to the board with pieces
gameboard = {}
--Flag if the game is paused
pause = false
--The group that holds all the drawn pieces.
group = {}
--The group that holds a reference to all the extra stuff on the screen.
extra_group = {}
--Used to replay the game or to exit
start_over = true
--Holds a reference to all the items when the game fails
gameOverGroup = {}

--Constants for the printing on screen. The offset for each
x_offset = 23
y_offset = 160

--the multiplier for the board values.
board_offset = 38 --need to be set at run time
height_offset = 38

--The constants for the board dimensions.
board_height = 7
board_width = 7

--A constants for printing the block sizes
block_size = 36

--A block used to block the screen when paused
pause_block = display.newRect(0,0,0,0)
--A reference to the text when paused
pause_text = {}

--The reference to the sound effect.
click = audio.loadSound("tap4.wav")

--References to the menu and listeners.
local menuScreen = {}
local tweenMS = {}
settingsScreenGroup = {}

--References to the settings buttons
soundEffectImage = {}
musicImage = {}

dark_color = 0.2
light_color = 0.6

--Used to populate the settingsScreen with all the buttons, listeners and text.
function settingsScreen()
	--TODO add controls for the pieceLines and ghostPiece

	menuScreen:removeSelf()
	audio.stop()
	settingScreenGroup = display.newGroup()

	local fillText = display.newText(settingScreenGroup, "Fill Board", display.contentWidth/5, display.contentHeight/6, native.systemFontBold, 14)
	local soundEffectText = display.newText(settingScreenGroup, "Sound Effects", display.contentWidth/5, display.contentHeight/6 * 2, native.systemFontBold, 14)
	local musicText = display.newText(settingScreenGroup, "music", display.contentWidth/5, display.contentHeight/6 * 3, native.systemFontBold, 14)
	local controlText = display.newText(settingScreenGroup, "Control: On for Tap", display.contentWidth/5, display.contentHeight/6 * 4, native.systemFontBold, 14)
	
	local backText = display.newText(settingScreenGroup, "Main Menu", display.contentWidth/2, display.contentHeight/6 * 5, native.systemFontBold, 14)
	
	--Used to create the correct button depending on the value of the corresponding flags.
	if fillBoard == true then
		fillImage = display.newImage("on_button.png")
	else 
		fillImage = display.newImage("off_button.png")
	end
	if soundEffects == true then
		soundEffectImage = display.newImage("on_button.png")
	else 
		soundEffectImage = display.newImage("off_button.png")
	end
	if music == true then
		musicImage = display.newImage("on_button.png")
	else 
		musicImage = display.newImage("off_button.png")
	end
	if tapControl == true then
		controlImage = display.newImage("on_button.png")
	else 
		controlImage = display.newImage("off_button.png")
	end
	
	--Scaling for the current image
	fillImage:scale(0.5, 0.5)
	soundEffectImage:scale(0.5, 0.5)
	musicImage:scale(0.5, 0.5)
	controlImage:scale(0.5, 0.5)
	
	-- The x values of the buttons
	fillImage.x = display.contentWidth/4 * 3
	soundEffectImage.x = display.contentWidth/4 * 3
	musicImage.x = display.contentWidth/4 * 3
	controlImage.x = display.contentWidth/4 * 3
	
	--The y values of the buttons
	fillImage.y = display.contentHeight/6
	soundEffectImage.y = display.contentHeight/6 * 2
	musicImage.y = display.contentHeight/6 * 3
	controlImage.y = display.contentHeight/6 * 4
	
	--The event listeners for the buttons	
	fillImage:addEventListener("tap", changeFill)
	soundEffectImage:addEventListener("tap", soundEffect)
	musicImage:addEventListener("tap", soundMusic)
	controlImage:addEventListener("tap", displayControl)	
	backText:addEventListener("tap", backToMenu)
	
end

--Listener method used to remove the settings Screen and go back to main menu.
function backToMenu()
	--Remove all buttons and text and recreate menu Screen.
	settingScreenGroup:removeSelf()
	settingScreenGroup = display.newGroup()
	
	fillImage:removeSelf()
	soundEffectImage:removeSelf()
	musicImage:removeSelf()
	controlImage:removeSelf()
	
	--Used to keep a blank reference, to keep other code from removing nil references.
	fillImage = display.newRect(0,0,0,0)
	soundEffectImage = display.newRect(0,0,0,0)
	musicImage = display.newRect(0,0,0,0)
	controlImage = display.newRect(0,0,0,0)
	
	addMenuScreen()

end

--Listener method used to pause and unpause the game. Stops the pieces from moving and blocks the screen.
function pauseGame()
	if pause == false then
		pause = true
		audio.pause()
		pause_block = display.newRect(0,0,1000, 1000)
		pause_block:setFillColor(0,0,0)
		pause_block:addEventListener("tap", pauseGame)
		pauseText = display.newText("PAUSED", display.contentWidth/2, display.contentHeight/2, native.systemFontBold, 18)
	else
		pause = false
		audio.play(the_music, options)
		pause_block:removeSelf()
		pauseText:removeSelf()
	end
end

--Used to randomize the color of all the blocks currently on the board.
function randomizeColor()
	for i = 0, board_height do
		for j = 0, board_width do
			if board[i][j] ~= 0 then
				board[i][j]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			end
		end
	end
end

--Deletes the references to all the blocks in the board to all deletion of blocks.
function deleteBoard()
	for i =0, board_height do
		for j = 0, board_width do
			board[i][j] = 0
		end
	end
end

--Creates the table that is the board.
function createBoard()
	local dark = true
	for i = 0, board_height do
		if dark == true then
			dark = false
		else
			dark = true
		end
		board[i] = {}
		for j = 0, board_width do
			if dark == true then
				board[i][j] = display.newRect(j * board_offset + x_offset, i * height_offset + y_offset, block_size, block_size);
				board[i][j]:setFillColor(dark_color, dark_color, dark_color)
				board[i][j]:addEventListener("tap", pieceTouch)
				dark = false
			else 
				board[i][j] = display.newRect(j * board_offset + x_offset, i * height_offset + y_offset, block_size, block_size);
				board[i][j]:setFillColor(light_color, light_color, light_color)
				board[i][j]:addEventListener("tap", pieceTouch)
				dark = true
			end
		end
	end
end

function recolorBoard()
	local dark = true
	for i = 0, board_height do
		if dark == true then
			dark = false
		else
			dark = true
		end
		board[i] = {}
		for j = 0, board_width do
			if dark == true then
				board[i][j] = display.newRect(j * board_offset + x_offset, i * height_offset + y_offset, block_size, block_size);
				board[i][j]:setFillColor(0.2, 0.2, 0.2)
				board[i][j]:addEventListener("tap", pieceTouch)
				dark = false
			else 
				board[i][j] = display.newRect(j * board_offset + x_offset, i * height_offset + y_offset, block_size, block_size);
				board[i][j]:setFillColor(0.6, 0.6, 0.6)
				board[i][j]:addEventListener("tap", pieceTouch)
				dark = true
			end
		end
	end

end

function createGameBoard()
	for i = 0, board_height do
		gameboard[i] = {}
		for j = 0, board_width do
			gameboard[i][j] = 0
		end
	end

	--red color
	local everyOther = false
	for i = 0, 2 do
		if everyOther == true then
			everyOther = false
		else
			everyOther = true
		end
		for j = 0, board_width do
			if everyOther == true then
				gameboard[i][j] = display.newCircle(j * board_offset + x_offset, i * height_offset + y_offset, block_size /2 - 3)
				gameboard[i][j]:setFillColor(0.1, 0.1, 0.1)
				everyOther = false
			else
				gameboard[i][j] = 0
				everyOther = true
			end
		end
	end
	
	--black color
	local everyOtherOne = true
	for i = 5, 7 do
		if everyOtherOne == true then
			everyOtherOne = false
		else
			everyOtherOne = true
		end
		for j = 0, board_width do
			if everyOtherOne == true then
				gameboard[i][j] = display.newCircle(j * board_offset + x_offset, i * height_offset + y_offset, block_size /2 - 3)
				gameboard[i][j]:setFillColor(0.9, 0.1, 0.1)
				everyOtherOne = false
			else
				everyOtherOne = true
			end
		end
	end
	


end

function colorGameBoard()
	for i = 0, 7 do
		for j = 0, 7 do
			board[i][j] = board[i][j]
		end
	end
end

--Listener method used to change if sound effects are to be used.
function soundEffect()
	if soundEffects then
		soundEffects = false
		soundEffectImage:removeSelf()
		soundEffectImage = display.newImage("off_button.png")
		soundEffectImage.x = display.contentWidth/4 * 3
		soundEffectImage.y = display.contentHeight/6 * 2
		soundEffectImage:scale(0.5, 0.5)
		soundEffectImage:addEventListener("tap", soundEffect)
	else
		soundEffects = true
		soundEffectImage:removeSelf()
		soundEffectImage = display.newImage("on_button.png")
		soundEffectImage.x = display.contentWidth/4 * 3
		soundEffectImage.y = display.contentHeight/6 * 2
		soundEffectImage:scale(0.5, 0.5)
		soundEffectImage:addEventListener("tap", soundEffect)
	end
end

--Listener method used to change if music is to be used.
function soundMusic()
	if music then
		music = false
		musicImage:removeSelf()
		musicImage = display.newImage("off_button.png")
		musicImage.x = display.contentWidth/4 * 3
		musicImage.y = display.contentHeight/6 * 3
		musicImage:scale(0.5, 0.5)
		musicImage:addEventListener("tap", soundMusic)
	else
		music = true
		musicImage:removeSelf()
		musicImage = display.newImage("on_button.png")
		musicImage.x = display.contentWidth/4 * 3
		musicImage.y = display.contentHeight/6 * 3
		musicImage:scale(0.5, 0.5)
		musicImage:addEventListener("tap", soundMusic)
	end
end

--Creates the main menu screen.
function addMenuScreen()
	menuScreen = display.newGroup()
	local mScreen = display.newImage("splash_other.png")
	mScreen:toBack()
	local startButton = display.newImage("start.png")
	startButton:scale( .5, .5)
	
	local settingsButton = display.newImage("settings-button.png")
	settingsButton:scale(0.13, 0.13)
	settingsButton.x = display.contentWidth/4 * 3.25
	settingsButton.y = display.contentHeight/4 * 3.70
	settingsButton:addEventListener("tap", settingsScreen)
	
	mScreen.x = display.contentWidth/2 
	mScreen.y = display.contentHeight/2
	menuScreen:insert(mScreen)
	menuScreen:insert(startButton)
	menuScreen:insert(settingsButton)
	
	startButton.name = 'startB'
	startButton.x = display.contentWidth/4
	startButton.y = display.contentHeight/4 * 3.6
	startButton:addEventListener('tap', tweenMS)
	
	if music then 
		audio.play(sfx.theme, options)
	end

end

--Listener method used to transition from the main menu to the game.
function tweenMS:tap(e)
	if (e.target.name == 'startB') then
		transition.to(menuScreen, {time = 400, y = -menuScreen.height * 2, transition = easing.outExpo, onComplete = addGameScreen})
		audio.stop()
		create()
	end
end

--Listener method used to kill the app.
function goAway()
	audio.stop()
	os.exit()
end

--Listener method used to restart the game
function recreate()
	gameOverGroup:removeSelf()
	timer.performWithDelay(1000, create, 1)
	nextPieceGroup = display.newGroup()
end

--Used to stop the game when the user fails.
function fail()
	if start_over then
		deleteBoard()
		board = {}
		pieceCreate = false
		gameOverGroup = display.newGroup()
		start_over = false
		pause = true
		
		extra_group:removeSelf()
		
		Runtime:removeEventListener("enterFrame", movePiece)

		local yes = display.newImage("yes.png")
		yes.x = display.contentWidth/4
		yes.y = (display.contentHeight/4) * 3
		yes:scale(0.4, 0.4)
		local no = display.newImage("no.png")
		no:scale(0.5, 0.5)
		no.x = (display.contentWidth/4) * 3
		no.y = (display.contentHeight/4) * 3
		
		local failed = display.newImage("fail.png")
		
		failed.x = display.contentWidth/2
		failed.y = display.contentHeight/4
		failed.name = "failed"
		
		yes.name = "yes"
		no.nmae = "no"
		
		gameOverGroup:insert(yes)
		gameOverGroup:insert(no)
		gameOverGroup:insert(failed)
		
		yes:addEventListener('tap', recreate)
		no:addEventListener('tap', goAway)
		no:addEventListener('tap', goAway)
		group:removeSelf()
		if nextPieceGroup ~= nil then
			nextPieceGroup:removeSelf()
		end
		scoreGroup:removeSelf()
		ghostGroup:removeSelf()
		--line1:removeSelf()
		--line2:removeSelf()
		pieceLines:removeSelf()
		pieceLines = display.newGroup()
		ghostGroup = display.newGroup()
		
		if totalScore > highScore.score1 then
			highScore.score1 = totalScore
			saveTable(highScore, "highScore.json")
			display.newText(gameOverGroup, "NEW HIGHSCORE!", display.contentWidth/2, display.contentHeight/2 + 30, native.systemFontBold, 16)
		end
	
		highScoreText = display.newText(gameOverGroup, "High Score: "..highScore.score1, display.contentWidth/5 * 2- 30, display.contentHeight/2, native.systemFontBold, 14)
		highScoreText:setFillColor(0,0,0)
		
		yourScoreText = display.newText(gameOverGroup, "Your Score: "..totalScore, display.contentWidth/5 * 4 - 35, display.contentHeight/2, native.systemFontBold, 14)
		yourScoreText:setFillColor(0,0,0)
		
	end
end

--Used to make the board match the screen.
function updateBoard(the_pieces)
--will be called will freezeing piece
--will create new objects on board and then display.
--will be able to keep a reference to all "destroyed" pieces
--will check rows to see if deletion is necassary
	if pause == false then

		i = math.floor(currentPiece.y/board_offset)
		j = math.floor(currentPiece.x/board_offset)
		
		--well checks are actually working at the moment. 

		if i + the_pieces.piece1y > board_height or j + the_pieces.piece1x > board_width or j + the_pieces.piece1x < 0 or i + the_pieces.piece1y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece1y][j + the_pieces.piece1x] = display.newRect((j + the_pieces.piece1x)* board_offset + x_offset, (i + the_pieces.piece1y)*board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece1y][j + the_pieces.piece1x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece1y][j + the_pieces.piece1x])
			physics.addBody(board[i + the_pieces.piece1y][j + the_pieces.piece1x], "kinematic")
		end
		
		if i + the_pieces.piece2y > board_height or j + the_pieces.piece2x > board_width or j + the_pieces.piece2x < 0 or i + the_pieces.piece2y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece2y][j + the_pieces.piece2x] = display.newRect((j + the_pieces.piece2x)* board_offset + x_offset, (i + the_pieces.piece2y)*board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece2y][j + the_pieces.piece2x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece2y][j + the_pieces.piece2x])
			physics.addBody(board[i + the_pieces.piece2y][j + the_pieces.piece2x], "kinematic")
		end
		if i + the_pieces.piece3y > board_height or j + the_pieces.piece3x > board_width  or j + the_pieces.piece3x < 0 or i + the_pieces.piece3y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece3y][j + the_pieces.piece3x] = display.newRect((j + the_pieces.piece3x)*board_offset + x_offset, (i + the_pieces.piece3y)*board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece3y][j + the_pieces.piece3x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece3y][j + the_pieces.piece3x])
			physics.addBody(board[i + the_pieces.piece3y][j + the_pieces.piece3x], "kinematic")
		end
		if i + the_pieces.piece4y > board_height or j + the_pieces.piece4x > board_width  or j + the_pieces.piece4x < 0 or i + the_pieces.piece4y < 0 then
			pause = true
			fail()
			return
		else
			board[i + the_pieces.piece4y][j + the_pieces.piece4x] = display.newRect((j + the_pieces.piece4x)* board_offset + x_offset, (i + the_pieces.piece4y)* board_offset + y_offset, block_size, block_size)
			board[i + the_pieces.piece4y][j + the_pieces.piece4x]:setFillColor(math.random(low_color, high_color) / 100 ,math.random(low_color, high_color) / 100, math.random(low_color, high_color) / 100)
			group:insert(board[i + the_pieces.piece4y][j + the_pieces.piece4x])
			physics.addBody(board[i + the_pieces.piece4y][j + the_pieces.piece4x], "kinematic")
		end
		removeRows()
	end
end

function checkMove(dx, dy)
--check to see if can move. First check within the board bounds
--then check if a piece in that location.
--then if move is greater than 1 check for possible jumping ability.

	if clickPieceX + dx < 0 or clickPieceX + dx > 7 then
		return false
	end
	if clickPieceY + dy < 0 or clickPieceY + dy > 7 then
		return false
	end
	if gameboard[clickPieceY + dy][clickPieceX + dx] ~= 0 then
		return false
	end
	local check = false
	local nx = dx
	local xy = dy
	if dx > 1 then
		check = true
		nx = dx - 1
		ny = dy - 1
	elseif dx < 1 then
		check = true
		nx = dx + 1
		ny = dy + 1 
	end 
	local jump = false
	if check == true then
		if gameboard[clickPieceY + ny][clickPieceX + nx] ~= 0 then
			return true
		end
	end
	return true
end

--Freezes the current piece updates the board and creates a new piece.
function freezePiece(freezeEvent)
	if pieceCreate == true then
		if soundEffects then
			audio.play(click)
		end
		local pieces = pieceRotation(currentPiece)
		physics.addBody(currentPiece, "static")
		currentPiece.myName = "death"
		pieceCreate = false
		randomizeColor()
		updateBoard(pieces)
		currentPiece:removeSelf()
		createPiece()
	end
end

--Listener method called when asked to move the piece left. if possible moves, if not nothing.
function moveLeft()
	if currentPiece == nil then
		return
	end
	if checkMove(-1, 0) then
		currentPiece.x = currentPiece.x - board_offset
	end
	drawPiece(pieceRotation(currentPiece))
end

--Listener method called when asked to move the piece right. if possible moves, if not nothing.
function moveRight()
	if currentPiece == nil then
		return
	end
	if checkMove(1,0) then
		currentPiece.x = currentPiece.x + board_offset
	end
	drawPiece(pieceRotation(currentPiece))
end

--Creates the game and all the stuff.
function create()
	start_over = true
	pause = false

	group = display.newGroup()
	extra_group = display.newGroup()
	createBoard()
	createGameBoard()
	
	local pauseB = display.newImage("pause.png")
	pauseB.x = display.contentWidth - 50
	pauseB.y = (display.contentHeight / 7 )
	pauseB:scale(0.5, 0.5)
	
	pauseB:addEventListener("tap", pauseGame)
	extra_group:insert(pauseB)

	if music then
		audio.play(sfx.level_one, options)
	end
	--timer.performWithDelay(1000,fail, 1)
end

function isDark(x, y)
	local darkColor = true
	for i = 0, 7 do
		if darkColor == true then
			darkColor = false
		else
			darkColor = true
		end
		for j = 0, 7 do
			if i == y and j == x then
				return darkColor
			end
			if darkColor == true then
				darkColor = false
			else
				darkColor = true
			end
		end
	end
end

function pieceTouch(event)
	--check if clicked location was current location if so, negate
	--if clicked on a current piece then click again, checkmove if true move
	--else do something
	--if clicked on another piece, change to that location
	
	
	local x = event.x 
	local y = event.y
	x = x - x_offset - block_size/2
	y = y - y_offset - block_size/2
	x = x / board_offset
	x = math.floor(x)
	y = y / height_offset
	y = math.floor(y)
	x = x + 1
	y = y + 1
	local currentClickx = x
	local currentClicky = y
	if clickPieceX == -1 or clickPieceY == -1 then
		board[currentClicky][currentClickx]:setFillColor(0.1, 0.8, 0.3)
		clickPieceX = x
		clickPieceY = y
		print(1)
		return
	end
	if currentClickx == clickPieceX and currentClickY == clickPieceY then
		print(2)
		if isDark(clickPieceX, clickPieceY) then
			board[currentClicky][currentClickx]:setFillColor(dark_color, dark_color, dark_color)
			print(3)
		else
			board[clickPieceY][clickPieceX]:setFillColor(light_color, light_color, light_color)
			print(4)
		end
		print(5)
		return
	else --new click is different than old click
		print(6)
		if gameboard[currentClicky][currentClickx] ~= 0 then --click on new piece
			print(7)
			if isDark(clickPieceX, clickPieceY) then
				board[currentClicky][currentClickx]:setFillColor(dark_color, dark_color, dark_color)
				print(8)
			else
				board[clickPieceY][clickPieceX]:setFillColor(light_color, light_color, light_color)
				print(9)
			end
			print(10)
			board[currentClicky][currentClickx]:setFillColor(0.1, 0.8, 0.3)
			clickPieceX = x
			clickPieceY = y
		else --click on non piece
			print(11)
			if isDark(clickPieceX, clickPieceY) then
				board[currentClicky][currentClickx]:setFillColor(dark_color, dark_color, dark_color)
				print(12)
			else
				board[clickPieceY][clickPieceX]:setFillColor(light_color, light_color, light_color)
				print(13)
			end
			clickPieceY = -1
			clickPieceX = -1
			print(14)
		end
	end
end

--Starts the game by starting the menu screen. game is reactionary after this point. 
addMenuScreen()
