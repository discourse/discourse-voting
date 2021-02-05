# frozen_string_literal: true

require 'rails_helper'

describe SearchController do
  fab!(:user) { Fabricate(:user) }

  fab!(:category) { Fabricate(:category) }

  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:topic_2) { Fabricate(:topic, category: category) }

  fab!(:post_1) do
    SearchIndexer.enable
    Fabricate(:post, topic: topic, raw: 'this is an awesome topic')
  end

  fab!(:post_2) do
    SearchIndexer.enable
    Fabricate(:post, topic: topic_2, raw: 'this is an awesome topic')
  end

  before do
    DiscourseVoting::CategorySetting.create!(category: category)
    SiteSetting.voting_enabled = true
    sign_in(user)
  end

  it 'can search for posts ordered by votes' do
    post "/voting/vote.json", params: { topic_id: post_2.topic_id }

    expect(response.status).to eq(200)

    get "/search/query.json", params: {
      term: 'awesome order:votes',
    }

    expect(response.status).to eq(200)

    data = response.parsed_body

    expect(data['posts'].length).to eq(2)
    expect(data['posts'][0]['id']).to eq(post_2.id)
    expect(data['posts'][1]['id']).to eq(post_1.id)
  end

end
