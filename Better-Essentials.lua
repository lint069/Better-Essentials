--// lint0 | v1.0.0

local settings = nil
local sim = ac.getSim()
local car = ac.getCar(0)
if car == nil then return end

settings = ac.storage{
    usemph = false
}

local function get_asset(name)
    return string.format("apps/lua/Better-Essentials/assets/%s.png", name)
end

local function is_inside(to_check, area_center, area_half_size)
    if to_check.x < area_center.x - area_half_size.x then return false end
    if to_check.x > area_center.x + area_half_size.x then return false end
    if to_check.y < area_center.y - area_half_size.y then return false end
    if to_check.y > area_center.y + area_half_size.y then return false end
    return true
end

---@param c1 rgbm
---@param c2 rgbm
---@param t number
local function color_lerp(c1, c2, t)
    return rgbm(
        math.lerp(c1.r, c2.r, t),
        math.lerp(c1.g, c2.g, t),
        math.lerp(c1.b, c2.b, t),
        math.lerp(c1.mult, c2.mult, t)
    )
end

function script.windowMain(dt)

    local gear  = car.gear
    local maxfuel = car.maxFuel
    local fuel = car.fuel
    local rpmlimit = car.rpmLimiter
    local rpm = car.rpm
    local textsize = 17
    local lineheight = 80
    local red = rgbm(1, 0.12, 0.12, 1)

    ui.image(get_asset("background"), vec2(650, 110), rgbm(1, 1, 1, 0.4), nil, vec2(0, 0), vec2(1, 1))

    --// logo/close button
    ui.drawImage(get_asset("ac_logo"), vec2(8, 4), vec2(40, 36))
    if is_inside(ui.mouseLocalPos(), vec2(23, 16), vec2(16, 15)) then
        ui.setMouseCursor(ui.MouseCursor.Hand)
        if ui.mouseClicked(ui.MouseButton.Left) then
            ac.setWindowOpen("BetterEssentials", false)
        end
    end

    --// GEAR
    local gear_num_color = rgbm(1,1,1,1)
    local offset = 0

    if rpm >= rpmlimit - 320 then
        gear_num_color = red
    end

    if gear == 0 then
        gear = 'N'
        offset = -4
    elseif gear == -1 then
        gear = 'R'
        offset = -3
    end

    ui.dwriteDrawText("Gear", textsize, vec2(310, lineheight))
    ui.dwriteDrawText(tostring(gear), 60, vec2(310 + offset, 2), gear_num_color)

    --// SPEED
    local speed = math.floor(car.speedKmh * (settings.usemph and 0.6213711922 or 1))
    ui.dwriteDrawText(settings.usemph and "mph" or "km/h", textsize, vec2(390, lineheight))
    ui.dwriteDrawText(tostring(speed), 35, vec2(388, 35))

    --// RPMBAR
    local rpm_limiter = math.clamp(rpm / rpmlimit * 136, 0, 136)
    local rpm_color = rgbm(0.3, 0.8, 0.4, 1)

    if rpm >= rpmlimit - 320 then
        rpm_color = red
    end

    ui.dwriteDrawText("rpms", textsize, vec2(175, lineheight))
    ui.drawRect(vec2(125, 60), vec2(265, 75), rgbm(1, 1, 1, 0.6), 30, ui.CornerFlags.All)
    ui.drawRectFilled(vec2(127, 62), vec2(128 + rpm_limiter, 73), rpm_color, 30, ui.CornerFlags.All)

    --// FUELBAR
    local t = math.clamp(fuel / maxfuel, 0, 1)
    local fuel_color = rgbm(0,0,0,0)
    local f_start = 22
    local f_end = 98
    local f_width = f_end - f_start

    if t < 0.5 then
        fuel_color = color_lerp(red, rgbm(0.3, 1, 0.4, 0.9), t * 2)
    else
        fuel_color = color_lerp(rgbm(0.3, 1, 0.4, 0.9), rgbm(0.3, 1, 0.4, 0.9), (t - 0.5) * 2)
    end

    -- get opinions
    if fuel < 9 and sim.frame % 120 < 40 then
        fuel_color = rgbm(1, 0, 0, 1)
    end

    ui.dwriteDrawText("fuel", textsize, vec2(45, lineheight))
    ui.drawRect(vec2(20, 60), vec2(100, 75), rgbm(1, 1, 1, 0.6), 30, ui.CornerFlags.All)
    ui.drawRectFilled(vec2(f_start, 62), vec2(f_start + f_width * t, 73), fuel_color, 30, ui.CornerFlags.All)

    --// TIME
    local last_laptime = ac.lapTimeToString(car.previousLapTimeMs, true)
    ui.dwriteDrawText("last lap", textsize, vec2(500, lineheight))
    ui.dwriteDrawText(string.format("%s", last_laptime), 25, vec2(498, 45))
end