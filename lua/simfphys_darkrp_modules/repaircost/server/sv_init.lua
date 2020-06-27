local Scripts = SimfphysDarkRPScripts

function Scripts:RepairCost_Init()
    local swep = weapons.GetStored("weapon_simrepair")

    simrepaircost_PrimaryAttack = simrepaircost_PrimaryAttack or swep.PrimaryAttack
    local primaryAttack = simrepaircost_PrimaryAttack
    local repairCost = 50


    swep.PrimaryAttack = function(self, ...)
        local owner = self.Owner
        local money = owner:getDarkRPVar("money")
        if money < repairCost then return end
        
        local trace = owner:GetEyeTrace()
        local ent = trace.Entity
        
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
end

hook.Add( "InitPostEntity", "SimfPhysRepairCostInit", function()
    Scripts:RepairCost_Init()
end )
