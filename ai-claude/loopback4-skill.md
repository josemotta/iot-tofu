# Skill: IBM LoopBack 4 with MySQL Specialist

## Context & Stack

- **Framework:** IBM LoopBack 4 (LB4) / TypeScript / Node.js
- **Database:** MySQL
- **Design Pattern:** Domain-Driven Design (DDD), Dependency Injection (DI)

## 1. Project Initialization & CLI Rules

- Always use the LoopBack 4 CLI for generating foundational components. Do not write boilerplate files manually unless requested.
- Recommended generation sequence: `lb4 datasource` -> `lb4 model` -> `lb4 repository` -> `lb4 controller`.

## 2. Datasource Configuration (MySQL)

- Use the `loopback4-connector-mysql` connector.
- Enforce the use of environment variables for credentials in `src/datasources/<name>.datasource.config.json` or `.ts`:
  ```ts
  const config = {
    name: 'db',
    connector: 'mysql',
    url: process.env.DB_URL,
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
  };
  ```

## 3. Model Definition Standards

- Always include `idInjection: true` or manually decorate the primary key with `id: true` and `generated: true`.
- Map property types to valid MySQL data types using the `mysql` setting inside `@property`:
  ```ts
  @property({
    type: 'string',
    required: true,
    mysql: {
      columnName: 'first_name',
      dataType: 'VARCHAR',
      dataLength: 100,
    },
  })
  firstName: string;
  ```

## 4. Repository & Dependency Injection Patterns

- Inject the MySQL datasource into repositories using `@inject('datasources.db')`.
- Define explicit relations (e.g., `HasMany`, `BelongsTo`) using LB4's relational decorators, ensuring correct foreign key naming conventions for MySQL.

## 5. Controller & OpenAPI Standards

- Controllers must define clear REST endpoints (`@get`, `@post`, `@patch`, `@delete`).
- Use typed request bodies and enforce standard HTTP response codes (`200 OK`, `201 Created`, `204 No Content`).
- Utilize standard repository filters (`where`, `include`, `limit`, `offset`) cleanly in controller method arguments.
