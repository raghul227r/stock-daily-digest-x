# stock-twitter-digest

Emails you a daily digest of what X (Twitter) said about your tracked Indian stocks in the
past 24 hours: summary, what happened, sentiment, notable posts and unverified claims.

Stocks live in `stocks.yaml`; secrets live in `.env` (never committed).

## 1. Get the credentials
| Variable | Where from |
|---|---|
| `X_BEARER_TOKEN` | console.x.com > your app > Keys & Tokens > Bearer Token (add credits under Billing) |
| `ANTHROPIC_API_KEY` | console.anthropic.com > API keys (add credits under Billing) |
| `SMTP_USER` | the Gmail address that sends the digest |
| `SMTP_PASSWORD` | Gmail **app password** (needs 2-Step Verification): myaccount.google.com/apppasswords |
| `MAIL_TO` | optional; defaults to `SMTP_USER` |

## 2. Install
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env      # then fill in the values
```

## 3. Configure stocks
Edit `stocks.yaml`. Each stock needs a `name`; `symbol`, `aliases` and a custom `query` are optional.
If no `query` is given, one is built automatically: `("Name" OR "alias" OR SYMBOL OR #Name)`.

## 4. Try it
```bash
python stock_digest.py --dry-run --only Pricol   # writes output/digest-<date>.html, sends nothing
python stock_digest.py                           # full run, sends the email
```
`--dry-run` still calls the X and Claude APIs, so it uses a little credit.

## 5. Schedule on a Mac (daily 6 AM)
```bash
./install_launchd.sh          # 6:00 AM local time; or ./install_launchd.sh 7 30
launchctl kickstart -k gui/$(id -u)/com.stockdigest.daily   # run it right now to test
```
Notes:
- The Mac must be **on and awake** at the scheduled time. If it is asleep, launchd runs the job
  when it wakes; if it is powered off, that day is skipped.
- To wake it just before the run (works best plugged in):
  `sudo pmset repeat wakeorpoweron MTWRFSU 05:58:00`
- Keep the project in your home folder (e.g. `~/Projects`), not in Documents/Desktop/Downloads,
  to avoid macOS privacy prompts blocking background jobs.
- Logs: `logs/digest.log` and `logs/digest.err.log`.
- Uninstall: `launchctl bootout gui/$(id -u)/com.stockdigest.daily && rm ~/Library/LaunchAgents/com.stockdigest.daily.plist`

## Cost
X charges per post read (check your Developer Console for the current rate). At 15 stocks x 50 posts
that is about 750 reads a day. Lower `max_posts_per_stock` in `stocks.yaml` to spend less. Claude
usage is 15 short summaries a day.

## Security
`.env` is in `.gitignore`. If a key leaks, regenerate it in the provider's console.
