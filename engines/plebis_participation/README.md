# PlebisParticipation Engine

Participation Teams Management engine for PlebisHub.

## Description

This engine handles the "Equipos de Acción Participativa" (Participation Action Teams) functionality, allowing users to join and leave teams for collaborative work.

## Models

### PlebisParticipation::ParticipationTeam
- Manages participation teams
- Has and belongs to many Users (HABTM relationship)
- Join table: `participation_teams_users`

## Controllers

### PlebisParticipation::ParticipationTeamsController
- `index` - List all participation teams
- `join` - Allow users to join a team
- `leave` - Allow users to leave a team
- `update_user` - Update user information in teams

## Routes

- `GET /equipos-de-accion-participativa` - List teams
- `PUT /equipos-de-accion-participativa/entrar(/:team_id)` - Join team
- `PUT /equipos-de-accion-participativa/dejar(/:team_id)` - Leave team
- `PATCH /equipos-de-accion-participativa/actualizar` - Update user

## Dependencies

- User model (from main app)
- Rails 7.2.3
- Ruby 3.3.10

## Installation

Add to your application's Gemfile:

```ruby
gem 'plebis_participation', path: 'engines/plebis_participation'
```

## Activation

The engine can be activated/deactivated dynamically:

```ruby
# Enable
EngineActivation.enable!('plebis_participation')

# Disable
EngineActivation.disable!('plebis_participation')

# Check status
EngineActivation.enabled?('plebis_participation')
```

## Testing

```bash
cd engines/plebis_participation
bundle exec rspec
```

## License

MIT License
