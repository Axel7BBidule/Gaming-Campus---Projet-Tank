--Machine a état
local Tank_Etat = {}
Tank_Etat.NONE = ""
Tank_Etat.WALK = "WALK"
Tank_Etat.CHANGEDIR = "change_direction"
Tank_Etat.ATTACK = "ATTACK"
Tank_Etat.FOLLOW = "FOLLOW"

-- Fonction utilitaire pour calculer l'angle entre deux points
function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function math.dist(x1, y1, x2, y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

function StateMachine(pTank, dt)
    if pTank.target and pTank.vision then
        local player_distance = math.dist(pTank.x, pTank.y, pTank.target.x, pTank.target.y)
        if player_distance <= pTank.vision then
            pTank.last_fire = pTank.last_fire + dt
            if pTank.last_fire >= pTank.cooldownTir then
                pTank:fire()
                pTank.last_fire = 0
            end
            if player_distance > pTank.range_min then
                pTank.etat = Tank_Etat.FOLLOW
            else
                pTank.etat = Tank_Etat.ATTACK
            end
        else
            if pTank.etat ~= Tank_Etat.WALK then
                pTank.etat = Tank_Etat.CHANGEDIR
            end
        end
    end
    if pTank.etat == Tank_Etat.FOLLOW then
        local angle = math.angle(pTank.x, pTank.y, pTank.target.x, pTank.target.y)
        pTank.vx = pTank.speed * math.cos(angle)
        pTank.vy = pTank.speed * math.sin(angle)
        pTank.x = pTank.x + pTank.vx
        pTank.y = pTank.y + pTank.vy
    elseif pTank.etat == Tank_Etat.ATTACK then
        pTank.vx = 0
        pTank.vy = 0
    elseif pTank.etat == Tank_Etat.WALK then
        pTank.x = pTank.x + pTank.vx
        pTank.y = pTank.y + pTank.vy
        local Collision = false
        if pTank.x < 0 then
            pTank.x = 0
            Collision = true
        end
        if pTank.x > width then
            pTank.x = width
            Collision = true
        end
        if pTank.y < 0 then
            pTank.y = 0
            Collision = true
        end
        if pTank.y > height then
            pTank.y = height
            Collision = true
        end
        if Collision then
            pTank.etat = Tank_Etat.CHANGEDIR
        end
    elseif pTank.etat == Tank_Etat.CHANGEDIR or pTank.etat == Tank_Etat.NONE then
        local angle = math.angle(pTank.x, pTank.y, math.random(0, width), math.random(0, height))
        pTank.vx = pTank.speed * math.cos(angle)
        pTank.vy = pTank.speed * math.sin(angle)
        pTank.etat = Tank_Etat.WALK
    end
end
