# /organizations resource

    Field         Type     Writable By   Description
    -----         ----     -----------   -----------
    name          String   curator       canonical name
    names         Array    curator       list of names
    acronym       String   curator       acronym
    org_type      String   curator       "commercial", "governmental", or "not-for-profit"
    description   String   curator       description
    slug          String   curator       URL slug, will be auto-generated if not specified
    url           String   curator       URL
    interest      Integer  curator       subjective measure of interest (see note)
    top_level     Boolean  curator       display this organization as a top level "jurisdiction"?
    custom        Hash     admin         custom parameters
    raw           Hash     admin         raw data (usually from the original import)
    user_id       String   nobody        the user that created this entity in the API

    Permission   Who
    ----------   ---
    List         basic
    Create       basic
    Read         curator
    Update       curator
    Delete       curator

## interest

'interest' is a subjective measure of how interesting and relevant an organization is to the National Data Catalog. Specific values are set by our curators and should not be treated as definitive.

## top_level

Set 'top_level' to true to let an organization be used as a highlighted grouping. The National Data Catalog Web App uses this field to make a list of "jurisdictions" for users to filter by; such as:

  * US Federal
  * District of Columbia
  * San Francisco

Why is top_level needed -- couldn't one just test for `parent_id == nil`? Perhaps. However, consider the case of San Francisco and the State of California: the city arguably has the state as an ancestor. (Cities get their charters from states and are subject to their laws.) However, the user interface still wants to present San Francisco as a top-level grouping. This explains the need for the boolean 'top level' flag.
