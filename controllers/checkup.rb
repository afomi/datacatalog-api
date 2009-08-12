get '/checkup' do
  check_api_key({
    :missing => lambda { CheckupHelper.anonymous },
    :invalid => lambda { CheckupHelper.invalid_api_key },
    :normal  => lambda { CheckupHelper.normal_api_key },
    :admin   => lambda { CheckupHelper.admin_api_key }
  })
end
