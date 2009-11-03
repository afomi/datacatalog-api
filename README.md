# Install MongoDB

* Download the latest MongoDB stable build from http://www.mongodb.org/display/DOCS/Downloads
* Setup and run Mongo using the directions at http://www.mongodb.org/display/DOCS/Getting+Started

# Gem Dependencies

    # If you have not used gemcutter before:
    gem install gemcutter
    gem tumble
    
    # Install dependencies with a rake task:
    rake dependencies:install

# Setting up Config Files

* Create a `config/config.yml`, based off `config/config_example.yml`
* If using Passenger to run the app (or for deployment), create a `config.ru` based off `config.ru.example`.

# Running Test Suite

* Make sure MongoDB is running (see above)
* Run `rake test`
