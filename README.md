# Habit Tracker

A full-stack habit tracking app built with Ruby on Rails 8. Users sign up, create habits, mark them done each day, and watch their current and longest streaks grow.

## Features

- **Authentication:** sign up, log in, and log out using Rails 8's built-in session-based authentication, with bcrypt-hashed passwords and rate-limited login and sign-up.
- **Per-user data isolation:** every habit query goes through the logged-in user, so one user can never view, edit, or delete another user's habits (requests for someone else's habit return a 404).
- **Daily completions:** mark a habit done for today or undo it. The button updates in place with Turbo Streams, with no full page reload.
- **Streaks:** current streak and longest streak, calculated from completion dates.
- **Per-user time zones:** each user picks a time zone at sign-up, and "today" is calculated in that zone.
- **Database-enforced uniqueness:** a unique index on `(habit_id, completed_on)` guarantees at most one completion per habit per day, backed by a matching model validation.

## Tech stack

- **Backend:** Ruby 4.0, Ruby on Rails 8.1
- **Frontend:** ERB views, Hotwire (Turbo Drive and Turbo Streams)
- **Database:** SQLite
- **Testing:** Minitest ([32] tests covering models, controllers, authorization, and streak logic)
- **CI:** GitHub Actions (test suite, RuboCop, Brakeman, and bundler-audit on every push and pull request)

## Getting started

Requires Ruby 4.0 or newer (a version manager like [mise](https://mise.jdx.dev) works well) and git.

```bash
git clone https://github.com/MichaelLiang1/habit-tracker.git
cd habit-tracker
bundle install
bin/rails db:setup
bin/rails server
```

Then open http://localhost:3000, click **Sign up**, and create an account.

## Running the tests

```bash
bin/rails test
```

## How it works

**Authentication.** Logging in creates a `Session` row and stores its id in a signed, HTTP-only cookie. A `before_action` in `ApplicationController` loads the session on every request and redirects to the login page when there isn't one. The logged-in user is available as `Current.user`.

**Authorization.** Controllers never look up habits with `Habit.find`. They start from `Current.user.habits`, so Rails automatically adds `WHERE user_id = ...` to every query. Tests cover the case where a second user requests the first user's habit.

**Streaks.** A `Completion` stores a calendar date (`completed_on`), not a timestamp. Streaks are computed by walking back through consecutive dates. The current streak stays alive if you've completed the habit yesterday but not yet today.

## Hard Problems I solved

**Time zones and "today."** The server runs in UTC, so a completion marked at 9pm in Toronto would land on tomorrow's date if the app used the server's clock. I store each user's time zone and compute "today" in that zone, then save the result as a plain date. Because streaks compare dates instead of timestamps, there's no conversion at query time and no off-by-one day around midnight.

**Preventing duplicate completions.** A model validation alone can be bypassed by two simultaneous requests, so I added a unique database index on `(habit_id, completed_on)` as the real guarantee, with the validation on top to give friendly error messages.

## Possible future work

- Calendar or heatmap view of completions
- Habit archiving, so old habits keep their history
- Reminder emails with Solid Queue
- Deployment

