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
    ret.CDOIIsSilenced = false;
    return ret
end


function ISVehicleDashboard:createChildren()
    self:CDOI_createChildren();
    self.doorTex.mouseovertext = getText("Tooltip_CDOI_doors");
    self.doorTex.onRightMouseUp = ISVehicleDashboard.onToggleSilenceDoors
    self.engineTex.onRightMouseUp = ISVehicleDashboard.onToggleSilenceDoors
    self.trunkTex.onRightMouseUp = ISVehicleDashboard.onToggleSilenceDoors
end


function ISVehicleDashboard:prerender()
    self:CDOI_prerender();

    self.CDOIIsFlashing = false;
    local CDOI_colour = {r=1,g=0.6,b=0,a=self.CDOIFlashAlpha}
    if self.CDOIIsSilenced then
        CDOI_colour = {r=0.3,g=0.1,b=0,a=self.CDOIFlashAlpha}
    end

    if self:isAnyDoorOpen(self.vehicle) then
        self.CDOIIsFlashing = true;
        self.doorTex.backgroundColor = CDOI_colour
        self.doorTex.mouseovertext = getText("Tooltip_CDOI_doors")
    else
        self.doorTex.mouseovertext = getText("Tooltip_Dashboard_LockedDoors")
    end

    if self:isTrunkOpen(self.vehicle) then
        self.CDOIIsFlashing = true;
        self.trunkTex.backgroundColor = CDOI_colour
        if self.vehicle:isTrunkLocked() then
            self.trunkTex.mouseovertext = getText("Tooltip_CDOI_trunkLocked")
        else
            self.trunkTex.mouseovertext = getText("Tooltip_CDOI_trunkUnlocked")
        end
    end

    if self:isHoodOpen(self.vehicle) then
        self.CDOIIsFlashing = true;
        self.engineTex.backgroundColor = CDOI_colour
        self.engineTex.mouseovertext = getText("Tooltip_CDOI_engine")
    else
        self.engineTex.mouseovertext = getText("Tooltip_Dashboard_Engine")
    end

    if self.CDOIIsFlashing then
        if self.CDOIFlashAlpha == 1 and self.character and not self.CDOIIsSilenced then
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
		if part and part:getDoor() and part:getCategory() ~= "nodisplay" then
            -- If the door is missing, then it is open
            if not part:getInventoryItem() then return true end
            if part:getDoor():isOpen() then return true end
		end
	end
    return false
end


function ISVehicleDashboard:isTrunkOpen(vehicle)
    if not vehicle then return false end
    local trunkDoor = vehicle:getPartById("TrunkDoor") or vehicle:getPartById("DoorRear")
    if trunkDoor and trunkDoor:getDoor() and trunkDoor:getCategory() ~= "nodisplay" then
        -- If the door is missing, then it is open
        if not trunkDoor:getInventoryItem() then return true end
        if trunkDoor:getDoor():isOpen() then return true end
    end
    return false
end


function ISVehicleDashboard:isHoodOpen(vehicle)
    if not vehicle then return false end
    local engineDoor = vehicle:getPartById("EngineDoor")
    if engineDoor and engineDoor:getDoor() and engineDoor:getCategory() ~= "nodisplay" then
        -- If the door is missing, then it is open
        if not engineDoor:getInventoryItem() then return true end
        if engineDoor:getDoor():isOpen() then return true end
    end
    return false
end


function ISVehicleDashboard.onToggleSilenceDoors()
    -- I'm not really sure why this didn't work pointing at self
    -- It seems like self is actually a different table later on?
    local player = getPlayer();
    local playerNum = player:getPlayerNum();
    local dash = getPlayerVehicleDashboard(playerNum)
    if dash then
        dash.CDOIIsSilenced = not dash.CDOIIsSilenced;
    end
end
