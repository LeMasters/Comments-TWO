local physics = require( "physics" )
local rnd = math.random
local screenHeight = display.contentHeight
local screenWidth = display.contentWidth
local scrCtrX = screenWidth * 0.5
local scrCtrY = screenHeight * 0.5
local introScreenInfo = display.newGroup()
display.setStatusBar(display.HiddenStatusBar)
local garbageRecepticle
local maxQtyCans = 144
local abs_GPM = ( maxQtyCans / 24 )
local marginX = screenWidth * 0.15
local verticalOffset = 2.5
local balanceOffset = 0.002
local function showIntroScreen( )
	local background = display.newRect(screenWidth*0.5, screenHeight*0.5,
	                                   screenWidth, screenHeight)
	background:setFillColor(1,1,1)
	local cokeCan = display.newImage("CokeCan.png")
	local reSize = screenWidth / (cokeCan.width * 3)
	cokeCan.width = cokeCan.width * reSize
	cokeCan.height = cokeCan.height * reSize
	cokeCan.x = screenWidth - (cokeCan.width * 0.5)
	cokeCan.y = screenHeight - (cokeCan.height * 0.5)
	local topAlignAxis = screenHeight * 0.15
	local options1 = 
	{
	    text = "Hey!  You look like you recycle. Religiously. Good for you!  Let's take a look at how many aluminum cans you would have had to have recycled by this time today in order to offset your neighbor's daily garbage output!",
	    x = screenWidth * 0.5,
	    width = screenWidth * 0.75,
	    font = native.systemFont,
	    fontSize = ( screenWidth / 10 ) / 1.35
	}
	local myText1 = display.newText( options1 )
	myText1:setFillColor( .1, .1, .15 )
	myText1.anchorY = 0
	myText1.y = topAlignAxis
	introScreenInfo:insert(background)
	introScreenInfo:insert(cokeCan)	
	introScreenInfo:insert(myText1)
end
local function canRadiusFinder( canQty )
	local containerX = ( screenWidth - ( marginX * 2 ))
	local containerY = screenHeight
	local screenArea = containerX * containerY
	local sqPixelsPerUnit = screenArea / maxQtyCans
	local diameter = math.sqrt( sqPixelsPerUnit )
	local radius = math.round( diameter * 0.5 ) * 0.9
	return radius
end
local function canTime( )
	local clockQueryHour = "%H"
	local clockQueryMinute = "%M"
	local h = os.date(clockQueryHour) * 60
	local m = os.date(clockQueryMinute)
	local tMinutes = h + m
	local unitsGarbage = math.round( tMinutes / abs_GPM )
	return unitsGarbage
end
local function toTheDump( garbageObjects, cRad )
	for i = 1, #garbageObjects do
		garbageObjects[ i ].x = scrCtrX + (i * balanceOffset)
		garbageObjects[ i ].y = screenHeight - ( i * cRad * verticalOffset )
		physics.addBody( garbageObjects[ i ], "dynamic", 
		                { radius = cRad,
		                density = 1.0, 
		                friction = 0.25,
		                bounce = 0.35,
		                isSensor = false
		                })
	end
end
local function rubberMaid( )
	local floor=display.newRect( scrCtrX, screenHeight-4, screenWidth, 8 )
	physics.addBody(floor, "static", 
	                { density = 1.0, 
	                friction = 0.4, 
	                bounce = 0.5, 
	                isSensor = false })
	local wallLeft=display.newRect( marginX, scrCtrY * 1.3, 6, screenHeight * 0.7  )
	physics.addBody(wallLeft, "static", 
	                { density = 1.0, 
	                friction = 0.4, 
	                bounce = 0.2, 
	                isSensor = false })
	local wallRight=display.newRect( screenWidth-marginX, scrCtrY * 1.3, 6, screenHeight * 0.7 )
	physics.addBody(wallRight, "static", 
	                { density = 1.0, 
	                friction = 0.4, 
	                bounce = 0.2, 
	                isSensor = false })
	wallRight.rotation = 5.5
	wallLeft.rotation = -5.5
	local wallFarLeft=display.newRect( - marginX, scrCtrY, 8, screenHeight )
	physics.addBody(wallFarLeft, "static", 
	                { density = 1.0, 
	                friction = 0.4, 
	                bounce = 0.2, 
	                isSensor = false })
	local wallFarRight=display.newRect( screenWidth+marginX, scrCtrY, 8, screenHeight )
	physics.addBody(wallFarRight, "static", 
	                { density = 1.0, 
	                friction = 0.4, 
	                bounce = 0.2, 
	                isSensor = false })
	local trashcan = display.newGroup()
	trashcan:insert( floor )
	trashcan:insert( wallLeft )
	trashcan:insert( wallRight )
	trashcan:insert( wallFarLeft )
	trashcan:insert( wallFarRight )
	return trashcan
end
local function localBottler( canQty, iCanHazRadius )
	local aluCan = {}
	local canTopFill = {
		type = "image",
		filename = "aluCanTopA.png"
	}
	for i = 1, canQty do
		aluCan[i] = display.newCircle( 0, 0, iCanHazRadius )
		aluCan[i].fill = canTopFill
	end
	return aluCan
end
local function mainLoop( )
	physics.start( )
	local currentUnits = canTime()
	local canRadius = canRadiusFinder( currentUnits )
	local garbageObjects = localBottler( currentUnits, canRadius )
	garbageRecepticle = rubberMaid()
	toTheDump( garbageObjects, canRadius )
end
local function doIt( event )
	if event.phase == "began" then
		introScreenInfo:removeEventListener("touch", doIt)
		transition.to( introScreenInfo, { time = 1501, alpha = 0, onComplete = mainLoop })
	end
end
showIntroScreen( )
introScreenInfo:addEventListener("touch", doIt)