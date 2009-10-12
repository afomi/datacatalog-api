# Install MongoDB

* Download the latest MongoDB stable build from http://www.mongodb.org/display/DOCS/Downloads
* Setup and run Mongo using the directions at http://www.mongodb.org/display/DOCS/Getting+Started

# Gem Dependencies

## Production

    gem install gemcutter
    gem tumble
    gem install sinatra
    gem install mongo
    gem install djsun-mongomapper
    gem install rest-sinatra
    gem install frequency

## Testing

    gem install rcov
    gem install rack-test
    gem install djsun-context
    gem install jeremymcanally-pending
    gem install rr
    gem install timecop
    
# Setting up Config Files

* Create a `config/config.yml`, based off `config/config_example.yml`
* If using Passenger to run the app (or for deployment), create a `config.ru` based off `config.ru.example`.

# Running Test Suite

* Make sure MongoDB is running (see above)
* Run `rake test`
