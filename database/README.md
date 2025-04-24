# Database Schema Documentation

This document outlines the database schema for the project.
The SQL definitions are stored in `schema.sql`.

## Tables

### 1. `Users`

Stores user profile information.

- **`user_id`**: Primary Key. Unique identifier for the user.
- **`email`**: User's login email (must be unique).
- **`display_name`**: Name shown in the UI.
- **`hashed_password`**: Securely stored password hash (if applicable).
- **`first_name`**: Optional first name.
- **`last_name`**: Optional last name.
- **`profile_picture_url`**: Optional URL for avatar.
- **`created_at`**: Timestamp of record creation.
- **`updated_at`**: Timestamp of last update.

### 2. `Projects`

Stores information about user projects.

- **`project_id`**: Primary Key. Unique identifier for the project.
- **`user_id`**: Foreign Key referencing `Users.user_id`. Links project to its owner.
- **`name`**: Name of the project.
- **`description`**: Optional project description.
- **`created_at`**: Timestamp of record creation.
- **`updated_at`**: Timestamp of last update.

### 3. `UserProjectDisplayOrder`

Stores the custom display order of projects for each user on the main menu.

- **`user_id`**: Composite Primary Key, Foreign Key referencing `Users.user_id`.
- **`project_id`**: Composite Primary Key, Foreign Key referencing `Projects.project_id`.
- **`display_position`**: Integer representing the order (e.g., 0, 1, 2...). Must be unique per user.

## Relationships

- A `User` can have many `Projects` (One-to-Many).
- A `User` can have many `UserProjectDisplayOrder` entries (One-to-Many).
- A `Project` belongs to one `User` (Many-to-One).
- A `Project` can have one `UserProjectDisplayOrder` entry per user (One-to-One within the scope of a user).

## Rationale

This structure separates core user and project data from display-specific ordering information, enhancing maintainability and flexibility. Using foreign keys ensures data integrity, and indexes provide efficient querying.

Refer to `schema.sql` for detailed column types, constraints, and indexes.
