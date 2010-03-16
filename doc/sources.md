## Source

Data sources are the primary feature of the National Data Catalog. They are representations of data sets and APIs. See sources.md for more information.

## Schema

    Field              R  W  Type       Description
    -----              -  -  ----       -----------
    id                 R     String     Unique ID (auto-generated upon creation)
    title                 W  String     Unique name of data source
    slug                     String     URL slug (auto-generated if not provided)
    source_type           W  String     Either "dataset" or "api"
    url                   W  String     Primary URL for this data source (should have metadata) 
    documentation_url        String     Official documentation for data source 
    license                  String     License for the data (e.g. public domain)
    license_url              String     URL describing license
    catalog_name             String     Name of originating catalog (e.g. 'data.gov')
    catalog_url              String     URL of originating catalog   
    released                 Date Hash  When this source was publicly released
    period_start             Date Hash  Beginning date for source's applicability
    period_end               Date Hash  End date for source's applicability
    frequency                String     How often the data source is released
    organization_id          String     Organization that published this source.
    ratings            R     Array      Embedded collection of Rating objects
    rating_stats       R     Hash       Contains total, count, and average.
    created_at         R     Time       Automatic timestamp on creation
    updated_at         R     Time       Automatic timestamp on update

*Notes*:

* R denotes read-only fields
* W denotes required fields when writing (creating or updating)
* "Date Hash" is a Ruby hash intended for use with the Kronos gem.

## Permissions

	Permission   Who
	----------   ---
	List         (add information here)
	Create       (add information here)
	Read         (add information here)
	Update       (add information here)
	Delete       (add information here)

## API Calls

*Note*: You will need to add `api_key=MY_API_KEY` to the examples below.

A normal user can read sources, while curators and admins can perform full CRUD on sources.

Get all sources:

    GET http://sandbox.nationaldatacatalog.com/sources?api_key=MY_API_KEY

Get one source:

    GET http://sandbox.nationaldatacatalog.com/sources/SOURCE_ID?api_key=MY_API_KEY
    
Create a new source:

    POST http://sandbox.nationaldatacatalog.com/sources?api_key=MY_API_KEY

Update an existing source:

    PUT http://sandbox.nationaldatacatalog.com/sources/SOURCE_ID?api_key=MY_API_KEY
    
Delete an existing source:

    DELETE http://sandbox.nationaldatacatalog.com/sources/SOURCE_ID?api_key=MY_API_KEY
