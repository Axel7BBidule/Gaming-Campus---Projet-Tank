function CreateEntities(pImage, pType, pX, pY)
    local entite = {}
    entite.image = love.graphics.newImage("images/" .. pImage .. ".png")
    entite.size = {x = entite.image:getWidth(), y = entite.image:getHeight()}
    entite.type = pType
    entite.x = pX
    entite.y = pY
    entite.vx = 0
    entite.vy = 0
    entite.angle = 0
    entite.speed = 0.3
    entite.actual_speed = 0
    entite.speed_max = SPEED_TANK_MAX
    entite.speed_min = SPEED_TANK_MIN
    entite.bulletcount = 0
    entite.acceleration = 1
    entite.vision = 200 --
    entite.pv = 10
    entite.etat = ""
    entite.level = 1
    if pType == "pnjEnemie" then
        entite.range = math.random(150, 250)
        entite.cooldownTir = 2
        entite.last_fire = 0
        entite.target = player
        entite.walkTargetX = nil
        entite.walkTargetY = nil
        entite.lastSeenX = nil
        entite.lastSeenY = nil
        
        function entite:fire()
            local bullet = {}
            bullet.x = self.x
            bullet.y = self.y
            local angle = math.atan2(player.y - self.y, player.x - self.x)
            bullet.angle = math.deg(angle)
            bullet.speed = SPEED_BULLET
            bullet.source = "ennemi"
            table.insert(bullets, bullet)
        end
    end
    table.insert(LIST_ENTITIES, entite)
    return entite
end

function CreateEnemies(n)
    for i = 1, n do
        local ennemi = CreateEntities("enemie", "pnjEnemie", math.random(100, 500), math.random(10, 100))
        ennemi.target = player
    end
end

function FireBullet(entite)
    local bullet = {}
    bullet.x = entite.x
    bullet.y = entite.y
    bullet.angle = math.deg(math.atan2(mouse.y - entite.y, mouse.x - entite.x))
    bullet.speed = SPEED_BULLET
    bullet.source = "player"
    bullet.count = 0
    table.insert(bullets, bullet)
    
end