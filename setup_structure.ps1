# KitchenCue Folder Structure Setup Script
# Feature-based architecture for Flutter app

Write-Host "Creating KitchenCue folder structure..." -ForegroundColor Green

# Create main lib directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "lib" | Out-Null

# Core directories
$corePaths = @(
    "lib/core/constants",
    "lib/core/theme",
    "lib/core/utils",
    "lib/core/widgets"
)

foreach ($path in $corePaths) {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    Write-Host "Created: $path" -ForegroundColor Cyan
}

# Services directories
$servicePaths = @(
    "lib/services/firebase",
    "lib/services/state_management"
)

foreach ($path in $servicePaths) {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    Write-Host "Created: $path" -ForegroundColor Cyan
}

# Models directory
New-Item -ItemType Directory -Force -Path "lib/models" | Out-Null
Write-Host "Created: lib/models" -ForegroundColor Cyan

# Feature directories with screens and widgets
$features = @(
    "auth",
    "menu_dashboard",
    "order_management",
    "kitchen_queue"
)

foreach ($feature in $features) {
    $featurePaths = @(
        "lib/features/$feature/screens",
        "lib/features/$feature/widgets",
        "lib/features/$feature/state"
    )
    
    foreach ($path in $featurePaths) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
        Write-Host "Created: $path" -ForegroundColor Cyan
    }
}

Write-Host "`nCreating placeholder screen files..." -ForegroundColor Green

# Create placeholder screen files
$screenFiles = @{
    "lib/features/auth/screens/login_screen.dart" = "// Login/Role Selection Screen`n// TODO: Implement login and role selection UI"
    "lib/features/menu_dashboard/screens/menu_dashboard_screen.dart" = "// Table/Menu Dashboard Screen (Waiter)`n// TODO: Implement menu items with live stock counter"
    "lib/features/order_management/screens/order_detail_screen.dart" = "// Order Detail View Screen`n// TODO: Implement order details and submission"
    "lib/features/kitchen_queue/screens/kitchen_queue_screen.dart" = "// Kitchen Order Queue Screen (Chef)`n// TODO: Implement order queue with timestamps"
    "lib/features/kitchen_queue/screens/kitchen_status_screen.dart" = "// Kitchen Management/Status Screen`n// TODO: Implement Busy Mode toggle and kitchen controls"
}

foreach ($file in $screenFiles.GetEnumerator()) {
    New-Item -ItemType File -Force -Path $file.Key -Value $file.Value | Out-Null
    Write-Host "Created: $($file.Key)" -ForegroundColor Yellow
}

# Create router placeholder
$routerContent = @"
// GoRouter Configuration
// TODO: Define routes for Waiter and Kitchen paths
"@

New-Item -ItemType File -Force -Path "lib/core/router.dart" -Value $routerContent | Out-Null
Write-Host "Created: lib/core/router.dart" -ForegroundColor Yellow

# Create global state placeholder
$stateContent = @"
// Global State Management
// TODO: Manage liveInventoryCount and kitchenStatus
"@

New-Item -ItemType File -Force -Path "lib/services/state_management/global_state.dart" -Value $stateContent | Out-Null
Write-Host "Created: lib/services/state_management/global_state.dart" -ForegroundColor Yellow

# Create model placeholders
$modelFiles = @{
    "lib/models/menu_item.dart" = "// Menu Item Model`n// TODO: Define MenuItem with stock count"
    "lib/models/order.dart" = "// Order Model`n// TODO: Define Order with timestamp"
    "lib/models/kitchen_status.dart" = "// Kitchen Status Model`n// TODO: Define KitchenStatus (busy/available)"
}

foreach ($file in $modelFiles.GetEnumerator()) {
    New-Item -ItemType File -Force -Path $file.Key -Value $file.Value | Out-Null
    Write-Host "Created: $($file.Key)" -ForegroundColor Yellow
}

Write-Host "`nFolder structure created successfully!" -ForegroundColor Green
Write-Host "`nStructure Overview:" -ForegroundColor Magenta
Write-Host "  lib/" -ForegroundColor White
Write-Host "    - core/ (constants, theme, utils, widgets, router)" -ForegroundColor Gray
Write-Host "    - services/ (firebase, state_management)" -ForegroundColor Gray
Write-Host "    - models/ (menu_item, order, kitchen_status)" -ForegroundColor Gray
Write-Host "    - features/" -ForegroundColor Gray
Write-Host "        - auth/ (Login/Role Selection)" -ForegroundColor Gray
Write-Host "        - menu_dashboard/ (Waiter Menu View)" -ForegroundColor Gray
Write-Host "        - order_management/ (Order Details)" -ForegroundColor Gray
Write-Host "        - kitchen_queue/ (Kitchen Queue and Status)" -ForegroundColor Gray
