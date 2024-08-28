-- Creates structure for the postgres database

-- Default local connection:
--     host: 'localhost'
--     port: 5432
--     database: 'roastplanner'

-- When deployed, the connection string will be set as an environment variable

-- ------------------------------------------------------------

-- USER AND ORGANIZATION TABLES: Structural tables for users and organizations

-- Table: users
    -- User information created when a user registers
CREATE TABLE "users"(
    "id" SERIAL PRIMARY KEY,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "password" VARCHAR(1000) NOT NULL,
    "first_name" VARCHAR(255) NOT NULL,
    "last_name" VARCHAR(255) NOT NULL,
    "address_1" VARCHAR(255) NOT NULL,
    "address_2" VARCHAR(255) NOT NULL,
    "city" VARCHAR(255) NOT NULL,
    "state" VARCHAR(255) NOT NULL,
    "country" BIGINT NOT NULL,
    "zip" VARCHAR(255) NOT NULL,
    "country_code" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(255) NOT NULL,
    "title" BIGINT NOT NULL,
    "title_descriptor" BIGINT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL,
    "last_login" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: orgs
    -- Organization information created when a user registers an organization
    -- Creating user is the default owner
CREATE TABLE "orgs"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "owner" BIGINT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL,
    "last_login" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: orgs_members
    -- Table for storing members of an organization
    -- Users levels cascade down
    -- Users can be a memeber of multiple organizations and have different levels in each
    -- Users can be members of multiple facilities but have only one level in an organization
    -- Users above Level 6 and up can add new members to their facility and the organization
    -- Users can only grant access to the level they are at or below

        -- Organization-wide Levels:

        -- Level 10 is for organization-wide management
            -- Owner is Level 10 by default
        -- Level 9 is for IT and security
            -- Controls online integrations and security
        -- Level 8 is for multi-facility green buyers
            -- Can add new green coffees as well as archive old ones
            -- Can create a shipment of green coffee
        -- Level 7 is for global recipe control
            -- Can create new recipes and archive old ones

        -- Facility-specific levels:

        -- Level 6 is for facility-specific management
            -- Read/write access to everything for the facility assigned
        -- Level 5 is for scheduling and production management
        -- Level 4 is for inventory management
            -- Can change inventory levels via cycle counts
        -- Level 3 is for quality team members
        -- Level 2 is for roasters
        -- Level 1 is for packers and shippers
        -- Level 0 is the default level for all members and is read-only
CREATE TABLE "orgs_members"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "user" BIGINT NOT NULL,
    "level" BIGINT NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL,
    "last_login" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: orgs_tags
    -- Tag-management system for organizations to easily filter and search
CREATE TABLE "orgs_tags"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "tag" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- ------------------------------------------------------------

-- COFFEE TABLES: Recipe and ingredient tables for coffee roasting
-- Each entry must be tied to an organization to keep recipes private

-- Table: green
-- Pedigree information for green coffee. Recipes are built from these
CREATE TABLE "green"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "tags" VARCHAR(255) DEFAULT NULL,
    "name" VARCHAR(255) NOT NULL,
    "country" BIGINT NOT NULL,
    "importer" VARCHAR(255) DEFAULT NULL,
    "price" VARCHAR(255) DEFAULT NULL,
    "price_currency" BIGINT DEFAULT NULL,
    "init_purchase_volume" VARCHAR(255) NOT NULL DEFAULT '0',
    "farm" VARCHAR(255) DEFAULT NULL,
    "iso" VARCHAR(255) DEFAULT NULL,
    "crop_year" VARCHAR(255) DEFAULT NULL,
    "processing_method" BIGINT DEFAULT NULL,
    "flavors" VARCHAR(255) DEFAULT NULL,
    "cup_score" VARCHAR(255) DEFAULT NULL,
    "notes" VARCHAR(255) DEFAULT NULL,
    "active" BOOLEAN DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- Table: single_origins
    -- Recipe for a single origin coffee created from a single green component
    -- Min and max of 1 component
CREATE TABLE "single_origins"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "use_baskets" BOOLEAN NOT NULL DEFAULT FALSE,
    "green" BIGINT NOT NULL,
    "loss_percent" VARCHAR(255) NOT NULL,
    "flavors" VARCHAR(255) DEFAULT NULL,
    "target_color" VARCHAR(255) DEFAULT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL,
);

