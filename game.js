// =====================================================
// EGG FOOTBALL - JOGO COMPLETO
// =====================================================

// VARIÁVEIS GLOBAIS
let canvas = document.getElementById('gameCanvas');
let ctx = canvas.getContext('2d');
let gameMode = null; // 'casual', 'ranked', 'training'
let playersPerTeam = 1;
let gameRunning = false;
let gamePaused = false;
let timeLeft = 180; // 3 minutos em segundos
let timerInterval = null;

// RANKING (localStorage)
let ranking = JSON.parse(localStorage.getItem('eggFootballRanking')) || {};

// DIMENSÕES DO CAMPO - variam conforme jogadores
let fieldConfig = {
    1: { width: 600, height: 350, teams: 1 },
    2: { width: 700, height: 400, teams: 2 },
    3: { width: 800, height: 450, teams: 3 },
    4: { width: 900, height: 500, teams: 4 },
    5: { width: 1000, height: 600, teams: 5 }
};

let game = {
    fieldWidth: 600,
    fieldHeight: 350,
    fieldX: 200,
    fieldY: 125
};

// BOLA
let ball = {
    x: 400,
    y: 300,
    radius: 8,
    vx: 0,
    vy: 0,
    friction: 0.98,
    owner: null // qual equipa tem a bola
};

// JOGADORES
let players = {
    team1: [],
    team2: []
};

let score = {
    team1: 0,
    team2: 0
};

let ballControl = {
    hasControl: false,
    controlTeam: null,
    controlPlayer: null,
    lastBallX: 0,
    lastBallY: 0
};

// =====================================================
// FUNÇÕES DE MENU
// =====================================================

function showMenu(menuId) {
    document.querySelectorAll('.menu-screen, .game-screen').forEach(el => {
        el.classList.remove('active');
    });
    document.getElementById(menuId).classList.add('active');
}

function initGameMode(mode) {
    gameMode = mode;
    showMenu('modeSelection');
}

function backToMenu() {
    if (timerInterval) clearInterval(timerInterval);
    gameRunning = false;
    score.team1 = 0;
    score.team2 = 0;
    timeLeft = 180;
    showMenu('menuInicial');
}

function playAgain() {
    startGame(playersPerTeam);
}

// =====================================================
// INICIALIZAR JOGO
// =====================================================

function startGame(numPlayers) {
    playersPerTeam = numPlayers;
    
    // Configurar campo
    let config = fieldConfig[numPlayers];
    game.fieldWidth = config.width;
    game.fieldHeight = config.height;
    game.fieldX = (canvas.width - game.fieldWidth) / 2;
    game.fieldY = (canvas.height - game.fieldHeight) / 2;
    
    // Redimensionar canvas conforme necessário
    canvas.width = 1000;
    canvas.height = 600;

    // Resetar jogo
    score.team1 = 0;
    score.team2 = 0;
    timeLeft = 180;
    gameRunning = true;

    // Criar jogadores
    createPlayers(numPlayers);

    // Resetar bola no centro
    ball.x = game.fieldX + game.fieldWidth / 2;
    ball.y = game.fieldY + game.fieldHeight / 2;
    ball.vx = 0;
    ball.vy = 0;
    ball.owner = null;

    // Mostrar jogo
    showMenu('gameContainer');

    // Iniciar timer
    startTimer();

    // Loop de jogo
    gameLoop();
}

