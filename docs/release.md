# Release Process

Use this checklist for public RubyGems releases.

## Prepare

1. Ensure GitHub Actions is passing on `main`.
2. Add user-facing changes under `## Unreleased` in `CHANGELOG.md`.
3. Start from a clean working tree.

## Build Locally

Run:

```bash
bin/prepare_release 1.0.9
```

The script:

- updates `lib/page_structured_data/version.rb`
- moves `CHANGELOG.md` unreleased notes into the release section
- runs `bundle install`
- runs `bundle exec rake test`
- verifies the gem can be required
- builds the `.gem` file

## Publish

Push to RubyGems manually with MFA:

```bash
gem push page_structured_data-1.0.9.gem --otp YOUR_OTP
```

## Commit And Tag

```bash
git add CHANGELOG.md Gemfile.lock lib/page_structured_data/version.rb
git commit -m "Release 1.0.9"
git tag v1.0.9
git push origin main --tags
```

## Verify

```bash
curl https://rubygems.org/api/v1/gems/page_structured_data.json
```

Confirm the RubyGems version, dependency metadata, and links are correct.
