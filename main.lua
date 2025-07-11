--Fichiers liés
require("ennemies")

--Constante
NUMBERS_ENEMY = 6
SPEED_BULLET = 100
SPEED_TANK_MAX = 1
SPEED_TANK_MIN = -1

--bullet
local bullets = {}
local coolDown = 1
local last_fire = 1
-- Tableau de mes entités
LIST_ENTITIES = {}

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
    entite.speed = 0.5
    entite.actual_speed = 0
    entite.speed_max = SPEED_TANK_MAX
    entite.speed_min = SPEED_TANK_MIN
    entite.acceleration = 1
    entite.vision = 200 --
    entite.pv = 10
    entite.etat = ""
    if pType == "pnjEnemie" then
        entite.range_min = math.random(10, 20)
        entite.cooldownTir = 2
        entite.last_fire = 0
        entite.target = player -- sera mis à jour dans love.load
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



local mouse = {}
mouse.x = 0
mouse.y = 0
mouse.angle = 0

function FireBullet(entite)
    local bullet = {}
    bullet.x = entite.x
    bullet.y = entite.y
    bullet.angle = math.deg(math.atan2(mouse.y - entite.y, mouse.x - entite.x))
    bullet.speed = SPEED_BULLET
    bullet.source = "player"
    table.insert(bullets, bullet)
end

function love.load()
    --Calculer taille écran
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    player = CreateEntities("tank", "hero", width / 2, height / 2)

    CreateEnemies(NUMBERS_ENEMY)
end

function love.update(dt)
    -- Affiche l'aide au debug
    if love.keyboard.isDown("r") then
        info = true
    end

    if love.keyboard.isDown("t") then
        info = false
    end

    -- Gestion de l'accélération avant
    if love.keyboard.isDown("up") or love.keyboard.isDown("z") then
        player.actual_speed = player.actual_speed + player.acceleration * dt / 2
        if player.actual_speed > player.speed_max then
            player.actual_speed = player.speed_max
        end
    elseif player.actual_speed > 0 then
        player.actual_speed = player.actual_speed - player.acceleration * dt / 2
        if player.actual_speed < 0 then
            player.actual_speed = 0
        end
    end

    -- Gestion de la marche arrière
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.actual_speed = player.actual_speed - player.acceleration * dt
        if player.actual_speed < player.speed_min then
            player.actual_speed = player.speed_min
        end
    elseif player.actual_speed < 0 then
        player.actual_speed = player.actual_speed + player.acceleration * dt / 2
        if player.actual_speed > 0 then
            player.actual_speed = 0
        end
    end

    -- Gestion de la rotation
    if love.keyboard.isDown("left") or love.keyboard.isDown("q") then
        player.angle = player.angle - 90 * dt

        --Permet de rester entre -0 et -360
        if player.angle <= -360 then
            player.angle = 0
        end
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.angle = player.angle + 90 * dt

        --Permet de rester entre 0 et 360
        if player.angle >= 360 then
            player.angle = 0
        end
    end

    -- Appliquer le déplacement
    player.velocity = player.actual_speed
    offsetX = math.cos(math.rad(player.angle)) * player.velocity
    offsetY = math.sin(math.rad(player.angle)) * player.velocity
    player.x = player.x + offsetX
    player.y = player.y + offsetY

    -- Mettre à jour la position de la mouse
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()

    --Tire de bullet avec délai (coolDown)
    last_fire = last_fire + dt
    if love.mouse.isDown(1) and last_fire >= coolDown and #bullets < 5 then
        FireBullet(player)
        last_fire = 0
    end

    --Gestion du mouvement des bullets
    for i, bullet in ipairs(bullets) do
        bullet.x = bullet.x + math.cos(math.rad(bullet.angle)) * bullet.speed * dt
        bullet.y = bullet.y + math.sin(math.rad(bullet.angle)) * bullet.speed * dt
    end

    --Gestion suppression des bullets
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        if bullet.x < 0 or bullet.x > width or bullet.y < 0 or bullet.y > height then
            table.remove(bullets, i)
        end
    end

    --Gestion collision
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        if bullet.source == "player" then
            for n = #LIST_ENTITIES, 1, -1 do
                local entite = LIST_ENTITIES[n]
                if entite.type == "pnjEnemie" then
                    if
                        bullet.x > entite.x - entite.size.x / 2 and bullet.x < entite.x + entite.size.x / 2 and
                            bullet.y > entite.y - entite.size.y / 2 and
                            bullet.y < entite.y + entite.size.y / 2
                     then
                        table.remove(bullets, i)
                        entite.pv = entite.pv - 1
                        if entite.pv <= 0 then
                            table.remove(LIST_ENTITIES, n)
                        end
                        break
                    end
                end
            end
        elseif bullet.source == "ennemi" then
            -- Collision bullet
            if
                bullet.x > player.x - player.size.x / 2 and bullet.x < player.x + player.size.x / 2 and
                    bullet.y > player.y - player.size.y / 2 and
                    bullet.y < player.y + player.size.y / 2
             then
                table.remove(bullets, i)
                player.pv = player.pv - 1
            end
        end
    end

    --Gestion comportement enemies
    for i, entite in ipairs(LIST_ENTITIES) do
        if entite.type == "pnjEnemie" then
            StateMachine(entite, dt)
        end
    end
end

function love.draw()
    if info == true then
        --Afficher Informations
        love.graphics.print("speed tank : " .. player.actual_speed, 1, 1)
        love.graphics.print("Angle tank : " .. math.floor(player.angle), 1, 15)
        love.graphics.print("X du tank : " .. math.floor(player.x), 1, 30)
        love.graphics.print("Y du tank : " .. math.floor(player.y), 1, 45)
        love.graphics.print("Nombre de bullet : " .. #bullets, 1, 60)
    end

    --Afficher les entités
    for i, entite in ipairs(LIST_ENTITIES) do
        love.graphics.draw(
            entite.image,
            entite.x,
            entite.y,
            math.rad(entite.angle),
            1,
            1,
            entite.image:getWidth() / 2,
            entite.image:getHeight() / 2
        )
    end

    --Afficher le tire/la bullet
    for i, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.x, bullet.y, 5)
    end
    --Afficher PV ennemie
    for i, entite in ipairs(LIST_ENTITIES) do
        love.graphics.print("PV : " .. entite.pv, entite.x + (entite.size.x / 2), entite.y + (entite.size.y / 2))
    end
end
