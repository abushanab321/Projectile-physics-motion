local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local DetectHit = require(script.HitDetection)

local ProjectileModule = {}
ProjectileModule.__index = ProjectileModule

export type ProjectileConfig = {
	StartPosition: Vector3,
	TargetPosition: Vector3,
	Projectile: any,
	Force: number?,
	Gravity: Vector3?,
	Blacklist: any?,
	DespawnTime: number?,
	LastingTime: number?,
	Range: number?,
	IsHitable: boolean?,
	OnTarget: boolean?,
	Curve: number?
}

local Defaults = {
	Force = 100,
	Gravity = -100,
	Blacklist = {},
	DespawnTime = 5,
	LastingTime = 5,
	Range = 100,
	IsHitable = true,
	OnTarget = false,
	Curve = 0
}

function ProjectileModule.NewProjectile(Info: ProjectileConfig)
	local self = setmetatable({}, ProjectileModule)
	
	self.StartPosition = Info.StartPosition
	self.TargetPosition = Info.TargetPosition
	self.OnTarget = Info.OnTarget or Defaults.OnTarget
	self.Projectile = Info.Projectile:Clone()
	self.Force = Info.Force or Defaults.Force
	self.Gravity = Info.Gravity or Defaults.Gravity
	self.Blacklist = Info.Blacklist or Defaults.Blacklist
	self.DespawnTime = Info.DespawnTime or Defaults.DespawnTime
	self.LastingTime = Info.LastingTime or Defaults.LastingTime
	self.Range = Info.Range or Defaults.Range
	self.IsHitable = Info.IsHitable or Defaults.IsHitable
	self.Curve = Info.Curve or Defaults.Curve
	
	return self
end

function ProjectileModule:Fire()
	local StartTick = tick()
	local IsHitable = self.IsHitable
	local OnTarget = self.OnTarget
	local GravityVector = Vector3.new(self.Curve, self.Gravity, 0)

	self.Projectile.Parent = workspace
	self.Projectile.Position = self.StartPosition
	self.Projectile.Anchored = true
	self.Projectile.CanCollide = false
	
	-- If OnTarget is true, we want to calculate the exact velocity needed to hit the target. IF IT IS IN RANGE, we can use a simple approach.
	if (self.TargetPosition - self.StartPosition).Magnitude > self.Range then
		OnTarget = false
	end

	-- Calculate the distance and direction to the target
	local Displacement = self.TargetPosition - self.StartPosition
	local AppliedVelocity

	if OnTarget then
		-- 1. Find out how long it takes to reach the target using your intended speed
		local TimeToTarget = Displacement.Magnitude / self.Force

		-- 2. Calculate the exact initial velocity required to hit the target
		AppliedVelocity = (Displacement / TimeToTarget) - (0.5 * GravityVector * TimeToTarget)
	else
		if Displacement.Magnitude > self.Range then
			-- The target is out of range. Create a new point exactly at the edge of your range.
			local MaxDisplacement = Displacement.Unit * self.Range

			-- Calculate the exact arc needed to drop the projectile at this furthest point
			local TimeToTarget = self.Range / self.Force
			AppliedVelocity = (MaxDisplacement / TimeToTarget) - (0.5 * GravityVector * TimeToTarget)
		else
			-- Original behavior: Aim straight at the target (gravity will cause it to drop naturally)
			AppliedVelocity = (Displacement.Unit * self.Force) - (0.5 * GravityVector)
		end
	end

	local HeartConnection
	HeartConnection = RunService.Heartbeat:Connect(function(DeltaTime)
		local Timer = tick() - StartTick

		local ProjectilePosition = self.Projectile.Position + AppliedVelocity * DeltaTime + 0.5 * GravityVector * DeltaTime * DeltaTime
		self.Projectile.Position = ProjectilePosition

		-- Set rotation to face the direction of velocity
		if AppliedVelocity.Magnitude > 0 then
			self.Projectile.CFrame = CFrame.lookAt(ProjectilePosition, ProjectilePosition + AppliedVelocity)
		end

		-- Update velocity with gravity for the next frame
		AppliedVelocity = AppliedVelocity + GravityVector * DeltaTime

		if IsHitable then
			local Hit, HitVictim, Position = DetectHit:Detect(self.Projectile, AppliedVelocity.Unit * self.Projectile.Size.Z, self.Blacklist)
			if Hit then
				HeartConnection:Disconnect()
				Debris:AddItem(self.Projectile, self.LastingTime)
			end
		end	

		if self.DespawnTime <= Timer then
			HeartConnection:Disconnect()
			Debris:AddItem(self.Projectile, self.LastingTime)
		end
	end)
end

return ProjectileModule