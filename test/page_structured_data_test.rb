require "test_helper"

class PageStructuredDataTest < ActiveSupport::TestCase
  setup do
    @original_base_app_name = PageStructuredData.base_app_name
    PageStructuredData.base_app_name = nil
  end

  teardown do
    PageStructuredData.base_app_name = @original_base_app_name
  end

  test "it has a version number" do
    assert PageStructuredData::VERSION
  end

  test "builds page title from title extra title breadcrumbs and base app name" do
    PageStructuredData.base_app_name = "Example"
    breadcrumbs = PageStructuredData::Breadcrumbs.new(
      hierarchy: [
        { title: "Resources", href: "https://example.com/resources" },
        { title: "Articles", href: "https://example.com/resources/articles" }
      ]
    )

    page = PageStructuredData::Page.new(
      title: "Launch Notes",
      extra_title: "Official",
      breadcrumb: breadcrumbs
    )

    assert_equal "Launch Notes - Official - Articles - Resources - Example", page.page_title
  end

  test "pages include default breadcrumb json ld" do
    page = PageStructuredData::Page.new(title: "Home")

    json_ld = parse_json_ld(page.json_lds)

    assert_equal "https://schema.org", json_ld["@context"]
    assert_equal "BreadcrumbList", json_ld["@type"]
    assert_equal [{ "@type" => "ListItem", "position" => 1, "name" => "Home" }], json_ld["itemListElement"]
  end

  test "breadcrumbs include hierarchy and current page" do
    breadcrumbs = PageStructuredData::Breadcrumbs.new(
      hierarchy: [{ title: "Resources", href: "https://example.com/resources" }]
    )

    json_ld = parse_json_ld(breadcrumbs.json_ld(current_page_title: "Article"))

    assert_equal [
      {
        "@type" => "ListItem",
        "position" => 1,
        "name" => "Resources",
        "item" => "https://example.com/resources"
      },
      { "@type" => "ListItem", "position" => 2, "name" => "Article" }
    ], json_ld["itemListElement"]
  end

  test "breadcrumbs expose schema hash" do
    breadcrumbs = PageStructuredData::Breadcrumbs.new(
      hierarchy: [{ title: "Resources", href: "https://example.com/resources" }]
    )

    assert_equal(
      {
        "@context" => "https://schema.org",
        "@type" => "BreadcrumbList",
        "itemListElement" => [
          {
            "@type" => "ListItem",
            "position" => 1,
            "name" => "Resources",
            "item" => "https://example.com/resources"
          },
          { "@type" => "ListItem", "position" => 2, "name" => "Article" }
        ]
      },
      breadcrumbs.to_h(current_page_title: "Article").deep_stringify_keys
    )
  end

  test "blog posting renders article schema" do
    page_type = PageStructuredData::PageTypes::BlogPosting.new(
      headline: "Launch Notes",
      images: ["https://example.com/cover.png"],
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC"),
      authors: [{ name: "Jane Doe", url: "https://example.com/jane" }]
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "BlogPosting", json_ld["@type"]
    assert_equal "Launch Notes", json_ld["headline"]
    assert_equal ["https://example.com/cover.png"], json_ld["image"]
    assert_equal [{ "@type" => "Person", "name" => "Jane Doe", "url" => "https://example.com/jane" }], json_ld["author"]
  end

  test "blog posting exposes schema hash" do
    page_type = PageStructuredData::PageTypes::BlogPosting.new(
      headline: "Launch Notes",
      images: ["https://example.com/cover.png"],
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC"),
      authors: [{ name: "Jane Doe", url: "https://example.com/jane" }]
    )

    schema = page_type.to_h.deep_stringify_keys

    assert_equal "https://schema.org", schema["@context"]
    assert_equal "BlogPosting", schema["@type"]
    assert_equal "Launch Notes", schema["headline"]
    assert_equal ["https://example.com/cover.png"], schema["image"]
    assert_equal [{ "@type" => "Person", "name" => "Jane Doe", "url" => "https://example.com/jane" }], schema["author"]
  end

  test "news article renders article schema" do
    page_type = PageStructuredData::PageTypes::NewsArticle.new(
      headline: "Launch Notes",
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC")
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "NewsArticle", json_ld["@type"]
    assert_equal "Launch Notes", json_ld["headline"]
    assert_equal [], json_ld["image"]
    assert_equal [], json_ld["author"]
  end

  test "page renders breadcrumbs before page type json ld" do
    breadcrumbs = PageStructuredData::Breadcrumbs.new(
      hierarchy: [{ title: "Resources", href: "https://example.com/resources" }]
    )
    page_type = PageStructuredData::PageTypes::NewsArticle.new(
      headline: "Launch Notes",
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC")
    )
    page = PageStructuredData::Page.new(
      title: "Launch Notes",
      breadcrumb: breadcrumbs,
      page_type: page_type
    )

    json_lds = parse_json_lds(page.json_lds)

    assert_equal ["BreadcrumbList", "NewsArticle"], json_lds.map { |json_ld| json_ld["@type"] }
    assert_equal "Launch Notes", json_lds.first["itemListElement"].last["name"]
    assert_equal "Launch Notes", json_lds.second["headline"]
  end

  test "json ld escapes script-breaking content" do
    dangerous_value = "</script><script>alert(1)</script>"
    page = PageStructuredData::Page.new(title: dangerous_value)

    html = page.json_lds

    assert_json_ld_escapes_script_breaking_content(html, dangerous_value)
    assert_equal dangerous_value, parse_json_ld(html)["itemListElement"].first["name"]
  end

  test "breadcrumb json ld escapes hierarchy titles and urls" do
    dangerous_value = "</script><script>alert(1)</script>"
    breadcrumbs = PageStructuredData::Breadcrumbs.new(
      hierarchy: [{ title: dangerous_value, href: "https://example.com/#{dangerous_value}" }]
    )

    html = breadcrumbs.json_ld(current_page_title: "Current #{dangerous_value}")
    json_ld = parse_json_ld(html)

    assert_json_ld_escapes_script_breaking_content(html, dangerous_value)
    assert_equal dangerous_value, json_ld["itemListElement"].first["name"]
    assert_equal "https://example.com/#{dangerous_value}", json_ld["itemListElement"].first["item"]
    assert_equal "Current #{dangerous_value}", json_ld["itemListElement"].second["name"]
  end

  test "article json ld escapes headline images and author data" do
    dangerous_value = "</script><script>alert(1)</script>"
    page_type = PageStructuredData::PageTypes::BlogPosting.new(
      headline: "Headline #{dangerous_value}",
      images: ["https://example.com/#{dangerous_value}.png"],
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC"),
      authors: [{ name: "Author #{dangerous_value}", url: "https://example.com/authors/#{dangerous_value}" }]
    )

    html = page_type.json_ld
    json_ld = parse_json_ld(html)

    assert_json_ld_escapes_script_breaking_content(html, dangerous_value)
    assert_equal "Headline #{dangerous_value}", json_ld["headline"]
    assert_equal ["https://example.com/#{dangerous_value}.png"], json_ld["image"]
    assert_equal "Author #{dangerous_value}", json_ld["author"].first["name"]
    assert_equal "https://example.com/authors/#{dangerous_value}", json_ld["author"].first["url"]
  end

  private

  def parse_json_ld(html)
    parse_json_lds(html).first
  end

  def parse_json_lds(html)
    html.scan(%r{<script type="application/ld\+json">\s*(.*?)\s*</script>}m).map do |match|
      JSON.parse(match.first)
    end
  end

  def assert_json_ld_escapes_script_breaking_content(html, dangerous_value)
    escaped_value = dangerous_value.gsub("<", "\\u003c").gsub(">", "\\u003e")

    assert_includes html, escaped_value
    refute_includes html, dangerous_value
  end
end
