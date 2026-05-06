# Changelog

All notable changes to this project are documented here.

## Unreleased

- Add tests for HTML escaping in rendered meta tags.
- Add tests for script-breaking content in JSON-LD output.
- Add broader JSON-LD escaping coverage for breadcrumbs and article data.
- Extract shared article JSON-LD behavior for `BlogPosting` and `NewsArticle`.
- Add `to_h` schema hash APIs for breadcrumbs and article page types.
- Add tests for pages that render both breadcrumb and page type JSON-LD.

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
