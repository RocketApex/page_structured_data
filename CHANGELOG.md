# Changelog

All notable changes to this project are documented here.

## Unreleased

## 1.0.9 - 2026-05-06

- Add release preparation script and release checklist documentation.
- Add `to_h` schema hash API for organization page types.

## 1.0.8 - 2026-05-06

- Add `PageStructuredData::PageTypes::Organization` for schema.org Organization JSON-LD.

## 1.0.7 - 2026-05-06

- Remove unused generated Rails engine boilerplate files.

## 1.0.6 - 2026-05-06

- Add tests for HTML escaping in rendered meta tags.
- Add tests for script-breaking content in JSON-LD output.
- Add broader JSON-LD escaping coverage for breadcrumbs and article data.
- Extract shared article JSON-LD behavior for `BlogPosting` and `NewsArticle`.
- Add `to_h` schema hash APIs for breadcrumbs and article page types.
- Add tests for pages that render both breadcrumb and page type JSON-LD.
- Align the gemspec Ruby requirement with the Rails 7 baseline.
- Add GitHub Actions CI for tests, require verification, and gem build verification.
- Constrain the Rails dependency to Rails 7.x, matching the tested support baseline.
- Add `render_default_breadcrumb_json_ld` config to opt out of current-page-only breadcrumb JSON-LD.
- Add CI coverage for Rails 7.0, 7.1, 7.2, 8.0, and 8.1.
- Widen the Rails dependency to support Rails 7.x and 8.x.

## 1.0.5 - 2026-05-06

- Previous public release.

## 1.0.4 - 2026-05-06

- Replace the bundled Slim meta tags partial with ERB so applications are not required to use Slim.
- Remove the Slim runtime dependency.
- Add view-rendering tests for the meta tags partial.

## 1.0.3 - 2026-05-06

- Improve RubyGems metadata, documentation links, and public README presentation.

## 1.0.2 - 2026-05-06

- Fix dummy app compatibility with Rails 7.0 by replacing `config.autoload_lib`.
- Fix requiring `page_structured_data` before Rails has already been loaded.
- Add baseline tests for page title composition and JSON-LD output.
- Improve README documentation for installation, configuration, usage, and compatibility.

## 1.0.1

- Previous public release.

## 1.0.0

- Initial public release.
