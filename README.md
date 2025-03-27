# luckyluke
Luck is not merely random; luck is a choice.
# Lottery Game Picking System

A lottery game system featuring Mega 6/45 and Power 6/55 games.

## Tech Stack

- **Backend**: Go
- **Frontend**: Svelte
- **Database**: PostgreSQL
- **Containerization**: Docker & Docker Compose
- **Version Control**: Git

## Products

### Mega 6/45
- Players select 6 numbers from a pool of 1 to 45
- Prize Categories:
  - Jackpot: Matches all 6 numbers
  - First Prize: Matches 5 numbers
  - Second Prize: Matches 4 numbers
  - Third Prize: Matches 3 numbers

### Power 6/55
- Players choose 6 numbers from 1 to 55
- Prize Categories:
  - Jackpot 1: Matches all 6 main numbers
  - Jackpot 2: Matches 5 main numbers plus the bonus number
  - First Prize: Matches 5 main numbers
  - Second Prize: Matches 4 main numbers
  - Third Prize: Matches 3 main numbers

## Setup and Installation

1. Clone the repository
2. Run `docker-compose up -d`
3. Access the frontend at `http://localhost:3000`
4. API is available at `http://localhost:8080`

## Development

Instructions for local development setup can be found in each component's directory.
