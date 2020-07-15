
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
Camera.position = New RVector3(0, 2, -10) ' Camera position
Camera.target = New RVector3(0, 0, 0)      ' Camera looking at point
Camera.up = New RVector3(0, 1, 0)          ' Camera up vector (rotation towards target)
Camera.fovy = 75.0                               ' Camera field-of-view Y
Camera.cameraType = CAMERA_PERSPECTIVE           ' Camera mode type (What does that do??)

SetCameraMode(Camera, CAMERA_FIRST_PERSON) ' Set a free camera mode

SetTargetFPS(60)                   ' Set our game to run at 60 frames-per-second

Local NWorld:TNWorld = TNWorld.Create() ' Create physical world
'--------------------------------------------------------------------------------------


' Shorthand definitions
'--------------------------------------------------------------------------------------
Local Cube:TPEntity = CreatePCube(NWorld, 3)
Local Plane:TPEntity = CreatePPlane(NWorld)

Cube.SetPosition(0, 50, 0)
Plane.SetPosition(0, 0, 0)

Plane.Color = BLUE
'--------------------------------------------------------------------------------------

' Main game loop
NWorld.InvalidateCache()

While Not WindowShouldClose()    ' Detect window close button or ESC key
	' Update
	'----------------------------------------------------------------------------------
	NWorld.Update(1.0/60) ' Update physics
	
	UpdateCamera(camera)      ' Update camera
	
	If IsKeyDown(KEY_R)
		Cube.SetPosition(0, 50, 0)
	End If
	'----------------------------------------------------------------------------------

	' Draw
	'----------------------------------------------------------------------------------
	BeginDrawing()

		ClearBackground(RAYWHITE)

		BeginMode3D(camera)
		
			Cube.Draw()
			Plane.Draw()
			
		EndMode3D()

		DrawFPS(10, 10)
		DrawText("Press R to reset the cube position!", 10, 30, 20, DARKGRAY);

	EndDrawing()
	'----------------------------------------------------------------------------------
Wend

' De-Initialization
'--------------------------------------------------------------------------------------

CloseWindow()              ' Close window and OpenGL context
'--------------------------------------------------------------------------------------
