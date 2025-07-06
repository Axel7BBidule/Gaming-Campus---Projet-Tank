--Constante
NOMBRE_ENNEMIS = 2
VITESSE_MAX_TANK = 2
VITESSE_MIN_TANK = -1

-- Tableau de mes entités
listeDesEntites = {}

function CreerUneEntite(pImage, pType, pX, pY)
    local entite = {}
    entite.image = love.graphics.newImage("images/" .. pImage .. ".png")
    entite.taille = {x = entite.image:getWidth(), y = entite.image:getHeight()}
    entite.type = pType
    entite.x = pX
    entite.y = pY
    entite.angle = 0
    entite.vitesseActuelle = 0
    entite.vitesseMax = VITESSE_MAX_TANK
    entite.vitesseMin = VITESSE_MIN_TANK
    entite.acceleration = 2

    table.insert(listeDesEntites, entite)
    return entite
end

function CreerEnnemis(n)
    for i = 1, n do
        CreerUneEntite("enemie", "pnjEnemie", math.random(100, 500), math.random(10, 100))
    end
end

--Balle
balles = {}
coolDown = 1
tempsDepuisDernierTir = 1

souris = {}
souris.x = 0
souris.y = 0
souris.angle = 0

function tirerBalle(entite)
    local balle = {}
    balle.x = entite.x
    balle.y = entite.y
    -- Calcul de l'angle entre le tank et la souris
    balle.angle = math.deg(math.atan2(souris.y - entite.y, souris.x - entite.x))
    balle.vitesse = 250
    table.insert(balles, balle)
end

function love.load()
    --Calculer taille écran
    largeur = love.graphics.getWidth()
    hauteur = love.graphics.getHeight()

    joueur = CreerUneEntite("tank", "hero", largeur / 2, hauteur / 2)

    CreerEnnemis(NOMBRE_ENNEMIS)
end

function love.update(dt)
    -- Gestion de l'accélération avant
    if love.keyboard.isDown("up") then
        joueur.vitesseActuelle = joueur.vitesseActuelle + joueur.acceleration * dt / 2
        if joueur.vitesseActuelle > joueur.vitesseMax then
            joueur.vitesseActuelle = joueur.vitesseMax
        end
    elseif joueur.vitesseActuelle > 0 then
        joueur.vitesseActuelle = joueur.vitesseActuelle - joueur.acceleration * dt / 2
        if joueur.vitesseActuelle < 0 then
            joueur.vitesseActuelle = 0
        end
    end

    -- Gestion de la marche arrière
    if love.keyboard.isDown("down") then
        joueur.vitesseActuelle = joueur.vitesseActuelle - joueur.acceleration * dt
        if joueur.vitesseActuelle < joueur.vitesseMin then
            joueur.vitesseActuelle = joueur.vitesseMin
        end
    elseif joueur.vitesseActuelle < 0 then
        joueur.vitesseActuelle = joueur.vitesseActuelle + joueur.acceleration * dt / 2
        if joueur.vitesseActuelle > 0 then
            joueur.vitesseActuelle = 0
        end
    end

    -- Gestion de la rotation
    if love.keyboard.isDown("left") then
        joueur.angle = joueur.angle - 90 * dt

        --Permet de rester entre -0 et -360
        if joueur.angle <= -360 then
            joueur.angle = 0
        end
    end

    if love.keyboard.isDown("right") then
        joueur.angle = joueur.angle + 90 * dt

        --Permet de rester entre 0 et 360
        if joueur.angle >= 360 then
            joueur.angle = 0
        end
    end

    -- Appliquer le déplacement
    joueur.velocite = joueur.vitesseActuelle
    offsetX = math.cos(math.rad(joueur.angle)) * joueur.velocite
    offsetY = math.sin(math.rad(joueur.angle)) * joueur.velocite
    joueur.x = joueur.x + offsetX
    joueur.y = joueur.y + offsetY

    -- Mettre à jour la position de la souris
    souris.x = love.mouse.getX()
    souris.y = love.mouse.getY()

    --Tire de balle avec délai (coolDown)
    tempsDepuisDernierTir = tempsDepuisDernierTir + dt
    if love.keyboard.isDown("space") and tempsDepuisDernierTir >= coolDown and #balles < 5 then
        tirerBalle(joueur)
        tempsDepuisDernierTir = 0
    end

    --Gestion du mouvement des balles
    for i, balle in ipairs(balles) do
        balle.x = balle.x + math.cos(math.rad(balle.angle)) * balle.vitesse * dt
        balle.y = balle.y + math.sin(math.rad(balle.angle)) * balle.vitesse * dt
    end

    --Gestion suppression des Balles
    for i = #balles, 1, -1 do
        local balle = balles[i]
        if balle.x < 0 or balle.x > largeur or balle.y < 0 or balle.y > hauteur then
            table.remove(balles, i)
        end
    end

    --Gestion collision avec la Balle

    --Gestion comportement enemies
end

function love.draw()
    --Afficher Informations
    love.graphics.print("Vitesse tank : " .. joueur.vitesseActuelle, 1, 1)
    love.graphics.print("Angle tank : " .. math.floor(joueur.angle), 1, 15)
    love.graphics.print("X du tank : " .. math.floor(joueur.x), 1, 30)
    love.graphics.print("Y du tank : " .. math.floor(joueur.y), 1, 45)
    love.graphics.print("Nombre de balle : " .. #balles, 1, 60)
    love.graphics.print("Position souris : " .. souris.x .. " | " .. souris.y, 1, 75)

    --Afficher les entités
    for i, entite in ipairs(listeDesEntites) do
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

    --Afficher le tire/la balle
    for i, balle in ipairs(balles) do
        love.graphics.circle("fill", balle.x, balle.y, 5)
    end
end
