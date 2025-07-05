# 📝 Blog API

A RESTful blog API built with **Ruby on Rails**, supporting authentication, post and comment management, tagging, and automatic cleanup. Containerized using **Docker** with dedicated setups for development and testing.

---

## Features

- JWT authentication (signup/login)
- Create, read, update, and delete blog posts
- Each post must have at least one tag
- Add, edit, and delete comments
- Only post authors can modify and delete their posts and comments
- Posts auto-deleted 24 hours after creation (via Sidekiq)
- RSpec test suite

---

## Development Setup

1. **Build and start development environment**

```bash
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up -d
```

This will start the app, database, Redis, and Sidekiq for development.

---

## Running Tests

1. **Start test environment with services**

```bash
docker compose -f docker-compose.test.yml up -d --build
```

2. **Run test suite**

```bash
docker compose -f docker-compose.test.yml run test bundle exec rspec
```

---

## 🔐 Authentication

All API endpoints require authentication except for:

- `POST /api/v1/signup`
- `POST /api/v1/login`

**Use JWT in headers**:

```http
Authorization: Bearer <your_token>
```

---

## Background Jobs

Posts are automatically deleted 24 hours after creation using a Sidekiq background job.

---

## Project Structure Highlights

- `app/controllers/api/v1/` – Namespaced API controllers
- `app/models/` – Core models: `User`, `Post`, `Comment`, `Tag`
- `app/jobs/` – Background job: `PostCleanupJob`
- `spec/requests/` – RSpec request tests

---

## 🧹 Cleanup

To stop and remove containers:

```bash
docker compose -f docker-compose.dev.yml down
```

For test environment:

```bash
docker compose -f docker-compose.test.yml down
```