-- SWEP Information
SWEP.Author			= "Michael 'Xaymar' Dirks"
SWEP.Contact		= "info@xaymar.com"
SWEP.PrintName		= "PH Submachine Gun"
SWEP.Purpose		= "More accurate SMG for Prop Hunt."
SWEP.Instructions	= "Fire away! Alternative fire to fire a grenade."
SWEP.Category		= "Prop Hunt Weapons"

-- Weapon Information
SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.Slot			= 2
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true

-- Weapon is spawnable for everyone, not just administrators.
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

-- Model
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.UseHands	= true

-- Primary Ammunition: SMG
SWEP.Primary.ClipSize		= 45
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Damage			= 4
SWEP.Primary.RefireTime		= 0.075

-- Secondary Ammunition: SMG Grenades
SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "SMG1_Grenade"
SWEP.Secondary.Damage		= 100
SWEP.Secondary.RefireTime	= 1.0

-- Recoil
SWEP.Recoil = {}
SWEP.Recoil.SingleFire		= 0.2
SWEP.Recoil.BurstFire		= 1.0
SWEP.Recoil.SecondaryFire	= 8.0

-- Accuracy
SWEP.Accuracy = {}
SWEP.Accuracy.Primary = {}
SWEP.Accuracy.Primary.Min			= 0.975
SWEP.Accuracy.Primary.Max			= 1.00
SWEP.Accuracy.Primary.Reduction		= 0.005
SWEP.Accuracy.Primary.Recovery		= 0.0025
SWEP.Accuracy.Primary.Delay			= 0.1
SWEP.Accuracy.Secondary = {}
SWEP.Accuracy.Secondary.Min			= 1.00
SWEP.Accuracy.Secondary.Max			= 1.00
SWEP.Accuracy.Secondary.Reduction	= 0.00
SWEP.Accuracy.Secondary.Recovery	= 0.00
SWEP.Accuracy.Secondary.Delay		= 0.00

-- Sounds
SWEP.Sound = {}
SWEP.Sound.SwitchSingle		= "weapons/smg1/switch_single.wav"
SWEP.Sound.SwitchBurst		= "weapons/smg1/switch_burst.wav"
SWEP.Sound.SingleFire		= "weapons/smg1/smg1_fire1.wav"
SWEP.Sound.BurstFire		= "weapons/smg1/smg1_fireburst1.wav"
SWEP.Sound.SecondaryFire	= "weapons/ar2/ar2_altfire.wav"
SWEP.Sound.Reload			= "weapons/smg1/smg1_reload.wav"
SWEP.Sound.NoPrimaryAmmo	= "weapons/pistol/pistol_empty.wav"
SWEP.Sound.NoSecondaryAmmo	= "weapons/pistol/pistol_empty.wav"

-- Initialization
function SWEP:Initialize()
	-- Set holding type to smg.
	self:SetHoldType("smg");
	
	-- Precache sounds for lagless experience.
	for i,v in ipairs(self.Sound) do
		util.PrecacheSound(v)
	end
	
	-- Initialize default values.
	self.BurstFire = false
	self:SetNWBool("BurstFire", false)
	self.LastReload = CurTime()
	
	self.PrimaryAccuracy = self.Accuracy.Primary.Max
	self.LastPrimaryAttack = CurTime()
	self.SecondaryAccuracy = self.Accuracy.Secondary.Max
	self.LastSecondaryAttack = CurTime()
	
end

-- Primary Attack
function SWEP:CanPrimaryAttack()
	-- Check if there is ammo in the clip.
	if (self:Clip1() <= 0) then
		-- If not, check if there's ammo available.
		if (self:Ammo1() > 0) then
			-- If yes, reload and wait for weapon to be ready again.
			self.Weapon:EmitSound(self.Sound.NoPrimaryAmmo)
			self:Reload()
			return false
		end
		
		-- If no, emit empty sound for primary fire.
		self.Weapon:EmitSound(self.Sound.NoPrimaryAmmo)
		self:SetNextPrimaryFire(CurTime() + 0.1)
		return false
	end
	
	-- Otherwise, return true.
	return true
end

