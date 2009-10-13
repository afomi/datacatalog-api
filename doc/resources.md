# National Data Catalog API Resources

This document contains a list of resources made available by the National Data Catalog API.

## User

The `User` resource represents a user account. A user account starts off with a primary API key. Using this key, you can request more API keys.

There are three types of users:

1. **basic** - Has read access to data sources and other users. Has full access to own user profile.
2. **curator** - Has full access to data sources and own user profile. Has read access to other users.
3. **admin** - Has full access to data sources and all users.

### Schema for User

    Asterisk (*) denotes read-only fields

    Parameter               Type           Description
    ---------               ----           -----------
    id*                     String         Unique ID, will be auto-generated upon creation
    name                    String         User's real name
    email                   String         User's email address
    curator                 Boolean        Is the user a curator?
    admin                   Boolean        Is the user an admin?
    api_keys                Array          Embedded collection of ApiKey objects (see below)
    primary_api_key*        String         Convenience method
    application_api_keys*   String         Convenience method
    valet_api_keys*         String         Convenience method
    created_at*             Time           Automatic timestamp on creation
    updated_at*             Time           Automatic timestamp on update

### API Calls for User

According to the access rules described above, the `User` resource responds to standard CRUD operations.

*Note*: All calls assume an added `api_key=MY_API_KEY` as a parameter.

Get all users:

    GET http://sandbox.nationaldatacatalog.com/users
    
Get all users named John:

    GET http://sandbox.nationaldatacatalog.com/users?first_name=John

Get one user:

    GET http://sandbox.nationaldatacatalog.com/users/USER_ID
    
Create a new user:

    POST http://sandbox.nationaldatacatalog.com/users

Update an existing user:

    PUT http://sandbox.nationaldatacatalog.com/users/USER_ID
    
Delete an existing user:

    DELETE http://sandbox.nationaldatacatalog.com/users/USER_ID
    
## ApiKey

There are three types of API Keys:

1. **Primary** - Created when a new `user` is created. Cannot be deleted.
2. **Application** - For developers who need their applications to access the API.
3. **Valet** - For users to give other applications access to their user-specific data. May be replaced in the future by OAuth.

### Schema for ApiKey

    Asterisk (*) denotes read-only fields
    Plus (+) denotes required fields when creating and updating

    Parameter               Type           Description
    ---------               ----           -----------
    id*                     String         Unique ID, will be auto-generated upon creation
    api_key                 String         Unique key to be used
    key_type+               String         Must be "application" or "valet".
    purpose+                String         User-supplied description of key's use
    created_at*             Time           Automatic timestamp on creation
    updated_at*             Time           Automatic timestamp on update
    
### API Calls for ApiKey

A user can perform CRUD on her own keys, as can an admin user. `Keys` are nested underneath the `User` resource.

*Note*: All calls assume an added `api_key=MY_API_KEY` as a parameter.

Get a user's API keys:

    GET http://sandbox.nationaldatacatalog.com/users/USER_ID/keys

Get one API key:

    GET http://sandbox.nationaldatacatalog.com/users/USER_ID/keys/KEY_ID
    
Create a new key:

    POST http://sandbox.nationaldatacatalog.com/users/USER_ID/keys

Update an existing key:

    PUT http://sandbox.nationaldatacatalog.com/users/USER_ID/keys/KEY_ID
    
Delete an existing key:

    DELETE http://sandbox.nationaldatacatalog.com/users/USER_ID/keys/KEY_ID
    
## Source

Data sources are the primary feature of the National Data Catalog. They are representations of data sets and APIs.

### Schema for Source

    Asterisk (*) denotes read-only fields
    Plus (+) denotes required fields when creating and updating

    Parameter               Type           Description
    ---------               ----           -----------
    id*                     String         Unique ID, will be auto-generated upon creation
    title(+)                String         Required, unique name of data source
    url                     String         Primary URL for this data source
    released                Date           When this source was publicly released
    period_start            Date           Beginning date for source's applicability
    period_end              Date           End date for source's applicability
    frequency               String         How often the data source is released
    ratings                 Array          Embedded collection of Rating objects
    rating_stats*           Hash           Contains total, count, average, and histogram
    created_at*             Time           Automatic timestamp on creation
    updated_at*             Time           Automatic timestamp on update

### API Calls for Source

A normal user can read sources, while curators and admins can perform full CRUD on sources.

*Note*: All calls assume an added `api_key=MY_API_KEY` as a parameter.

Get all sources:

    GET http://sandbox.nationaldatacatalog.com/sources

Get one source:

    GET http://sandbox.nationaldatacatalog.com/sources/SOURCE_ID
    
Create a new source:

    POST http://sandbox.nationaldatacatalog.com/sources

Update an existing source:

    PUT http://sandbox.nationaldatacatalog.com/sources/SOURCE_ID
    
Delete an existing source:

    DELETE http://sandbox.nationaldatacatalog.com/sources/SOURCE_ID
    
## Coming Soon...

All the supporting/embedded resources for data sources:

* User ratings - 1 to 5 star ratings by users
* Comments - user comments about the data
* Organization - host organization of the data (e.g. FEC or Center for Responsive Politics)
* Notes - user notes about the data source
* Tags - collection of tags (both user and curator provided) for the data source
* Documents - wiki-like user-generated documentation for a source
* Category - curated category for enhanced browsing

Also, custom fields for sources, so that on create/update one can pass in fields that were not predicted to be needed in advance, like "Documentation URL" or "Fear Factor".