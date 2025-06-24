# create_ash_phoenix_worktree.sh

## Overview
Creates a dedicated git worktree specifically configured for Ash Phoenix project migration and development.

## Purpose
- Set up Phoenix-specific development environment
- Configure Ash framework integration
- Prepare for Phoenix LiveView development
- Enable Ash Phoenix migration workflows

## Usage
```bash
# Create Ash Phoenix worktree
./create_ash_phoenix_worktree.sh

# Create with custom branch
./create_ash_phoenix_worktree.sh <branch_name>

# Create for specific feature
./create_ash_phoenix_worktree.sh ash-authentication-feature
```

## Key Features
- **Phoenix Configuration**: Pre-configured for Phoenix development
- **Ash Integration**: Ash framework dependencies and setup
- **LiveView Ready**: Configured for Phoenix LiveView
- **Migration Tools**: Database migration and seeding setup

## Phoenix-Specific Setup
1. **Elixir Environment**: Configured Mix environment
2. **Database Setup**: Phoenix-specific database configuration
3. **Asset Pipeline**: Node.js and asset compilation setup
4. **LiveView Configuration**: Real-time features enabled
5. **Ash Framework**: Resource definitions and API setup

## Created Structure
```
worktrees/ash-phoenix/
├── .git                          # Git worktree
├── config/
│   ├── dev.exs                   # Phoenix dev config
│   ├── test.exs                  # Test configuration
│   └── runtime.exs               # Runtime configuration
├── lib/
│   └── ash_phoenix_app/          # Phoenix application
├── priv/
│   └── repo/migrations/          # Database migrations
├── assets/                       # Frontend assets
└── test/                         # Test files
```

## Environment Variables
```bash
MIX_ENV=dev
PHX_SERVER=true
PHX_HOST=localhost
PHX_PORT=4000
DATABASE_URL=postgres://localhost/ash_phoenix_dev
```

## Ash Framework Setup
- **Resources**: User, Post, Comment resource definitions
- **API**: JSON API for frontend integration
- **Authentication**: Ash Authentication setup
- **Authorization**: Policy-based access control

## Development Workflow
```bash
# Navigate to worktree
cd worktrees/ash-phoenix

# Install dependencies
mix deps.get

# Setup database
mix ecto.setup

# Start Phoenix server
mix phx.server
```

## Integration Points
- Uses `create_s2s_worktree.sh` as base worktree creation
- Integrates with `worktree_environment_manager.sh` for Phoenix-specific ports
- Compatible with agent deployment for automated testing
- Connects to Phoenix LiveView for real-time coordination

## Phoenix Development Features
- **Hot Reloading**: Automatic code reloading
- **LiveView**: Real-time user interfaces
- **PubSub**: Real-time communication
- **Telemetry**: Performance monitoring integration

## Testing
```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run LiveView tests
mix test test/live/
```

## Examples
```bash
# Standard Phoenix development
./create_ash_phoenix_worktree.sh

# Feature branch development
./create_ash_phoenix_worktree.sh user-management-feature

# Bug fixes
./create_ash_phoenix_worktree.sh bugfix-liveview-updates
```

## Verification
```bash
# Check Phoenix is running
curl http://localhost:4000

# Verify database connection
mix ecto.create

# Test LiveView
mix test test/live/
```