--[[

	Made by Codes Otaku
	Tutorial:
		https://youtu.be/KGYBckh3lUA
	Credits:
		EgoMoose (Render function)

]]

local Triangle3D = {ClassName = "Triangle3D"}
Triangle3D.__index = Triangle3D

local vec3 = {
	ZERO = Vector3.new(0,0,0)
}

local TriangleMesh = script.TriangleMesh

-- [Constructor] Make a triangle out of 3 positions a,b and c (Vector3's)  and a preset
-- new(a, b, c, preset)
-- new({a, b, c}, preset)
-- preset example
--[[
local DrawPreset = {
	build = true, -- Build?
	render = true, -- Render?
	draw = true, -- Draw? requires "build" and "render"
	parent = workspace -- Parent? requires "build"
}
]]

local function new(a, b, c, preset)
	local self = {}

	
	if typeof(a) == "table"	 then
		self.Vertices = a
		preset = b
	else
		self.Vertices = {a or vec3.ZERO, b or vec3.ZERO, c or vec3.ZERO}
	end
	
	self.Preset = preset
	
	setmetatable(self, Triangle3D)
	
	if typeof(preset) == "table" then
		if preset.render then
			self:Render()
		end
		
		if preset.build then		
			self:Build()
			
			if preset.draw and preset.render then
				self:Draw()
			end
			
			if preset.parent then
				self:Parent(preset.parent)
			end
		end
	end
	
	return self
end

-- Call this to create the necessary wedges.
function Triangle3D:Build()
	local Model = Instance.new("Model")
	Model.Name = "TriangleModel"
	
	local wedge1 = TriangleMesh:Clone()
	wedge1.CastShadow = false
	wedge1.Anchored = true
	wedge1.TopSurface = Enum.SurfaceType.Smooth
	wedge1.BottomSurface = Enum.SurfaceType.Smooth
	wedge1.Locked = true--wedge1.Parent = Model

	local WeldConstraint = Instance.new("WeldConstraint")
	WeldConstraint.Part0 = wedge1
	WeldConstraint.Parent = wedge1

	self.Model = Model
	self.Wedge1 = wedge1
	self.Wedge2 = wedge1:Clone()

	self.Wedge1.WeldConstraint.Part1 = self.Wedge2
	self.Wedge2.WeldConstraint.Part1 = self.Wedge1
end

-- Set properties of the drawn triangle (Wedge1, Wedge2)
function Triangle3D:Set(property, value)
	self.Wedge1[property] = value
	self.Wedge2[property] = value
end

-- Set a lot of properties of the triangle at once
function Triangle3D:BulkSet(Table)
	for i,v in pairs(Table) do
		self:Set(i, v)
	end
end

-- Call this to parent the wedges to the specified parent
function Triangle3D:Parent(parent)
	self:Set("Parent", self.Model)
	self.Model.Parent = parent
end

-- Call this to color the triangle
function Triangle3D:Color(color)
	if typeof(color) == "BrickColor" then
		self:Set("BrickColor", color)
	else
		self:Set("Color", color)
	end
end

-- Call this to change the Reflectance of the triangle
function Triangle3D:Reflectance(value)
	self:Set("Reflectance", value)
end

-- Call this to change the transparency of the triangle
function Triangle3D:Transparency(value)
	self:Set("Transparency", value)
end

-- Call this to calculate RenderInfo (Wedges size and CFrames)
-- Credits to EgoMoose for the render function (Edited)

function Triangle3D:Render()
	local vertices = self.Vertices

	local a = vertices[1]
	local b = vertices[2]
	local c = vertices[3]

	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if (abd > acd and abd > bcd) then
		c, a = a, c
	elseif (acd > bcd and acd > abd) then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local right = ac:Cross(ab).unit
	local up = bc:Cross(right).unit
	local back = bc.unit

	local height = math.abs(ab:Dot(up))
	
	self.RenderInfo = {
		Vector3.new(0, height, math.abs(ab:Dot(back))),
		CFrame.fromMatrix((a + b)/2, right, up, back),
		Vector3.new(0, height, math.abs(ac:Dot(back))),
		CFrame.fromMatrix((a + c)/2, -right, up, -back)
	}
end

-- Call this to apply the render info (resulted from Render)
function Triangle3D:Draw()
	local render_info = self.RenderInfo
	
	local wedge1 = self.Wedge1
	local wedge2 = self.Wedge2

	wedge1.Size = render_info[1]
	wedge1.CFrame = render_info[2]

	wedge2.Size = render_info[3]
	wedge2.CFrame = render_info[4]
end

-- Call this to render and draw at the same time
function Triangle3D:Animate()
	self:Render()
	self:Draw()
end

-- Call this to change the vertices only
function Triangle3D:SetVertices(a, b, c)
	if typeof(a) == "table" then
		self.Vertices = a
	else
		self.Vertices = {a, b, c}
	end
end

-- Call this to change the vertices and render and draw at the same time
function Triangle3D:AnimateVertices(a, b, c)
	self:SetVertices(a, b, c)
	self:Animate()
end

-- Call this to change the vertices and render the calculations without drawing
function Triangle3D:RenderVertices(a, b, c)
	self:SetVertices(a, b, c)
	self:Render()
end

-- Call this to get a new triangle with the same contrustor you used for the original.
-- Same vertices and same preset
function Triangle3D:Clone(preset)
	local s = Triangle3D.new(self.Vertices, preset or self.Preset)
	return s
end

-- Call this to destroy the triangle if you no longer need it
function Triangle3D:Destroy()
	self.Model:Destroy()
	
	for i,v in pairs(self) do
		self[i] = nil
	end
	
	self = nil
end

Triangle3D.new = new
return Triangle3D