function SWEP:PrimaryAttack()
	-- Can't fire without Ammo
	if (!self:CanPrimaryAttack()) then return end
	
	if (self:GetNWBool("BurstFire") == false) then
		-- Single Mode: fire and take one bullet from the clip.
		self:TakePrimaryAmmo(1)
		self:SetNextPrimaryFire( CurTime() + self.Primary.RefireTime )
		self.Weapon:EmitSound(self.Sound.SingleFire)
		
		-- Apply recoil
		if IsValid(self.Owner) then
			self.Owner:ViewPunch( Angle(-1, 0, 0) * self.Recoil.SingleFire * (1 + (1 - self.PrimaryAccuracy)) )
			self:ShootBullet(self.Primary.Damage, 1, 1.0 - self.PrimaryAccuracy)
		end
		
		-- Decrease accuracy
		self.PrimaryAccuracy = math.Clamp(self.PrimaryAccuracy - self.Accuracy.Primary.Reduction, self.Accuracy.Primary.Min, self.Accuracy.Primary.Max)
	else
		-- Burst Mode: fire and take up to three bullets from the clip
		local bulletCount = math.Clamp(self:Clip1(), 1, 3)
		self:TakePrimaryAmmo(bulletCount)
		self:SetNextPrimaryFire( CurTime() + self.Primary.RefireTime * bulletCount )
		self.Weapon:EmitSound(self.Sound.BurstFire)
		
		for i = 1, bulletCount do
			if (IsValid(self)) && (IsValid(self.Owner)) then
				-- Apply recoil & shoot
				self.Owner:ViewPunch(Angle(-1, 0, 0) * self.Recoil.BurstFire * (1 + (1 - self.PrimaryAccuracy)))
				self:ShootBullet(self.Primary.Damage, 1, 1.0 - self.PrimaryAccuracy)
				
				-- Decrease accuracy
				self.PrimaryAccuracy = math.Clamp(self.PrimaryAccuracy - self.Accuracy.Primary.Reduction, self.Accuracy.Primary.Min, self.Accuracy.Primary.Max)
			end
		end
	end
	
	-- Set Animation and attack time.
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.LastPrimaryAttack = CurTime()
	return
end

-- Secondary Attack
function SWEP:CanSecondaryAttack()
	if (self:Clip2() == 0) then
		if (self:Ammo2() == 0) then
			self.Weapon:EmitSound(self.Sound.NoSecondaryAmmo)
			self:SetNextSecondaryFire( CurTime() + 1.0 )
			return false
		else
			self:SetClip2( 1 )
		end
	end
	
	return true
end

function SWEP:SecondaryAttack()
	-- Can't fire without Ammo
	if (!self:CanSecondaryAttack()) then return end
	
	self.Owner:SetAmmo( self.Owner:GetAmmoCount( self:GetSecondaryAmmoType() ) - 1, self:GetSecondaryAmmoType() )
	
	-- Emit a sound.
	self.Weapon:EmitSound(self.Sound.SecondaryFire)
	self:SetNextSecondaryFire( CurTime() + self.Secondary.RefireTime )
	self:TakeSecondaryAmmo(1)
	
	-- Create grenade
	if SERVER then
		local grenade = ents.Create("grenade_ar2")
		if (!IsValid(grenade)) then return end
		grenade:SetPos( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 30 )
		grenade:SetVelocity( self.Owner:GetAimVector() * 1000 )
		grenade:SetAngles( self.Owner:GetAngles() )
		grenade:SetOwner( self.Owner )
		grenade:Spawn()
		grenade:SetPhysicsAttacker( self.Owner, 60 )
	end
		
	-- Set Animation and attack time.
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self.LastSecondaryAttack = CurTime()
	return
end

-- Reload: Combination of reloading and switching fire type.
function SWEP:Reload()
	-- Fix reload for secondary
	if (self:Clip2() == 0) then
		if (self:Ammo2() > 0) then
			self:SetClip2( 1 )
		end
	end

	if self:DefaultReload(ACT_VM_RELOAD) then
		self.Weapon:EmitSound(self.Sound.Reload)
	else
		if (self.LastReload) && ((CurTime() - self.LastReload) > 1) then
			self.BurstFire = !self:GetNWBool("BurstFire")
			self.LastReload = CurTime()
			
			if (self.BurstFire) then
				self.Weapon:EmitSound(self.Sound.SwitchBurst)
				if SERVER then self:GetOwner():ChatPrint("Weapon: BurstFire is now on.") end
			else
				self.Weapon:EmitSound(self.Sound.SwitchSingle)
				if SERVER then self:GetOwner():ChatPrint("Weapon: BurstFire is now off.") end
			end
			if SERVER then self:SetNWBool("BurstFire", self.BurstFire) end
		end
	end
	
	return
end

function SWEP:ShootEffects()
	
end

-- Think: Restore accuracy over time.
function SWEP:Think()
	local ThinkTime = CurTime()
	
	if (ThinkTime >= (self.LastPrimaryAttack + self.Accuracy.Primary.Delay)) then
		self.PrimaryAccuracy = math.Clamp(self.PrimaryAccuracy + self.Accuracy.Primary.Recovery, self.Accuracy.Primary.Min, self.Accuracy.Primary.Max)
	end
	if (ThinkTime >= (self.LastSecondaryAttack + self.Accuracy.Secondary.Delay)) then
		self.SecondaryAccuracy = math.Clamp(self.SecondaryAccuracy + self.Accuracy.Secondary.Recovery, self.Accuracy.Secondary.Min, self.Accuracy.Secondary.Max)
	end
end
