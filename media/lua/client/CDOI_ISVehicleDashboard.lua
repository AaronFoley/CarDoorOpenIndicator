require "Vehicles/ISUI/ISVehicleDashboard"

-- Copy existing functions if they haven't been copied
if not ISVehicleDashboard.CDOI_createChildren then
    ISVehicleDashboard.CDOI_createChildren = ISVehicleDashboard.createChildren;
end

if not ISVehicleDashboard.CDOI_prerender then
    ISVehicleDashboard.CDOI_prerender = ISVehicleDashboard.prerender;
end

if not ISVehicleDashboard.CDOI_new then
    ISVehicleDashboard.CDOI_new = ISVehicleDashboard.new;
end


function ISVehicleDashboard:new(playerNum, chr)
    local ret = self:CDOI_new(playerNum, chr)
    ret.CDOIFlashAlpha = 1;
    ret.CDOIFlashAlphaInc = false;
    ret.CDOIIsFlashing = false;
    return ret
end


function ISVehicleDashboard:createChildren()
    self:CDOI_createChildren();
    self.doorTex.mouseovertext = getText("UI_CDOI_doors");
end


function ISVehicleDashboard:prerender()
    self:CDOI_prerender();

    self.CDOIIsFlashing = false;

    if self:isAnyDoorOpen(self.vehicle) then
        self.CDOIIsFlashing = true;
        self.doorTex.backgroundColor = {r=1,g=0.6,b=0,a=self.CDOIFlashAlpha}
        self.doorTex.mouseovertext = getText("Tooltip_CDOI_doors")
    else
        self.doorTex.mouseovertext = getText("Tooltip_Dashboard_LockedDoors")
    end

    if self:isTrunkOpen(self.vehicle) then
        self.CDOIIsFlashing = true;
        self.trunkTex.backgroundColor = {r=1,g=0.6,b=0,a=self.CDOIFlashAlpha}
        if self.vehicle:isTrunkLocked() then
            self.trunkTex.mouseovertext = getText("Tooltip_CDOI_trunkLocked")
        else
            self.trunkTex.mouseovertext = getText("Tooltip_CDOI_trunkUnlocked")
        end
    end

    if self:isHoodOpen(self.vehicle) then
        self.CDOIIsFlashing = true;
        self.engineTex.backgroundColor = {r=1,g=0.6,b=0,a=self.CDOIFlashAlpha}
    else
        self.engineTex.mouseovertext = getText("Tooltip_Dashboard_Engine")
    end


    if self.CDOIIsFlashing then
        if self.CDOIFlashAlpha == 1 and self.character then
            self.character:playSound("carChime")
        end
        self:CDOICalulateFlashAlpha()
    end
end


function ISVehicleDashboard:CDOICalulateFlashAlpha()
    if self.CDOIFlashAlphaInc then
        self.CDOIFlashAlpha = self.CDOIFlashAlpha + 0.06;
        if self.CDOIFlashAlpha >= 1 then self.CDOIFlashAlpha = 1; self.CDOIFlashAlphaInc = false; end
    else
        self.CDOIFlashAlpha = self.CDOIFlashAlpha - 0.06;
        if self.CDOIFlashAlpha <= 0 then self.CDOIFlashAlpha = 0; self.CDOIFlashAlphaInc = true; end
    end
end


function ISVehicleDashboard:isAnyDoorOpen(vehicle)
    if not vehicle then return false end
    for seat=1,vehicle:getMaxPassengers() do
		local part = vehicle:getPassengerDoor(seat-1)
		if part then
            local door = part:getDoor()
            if door and door:isOpen() then
                return true
            end
		end
	end
    return false
end


function ISVehicleDashboard:isTrunkOpen(vehicle)
    if not vehicle then return false end
    local trunkDoor = vehicle:getPartById("TrunkDoor") or vehicle:getPartById("DoorRear")
    if trunkDoor and trunkDoor:getDoor() and trunkDoor:getDoor():isOpen() then
        return true
    end
    return false
end


function ISVehicleDashboard:isHoodOpen(vehicle)
    if not vehicle then return false end
    local engineDoor = vehicle:getPartById("EngineDoor")
    if engineDoor and engineDoor:getDoor() and engineDoor:getDoor():isOpen() then
        return true
    end
    return false
end
