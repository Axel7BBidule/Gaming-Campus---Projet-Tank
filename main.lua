--Fichiers liés
require("machineEtat")
require("entite")

--Constante
NUMBERS_ENEMY = math.random(4,10)
SPEED_BULLET = 300
SPEED_TANK_MAX = 1
SPEED_TANK_MIN = -1

--bullet
bullets = {}
coolDown = 0.2
last_fire = 1
-- Tableau de mes entités
LIST_ENTITIES = {}


--Souris 
mouse = {}
mouse.x = 0
mouse.y = 0
mouse.angle = 0



function love.load()
    --Calculer taille écran
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    player = CreateEntities("tank", "hero", width / 2, height / 2)

    CreateEnemies(NUMBERS_ENEMY)
    startTime = love.timer.getTime()
    victoryStats = {time = 0, enemiesKilled = 0, bulletsFired = 0, playerPV = 0}
end

--Etat du jeu
gameState = "menu"
-- Statistiques pour l'écran victoire
victoryStats = {time = 0, enemiesKilled = 0, bulletsFired = 0, playerPV = 0}

function love.update(dt)
    if gameState == "menu" then
        if love.keyboard.isDown("space") then
            gameState = "game"
            -- Reset du jeu
            LIST_ENTITIES = {}
            bullets = {}
            player = CreateEntities("tank", "hero", width / 2, height / 2)
            CreateEnemies(NUMBERS_ENEMY)
            startTime = love.timer.getTime()
            victoryStats = {time = 0, enemiesKilled = 0, bulletsFired = 0, playerPV = 0}
        end
        return
    elseif gameState == "end" then
        if love.keyboard.isDown("r") then
            gameState = "menu"
        end
        return
    elseif gameState == "victory" then
        if love.keyboard.isDown("r") then
            gameState = "menu"
        end
        return
    end
   
    -- Affiche l'aide au debug
    if love.keyboard.isDown("r") then
        info = true
    end

    if love.keyboard.isDown("t") then
        info = false
    end

    --Arrete le jeu
    if love.keyboard.isDown("escape") then
        gameState = "menu"
    end
    -- Gestion de l'accélération avant
    if love.keyboard.isDown("up") or love.keyboard.isDown("z") and  width > player.x then
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
    local offsetX = math.cos(math.rad(player.angle)) * player.velocity
    local offsetY = math.sin(math.rad(player.angle)) * player.velocity
    player.x = player.x + offsetX
    player.y = player.y + offsetY
    
    -- Empêche le héros de sortir de l'écran
    if player.x < 0 then player.x = 0 end
    if player.x > width then player.x = width end
    if player.y < 0 then player.y = 0 end
    if player.y > height then player.y = height end

    -- Mettre à jour la position de la souris
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()

    --Tire de bullet avec délai 
    last_fire = last_fire + dt
    if love.mouse.isDown(1) and last_fire >= coolDown then
        if player.bulletcount < 5  then
            FireBullet(player)
            player.bulletcount = player.bulletcount + 1
            last_fire = 0           
        end        
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
            player.bulletcount = player.bulletcount - 1
            table.remove(bullets, i)
        end
    end

    --Gestion collision sur ennemies
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
                        player.bulletcount = player.bulletcount - 1
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
                if player.pv <= 0 then
                    table.remove(LIST_ENTITIES,hero)
                end
            end
        end
    end
    

    -- Suppression du joueur si ses PV tombent à 0
    for i = #LIST_ENTITIES, 1, -1 do
        local entite = LIST_ENTITIES[i]
        if entite.type == "hero" and entite.pv <= 0 then
            table.remove(LIST_ENTITIES, i)
            gameState = "end"
        end
    end
    
    --Gestion comportement enemies
    for i, entite in ipairs(LIST_ENTITIES) do
        if entite.type == "pnjEnemie" then
            StateMachine(entite,dt)            
        end
    end

    -- Compter le nombre d'ennemis restants
    local enemiesLeft = 0
    for i, entite in ipairs(LIST_ENTITIES) do
        if entite.type == "pnjEnemie" then
            enemiesLeft = enemiesLeft + 1
        end
    end
    -- Si plus d'ennemis, victoire
    if enemiesLeft == 0 then
        gameState = "victory"
        victoryStats.time = math.floor(love.timer.getTime() - startTime)
        victoryStats.enemiesKilled = NUMBERS_ENEMY        
        victoryStats.playerPV = player.pv
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.printf("Appuyer sur SPACE pour jouer", 0, height/2, width, "center")
        return
    elseif gameState == "end" then
        love.graphics.printf("GAME OVER\nAppuyez sur R pour recommencer", 0, height/2, width, "center")
        return
    elseif gameState == "victory" then
        love.graphics.printf("VICTOIRE !\nAppuyez sur R pour rejouer\n\nTemps : " .. victoryStats.time .. "s\nEnnemis tués : " .. victoryStats.enemiesKilled .. "\nPV restants : " .. victoryStats.playerPV, 0, height/2-40, width, "center")
        return
    end

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
        -- Afficher le canon du joueur
        if entite.type == "hero" then
            love.graphics.setColor(0, 2, 0, 1)
            local dx = mouse.x - entite.x
            local dy = mouse.y - entite.y
            local dist = math.sqrt(dx*dx + dy*dy)
            local canonLength = 20
            local nx = entite.x + (dx/dist) * canonLength
            local ny = entite.y + (dy/dist) * canonLength
            love.graphics.setLineWidth(5)
            love.graphics.line(entite.x, entite.y, nx, ny)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(1, 1, 1, 1)
        end
        -- Affiche cercle de range ennemies
        if info == true and entite.type == "pnjEnemie" then
            love.graphics.setColor(1, 0, 0, 0.3) -- 
            love.graphics.circle("fill", entite.x, entite.y, entite.range)
            love.graphics.setColor(1, 1, 1, 1) 
        end
        --Affiche direction a atteindre aléatoire ennemies
        if info == true and entite.type == "pnjEnemie" and entite.walkTargetX and entite.walkTargetY then
            love.graphics.setColor(1, 1, 0, 1) 
            love.graphics.rectangle("fill", entite.walkTargetX-1, entite.walkTargetY-1, 2, 2)
            love.graphics.setColor(1, 1, 1, 1) 
        end
        --Affiche la dernière position connu du joueur 
        if info == true and entite.type == "pnjEnemie" and entite.lastSeenX and entite.lastSeenY then
            love.graphics.setColor(0, 0.5, 1, 1) -- bleu
            love.graphics.circle("fill", entite.lastSeenX, entite.lastSeenY, 6)
            love.graphics.setColor(1, 1, 1, 1) -- reset couleur
        end
        --Affiche l'état actuel de l'ennemie uniquement si info == true
        if info == true and entite.type == "pnjEnemie" then
            love.graphics.print("Etat : " .. entite.etat , entite.x - entite.size.x ,entite.y - entite.size.y)
        end
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
