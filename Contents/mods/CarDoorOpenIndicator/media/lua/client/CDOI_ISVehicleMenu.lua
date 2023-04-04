require "Vehicles/ISUI/ISVehicleMenu"

-- Copy existing functions if they haven't been copied
if not ISVehicleMenu.CDOI_showRadialMenu then
    ISVehicleMenu.CDOI_showRadialMenu = ISVehicleMenu.showRadialMenu;
end

if not ISVehicleMenu.CDOI_showRadialMenuOutside then
    ISVehicleMenu.CDOI_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside;
end


function ISVehicleMenu.showRadialMenu(playerObj)
    ISVehicleMenu.CDOI_showRadialMenu(playerObj);
    local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
    if isPaused then return end
    local vehicle = playerObj:getVehicle()
    if not vehicle then return end

    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())

    if ISVehicleDashboard:isAnyDoorOpen(vehicle) then
        if not vehicle:isStopped() then
            menu:addSlice(getText("ContextMenu_CDOI_closeDoorsStopCar"), getTexture("media/ui/vehicles/vehicle_exit.png"), nil, playerObj, vehicle)
        else
            menu:addSlice(getText("ContextMenu_CDOI_closeDoors"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseAllDoors, playerObj, vehicle);
        end
    end

    if ISVehicleDashboard:isTrunkOpen(vehicle) then
        if not vehicle:isStopped() then
            menu:addSlice(getText("ContextMenu_CDOI_closeTrunkStopCar"), getTexture("media/ui/vehicles/vehicle_exit.png"), nil, playerObj, vehicle)
        else
            local trunkDoor = vehicle:getPartById("TrunkDoor") or vehicle:getPartById("DoorRear")
            menu:addSlice(getText("ContextMenu_CDOI_closeTrunk"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseExternalDoor, playerObj, vehicle, trunkDoor)
        end
    end

    if ISVehicleDashboard:isHoodOpen(vehicle) then
        if not vehicle:isStopped() then
            menu:addSlice(getText("ContextMenu_CDOI_closeHoodStopCar"), getTexture("media/ui/vehicles/vehicle_exit.png"), nil, playerObj, vehicle)
        else
            local engineDoor = vehicle:getPartById("EngineDoor")
            menu:addSlice(getText("ContextMenu_CDOI_closeHood"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseExternalDoor, playerObj, vehicle, engineDoor)
        end
    end
end


function ISVehicleMenu.showRadialMenuOutside(playerObj)
    ISVehicleMenu.CDOI_showRadialMenuOutside(playerObj);
    if playerObj:getVehicle() then return end

    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)

    if vehicle then
        if ISVehicleDashboard:isAnyDoorOpen(vehicle) then
            -- TODO: Should this path to each door?
            menu:addSlice(getText("ContextMenu_CDOI_closeDoors"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseAllDoors, playerObj, vehicle);
        end

        local useablePart = vehicle:getUseablePart(playerObj)

        if ISVehicleDashboard:isTrunkOpen(vehicle) then
            local trunkDoor = vehicle:getPartById("TrunkDoor") or vehicle:getPartById("DoorRear")
            if useablePart ~= trunkDoor then
                menu:addSlice(getText("ContextMenu_CDOI_closeTrunk"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseExternalDoor, playerObj, vehicle, trunkDoor)
            end
        end
        if ISVehicleDashboard:isHoodOpen(vehicle) then
            local engineDoor = vehicle:getPartById("EngineDoor")
            if useablePart ~= engineDoor then
                menu:addSlice(getText("ContextMenu_CDOI_closeHood"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onCloseExternalDoor, playerObj, vehicle, engineDoor)
            end
        end
    end
end


function ISVehicleMenu.onCloseAllDoors(playerObj, vehicle)
    for seat=1,vehicle:getMaxPassengers() do
        local part = vehicle:getPassengerDoor(seat-1)
		if part then
            local door = part:getDoor()
            if door and door:isOpen() then
                ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, vehicle, part))
            end
        end
    end
end


function ISVehicleMenu.onCloseExternalDoor(playerObj, vehicle, doorPart)
    if not doorPart or not doorPart:getDoor() or not doorPart:getDoor():isOpen() then
        return
    end

    if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end

    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, doorPart:getArea()))
    ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, vehicle, doorPart))
end