function createPlayers(numPlayers) {
    players.team1 = [];
    players.team2 = [];

    const positions = {
        1: [{ x: 0.3, y: 0.5 }],
        2: [
            { x: 0.2, y: 0.35 },
            { x: 0.2, y: 0.65 }
        ],
        3: [
            { x: 0.15, y: 0.25 },
            { x: 0.15, y: 0.5 },
            { x: 0.15, y: 0.75 }
        ],
        4: [
            { x: 0.15, y: 0.2 },
            { x: 0.15, y: 0.45 },
            { x: 0.15, y: 0.65 },
            { x: 0.15, y: 0.85 }
        ],
        5: [
            { x: 0.12, y: 0.15 },
            { x: 0.12, y: 0.35 },
            { x: 0.12, y: 0.5 },
            { x: 0.12, y: 0.65 },
            { x: 0.12, y: 0.85 }
        ]
    };

    const basePositions = positions[numPlayers];

    // Team 1 (esquerda)
    basePositions.forEach((pos, i) => {
        players.team1.push({
            id: i,
            x: game.fieldX + game.fieldWidth * pos.x,
            y: game.fieldY + game.fieldHeight * pos.y,
            radius: 12,
            vx: 0,
            vy: 0,
            color: '#FF6B6B',
            team: 1,
            speed: 2,
            hasBall: false
        });
    });

    // Team 2 (direita)
    basePositions.forEach((pos, i) => {
        players.team2.push({
            id: i,
            x: game.fieldX + game.fieldWidth * (1 - pos.x),
            y: game.fieldY + game.fieldHeight * pos.y,
            radius: 12,
            vx: 0,
            vy: 0,
            color: '#4169E1',
            team: 2,
            speed: 2,
            hasBall: false
        });
    });
}

// =====================================================
// TIMER
// =====================================================

function startTimer() {
    timerInterval = setInterval(() => {
        if (gameRunning) {
            timeLeft--;
            updateTimerDisplay();

            if (timeLeft <= 0) {
                endGame();
            }
        }
    }, 1000);
}

