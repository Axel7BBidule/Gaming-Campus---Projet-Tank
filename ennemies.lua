--Machine a état
local Tank_Etat = {}
Tank_Etat.NONE = "NONE"
Tank_Etat.WALK = "WALK"
Tank_Etat.CHANGEDIR = "CHANGE_DIRECTION"
Tank_Etat.ATTACK = "ATTACK"
Tank_Etat.SEARCH = "SEARCH LAST POSITION"


-- Fonction utilitaire pour calculer l'angle entre deux points
function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function math.dist(x1, y1, x2, y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

function StateMachine(pEnemies,dt)

    --Condition d'activation
local player_distance = math.dist(pEnemies.x, pEnemies.y, pEnemies.target.x, pEnemies.target.y)

if pEnemies.etat == Tank_Etat.SEARCH then
    
elseif player_distance < pEnemies.range then
    --Garde en mémoire la dernière position de mon héro
    pEnemies.lastSeenX = pEnemies.target.x
    pEnemies.lastSeenY = pEnemies.target.y
    pEnemies.etat = Tank_Etat.ATTACK
elseif player_distance > pEnemies.range and pEnemies.etat == Tank_Etat.ATTACK then
    pEnemies.etat = Tank_Etat.SEARCH
else 
    pEnemies.etat = Tank_Etat.WALK
end
  

    if pEnemies.etat == Tank_Etat.SEARCH then

        
    local angle = math.angle(pEnemies.x, pEnemies.y, pEnemies.lastSeenX, pEnemies.lastSeenY)
    pEnemies.vx = pEnemies.speed * math.cos(angle)
    pEnemies.vy = pEnemies.speed * math.sin(angle)
    pEnemies.x = pEnemies.x + pEnemies.vx
    pEnemies.y = pEnemies.y + pEnemies.vy
    -- Si la position est atteinte, repasse en WALK
    if math.dist(pEnemies.x, pEnemies.y, pEnemies.lastSeenX, pEnemies.lastSeenY) < 5 then
        pEnemies.etat = Tank_Etat.WALK
        pEnemies.lastSeenX = nil
        pEnemies.lastSeenY = nil
    end

    end    
    
    if pEnemies.etat == Tank_Etat.ATTACK then
        local angle = math.angle(pEnemies.x, pEnemies.y, pEnemies.target.x, pEnemies.target.y)
        pEnemies.vx = pEnemies.speed * math.cos(angle)
        pEnemies.vy = pEnemies.speed * math.sin(angle)
        pEnemies.x = pEnemies.x + pEnemies.vx
        pEnemies.y = pEnemies.y + pEnemies.vy
        -- Tirer sur le joueur si cooldown OK
        pEnemies.last_fire = pEnemies.last_fire + dt
        if pEnemies.last_fire >= pEnemies.cooldownTir then
            if pEnemies.fire then
                pEnemies:fire()
            else
                -- fallback si fire n'existe pas
                if FireBullet then
                    FireBullet(pEnemies)
                end
            end
            pEnemies.last_fire = 0
        end
    end
       
    if pEnemies.etat == Tank_Etat.CHANGEDIR then
        local angle = math.angle(pEnemies.x, pEnemies.y, math.random(0, width), math.random(0, height))
        pEnemies.vx = pEnemies.speed * math.cos(angle)
        pEnemies.vy = pEnemies.speed * math.sin(angle)
        pEnemies.etat = Tank_Etat.WALK
    end

    if pEnemies.etat == Tank_Etat.WALK then
    -- Si pas de cible ou cible atteinte, choisis un nouveau point aléatoire
    if not pEnemies.walkTargetX or math.dist(pEnemies.x, pEnemies.y, pEnemies.walkTargetX, pEnemies.walkTargetY) < 5 then
        pEnemies.walkTargetX = math.random(0, width)
        pEnemies.walkTargetY = math.random(0, height)
    end
    -- Va vers la cible
    local angle = math.angle(pEnemies.x, pEnemies.y, pEnemies.walkTargetX, pEnemies.walkTargetY)
    pEnemies.vx = pEnemies.speed * math.cos(angle)
    pEnemies.vy = pEnemies.speed * math.sin(angle)
    pEnemies.x = pEnemies.x + pEnemies.vx
    pEnemies.y = pEnemies.y + pEnemies.vy
    end

--Securisation de la machine à état
    if pEnemies.etat == Tank_Etat.NONE then
        pEnemies.etat = Tank_Etat.WALK
    end
--Detection collision
    local Collision = false
    if pEnemies.x < 0 then
        pEnemies.x = 0
        Collision = true
    end
    if pEnemies.x > width then
        pEnemies.x = width
        Collision = true
    end
    if pEnemies.y < 0 then
        pEnemies.y = 0
        Collision = true
    end
    if pEnemies.y > height then
        pEnemies.y = height
        Collision = true
    end
    if Collision == true then
        pEnemies.etat = Tank_Etat.CHANGEDIR
    end
   
end

