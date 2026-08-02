# ⚽ UEFA Champions League Analysis (Snowflake SQL)

## 📌 Project Overview
The UEFA Champions League is the pinnacle of European club football. This project leverages **Snowflake SQL** to analyze performance metrics across the 2020–2021, 2021–2022, and 2022–2023 seasons. 

The analysis focuses on home-field goal efficiency, ball possession dominance, and match anomaly tracking (teams winning physical duels but losing matches).

---

## 📊 Database Schema & Data Structure

* **Schema Name:** `SOCCER`
* **Tables:** `TBL_UEFA_2020` | `TBL_UEFA_2021` | `TBL_UEFA_2022`

> **Note:** All database object names, tables, and columns follow Snowflake's default **UPPERCASE** naming convention.

| Column | Description | Data Type |
| :--- | :--- | :--- |
| `STAGE` | Stage of the match | `VARCHAR(50)` |
| `DATE` | Match date | `DATE` |
| `PENS` | Penalty shootout indicator | `VARCHAR(50)` |
| `PENS_HOME_SCORE` | Penalty score for home team | `VARCHAR(50)` |
| `PENS_AWAY_SCORE` | Penalty score for away team | `VARCHAR(50)` |
| `TEAM_NAME_HOME` | Home team name | `VARCHAR(50)` |
| `TEAM_NAME_AWAY` | Away team name | `VARCHAR(50)` |
| `TEAM_HOME_SCORE` | Goals scored by home team | `NUMBER` |
| `TEAM_AWAY_SCORE` | Goals scored by away team | `NUMBER` |
| `POSSESSION_HOME` | Ball possession % for home team | `FLOAT` |
| `POSSESSION_AWAY` | Ball possession % for away team | `FLOAT` |
| `TOTAL_SHOTS_HOME` | Shots by home team | `NUMBER` |
| `TOTAL_SHOTS_AWAY` | Shots by away team | `NUMBER` |
| `SHOTS_ON_TARGET_HOME` | Shots on target for home team | `FLOAT` |
| `SHOTS_ON_TARGET_AWAY` | Shots on target for away team | `FLOAT` |
| `DUELS_WON_HOME` | Duels won by home team | `NUMBER` |
| `DUELS_WON_AWAY` | Duels won by away team | `NUMBER` |
| `PREDICTION_TEAM_HOME_WIN` | Home win probability | `FLOAT` |
| `PREDICTION_DRAW` | Draw probability | `FLOAT` |
| `PREDICTION_TEAM_AWAY_WIN` | Away win probability | `FLOAT` |
| `LOCATION` | Stadium location | `VARCHAR(50)` |

---

## 💡 Business Questions & Snowflake SQL Solutions

### 1️⃣ Top 3 Home Scoring Teams (2020-21)
**Objective:** Find the top 3 teams that scored the highest total goals playing on home ground during the 2020-21 season.

### 2️⃣ Most Dominant Possession Team (2021-22)
Objective: Identify the team that secured majority possession (> 50%) in the highest number of matches during the 2021-22 season

### 3️⃣ Teams Winning Duels But Losing the Match (2022-23 Stage-Wise)
Objective: Extract a stage-wise list of teams that won more physical duels during a match but still lost the game in the 2022-23 tournament.
