--Fichiers liés
require("ennemies")

--Constante
NOMBRE_ENNEMIS = 6
VITESSE_BALLE = 100
VITESSE_MAX_TANK = 1
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
    entite.vx = 0
    entite.vy = 0
    entite.angle = 0
    entite.vitesse = 0.5
    entite.vitesseActuelle = 0
    entite.vitesseMax = VITESSE_MAX_TANK
    entite.vitesseMin = VITESSE_MIN_TANK
    entite.acceleration = 1
    entite.vision = 200 --
    entite.pv = 10
    entite.etat = ""
    if pType == "pnjEnemie" then
        entite.distance_min = math.random(10, 20)
        entite.cooldownTir = 2
        entite.tempsDepuisDernierTir = 0
        entite.cible = joueur -- sera mis à jour dans love.load
        function entite:tirer()
            local balle = {}
            balle.x = self.x
            balle.y = self.y
            local angle = math.atan2(joueur.y - self.y, joueur.x - self.x)
            balle.angle = math.deg(angle)
            balle.vitesse = VITESSE_BALLE
            balle.source = "ennemi"
            table.insert(balles, balle)
        end
    end
    table.insert(listeDesEntites, entite)
    return entite
end

function CreerEnnemis(n)
    for i = 1, n do
        local ennemi = CreerUneEntite("enemie", "pnjEnemie", math.random(100, 500), math.random(10, 100))
        ennemi.cible = joueur
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
    balle.angle = math.deg(math.atan2(souris.y - entite.y, souris.x - entite.x))
    balle.vitesse = VITESSE_BALLE
    balle.source = "joueur"
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
    if love.keyboard.isDown("up") or love.keyboard.isDown("z") then
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
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
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
    if love.keyboard.isDown("left") or love.keyboard.isDown("q") then
        joueur.angle = joueur.angle - 90 * dt

        --Permet de rester entre -0 et -360
        if joueur.angle <= -360 then
            joueur.angle = 0
        end
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
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
    if love.mouse.isDown(1) and tempsDepuisDernierTir >= coolDown and #balles < 5 then
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

    --Gestion collision
    for i = #balles, 1, -1 do
        local balle = balles[i]
        if balle.source == "joueur" then
            for n = #listeDesEntites, 1, -1 do
                local entite = listeDesEntites[n]
                if entite.type == "pnjEnemie" then
                    if
                        balle.x > entite.x - entite.taille.x / 2 and balle.x < entite.x + entite.taille.x / 2 and
                            balle.y > entite.y - entite.taille.y / 2 and
                            balle.y < entite.y + entite.taille.y / 2
                     then
                        table.remove(balles, i)
                        entite.pv = entite.pv - 1
                        if entite.pv <= 0 then
                            table.remove(listeDesEntites, n)
                        end
                        break
                    end
                end
            end
        elseif balle.source == "ennemi" then
            -- Collision balle
            if
                balle.x > joueur.x - joueur.taille.x / 2 and balle.x < joueur.x + joueur.taille.x / 2 and
                    balle.y > joueur.y - joueur.taille.y / 2 and
                    balle.y < joueur.y + joueur.taille.y / 2
             then
                table.remove(balles, i)
                joueur.pv = joueur.pv - 1
            end
        end
    end

    --Gestion comportement enemies
    for i, entite in ipairs(listeDesEntites) do
        if entite.type == "pnjEnemie" then
            machineEtat(entite, dt)
        end
    end
end

function love.draw()
    --Afficher Informations
    love.graphics.print("Vitesse tank : " .. joueur.vitesseActuelle, 1, 1)
    love.graphics.print("Angle tank : " .. math.floor(joueur.angle), 1, 15)
    love.graphics.print("X du tank : " .. math.floor(joueur.x), 1, 30)
    love.graphics.print("Y du tank : " .. math.floor(joueur.y), 1, 45)
    love.graphics.print("Nombre de balle : " .. #balles, 1, 60)

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
    --Afficher PV ennemie
    for i, entite in ipairs(listeDesEntites) do
        love.graphics.print("PV : " .. entite.pv, entite.x + (entite.taille.x / 2), entite.y + (entite.taille.y / 2))
    end
end