-- Table: blends
    -- Recipe for a blend of green components
    -- Up to 6 components can be used, minimum of 2
    -- Each component must have a percentage
CREATE TABLE "blends"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "use_baskets" BOOLEAN NOT NULL DEFAULT FALSE,
    "blend_component_1" BIGINT NOT NULL,
    "blend_component_2" BIGINT NOT NULL,
    "blend_component_3" BIGINT DEFAULT NULL,
    "blend_component_4" BIGINT DEFAULT NULL,
    "blend_component_5" BIGINT DEFAULT NULL,
    "blend_component_6" BIGINT DEFAULT NULL,
    "blend_component_1_percent" BIGINT NOT NULL,
    "blend_component_2_percent" BIGINT NOT NULL,
    "blend_component_3_percent" BIGINT DEFAULT NULL,
    "blend_component_4_percent" BIGINT DEFAULT NULL,
    "blend_component_5_percent" BIGINT DEFAULT NULL,
    "blend_component_6_percent" BIGINT DEFAULT NULL,
    "loss_percent" VARCHAR(255) NOT NULL DEFAULT '20',
    "flavors" VARCHAR(255) DEFAULT NULL,
    "target_color" VARCHAR(255) DEFAULT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL,
);

-- Table: post_roast_blends
    -- Recipe for a blend of post-roast components
    -- Up to 6 components can be used, minimum of 2
    -- Each component must have a percentage
    -- Created using roasted components from a blend or single origin
CREATE TABLE "post_roast_blends"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "pr_component_1" VARCHAR(255) NOT NULL,
    "pr_component_2" VARCHAR(255) NOT NULL,
    "pr_component_3" VARCHAR(255) DEFAULT NULL,
    "pr_component_4" VARCHAR(255) DEFAULT NULL,
    "pr_component_5" VARCHAR(255) DEFAULT NULL,
    "pr_component_6" BIGINT DEFAULT NULL,
    "pr_component_1_percent" BIGINT NOT NULL,
    "pr_component_2_percent" BIGINT NOT NULL,
    "pr_component_3_percent" BIGINT DEFAULT NULL,
    "pr_component_4_percent" BIGINT DEFAULT NULL,
    "pr_component_5_percent" BIGINT DEFAULT NULL,
    "pr_component_6_percent" BIGINT DEFAULT NULL,
    "flavors" BIGINT DEFAULT NULL,
    "target_color" VARCHAR(255) DEFAULT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL,
);

CREATE TABLE "facilities"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "roasters"( 
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "facility" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "brand" VARCHAR(255) NOT NULL,
    "model" VARCHAR(255) NOT NULL,
    "capacity" VARCHAR(255) NOT NULL,
    "min_batch_size" VARCHAR(255) NOT NULL,
    "max_batch_size" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "green_inventory"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "facility" BIGINT NOT NULL,
    "green_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "roasted_inventory"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "facility" BIGINT NOT NULL,
    "roasted_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "finished_products"( 
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "tags" VARCHAR(255) DEFAULT NULL,
    "recipe_id" BIGINT NOT NULL,
    "packaging_id" BIGINT DEFAULT NULL,
    "label_id" BIGINT DEFAULT NULL,
    "content_weight" VARCHAR(255) NOT NULL,
    "total_weight" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "packaging"( 
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "labels"( 
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "fp_packaging"( 
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "fp_id" BIGINT NOT NULL,
    "packaging_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE "title_descriptors"(
    "id" SERIAL PRIMARY KEY,
    "descriptor" VARCHAR(255) NOT NULL
);



CREATE TABLE "currencies"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "country" VARCHAR(255) NOT NULL,
    "symbol" BIGINT NOT NULL
);



CREATE TABLE "currency_symbols"(
    "id" SERIAL PRIMARY KEY,
    "symbol" VARCHAR(255) NOT NULL
);



CREATE TABLE "flavors"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL
);

CREATE TABLE "countries"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "iso_code" BIGINT NOT NULL,
    "phone_code" BIGINT NOT NULL
);

CREATE TABLE "processing_methods"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL
);

CREATE TABLE "states"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "country" BIGINT NOT NULL
);

