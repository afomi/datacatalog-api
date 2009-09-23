# National Data Catalog API

The National Data Catalog stores metadata about data sets and APIs published by all leves of government. It helps developers search for, identify, and work with data sources that would otherwise take significant effort to track down.

Currently, the National Data Catalog consists of a web front-end that is powered by an API back-end.

## Accessing the API

The API is RESTful and speaks JSON. It will throw appropriate HTTP status codes on errors, along with a helpful error message passed as a JSON object.

All calls regarding Users and Sources must include an API Key as a parameter.
User accounts can be registered on the National Data Catalog website and curator/admin access can be granted via the Contact Us form.

To view general information:

    http://sandbox.nationaldatacatalog.com/
    
To view available resources for an anonymous user:

    http://sandbox.nationaldatacatalog.com/resources
    
To view available resources for a keyed user:

    http://sandbox.nationaldatacatalog.com/resources?api_key=YOURAPIKEY

To view status of a user via her API key:

    http://sandbox.nationaldatacatalog.com/checkup?api_key=YOURAPIKEY
    
## User

The `User` resource represents a user account, which comes with an API key and the ability to request more API keys. In addition to anonymous users, there are three types of keyed users:

1. **Plain user** - Has read access to data sources and other users. Has full access to own user profile.
2. **Curator** - Has full access to data sources and own user profile. Has read access to other users.
3. **Admin** - Has full access to data sources and all users.

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

*Note*: All calls assume an added `api_key=YOURAPIKEY` as a parameter.

Get all users:

    GET http://sandbox.nationaldatacatalog.com/users
    
Get all users named John:

    GET http://sandbox.nationaldatacatalog.com/users?first_name=John

Get one user:

    GET http://sandbox.nationaldatacatalog.com/users/SOMEUSERID
    
Create a new user:

    POST http://sandbox.nationaldatacatalog.com/users

Update an existing user:

    PUT http://sandbox.nationaldatacatalog.com/users/SOMEUSERID
    
Delete an existing user:

    DELETE http://sandbox.nationaldatacatalog.com/users/SOMEUSERID
    
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

*Note*: All calls assume an added `api_key=YOURAPIKEY` as a parameter.

Get a user's API keys:

    GET http://sandbox.nationaldatacatalog.com/users/SOMEUSERID/keys

Get one API key:

    GET http://sandbox.nationaldatacatalog.com/users/SOMEUSERID/keys/SOMEKEYID
    
Create a new key:

    POST http://sandbox.nationaldatacatalog.com/users/SOMEUSERID/keys

Update an existing key:

    PUT http://sandbox.nationaldatacatalog.com/users/SOMEUSERID/keys/SOMEKEYID
    
Delete an existing key:

    DELETE http://sandbox.nationaldatacatalog.com/users/SOMEUSERID/keys/SOMEKEYID
    
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
    ratings_total*          Integer        Sum of ratings. Divide by ratings_count to get average.
    ratings_count*          Integer        Number of ratings.
    created_at*             Time           Automatic timestamp on creation
    updated_at*             Time           Automatic timestamp on update

### API Calls for Source

A normal user can read sources, while curators and admins can perform full CRUD on sources.

*Note*: All calls assume an added `api_key=YOURAPIKEY` as a parameter.

Get all sources:

    GET http://sandbox.nationaldatacatalog.com/sources

Get one source:

    GET http://sandbox.nationaldatacatalog.com/sources/SOMESOURCEID
    
Create a new source:

    POST http://sandbox.nationaldatacatalog.com/sources

Update an existing source:

    PUT http://sandbox.nationaldatacatalog.com/sources/SOMESOURCEID
    
Delete an existing source:

    DELETE http://sandbox.nationaldatacatalog.com/sources/SOMESOURCEID
    
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