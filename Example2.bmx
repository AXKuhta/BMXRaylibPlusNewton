
SuperStrict

Framework Ray.Lib

Import "Source/TPEntity.bmx"

' Initialization
'--------------------------------------------------------------------------------------
Const ScreenWidth:Int = 1280
Const ScreenHeight:Int = 720

InitWindow(ScreenWidth, ScreenHeight, "Raylib + Newton Dynamics")

' Define the camera to look into our 3d world
Local Camera:RCamera
Camera.position = New RVector3(0, 2, -50) ' Camera position
Camera.target = New RVector3(0, 0, 0)      ' Camera looking at point
Camera.up = New RVector3(0, 1, 0)          ' Camera up vector (rotation towards target)
Camera.fovy = 75.0                               ' Camera field-of-view Y
Camera.cameraType = CAMERA_PERSPECTIVE           ' Camera mode type (What does that do??)

'SetCameraMode(Camera, CAMERA_FIRST_PERSON) ' Set a free camera mode

SetTargetFPS(60)                   ' Set our game to run at 60 frames-per-second

Local NWorld:TNWorld = TNWorld.Create() ' Create physical world
'--------------------------------------------------------------------------------------


' Shorthand definitions
'--------------------------------------------------------------------------------------
Local Plane:TPEntity = CreatePPlane(NWorld)
Plane.SetRotation(0, 0, 15) ' You can tilt the ground plane

Plane.Color = BLUE

' Something strange starts happening if you set uneven dimensions
' For example, with values 5, 15, 5, you can distinctly notice invisible cubes stacking on top of the visible ones
Local Width:Int = 5
Local Height:Int = 5
Local Depth:Int = 5

Local PileOfCubes:TPEntity[Width, Height, Depth]

For Local i:Int = 0 To Width - 1
	For Local j:Int = 0 To Height - 1
		For Local k:Int = 0 To Depth - 1
			PileOfCubes[i, j, k] = CreatePCube(NWorld, 3)
			PileOfCubes[i, j, k].SetPosition(i*3, j*5 + 3, k*3)
		Next
	Next 
Next

PileOfCubes[4, 4, 0].Color = GREEN
'--------------------------------------------------------------------------------------



' Main game loop
NWorld.InvalidateCache()

While Not WindowShouldClose()    ' Detect window close button or ESC key
	' Update
	'----------------------------------------------------------------------------------
	NWorld.Update(1.0/60) ' Update physics
	
	camera.target = PileOfCubes[4, 4, 0].Position
	
	UpdateCamera(camera)      ' Update camera
	'----------------------------------------------------------------------------------

	' Draw
	'----------------------------------------------------------------------------------
	BeginDrawing()

		ClearBackground(RAYWHITE)

		BeginMode3D(camera)
		
			For Local i:Int = 0 To Depth - 1
				For Local j:Int = 0 To Width - 1
					For Local k:Int = 0 To Height - 1
						PileOfCubes[i, j, k].Draw()
					Next
				Next 
			Next

			Plane.Draw()
			
		EndMode3D()

		DrawFPS(10, 10)

	EndDrawing()
	'----------------------------------------------------------------------------------
Wend

' De-Initialization
'--------------------------------------------------------------------------------------

CloseWindow()              ' Close window and OpenGL context
'--------------------------------------------------------------------------------------