function updateTimerDisplay() {
    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    document.getElementById('timer').textContent = 
        `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

// =====================================================
// CONTROLES DO JOGO
// =====================================================

function shootBall() {
    if (!gameRunning) return;
    
    let player = getPlayerWithBall();
    if (!player) return;

    // Direção para o golo oposto
    let targetX = player.team === 1 ? 
        game.fieldX + game.fieldWidth - 30 : 
        game.fieldX + 30;
    let targetY = game.fieldY + game.fieldHeight / 2;

    let dx = targetX - ball.x;
    let dy = targetY - ball.y;
    let distance = Math.sqrt(dx * dx + dy * dy);

    if (distance > 0) {
        const force = 0.35; // Força máxima para chutar
        ball.vx = (dx / distance) * force;
        ball.vy = (dy / distance) * force;
    }

    player.hasBall = false;
    ball.owner = null;
}

function passBall() {
    if (!gameRunning) return;
    
    let player = getPlayerWithBall();
    if (!player) return;

    // Pass para um companheiro aleatório
    let team = player.team === 1 ? players.team1 : players.team2;
    let teammates = team.filter(p => p.id !== player.id);
    
    if (teammates.length === 0) return;

    let teammate = teammates[Math.floor(Math.random() * teammates.length)];

    let dx = teammate.x - ball.x;
    let dy = teammate.y - ball.y;
    let distance = Math.sqrt(dx * dx + dy * dy);

    if (distance > 0) {
        const force = 0.15; // Força menor para pass
        ball.vx = (dx / distance) * force;
        ball.vy = (dy / distance) * force;
    }

    player.hasBall = false;
    ball.owner = null;
}

function getPlayerWithBall() {
    let allPlayers = [...players.team1, ...players.team2];
    return allPlayers.find(p => p.hasBall);
}

// =====================================================
// LÓGICA DO JOGO
// =====================================================

function update() {
    // Atualizar posição da bola
    ball.x += ball.vx;
    ball.y += ball.vy;
    ball.vx *= ball.friction;
    ball.vy *= ball.friction;

    // Parar bola se velocidade muito pequena
    if (Math.abs(ball.vx) < 0.01) ball.vx = 0;
    if (Math.abs(ball.vy) < 0.01) ball.vy = 0;

    // Colisão com as paredes do campo
    if (ball.x - ball.radius < game.fieldX) {
        ball.x = game.fieldX + ball.radius;
        ball.vx *= -0.8;
    }
    if (ball.x + ball.radius > game.fieldX + game.fieldWidth) {
        ball.x = game.fieldX + game.fieldWidth - ball.radius;
        ball.vx *= -0.8;
    }
    if (ball.y - ball.radius < game.fieldY) {
        ball.y = game.fieldY + ball.radius;
        ball.vy *= -0.8;
    }
    if (ball.y + ball.radius > game.fieldY + game.fieldHeight) {
        ball.y = game.fieldY + game.fieldHeight - ball.radius;
        ball.vy *= -0.8;
    }

    // Verificar golos
    checkGoals();

    // Atualizar jogadores (IA simples)
    updatePlayers();

    // Controle de bola
    updateBallControl();
}

function checkGoals() {
    // Área de golo Team 1 (direita)
    if (ball.x + ball.radius > game.fieldX + game.fieldWidth - 30 &&
        ball.y > game.fieldY + 100 && ball.y < game.fieldY + game.fieldHeight - 100) {
        score.team1++;
        resetBall();
        updateScoreDisplay();
        if (score.team1 >= 3) {
            endGame();
        }
    }

    // Área de golo Team 2 (esquerda)
    if (ball.x - ball.radius < game.fieldX + 30 &&
        ball.y > game.fieldY + 100 && ball.y < game.fieldY + game.fieldHeight - 100) {
        score.team2++;
        resetBall();
        updateScoreDisplay();
        if (score.team2 >= 3) {
            endGame();
        }
    }
}

function resetBall() {
    ball.x = game.fieldX + game.fieldWidth / 2;
    ball.y = game.fieldY + game.fieldHeight / 2;
    ball.vx = 0;
    ball.vy = 0;
    ball.owner = null;
    
    [...players.team1, ...players.team2].forEach(p => p.hasBall = false);
}

function updateBallControl() {
    let allPlayers = [...players.team1, ...players.team2];

    // Verificar se alguém pega na bola
    for (let player of allPlayers) {
        let dx = player.x - ball.x;
        let dy = player.y - ball.y;
        let distance = Math.sqrt(dx * dx + dy * dy);

        if (distance < player.radius + ball.radius + 10) {
            if (!player.hasBall) {
                [...players.team1, ...players.team2].forEach(p => p.hasBall = false);
                player.hasBall = true;
                ball.owner = player.team;
            }
            // Bola acompanha jogador com aderência
            let targetX = player.x + Math.cos(Math.random() * Math.PI * 2) * 15;
            let targetY = player.y + Math.sin(Math.random() * Math.PI * 2) * 15;
            ball.x += (targetX - ball.x) * 0.1;
            ball.y += (targetY - ball.y) * 0.1;
            ball.vx *= 0.8;
            ball.vy *= 0.8;
            break;
        }
    }
}

function updatePlayers() {
    // Atualizar IA dos jogadores
    [...players.team1, ...players.team2].forEach(player => {
        if (!player.hasBall) {
            // Mover jogador em direção à bola
            let dx = ball.x - player.x;
            let dy = ball.y - player.y;
            let distance = Math.sqrt(dx * dx + dy * dy);

            if (distance > 5) {
                player.vx = (dx / distance) * player.speed * 0.5;
                player.vy = (dy / distance) * player.speed * 0.5;
            } else {
                player.vx *= 0.9;
                player.vy *= 0.9;
            }
        }

        // Atualizar posição
        player.x += player.vx;
        player.y += player.vy;

        // Manter dentro do campo
        if (player.x - player.radius < game.fieldX) player.x = game.fieldX + player.radius;
        if (player.x + player.radius > game.fieldX + game.fieldWidth) player.x = game.fieldX + game.fieldWidth - player.radius;
        if (player.y - player.radius < game.fieldY) player.y = game.fieldY + player.radius;
        if (player.y + player.radius > game.fieldY + game.fieldHeight) player.y = game.fieldY + game.fieldHeight - player.radius;
    });
}

// =====================================================
// DESENHO
// =====================================================

function drawField() {
    // Fundo do campo
    ctx.fillStyle = '#2d5016';
    ctx.fillRect(game.fieldX, game.fieldY, game.fieldWidth, game.fieldHeight);

    // Linha do campo (branco)
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;
    ctx.strokeRect(game.fieldX, game.fieldY, game.fieldWidth, game.fieldHeight);

    // Linha do meio
    ctx.beginPath();
    ctx.moveTo(game.fieldX + game.fieldWidth / 2, game.fieldY);
    ctx.lineTo(game.fieldX + game.fieldWidth / 2, game.fieldY + game.fieldHeight);
    ctx.stroke();

    // Círculo do meio
    ctx.beginPath();
    ctx.arc(game.fieldX + game.fieldWidth / 2, game.fieldY + game.fieldHeight / 2, 40, 0, Math.PI * 2);
    ctx.stroke();

    // Ponto central
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(game.fieldX + game.fieldWidth / 2, game.fieldY + game.fieldHeight / 2, 4, 0, Math.PI * 2);
    ctx.fill();

    // Áreas de gol com destaque
    ctx.strokeStyle = '#FFFF00';
    ctx.lineWidth = 2;
    ctx.strokeRect(game.fieldX, game.fieldY + game.fieldHeight / 2 - 50, 40, 100);
    ctx.strokeRect(game.fieldX + game.fieldWidth - 40, game.fieldY + game.fieldHeight / 2 - 50, 40, 100);
}

function drawPlayers() {
    [...players.team1, ...players.team2].forEach(player => {
        // Corpo do jogador
        ctx.fillStyle = player.color;
        ctx.beginPath();
        ctx.arc(player.x, player.y, player.radius, 0, Math.PI * 2);
        ctx.fill();

        // Contorno
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 2;
        ctx.stroke();

        // Indicador de quem tem a bola
        if (player.hasBall) {
            ctx.strokeStyle = '#FFFF00';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.arc(player.x, player.y, player.radius + 5, 0, Math.PI * 2);
            ctx.stroke();
        }

        // Sombra
        ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
        ctx.beginPath();
        ctx.ellipse(player.x, player.y + 3, player.radius, player.radius / 2, 0, 0, Math.PI * 2);
        ctx.fill();
    });
}

function drawBall() {
    // Bola
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(ball.x, ball.y, ball.radius, 0, Math.PI * 2);
    ctx.fill();

    // Contorno
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.stroke();

    // Sombra
    ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
    ctx.beginPath();
    ctx.ellipse(ball.x, ball.y + 3, ball.radius, ball.radius / 2, 0, 0, Math.PI * 2);
    ctx.fill();
}

// =====================================================
// LOOP PRINCIPAL
// =====================================================

function gameLoop() {
    // Limpar canvas
    ctx.fillStyle = '#1a1a1a';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Desenhar jogo
    if (gameRunning) {
        drawField();
        update();
    }

    drawPlayers();
    drawBall();

    if (gameRunning) {
        requestAnimationFrame(gameLoop);
    }
}

// =====================================================
// FIM DO JOGO
// =====================================================

function endGame() {
    gameRunning = false;
    if (timerInterval) clearInterval(timerInterval);

    let winner = score.team1 > score.team2 ? 'TEAM 1' : 'TEAM 2';
    let message = `${winner} VENCEU!`;

    document.getElementById('gameOverTitle').textContent = '🏆 JOGO TERMINADO! 🏆';
    document.getElementById('gameOverMessage').textContent = message;

    // Atualizar ranking se for ranqueada
    let pointsText = '';
    if (gameMode === 'ranked') {
        let playerName = 'Jogador';
        let pointsGained = 0;

        if (winner === 'TEAM 1') {
            pointsGained = 50;
        } else {
            pointsGained = -20;
        }

        if (!ranking[playerName]) {
            ranking[playerName] = 1000;
        }
        ranking[playerName] += pointsGained;

        localStorage.setItem('eggFootballRanking', JSON.stringify(ranking));

        pointsText = pointsGained > 0 ? 
            `✅ +${pointsGained} pontos` : 
            `❌ ${pointsGained} pontos`;

        document.getElementById('pointsChange').textContent = pointsText;
    }

    showMenu('gameOver');
}

function updateScoreDisplay() {
    document.getElementById('score1').textContent = score.team1;
    document.getElementById('score2').textContent = score.team2;
}
