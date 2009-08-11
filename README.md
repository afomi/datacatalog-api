# Install MongoDB

* Download the latest MongoDB stable build from http://www.mongodb.org/display/DOCS/Downloads
* Setup and run Mongo using the directions at http://www.mongodb.org/display/DOCS/Getting+Started

# Gem Dependencies

## Production

    sudo gem sources -a http://gems.github.com
    sudo gem install sinatra
    sudo gem install mongodb-mongo
    sudo gem install jnunemaker-mongomapper

## Testing

    sudo gem install rack-test
    sudo gem install djsun-context
    sudo gem install jeremymcanally-pending
    sudo gem install rr
    
# Setting up Config Files

* Create a `config/config.yml`, based off `config/config_example.yml`
* If using Passenger to run the app (or for deployment), create a `config.ru` based off `config.ru.example`.

# Running Test Suite

* Make sure MongoDB is running (see above)
* Run `rake test`
