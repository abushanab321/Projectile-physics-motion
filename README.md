----This Module was made by Sir_Sh8la7----

Description: This ROBLOX module was made by me "Sir_Sh8la7" to make way simpler and easier to throw your projectiles in a way that replicate physics from the real world.
The physics formula for the position of the projectile is = Y = Y0 + V0t + (1/2)*at^2

HOW TO USE:
1. Make a new projectile using Module.NewProjectile(Arguments)
2. Assign the following arguments:

	StartPosition: Vector3 --- Where the projectile starts.
	TargetPosition: Vector3 --- Where the projectile moves towards.
	Projectile: any --- The projectile object. "CANNOT BE A MODEL"

	Force: number? --- Amount of force. Default: 100
	Gravity: number? --- Gravity is applied to the projectile. Default: -100
	Blacklist: table? --- Objects to ignore. Default: {}
	DespawnTime: number? --- Time before despawning. Default: 5
	LastingTime: number? --- Time to remain after hitting. Default: 5
	Range: number? --- Maximum travel distance. Default: 100
	IsHitable: boolean? --- Enables hit detection. Default: true
	OnTarget: boolean? --- Lands exactly on the target. Default: false
	Curve: number? --- Amount of trajectory curve. Default: 0

---- Any argument marked with "?" is optional and will use its default value if omitted. ----


3. Simply do Projectile:Fire
