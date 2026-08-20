# Claude AI for Loopback

A **Claude skill or custom configuration for the IBM LoopBack 4 framework** equips AI coding assistants like Claude Code with deep context on TypeScript-based models, controllers, repositories, and dependency injection patterns used in LoopBack architecture.

## Core Components of an LB4 Claude Skill

- Scaffolding Rules: Teaches the AI how to use lb4 CLI commands for models, controllers, and datasources correctly.
- TypeScript & DI Patterns: Enforces LoopBack 4's inversion of control, decorators (@inject, @repository), and component architecture.
- Data Access: Guides correct integration with connectors (PostgreSQL, MongoDB, REST/SOAP).
- Decorator Mastery: Properly implements TypeScript decorators like @model, @property, @repository, and @get/@post` routing annotations.
- DI & IoC Understanding: Configures binding scopes, providers, and component integrations unique to LoopBack 4's inversion of control container.
- Testing Conventions: Aligns with standard project setup, using Mocha, Supertest, and acceptance/integration/unit testing layouts under src/**tests**/.

## Setting Up a LoopBack 4 Skill File (CLAUDE.md)

To give Claude persistent instructions for a LoopBack 4 repository, place a CLAUDE.md file in your project root with build and test rules:

- Build Commands: npm run build or lb-tsc
- Test Commands: npm test (runs unit, integration, and acceptance tests in dist/**tests**)
- Lint/Format: npm run lint and npm run prettier:fix
- Architecture Rules: Enforce strict separation between Controllers (HTTP layer), Repositories (Data access), and Models (Business data).

The current CLAUDE.md file was extracted from [oficial loopback-next](https://github.com/loopbackio/loopback-next/blob/master/CLAUDE.md) and adjusted accordingly.

## Claude Skill for LoopBack 4 and MySQL (AI Overview)

A complete, custom Claude Skill profile optimized for a new LoopBack 4 and MySQL project. Save this content as .clauderules or loopback4-mysql-skill.md in the root directory of your workspace. When you start a chat, point Claude to this file to instantly align its code generation with LoopBack 4's architecture.

_saved on loopback4-skill.md_

### CLI commands

To get your application up and running with Model containing users, orders, products using a MySQL database-backed application, run these sequential LoopBack 4 CLI commands inside your terminal.

#### 1. Initialize the Project & Connect MySQL

Run these commands in your terminal to set up the project and configure your MySQL datasource:

_saved on .loopback4-setup.sh_

When prompted for the datasource:

- Datasource name: db
- Select connector: MySQL

#### 2. Generate the Models

Run the lb4 model command for each entity. Copy and paste the property configurations exactly as prompted by the CLI:

##### Create the User Model

> lb4 model User

- Base class: Entity
- Property: id ➔ Type: number, ID: yes, Generated: yes
- Property: email ➔ Type: string, Required: yes
- Property: name ➔ Type: string, Required: no

##### Create the Product Model

> lb4 model Product

- Base class: Entity
- Property: id ➔ Type: number, ID: yes, Generated: yes
- Property: title ➔ Type: string, Required: yes
- Property: price ➔ Type: number, Required: yes
- Property: stock ➔ Type: number, Required: yes

##### Create the Order Model

> lb4 model Order

- Base class: Entity
- Property: id ➔ Type: number, ID: yes, Generated: yes
- Property: userId ➔ Type: number, Required: yes (Foreign Key for User)
- Property: total ➔ Type: number, Required: yes
- Property: status ➔ Type: string, Required: yes

#### 3. Generate Repositories and Controllers

Once your models are defined, generate the data layers and standard CRUD REST endpoints:

> lb4 repository

- Select all three models (User, Product, Order).
- Select your db datasource.

Generate REST Controllers

> lb4 controller UserController --type REST --model User --repository UserRepository
> lb4 controller ProductController --type REST --model Product --repository ProductRepository
> lb4 controller OrderController --type REST --model Order --repository OrderRepository

If you are ready to configure relationships, let me know:

- Should a User have many Orders?
- Should an Order contain many Products (requiring a many-to-many join table)?

I can provide the CLI commands or source code to set up those database relations.
