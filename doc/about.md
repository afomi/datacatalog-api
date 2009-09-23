# About the National Data Catalog API

## Pre-Release Note

The National Data Catalog has not yet been launched. We plan on an early October 2009 release for both the Web App and the API.

Please consider this to be early-stage documentation. We are releasing it now (in rough form) to help internal development and to solicit feedback from our community.

## Overview

The National Data Catalog, a project of the [Sunlight Labs](http://sunlightlabs.com), stores metadata about data sets and APIs published by all levels and branches of the United States government. The API is designed to help software developers search for, identify, and work with U.S. government data sources.

The National Data Catalog consists of several pieces:

* At the center is the API. (We say the center because the other services rely on it.)

* The API powers the [National Data Catalog Web app](http://nationaldatacatalog.com), intended for use by the public (e.g. reporters, researchers, and so on -- not only software developers).

* The catalog is kept up-to-date with the help of our users, curators, and automatic importers. The importers are Web services that talk directly to the API that populate the National Data Catalog with information from other Web sites and services.

* The API is intended to be open-ended; we encourage the development of third-party applications and tools built around it.

## Getting Access

Generally speaking, all API calls require an API key parameter (called api_key).

When we launch the National Data Catalog Web App, you will be able to get an API key by visiting [nationaldatacatalog.com](http://nationaldatacatalog.com).

## JSON Based

The API speaks [JSON](http://json.org/). It does not speak XML or HTML.

## Exploring with a Web Browser

For getting started quickly, we recommend using [Firefox](http://getfirefox.com) with two add-ons:

1. [JSONView](https://addons.mozilla.org/en-US/firefox/addon/10869) so that JSON renders in Firefox (instead of downloading a file)
2. [REST Client](https://addons.mozilla.org/en-US/firefox/addon/9780) so you can easily use the four [HTTP](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)  verbs from Firefox:  GET, POST, PUT, and DELETE.

To view general meta data about the API:

    GET http://sandbox.nationaldatacatalog.com/
    
To view available resources for anonymous access:

    GET http://sandbox.nationaldatacatalog.com/resources

To view available resources accessible via a particular API key:

    GET http://sandbox.nationaldatacatalog.com/resources?api_key=MY_API_KEY

To view status of an API key, including the associated user ID:

    GET http://sandbox.nationaldatacatalog.com/checkup?api_key=MY_API_KEY

## API Design Principles

The National Data Catalog API is designed to be a Resource-Oriented Architecture (ROA), as explained by [Leonard Richardson](http://www.crummy.com/) and [Sam Ruby](http://intertwingly.net/) in [RESTful Web Services](http://oreilly.com/catalog/9780596529260). This means that the API is (1) organized around resources, (2) accessible using a uniform interface
(3) careful to return correct HTTP status codes, and (4) interconnected with hyperlinks:

1. Each resource is named with one or more [URI](http://en.wikipedia.org/wiki/Uniform_Resource_Identifier)s.

2. The uniform interface defines [CRUD](http://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on each resource using four HTTP verbs: GET, POST, PUT, and DELETE.

3. A good list of HTTP status codes can be found in [several](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes) [places](http://www.w3.org/Protocols/HTTP/HTRESP.html). For the purpose of this API, the most relevant status codes are:

    * 200 OK
    * 201 Created
    * 301 Moved Permanently
    * 303 See Other
    * 400 Bad Request
    * 401 Unauthorized
    * 403 Forbidden
    * 404 Not Found
    * 500 Internal Server Error
    * 503 Service Unavailable

4. You can navigate the API by following links (hypermedia). This matches up with the fourth constraint of [REST's four interface constraints](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_5) by [Roy Fielding](http://roy.gbiv.com/): "identification of resources; manipulation of resources through representations; self-descriptive messages; and, hypermedia as the engine of application state." Put another way, this is what [Joe Gregorio calls Hypertext Navigation](http://www.xml.com/pub/a/2005/04/06/restful.html) (as opposed to URI Construction). 

## Join Our Community

Here are some ways to get involved:

* the [National Data Catalog Mailing List](http://groups.google.com/group/datacatalog)
* the [National Data Catalog project page](http://sunlightlabs.com/projects/datacatalog/)
* the [Sunlight Labs Mailing List](http://groups.google.com/group/sunlightlabs)
* the [transparency chat room](irc://chat.freenode.net/transparency)

You might also like to read our [inaugural blog post](http://www.sunlightlabs.com/blog/2009/kickoff-national-data-catalog/) about the project.
