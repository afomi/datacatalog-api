# User

The `User` resource represents a user account. A user account starts off with a primary API key. Using this key, you can request more API keys.

There are three types of users:

1. **basic** - Has read access to data sources and other users. Has full access to own user profile.
2. **curator** - Has full access to data sources and own user profile. Has read access to other users.
3. **admin** - Has full access to data sources and all users.

## Schema

    Field                 R  W  Type     Description
    -----                 -  -  ----     -----------
    id                    R     String   Unique ID (auto-generated upon creation)
    name                        String   User's real name
    email                       String   User's email address
    curator                     Boolean  Is the user a curator?
    admin                       Boolean  Is the user an admin?
    api_keys                    Array    Embedded collection of ApiKey objects
    primary_api_key       R     String   Convenience method
    application_api_keys  R     String   Convenience method
    valet_api_keys        R     String   Convenience method
    created_at            R     Time     Automatic timestamp on creation
    updated_at            R     Time     Automatic timestamp on update

*Notes*:

* R denotes read-only fields
* W denotes required fields when writing (creating or updating)

## Permissions

	Permission   Who
	----------   ---
	List         basic
	Create       basic
	Read         curator
	Update       curator
	Delete       curator

## API Calls

The `User` resource responds to standard CRUD operations, according to the permissions above. You will need to add `api_key=MY_API_KEY` to the examples below.

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

