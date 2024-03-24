
## Start Guide

### Initialize Firebase Cli

If the app uses firebase follow these steps:
1. Download the [firebase CLI](https://firebase.google.com/docs/cli)
2. [Sign in](https://firebase.google.com/docs/cli#sign-in-test-cli) to the firebase CLI

### Run App

1. Install global rds package: Run `dart pub global activate rps`. Ensure to added to path the
    pub-cache bin folder
2. If there is `bootstrap` script in the pubspec.yaml run it. Run `rps bootstrap`
3. If there is `runner:watch` script in the pubspec.yaml, run it. Run `rps runner:watch`.
    PS: This command will remain pending file changes, so once it completes the first build you can 
    move on to the next step 
4. If the app/project has the `Env` class you have to add the .env file in the root and add to your
    command to anchor the app the argument: `--dart-define-from-file=<use-define-config.json|.env>`

## Contributing guide

- To generate the generated dart files `*.g.dart` run the script `runner:watch`. Run `rps runner:watch`
- To generate app launcher icons run the `generate:icons` script. Run `generate:icons`

## Integration scripts

Copy/paste to pubspec.yaml file

### dart

```yaml
scripts:
  # Integration tools
  integration: rps check-format && rps analyze && rps test
  check-format: >-
    dart format --line-length 100 --set-exit-if-changed --output none
    $(find . ! -path "./.dart_tool/**" ! -path "./build/**" -name "*.dart" ! -name "*.g.dart")
  analyze: dart analyze
  test: dart test ./test
```

### flutter

```yaml
scripts:
  # Integration tools
  integration: rps check-format && rps analyze && rps test
  check-format: >-
    dart format --line-length 100 --set-exit-if-changed --output none
    $(find . ! -path "./.dart_tool/**" ! -path "./build/**" -name "*.dart" ! -name "*.g.dart")
  analyze: flutter analyze --no-fatal-infos
  test: flutter test ./test
```
