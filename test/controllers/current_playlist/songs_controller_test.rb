# frozen_string_literal: true

require "test_helper"

class CurrentPlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @playlist = @user.current_playlist
    @playlist.song_ids = [1, 2]

    login @user
  end

  test "should show current playlist songs" do
    get current_playlist_songs_url
    assert_response :success
  end

  test "should add song next to the current song when current song did set" do
    cookies[:current_song_id] = @playlist.song_ids.first

    post current_playlist_songs_url, params: {song_id: 3}, xhr: true
    assert_equal [1, 3, 2], @playlist.reload.song_ids
  end

  test "should add song to the first position when current song did not set" do
    post current_playlist_songs_url, params: {song_id: 3}, xhr: true
    assert_equal [3, 1, 2], @playlist.reload.song_ids
  end

  test "should has error flash when song alreay in playlist" do
    post current_playlist_songs_url, params: {song_id: 2}, xhr: true
    assert flash[:error].present?
  end
end
