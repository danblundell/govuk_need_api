require_relative '../integration_test_helper'

class SearchingNeedsTest < ActionDispatch::IntegrationTest

  setup do
    login_as_stub_user
    use_test_index
  end

  teardown do
    delete_test_index
  end

  should "return no results on an empty index" do
    get "/needs?q=user"
    body = JSON.parse(last_response.body)
    assert_equal 0, body["results"].count
  end

  should "return a result that matches on a text field" do
    post_json "/needs", {
       role: "student",
       goal: "apply for student finance",
       benefit: "I can get the money I need to go to university",
       author: { name: "Bob", email: "bob@example.com" },
       applies_to_all_organisations: true,
       in_scope: false,
       out_of_scope_reason: "foo"
    }.to_json

    assert_equal 201, last_response.status

    refresh_index

    get "/needs?q=student"
    body = JSON.parse(last_response.body)
    assert_equal 1, body["results"].count
    assert_equal "apply for student finance", body["results"].first["goal"]
    assert_equal true, body["results"].first["applies_to_all_organisations"]
    assert_equal false, body["results"].first["in_scope"]
  end

  should "match a result with a similar word" do
    post_json "/needs", {
       role: "student",
       goal: "apply for student finance",
       benefit: "I can get the money I need to go to university",
       author: { name: "Bob", email: "bob@example.com" }
    }.to_json

    assert_equal 201, last_response.status

    refresh_index

    get "/needs?q=students"
    body = JSON.parse(last_response.body)
    assert_equal 1, body["results"].count
    assert_equal "apply for student finance", body["results"].first["goal"]
  end

  should "match a result on the need ID" do
    post_json "/needs", {
       role: "student",
       goal: "apply for student finance",
       benefit: "I can get the money I need to go to university",
       author: { name: "Bob", email: "bob@example.com" }
    }.to_json

    assert_equal 201, last_response.status
    submitted_need = JSON.parse(last_response.body)

    refresh_index

    get "/needs?q=#{submitted_need["id"]}"

    body = JSON.parse(last_response.body)
    assert_equal 1, body["results"].count
    assert_equal "apply for student finance", body["results"].first["goal"]
  end
end
