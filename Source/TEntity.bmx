SuperStrict

Import Ray.Lib
Import Ray.Math

Type TEntity
	Field Model:RModel
	Field Position:RVector3
	Field Scale:Float = 1.0
	Field Color:RColor = RED
	
	Method Update()
	
	End Method
	
	Method Draw()
		' Use Model.transform to rotate the model
		DrawModel(Model, Position, Scale, Color)
	End Method
	
	' A helper to update position without typing a lot of letters	
	Method SetPosition(X:Float, Y:Float, Z:Float)
		Position.x = X
		Position.y = Y
		Position.z = Z
	End Method
	
	Method SetRotation(Pitch:Float, Yaw:Float, Roll:Float)
		Local NewMatrix:RMatrix
		
		NewMatrix = MatrixRotateXYZ(New RVector3(Pitch, Yaw, Roll))
		
		' Preserve the position
		NewMatrix.m12 = Position.x
		NewMatrix.m13 = Position.y
		NewMatrix.m14 = Position.z

		Model.transform = NewMatrix
	End Method

End Type

