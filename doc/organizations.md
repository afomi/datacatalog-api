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
