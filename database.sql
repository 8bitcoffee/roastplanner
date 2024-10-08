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

-- Table: users_facilities
    -- Table for storing facility access for users
    -- Users can be members of multiple facilities but have only one level in an organization
CREATE TABLE "users_facilities"(
    "id" SERIAL PRIMARY KEY,
    "user" BIGINT NOT NULL,
    "facility" BIGINT NOT NULL,
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
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
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
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
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
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- ------------------------------------------------------------

-- PHYSICAL EQUIPMENT TABLES:

-- Table: Facilities
    -- Facilites are the physical locations where equipment and inventory are stored
    -- Each facility is tied to an organization
CREATE TABLE "facilities"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "address_1" VARCHAR(255) DEFAULT NULL,
    "address_2" VARCHAR(255) DEFAULT NULL,
    "city" VARCHAR(255) DEFAULT NULL,
    "state" VARCHAR(255) DEFAULT NULL,
    "country" BIGINT DEFAULT NULL,
    "zip" VARCHAR(255) DEFAULT NULL,
    "active" BOOLEAN NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- Table: Roasters
    -- Roasters are the physical machines used to roast coffee
    -- Each roaster is tied to a facility
    -- Specs for roasters are required to populate schedules
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

-- ------------------------------------------------------------

-- INVENTORY TABLES: Tables for tracking inventory of bulk roasted and finished products

-- Table: roasted_inventory
    -- Inventory of roasted coffee in bulk
    -- Each entry is tied to a facility
    -- Each entry is tied to a roasted product
    -- Quantity is in kilograms
    -- Created by loose leftover roasted coffee from a batch
CREATE TABLE "roasted_inventory"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "facility" BIGINT NOT NULL,
    "roasted_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- Table: finished_products
    -- Inventory of finished products ready for sale
    -- Leftover packaged coffee from a batch
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
    "sku" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- Table: packing
    -- Inventory of packaging materials
    -- Each entry is tied to a facility
CREATE TABLE "packaging"( 
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- Table: labels
    -- Inventory of labels
    -- Each entry is tied to an organization
CREATE TABLE "labels"( 
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" TIMESTAMP(0) WITH TIME ZONE DEFAULT NULL
);

-- ------------------------------------------------------------
-- TRANSACTION TABLES: Tables for tracking transactions and batches

-- Table: roast_cycles
    -- Table for tracking roast cycles
    -- Each entry is tied to a facility
    -- Each entry is tied to a roaster
    -- Each entry is tied to a recipe
    -- Batch size and post-roast weight are in kilograms
    -- Created by a user when a batch is roasted
CREATE TABLE "roast_cycles"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "roaster" BIGINT NOT NULL,
    "recipe_id" BIGINT NOT NULL,
    "batch_size" VARCHAR(255) NOT NULL,
    "post_roast_weight" VARCHAR(255) NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: packaging_batches
    -- Table for tracking packaging batches
    -- Each entry is tied to a facility
    -- Each entry is tied to a finished product
    -- Each entry is tied to a packaging material
    -- Each entry is tied to a label
    -- Quantity is in units
    -- Created by a user when a batch is packaged
CREATE TABLE "packaging_batches"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "fp_id" BIGINT NOT NULL,
    "packaging_id" BIGINT NOT NULL,
    "label_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: green_transactions
    -- Table for tracking green coffee transactions
    -- Each entry is tied to a facility
    -- Each entry is tied to a green coffee
    -- Quantity is in kilograms
    -- Created by a user when a transaction is made
CREATE TABLE "green_transactions"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "green_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: roasted_transactions
    -- Table for tracking roasted coffee transactions
    -- Each entry is tied to a facility
    -- Each entry is tied to a roasted coffee
    -- Quantity is in kilograms
    -- Created by a user when a transaction is made
CREATE TABLE "roasted_transactions"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "roasted_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: packaging_transactions
    -- Table for tracking packaging material transactions
    -- Each entry is tied to a facility
    -- Each entry is tied to a packaging material
    -- Quantity is in units
    -- Created by a user when a transaction is made
CREATE TABLE "packaging_transactions"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "packaging_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: label_transactions
    -- Table for tracking label transactions
    -- Each entry is tied to a facility
    -- Each entry is tied to a label
    -- Quantity is in units
    -- Created by a user when a transaction is made
CREATE TABLE "label_transactions"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "label_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: finished_product_transactions
    -- Table for tracking finished product transactions
    -- Each entry is tied to a facility
    -- Each entry is tied to a finished product
    -- Quantity is in units
    -- Created by a user when a transaction is made
CREATE TABLE "finished_product_transactions"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "fp_id" BIGINT NOT NULL,
    "quantity" BIGINT NOT NULL,
    "created" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- SCHEDULE TABLES: Tables for tracking production schedules

-- Table: orders
    -- Table tracking orders from online sources
    -- Each entry is tied to an organization
    -- Boolean for whether the order has been fulfilled
    -- Boolean for retail or wholesale
CREATE TABLE "orders"(
    "id" SERIAL PRIMARY KEY,
    "org" BIGINT NOT NULL,
    "order_number" VARCHAR(255) NOT NULL,
    "order_date" TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fulfilled" BOOLEAN NOT NULL DEFAULT FALSE,
    "wholesale" BOOLEAN NOT NULL DEFAULT FALSE,
    "order_details" JSONB NOT NULL
);

-- Table: schedules
    -- Table for tracking production schedules
    -- Each entry is tied to a facility
    -- Each schedule has a start time
    -- The schedule is a json object populated according to orders
CREATE TABLE "schedules"(
    "id" SERIAL PRIMARY KEY,
    "facility" BIGINT NOT NULL,
    "time" TIMESTAMP(0) WITH TIME ZONE NOT NULL,
    "schedule" JSONB NOT NULL
);



-- ------------------------------------------------------------
-- REFERENCE TABLES: Tables for storing reference data

-- Table: titles
    -- Table for storing titles
CREATE TABLE "title_descriptors"(
    "id" SERIAL PRIMARY KEY,
    "descriptor" VARCHAR(255) NOT NULL
);

-- Table: currencies
    -- Table for storing currencies
    -- symbol references currency_symbols
CREATE TABLE "currencies"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "country" VARCHAR(255) NOT NULL,
    "symbol" BIGINT NOT NULL
);

-- Table: currency_symbols
    -- Table for storing currency symbols
CREATE TABLE "currency_symbols"(
    "id" SERIAL PRIMARY KEY,
    "symbol" VARCHAR(255) NOT NULL
);

-- Table: flavors
    -- Table for storing flavor descriptions
CREATE TABLE "flavors"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL
);

-- Table: countries
    -- Table for storing countries
    -- iso_code is the country specific iso code
    -- phone_code is the country's phone code
CREATE TABLE "countries"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "iso_code" BIGINT NOT NULL,
    "phone_code" BIGINT NOT NULL
);

-- Table: processing_methods
    -- Table for storing processing methods
CREATE TABLE "processing_methods"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL
);

-- Table: states
    -- Table for storing states
    -- country references countries table
CREATE TABLE "states"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "country" BIGINT NOT NULL
);