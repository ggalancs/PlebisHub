# Plebis CMS Engine

Content Management System for PlebisHub platform.

## Description

This engine provides blog posts, pages, and notifications management functionality for PlebisHub.

## Models

- **Post**: Blog posts with content, categories, and publication status
- **Category**: Categorization for blog posts
- **Page**: Static pages content
- **Notice**: System notifications
- **NoticeRegistrar**: Notification registration tracking

## Controllers

- **BlogController**: Blog listing and post display
- **PageController**: Static pages display
- **NoticeController**: Notifications management

## Dependencies

- User model (for author relationship)
- ActiveAdmin (for admin interface)

## Installation

This engine is automatically loaded when activated from the admin panel.

## Activation

```ruby
# From Rails console
EngineActivation.enable!('plebis_cms')

# Or from admin panel: /admin/engine_activations
```

## Usage

Once activated, the CMS routes are available at:
- `/brujula` - Blog index
- `/pages/:id` - Static pages
- `/notice` - Notifications

## Configuration

Configure via EngineActivation record:

```json
{
  "wordpress_api_enabled": false,
  "push_notifications_enabled": true
}
```

## Development

### Running Tests

```bash
bundle exec rspec engines/plebis_cms/spec
```

### Code Structure

```
engines/plebis_cms/
├── app/
│   ├── controllers/plebis_cms/
│   ├── models/plebis_cms/
│   ├── views/plebis_cms/
│   └── admin/plebis_cms/
├── config/
│   └── routes.rb
├── spec/
│   ├── models/
│   ├── controllers/
│   └── requests/
└── lib/plebis_cms/
    └── engine.rb
```

## License

MIT License
