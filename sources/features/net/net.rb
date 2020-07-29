require 'rest-client'

# we use API-method for a clearing state

def delete_all_posts_from_profile

  token = $user[:accesstoken]
  user_id = $user[:userid]

  response_posts = RestClient.get 'https://test/users/' + user_id + '/posts?filter=0&limit=100&offset=0',
      {'access-token' => token}

  post_id = Array.new
  post_id.clear

  list_post = JSON.parse(response_posts.body)
  post_items = list_post['items']
  post_items.each {|value| post_id << value['id']}

  for i in 0..post_id.length - 1

    RestClient.delete 'https://test/posts/' + post_id[i].to_s,
        {'access-token' => token}

    sleep(1.5)
  end

end
