# Fonix Chat

A prototype web chat for the Fonix Mobile technical challenge. Users sign up with a confirmed
email address, chat in real time in a single public room over websockets, and get a weekly
summary email.

## The brief

| Requirement | Where |
| --- | --- |
| Rails, git | Rails 8.1, Ruby 3.4.7 |
| Messages sent through websockets | Action Cable: `ChatChannel`, `chat_controller.js` |
| One room all users can access | `Room.general`, `RoomsController` |
| Accounts need a valid email address | Devise with email confirmation |
| Weekly email: messages exchanged last week, and received since your last message | `WeeklyDigestJob`, `WeeklyDigest`, `DigestMailer` |

## How it works

**Accounts** use [Devise](https://github.com/heartcombo/devise) (settings in
`config/initializers/devise.rb`):

- Emails must match `URI::MailTo::EMAIL_REGEXP` and be confirmed via an emailed link (valid for
  2 days) before the user can sign in, open a websocket or receive digests.
- Passwords need 8+ characters. Password reset, "remember me" and an account page are included.
- Paranoid mode stops password reset and resend confirmation revealing which emails have accounts.

**Chat:**

- Everyone lands in `#general`. It's a `Room` record rather than a hard-coded name, so more rooms
  can be added without reworking messages. The sidebar room list is ready for that.
- Messages are sent with `perform("speak")` on the `ChatChannel` subscription, not an HTTP
  request. Once saved, a message broadcasts its rendered HTML to the room (`stream_for room`).
- The websocket connection reuses the Devise session and rejects anonymous or unconfirmed users.
  Validation errors go back to the sender only, and message bodies are HTML-escaped.

**Weekly email:** Solid Queue runs `WeeklyDigestJob` every Monday at 9am UK time
(`config/recurring.yml`) and emails each confirmed user, for example:

```
600 messages have been exchanged in the last week.
You sent 25 and received 575.

750 since your last message on the 1st of February.
```

## Running locally

Requires Ruby 3.4.7, SQLite, and Chrome for the browser specs.

```sh
bin/setup --skip-server   # install gems, prepare the database
bin/rails db:seed         # optional: alice@example.com / bob@example.com, password "password123"
bin/dev                   # http://localhost:3000
```

- Development emails are caught at http://localhost:3000/letter_opener (click confirmation links
  there). Mailer previews are at http://localhost:3000/rails/mailers.
- `bin/rails digest:deliver` sends the weekly email immediately.
- To chat as two users, sign in as Alice in one browser and Bob in a private window.

## Tests

44 RSpec examples with FactoryBot, covering models, Devise configuration, the channel and
websocket authentication, mailers, the job, and headless Chrome specs of two users chatting live
and of signing up.

```sh
bundle exec rspec
bin/rubocop
bin/brakeman
```

## Decisions

- **Devise** rather than the Rails 8 authentication generator: it's well tested and includes
  confirmation and password reset. Following its defaults, users sign in after confirming.
- **"Sent and received in the last week"** is the total posted in the room in the last 7 days
  (as in the brief's example), plus how many of those the user sent and received.
- **"Since your last message"** counts other users' messages after the user's latest one, even if
  that was over a week ago. If they've never posted, it counts from when they joined.
- Only confirmed users get the digest. Users are shown by email address, as that's the only
  detail the brief asks for.
- The default Rails 8 Solid stack (Solid Cable, Solid Queue) means no Redis is needed.

## Next steps

- Let users create rooms, including private rooms only their members can see.
- Display names, typing indicators and online presence.
- Let users unsubscribe from the weekly email.
