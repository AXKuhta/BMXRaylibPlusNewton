SuperStrict

Import Newton.Dynamics
Import Ray.Math

Import "TEntity.bmx"

' =================
' T Physical Entity
' =================
Type TPEntity Extends TEntity
	Field PEntity:TNBody
	
	Method New()
		' Need to init the TNBody
		PEntity = New TNBody
	End Method
	
	Method Draw() Override
		SyncPhysics()
		DrawModel(Model, Position, Scale, Color)
	End Method
	
	Method SyncPhysics()
		' Copy the matrix provided by Newton over the Raylib matrix
		NewtonBodyGetMatrix(PEntity.bodyPtr, Varptr Model.transform.m0)
		
		' Hack to salvage positions from the new matrix
		' Needs to be done before transposition
		' Take a look at the source code of `TNMatrix` in `dynamics.bmx` and `struct Matrix` in `raylib.h` to understand what exactly goes down here
		Position.x = Model.transform.m3
		Position.y = Model.transform.m7
		Position.z = Model.transform.m11

		' It also needs to be transposed afterwards
		Model.transform = MatrixTranspose(Model.transform)
	End Method
	
	' Because TPEntity has the model matrix synced with Newton matrix, we need to update the latter
	Method SetPosition(X:Float, Y:Float, Z:Float) Override
		Local TransposedMatrix:RMatrix
		
		Model.transform.m12 = X
		Model.transform.m13 = Y
		Model.transform.m14 = Z
		
		TransposedMatrix = MatrixTranspose(Model.transform)
		
		NewtonBodySetMatrix(PEntity.bodyPtr, Varptr TransposedMatrix.m0)
	End Method
	
	Method SetRotation(Pitch:Float, Yaw:Float, Roll:Float) Override
		Local NewMatrix:RMatrix
		Local TransposedMatrix:RMatrix
		
		NewMatrix = MatrixRotateXYZ(New RVector3(Pitch, Yaw, Roll))
		
		' Preserve the position
		NewMatrix.m12 = Model.transform.m12
		NewMatrix.m13 = Model.transform.m13
		NewMatrix.m14 = Model.transform.m14

		TransposedMatrix = MatrixTranspose(NewMatrix)
		
		NewtonBodySetMatrix(PEntity.bodyPtr, Varptr TransposedMatrix.m0)
	End Method
	
End Type


' =====================
' Body update functions
' =====================
Function NFN_Freefall(Body:TNBody, Timestamp:Float, ThreadIndex:Int)
	Local Mass:Float
	Local Ixx:Float
	Local Iyy:Float
	Local Izz:Float
	
	Body.GetMassMatrix(Mass, Ixx, Iyy, Izz)
	Body.SetForce(0.0, -9.8 * Mass, 0.0, 0.0)
End Function


' ============================
' Primitive creation functions
' ============================
Function CreatePCube:TPEntity(World:TNWorld, Sides:Float = 1.0, Mass:Float = 1.0)
	Local Cube:TPEntity = New TPEntity
	
	' # Prepare physical representation
	Local Shape:TNCollision = World.CreateBox(Sides, Sides, Sides)
	
	Local Matrix:TNMatrix = TNMatrix.GetIdentityMatrix()
	Matrix.positX = 0
	Matrix.positY = 0
	Matrix.positZ = 0
	
	World.CreateDynamicBody(Shape, Matrix, Cube.PEntity)

	Cube.PEntity.SetMassProperties(Mass, Shape)
	Cube.PEntity.SetLinearDamping(0.0)

	Shape.Destroy()
	
	Cube.PEntity.SetForceAndTorqueCallback(NFN_Freefall)
	
	' # Prepare visual representation
	Cube.Model = LoadModelFromMesh(GenMeshCube(Sides * 2, Sides * 2, Sides * 2))
	Cube.SetPosition(0, 0, 0)
	
	Return Cube
End Function

Function CreatePPlane:TPEntity(World:TNWorld, Length:Int = 10000, Resolution:Int = 2)
	Local Plane:TPEntity = New TPEntity
	
	' # Prepare physical representation
	' These points are X, Y and Z of the physical plane basically
	Local Points:Float[] = [ ..
		-Length, 0.0,  Length, ..
		 Length, 0.0,  Length, .. 
		 Length, 0.0, -Length, ..
		-Length, 0.0, -Length ]

	' Create a collision tree
	Local Tree:TNTreeCollision = World.CreateTreeCollision(0)

	' Start building the collision mesh
	Tree.BeginBuild()

	' Add the face one at a time
	Tree.AddFace(4, Points, 12, 0)

	' Finish building the collision
	Tree.EndBuild(1)

	' Create a body with a collision
	Local Matrix:TNMatrix = TNMatrix.GetIdentityMatrix()

	World.CreateDynamicBody(Tree, Matrix, Plane.PEntity)
	
	' No need in update function for a plane
	
	' Don't forget to destroy the collision tree after you no longer need it
	Tree.Destroy()
	
	' # Prepare visual representation
	Plane.Model = LoadModelFromMesh(GenMeshPlane(10000, 10000, Resolution, Resolution))
	Plane.SetPosition(0, 0, 0)
	
	Return Plane
End Function

