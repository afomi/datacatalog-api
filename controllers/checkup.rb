get '/checkup' do
  check_api_key({
    :missing   => lambda { CheckupHelper.anonymous },
    :invalid   => lambda { CheckupHelper.invalid_api_key },
    :non_owner => lambda { CheckupHelper.normal_api_key },
    :owner     => lambda { CheckupHelper.normal_api_key },
    :curator   => lambda { CheckupHelper.curator_api_key },
    :admin     => lambda { CheckupHelper.admin_api_key }
  })
end
