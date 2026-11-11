# Fonix Chat

A prototype web chat built for the Fonix Mobile technical challenge (2023 v1.1).

A single chat room that every signed-up user can access. Users register with a valid,
confirmed email address, then send and receive messages in real time over websockets.
Every user gets a weekly summary email of the room's activity.

## Requirements from the brief

| Requirement | Status | Where |
| --- | --- | --- |
| Built with Rails | Done | Rails 8.1, Ruby 3.4.7 |
| Git for version control | Done | Commit history in this repository |
| Messages sent through websockets | Done | Action Cable, `ChatChannel#speak` |
| One channel/room that all users can access | Done | `MessagesController#index`, `Message::STREAM` |
| Users create an account with a valid email address | Done | Devise (`:registerable`, `:validatable`, `:confirmable`) |
| Logged in users can send and receive messages | Done | `ChatChannel`, `chat_controller.js` |
| Weekly email with messages exchanged last week and messages received since the user's last message | Done | `WeeklyDigestJob`, `DigestMailer`, `WeeklyDigest` |

## What has been implemented

### Accounts and authentication

- Built with [Devise](https://github.com/heartcombo/devise) using the `database_authenticatable`,
  `registerable`, `recoverable`, `rememberable`, `validatable` and `confirmable` modules. Settings
  are in `config/initializers/devise.rb`.
- **Sign up** (`/users/sign_up`) with email, password and password confirmation.
- **Valid email address** is enforced in two ways:
  - Format validation with the stricter `URI::MailTo::EMAIL_REGEXP` (instead of Devise's
    default `/\A[^@\s]+@[^@\s]+\z/`), case-insensitive uniqueness, and trimming and
    downcasing.
  - **Email confirmation**: after signing up a confirmation link is emailed. Until it's
    clicked, the user can't sign in, open a websocket or receive digests. The link expires
    after 2 days (`confirm_within`). Confirmation emails can be resent from
    `/users/confirmation/new`.
- Passwords must be at least 8 characters.
- Password reset by email, "remember me", and an account page (`/users/edit`, linked from your
  email address in the top bar) to change your email or password or delete your account.
- Paranoid mode is on, so password reset and resend confirmation don't reveal whether an
  email address has an account.
- Devise emails are sent in the background (`deliver_later`).
- The users table was moved over from the Rails 8 authentication generator with a reversible
  migration (`MoveUsersToDevise`). Both store bcrypt hashes, so existing passwords keep working.

### Chat room (websockets)

- The room is the root page and requires a signed in, confirmed user.
- **Sending**: the composer is handled by a Stimulus controller (`chat_controller.js`) which
  calls `perform("speak", { body })` on the `ChatChannel` subscription. No HTTP request is made
  to post a message, it travels over the websocket.
- **Receiving**: `ChatChannel` streams from a single `chat_room` stream. When a message is
  saved, an `after_create_commit` callback renders the message partial and broadcasts it to
  every subscriber, who appends it to the room.
- **Websocket authentication**: the websocket handshake sends the same session cookie, so
  `ApplicationCable::Connection` reads the signed in user from Devise (`env["warden"].user`) and
  rejects anonymous or unconfirmed users.
- Validation errors (blank or over 1,000 characters) are transmitted back to the sender only.
- The page loads the latest 100 messages. Own messages are styled differently, timestamps are
  shown in the browser's time zone, Enter sends and Shift+Enter adds a new line, the view
  auto scrolls when you are at the bottom, and the connection status is shown (the send button
  is disabled while reconnecting).
- Message bodies are escaped by ERB, so HTML from users is rendered as text.

### Weekly digest email

- `WeeklyDigestJob` emails every confirmed user. It is scheduled with Solid Queue's recurring
  tasks (`config/recurring.yml`) for **every Monday at 9am**.
- `WeeklyDigest` calculates the stats for a user, for the week up to the time the job runs:
  - messages exchanged in the room in the last week (with a breakdown of how many the user
    sent and received),
  - messages received from other users since the user's last message, along with the date of
    that message. If the user has never posted, it counts messages since they joined.
- Example output, matching the brief:

  ```
  600 messages have been exchanged in the last week.
  You sent 25 and received 575.

  750 since your last message on the 1st of February.
  ```

### Tests

37 RSpec examples, using FactoryBot for test data:

| Folder | Covers |
| --- | --- |
| `spec/models` | `User`, `Message` (including the broadcast), `WeeklyDigest` counts |
| `spec/requests` | How Devise is configured (sign up, confirmation, sign in/out, password reset) and the chat page |
| `spec/channels` | `ChatChannel` (`speak`, errors) and websocket authentication |
| `spec/mailers` | Confirmation and weekly digest emails |
| `spec/jobs` | `WeeklyDigestJob` only emails confirmed users |
| `spec/features` | Headless Chrome: two users chatting live over websockets, and sign up with email confirmation |

Rubocop (`rubocop-rails-omakase`) and Brakeman both pass with no offences or warnings.

## Running locally

Requirements: Ruby 3.4.7, SQLite, and Chrome for the feature specs.

```sh
bin/setup --skip-server   # installs gems, prepares the database
bin/rails db:seed         # optional: alice@example.com / bob@example.com, password "password123"
bin/dev                   # http://localhost:3000
```

- Emails sent in development (confirmation, password reset, digest) are caught by
  [letter_opener_web](https://github.com/fgrehm/letter_opener_web) at
  http://localhost:3000/letter_opener, so you can click the confirmation link from there.
- Mailer previews are at http://localhost:3000/rails/mailers.
- To send the weekly digest now instead of waiting for Monday, then check letter_opener:

  ```sh
  bin/rails digest:deliver
  ```

To try the chat with two users, sign in as Alice in one browser and Bob in a private window.

### Tests and linting

```sh
bundle exec rspec                 # everything, including the headless Chrome feature specs
bundle exec rspec spec/features   # just the browser specs
bin/rubocop
bin/brakeman
```

## Architecture

| Piece | Responsibility |
| --- | --- |
| `app/models/user.rb` | Devise modules, `confirmed` scope |
| `app/models/message.rb` | Validation, `recent` messages, broadcasts new messages to the room |
| `app/models/weekly_digest.rb` | Stats for the weekly email |
| `app/channels/application_cable/connection.rb` | Authenticates websocket connections with Devise's signed in user |
| `app/channels/chat_channel.rb` | Streams the room, `speak` creates messages |
| `app/javascript/controllers/chat_controller.js` | Websocket client: sends, receives and renders messages |
| `app/controllers/users/registrations_controller.rb` | Devise sign up, sends new users to the sign in page while they confirm |
| `app/views/devise/` | Devise views, styled to match the app |
| `app/jobs/weekly_digest_job.rb` | Sends the digest to every confirmed user |
| `app/mailers/digest_mailer.rb` | Weekly email (HTML and plain text) |

The default Rails 8 "Solid" stack is used, so there is no Redis dependency: Solid Cable backs
Action Cable in production, Solid Queue runs jobs and the recurring schedule. In development
Action Cable uses the in-process async adapter.

## Decisions and assumptions

- **Devise for accounts** rather than the Rails 8 authentication generator. It's the standard,
  well tested choice for Rails apps, and confirmation, password reset, "remember me" and account
  editing come with it instead of being hand written. Following Devise's defaults, a user signs
  in after confirming their email rather than being signed in automatically by the link.
- **"Sent and received in the last week"** is read as the total number of messages posted in
  the single room in the last 7 days (as in the brief's example), plus a personal breakdown of
  how many of those the user sent and received.
- **"Received since the user last sent a message"** counts messages from other users posted
  after the user's most recent message, regardless of whether that falls in the last week.
- Only confirmed users receive the digest, since an unconfirmed address may not be theirs.
- Users are shown by email address, since that is the only detail the brief asks for. A
  display name would be an easy next step.

## Possible next steps

- Load older messages when scrolling up (pagination) and catch up on messages missed while a
  websocket was disconnected.
- Display names and avatars, typing indicators and online presence.
- Multiple rooms, which `Message::STREAM` would become a per-room stream for.
- Allow users to unsubscribe from the weekly email.
- Deployment config (Kamal or a PaaS) with persistent storage for the SQLite databases.
