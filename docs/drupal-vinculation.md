## Vinculate DSpace with an existing Drupal instance (used as an Authority Management solution)

> This only is intended for a development environment that uses an authorities management solution based on [Drupal](https://www.drupal.org/) + [ARC2Store](https://www.drupal.org/project/arc2_store) + [RDF Indexer](https://www.drupal.org/project/rdf_indexer) + [Search API](https://www.drupal.org/project/search_api) modules. For more information you can read http://sedici.unlp.edu.ar/handle/10915/69754 (only in spanish available). This solution is used at [SEDICI DSpace](https://github.com/sedici/DSpace) implementation.

If you want to vinculate your DSpace installation with an existing Drupal instance (used as an authority management solution), you must follow the steps below.

First you must create a container with a Drupal instance, as explained at https://github.com/sedici/docker4drupal/blob/drupal-sedici/how_to_use.md. You must mount the Drupal service at the same Docker network where DSpace is running.

When you have configured the Drupal container, then you must edit the URL where the **Sparql endpoint** is mounted ([sparql-authorities.cfg](https://github.com/sedici/DSpace/blob/sedici_master/dspace/config/modules/sparql-authorities.cfg)). In example:
```
sparql-authorities.endpoint.url = http://drupal_sedici_nginx/sparql?output=xml
```
