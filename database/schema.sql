-- Database Schema Definition

-- 1. Users Table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    hashed_password VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    profile_picture_url VARCHAR(512),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_display_name ON Users(display_name);

-- 2. Projects Table
CREATE TABLE Projects (
    project_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_projects_user_id ON Projects(user_id);
CREATE INDEX idx_projects_name ON Projects(name);

-- 3. UserProjectDisplayOrder Table (For ordering projects in MainMenuPage)
CREATE TABLE UserProjectDisplayOrder (
    user_id INT NOT NULL,
    project_id INT NOT NULL,
    display_position INT NOT NULL,
    PRIMARY KEY (user_id, project_id),
    CONSTRAINT fk_user_order
        FOREIGN KEY(user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_project_order
        FOREIGN KEY(project_id)
        REFERENCES Projects(project_id)
        ON DELETE CASCADE,
    CONSTRAINT unique_user_position UNIQUE (user_id, display_position) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX idx_user_project_order_position ON UserProjectDisplayOrder(user_id, display_position);

-- 4. Module Type Enum
CREATE TYPE module_type_enum AS ENUM (
    'VISION',
    'OBJECTIVE_SCOREBOARD',
    'TOUCHBASE',
    'BRAINSTORM',
    'CHOOSE'
);

-- 5. ProjectModules Table (Represents created instances of modules within a project)
-- Added: layout_preference column
CREATE TABLE ProjectModules (
    project_module_id SERIAL PRIMARY KEY, 
    project_id INT NOT NULL,
    module_type module_type_enum NOT NULL,
    name VARCHAR(255) NOT NULL, -- Display name in History (renameable)
    layout_preference VARCHAR(30) DEFAULT 'objective_first', -- For Objective/Scoreboard layout: 'objective_first' or 'scoreboard_first'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module
        FOREIGN KEY(project_id)
        REFERENCES Projects(project_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_projectmodules_project_id ON ProjectModules(project_id);
CREATE INDEX idx_projectmodules_type ON ProjectModules(module_type);

-- 6. ProjectModuleDisplayOrder Table (For ordering module instances in ModulesMenuPage History)
CREATE TABLE ProjectModuleDisplayOrder (
    project_id INT NOT NULL,
    project_module_id INT NOT NULL,
    display_position INT NOT NULL,
    PRIMARY KEY (project_id, project_module_id),
    CONSTRAINT fk_project_module_order_project
        FOREIGN KEY(project_id)
        REFERENCES Projects(project_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_project_module_order_module
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE,
    CONSTRAINT unique_project_module_position UNIQUE (project_id, display_position) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX idx_project_module_order_position ON ProjectModuleDisplayOrder(project_id, display_position);
CREATE INDEX idx_project_module_order_module_id ON ProjectModuleDisplayOrder(project_module_id);


-- 7. Module-Specific Data Tables (Linked to ProjectModules)

-- Vision Module Data (No changes)
CREATE TABLE VisionModuleData (
    vision_data_id SERIAL PRIMARY KEY,
    project_module_id INT UNIQUE NOT NULL,
    purpose TEXT,
    achieve TEXT,
    market TEXT,
    customers TEXT,
    win TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module_vision
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_visiondata_module_id ON VisionModuleData(project_module_id);

-- Objective & Scoreboard Module Data (No changes needed here for scoreboard)
CREATE TABLE ObjectiveScoreboardModuleData (
    objective_data_id SERIAL PRIMARY KEY,
    project_module_id INT UNIQUE NOT NULL,
    objective_talk_about TEXT,
    steps_to_accomplish TEXT,
    additional_business_services TEXT,
    necessary_skills TEXT,
    additional_tools TEXT,
    who_to_contact TEXT,
    who_to_cooperate TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module_objective
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_objectivedata_module_id ON ObjectiveScoreboardModuleData(project_module_id);

-- NEW: Scoreboard Task Table
CREATE TABLE ScoreboardTasks (
    scoreboard_task_id SERIAL PRIMARY KEY,
    project_module_id INT NOT NULL, -- FK to the specific ObjectiveScoreboard instance
    task_description TEXT NOT NULL DEFAULT '',
    status VARCHAR(100), -- Can reference DropdownOptions or just store the string value
    person VARCHAR(255), -- Optional assignee 
    due_date DATE,       -- Optional due date
    display_order INT,    -- Order within the scoreboard table
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module_scoreboard
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_scoreboardtasks_module_id ON ScoreboardTasks(project_module_id);
CREATE INDEX idx_scoreboardtasks_order ON ScoreboardTasks(project_module_id, display_order);

-- NEW: Dropdown Options Table (Generic for different types)
CREATE TYPE dropdown_type_enum AS ENUM (
    'scoreboard_status'
    -- Add other types here later if needed (e.g., 'task_priority')
);

CREATE TABLE DropdownOptions (
    option_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL, -- Options are per-user
    option_type dropdown_type_enum NOT NULL,
    option_value VARCHAR(255) NOT NULL,
    color_hex VARCHAR(7), -- Optional color (e.g., '#FF0000')
    display_order INT,    -- Order within the dropdown editor
    is_default BOOLEAN DEFAULT FALSE, -- Indicate if it's a non-deletable default
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_dropdown_options
        FOREIGN KEY(user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT unique_user_option_type_value UNIQUE (user_id, option_type, option_value)
);
CREATE INDEX idx_dropdownoptions_user_type ON DropdownOptions(user_id, option_type);
CREATE INDEX idx_dropdownoptions_order ON DropdownOptions(user_id, option_type, display_order);


-- Touchbase Module Data (No changes)
CREATE TABLE TouchbaseModuleData (
    touchbase_data_id SERIAL PRIMARY KEY,
    project_module_id INT UNIQUE NOT NULL,
    working_on TEXT,
    doing_today TEXT,
    need_help_with TEXT,
    potential_assistance TEXT,
    update_status TEXT,
    add_or_delete_task TEXT,
    timeline_change TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module_touchbase
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_touchbasedata_module_id ON TouchbaseModuleData(project_module_id);

-- Brainstorm Module Data (No changes)
CREATE TABLE BrainstormModuleData (
    brainstorm_data_id SERIAL PRIMARY KEY,
    project_module_id INT UNIQUE NOT NULL,
    imitate_trends TEXT,
    ideate TEXT,
    ignore TEXT,
    integrate TEXT,
    interfere TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module_brainstorm
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_brainstormdata_module_id ON BrainstormModuleData(project_module_id);

-- Choose Module Data (No changes)
CREATE TABLE ChooseModuleData (
    choose_data_id SERIAL PRIMARY KEY,
    project_module_id INT UNIQUE NOT NULL,
    scenarios_considered TEXT,
    similarities_differences TEXT,
    decision_criteria TEXT,
    evaluate_differences TEXT,
    support_decision TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_module_choose
        FOREIGN KEY(project_module_id)
        REFERENCES ProjectModules(project_module_id)
        ON DELETE CASCADE
);
CREATE INDEX idx_choosedata_module_id ON ChooseModuleData(project_module_id);


-- 8. Trigger function to automatically update 'updated_at' timestamps
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to relevant tables (Added new tables)
CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON Users FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_projects BEFORE UPDATE ON Projects FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_projectmodules BEFORE UPDATE ON ProjectModules FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_visionmoduledata BEFORE UPDATE ON VisionModuleData FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_objectivescoreboardmoduledata BEFORE UPDATE ON ObjectiveScoreboardModuleData FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_touchbasemoduledata BEFORE UPDATE ON TouchbaseModuleData FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_brainstormmoduledata BEFORE UPDATE ON BrainstormModuleData FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_choosemoduledata BEFORE UPDATE ON ChooseModuleData FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_scoreboardtasks BEFORE UPDATE ON ScoreboardTasks FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_dropdownoptions BEFORE UPDATE ON DropdownOptions FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

