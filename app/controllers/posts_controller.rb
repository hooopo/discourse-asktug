# frozen_string_literal: true
PostsController.class_eval do
  def create
    manager_params = create_params
    manager_params[:first_post_checks] = !is_api?
    manager_params[:advance_draft] = !is_api?

    manager = NewPostManager.new(current_user, manager_params)

    json =
      if is_api?
        memoized_payload =
          DistributedMemoizer.memoize(signature_for(manager_params), 120) do
            MultiJson.dump(serialize_data(manager.perform, NewPostResultSerializer, root: false))
          end

        JSON.parse(memoized_payload)
      else
        serialize_data(manager.perform, NewPostResultSerializer, root: false)
      end

    backwards_compatible_json(json)
  end
end
