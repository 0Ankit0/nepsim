# NEPSIM QA Testing Guide

## 1) Prerequisites

- PostgreSQL running on localhost:5432
- PostgreSQL credentials:
  - username: `postgres`
  - password: `postgres`
- Python venv available at `backend/.venv`
- Node dependencies installed in `frontend/`

## 2) Run Backend + Frontend (QA Ports)

Run backend on port `8001`:

```bash
source /media/ankit/Programming/Projects/python/fastapi/nepsim/backend/.venv/bin/activate
cd /media/ankit/Programming/Projects/python/fastapi/nepsim/backend
uvicorn src.main:app --host 0.0.0.0 --port 8001 --reload
```

Run frontend on port `3001`:

```bash
cd /media/ankit/Programming/Projects/python/fastapi/nepsim/frontend
npm run dev -- --host 0.0.0.0 --port 3001
```

Frontend env expected in `frontend/.env`:

```env
VITE_API_URL=http://localhost:8001/api/v1
VITE_WS_URL=ws://localhost:8001
```

## 3) Apply Migrations (PostgreSQL)

```bash
source /media/ankit/Programming/Projects/python/fastapi/nepsim/backend/.venv/bin/activate
cd /media/ankit/Programming/Projects/python/fastapi/nepsim/backend
alembic upgrade head
```

## 4) Seed QA Data

Core NEPSIM seed (stocks, achievements, lessons/quizzes):

```bash
export DATABASE_URL='postgresql+asyncpg://postgres:postgres@localhost/nepsim'
export SYNC_DATABASE_URL='postgresql+psycopg2://postgres:postgres@localhost/nepsim'
export POSTGRES_SERVER='localhost'
export POSTGRES_DB='nepsim'
export POSTGRES_USER='postgres'
export POSTGRES_PASSWORD='postgres'
source /media/ankit/Programming/Projects/python/fastapi/nepsim/backend/.venv/bin/activate
python3 /media/ankit/Programming/Projects/python/fastapi/nepsim/backend/scripts/seed_market_data.py
```

QA fixture seed (users/roles + watchlist/portfolio/simulation sample data):

```bash
export DATABASE_URL='postgresql+asyncpg://postgres:postgres@localhost/nepsim'
export SYNC_DATABASE_URL='postgresql+psycopg2://postgres:postgres@localhost/nepsim'
export POSTGRES_SERVER='localhost'
export POSTGRES_DB='nepsim'
export POSTGRES_USER='postgres'
export POSTGRES_PASSWORD='postgres'
source /media/ankit/Programming/Projects/python/fastapi/nepsim/backend/.venv/bin/activate
python3 /media/ankit/Programming/Projects/python/fastapi/nepsim/backend/scripts/seed_qa_data.py
```

Seeded QA users:

- `qa_admin` / `QaPass123!` (superuser)
- `qa_trader` / `QaPass123!` (normal user)
- `qa_analyst` / `QaPass123!` (normal user)

## 5) Manual UI QA Checklist

Open `http://localhost:3001` and test:

Public pages:

- `/`
- `/login`
- `/signup`
- `/forgot-password`

Trader workflow (`qa_trader`):

- Login and land on `/dashboard`
- Open each page from sidebar:
  - `/market`
  - `/portfolio`
  - `/watchlist`
  - `/analysis`
  - `/stock360`
  - `/simulator`
  - `/learn`
  - `/settings`
  - `/profile`
  - `/finances`
  - `/notifications`
  - `/tokens`
- Validate seeded data appears in watchlist/portfolio/simulator sections.

Admin workflow (`qa_admin`):

- Login and open admin routes:
  - `/admin/dashboard`
  - `/admin/users`
  - `/admin/market`
  - `/admin/simulator`
  - `/admin/learn`
- Confirm admin pages are accessible only to superuser account.

Authorization checks:

- Non-admin user should be redirected away from `/admin/*`
- Logged-out user should be redirected to `/login` for protected routes.

## 6) API Smoke QA

```bash
TRADER_ACCESS=$(curl -s -X POST 'http://localhost:8001/api/v1/auth/login/?set_cookie=false' \
  -H 'Content-Type: application/json' \
  --data '{"username":"qa_trader","password":"QaPass123!"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access'])")

ADMIN_ACCESS=$(curl -s -X POST 'http://localhost:8001/api/v1/auth/login/?set_cookie=false' \
  -H 'Content-Type: application/json' \
  --data '{"username":"qa_admin","password":"QaPass123!"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access'])")

for ep in \
  '/api/v1/users/me' \
  '/api/v1/market/stocks' \
  '/api/v1/watchlist/alerts' \
  '/api/v1/portfolio/' \
  '/api/v1/simulations/' \
  '/api/v1/learn/lessons' \
  '/api/v1/notifications/' \
  '/api/v1/tokens/'
do
  code=$(curl -m 8 -s -o /dev/null -w '%{http_code}' "http://localhost:8001${ep}" -H "Authorization: Bearer ${TRADER_ACCESS}")
  echo "${code} ${ep}"
done

for ep in '/api/v1/users/' '/api/v1/users/me' '/api/v1/tokens/' '/api/v1/market/stocks'
do
  code=$(curl -m 8 -s -o /dev/null -w '%{http_code}' "http://localhost:8001${ep}" -H "Authorization: Bearer ${ADMIN_ACCESS}")
  echo "${code} ${ep}"
done
```

## 7) Podman QA (Alternate Port)

Frontend image build and run on `3002`:

```bash
cd /media/ankit/Programming/Projects/python/fastapi/nepsim/frontend
podman build -t nepsim-frontend-qa \
  --build-arg VITE_API_URL=http://localhost:8001/api/v1 \
  --build-arg VITE_WS_URL=ws://localhost:8001 \
  .
podman rm -f nepsim-frontend-qa-run >/dev/null 2>&1 || true
podman run -d --name nepsim-frontend-qa-run -p 3002:80 nepsim-frontend-qa
```

Then test in browser:

- `http://127.0.0.1:3002/`
- `http://127.0.0.1:3002/login`

Stop Podman container:

```bash
podman rm -f nepsim-frontend-qa-run
```

## 8) Known QA Issues Found

- Some market-provider-backed endpoints may block or time out depending on upstream Supabase response latency:
  - `/api/v1/market-analysis/market-overview`
  - `/api/v1/watchlist/`
- Backend now includes timeout guards in market-analysis and watchlist enrichment paths, but upstream unavailability can still degrade those features.

- In some Linux environments, `localhost:3002` may reset while `127.0.0.1:3002` works correctly.
