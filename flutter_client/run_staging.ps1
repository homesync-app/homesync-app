$ErrorActionPreference = 'Stop'

flutter run --dart-define-from-file=.env.local --dart-define=APP_ENV=staging @args
