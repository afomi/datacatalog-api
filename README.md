# Gem Dependencies

## Production

    sudo gem sources -a http://gems.github.com
    sudo gem install sinatra
    sudo gem install mongomapper

## Testing

    # sudo gem install jeremymcanally-context
    sudo gem install djsun-context
    sudo gem install jeremymcanally-pending
    
    
# Setting up config files

* Create a `config/config.yml`, based off `config/config_example.yml`
* If using Passenger to run the app (or for deployment), create a `config.ru` based off `config.ru.example`.