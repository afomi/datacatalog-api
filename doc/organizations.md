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
    level         Integer  curator       hierarchical level (see note)
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

## interest vs. level

'interest' is a subjective measure of how interesting and relevant an organization is to the National Data Catalog. Specific values are set by our curators and should not be treated as definitive.

'level' is the distance from the top of an organizational hierarchy. It is determined by a governmental org chart. The hierarchical level may differ from the perceived power and importance of an entity.

    level   examples
    -----   --------
      0     US Federal Government
      1     Executive Branch
            Judicial Branch
            Legislative Branch
      2     Department of Commerce
            Department of Defense
            Department of the Treasury
            Department of Transportation
            Environmental Protection Agency
            Executive Office of the President
            House of Representatives
            Senate
            Social Security Administration
            Tennessee Valley Authority
            The Supreme Court
      3     Central Command
            Congressional Budget Office
            Department of the Navy
            Forest Service
            Internal Revenue Service
            Library of Congress
            Office of Management and Budget
            U.S. Geological Survey
            United States Botanic Garden
            United States Tax Court
      4     Bureau of Labor Statistics, Department of Labor
            Congressional Research Service, Library of Congress
            Copyright Office, Library of Congress
            Office of Public Affairs, Department of Labor
