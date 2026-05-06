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

  private

  def parse_json_ld(html)
    JSON.parse(html.match(%r{<script type="application/ld\+json">\s*(.*?)\s*</script>}m)[1])
  end
end
