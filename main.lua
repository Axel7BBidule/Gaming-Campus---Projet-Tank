--Test de commit

-- Tableau de mon tank
tank = {}
tank.image = love.graphics.newImage("images/tank.png")
tank.taille = {x = tank.image:getWidth(), y = tank.image:getHeight()}
tank.x = 1
tank.y = 1
tank.vx = 0
tank.vy = 0
tank.angle = 0
tank.vitesse = 0
tank.vitesseMax = 100
tank.acceleration = 2

function love.load()
    --Calculer taille écran
    largeur = love.graphics.getWidth()
    hauteur = love.graphics.getHeight()
    -- positionner tank au milieu
    tank.x = largeur / 2
    tank.y = hauteur / 2
end

function love.update(dt)
    --Controler le tank
    if love.keyboard.isDown("up") then
        tank.vitesse = tank.vitesse + tank.acceleration
    end

    if love.keyboard.isDown("down") then
        tank.vitesse = tank.vitesse - tank.acceleration
    end

    if love.keyboard.isDown("right") then
        tank.angle = tank.angle + 90 * dt
        --Rotation augmentée si on est à 0 en vitesse
        if tank.vitesse == 0 then
            tank.angle = tank.angle + 100 * dt
        end
    end

    if love.keyboard.isDown("left") then
        tank.angle = tank.angle - 90 * dt
        --Rotation augmentée si on est à 0 en vitesse
        if tank.vitesse == 0 then
            tank.angle = tank.angle - 100 * dt
        end
    end
    -- arreter le tank
    if love.keyboard.isDown("space") then
        tank.vitesse = 0
    end

    --Limiter la vitesse--
    if tank.vitesse > tank.vitesseMax then
        tank.vitesse = tank.vitesseMax
    end

    if tank.vitesse < -50 then
        tank.vitesse = -50
    end

    --Gestion de l'angle :  pour avancer en fonction de l'angle (atelier Space)
    local angle_rad = math.rad(tank.angle)
    tank.vx = math.cos(angle_rad) * tank.vitesse
    tank.vy = math.sin(angle_rad) * tank.vitesse
    tank.x = tank.x + tank.vx * dt
    tank.y = tank.y + tank.vy * dt

    --Gestion des bordures d'écran pour ne pas que le tank sorte
    if tank.x + tank.image:getWidth() / 2 > largeur then
        tank.x = largeur - tank.image:getWidth() / 2
    end

    if tank.x - tank.image:getWidth() / 2 < 0 then
        tank.x = 0 + tank.image:getWidth() / 2
    end

    if tank.y - tank.image:getHeight() / 2 < 0 then
        tank.y = 0 + tank.image:getHeight() / 2
    end

    if tank.y + tank.image:getHeight() / 2 > hauteur then
        tank.y = hauteur - tank.image:getHeight() / 2
    end
end

function love.draw()
    --Afficher Informations
    love.graphics.print("Vitesse tank : " .. tank.vitesse, 1, 1)
    love.graphics.print("Angle tank : " .. math.floor(tank.angle), 1, 15)
    love.graphics.print("X du tank : " .. math.floor(tank.x), 1, 30)
    love.graphics.print("Y du tank : " .. math.floor(tank.y), 1, 45)
    love.graphics.print("Espace pour mettre la vitesse à 0", largeur - 250, 1)

    love.graphics.print("Taille X : " .. tank.taille.x, 1, 60)
    love.graphics.print("Taille Y : " .. tank.taille.y, 1, 75)

    --Afficher le tank
    love.graphics.draw(
        tank.image, --Charger l'image
        tank.x, --Position X
        tank.y, --Position Y
        math.rad(tank.angle), --Rotation
        1, --Zoom
        1,
        tank.image:getWidth() / 2, --Point d'origine X
        tank.image:getHeight() / 2 --Point d'origine Y
    )
end
