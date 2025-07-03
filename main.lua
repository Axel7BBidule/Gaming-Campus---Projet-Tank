-- Tableau de mon tank
tank = {}
tank.image = love.graphics.newImage("images/tank.png")
tank.taille = {x = tank.image:getWidth(), y = tank.image:getHeight()}
tank.x = 1
tank.y = 1
tank.angle = 0
tank.velocite = 0
tank.vitesse = 100
tank.acceleration = 2

--Balle
balles = {}
coolDown = 1
tempsDepuisDernierTir = 1

function tirerBalle()
    local balle = {}
    balle.x = tank.x
    balle.y = tank.y
    balle.angle = tank.angle
    balle.vitesse = 50
    table.insert(balles, balle)
end

function love.load()
    --Calculer taille écran
    largeur = love.graphics.getWidth()
    hauteur = love.graphics.getHeight()
    -- positionner tank au milieu
    tank.x = largeur / 2
    tank.y = hauteur / 2
end

function love.update(dt)
    --INPUT
    local orientation
    local tire

    if love.keyboard.isDown("up") then
        orientation = "haut"
    elseif love.keyboard.isDown("down") then
        orientation = "bas"
    elseif love.keyboard.isDown("right") then
        orientation = "droite"
    elseif love.keyboard.isDown("left") then
        orientation = "gauche"
    end

    --Controler le tank

    if orientation == "bas" then
        tank.velocite = -tank.vitesse * dt
    elseif orientation == "haut" then
        tank.velocite = tank.vitesse * dt
    end

    if orientation == "gauche" then
        tank.angle = tank.angle - 90 * dt
        if tank.angle <= 0 and tank.angle <= -360 then
            tank.angle = 0
        end
    elseif orientation == "droite" then
        tank.angle = tank.angle + 90 * dt
        if tank.angle >= 360 then
            tank.angle = 0
        end
    end
    --Tire de balle avec délai (coolDown)
    tempsDepuisDernierTir = tempsDepuisDernierTir + dt
    if love.keyboard.isDown("space") and tempsDepuisDernierTir >= coolDown and #balles < 5 then
        tirerBalle()
        tempsDepuisDernierTir = 0
    end

    --Gestion du mouvement du tank avec Sinus et Cosinus

    offsetX = math.cos(math.rad(tank.angle)) * tank.velocite
    offsetY = math.sin(math.rad(tank.angle)) * tank.velocite
    tank.x = tank.x + offsetX
    tank.y = tank.y + offsetY

    --Gestion du mouvement des balles
    for i, balle in ipairs(balles) do
        balle.x = balle.x + math.cos(math.rad(balle.angle)) * balle.vitesse * dt
        balle.y = balle.y + math.sin(math.rad(balle.angle)) * balle.vitesse * dt
    end
end

function love.draw()
    --Afficher Informations
    love.graphics.print("Vitesse tank : " .. tank.velocite, 1, 1)
    love.graphics.print("Angle tank : " .. math.floor(tank.angle), 1, 15)
    love.graphics.print("X du tank : " .. math.floor(tank.x), 1, 30)
    love.graphics.print("Y du tank : " .. math.floor(tank.y), 1, 45)

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
    --Afficher le tire/la balle
    for i, balle in ipairs(balles) do
        love.graphics.circle("fill", balle.x, balle.y, 5)
    end
end
