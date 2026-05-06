require "test_helper"

class PageStructuredDataTest < ActiveSupport::TestCase
  setup do
    @original_base_app_name = PageStructuredData.base_app_name
    @original_render_default_breadcrumb_json_ld = PageStructuredData.render_default_breadcrumb_json_ld
    PageStructuredData.base_app_name = nil
    PageStructuredData.render_default_breadcrumb_json_ld = true
  end

  teardown do
    PageStructuredData.base_app_name = @original_base_app_name
    PageStructuredData.render_default_breadcrumb_json_ld = @original_render_default_breadcrumb_json_ld
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

  test "pages can opt out of default breadcrumb json ld" do
    PageStructuredData.render_default_breadcrumb_json_ld = false
    page = PageStructuredData::Page.new(title: "Home")

    assert_equal "", page.json_lds
  end

  test "explicit breadcrumbs render when default breadcrumb json ld is disabled" do
    PageStructuredData.render_default_breadcrumb_json_ld = false
    breadcrumbs = PageStructuredData::Breadcrumbs.new(
      hierarchy: [{ title: "Resources", href: "https://example.com/resources" }]
    )
    page = PageStructuredData::Page.new(title: "Article", breadcrumb: breadcrumbs)

    json_ld = parse_json_ld(page.json_lds)

    assert_equal "BreadcrumbList", json_ld["@type"]
    assert_equal ["Resources", "Article"], json_ld["itemListElement"].map { |item| item["name"] }
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

  test "blog posting renders interaction statistics from convenience counts" do
    page_type = PageStructuredData::PageTypes::BlogPosting.new(
      headline: "Launch Notes",
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC"),
      likes_count: 42,
      comments_count: 0,
      shares_count: 7
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal(
      [
        {
          "@type" => "InteractionCounter",
          "interactionType" => { "@type" => "LikeAction" },
          "userInteractionCount" => 42
        },
        {
          "@type" => "InteractionCounter",
          "interactionType" => { "@type" => "CommentAction" },
          "userInteractionCount" => 0
        },
        {
          "@type" => "InteractionCounter",
          "interactionType" => { "@type" => "ShareAction" },
          "userInteractionCount" => 7
        }
      ],
      json_ld["interactionStatistic"]
    )
  end

  test "blog posting renders provided interaction statistics" do
    page_type = PageStructuredData::PageTypes::BlogPosting.new(
      headline: "Launch Notes",
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC"),
      interaction_statistics: [
        PageStructuredData::PageTypes::InteractionStatistic.new(
          interaction_type: :like,
          user_interaction_count: 42
        ),
        {
          "@type" => "InteractionCounter",
          interactionType: { "@type" => "WatchAction" },
          userInteractionCount: 12
        }
      ]
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "LikeAction", json_ld["interactionStatistic"][0]["interactionType"]["@type"]
    assert_equal 42, json_ld["interactionStatistic"][0]["userInteractionCount"]
    assert_equal "WatchAction", json_ld["interactionStatistic"][1]["interactionType"]["@type"]
    assert_equal 12, json_ld["interactionStatistic"][1]["userInteractionCount"]
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

  test "interaction statistic exposes schema hash" do
    interaction_statistic = PageStructuredData::PageTypes::InteractionStatistic.new(
      interaction_type: :like,
      user_interaction_count: 42,
      interaction_service: {
        "@type" => "WebSite",
        name: "Example",
        url: "https://example.com"
      }
    )

    assert_equal(
      {
        "@type" => "InteractionCounter",
        "interactionType" => { "@type" => "LikeAction" },
        "userInteractionCount" => 42,
        "interactionService" => {
          "@type" => "WebSite",
          "name" => "Example",
          "url" => "https://example.com"
        }
      },
      interaction_statistic.to_h.deep_stringify_keys
    )
  end

  test "discussion forum posting renders article-like schema" do
    page_type = PageStructuredData::PageTypes::DiscussionForumPosting.new(
      headline: "Is schema.org useful?",
      text: "A public forum post about structured data.",
      image: "https://example.com/post.png",
      url: "https://example.com/posts/1",
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC"),
      authors: [{ name: "Jane Doe", url: "https://example.com/jane" }],
      interaction_statistics: [PageStructuredData::PageTypes::InteractionStatistic.comment(25)]
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "DiscussionForumPosting", json_ld["@type"]
    assert_equal "Is schema.org useful?", json_ld["headline"]
    assert_equal "A public forum post about structured data.", json_ld["articleBody"]
    assert_equal ["https://example.com/post.png"], json_ld["image"]
    assert_equal "https://example.com/posts/1", json_ld["url"]
    assert_equal "CommentAction", json_ld["interactionStatistic"][0]["interactionType"]["@type"]
    assert_equal 25, json_ld["interactionStatistic"][0]["userInteractionCount"]
  end

  test "organization renders required schema" do
    page_type = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com"
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "https://schema.org", json_ld["@context"]
    assert_equal "Organization", json_ld["@type"]
    assert_equal "RocketApex", json_ld["name"]
    assert_equal "https://rocketapex.com", json_ld["url"]
    refute json_ld.key?("logo")
    refute json_ld.key?("sameAs")
    refute json_ld.key?("parentOrganization")
    refute json_ld.key?("description")
    refute json_ld.key?("founder")
  end

  test "organization is available from the gem entrypoint" do
    assert PageStructuredData::PageTypes::Organization
  end

  test "organization renders optional schema" do
    page_type = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com",
      description: "Open source projects from RocketApex",
      logo: "https://rocketapex.com/logo.png",
      same_as: ["https://github.com/RocketApex"],
      parent_organization: { name: "Parent Org", url: "https://parent.example" },
      founder: { '@type': 'Person', name: "Jane Doe", url: "https://example.com/jane" }
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "Open source projects from RocketApex", json_ld["description"]
    assert_equal "https://rocketapex.com/logo.png", json_ld["logo"]
    assert_equal ["https://github.com/RocketApex"], json_ld["sameAs"]
    assert_equal(
      { "@type" => "Organization", "name" => "Parent Org", "url" => "https://parent.example" },
      json_ld["parentOrganization"]
    )
    assert_equal(
      { "@type" => "Person", "name" => "Jane Doe", "url" => "https://example.com/jane" },
      json_ld["founder"]
    )
  end

  test "organization exposes schema hash" do
    page_type = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com",
      description: "Open source projects from RocketApex",
      logo: "https://rocketapex.com/logo.png",
      same_as: ["https://github.com/RocketApex"],
      parent_organization: { name: "Parent Org", url: "https://parent.example" },
      founder: { '@type': 'Person', name: "Jane Doe", url: "https://example.com/jane" }
    )

    assert_equal(
      {
        "@context" => "https://schema.org",
        "@type" => "Organization",
        "name" => "RocketApex",
        "url" => "https://rocketapex.com",
        "description" => "Open source projects from RocketApex",
        "logo" => "https://rocketapex.com/logo.png",
        "sameAs" => ["https://github.com/RocketApex"],
        "parentOrganization" => {
          "@type" => "Organization",
          "name" => "Parent Org",
          "url" => "https://parent.example"
        },
        "founder" => {
          "@type" => "Person",
          "name" => "Jane Doe",
          "url" => "https://example.com/jane"
        }
      },
      page_type.to_h.deep_stringify_keys
    )
  end

  test "website renders schema" do
    organization = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com"
    )
    page_type = PageStructuredData::PageTypes::WebSite.new(
      name: "RocketApex",
      url: "https://rocketapex.com",
      description: "Open source projects from RocketApex",
      publisher: organization,
      potential_action: {
        '@type': 'SearchAction',
        target: "https://rocketapex.com/search?q={search_term_string}",
        'query-input': "required name=search_term_string"
      }
    )

    json_ld = parse_json_ld(page_type.json_ld)

    assert_equal "https://schema.org", json_ld["@context"]
    assert_equal "WebSite", json_ld["@type"]
    assert_equal "RocketApex", json_ld["name"]
    assert_equal "https://rocketapex.com", json_ld["url"]
    assert_equal "Open source projects from RocketApex", json_ld["description"]
    assert_equal "Organization", json_ld["publisher"]["@type"]
    assert_equal "SearchAction", json_ld["potentialAction"]["@type"]
  end

  test "website exposes schema hash" do
    page_type = PageStructuredData::PageTypes::WebSite.new(
      name: "RocketApex",
      url: "https://rocketapex.com"
    )

    assert_equal(
      {
        "@context" => "https://schema.org",
        "@type" => "WebSite",
        "name" => "RocketApex",
        "url" => "https://rocketapex.com"
      },
      page_type.to_h.deep_stringify_keys
    )
  end

  test "page renders organization page type json ld" do
    PageStructuredData.render_default_breadcrumb_json_ld = false
    page_type = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com"
    )
    page = PageStructuredData::Page.new(title: "About", page_type: page_type)

    json_ld = parse_json_ld(page.json_lds)

    assert_equal "Organization", json_ld["@type"]
    assert_equal "RocketApex", json_ld["name"]
  end

  test "page renders multiple page types" do
    PageStructuredData.render_default_breadcrumb_json_ld = false
    organization = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com"
    )
    website = PageStructuredData::PageTypes::WebSite.new(
      name: "RocketApex",
      url: "https://rocketapex.com",
      publisher: organization
    )
    page = PageStructuredData::Page.new(
      title: "Home",
      page_types: [organization, website]
    )

    json_lds = parse_json_lds(page.json_lds)

    assert_equal ["Organization", "WebSite"], json_lds.map { |json_ld| json_ld["@type"] }
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

  test "organization json ld escapes name urls description logo same as founder and parent organization" do
    dangerous_value = "</script><script>alert(1)</script>"
    page_type = PageStructuredData::PageTypes::Organization.new(
      name: "Org #{dangerous_value}",
      url: "https://example.com/#{dangerous_value}",
      description: "Description #{dangerous_value}",
      logo: "https://example.com/#{dangerous_value}.png",
      same_as: ["https://github.com/#{dangerous_value}"],
      founder: {
        '@type': 'Person',
        name: "Founder #{dangerous_value}",
        url: "https://founder.example/#{dangerous_value}"
      },
      parent_organization: {
        name: "Parent #{dangerous_value}",
        url: "https://parent.example/#{dangerous_value}"
      }
    )

    html = page_type.json_ld
    json_ld = parse_json_ld(html)

    assert_json_ld_escapes_script_breaking_content(html, dangerous_value)
    assert_equal "Org #{dangerous_value}", json_ld["name"]
    assert_equal "https://example.com/#{dangerous_value}", json_ld["url"]
    assert_equal "Description #{dangerous_value}", json_ld["description"]
    assert_equal "https://example.com/#{dangerous_value}.png", json_ld["logo"]
    assert_equal ["https://github.com/#{dangerous_value}"], json_ld["sameAs"]
    assert_equal "Founder #{dangerous_value}", json_ld["founder"]["name"]
    assert_equal "https://founder.example/#{dangerous_value}", json_ld["founder"]["url"]
    assert_equal "Parent #{dangerous_value}", json_ld["parentOrganization"]["name"]
    assert_equal "https://parent.example/#{dangerous_value}", json_ld["parentOrganization"]["url"]
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
