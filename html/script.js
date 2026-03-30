// AdminHUD System - JavaScript
// Created by D

let selectedPlayer = null;
let isAdminMenuOpen = false;

// Listen for messages from FiveM
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.action) {
        case 'openAdminMenu':
            openAdminMenu(data);
            break;
        case 'closeAdminMenu':
            closeAdminMenu();
            break;
        case 'updateHUD':
            updateHUD(data);
            break;
    }
});

// Update HUD
function updateHUD(data) {
    document.getElementById('money').textContent = `$${data.money.toLocaleString()}`;
    
    const healthBar = document.getElementById('health-bar');
    const armorBar = document.getElementById('armor-bar');
    const hungerBar = document.getElementById('hunger-bar');
    const thirstBar = document.getElementById('thirst-bar');
    const stressBar = document.getElementById('stress-bar');
    
    if (healthBar) healthBar.style.width = `${data.health}%`;
    if (armorBar) armorBar.style.width = `${data.armor}%`;
    if (hungerBar) hungerBar.style.width = `${data.hunger}%`;
    if (thirstBar) thirstBar.style.width = `${data.thirst}%`;
    if (stressBar) stressBar.style.width = `${data.stress}%`;
}

// Open admin menu
function openAdminMenu(data) {
    if (isAdminMenuOpen) return;
    
    isAdminMenuOpen = true;
    selectedPlayer = null;
    
    // Load players
    loadPlayers(data.players || []);
    
    // Show admin menu
    document.getElementById('admin-menu').classList.remove('hidden');
    
    // Set NUI focus
    fetch(`https://client/setNuiFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ focus: true })
    });
}

// Close admin menu
function closeAdminMenu() {
    isAdminMenuOpen = false;
    selectedPlayer = null;
    
    // Hide admin menu
    document.getElementById('admin-menu').classList.add('hidden');
    
    // Remove NUI focus
    fetch(`https://client/setNuiFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ focus: false })
    });
}

// Load players
function loadPlayers(players) {
    const playerList = document.getElementById('player-list');
    playerList.innerHTML = '';
    
    if (players.length === 0) {
        playerList.innerHTML = '<div class="no-players">No players online</div>';
        return;
    }
    
    players.forEach(player => {
        const item = document.createElement('div');
        item.className = 'player-item';
        item.onclick = () => selectPlayer(player);
        
        item.innerHTML = `
            <div>
                <div class="player-name">${player.name}</div>
                <div class="player-info">ID: ${player.id} | HP: ${player.health} | AR: ${player.armor}</div>
            </div>
        `;
        
        playerList.appendChild(item);
    });
}

// Select player
function selectPlayer(player) {
    // Remove previous selection
    document.querySelectorAll('.player-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    // Add selection to clicked item
    event.currentTarget.classList.add('selected');
    selectedPlayer = player;
    
    console.log('Selected player:', player);
}

// Player management functions
function teleportToPlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    fetch(`https://client/teleportToPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ playerId: selectedPlayer.id })
    });
    
    showNotification(`Teleported to ${selectedPlayer.name}`, 'success');
}

function bringPlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    fetch(`https://client/bringPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ playerId: selectedPlayer.id })
    });
    
    showNotification(`Brought ${selectedPlayer.name} to you`, 'success');
}

function healPlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    fetch(`https://client/healPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ playerId: selectedPlayer.id })
    });
    
    showNotification(`Healed ${selectedPlayer.name}`, 'success');
}

function giveArmor() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    fetch(`https://client/giveArmor`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ playerId: selectedPlayer.id })
    });
    
    showNotification(`Gave armor to ${selectedPlayer.name}`, 'success');
}

function giveMoney() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    const amount = prompt('Enter amount:');
    if (amount && !isNaN(amount)) {
        fetch(`https://client/giveMoney`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ 
                playerId: selectedPlayer.id,
                amount: parseInt(amount)
            })
        });
        
        showNotification(`Gave $${amount} to ${selectedPlayer.name}`, 'success');
    }
}

function kickPlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    const reason = prompt('Enter kick reason:');
    if (reason) {
        fetch(`https://client/kickPlayer`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ 
                playerId: selectedPlayer.id,
                reason: reason 
            })
        });
        
        showNotification(`Kicked ${selectedPlayer.name}`, 'success');
    }
}

function banPlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    const reason = prompt('Enter ban reason:');
    const duration = prompt('Enter duration (hours, 0 for permanent):');
    
    if (reason && duration && !isNaN(duration)) {
        fetch(`https://client/banPlayer`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ 
                playerId: selectedPlayer.id,
                reason: reason,
                duration: parseInt(duration)
            })
        });
        
        showNotification(`Banned ${selectedPlayer.name}`, 'success');
    }
}

function revivePlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    fetch(`https://client/revivePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ playerId: selectedPlayer.id })
    });
    
    showNotification(`Revived ${selectedPlayer.name}`, 'success');
}

function spectatePlayer() {
    if (!selectedPlayer) {
        showNotification('Please select a player', 'error');
        return;
    }
    
    fetch(`https://client/spectatePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ playerId: selectedPlayer.id })
    });
    
    showNotification(`Spectating ${selectedPlayer.name}`, 'info');
}

// Vehicle management functions
function spawnVehicle() {
    const model = document.getElementById('vehicle-model').value.trim();
    
    if (!model) {
        showNotification('Please enter a vehicle model', 'error');
        return;
    }
    
    fetch(`https://client/spawnVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ model: model })
    });
    
    showNotification(`Spawned ${model}`, 'success');
    document.getElementById('vehicle-model').value = '';
}

function deleteVehicle() {
    fetch(`https://client/deleteVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
    
    showNotification('Vehicle deleted', 'success');
}

// Admin tools functions
function toggleNoclip() {
    fetch(`https://client/toggleNoclip`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
    
    showNotification('Toggled noclip', 'info');
}

function toggleGodMode() {
    fetch(`https://client/toggleGodMode`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
    
    showNotification('Toggled god mode', 'info');
}

function toggleInvisible() {
    fetch(`https://client/toggleInvisible`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
    
    showNotification('Toggled invisible mode', 'info');
}

function clearArea() {
    fetch(`https://client/clearArea`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
    
    showNotification('Area cleared', 'success');
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <div class="notification-message">${message}</div>
            <button class="notification-close" onclick="this.parentElement.parentElement.remove()">×</button>
        </div>
    `;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Auto remove after 3 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 3000);
}

// Keyboard shortcuts
document.addEventListener('keydown', function(event) {
    if (!isAdminMenuOpen) return;
    
    // F5 to open admin menu
    if (event.key === 'F5') {
        event.preventDefault();
        // Trigger admin menu open
        fetch(`https://client/openAdminMenu`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    }
    
    // ESC to close admin menu
    if (event.key === 'Escape') {
        closeAdminMenu();
    }
});

// Add notification styles
const style = document.createElement('style');
style.textContent = `
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        background: rgba(0, 0, 0, 0.8);
        color: #fff;
        padding: 15px 20px;
        border-radius: 8px;
        border-left: 4px solid #ff0000;
        backdrop-filter: blur(10px);
        animation: slideIn 0.3s ease;
        min-width: 250px;
        max-width: 400px;
        z-index: 10000;
    }
    
    .notification.success {
        border-left-color: #00ff00;
    }
    
    .notification.error {
        border-left-color: #ff0000;
    }
    
    .notification.warning {
        border-left-color: #ff9900;
    }
    
    .notification.info {
        border-left-color: #0099ff;
    }
    
    .notification-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .notification-message {
        flex: 1;
    }
    
    .notification-close {
        background: none;
        border: none;
        color: #fff;
        font-size: 18px;
        cursor: pointer;
        padding: 0;
        margin-left: 10px;
    }
    
    .no-players {
        color: #aaa;
        text-align: center;
        padding: 20px;
        font-style: italic;
    }
    
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
`;
document.head.appendChild(style);

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('AdminHUD loaded');
});

// Export functions for FiveM
window.openAdminMenu = openAdminMenu;
window.closeAdminMenu = closeAdminMenu;
