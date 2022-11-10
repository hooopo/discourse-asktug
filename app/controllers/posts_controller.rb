# frozen_string_literal: true
PostsController.class_eval do
  def create
    @manager_params = create_params
    @manager_params[:first_post_checks] = !is_api?
    @manager_params[:advance_draft] = !is_api?

    # The asynchronous process is triggered when the target user is greater than 600,
    # because after the asynchronous process is used, the page may get 404, try to reduce
    if @manager_params[:target_group_names].present? && Group.where(name: @manager_params[:target_group_names].split(",")).map{|x| x.users}.flatten.size > 600
      result = NewPostResult.new(:created_post, true)
      manager = Jobs::AsyncNewPostManager.new.perform(current_user, @manager_params)
      sleep 8
      result.post = current_user.posts.last
      json = serialize_data(result, NewPostResultSerializer, root: false)
      backwards_compatible_json(json, result.success?)
    else
      manager = NewPostManager.new(current_user, @manager_params)

      if is_api?
        memoized_payload = DistributedMemoizer.memoize(signature_for(@manager_params), 120) do
          result = manager.perform
          MultiJson.dump(serialize_data(result, NewPostResultSerializer, root: false))
        end

        parsed_payload = JSON.parse(memoized_payload)
        backwards_compatible_json(parsed_payload, parsed_payload['success'])
      else
        result = manager.perform
        json = serialize_data(result, NewPostResultSerializer, root: false)
        backwards_compatible_json(json, result.success?)
      end
    end
  end
end
