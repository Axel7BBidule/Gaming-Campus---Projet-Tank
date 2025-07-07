--Machine a état
local Tank_Etat = {}
Tank_Etat.NONE = ""
Tank_Etat.MARCHE = "marche"
Tank_Etat.CHANGEDIR = "change_direction"
Tank_Etat.ATTAQUE = "attaque"
Tank_Etat.SUIVRE = "suivre"

-- Fonction utilitaire pour calculer l'angle entre deux points
function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function math.dist(x1, y1, x2, y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

function machineEtat(pTank, dt)
    if pTank.cible and pTank.vision then
        local distJoueur = math.dist(pTank.x, pTank.y, pTank.cible.x, pTank.cible.y)
        if distJoueur <= pTank.vision then
            pTank.tempsDepuisDernierTir = pTank.tempsDepuisDernierTir + dt
            if pTank.tempsDepuisDernierTir >= pTank.cooldownTir then
                pTank:tirer()
                pTank.tempsDepuisDernierTir = 0
            end
            if distJoueur > pTank.distance_min then
                pTank.etat = Tank_Etat.SUIVRE
            else
                pTank.etat = Tank_Etat.ATTAQUE
            end
        else
            if pTank.etat ~= Tank_Etat.MARCHE then
                pTank.etat = Tank_Etat.CHANGEDIR
            end
        end
    end
    if pTank.etat == Tank_Etat.SUIVRE then
        local angle = math.angle(pTank.x, pTank.y, pTank.cible.x, pTank.cible.y)
        pTank.vx = pTank.vitesse * math.cos(angle)
        pTank.vy = pTank.vitesse * math.sin(angle)
        pTank.x = pTank.x + pTank.vx
        pTank.y = pTank.y + pTank.vy
    elseif pTank.etat == Tank_Etat.ATTAQUE then
        pTank.vx = 0
        pTank.vy = 0
    elseif pTank.etat == Tank_Etat.MARCHE then
        pTank.x = pTank.x + pTank.vx
        pTank.y = pTank.y + pTank.vy
        local Collision = false
        if pTank.x < 0 then
            pTank.x = 0
            Collision = true
        end
        if pTank.x > largeur then
            pTank.x = largeur
            Collision = true
        end
        if pTank.y < 0 then
            pTank.y = 0
            Collision = true
        end
        if pTank.y > hauteur then
            pTank.y = hauteur
            Collision = true
        end
        if Collision then
            pTank.etat = Tank_Etat.CHANGEDIR
        end
    elseif pTank.etat == Tank_Etat.CHANGEDIR or pTank.etat == Tank_Etat.NONE then
        local angle = math.angle(pTank.x, pTank.y, math.random(0, largeur), math.random(0, hauteur))
        pTank.vx = pTank.vitesse * math.cos(angle)
        pTank.vy = pTank.vitesse * math.sin(angle)
        pTank.etat = Tank_Etat.MARCHE
    end
end
