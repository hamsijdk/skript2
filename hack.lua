let currentPlayers = [];
let selectedPlayer = null;

// NUI ile iletişim
function sendData(data) {
    fetch(`https://${GetParentResourceName()}/${data.action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp => console.log(resp));
}

// Sayfa yüklendiğinde
document.addEventListener('DOMContentLoaded', function() {
    loadPlayers();
    setupEventListeners();
});

// Event listener'ları kur
function setupEventListeners() {
    // Kapat butonu
    document.getElementById('closeBtn').addEventListener('click', function() {
        sendData({ action: 'closeMenu' });
    });
    
    // Tab'lar
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            switchTab(this.dataset.tab);
        });
    });
    
    // Arama
    document.getElementById('searchInput').addEventListener('input', function() {
        filterPlayers(this.value);
    });
    
    // Modal butonları
    document.getElementById('confirmImprison').addEventListener('click', imprisonPlayer);
    document.getElementById('cancelImprison').addEventListener('click', closeModal);
}

// Tab değiştirme
function switchTab(tabName) {
    // Tab butonlarını güncelle
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
    
    // Tab içeriklerini güncelle
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}-tab`).classList.add('active');
    
    if (tabName === 'players') {
        loadPlayers();
    } else if (tabName === 'imprisoned') {
        loadImprisonedPlayers();
    }
}

// Oyuncuları yükle
function loadPlayers() {
    sendData({ action: 'getPlayers' });
}

// Oyuncuları filtrele
function filterPlayers(searchTerm) {
    const filtered = currentPlayers.filter(player => 
        player.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        player.id.toString().includes(searchTerm)
    );
    displayPlayers(filtered);
}

// Hapsedilen oyuncuları yükle
function loadImprisonedPlayers() {
    const imprisoned = currentPlayers.filter(player => player.isImprisoned);
    displayImprisonedPlayers(imprisoned);
}

// Oyuncuları göster
function displayPlayers(players) {
    const container = document.getElementById('playerList');
    container.innerHTML = '';
    
    players.forEach(player => {
        const playerElement = document.createElement('div');
        playerElement.className = 'player-item';
        playerElement.innerHTML = `
            <div class="player-info">
                <div class="player-name">${escapeHtml(player.name)}</div>
                <div class="player-id">ID: ${player.id}</div>
            </div>
            <div>
                ${player.isImprisoned ? 
                    '<button class="btn btn-jailed" disabled>⛓️ Hapiste</button>' :
                    `<button class="btn btn-imprison" onclick="openImprisonModal(${player.id}, '${escapeHtml(player.name)}')">⛓️ Hapse At</button>`
                }
            </div>
        `;
        container.appendChild(playerElement);
    });
}

// Hapisteki oyuncuları göster
function displayImprisonedPlayers(players) {
    const container = document.getElementById('imprisonedList');
    container.innerHTML = '';
    
    if (players.length === 0) {
        container.innerHTML = '<div class="player-item">❌ Hapiste kimse yok</div>';
        return;
    }
    
    players.forEach(player => {
        const playerElement = document.createElement('div');
        playerElement.className = 'imprisoned-item';
        playerElement.innerHTML = `
            <div class="player-info">
                <div class="player-name">${escapeHtml(player.name)}</div>
                <div class="player-id">ID: ${player.id}</div>
            </div>
            <div>
                <button class="btn btn-release" onclick="releasePlayer(${player.id})">🔓 Serbest Bırak</button>
            </div>
        `;
        container.appendChild(playerElement);
    });
}

// Hapis modal'ını aç
function openImprisonModal(playerId, playerName) {
    selectedPlayer = playerId;
    document.getElementById('modalPlayerName').textContent = playerName;
    document.getElementById('imprisonModal').style.display = 'block';
    document.getElementById('durationInput').focus();
}

// Modal'ı kapat
function closeModal() {
    document.getElementById('imprisonModal').style.display = 'none';
    selectedPlayer = null;
}

// Oyuncuyu hapse at
function imprisonPlayer() {
    const duration = document.getElementById('durationInput').value;
    
    if (!duration || duration < 1) {
        alert('Lütfen geçerli bir süre girin!');
        return;
    }
    
    sendData({
        action: 'imprisonPlayer',
        playerId: selectedPlayer,
        duration: parseInt(duration)
    });
    
    closeModal();
}

// Oyuncuyu serbest bırak
function releasePlayer(playerId) {
    if (confirm('Bu oyuncuyu serbest bırakmak istediğinizden emin misiniz?')) {
        sendData({
            action: 'releasePlayer',
            playerId: playerId
        });
    }
}

// NUI event'lerini dinle
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'sendPlayers') {
        currentPlayers = data.players;
        if (document.getElementById('players-tab').classList.contains('active')) {
            displayPlayers(currentPlayers);
        }
    }
});

// HTML escape
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// ESC tuşu ile kapat
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (document.getElementById('imprisonModal').style.display === 'block') {
            closeModal();
        } else {
            sendData({ action: 'closeMenu' });
        }
    }
});
