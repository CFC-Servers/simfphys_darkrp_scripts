local swep = weapons.GetStored("weapon_simrepair")
simrepair_primary = simrepair_primary or swep.PrimaryAttack
local primaryAttack = simrepair_primary
local repairCost = 100


swep.PrimaryAttack = function(self, ...)
    local owner = self.Owner
	local money = owner:getDarkRPVar("money")
	if money < repairCost then return end
	
	local Trace = owner:GetEyeTrace()
	local ent = Trace.Entity
	
	local class = ent:GetClass()
	
	local isVehicle = class == "gmod_sent_vehicle_fphysics_base"
	local isWheel = class == "gmod_sent_vehicle_fphysics_wheel"
	
	if isVehicle then
		local func = ent.SetCurHealth
		ent.SetCurHealth = function(...)
			self.Owner:addMoney(-repairCost)
			func(...)
		end
		primaryAttack(self, ...)
		ent.SetCurHealth = func
	elseif isWheel then
		local func = ent.SetDamaged
		ent.SetDamaged = function(...)
			self.Owner:addMoney(-repairCost)
			func(...)
		end
		primaryAttack(self, ...)
		ent.SetDamaged = func
	else
		primaryAttack(self, ...)
	end
	
end

